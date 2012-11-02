package com.reyco1.multiuser.group
{
	import com.reyco1.multiuser.data.KeepAliveObject;
	import com.reyco1.multiuser.data.ListRoutingObject;
	import com.reyco1.multiuser.data.UserObject;
	import com.reyco1.multiuser.debug.Logger;
	import com.reyco1.multiuser.events.P2PDispatcher;
	import com.reyco1.multiuser.events.UserStatusEvent;
	
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	/**
	 * Core class for the connected user roster.
	 * @author reyco1
	 * 
	 */	
	public class UserGroup extends NetGroup
	{
		/**
		 * Interval in which a user should be considered expired (defaults to 20 seconds) 
		 */		
		public static var EXPIRE_TIMEOUT:Number 	= 20000;
		/**
		 * Interval in which a user should be considered idle (defaults to 10 seconds) 
		 */	
		public static var IDEL_TIMEOUT:Number 		= 10000;
		/**
		 * Interval in which a we should tell other users we are still active (defaults to 3 seconds) 
		 */	
		public static var KEEP_ALIVE_INTERVAL:int 	= 3000;
		/**
		 * Interval in which a we should check for expired/idle users (defaults to 3 seconds) 
		 */	
		public static var EXPIRED_INTERVAL:int		= 3000;
		
		/**
		 * Your UserObject instance. 
		 */		
		public var myUser:UserObject;
		/**
		 * The object containing all the UserObject instances (one per connected user) 
		 */		
		public var userList:Object;
		
		protected var userName:String;
		protected var userDetails:Object;		
		protected var nearID:String;
		protected var groupAddress:String;
		protected var neighbored:Boolean;
		protected var keepAliveTimer:Timer;
		protected var expiredTimer:Timer;
		
		/**
		 * Creates an instance of the UserGroup class. This class is the core of the user roster. It's main purpose is to always keep an organized list of all connected users. It
		 * also handles making sure that you are aware of all users that are idle or have expired and dispatches event whenever the list is updated. Though this class is made to 
		 * be subclassed, it can still be used as a standalone class to maintain a user list.
		 *  
		 * @param connection
		 * @param groupspec
		 * @param userName
		 * @param userDetails
		 * 
		 */		
		public function UserGroup(connection:NetConnection, groupspec:String, userName:String, userDetails:Object)
		{
			super(connection, groupspec);
			
			this.userList	 = new Object();
			this.userName 	 = userName;
			this.userDetails = userDetails;
			this.neighbored	 = false;
			
			connection.addEventListener(NetStatusEvent.NET_STATUS, createOwnUser);
			addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		}
		
		protected function netStatusHandler(event:NetStatusEvent):void
		{
			Logger.log(event.info.code, this, true);
			
			switch(event.info.code)
			{
				case "NetGroup.Neighbor.Connect":
					if(!neighbored)
					{
						neighbored = true;
						initializeTimers();
						announceSelf();
						requestUserList(event.info.neighbor);
						setTimeout(announceSelf, 15000);
					}
					break;
				
				case "NetGroup.Posting.Notify":	
					if(event.info.message.type != null && event.info.message.type == "keepAlive")
						resolveUserKeepAliveRequest(event.info.message);
					break;
				
				case "NetGroup.Neighbor.Disconnect":
					for(var user:String in userList)
					{
						if(userList[user].id == event.info.peerID)
						{
							var temp:UserObject = userList[user];
							delete userList[user];
							P2PDispatcher.dispatchEvent(new UserStatusEvent(UserStatusEvent.USER_REMOVED, temp));
						}
					}
					break;
				
				case "NetGroup.SendTo.Notify":
					processRoutedNotification(event.info);
					break;
			}
		}
		
		protected function requestUserList(neighborID:String):void
		{
			Logger.log("user list requested", this);
			
			var request:ListRoutingObject = new ListRoutingObject();
			request.destination			  = neighborID;
			request.sender 				  = groupAddress;
			request.type 				  = ListRoutingObject.REQEUST;
			
			sendToNearest(request, request.destination);
		}
		
		protected function processRoutedNotification(info:Object):void
		{
			if(info.message.destination == groupAddress)
			{
				if(info.message.type == ListRoutingObject.REQEUST)
				{
					Logger.log("responding to user list request", this);
					
					var response:ListRoutingObject 	= new ListRoutingObject();
					response.type 		 			= ListRoutingObject.RESPONSE;
					response.userList 				= userList;
					response.destination 			= info.message.sender;
					response.time					= getTimer();
					
					sendToNearest(response, response.destination);
				}
				
				if(info.message.type == ListRoutingObject.RESPONSE)
				{
					Logger.log("user list recieved", this);
					
					var users:Object 		 = info.message.userList;
					var neighborsTime:Number = info.message.time;
					var neighborsAge:Number  = 0;
					var localAge:Number 	 = 0;					
					
					for(var user:String in users) 
					{
						neighborsAge = neighborsTime - users[user].stamp + 1000;
						
						if(userList[user] == null)
						{
							var temp:UserObject = new UserObject();
							temp.stamp 		  = getTimer() - neighborsAge;
							temp.address 	  = users[user].address;
							temp.details 	  = users[user].details;
							temp.id 		  = users[user].id;
							temp.name 		  = users[user].name;
							
							userList[user] = temp;
							
							P2PDispatcher.dispatchEvent(new UserStatusEvent(UserStatusEvent.USER_ADDED, temp));
						}
						else
						{
							localAge = getTimer() - userList[user].stamp;
							
							if( neighborsAge < localAge )
							{
								userList[user].stamp = getTimer() - neighborsAge;
							}
						}
					}
				}
			}
			else if(!info.fromLocal)
			{
				Logger.log("routing user list request", this);
				sendToNearest(info.message, info.message.destination);
			}
		}
		
		protected function resolveUserKeepAliveRequest(user:Object):void
		{
			Logger.log("resolving keep alive request", this);
			
			user.stamp = getTimer();
			
			if(userList[user.id] == null)
			{
				var temp:UserObject = new UserObject();
				temp.address 	  = user.address;
				temp.details 	  = user.details;
				temp.id 		  = user.id;
				temp.name 	 	  = user.name;
				temp.stamp 		  = user.stamp;
				
				userList[user.id] = temp;
				
				P2PDispatcher.dispatchEvent(new UserStatusEvent(UserStatusEvent.USER_ADDED, temp));
			}
			
			userList[user.id].stamp = getTimer();
		}
		
		protected function initializeTimers():void
		{
			Logger.log("initializing expired and alive timers", this);
			
			keepAliveTimer = new Timer( KEEP_ALIVE_INTERVAL );
			keepAliveTimer.addEventListener(TimerEvent.TIMER, announceSelf);
			keepAliveTimer.start();
			
			expiredTimer = new Timer( EXPIRED_INTERVAL );
			expiredTimer.addEventListener(TimerEvent.TIMER, invalidateUserList);
			expiredTimer.start();
		}
		
		protected function announceSelf(event:TimerEvent = null):void
		{
			Logger.log("announcing self", this);
			
			var keepAliveObject:KeepAliveObject = new KeepAliveObject();
			keepAliveObject.serialNumber = getTimer();
			keepAliveObject.name		 = userName;
			keepAliveObject.id			 = nearID;	
			keepAliveObject.stamp		 = myUser.stamp;
			keepAliveObject.address		 = myUser.address;
			keepAliveObject.details		 = myUser.details;
			
			post( keepAliveObject );
			
			myUser.stamp = getTimer();
		}
		
		protected function invalidateUserList(event:TimerEvent = null):void
		{
			Logger.log("invalidating user list", this);
			
			var currentTimeStamp:int = getTimer();
			var userAge:int = 0;
			
			for(var user:String in userList)
			{
				if(userList[user].id == nearID)
					continue;
				
				userAge = currentTimeStamp - userList[user].stamp
				
				if(userAge > EXPIRE_TIMEOUT)
				{
					P2PDispatcher.dispatchEvent(new UserStatusEvent(UserStatusEvent.USER_EXPIRED, userList[user]));
					delete userList[user];
					continue;
				}
				
				if(userAge > IDEL_TIMEOUT)
				{
					P2PDispatcher.dispatchEvent(new UserStatusEvent(UserStatusEvent.USER_IDLE, userList[user]));
					continue;
				}
			}
		}
		
		protected function createOwnUser(event:NetStatusEvent):void
		{
			Logger.log("joined. creating own user", this);
			
			if(event.info.code == "NetGroup.Connect.Success")
			{
				(event.target as NetConnection).removeEventListener(NetStatusEvent.NET_STATUS, createOwnUser);
				
				myUser 			= new UserObject();
				myUser.id 	    = nearID = (event.target as NetConnection).nearID;
				myUser.address  = groupAddress = convertPeerIDToGroupAddress(myUser.id );
				myUser.name 	= userName;
				myUser.details 	= userDetails;
				myUser.stamp 	= getTimer();
				myUser.address 	= groupAddress;
				
				userList[nearID] = myUser;
				
				P2PDispatcher.dispatchEvent(new UserStatusEvent(UserStatusEvent.CONNECTED, userList[nearID]));
			}
		}		
		
		/**
		 * Returns all connected users (UserObjects) in an Array 
		 * @return 
		 * 
		 */		
		public function get userArray():Array
		{
			var arr:Array = [];
			for(var user:String in userList)
			{
				arr.push( userList[user] );
			}
			return arr;
		}
		
		/**
		 * Returns the total number of users 
		 * @return 
		 * 
		 */		
		public function get userCount():int
		{
			return this.userArray.length;
		}
	}
}