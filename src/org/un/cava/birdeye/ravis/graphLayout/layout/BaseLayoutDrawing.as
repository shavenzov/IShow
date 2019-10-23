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
package org.un.cava.birdeye.ravis.graphLayout.layout
{
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.utils.Geometry;
	
	/**
	 * This is a base class to hold layout drawing information
	 * like target coordinates for all nodes, access to polar and
	 * cartesian versions of those coordinates and an origin offset.
	 * So it can already represent a drawing.
	 * */
	public class BaseLayoutDrawing implements ILayoutDrawing
	{

		/* we create a virtual origin, that is used as an offset
		 * to the (0,0) origin of the root node */
		private var _originOffset : Point;
		
		/* this is the current center offset of the 
		 * canvas, which can be applied as well */
		private var _centerOffset : Point;
		
		private var _centeredLayout : Boolean = true;
		
		/* we need the polar coordinates AND the relative
		 * origin AND the "zero degrees" ray angle of every
		 * node and of course the cartesian coordinates */
		
		/* node coordinates in polar and cartesian form, these
		 * are all "relative" coordinates. */
		private var _nodePolarRs        : Dictionary;
		private var _nodePolarPhis      : Dictionary;
		private var _nodeCartCoordinates : Dictionary;
		
		//public var testPoints : Vector.<Object> = new Vector.<Object>();

		/**
		 * The constructor just initializes the internal data structures.
		 * */
		public function BaseLayoutDrawing()
		{
			_nodePolarRs         = new Dictionary;
			_nodePolarPhis       = new Dictionary;
			_nodeCartCoordinates = new Dictionary;
			
			/*_originOffset        = new Point(0,0);
			_centerOffset        = new Point(0,0);
			_centeredLayout      = true;*/
		}
		
		/*
		 * getters and setters 
		 * */
		
		public function get nodePolarRs() : Dictionary
		{
			return _nodePolarRs;
		}
		
		public function get nodePolarPhis() : Dictionary
		{
			return _nodePolarPhis;
		}
		
		public function get nodeCartCoordinates() : Dictionary
		{
			return _nodeCartCoordinates;
		}
		
		/**
		 * Access to the offset of the origin of the layout.
		 * The actual origin is the upper left corner of the
		 * canvas. But that changes if we scroll the canvas
		 * around, so we have to keep track of this offset.
		 * @param o The new origin offset.
		 * */
		public function get originOffset() : Point 
		{
			return _originOffset;
		}
		/**
		 * @private
		 * */
		public function set originOffset( o : Point ) : void
		{
			//_originOffset = o;
		}
		
		/**
		 * Access to the offset of the center of the layout.
		 * The actual origin is the upper left corner of the
		 * canvas. But the calculation of this layout is done around
		 * circles around the origin. So we want to move the
		 * origin into the center of the canvas, This is what the
		 * center offset actually does.
		 * @param o The new center offset.
		 * */
		public function get centerOffset() : Point
		{
			return _centerOffset;
		}
		/**
		 * @private
		 * */
		public function set centerOffset( o : Point ) : void
		{
			//_centerOffset = o;
		}
		
		/**
		 * Specifies if the center offset should be applied 
		 * or not.
		 * @param o The new origin offset.
		 * */
		public function get centeredLayout() : Boolean {
			return _centeredLayout;
		}
		/**
		 * @private
		 * */
		public function set centeredLayout( c : Boolean ) : void {
			//_centeredLayout = c;
		}
		
		/**
		 * Set the target coordinates for node n according to the
		 * calculated layout in Polar form. Consider these are
		 * "relative" coordinates, which will finally be adjusted
		 * by the origin offset.
		 * 
		 * @param n The node to set its coordinates.
		 * @param polarR The radius (length) part of the polar coordinates.
		 * @param polarPhi The angle part of the polar coordinates (in degrees).
		 * @throws An error if any part of the coordinates is NaN (not a number).
		 *  */
		public function setPolarCoordinates( n : INode, polarR : Number, polarPhi : Number ) : void
		{
			_nodePolarRs[ n ]         = polarR;
			_nodePolarPhis[ n ]       = polarPhi;
			_nodeCartCoordinates[ n ] = Geometry.cartFromPolarDeg( polarR, polarPhi );
		}
		
		/**
		 * Set the target coordinates for node n according to the
		 * calculated layout in cartesian (i.e. x and y) form. Consider these are
		 * "relative" coordinates, which will finally be adjusted
		 * by the origin offset.
		 * @param n The node to set its coordinates.
		 * @param p The point object representing the target coordinates.
		 *  */
		public function setCartCoordinates( n : INode, p : Point ) : void
		{
			_nodePolarRs[ n ]         = p.length;
			_nodePolarPhis[ n ]       = Geometry.polarAngleDeg(p);
			_nodeCartCoordinates[ n ] = p;
		}		
		
		/**
		 * access the polar radius part of the 
		 * target coordinates of the given node.
		 * These are relative coordinates (subject to origin offset).
		 * @param n The node which target coordinate is required.
		 * @return The radius part of n's target coordinates (in polar).
		 * */ 
		public function getPolarR( n : INode ) : Number
		{
			return _nodePolarRs[ n ];
		}
		
		/**
		 * access the polar angle part of the 
		 * target coordinates of the given node.
		 * These are relative coordinates (subject to origin offset).
		 * @param n The node which target coordinate is required.
		 * @return The angle part of n's target coordinates (in polar).
		 * */ 
		public function getPolarPhi( n : INode) : Number
		{
			return _nodePolarPhis[ n ];
		}
		
		/**
		 * Access the cartesian coordinates of the given node.
		 * These are relative coordinates (subject to origin offset).
		 * @param n The node which target coordinates are required.
		 * @return A Point object that contains the required coordinates.
		 * */
		public function getRelCartCoordinates( n : INode ) : Point
		{
			
			/* these may not yet have been initialised
			 * in this case, we preset them to the current
			 * Relative coordinates, i.e. minus the originOffset 
			 */
			var c : Point;
			
			c = _nodeCartCoordinates[ n ];
			
			/*if ( c == null )
			{
				if ( n.vnode )
				{
					n.vnode.refresh();	
					c =	new Point( n.vnode.x, n.vnode.y );
					c = c.subtract( _originOffset );
					
					if ( _centeredLayout )
					{
						c = c.subtract( _centerOffset );
					}
				}
				
				//setCartCoordinates(n,c);
			}*/
			
			return c;
		}
		
		/**
		 * Access the absolute cartesian coordinates of the given node.
		 * These are the absolute coordinates with the origin offset
		 * already applied.
		 * @param n The node which target coordinates are required.
		 * @return A Point object that contains the required absolute coordinates.
		 * */
		public function getAbsCartCoordinates( n : INode ) : Point
		{
			var res : Point = getRelCartCoordinates( n );
			
			/*if ( res )
			{
				res = res.add( _originOffset );
				
				if ( _centeredLayout )
				{
					res = res.add( _centerOffset );
				}
			}*/
			
			return res;
		}
		
		public function add( l : ILayoutDrawing ) : void
		{
			var key : *;
			
			for ( key in l.nodeCartCoordinates )
			{
				nodeCartCoordinates[ key ] = l.nodeCartCoordinates[ key ];
			}
			
			for ( key in l.nodePolarRs )
			{
				nodePolarRs[ key ] = l.nodePolarRs[ key ];
			}
			
			for ( key in l.nodePolarPhis )
			{
				nodePolarPhis[ key ] = l.nodePolarPhis[ key ];
			}
			
			/*for each( key in BaseLayoutDrawing( l ).testPoints )
			{
				testPoints.push( key );
			}*/
		}
		
		public function offset( delta : Point ) : void
		{
		   var pos : Point;
		   
		   for each( pos in _nodeCartCoordinates )
		   {
			   pos.offset( delta.x, delta.y );
		   }
		   
		  /* for each( var b : Object in testPoints )
		   {
			   b.pos.offset( delta.x, delta.y );
		   }*/
		}
		
		public function scale( value : Number ) : void
		{
			var pos : Point;
			
			for each( pos in _nodeCartCoordinates )
			{
				pos.x *= value;
				pos.y *= value;
			}
			
			/*for each( var b : Object in testPoints )
			{
				b.pos.x *= value;
				b.pos.y *= value;
			}*/
		}
	}
}
