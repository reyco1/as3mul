package com.reyco1.multiuser.filesharing
{
	import com.reyco1.multiuser.debug.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	public class LocalFileLoader extends EventDispatcher
	{
		public var file:FileReference;
		public var p2pSharedObject:P2PSharedObject;
		
		public function LocalFileLoader()
		{			
		}				
		
		public function browseFileSystem():void 
		{
			file = new FileReference();
			file.addEventListener(Event.SELECT						, selectHandler);
			file.addEventListener(IOErrorEvent.IO_ERROR				, ioErrorHandler);
			file.addEventListener(ProgressEvent.PROGRESS			, progressHandler);
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR	, securityErrorHandler)
			file.addEventListener(Event.COMPLETE					, completeHandler);
			file.browse();
		}
		
		protected function selectHandler(event:Event):void 
		{
			writeText("fileChosen");			
			writeText(file.name+" | "+file.size);			
			file.load();
		}
		
		protected function ioErrorHandler(event:IOErrorEvent):void 
		{
			writeText("ioErrorHandler: " + event);
		}
		
		protected function securityErrorHandler(event:SecurityErrorEvent):void 
		{
			writeText("securityError: " + event);
		}
		
		protected function progressHandler(event:ProgressEvent):void 
		{
			var file:FileReference = FileReference(event.target);
			writeText("progressHandler: bytesLoaded=" + event.bytesLoaded + "/" +event.bytesTotal);			
		}
		
		protected function completeHandler(event:Event):void 
		{
			writeText("completeHandler");
			
			p2pSharedObject 				= new P2PSharedObject();
			p2pSharedObject.size 			= file.size;
			p2pSharedObject.packetLenght 	= Math.floor(file.size / 64000) + 1;
			p2pSharedObject.data 			= file.data;
			
			p2pSharedObject.chunks 			= new Object();
			p2pSharedObject.chunks[0] 		= p2pSharedObject.packetLenght + 1;
			
			for(var i:int = 1; i < p2pSharedObject.packetLenght; i++)
			{
				p2pSharedObject.chunks[i] = new ByteArray();
				p2pSharedObject.data.readBytes(p2pSharedObject.chunks[i], 0, 64000);				
			}
			
			p2pSharedObject.chunks[p2pSharedObject.packetLenght] = new ByteArray();
			p2pSharedObject.data.readBytes(p2pSharedObject.chunks[i], 0, p2pSharedObject.data.bytesAvailable);
			
			p2pSharedObject.packetLenght += 1;
			
			writeText("----- p2pSharedObject -----");
			writeText("packetLenght: "+(p2pSharedObject.packetLenght));			
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function writeText(str:String):void
		{
			Logger.log( str, this );
		}
	}
}