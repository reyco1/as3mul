package
{
	import com.reyco1.multiuser.MultiUserSession;
	import com.reyco1.multiuser.data.UserObject;
	import com.reyco1.multiuser.debug.Logger;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	[SWF(frameRate="60", width="250", height="350")] 
	public class multiuser_test extends Sprite
	{
		private const SERVER:String   = "rtmfp://p2p.rtmfp.net/";
		private const DEVKEY:String   = "";										// you can get a key from here : http://labs.adobe.com/technologies/cirrus/
		private const SERV_KEY:String = SERVER + DEVKEY;
		
		private var connection:MultiUserSession;
		private var cursors:Object = {};
		private var myName:String;
		private var myColor:uint;
		
		public function multiuser_testbed()
		{
			Logger.LEVEL = Logger.OWN;											// set Logger to only trace my traces
			initialize();
		}
		
		protected function initialize():void
		{
			connection = new MultiUserSession(SERV_KEY, "multiuser/test"); 		// create a new instance of MultiUserSession
			connection.onConnect 		= handleConnect;						// set the method to be executed when connected
			connection.onUserAdded 		= handleUserAdded;						// set the method to be executed once a user has connected
			connection.onUserRemoved 	= handleUserRemoved;					// set the method to be executed once a user has disconnected
			connection.onObjectRecieve 	= handleGetObject;						// set the method to be executed when we recieve data from a user
			
			myName  = "User_" + Math.round(Math.random()*100);					// my name
			myColor = Math.random()*0xFFFFFF;									// my color
			
			connection.connect(myName, {color:myColor});						// connect using my name and color variables
		}
		
		protected function handleConnect(user:UserObject):void					// method should expect a UserObject
		{
			Logger.log("I'm connected: " + user.name + ", total: " + connection.userCount); 
			stage.addEventListener(MouseEvent.MOUSE_MOVE, sendMyData);
		}
		
		protected function handleUserAdded(user:UserObject):void				// method should expect a UserObject
		{
			Logger.log("User added: " + user.name + ", total users: " + connection.userCount);
			cursors[user.id] = new CursorSprite(user.name, user.details.color);	// create a cursor for the new user that has just joined with his name and color
			addChild( cursors[user.id] );
			
			sendMyData();
		}
		
		protected function handleUserRemoved(user:UserObject):void				// method should expect a UserObject
		{
			Logger.log("User disconnected: " + user.name + ", total users: " + connection.userCount); 
			removeChild( cursors[user.id] );									// remove cursor for disconnected user
			delete cursors[user.id];
		}
		
		protected function sendMyData(event:MouseEvent = null):void			
		{
			connection.sendObject({x:stage.mouseX, y:stage.mouseY});			// send my cursor position
		}
		
		protected function handleGetObject(peerID:String, data:Object):void
		{
			cursors[peerID].update(data.x, data.y);								// update user cursor
		}		
	}
}