package ui.dialogs.renderers
{
	import flash.geom.Point;
	
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.VisualDefaults;
	import org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers.ArrowStyle;
	
	public class ArrowRenderer extends UIComponent implements IDataRenderer
	{
		/**
		 * The size of the arrowhead in pixel. The distance of the
		 * two points defining the base of the arrowhead.
		 * */
		private var arrowBaseSize:Number = 10;
		
		/**
		 * The distance of the arrowbase from the tip in pixel.
		 * */
		private var arrowHeadLength:Number = 20;
		
		public function ArrowRenderer()
		{
			super();
		}
		
		private var _data : Object;
		
		public function get data() : Object
		{
			return _data;
		}
		
		public function set data( value : Object ) : void
		{
			_data = value;
		    invalidateDisplayList();
		}
		
		override protected function measure() : void
		{
			measuredWidth = 100;
			measuredHeight = 15;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if ( _data )
			{
				var arrow : String = _data.arrow;
				var weight : Number = _data.weight;
				var color  : uint = _data.color;
				var defaults : Object = VisualDefaults.edgeStyle;
				
				var centerY : Number = ( unscaledHeight + weight ) / 2;
				
				graphics.clear();
				
				graphics.lineStyle( weight, color, defaults.alpha, defaults.pixelHinting, defaults.scaleMode, defaults.caps, defaults.joints, defaults.miterLimit );
				graphics.moveTo( 0.0, centerY );
				graphics.lineTo( unscaledWidth, centerY );
				
				graphics.beginFill( color );
				
				if ( arrow != ArrowStyle.NONE )
				{
					if ( arrow == ArrowStyle.SINGLE )
					{
						drawArrow( new Point( 0.0, centerY ), new Point( unscaledWidth, centerY ), weight );
					}
					else
					if ( arrow == ArrowStyle.SINGLE_INVERTED )
					{
						drawArrow( new Point( unscaledWidth, centerY ), new Point( 0.0, centerY ), weight );
					}
					else
					if ( arrow == ArrowStyle.DOUBLE )
					{
						drawArrow( new Point( 0.0, centerY ), new Point( unscaledWidth, centerY ), weight );
						drawArrow( new Point( unscaledWidth, centerY ), new Point( 0.0, centerY ), weight );
					}
				}
				
				graphics.endFill();
			}
		}
		
		private function drawArrow( fP : Point, tP : Point, weight : Number ) : void
		{
			var lArrowBase:Point;
			var rArrowBase:Point;
			var mArrowBase:Point;
			
			var arrowHeadLength : Number = this.arrowHeadLength; 
			var arrowBaseSize   : Number = this.arrowBaseSize; 
			
			var edgeAngle:Number;
			
			/* calculate the base bidpoint which is on
			* the same vector defined between the two endpoints
			*
			* First Step: get the angle of the edge in radians
			*/
			edgeAngle = Math.atan2(tP.y - fP.y,tP.x - fP.x);
			
			/* Second step: the midpoint of the base can easily
			* be specified in polar coords, using the same angle
			* and as distance the original distance - the base distance
			* then only the y value needs to be adjusted by the 
			* y value of the from point
			*/
			mArrowBase = Point.polar(Point.distance(tP,fP) - arrowHeadLength,edgeAngle);
			mArrowBase.offset(fP.x,fP.y);
			
			/* Now find the left and right arrow base points
			* in a similar way.
			* 1. We can keep the angle but add/subtract 90 degrees.
			* 2. As distance use the half of the base size
			* 3. add the midpoint as reference 
			*/
			lArrowBase = Point.polar(arrowBaseSize / 2.9,(edgeAngle - (Math.PI / 2.0)));
			rArrowBase = Point.polar(arrowBaseSize / 2.9,(edgeAngle + (Math.PI / 2.0)));
			
			lArrowBase.offset(mArrowBase.x,mArrowBase.y);			
			rArrowBase.offset(mArrowBase.x,mArrowBase.y);
			
			graphics.moveTo( tP.x, tP.y );
			graphics.lineTo( lArrowBase.x, lArrowBase.y );
			graphics.lineTo( rArrowBase.x, rArrowBase.y );
			graphics.lineTo( tP.x, tP.y );
		}
	}
}