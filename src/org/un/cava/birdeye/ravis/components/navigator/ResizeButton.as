package org.un.cava.birdeye.ravis.components.navigator
{
	import flash.display.Sprite;
	
	public class ResizeButton extends Sprite
	{
		public function ResizeButton()
		{
			super();
			
			graphics.beginFill( 0x00ff00, 0.0 );
			graphics.drawRect( 0.0, 0.0, 10.0, 10.0 );
			graphics.endFill();
		}
	}
}