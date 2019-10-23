package org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.ravis.utils.Geometry;

	public class BaseDirectedEdgeRenderer extends BaseEdgeRenderer
	{
		/**
		 * The size of the arrowhead in pixel. The distance of the
		 * two points defining the base of the arrowhead.
		 * */
		protected var arrowBaseSize:Number = 10;
		
		/**
		 * The distance of the arrowbase from the tip in pixel.
		 * */
		protected var arrowHeadLength:Number = 20;
		
		/**
		 * Смещение label относительно стрелки слева и справа 
		 */		
		protected var labelOffset : Number = 4;
		
		public function BaseDirectedEdgeRenderer()
		{
			super();
		}
		
		protected function drawArrow( fP : Point, tP : Point, weight : Number ) : void
		{
			var lArrowBase:Point;
			var rArrowBase:Point;
			var mArrowBase:Point;
			
			var arrowHeadLength : Number = this.arrowHeadLength + weight / 2; 
			var arrowBaseSize   : Number = this.arrowBaseSize + weight; 
			
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
			mArrowBase = Point.polar( Point.distance( tP, fP ) - arrowHeadLength, edgeAngle );
			mArrowBase.offset( fP.x, fP.y );
			
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
			
			g.moveTo( tP.x, tP.y );
			g.lineTo( lArrowBase.x, lArrowBase.y );
			g.lineTo( rArrowBase.x, rArrowBase.y );
			g.lineTo( tP.x, tP.y );
		}
		
		protected function updateLabel( fP : Point, tP : Point, offset : Number = 0.0 ) : void
		{
			/*if ( vedge.vgraph.displayEdgeLabels )
			{*/
				var labelView : UIComponent = vedge.labelView;
				
				if ( ( labelView.width == 0 ) || ( labelView.height == 0 ) )
				{
					return;
				}
				
				var size : Number = data.data.flow / 2;
				size = 1;
				//Корректируем смещение с учетом толщины связи
				if ( offset == 0 )
				{
					offset = size;
				}
				else
				{
					offset += ( offset / Math.abs( offset ) ) * size;
				}
				
				/*var fP:Point = vedge.edge.node1.vnode.viewCenter;
				var tP:Point = vedge.edge.node2.vnode.viewCenter;*/
				
				var v1    : Point  = Geometry.segmentVector( fP, tP );
				var v2    : Point  = Geometry.segmentVector( fP, new Point( tP.x, fP.y  ) );
				var k     : Number = 1.0;
				
				//Корректируем знак угла поворота, для того что-бы надпись всегда была над свзью
				if ( v1.x > 0.0 )
				{
					if ( v1.y < 0.0 )
					{
						k = - 1.0;
					}
				}
				else
				{
					if ( v1.y > 0.0 )
					{
						k = - 1.0;
					}
				}
				
				var alpha : Number = Math.acos( v1.x * v2.x + v1.y * v2.y ) * k; 
				
				var n      : Point = Geometry.segmentNormal( fP, tP );
				var middle : Point = Geometry.midPointOfLine( fP, tP );
				
				//Корректируем направление нормали (вверх) так что-бы надпись была всегда сверху
				k = ( v1.x >= 0.0 ) ? - 1.0 : 1.0;
								
				middle.x += k * n.x * ( ( labelView.height / 2 ) + offset );
				middle.y += k * n.y * ( ( labelView.height / 2 ) + offset );
				
				//trace( bounds );
				
				var m : Matrix = new Matrix();
				m.translate( - labelView.width / 2, - labelView.height / 2 );
				m.rotate( alpha );
				m.translate( middle.x, middle.y );
				
				vedge.labelView.transform.matrix = m;
				
				//Устанавливаем максимальную длину EdgeLabel
				var d : Number = Point.distance( fP, tP ) - ( arrowHeadLength + labelOffset ) * 2;
				
				if ( d < 5.0 )
				{
					d = 5.0;
				}
				
				vedge.labelView.maxWidth = d;
			//}
		}
	}
}