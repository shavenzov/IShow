/* 
 * The MIT License
 *
 * Copyright (c) 2007 The SixDegrees Project Team
 * (Jason Bellone, Juan Rodriguez, Segolene de Basquiat, Daniel Lang).
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The abovedge copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers {
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import org.un.cava.birdeye.ravis.utils.Geometry;

	/**
	 * This is the default edge renderer, which draws the edges
	 * as straight lines from one node to another.
	 * */
	public class BaseEdgeRenderer extends UIComponent implements IEdgeRenderer {
		
		protected var fuzzFactor:Number = 8;
        
        protected var vedge:IVisualEdge;
        
		public function BaseEdgeRenderer() {

		}
        
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
            super.updateDisplayList(unscaledWidth,unscaledHeight);
            
            graphics.clear();
            if(vedge)
                draw();
        }
	    
		private static const SEGMENT_INC   : Number = -10000.0;
		private static const MIN_DISTANCE  : Number = 25.0;
		//private static const OFFSET_STEP   : Number = 8; 
		
		/**
		 * Вычисляет оптимальные координаты соединения связи с узлами 
		 * @param arrowStyle - тип связи между узлами
		 * @param depth - глубина и направление смещения по контуру
		 * @return Вектор из двух точек, где первая точка, координаты соединения с узлом 1
		 *                                   вторая точка, координаты соединения с узлом 2 
		 * 
		 */		
		protected function getPoints( arrowStyle : String, depth : Number = NaN ) : Vector.<Point>
		{
			var result   : Vector.<Point> = new Vector.<Point>( 2 );
			var vnode1   : IVisualNode;
			var vnode2   : IVisualNode;
			
			if ( arrowStyle == ArrowStyle.SINGLE_INVERTED )
			{
				vnode1 = vedge.edge.node2.vnode;
				vnode2 = vedge.edge.node1.vnode;
			}
			else
			{
				vnode1 = vedge.edge.node1.vnode;
				vnode2 = vedge.edge.node2.vnode;
			}
			
			var center1  : Point          = vnode1.viewCenter;
			var center2  : Point          = vnode2.viewCenter; 
			
			var distance : Number         = Point.distance( center1, center2 );    
			
			if ( ( arrowStyle == ArrowStyle.NONE ) || ( distance <= MIN_DISTANCE ) || ( vedge.edge.node1.vnode.view == null ) || ( vedge.edge.node2.vnode.view == null ) )
			{
				result[ 0 ] = center1;
				result[ 1 ] = center2;
				return result;
			}
			
			var fromRect : Rectangle   = vnode1.getVisualBounds( parent );
			var toRect   : Rectangle   = vnode2.getVisualBounds( parent );
			
			const fromPoints : Vector.<Point> = Vector.<Point>( 
			  [
			    new Point( fromRect.left + fromRect.width / 2.0, fromRect.top ),
				new Point( fromRect.left, fromRect.top + fromRect.height / 2.0 ),
				new Point( fromRect.right, fromRect.top + fromRect.height / 2.0 ),
				new Point( fromRect.left + fromRect.width / 2.0, fromRect.bottom )
			  ]	  
			);
			
			const toPoints : Vector.<Point> = Vector.<Point>( 
				[
					new Point( toRect.left + toRect.width / 2, toRect.top ),
					new Point( toRect.left, toRect.top + toRect.height / 2 ),
					new Point( toRect.right, toRect.top + toRect.height / 2 ),
					new Point( toRect.left + toRect.width / 2, toRect.bottom )
				]	  
			);
			
			var minDistance : Number = Number.MAX_VALUE;
			var max_i       : int;
			var max_j       : int;
			
			for ( var i : int = 0; i < fromPoints.length; i ++ )
			{
				for ( var j : int = 0; j < toPoints.length; j ++ )
				{
					if ( arrowStyle == ArrowStyle.DOUBLE )
					{
						distance = Point.distance( fromPoints[ i ], toPoints[ j ] );
					}
					else
					{
						distance = Point.distance( center1, toPoints[ j ] );
					}
					
					if ( distance < minDistance )
					{
						minDistance = distance;
						max_i = i;
						max_j = j;
					}
				}
			}
			
			var crossPoint : Point;
			
			if ( arrowStyle == ArrowStyle.DOUBLE )
			{
				switch( max_i )
				{
					case 0 : crossPoint = new Point( fromRect.left + SEGMENT_INC , fromRect.top );
						break;
					case 1 : crossPoint = new Point( fromRect.left, fromRect.top + SEGMENT_INC  );
						break;
					case 2 : crossPoint = new Point( fromRect.right, fromRect.top + SEGMENT_INC  );
						break;
					case 3 : crossPoint = new Point( fromRect.left + SEGMENT_INC , fromRect.bottom )
						break;
				}
				
				result[ 0 ] = Geometry.crossSegmentsPoint( crossPoint, fromPoints[ max_i ], center1, center2 );
				/*
				if ( isNaN( depth ) )
				{
					result[ 0 ] = crossPoint;
				}
				else
				{
					result[ 0 ] = Geometry.getRectPoint( fromRect, crossPoint, depth * OFFSET_STEP, max_i );
				}*/
			}
			else
			{
				result[ 0 ] =  center1;
			}
			
			
			switch( max_j )
			{
				case 0 : crossPoint = new Point( toRect.left + SEGMENT_INC , toRect.top );
					break;
				case 1 : crossPoint = new Point( toRect.left, toRect.top + SEGMENT_INC  );
					break;
				case 2 : crossPoint = new Point( toRect.right, toRect.top + SEGMENT_INC  );
					break;
				case 3 : crossPoint = new Point( toRect.left + SEGMENT_INC, toRect.bottom );
					break;
			}
			
			result[ 1 ] = Geometry.crossSegmentsPoint( crossPoint, toPoints[ max_j ], center1, center2 );
			/*
			if ( isNaN( depth ) )
			{
				result[ 1 ] = crossPoint; 
			}
			else
			{
				result[ 1 ] = Geometry.getRectPoint( toRect, crossPoint, depth * OFFSET_STEP, max_j );
			}
			
			g.clear();
			g.beginFill( 0x00ff00, 1.0 );
			g.drawCircle( result[ 1 ].x, result[ 1 ].y, 4 );
			g.endFill();
			*/
			return result;
		}
		
		public function draw():void {
			
			/* first get the corresponding visual object */
			var fromNode:IVisualNode = vedge.edge.node1.vnode;
			var toNode:IVisualNode = vedge.edge.node2.vnode;
			
			/* apply the line style */
			applyLineStyle();
			
			/* now we actually draw */
			g.beginFill(uint(vedge.lineStyle.color));
			g.moveTo(fromNode.viewCenter.x, fromNode.viewCenter.y);			
			g.lineTo(toNode.viewCenter.x, toNode.viewCenter.y);
			g.endFill();
				
			/* if the vgraph currently displays edgeLabels, then
			 * we need to update their coordinates */
			if(vedge.vgraph.displayEdgeLabels) {
                vedge.setEdgeLabelCoordinates(labelCoordinates());
			}
		}
		
		/**
		 * @inheritDoc
		 * 
		 * In this simple implementation we put the label into the
		 * middle of the straight line between the two nodes.
		 * */
		public function labelCoordinates():Point {
			return Geometry.midPointOfLine(
                vedge.edge.node1.vnode.viewCenter,
                vedge.edge.node2.vnode.viewCenter
			);
		}
		
		/**
		 * Applies the linestyle stored in the passed visual Edge
		 * object to the Graphics object of the renderer.
		 * */
		protected function applyLineStyle():void {
			
			if(vedge &&
                vedge.lineStyle != null) {
				g.lineStyle(
					Number(vedge.lineStyle.thickness),
					uint(vedge.lineStyle.color),
					Number(vedge.lineStyle.alpha),
					Boolean(vedge.lineStyle.pixelHinting),
					String(vedge.lineStyle.scaleMode),
					String(vedge.lineStyle.caps),
					String(vedge.lineStyle.joints),
					Number(vedge.lineStyle.miterLimit)
				);
			}
		}
        
        protected function get g():Graphics
        {
            return graphics;
        }
        
        public function render(force:Boolean=false):void
        {
            if(force)
            {
                graphics.clear();
                if(vedge)
                    draw();   
            }
            else
            {
                invalidateDisplayList();
            }
        }
        
        public function get data():Object { return vedge; }
        public function set data(value:Object):void
        {
            vedge = value as IVisualEdge;
        }
	}
}
