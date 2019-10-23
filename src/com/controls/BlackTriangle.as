package com.controls
{
	import mx.core.UIComponent;
	
	public class BlackTriangle extends UIComponent
	{
		private static const SIZE : Number = 5.0;
		
		public function BlackTriangle( color : uint )
		{
			super();
			
			var halfSize : Number = SIZE / 2.0;
			
			graphics.beginFill( color, 1.0 );
			graphics.moveTo(  - halfSize, - halfSize );
			graphics.lineTo( halfSize, - halfSize );
			graphics.lineTo( 0.0, halfSize );
			graphics.endFill();
		}
		
		override protected function measure():void
		{
			measuredWidth = measuredHeight = SIZE;
		}
	}
}