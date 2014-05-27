package com.reyco1.multiuser.filesharing
{
	import com.reyco1.multiuser.debug.Logger;
	import com.reyco1.multiuser.events.FileShareEvent;
	import com.reyco1.multiuser.events.P2PDispatcher;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetGroup;
	import flash.utils.ByteArray;
	
	public class P2PFileSharer extends EventDispatcher
	{		
		private var netGroup:NetGroup;		
		private var autoShare:Boolean;
		
		public var localFileLoader:LocalFileLoader;
		public var p2pSharedObject:P2PSharedObject;
		
		public function P2PFileSharer(group:NetGroup)
		{
			netGroup = group;
			netGroup.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
		}
		
		public function browseForFile( autoShare:Boolean = true ):void
		{
			this.autoShare = autoShare;
			
			if(!localFileLoader)
			{
				localFileLoader = new LocalFileLoader();
			}
			
			localFileLoader.addEventListener(Event.COMPLETE, handleFileReady);
			localFileLoader.browseFileSystem();
		}
		
		protected function handleFileReady(event:Event):void
		{
			localFileLoader.removeEventListener(Event.COMPLETE, handleFileReady);
			
			P2PDispatcher.dispatchEvent( new FileShareEvent(FileShareEvent.FILE_TO_SHARE_READY, localFileLoader.p2pSharedObject, localFileLoader.file) );
			
			if(autoShare)
			{
				startSharing( localFileLoader.p2pSharedObject );
			}
		}
		
		public function startSharing( p2pSharedObject:P2PSharedObject = null ):void
		{
			if(p2pSharedObject == null)
				p2pSharedObject = localFileLoader.p2pSharedObject;
			
			writeText("startSharing - chunks shared: " + p2pSharedObject.packetLenght);
			this.p2pSharedObject = p2pSharedObject;			
			netGroup.addHaveObjects(0, p2pSharedObject.packetLenght);
		}
		
		public function startReceiving():void
		{
			writeText("Initializing share receive...");
			p2pSharedObject = new P2PSharedObject();
			p2pSharedObject.chunks = new Object();	
			receiveObject(0);
		}
		
		protected function netStatus(event:NetStatusEvent):void
		{
			switch(event.info.code)
			{
				case "NetGroup.Replication.Fetch.SendNotify":
					writeText("index: "+event.info.index);					
					break;
				
				case "NetGroup.Replication.Fetch.Failed":
					writeText("index: "+event.info.index);					
					break;
				
				case "NetGroup.Replication.Fetch.Result":
					
					netGroup.addHaveObjects(event.info.index,event.info.index);					
					p2pSharedObject.chunks[event.info.index] = event.info.object;
					
					if(event.info.index == 0)
					{
						p2pSharedObject.packetLenght = Number(event.info.object);
						writeText("p2pSharedObject.packetLenght: " + p2pSharedObject.packetLenght);						
						receiveObject(1);
						
					}
					else
					{
						if(event.info.index+1<p2pSharedObject.packetLenght)
						{
							receiveObject(event.info.index + 1);
						}
						else
						{
							writeText("Receiving DONE");
							writeText("p2pSharedObject.packetLenght: " + p2pSharedObject.packetLenght);
							
							p2pSharedObject.data = new ByteArray();
							
							for(var i:int = 1; i < p2pSharedObject.packetLenght; i++)
							{
								p2pSharedObject.data.writeBytes(p2pSharedObject.chunks[i]);
							}
							
							writeText("p2pSharedObject.data.bytesAvailable: " + p2pSharedObject.data.bytesAvailable);
							writeText("p2pSharedObject.data.length: " + p2pSharedObject.data.length);
							
							dispatchEvent( new Event(Event.COMPLETE) );
						}
					}				
					
					break;
				
				case "NetGroup.Replication.Request":
					
					netGroup.writeRequestedObject(event.info.requestID, p2pSharedObject.chunks[event.info.index])
					writeText("ID: " + event.info.requestID+", index: " + event.info.index);
					break;
				
				default:
					break;
			}
		}		
		
		protected function receiveObject(index:Number):void
		{
			netGroup.addWantObjects( index, index );
			p2pSharedObject.actualFetchIndex = index;
		}
		
		protected function writeText(str:String):void
		{
			Logger.log( str, this );
		}		
	}
}