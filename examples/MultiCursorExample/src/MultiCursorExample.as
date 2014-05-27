package
{
	import com.reyco1.multiuser.MultiUserSession;
	import com.reyco1.multiuser.data.UserObject;
	import com.reyco1.multiuser.debug.Logger;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	[SWF(frameRate="60", width="250", height="350")] 
	public class MultiCursorExample extends Sprite
	{
		// you can get a key from here : http://labs.adobe.com/technologies/cirrus/
		private const SERVER_AND_KEY:String   = "";										
		
		private var connection:MultiUserSession;
		private var cursors:Object = {};
		private var myName:String;
		private var myColor:uint;
		
		public function MultiCursorExample()
		{
			// set Logger to only trace my traces
			Logger.LEVEL = Logger.OWN;											
			
			initialize();
		}
		
		protected function initialize():void
		{
			// create a new instance of MultiUserSession
			connection = new MultiUserSession(SERVER_AND_KEY, "multiuser/test");		
			// set the method to be executed when connected
			connection.onConnect 		= handleConnect;						
			// set the method to be executed once a user has connected
			connection.onUserAdded 		= handleUserAdded;						
			// set the method to be executed once a user has disconnected
			connection.onUserRemoved 	= handleUserRemoved;					
			// set the method to be executed when we recieve data from a user
			connection.onObjectRecieve 	= handleGetObject;						
			// my name
			myName  = "User_" + Math.round(Math.random()*100);					
			// my color
			myColor = Math.random()*0xFFFFFF;									
			// connect using my name and color variables
			connection.connect(myName, {color:myColor});						
		}
		
		// method should expect a UserObject
		protected function handleConnect(user:UserObject):void					
		{
			Logger.log("I'm connected: " + user.name + ", total: " + connection.userCount); 
			stage.addEventListener(MouseEvent.MOUSE_MOVE, sendMyData);
		}
		
		// method should expect a UserObject
		protected function handleUserAdded(user:UserObject):void				
		{
			Logger.log("User added: " + user.name + ", total users: " + connection.userCount);
			// create a cursor for the new user that has just joined with his name and color
			cursors[user.id] = new CursorSprite(user.name, user.details.color);	
			addChild( cursors[user.id] );
			
			sendMyData();
		}
		
		// method should expect a UserObject
		protected function handleUserRemoved(user:UserObject):void				
		{
			Logger.log("User disconnected: " + user.name + ", total users: " + connection.userCount); 
			// remove cursor for disconnected user
			removeChild( cursors[user.id] );									
			delete cursors[user.id];
		}
		
		protected function sendMyData(event:MouseEvent = null):void			
		{
			// send my cursor position
			connection.sendObject({x:stage.mouseX, y:stage.mouseY});			
		}
		
		protected function handleGetObject(peerID:String, data:Object):void
		{
			// update user cursor
			cursors[peerID].update(data.x, data.y);								
		}		
	}
}