package org.un.cava.birdeye.ravis.utils
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class HitTestUtils
	{
		public static function rectIntersectsObject( target : DisplayObject, rect : Rectangle ) : Boolean
		{
			var bounds : Rectangle = target.getBounds( target.parent );
			
			return rect.intersects( bounds );
		}
		
		public static function rectIntersectsObjectComplex( target : DisplayObject, rect : Rectangle ) : Boolean
		{
			var bounds       : Rectangle = target.getBounds( target.parent );
			var intersection : Rectangle = rect.intersection( bounds );
			
			if ( intersection.width != 0 )
			{
				intersection.width  = Math.ceil( intersection.width );
				intersection.height = Math.ceil( intersection.height );
				
				var dummyRect : Shape = new Shape();
				    dummyRect.graphics.beginFill( 0xff0000 );
					dummyRect.graphics.drawRect( 0, 0, intersection.width, intersection.height );
					dummyRect.graphics.endFill();
				
				var m : Matrix = new Matrix( 1, 0, 0, 1, - intersection.x, - intersection.y );
					
				var bitmapData : BitmapData = new BitmapData( intersection.width, intersection.height, false, 0x000000 );
				    bitmapData.draw( target, m, new ColorTransform( 1, 1, 1, 1, 255, -255, -255, 255 ) );
					bitmapData.draw( dummyRect, null, new ColorTransform( 1, 1, 1, 1, 255, 255, 255, 255 ), BlendMode.DIFFERENCE );
					
				intersection = bitmapData.getColorBoundsRect( 0xFFFFFFFF,0xFF00FFFF );
				
				/*
				graphics.beginBitmapFill( bitmapData, null, false );
				graphics.drawRect( 0, 0, intersection.width, intersection.height );
				graphics.endFill();
				*/
				
				bitmapData.dispose();
				dummyRect = null;
				
				
				return intersection.width != 0;
			}
			
			return false;
		}
	}
}