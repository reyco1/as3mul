package com.reyco1.multiuser
{
	import com.reyco1.multiuser.channel.ChannelManager;
	import com.reyco1.multiuser.core.Session;
	import com.reyco1.multiuser.data.UserObject;
	import com.reyco1.multiuser.debug.Logger;
	import com.reyco1.multiuser.events.ChatMessageEvent;
	import com.reyco1.multiuser.events.FileShareEvent;
	import com.reyco1.multiuser.events.UserStatusEvent;
	import flash.events.EventDispatcher;
	
	/**
	 * A Facade for the Session, ChannelManager and ChatGroup instances for this session
	 * @author Reynaldo
	 * 
	 */	
	public class MultiUserSession
	{
		/**
		 * A reference to the Session instance used in this connection 
		 */		
		public  var session			:Session;
		/**
		 * A reference to the Channel Manager used in this connection 
		 */		
		public  var channelManager	:ChannelManager;
		/**
		 * The function that should be executed when we recieve an opbject from another user (should have 2 arguments: peerID and object) 
		 */		
		public  var onObjectRecieve	:Function;
		/**
		 * The function that should be executed when a user is added to the roster (should have one argument of type UserObject) 
		 */	
		public  var onUserAdded		:Function;
		/**
		 * The function that should be executed when a user is removed from the roster (should have one argument of type UserObject) 
		 */	
		public  var onUserRemoved	:Function;
		/**
		 * The function that should be executed when a user is idle (should have one argument of type UserObject) 
		 */	
		public  var onUserIdle		:Function;
		/**
		 * The function that should be executed when a user has expired (should have one argument of type UserObject) 
		 */	
		public  var onUserExpired	:Function;
		/**
		 * The function that should be executed when we connect to the user list (by this time, the NetCnnection is made and we are also connected to the NetGroup; should have one argument of type UserObject) 
		 */	
		public  var onConnect		:Function;
		/**
		 * The function that should be executed when ve recieve a chat message (should have one argument of type MessageObject) 
		 */	
		public 	var onChatMessage	:Function;
		/**
		 * Aboole indicating if the session is currently running or not 
		 */		
		public  var running			:Boolean;
		
		public var onFileReceived	:Function;
		public var onFileReady		:Function;
		
		private var p2pDispatcher:EventDispatcher = new EventDispatcher;
		
		private var serverAddress	:String;
		private var groupName		:String;
		
		/**
		 * Creates an instance of the MultiUserSession class 
		 * @param serverAddress
		 * @param groupName
		 * 
		 */		
		public function MultiUserSession(serverAddress:String, groupName:String = "defaultGroup")
		{
			this.serverAddress = serverAddress;
			this.groupName 	   = groupName;
			this.running	   = false;
		}
		
		
		/**
		 * Registers all the global event listeners by means of the P2PDispatcher class then proceeds to instantiate and connect the instance of the Session class 
		 * @param userName
		 * @param userDetails
		 * 
		 */
		public function connect(userName:String, userDetails:Object = null):void
		{

			p2pDispatcher.addEventListener(ChatMessageEvent.RECIEVE				, handleChatMessage);
			p2pDispatcher.addEventListener(UserStatusEvent.CONNECTED			, handleConnect);
			p2pDispatcher.addEventListener(UserStatusEvent.DISCONNECTED			, handleClose);
			p2pDispatcher.addEventListener(UserStatusEvent.USER_ADDED			, handleUserAdded);
			p2pDispatcher.addEventListener(UserStatusEvent.USER_REMOVED			, handleUserRemoved);
			p2pDispatcher.addEventListener(UserStatusEvent.USER_EXPIRED			, handleUserExpired);
			p2pDispatcher.addEventListener(UserStatusEvent.USER_IDLE			, handleUserIdle);
			p2pDispatcher.addEventListener(FileShareEvent.RECIEVE				, handleFileReceived);
			p2pDispatcher.addEventListener(FileShareEvent.FILE_TO_SHARE_READY	, handleFileReadyToShare);
			Logger.log("global listeners added", this);	
			
			session = new Session(serverAddress, groupName,p2pDispatcher);
			session.connect(userName, userDetails);
		}
		
		/**
		 * Sends an object to all connected users 
		 * @param object
		 * 
		 */		
		public function sendObject(object:*):void
		{
			channelManager.sendStream.send("receiveObject", myUser.id, object);
		}
		
		public function browseForFileToShare( autoShare:Boolean = true ):void
		{
			session.fileSharer.browseForFile( autoShare );
		}
		
		/**
		 * @private 
		 * @param peerID
		 * @param object
		 * 
		 */		
		public function receiveObject(peerID:String, object:Object):void
		{
			if(onObjectRecieve != null)
				onObjectRecieve.call(this, peerID, object);
		}
		
		/**
		 * Sends a chat message to all members of the group or to a specified user 
		 * @param message
		 * @param targetUser
		 * 
		 */		
		public function sendChatMessage(message:String, targetUser:UserObject = null):void
		{
			session.group.sendMessage(message, targetUser);
		}
		
		protected function handleChatMessage(event:ChatMessageEvent):void
		{
			Logger.log("chat message recieved", this);
			if(onChatMessage != null)
				onChatMessage(event.message);
		}
		
		/**
		 * Closes the connection and removes all associated Event Listeners.
		 * 
		 */		
		public function close():void
		{
			p2pDispatcher.removeEventListener(ChatMessageEvent.RECIEVE		, handleChatMessage);
			p2pDispatcher.removeEventListener(UserStatusEvent.CONNECTED		, handleConnect);
			p2pDispatcher.removeEventListener(UserStatusEvent.DISCONNECTED	, handleClose);
			p2pDispatcher.removeEventListener(UserStatusEvent.USER_ADDED	, handleUserAdded);
			p2pDispatcher.removeEventListener(UserStatusEvent.USER_REMOVED	, handleUserRemoved);
			p2pDispatcher.removeEventListener(UserStatusEvent.USER_EXPIRED	, handleUserExpired);
			p2pDispatcher.removeEventListener(UserStatusEvent.USER_IDLE		, handleUserIdle);
			Logger.log("global listeners removed", this);
			
			session.close();
		}
		
		protected function handleConnect(event:UserStatusEvent):void
		{
			Logger.log("initializing ChannelManager", this);
			running = true;
			channelManager = new ChannelManager(session);
			
			if(onConnect != null)
				onConnect(event.user);
		}
		
		protected function handleClose(event:UserStatusEvent):void
		{
			running = false;
		}
		
		protected function handleUserAdded(event:UserStatusEvent):void
		{			
	
			Logger.log("user added: " + event.user.name , this);
			if(event.user.id != myUser.id)
			{
				channelManager.addChannel(event.user.id, this);
				
				if(onUserAdded != null)
					onUserAdded(event.user);
			}
		}
		
		protected function handleUserRemoved(event:UserStatusEvent):void
		{
			Logger.log("user removed: " + event.user.name , this);
			if(event.user.id != myUser.id)
			{
				channelManager.removeChannel(event.user.id);
				
				if(onUserRemoved != null)
					onUserRemoved(event.user);
			}
		}
		
		protected function handleUserExpired(event:UserStatusEvent):void
		{
			Logger.log("user expired: " + event.user.name , this);
			if(onUserExpired != null)
				onUserExpired(event.user);
		}
		
		protected function handleUserIdle(event:UserStatusEvent):void
		{
			Logger.log("user idle: " + event.user.name , this);
			if(onUserIdle != null)
				onUserIdle(event.user);
		}
		
		private function handleFileReceived(event:FileShareEvent):void
		{
			Logger.log("File received.", this);
			if(onFileReceived != null)
				onFileReceived( event.fileObject );
		}
		
		private function handleFileReadyToShare(event:FileShareEvent):void
		{
			Logger.log("File received.", this);
			if(onFileReady != null)
				onFileReady( event.file );
		}
		
		/**
		 * Returns our instance of the UserObject 
		 * @return 
		 * 
		 */		
		public function get myUser():Object
		{
			return session != null ? session.group.myUser : {};
		}
		
		/**
		 * Returns the total number of current users in the roster 
		 * @return 
		 * 
		 */		
		public function get userCount():int
		{
			return session != null ? session.group.userCount : 0;
		}
		
		/**
		 * Returns an array of all UserObjects of all the connected users 
		 * @return 
		 * 
		 */		
		public function get userArray():Array
		{
			return session != null ? session.group.userArray : [];
		}
		
		/**
		 * Returns an array with all UserObjects of all the connected users 
		 * @return 
		 * 
		 */		
		public function get userList():Object
		{
			return session != null ? session.group.userList : {};
		}
	}
}