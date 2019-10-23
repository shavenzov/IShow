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
package org.un.cava.birdeye.ravis.graphLayout.layout {
	
	import flash.geom.Point;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.utils.Geometry;
	
	/**
	 * This class holds all the parameters needed
	 * for a drawing representation of a graph drawing
	 * with a Parent-Centered Radial Layout
	 * i.e. it represents a calculated drawing of the layout.
	 * */
	public class ParentCenteredDrawingModel	extends ConcentricRadialLayoutDrawing {

		private static const _LOG:String = "graphLayout.layout.ParentCenteredDrawingModel";
		
		/*
		Хранит оптимальную длину связи между родителем и его детьми
		*/
		public var linkLengths : Array;


		/**
		 * The constructor only initializes the datastructures.
		 * */
		public function ParentCenteredDrawingModel() {
			
			super();
			
			
		}
		
		/**
		 * This method sets polar coordinates along with the
		 * node's origin and zero angle offset.
		 * @param n The node for which to set the values.
		 * @param origin The node's origin (typically parents relative coordinates)
		 * @param angleOff The node's zero angle offset (in degrees).
		 * @param polarR The relative polar radius of the node.
		 * @param polarPhi The relative polar angle of the node (in degrees).
		 * */
		public function setNodeCoordinates( n : INode, origin : Point, angleOff : Number, polarR : Number, polarPhi : Number ) : void 
		{
			var p:Point;
			
			//angleOff = 0.0;
			
			/* we have to void NaN values */
			if( isNaN( angleOff ) ) {
				throw Error("angleOffset tried to set to NaN");
			}
			
			if ( isNaN( polarR ) ) {
				throw Error("polarR tried to set to NaN");
			}
			
			if ( isNaN( polarPhi ) ) {
				throw Error("polarPhi tried to set to NaN");
			}
			
			/* normalize angles */
			angleOff = Geometry.normaliseAngleDeg( angleOff );
			polarPhi = Geometry.normaliseAngleDeg( polarPhi );
			
			/*
			LogUtil.warn(_LOG, "Raw polar calc node:"+n.id+" origin:"+origin.toString()+" angleOff:"+angleOff+
			" polarRadius:"+polarR+" polarPhi:"+polarPhi+" result:"+Geometry.cartFromPolarDeg(polarR,polarPhi));
			*/
			
			/* set the values of the base class, BUT the relative coordinates
			 * must be consistent relative coordinates, but we may
			 * need to store the current polarR and polarPhis too...
			 * due to the y-axis orientation, we have to change the sign
			 * of the angle */
			this.setPolarCoordinates( n, polarR, /*-*/ Geometry.normaliseAngleDeg( polarPhi + angleOff ) );
			
			/* now get the relative cartesians, but we need to add the
			 * local origin offset */
			p = this.getRelCartCoordinates( n );
			
			//LogUtil.warn(_LOG, "With angle offset:"+p.toString());
			
			p = p.add( origin );
			
			//LogUtil.warn(_LOG, "With origin:"+origin.toString()+" offset = "+p.toString());
			
			/* and set them again */
			this.setCartCoordinates( n, p );
			
			/*
			LogUtil.warn(_LOG, "SetNodeCoordinates of node:"+n.id+" origin:"+origin.toString()+" angleOff:"+angleOff+
			" polarRadius:"+polarR+" polarPhi:"+polarPhi+" and in cartesian:"+this.getRelCartCoordinates(n).toString());
			*/
		}
		
		public function initLinkLengths( maxDepth : int ) : void
		{
			linkLengths = new Array( maxDepth );
			
			for ( var i : int = 0; i < maxDepth; i ++ )
			{
				linkLengths[ i ] = 0.0;
			}
		}
	}
}
