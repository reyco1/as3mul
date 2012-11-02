package com.reyco1.multiuser.debug
{
	import flash.text.TextField;
	import flash.utils.getQualifiedClassName;

	/**
	 * A class used to trace. If a text field is specified, then all traces made through this class will be outputted on to that field.
	 * @author reyco1
	 * 
	 */	
	public class Logger
	{
		/**
		 * No traces allowed 
		 */		
		public static const NONE:int 				= 0;
		/**
		 * All traces allowed 
		 */		
		public static const ALL:int 				= 1;
		/**
		 * Only traces out internal net status traces 
		 */		
		public static const NET_STATUS_ONLY:int 	= 2;
		/**
		 * Traces out all traces except net status traces 
		 */		
		public static const ALL_BUT_NET_STATUS:int  = 3;
		/**
		 * Only traces user specified traces 
		 */		
		public static const OWN:int 				= -1;
		
		/**
		 * Level of trace 
		 */		
		public static var LEVEL:int = OWN;
		
		/**
		 * Text area where to dum traces 
		 */		
		public static var textArea:TextField;
		
		/**
		 * Outputs user defined and framework level traces 
		 * @param traceStr trace string
		 * @param owner where the trace originates from. Usially a class name goes here
		 * @param isNetstatusTrace specifies if the trace should be a NetStatusEvent trace or not
		 * 
		 */		
		public static function log(traceStr:String, owner:* = null, isNetstatusTrace:Boolean = false):void
		{
			var classString:String = getQualifiedClassName(owner).split("::")[1] || "Logger";
			var toTrace:String = "["+ classString +"] " + traceStr;
			
			if(LEVEL > NONE)
			{
				if(shouldTrace(isNetstatusTrace))
					write(toTrace);
			}
			else if(LEVEL == OWN && classString == "Logger")
			{
				write(toTrace);
			}
		}
		
		private static function shouldTrace(isNetstatusTrace:Boolean):Boolean
		{
			return LEVEL == ALL || isNetstatusTrace && LEVEL == NET_STATUS_ONLY || !isNetstatusTrace && LEVEL == ALL_BUT_NET_STATUS;
		}
		
		private static function write(toTrace:String):void
		{
			trace(toTrace);
			if(textArea)
				textArea.appendText(toTrace + "\n");
		}
	}
}