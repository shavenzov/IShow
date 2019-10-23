package org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers
{
	import flash.geom.Point;
	
	import org.un.cava.birdeye.ravis.utils.Geometry;

	public class DirectedCurveEdgeRenderer extends BaseDirectedEdgeRenderer
	{
		/**
		 * Размер изгиба для первой "волны"
		 * Для следующих волн будет BEND_SIZE * depth
		 */		
		private static const BEND_SIZE : Number = 50;
		
		public function DirectedCurveEdgeRenderer()
		{
			super();
		}
		
		override public function draw() : void
		{
			var weight       : Number = data.data.flow;
			var arrowStyle   : String = data.data.arrow;
			var depth        : Number = data.data.depth;
			var sign         : int    = data.data.orientation;
			
			var points : Vector.<Point> = getPoints( arrowStyle, depth * sign );
			
			var fP:Point = points[ 0 ];
			var tP:Point = points[ 1 ];
			
			//Вычисляем середину связи
			var middlePoint  : Point  = Geometry.midPointOfLine( tP, fP );
		    
		    //Вычисляем вектор нормали
		    var v            : Point  = Geometry.segmentNormal( fP, tP );
		   
			//Вектор нормали !всегда должен! быть направлен "вверх"
			if ( v.y > 0 )
		    {
			 v.x *= -1;
			 v.y *= -1;
		    }
			
			//sign = 1.0;
			
			//Вычисляем точку луч от которой перпендикулярен нашей связи
			var cP : Point  = new Point( middlePoint.x + sign * v.x * BEND_SIZE * depth, middlePoint.y + sign * v.y * BEND_SIZE * depth );
			
			/* Vector Rotation
			//x' = x cos(t) - y sin(t)
			//y' = x sin(t) + y cos(t)
			*/
			
			vedge.lineStyle.thickness = weight;
			
			/* apply the line style */
			applyLineStyle();
			
			/*
			g.moveTo( middlePoint.x, middlePoint.y );
			g.lineTo( cP.x, cP.y );
			*/
			
			//Draw Line
			g.moveTo( fP.x, fP.y );
			g.curveTo( cP.x, cP.y, tP.x, tP.y );
			
			g.beginFill( uint( vedge.lineStyle.color ) );
			
			if ( arrowStyle != ArrowStyle.NONE )
			{
				drawArrow( cP, tP, weight );
				
				if ( arrowStyle == ArrowStyle.DOUBLE )
				{
					drawArrow( cP, fP, weight );
				}
			}
			
			g.endFill();
			
			//Invisible layer for selection
			g.lineStyle( fuzzFactor, 0x00FF00, 0.0 );
			g.moveTo( fP.x, fP.y );
			g.curveTo( cP.x, cP.y, tP.x, tP.y ); 
			
			if ( vedge.vgraph.displayEdgeLabels )
			{
				//Вычисляем на сколько нужно переместить label, что-бы он оказался над дугой
				var offset : Number = ( BEND_SIZE * depth ) / 2;
				
				//Корректируем направление нормали для label ( Возможно эти манипуляции необходимо реализовать в updateLabel )
				//2|1
				//3|4
				
				if ( v.y > 0 )
				{
					sign *= -1;
				}
				
				//-------------------
				
				if ( sign == -1 )
				{
					offset += vedge.labelView.height - 2;
				}
				
				offset *= sign;
				
				updateLabel( fP, tP, offset );
			}
		}
	}
}