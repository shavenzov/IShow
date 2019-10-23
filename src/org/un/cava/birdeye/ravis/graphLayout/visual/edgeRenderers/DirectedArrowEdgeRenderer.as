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
 * The above copyright notice and this permission notice shall be included in
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
	
	import flash.geom.Point;
	
	import org.un.cava.birdeye.ravis.utils.Geometry;


	/**
	 * This is a directed edge renderer, which draws the edges
	 * with arrowheads at the target point.
	 * Please note that for undirected graphs, the actual direction
	 * of the edge might be arbitrary.
	 * */
	public class DirectedArrowEdgeRenderer extends BaseDirectedEdgeRenderer {
		/**
		 * Constructor sets the graphics object (required).
		 * @param g The graphics object to be used.
		 * */
		public function DirectedArrowEdgeRenderer() {
			super();
		}
		
		/**
		 * The draw function, i.e. the main function to be used.
		 * Draws a curved line from one node of the edge to the other.
		 * The colour is determined by the "disting" parameter and
		 * a set of edge parameters, which are stored in an edge object.
		 * 
		 * @inheritDoc
		 * */
		override public function draw():void {
			
			var weight     : Number = data.data.flow;
			var arrowStyle : String = data.data.arrow;
		
			var points : Vector.<Point> = getPoints( arrowStyle );
			
			var fP:Point = points[ 0 ];
			var tP:Point = points[ 1 ];
			
			//Учитываем тощину связи при отрисовки стрелки
			if ( arrowStyle != ArrowStyle.NONE )
			{
				var v : Point = Geometry.segmentVector( fP, tP );
				    v.x *= weight;
				    v.y *= weight;
				
				if ( arrowStyle == ArrowStyle.DOUBLE )
				{
					fP.offset( - v.x, - v.y );
				}
					
				tP.offset( v.x, v.y );
			}
			
			vedge.lineStyle.thickness = weight;
			
			/* apply the line style */
			applyLineStyle();
			
            //Draw Line
			g.moveTo(fP.x, fP.y);
			g.lineTo(tP.x, tP.y);
			
			g.beginFill( uint( vedge.lineStyle.color ) );
			
			if ( arrowStyle != ArrowStyle.NONE )
			{
				drawArrow( fP, tP, weight );
				
				if ( arrowStyle == ArrowStyle.DOUBLE )
				{
					drawArrow( tP, fP, weight );
				}
			}
			
			g.endFill();
			
			//Invisible layer for selection
			g.lineStyle( fuzzFactor, 0x00FF00, 0.0 );
			g.moveTo( fP.x, fP.y );
			g.lineTo( tP.x, tP.y );
			
			if ( vedge.vgraph.displayEdgeLabels )
			{
				updateLabel( fP, tP, weight / 2 );
			}
		}
	}
}