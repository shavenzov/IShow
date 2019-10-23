package com.controls
{
	import mx.controls.LinkButton;
	
	public class LinkButton extends mx.controls.LinkButton
	{
		public function LinkButton()
		{
			super();
			buttonMode = false;
		}
		
		override public function set enabled( value : Boolean ) : void
		{
			super.enabled = value;
			alpha = value ? 1.0 : 0.45;
			buttonMode = false;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			graphics.beginFill( 0x000000, 0.0 );
			graphics.drawRect( 0.0, 0.0, unscaledWidth, unscaledHeight );
			graphics.endFill();
			
			super.updateDisplayList( unscaledWidth, unscaledHeight );
	    }
	}
}