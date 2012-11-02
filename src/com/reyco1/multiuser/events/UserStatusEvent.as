package com.reyco1.multiuser.events
{
	import com.reyco1.multiuser.data.UserObject;
	
	import flash.events.Event;
	
	public class UserStatusEvent extends Event
	{
		public static const CONNECTED:String	= "UserStatusEvent.connected";
		public static const DISCONNECTED:String	= "UserStatusEvent.disconnected";
		public static const USER_EXPIRED:String	= "UserStatusEvent.expired";
		public static const USER_IDLE:String	= "UserStatusEvent.userIdle";
		public static const USER_ADDED:String	= "UserStatusEvent.userAdded";
		public static const USER_REMOVED:String	= "UserStatusEvent.userRemoved";
		
		public var user:UserObject;
		
		public function UserStatusEvent(type:String, userData:UserObject=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.user = userData;
			super(type, bubbles, cancelable);
		}
	}
}