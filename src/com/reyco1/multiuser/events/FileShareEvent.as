package com.reyco1.multiuser.events
{
	import com.reyco1.multiuser.filesharing.P2PSharedObject;
	
	import flash.events.Event;
	import flash.net.FileReference;

	public class FileShareEvent extends Event
	{
		public static const RECIEVE:String = "fileRecieved";
		public static const FILE_TO_SHARE_READY:String = "fileToShareReady";
		
		public var fileObject:P2PSharedObject;
		public var file:FileReference;
		
		public function FileShareEvent(type:String, fileObject:P2PSharedObject, file:FileReference=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.fileObject = fileObject;
			this.file = file;
			super(type, bubbles, cancelable);
		}
	}
}