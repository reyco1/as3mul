package com.reyco1.multiuser.events
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * Centralized event dispatcher that handles the dispatching of and listening to all events. 
	 * @author reyco1
	 * 
	 */	
	public class P2PDispatcher
	{
		private static var instance:EventDispatcher
		
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=true):void
		{
			invalidate();
			instance.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			invalidate();
			instance.removeEventListener(type, listener, useCapture);
		}
		
		public static function dispatchEvent(event:*):Boolean
		{
			invalidate();
			return instance.dispatchEvent(event);
		}
		
		public static function hasEventListener(type:String):Boolean
		{
			invalidate();
			return instance.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean
		{
			invalidate();
			return instance.willTrigger(type);
		}
		
		private static function invalidate():void
		{
			instance = instance == null ? new EventDispatcher() : instance;
		}
	}
}