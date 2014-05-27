package com.reyco1.multiuser.filesharing
{
	import flash.utils.ByteArray;

	public class P2PSharedObject
	{
		
		public var size:Number 				= 0;
		public var packetLenght:uint 		= 0;
		public var actualFetchIndex:Number 	= 0;
		public var data:ByteArray			= null;
		public var chunks:Object 			= new Object();
		
		public function P2PSharedObject()
		{
		}
	}
}