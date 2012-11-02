package com.reyco1.multiuser.group
{
	import com.reyco1.multiuser.data.MessageObject;
	import com.reyco1.multiuser.data.UserObject;
	import com.reyco1.multiuser.debug.Logger;
	import com.reyco1.multiuser.events.ChatMessageEvent;
	import com.reyco1.multiuser.events.P2PDispatcher;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	/**
	 * Subclass of the UserGroup class that adds functionality to send and recieve chat messages both private and public.
	 * @author reyco1
	 * 
	 */	
	public class ChatGroup extends UserGroup
	{
		/**
		 * Creates an instace of the ChatGroup class 
		 * @param connection
		 * @param groupspec
		 * @param userName
		 * @param userDetails
		 * 
		 */		
		public function ChatGroup(connection:NetConnection, groupspec:String, userName:String, userDetails:Object)
		{
			super(connection, groupspec, userName, userDetails);
			addEventListener(NetStatusEvent.NET_STATUS, handleNetStatus);
		}
		
		protected function handleNetStatus(event:NetStatusEvent):void
		{
			Logger.log(event.info.code, this, true);
			
			switch (event.info.code)
			{
				case "NetGroup.Posting.Notify":
					if(event.info.message.type == "chat")
						receiveMessage(event.info.message);
					break;
				
				case "NetGroup.SendTo.Notify":
					if (event.info.fromLocal)
					{
						if(event.info.message.type == "chat")
							receiveMessage(event.info.message);
					}
					else
					{
						sendToNearest(event.info.message, event.info.message.destination);
					}
					break;
			}
		}
		
		/**
		 * Sends a message to the group or to an individual user. 
		 * @param messageStr
		 * @param targetUser
		 * 
		 */		
		public function sendMessage(messageStr:String, targetUser:UserObject = null):void
		{
			Logger.log("sending message", this);
			
			var message:MessageObject = new MessageObject();
			message.type 	= "chat"
			message.sender 	= convertPeerIDToGroupAddress(myUser.id);
			message.user 	= myUser.name;
			message.text 	= messageStr;
			
			if(targetUser)
			{
				message.destination = convertPeerIDToGroupAddress(targetUser.id);
				sendToNearest(message, message.destination);
			}
			else
			{
				post(message);
			}
			P2PDispatcher.dispatchEvent(new ChatMessageEvent(ChatMessageEvent.RECIEVE, message));
		}
		
		protected function receiveMessage(msg:Object):void
		{			
			Logger.log("message recieved", this);
			
			var message:MessageObject = MessageObject.make(msg);
			
			if(message.destination != null)
			{
				message.pm = true;
				P2PDispatcher.dispatchEvent(new ChatMessageEvent(ChatMessageEvent.RECIEVE, message));
			}
			else
			{
				P2PDispatcher.dispatchEvent(new ChatMessageEvent(ChatMessageEvent.RECIEVE, message));
			}
		}
	}
}