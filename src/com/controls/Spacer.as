package com.controls
{
	import mx.core.UIComponent;
	
	public class Spacer extends UIComponent
	{
		private static const PADDING : Number = 0.0;
		
		public function Spacer()
		{
			super();
		}
		
		override protected function measure():void
		{
			measuredHeight = 1.0;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			graphics.clear();
			graphics.lineStyle( 1.0, 0xc6c6c6, 0.8 );
			graphics.moveTo( 0.0, PADDING );
			graphics.lineTo( 0.0, unscaledHeight - PADDING );
		}
	}
}