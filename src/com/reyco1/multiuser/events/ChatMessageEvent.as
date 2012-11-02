package com.reyco1.multiuser.events
{
	import com.reyco1.multiuser.data.MessageObject;
	
	import flash.events.Event;
	
	public class ChatMessageEvent extends Event
	{
		public static const RECIEVE:String = "chatRecieved";
		
		public var message:MessageObject;
		
		public function ChatMessageEvent(type:String, message:MessageObject, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.message = message;
			super(type, bubbles, cancelable);
		}
	}
}