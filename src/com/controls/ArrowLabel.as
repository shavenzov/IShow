package com.controls
{
	import flash.display.GraphicsPathCommand;
	
	import mx.controls.Label;
	
	public class ArrowLabel extends Label
	{
		private var _fill           : uint   = 0x6d7a8c;
		private var _fillAlpha      : Number = 0.85;
		//private var _lineColor      : uint   = 0xc6c6c6;
		
		private static const TRIANGLE_SIZE : Number = 10.0;
		
		public function ArrowLabel()
		{
			super();
			
			setStyle( 'paddingLeft', 4.0 );
			setStyle( 'paddingRight', 4.0 );
		}
		
		public function get fill() : uint
		{
			return _fill;
		}
		
		public function set fill( value : uint ) : void
		{
			_fill = value;
			invalidateDisplayList();
		}
		
		override protected function measure() : void
		{
			super.measure();
			
			measuredWidth += TRIANGLE_SIZE;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			unscaledHeight -= 2;
			
			graphics.clear();
			//graphics.lineStyle( 1.0, _lineColor, 1.0 );
			graphics.beginFill( _fill, _fillAlpha );
			
			graphics.drawPath( Vector.<int>( [ GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO, 
				                               GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO,
											   GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO ] ),
				               Vector.<Number>( 
								                [
								                  0, 0,
												  unscaledWidth - TRIANGLE_SIZE, 0,
												  unscaledWidth, unscaledHeight / 2,
												  unscaledWidth - TRIANGLE_SIZE, unscaledHeight,
												  0, unscaledHeight,
												  0, 0
												]	 
								               )
							   );
			
			
			graphics.endFill();
		}
	}
}