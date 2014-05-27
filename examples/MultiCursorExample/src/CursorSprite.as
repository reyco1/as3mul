package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	public class CursorSprite extends Sprite
	{
		public  var textField:TextField;
		private var destX:Number;
		private var destY:Number;
		private var color:uint;
		
		public function CursorSprite(userName:String, clr:uint)
		{
			graphics.beginFill(clr);
			graphics.drawCircle(0, 0, 5);
			graphics.endFill();
						
			textField = new TextField();
			textField.text = userName;
			textField.autoSize = "left";
			textField.mouseEnabled = false;
			textField.x = textField.y = 10;
			addChild(textField);
			
			color = clr;
			
			addEventListener(Event.ENTER_FRAME, onRender);
		}
		
		public function update(newX:Number, newY:Number):void
		{
			destX = newX;
			destY = newY;
			
			graphics.clear();
			graphics.beginFill(color);
			graphics.drawCircle(0, 0, 5);
			graphics.endFill();
		}
		
		private function onRender(e:Event):void
		{
			x -= (x - destX) * 0.3;
			y -= (y - destY) * 0.3;
		}
	}
}