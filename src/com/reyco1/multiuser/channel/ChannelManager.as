package com.reyco1.multiuser.channel
{
	import com.reyco1.multiuser.core.Session;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetStream;
	
	/**
	 * Manages all RealtimeChannel instances 
	 * @author Reynaldo
	 * 
	 */	
	public class ChannelManager extends EventDispatcher
	{
		public var channels:Vector.<RealtimeChannel>;
		
		private var session:Session;
		public  var sendStream:NetStream;
		public  var streamMethod:String;
		public  var myCamera:Camera;
		public  var myMic:Microphone;
		
		/**
		 * Creates an instance of the ChannelManager class 
		 * @param session
		 * @param streamMethod
		 * 
		 */		
		public function ChannelManager(session:Session, streamMethod:String = NetStream.DIRECT_CONNECTIONS)
		{
			this.session 	  = session;
			this.streamMethod = streamMethod;
			this.channels  	  = new Vector.<RealtimeChannel>();
			
			initializeSendStream();
		}
		
		private function initializeSendStream():void
		{
			sendStream = new NetStream(session.connection, streamMethod);
			sendStream.publish("media");
			
			var sendStreamClient:Object = new Object();
			sendStreamClient.onPeerConnect = function(callerns:NetStream):Boolean
			{
				return true;
			}
			
			sendStream.client = sendStreamClient;
		}
		
		/**
		 * Creates a Camera instance and attaches it to the send stream. The Camera instance is returned where you can then add it to a Video instance or change its properties. 
		 * @param snapshotMilliseconds
		 * @return 
		 * 
		 */		
		public function sendCamera(snapshotMilliseconds:int = -1):Camera
		{
			myCamera = Camera.getCamera();
			sendStream.attachCamera( myCamera, snapshotMilliseconds );
			return myCamera;
		}
		
		/**
		 * Detaches the Camera instance and sets it to null. 
		 * 
		 */		
		public function stopCamera():void
		{
			sendStream.attachCamera( null );
			myCamera = null;
		}
		
		/**
		 * Creates a Microphone instance and attaches it to the send stream. The Microphone instance is then returned where you can then change its proerties. 
		 * @return 
		 * 
		 */		
		public function sendAudio():Microphone
		{
			myMic = Microphone.getEnhancedMicrophone();
			sendStream.attachAudio( myMic );
			return myMic;
		}
		
		/**
		 * Detaches the Microphone instance from the send stream and then sets it to null. 
		 * 
		 */		
		public function stopAudio():void
		{
			sendStream.attachAudio( null );
			myMic = null;
		}
		
		/**
		 * Adds a RealtimeChannel instance 
		 * @param peerID
		 * @param clientObject
		 * 
		 */		
		public function addChannel(peerID:String, clientObject:Object):void
		{
			var realtimeChannel:RealtimeChannel = new RealtimeChannel(session.connection, peerID, session.group.myUser.id, clientObject);
			channels.push(realtimeChannel);
		}
		
		
		/**
		 * Returns an instance of the RealtimeChannel which matches the peerID provided 
		 * @param peerID
		 * @return 
		 * 
		 */
		public function getChannelByPeerID(peerID:String):RealtimeChannel
		{
			var channel:RealtimeChannel;
			for (var a:int = 0; a < channels.length; a++) 
			{
				if(channels[a].peerID == peerID)
				{
					channel = channels[a];
					break;
				}
			}
			return channel;			
		}
		
		/**
		 * Removes a RealtimeChannel instance 
		 * @param peerID
		 * 
		 */		
		public function removeChannel(peerID:String):void
		{
			for(var i:uint = 0; i<channels.length; i++)
			{
				if(channels[i].peerID == peerID)
				{
					channels[i].close();
					channels.splice(i, 1);
					break;
				}
			}
		}
	}
}