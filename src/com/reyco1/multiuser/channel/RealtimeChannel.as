package com.reyco1.multiuser.channel
{
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	/**
	 * Creates a DIRECT_CONNECTION NetStream instance between 2 peers
	 * @author Reynaldo
	 * 
	 */	
	public class RealtimeChannel
	{
		public  var peerID:String;
		
		private var receiveStream:NetStream;		
		private var myPeerID:String;		
		private var client:Object;
		
		public function RealtimeChannel(connection:NetConnection, peerID:String, myPeerID:String, client:Object)
		{
			this.peerID 	= peerID;
			this.myPeerID 	= myPeerID;
			this.client 	= client;
			
			receiveStream = new NetStream(connection, peerID);
			receiveStream.client = client;
			receiveStream.play("media");
		}
		
		/**
		 * Closes this NetStream connection 
		 * 
		 */		
		public function close():void
		{
			receiveStream.close();
		}
		
		/**
		 * Determines if incoming audio should play on this stream 
		 * @param value
		 * 
		 */		
		public function receiveAudio(value:Boolean):void
		{
			receiveStream.receiveAudio(value);
		}
		
		/**
		 * Sets the volume of the incoming audio 
		 * @param value
		 * 
		 */		
		public function setVolume(value:Number):void
		{
			if (receiveStream)
			{
				var volume:Number = value;
				var st:SoundTransform = new SoundTransform(volume);
				receiveStream.soundTransform = st;
			}
		}
		
		/**
		 * Specifies if incoming video plays on the stream. If a videoObject is specified, then the stream is attached to that object.
		 * @param value
		 * @param videoObject
		 * 
		 */		
		public function receiveVideo(value:Boolean, videoObject:Video = null):void
		{
			receiveStream.receiveVideo(value);
			if(videoObject)
				videoObject.attachNetStream( receiveStream );
		}
	}
}