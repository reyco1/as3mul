package com.reyco1.multiuser.core
{
	import com.reyco1.multiuser.debug.Logger;
	import com.reyco1.multiuser.events.P2PDispatcher;
	import com.reyco1.multiuser.events.UserStatusEvent;
	import com.reyco1.multiuser.group.ChatGroup;
	
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	
	/**
	 * Manages and controls the connection session, NetConnection instance and the ChatGroup instance.
	 * @author reyco1
	 * 
	 */	
	public class Session
	{
		/**
		 *NetConnection instanceused in this session 
		 */		
		public  var connection:NetConnection;
		/**
		 *ChatGroup instance used in this session 
		 */		
		public  var group:ChatGroup;
		/**
		 *A reference to your user name 
		 */		
		public  var userName:String;
		/**
		 *A reference to your user object (if specified) 
		 */		
		public  var userDetails:Object;
		
		private var serverAddress:String;
		private var groupName:String;
		private var groupspec:GroupSpecifier;
		private var isWifiOnly:Boolean;
		
		/**
		 * Creates a new instance of the Session class 
		 * @param serverAddress
		 * @param groupName
		 * 
		 */		
		public function Session(serverAddress:String, groupName:String)
		{
			super();
			
			this.serverAddress = serverAddress;
			this.groupName 	   = groupName;
			
			groupspec = new GroupSpecifier(groupName);
			groupspec.multicastEnabled		= true;
			groupspec.postingEnabled 		= true;
			groupspec.serverChannelEnabled 	= true;
			groupspec.routingEnabled 		= true;
			
			Logger.log("group specs with auth", this);
		}
		
		/**
		 * Initialtes the NetConnection object and stores your user name and details 
		 * @param userName
		 * @param userDetails
		 * 
		 */		
		public function connect(userName:String, userDetails:Object = null):void
		{
			Logger.log("connecting...", this);
			
			this.userName	 = userName;
			this.userDetails = userDetails;
			
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, handleNetStatusEvent);			
			connection.connect( serverAddress );
		}
		
		protected function handleNetStatusEvent(event:NetStatusEvent):void
		{
			Logger.log(event.info.code, this, true);
			
			switch(event.info.code)
			{
				case "NetConnection.Connect.Success":					
					joinGroup();					
					break;
				
				case "NetGroup.Connect.Failed":
				case "NetConnection.Connect.Rejected":
				case "NetConnection.Connect.AppShutdown":
				case "NetConnection.Connect.InvalidApp":
				case "NetConnection.Connect.Closed":					
					P2PDispatcher.dispatchEvent(new UserStatusEvent(UserStatusEvent.DISCONNECTED));					
					break;
			}
		}
		
		private function joinGroup():void
		{
			Logger.log("connected. joining group...", this);
			
			group = new ChatGroup(connection, groupspec.groupspecWithAuthorizations(), userName, userDetails);
			group.addEventListener(NetStatusEvent.NET_STATUS, handleNetStatusEvent);
		}
		
		/**
		 *Closes the connectionand sets the NetConnection instance to null 
		 * 
		 */		
		public function close():void
		{
			Logger.log("closing session...", this);
			
			connection.close();
			connection = null;
		}
	}
}