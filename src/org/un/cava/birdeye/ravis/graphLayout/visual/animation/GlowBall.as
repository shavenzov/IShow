package org.un.cava.birdeye.ravis.graphLayout.visual.animation
{
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	
	public class GlowBall extends Sprite
	{
		private var _x          : Number;
		private var _y          : Number;
		private var _halfWidth  : Number;
		private var _halfHeight : Number;
		
		private var _size       : Number;
		
		public function GlowBall( size : Number = 4.0 )
		{
			super();
			
			_size = size;
			
			draw();
			
			_halfWidth  = width / 2;
			_halfHeight = height / 2;
			
			filters = [ new GlowFilter( 0xFFFF00, 1.0, 20.0, 20.0 ) ];
			blendMode = BlendMode.DIFFERENCE;
		}
		
		private function draw() : void
		{
			graphics.clear();
			graphics.beginFill( 0x6699FF, 1.0 );
			graphics.drawCircle( _size, _size, _size );
			graphics.endFill();
		}
		
		override public function get x() : Number
		{
			return _x;
		}
		
		override public function set x( value : Number ) : void
		{
			if ( _x != value )
			{
				_x      = value;
				super.x = _x - _halfWidth; 	
			}
		}
		
		override public function get y() : Number
		{
			return _y;
		}
		
		override public function set y( value : Number ) : void
		{
			if ( _y != value )
			{
				_y      = value;
				super.y = _y - _halfHeight; 
			}
		}
	}
}