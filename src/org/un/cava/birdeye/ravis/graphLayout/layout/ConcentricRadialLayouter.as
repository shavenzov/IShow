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
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.utils.Geometry;
	
	/**
	 * This is an implementation of the generic radial
	 * layout algorithm that uses concentric rings
	 * for the distance. In addition it will implement
	 * the animation algorithm by Yee et. al that moves
	 * nodes along their circles instead of in straight
	 * lines.
	 * */
	public class ConcentricRadialLayouter extends BaseLayouter implements ILayoutAlgorithm
	{
		public static const ID : String = 'ConcentricRadialLayouter';
		
		/**
		 * The default radius increase between
		 * the concentric circles.
		 * */
		private static const defaultRadius : Number = 100.0;
        
        /**
        * Smallest allowable radius
        */ 
		private static const minRadius : Number = 0;
		
		/**
		 * @internal
		 * the current maximum depth of the tree */
		private var _maxDepth:int = 0;
		
		/**
		 * @internal
		 * the current radius increase for each circle */
		//private var _radiusInc:Number = 0;
		
		/* the two bounding angles */
		private var _theta1:Number;
		private var _theta2:Number;	
		
		/* if we add views the initial size is 0,
		 * so we just keep track of the other nodes and
		 * use the largest size of a node to measure
		 */
		private var _maxviewwidth:Number = 0;
		private var _maxviewheight:Number = 0;

		/**
		 * this holds the data for a layout drawing.
		 * */
		private var _currentDrawing:ConcentricRadialLayoutDrawing;
        
        //private var _zoomToFit:Boolean;
		/**
		 * The constructor initializes the layouter and may assign
		 * already a VisualGraph object, but this can also be set later.
		 * @param vg The VisualGraph object on which this layouter should work on.
		 * */
		public function ConcentricRadialLayouter( vg : IVisualGraph, data : Object = null )
		{
			super( vg, data );
			
			/* this is inherited */
			//animationType = ANIM_STRAIGHT;
			
			_currentDrawing = null;
			
			_theta1 = 0;
			_theta2 = _theta1 + 360;
			
			_maxviewwidth = MINIMUM_NODE_WIDTH;
			_maxviewheight = MINIMUM_NODE_HEIGHT;
		}
		
		override protected function setDefaults() : void
		{
			super.setDefaults();
			
			_data.type = ID;
			
			/*if ( ! _data.hasOwnProperty( 'zoomToFit' ) )
			{
				_data.zoomToFit = false;
			}*/
			
			if ( ! _data.hasOwnProperty( 'radiusInc' ) )
			{
				_data.radiusInc = defaultRadius;
			}
		}
        
        private function get radiusInc() : Number
		{
            return Number( _data.radiusInc );
        }
		
        private function set radiusInc(value:Number):void {
           _data.radiusInc = Math.max(value,minRadius);
        }

		/**
		 * @inheritDoc
		 * */
		public override function resetAll():void {
			super.resetAll();
			_stree = null;
			graph.purgeTrees();
		}
		/*
        public function get zoomToFit():Boolean {
            return Boolean( _data.zoomToFit );
        }
        
        public function set zoomToFit( value : Boolean ) : void
		{
            _data.zoomToFit = value;
        }
		*/
		/**
		 * @inheritDoc
		 * */
		override public function set linkLength( r : Number ) : void
		{
			_data.radiusInc = r;
			sendChange();
		}
		
		/**
		 * @private
		 * */
		override public function get linkLength() : Number
		{
			return Number( radiusInc );
		}

		override public function calculate() : void
		{
			initDrawing();
			
			/* set the coordinates in the drawing of root
			* to 0,0 */
			_currentDrawing.setCartCoordinates( root, new Point( 0, 0 ) );
			
			/* establish the spanning tree, but have it restricted to
			* visible nodes */
			_stree = graph.getTree( root, true, false );
			
			_maxDepth = _stree.maxDepth;
			
			/* calculate the radius increment to fit the screen */
			autoFit();
			
			/* calculate the relative width and the
			* new max Depth */
			calcAngularWidth( root, 0 );
			
			/* do a static layout pass */
			if ( _maxDepth > 0 )
			{
				calculateStaticLayout( root, radiusIncs[ 0 ], _theta1, _theta2 );
			}
			
			super.calculate();
		}
	
        /*
        protected function doZoomToFit():void 
        {
            _currentDrawing.centeredLayout = false;
            var offset:Point = new Point(-bounds.x/2,-bounds.y/2);
            _currentDrawing.originOffset = offset;
            
            var wF:Number = (vgraph.width - margin)/(bounds.width);
            var hF:Number = (vgraph.height - margin)/(bounds.height);
            var sF:Number = Math.min(wF,hF);
            var newS:Number = Math.min(1, sF);
            vgraph.scale = newS;
            
            var setupsCenter:Point = new Point(bounds.width/2 , bounds.height/2);
            var ourCenter:Point = new Point(vgraph.width/newS/2, vgraph.height/newS/2);
            
            var transformPoint:Point = setupsCenter.subtract(ourCenter);
            for each(var node:INode in _stree.nodes )
            {
                var p:Point = _currentDrawing.getAbsCartCoordinates(node);
                p.x -= transformPoint.x;
                p.y -= transformPoint.y;
                _currentDrawing.setCartCoordinates(node,p);
            } 
        }
         */
		/*
		 * private functions
		 * */
		 
		/**
		 * @internal
		 * create a new layout model object, which is required
		 * on any root change (and possibly during other occasions)
		 * */
		private function initDrawing():void {			
			_currentDrawing = new ConcentricRadialLayoutDrawing();
			
			/* don't forget to set the object also in the 
			 * BaseLayouter */
			super.currentDrawing = _currentDrawing;
			
			/*_currentDrawing.originOffset = _vgraph.origin;
			_currentDrawing.centerOffset = _vgraph.center;
			_currentDrawing.centeredLayout = true;*/
			//LogUtil.debug(_LOG, "New Drawing with origin:"+_currentDrawing.originOffset.toString());
		}
		
		private static const CRITICAL_ANGULAR_WIDTH : Number = 220.0;
		
		/**
		 * Минимальное значение приращения радиуса 
		 */		
		private static const MIN_RADIUS_INC : Number = 200;
		
		/**
		 * @internal
		 * this autofit method sets the radius increment
		 * so that it should fit into the screen
		 * */
		protected function autoFit() : void
		{
			if ( autoFitEnabled )
			{
				/*radiusInc = defaultRadius;
				
				if ( fitToWindow )
				{
					initializeRadiusIncs();
				}
				else
				{*/
					radiusInc = Math.max( MIN_RADIUS_INC, /*radiusInc*/ defaultRadius );
					
					initializeRadiusIncs();
					
					var i               : int;
					var calcAgain       : Boolean; 
					var maxAngularWidth : Number;
					
					calcMaxAngularWidths( root );
					
					for ( i = 0; i < radiusIncs.length; i ++ )
					{
						do
						{
							maxAngularWidth = maxAngularWidths[ i ];
							
							calcAgain = maxAngularWidth >= CRITICAL_ANGULAR_WIDTH;
							
							if ( calcAgain )
							{
								radiusIncs[ i ] += 10;
								calcMaxAngularWidths( root );
							}
						}
						while( calcAgain );	
					}
					
					radiusIncs.sort( Array.NUMERIC | Array.DESCENDING );
				//}
			}
			else
			{
				initializeRadiusIncs();
			}
		}
		
		private function initializeRadiusIncs() : void
		{
			radiusIncs = new Vector.<Number>( _maxDepth + 1 );
			
			for ( var i : int = 0; i < radiusIncs.length; i ++ )
			{
				radiusIncs[ i ] = radiusInc;
			}
		}
		
		/**
		 * Временная переменная хранящая максимальное количество узлов на каждом уровне 
		 */		
		private var maxAngularWidths : Vector.<Number>;
		
		/**
		 * Значения приращений радиусов на каждом уровне 
		 */		
		private var radiusIncs : Vector.<Number>;
		
		private function calcMaxAngularWidths( n : INode, d : int = 0, r : Number = NaN ) : Number
		{
			var aw:Number = 0;
			var nw:Number;
			var nh:Number;
			var diameter:Number;
			var cn:INode; // child node
			
			/* the following two may be 0 in an early stage
			* so we have to get around that issue 
			* if it is 0 we assign a default size */
			nw = n.vnode.view.width;
			nh = n.vnode.view.height;
			
			/* update the max view width and height */
			_maxviewwidth = Math.max(_maxviewwidth, nw);
			_maxviewheight = Math.max(_maxviewheight, nh);
			
			if ( nw == 0 )
			{
				nw = _maxviewwidth;
			}
			
			if ( nh == 0 )
			{
				nh = _maxviewheight;
			}
			
			//Значение приращения радиуса не инициализировано
			if ( isNaN( r ) )
			{
				r = radiusIncs[ d ];
			}
			
			if ( d == 0 )
			{
				diameter = 0; // root node
				maxAngularWidths = new Vector.<Number>( _maxDepth + 1 );
				maxAngularWidths[ 0 ] = 0.0;
			}
			else
			{
				/* in another implementation this divided the real
				* diameter by d not by d times the radiusINcrement
				* which yields way too large values */
				diameter = Math.sqrt( nw*nw + nh*nh ) / /*( d * radiusInc)*/r;
				/* diameter is an angular width value in radians,
				* so we convert it to degrees when used */
				diameter = Geometry.rad2deg( diameter );
			}
			
			/* here the code checks if the node 'is expanded'
			* which means if he has visible children
			* we do it differently, if the node is invisible
			* his angular width is 0, so is it for all his
			* children in case they are not visible
			* this may be a bit less efficient, but it fits
			* our code */
			if(_stree.getNoChildren(n) > 0)
			{
				for each(cn in _stree.getChildren(n)) {
					aw += calcMaxAngularWidths( cn, d + 1, r + radiusIncs[ d + 1 ] );
					
				}
				
				aw = Math.max( diameter, aw );
			} 
			else
			{
				aw = diameter;
			}
			
			//Если не корневой узел		
			if ( d != 0 )
			{
			   if ( d < maxAngularWidths.length )
			   {
				   maxAngularWidths[ d ] = Math.max( maxAngularWidths[ d ], aw );
			   }
			   else
			   {
				   maxAngularWidths[ d ] = aw;
			   }
			}
			
			return aw;
		}
		
		/**
		 * @internal
		 * This calculates the angular width of a subtree.
		 * @param n the root node of the subtree.
		 * @param d the current depth.
		 * @return The angular width of the subtree rooted in n at level d.
		 * */
		private function calcAngularWidth(n:INode, d:int):Number {
			var aw:Number = 0;
			var nw:Number;
			var nh:Number;
			var diameter:Number;
			var cn:INode; // child node
			
			/*if ( ! n.vnode.isVisible )
			{
				return 0;
			}*/
			
			/* the following two may be 0 in an early stage
			 * so we have to get around that issue 
			 * if it is 0 we assign a default size */
			nw = n.vnode.view.width;
			nh = n.vnode.view.height;
			
			/* update the max view width and height */
			_maxviewwidth  = Math.max( _maxviewwidth, nw );
			_maxviewheight = Math.max( _maxviewheight, nh );
			
			if ( nw == 0 )
			{
				nw = _maxviewwidth;
			}
			
			if ( nh == 0 )
			{
				nh = _maxviewheight;
			}
			
			if ( d == 0 )
			{
				diameter = 0; // root node 
			} else {
				/* in another implementation this divided the real
				 * diameter by d not by d times the radiusINcrement
				 * which yields way too large values */
				diameter = Math.sqrt( nw*nw + nh*nh ) / (d * radiusIncs[ d ]);
				/* diameter is an angular width value in radians,
				* so we convert it to degrees when used */
				diameter = Geometry.rad2deg(diameter);
			}
				
			/* here the code checks if the node 'is expanded'
			 * which means if he has visible children
			 * we do it differently, if the node is invisible
			 * his angular width is 0, so is it for all his
			 * children in case they are not visible
			 * this may be a bit less efficient, but it fits
			 * our code */
			if(_stree.getNoChildren(n) > 0)
			{
				for each(cn in _stree.getChildren(n)) {
					aw += calcAngularWidth(cn, d+1);
					
				}
				
				aw = Math.max( diameter, aw );
			} 
			else
			{
				aw = diameter;
			}
			
			_currentDrawing.setAngularWidth(n,aw);
			
			return aw;
		}
		
		/**
		 * @internal
		 * calculate recursiveley the layout of the current
		 * subtree
		 * @param n The root of the current subtree.
		 * @param r The current radius (distance from center).
		 * @param theta1 The start of the current subtrees angular bounds region.
		 * @param theta2 The end of the current subtrees angular bounds region.
		 * */
		private function calculateStaticLayout( n : INode, r : Number, theta1 : Number, theta2 : Number, d : uint = 0 ) : void
		{
			var dtheta:Number;
			var dtheta2:Number;
			var awidth:Number;
			var cfrac:Number;
			var nfrac:Number;
			var i:int;
			var cc:int;
			var cn:INode;

			dtheta = theta2 - theta1;
			dtheta2 = dtheta / 2.0;
			nfrac = 0.0;
			cfrac = 0.0;
			awidth = _currentDrawing.getAngularWidth(n);	
			
			cc = _stree.getNoChildren( n );
			
			for( i=0; i < cc; ++i )
			{
				cn = _stree.getIthChildPerNode( n, i );			
				cfrac = _currentDrawing.getAngularWidth( cn ) / awidth;
				
				/* do we need to recurse, 
				 * we just recurse if the node has children */
				if ( _stree.getNoChildren( cn ) > 0 )
				{
					calculateStaticLayout( cn, r + radiusIncs[ d + 1 ], 
						theta1 + ( nfrac * dtheta ),
						theta1 + ( ( nfrac + cfrac ) * dtheta ), d + 1 );
				}
				
				//LogUtil.debug(_LOG, "CSL: current radius:"+r);
				_currentDrawing.setPolarCoordinates( cn, r, theta1 + ( nfrac * dtheta ) + ( cfrac * dtheta2 ) );
				
				/* set the orientation in the visual node */
				//cn.vnode.orientAngle = theta1+(nfrac*dtheta)+(cfrac*dtheta2);
				//trace( 'angle', cfrac, nfrac, theta1+(nfrac*dtheta)+(cfrac*dtheta2) );
				
				nfrac += cfrac;	
			}
		}
	}
}
