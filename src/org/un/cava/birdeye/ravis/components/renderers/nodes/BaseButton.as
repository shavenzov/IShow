package org.un.cava.birdeye.ravis.components.renderers.nodes
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	public class BaseButton extends Sprite
	{
		public function BaseButton()
		{
			super();
			
			addEventListener( MouseEvent.ROLL_OVER, overState );
			addEventListener( MouseEvent.ROLL_OUT, upState );
			addEventListener( MouseEvent.MOUSE_DOWN, downState, false, 10 );
			addEventListener( MouseEvent.MOUSE_UP, upState );
			
			upState( null );
		}
		
		private function upState( e : MouseEvent ) : void
		{
			//alpha = 0.85;
			filters = [ new GlowFilter( 0xffffff, 1.0, 6.0, 6.0, 2.0 ) ];
		}
		
		private function overState( e : MouseEvent ) : void
		{
			filters = [ new GlowFilter( 0xffffff, 1.0, 6.0, 6.0, 3 ) ];
			//alpha = 1.0;
		}
		
		private function downState( e : MouseEvent ) : void
		{
			//alpha = 1.0;
			filters = [ new GlowFilter( 0xffffff, 1.0, 8.0, 8.0, 4 ) ];
		}
	}
}