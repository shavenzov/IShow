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
    
    import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
    import org.un.cava.birdeye.ravis.graphLayout.data.INode;
    import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
    import org.un.cava.birdeye.ravis.utils.Geometry;
    
    /**
     * This is an implementation of the circular layout -
     * all visible nodes are arranged in a circle
     * 
     * @author Nitin Lamba
     * */
    public class CircularLayouter extends BaseLayouter {
        
        public static const ID : String = 'CircularLayouter';  
        
        /**
         * The radius of the layout
         */
        //private var _radius:Number = 200;
        
        /* The initial starting angle of the layout
        */
        //private var _phi:Number = 0;
        
        /**
         * this holds the data for a layout drawing.
         * */
        private var _currentDrawing : CircularLayoutDrawing;
        
        /**
         * The constructor only initialises some data structures.
         * @inheritDoc
         * */
        public function CircularLayouter( vg : IVisualGraph = null, data : Object = null )
		{
            super( vg, data );
            
			//animationType = ANIM_STRAIGHT; // inherited
            _currentDrawing = null; 
        }
		
		override protected function setDefaults() : void
		{
			super.setDefaults();
			
			_data.type = ID;
			
			if ( ! _data.hasOwnProperty( 'radius' ) )
			{
				_data.radius = 200;
			}
			
			if ( ! _data.hasOwnProperty( 'phi' ) )
			{
				_data.phi = 0;
			}
			
			if ( ! _data.hasOwnProperty( 'style' ) )
			{
				_data.style = CircularLayouterStyle.SINGLE_CYCLE;
			}
		}
		
		public function get style() : uint
		{
			return _data.style;
		}
		
		public function set style( value : uint ) : void
		{
			_data.style = value;
			sendChange();
		}
        
        /**
         * @inheritDoc
         * */
        override public function resetAll() : void
		{
            super.resetAll();
            initDrawing();
            _layoutChanged = true;			
        }
        
		override public function calculate() : void
		{
			_stree = graph.getTree( root, true, false );
			
			initDrawing();
			calculateAutoFit();
			calculateNodes();
			
			super.calculate();
		}
        
        private function get radius() : Number
		{
			return Number( _data.radius );
		}
		
		private function set radius( value : Number ) : void
		{
			_data.radius = value;
		}
		
		/**
         * @inheritDoc
         * */
        override public function get linkLength():Number {
            return Number( _data.radius );
        }
        /**
         * @private
         * */
        override public function set linkLength(rr:Number):void {
            _data.radius = rr;
			sendChange();
        }
        
        /**
         * Access the starting angle of the layout
         * */
        public function get phi():Number {
            return Number( _data.phi );
        }
        /**
         * Set the starting angle of the layout. Modifying this 
         * value rotates the layout by a given angle
         * */
        public function set phi(p:Number):void {
            _data.phi = p;
			sendChange();
        }
        
        /* private methods */
        
        /**
         * @internal
         * Create a new layout drawing object, which is required
         * on any root change (and possibly during other occasions)
         * and intialise various parameters of the drawing.
         * */
        private function initDrawing() : void
		{
            _currentDrawing = new CircularLayoutDrawing();
            
            /* Also set the object also in the BaseLayouter */
            super.currentDrawing = _currentDrawing;
			
			if ( style != CircularLayouterStyle.SINGLE_CYCLE )
			{
				_currentDrawing.initialize( _stree );
			}
            
           /* if ( _vgraph )
            {
                _currentDrawing.originOffset = _vgraph.origin;
                _currentDrawing.centerOffset = _vgraph.center;
            }
			
            _currentDrawing.centeredLayout = true;
			*/
        }
        
		/**
         * @internal
         * Calculate the polar angles of the nodes */
        private function calculateNodes() : void
		{
           switch( style )
		   {
			   case CircularLayouterStyle.SINGLE_CYCLE : calculateNodesForSingleCycleStyle();
				   break;
			   
			   case CircularLayouterStyle.BICONNECTED_INSIDE : calculateNodesForBiconnectedInsideStyle();
				   break;
			   
			   case CircularLayouterStyle.BICONNECTED_OUTSIDE : calculateNodesForBiconnectedOutsideStyle();
				   break;
		   }
		}
		
		private function calculateNodesForSingleCycleStyle() : void
		{
			/* needed for the calculation */
			var phi : Number;
			var ni  : INode;
			
			var nodes : Vector.<INode> = _stree.sortedNodes;
			var i     : int = 1;
			
			for each( ni in nodes ) 
			{
				phi = this.phi + ( 360 * i ) / nodes.length;
				phi = Geometry.normaliseAngleDeg( phi );
				_currentDrawing.setPolarCoordinates( ni, radius, phi );
				
				i ++;    
			}
		}
		
		private function calculateNodesForBiconnectedInsideStyle() : void
		{
			var biconnectedNodes : Vector.<INode> = Graph.sortNodes( _currentDrawing.biconnectedNodes );
			var phi              : Number;
			var node             : INode;
			var i                : int;
			
			i = 1;
			
			for each( node in biconnectedNodes )
			{
				phi = this.phi + ( 360 * i ) / biconnectedNodes.length;
				phi = Geometry.normaliseAngleDeg( phi );
				_currentDrawing.setPolarCoordinates( node, radius, phi );
				_currentDrawing.indexes[ node ] = i;
				
				i ++;
			}
			
			for each( node in _currentDrawing.singleConnectedNodes )
			{
				i = _currentDrawing.indexes[ _stree.parents[ node ] ];
				
				phi = this.phi + ( 360 * i ) / biconnectedNodes.length;
				phi = Geometry.normaliseAngleDeg( phi );
				_currentDrawing.setPolarCoordinates( node, radius + radius, phi );
			}
		}
		
		private function calculateNodesForBiconnectedOutsideStyle() : void
		{
			var singleConnectedNodes : Vector.<INode> = Graph.sortNodes( _currentDrawing.singleConnectedNodes );
			var phi              : Number;
			var node             : INode;
			var i                : int;
			
			i = 1;
			
			for each( node in singleConnectedNodes )
			{
				phi = this.phi + ( 360 * i ) / singleConnectedNodes.length;
				phi = Geometry.normaliseAngleDeg( phi );
				_currentDrawing.setPolarCoordinates( node, radius, phi );
				_currentDrawing.indexes[ node ] = i;
				
				i ++;
			}
			
			var depth    : int;
			var maxDepth : int = _stree.maxDepth;
			
			for each( node in _currentDrawing.biconnectedNodes )
			{
				i = getNodeIndex( node );
				depth = maxDepth - _stree.getDistance( node );
				
				phi = this.phi + ( 360 * i ) / singleConnectedNodes.length;
				phi = Geometry.normaliseAngleDeg( phi );
				_currentDrawing.setPolarCoordinates( node, radius + ( radius / 2 ) * depth, phi );
				_currentDrawing.indexes[ node ] = i;
				
				i ++;
			}
		}
		
		private function getNodeIndex( node : INode ) : int
		{
			if ( _currentDrawing.indexes[ node ] )
			{
				return _currentDrawing.indexes[ node ];
			}
			
			var children : Vector.<INode> = _stree.getChildren( node );
			var child    : INode;
			var index    : int = -1;
			
			for each( child in children )
			{
				index = getNodeIndex( child );
				
				if ( index != -1 )
				{
					return index;
				}
			}
			
			return index;
		}
        
        /**
         * @internal
         * Do all the calculations required for autoFit
         * */
        private function calculateAutoFit() : void
		{
           if ( autoFitEnabled )
		   {
			   switch( style )
			   {
				   case CircularLayouterStyle.SINGLE_CYCLE : calcAutoFitForSingleCycleStyle();
					   break;
				   
				   case CircularLayouterStyle.BICONNECTED_INSIDE : calcAutoFitForBiconnectedInsideStyle();
					   break;
				   
				   case CircularLayouterStyle.BICONNECTED_OUTSIDE : calcAutoFitForBiconnectedOutsideStyle();
					   break;
			   }
		   }
        }
		
		private function calcAutoFitForSingleCycleStyle() : void
		{
			if ( fitToWindow )
			{
				radius = Math.min( boundingRect.width, boundingRect.height ) / 2.0;	
			}
			else
			{
			    radius = 100.0;	
			}
			
			while( ! checkRadius( radius, _stree.nodes ) )
			{
				radius += 10.0;
			}
		}
		
		private function calcAutoFitForBiconnectedInsideStyle() : void
		{
			if ( _currentDrawing.singleConnectedNodes.length == 0 )
			{
				calcAutoFitForSingleCycleStyle();
			}
			
			radius  = 100;
			
			while( ! checkRadius( radius, _currentDrawing.biconnectedNodes ) )
			{
				radius += 10.0;
			}
			
			//radius -= radius / 4;
		}
		
		private function calcAutoFitForBiconnectedOutsideStyle() : void
		{
			if ( _currentDrawing.biconnectedNodes.length == 0 )
			{
				calcAutoFitForSingleCycleStyle();
			}
			
			radius  = 100;
			
			while( ! checkRadius( radius, _currentDrawing.singleConnectedNodes ) )
			{
				radius += 10.0;
			}
			
			//radius -= radius / 4;
		}
		
		/**
		 * Проверяет уместятся ли все узлы, не пересекаясь на круговой компоновке указанного радиуса 
		 * @param r радиус круговой компоновки
		 * @return true  - умещаются
		 *         false - не умещаются  
		 * 
		 */		
		protected function  checkRadius( r : Number, nodes : * ) : Boolean
		{
			var w         : Number;
			var h         : Number;
			var node      : INode;
			var nodesL    : Number = 0.0;
			
			for each( node in nodes )
			{
				w = node.vnode.view.width;
				h = node.vnode.view.height;
				
				nodesL += Math.sqrt( w * w + h * h );
			}
			
			var l : Number = 2 * Math.PI * r;
			
			return l > nodesL;
		}
		
		override public function get needRoot() : Boolean
		{
			return style != CircularLayouterStyle.SINGLE_CYCLE;
		}
    }
}
