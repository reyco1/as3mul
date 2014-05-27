package
{
	import com.bit101.components.PushButton;
	import com.reyco1.multiuser.MultiUserSession;
	import com.reyco1.multiuser.data.UserObject;
	import com.reyco1.multiuser.debug.Logger;
	import com.reyco1.multiuser.filesharing.P2PSharedObject;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	
	public class FileShareExample extends Sprite
	{
		private var connection:MultiUserSession;
		private var browseButton:PushButton;
		private var receiveButton:PushButton;
		private var loader:Loader;
		
		// you can get a key from here : http://labs.adobe.com/technologies/cirrus/
		private var SERVER_KEY:String = "";
		
		public function FileShareExample()
		{
			Logger.LEVEL = Logger.ALL_BUT_NET_STATUS;
			initialize();
		}
		
		private function initialize():void
		{
			// connect normally
			connection = new MultiUserSession(SERVER_KEY, "multiuser.share.test");
			
			// listen for when we connect
			connection.onConnect = handleConnect;
			
			// listen for when the file we want to send is ready to be shared
			connection.onFileReady = handleFileReadyToBeSent;
			
			// listen for when a file that is being shared with us has completed being transfered
			connection.onFileReceived = handleFileReceived;
			
			// connect
			connection.connect( "User" + Math.round((Math.random() * 100)) );
		}
		
		private function handleConnect( user:UserObject ):void
		{
			Logger.log("I'm connected: " + user.name + ", total: " + connection.userCount);
			
			// add a button to allow us to browse for a file to share.
			browseButton  = new PushButton(this, 10, 10, "Browse for file", handleBrowseRequest);
			
			// add a button to allow us to receive a file being shared.
			receiveButton = new PushButton(this, 10, 40, "Receive File", handleReceiveRequest);
		}
		
		private function handleBrowseRequest( event:MouseEvent ):void
		{
			// here we start browsing our local system for a file to share. The first parameter tells the FileSharer if it should
			// automatically share the file as soon as it is loaded. If set to false, you can then share it by calling
			// connection.session.fileSharer.startSharing();
			connection.browseForFileToShare( true );
		}		

		// this method receives an instance of the FileReference class whose 'data' property we can access to have direct access to
		// the file we want to share with the group. In this case we are simply just adding the image to the stage
		private function handleFileReadyToBeSent( file:FileReference ):void
		{
			loader = new Loader();
			loader.loadBytes( file.data );
			loader.x = 10;
			loader.y = 70;
			
			addChild( loader );
		}
		
		private function handleReceiveRequest( event:MouseEvent ):void
		{
			// here we tell our connection that we want to start receving the file. This can be automated if the sender sends us a 
			// message telling us that a file is ready as soon as it is ready for him to send.
			connection.session.fileSharer.startReceiving();
		}
		
		// here we handle when we have received a shared file. The method accepts an instance of the P2PSharedObject which in turn
		// has a 'data' property of type ByteArray which holds the data for the file shared.
		private function handleFileReceived( fileObject:P2PSharedObject ):void
		{
			loader = new Loader();
			loader.loadBytes( fileObject.data );
			loader.x = 10;
			loader.y = 70;
			
			addChild( loader );
		}
	}
}