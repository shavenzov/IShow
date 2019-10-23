package com.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class ImageUtil
	{
		public static function getScaledSize( image : DisplayObject,size : Number ) : Point
		{
			var k : Number;
			
			if ( image.width >= image.height )
			{
				k = image.width / size;
				
				return new Point( size, image.height / k );
			}
			
            k = image.height / size;	
			
			return new Point( image.width / k, size ); 
		}
	}
}