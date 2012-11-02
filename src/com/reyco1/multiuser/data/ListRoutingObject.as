package com.reyco1.multiuser.data
{
	public class ListRoutingObject
	{
		public static const REQEUST:String  = "ListRoutingObject.request";
		public static const RESPONSE:String = "ListRoutingObject.response";
		
		public var userList:Object;
		public var sender:String;
		public var destination:String;
		public var time:int;
		public var type:String;
		
		public function ListRoutingObject()
		{
		}
	}
}