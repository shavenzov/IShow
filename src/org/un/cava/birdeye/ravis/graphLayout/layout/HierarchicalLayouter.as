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
    
    /**
     * This layouter implements the drawing of generalized trees
     * in a hierarchical fashion using the algorithm by
     * Christoph Buchheim, Michael Juenger and Sebastian Leipert
     * presented in their paper 
     * "Improving Walker's Algorithm to run in linear time"
     * */
    public class HierarchicalLayouter extends BaseLayouter implements ILayoutAlgorithm {
        
        public static const ID : String = 'HierarchicalLayouter';
	
        /** this holds the data for the Hierarchical layout drawing */
        protected var _currentDrawing:HierarchicalLayoutDrawing;
        
        /* this is the distance between nodes within a layer
        * typically x distance if top-bottom orientation
        * it may be preset by autofit */
        //protected var _breadth:Number;
        
        /* set to true if you want node sizes to be taken
        * into account */
        //private var _honorNodeSize:Boolean;
        
        /* this is the distance between layers, or typically
        * the y distance if top-bottom orientation.
        * Again it may be set by autofit */
        //protected var _linkLength:Number;
        
        /* this holds the actual orientation */
        //private var _orientation:uint;
        
        /* this enables an additional spread of nodes within the
        * same layer, but which are all siblings */
        //private var _siblingSpreadEnabled:Boolean;
        
        /* the corresponding distance, should be at least */
        //private var _siblingSpreadDistance:Number;
        
        /* enables interleaved spread of nodes if _siblingSpreadEnabled is true */
        //private var _interleaveSiblings:Boolean;
        
        /**
         * The constructor only initialises some data structures.
         * @inheritDoc
         * */
        public function HierarchicalLayouter( vg : IVisualGraph, data : Object = null )
		{
            super( vg, data );
            //animationType = ANIM_STRAIGHT; // inherited
            initModel();
            
            /*_breadth = 10;
            _linkLength = 10;
            _orientation = ORIENT_TOP_DOWN;
            //_orientation = ORIENT_BOTTOM_UP;
            _siblingSpreadEnabled = false;
            _siblingSpreadDistance = 10;
            _honorNodeSize = false;
            _interleaveSiblings = false;*/
        }
		
		override protected function setDefaults() : void
		{
			super.setDefaults();
			
			_data.type = ID;
			
			if ( ! _data.hasOwnProperty( 'breadth' ) )
			{
				_data.breadth = 10.0;
			}
			
			if ( ! _data.hasOwnProperty( 'linkLength' ) )
			{
				_data.linkLength = 50.0;
			}
			
			if ( ! _data.hasOwnProperty( 'orientation' ) )
			{
				_data.orientation = LayoutOrientation.TOP_DOWN;
			}
			
			if ( ! _data.hasOwnProperty( 'siblingSpreadEnabled' ) )
			{
				_data.siblingSpreadEnabled = false;
			}
			
			if ( ! _data.hasOwnProperty( 'siblingSpreadDistance' ) )
			{
				_data.siblingSpreadDistance = 10.0;
			}
			
			if ( ! _data.hasOwnProperty( 'honorNodeSize' ) )
			{
				_data.honorNodeSize = false;
			}
			
			if ( ! _data.hasOwnProperty( 'interleaveSiblings' ) )
			{
				_data.interleaveSiblings = false;
			}
		}
        
        /**
         * @inheritDoc
         * */
        override public function resetAll():void {			
            
            super.resetAll();
            
            /* invalidate all trees in the graph */
            _stree = null;
            
            /* handles if we have been reset when 
            we do not have a graph */
            if(graph)
            {
                graph.purgeTrees();
            }
            
            initModel();
        }
        
		override public function calculate() : void
		{
			/* establish the spanning tree */
			//_graph.purgeTrees();
			_stree = graph.getTree( root, true, false );
			
			/* check if the root is visible, if not
			* this is an issue */
			// if( ! _root.vnode.isVisible ) {
			//LogUtil.warn(_LOG, "Invisible root node, this is probably due to wrong initialisation of nodes or wrong defaults");
			//   return false;
			//}
			
			/* need to see where how we could get a clear
			* list of situation how to deal with hab
			* if the layout was changed (or any parameter)
			* we have to reinit the model */
			initModel();
			calculateAutoFit();
			
			/* do the first pass */
			firstWalk( root );
			
			/* and now the second */
			secondWalk( root, -_currentDrawing.getPrelim( root ) );
			
			super.calculate();
		}
        
        /**
         * @inheritDoc
         * */
        override public function get linkLength() : Number {
            return Number( _data.linkLength );
        }
        /**
         * @private
         * */
        override public function set linkLength( value : Number ) : void {
            _data.linkLength = value;
			sendChange();
        }
        
        /**
         * Set the spacing between the nodes within a layer.
         * Typical range 0 .. 100 should be ok.
         * */
        public function set breadth( b : Number ) : void {
            _data.breadth = b;
			sendChange();
        }
        
        /**
         * @private
         * */
        public function get breadth():Number {
            return Number( _data.breadth );
        }		
        
        /**
         * Enable a spreading out of sibling nodes to
         * make labels more legible in some cases.
         * */
        public function set enableSiblingSpread(ss:Boolean):void {
            _data.siblingSpreadEnabled = ss;
			sendChange();
            /* notify controls (specifically interleaving toggle */
            /*if(_vgraph) {
                _vgraph.dispatchEvent(new VGraphEvent(VGraphEvent.LAYOUTER_HIER_SIBLINGSPREAD));
            }*/
        }
        
        /**
         * @private
         * */
        public function get enableSiblingSpread():Boolean {
            return Boolean( _data.siblingSpreadEnabled );
        }
        
        /**
         * Enable a interleaved spreading out of sibling nodes to
         * make labels more legible in some cases.
         * */
        public function set interleaveSiblings(value:Boolean):void {
            _data.interleaveSiblings = value;
			sendChange();
        }
        
        /**
         * @private
         * */
        public function get interleaveSiblings():Boolean {
            return Boolean( _data.interleaveSiblings );
        }
        
        /**
         * Allows to specify the fixed distance to spread the
         * siblings.
         * @default 10
         * */
        public function get siblingSpreadDistance():Number {
            return Number( _data.siblingSpreadDistance );	
        }
        
        /**
         * @private
         * */
        public function set siblingSpreadDistance(distance:Number):void {
            _data.siblingSpreadDistance = distance;
			sendChange();
        }
        
        /**
         * Allow to specify that node size should be honored
         * when spacing.
         * @default false
         * */
        public function get honorNodeSize():Boolean {
            return Boolean( _data.honorNodeSize );
        }
        
        /**
         * @private
         * */
        public function set honorNodeSize(honor:Boolean):void {
            _data.honorNodeSize = honor;
			sendChange();
        }
        
        /**
         * Set the orientation for the hierarchical
         * layouter. Available values are provided through
         * defined constants. Use one of:
         * HierarchicalLayouter.ORIENT_TOP_DOWN
         * HierarchicalLayouter.ORIENT_BOTTOM_UP
         * HierarchicalLayouter.ORIENT_LEFT_RIGHT
         * HierarchicalLayouter.ORIENT_RIGHT_LEFT
         * 
         * @param o The orientation value, one of the above.
         * */
        public function set orientation(o:uint):void {
            switch( o ) {
            case LayoutOrientation.LEFT_RIGHT:
            case LayoutOrientation.RIGHT_LEFT:
            case LayoutOrientation.TOP_DOWN:
            case LayoutOrientation.BOTTOM_UP:
                _data.orientation = o;
				sendChange();
                break;
            default:
                //LogUtil.warn(_LOG, "orientation:"+o+" not supported");
            }
        }
        
        /**
         * @private
         * */
        public function get orientation():uint {
            return uint( _data.orientation );
        }
        
        /* private methods */
        
        /**
         * @internal
         * This does the first pass over the nodes, recursing
         * downwards to each leaf and computing the preliminary
         * x value for each node. It also calls the "apportion()"
         * function which is the heart of the algorithm.
         * Then the children are spaced by executeShifts and finally
         * the node is moved to the center of its children.
         * @param v The root of the current subtree to work on.
         * */
        private function firstWalk(v:INode):void {
            var nochild:uint;
            var child:INode;
            var sibling:INode;
            var i:uint;
            var midpoint:Number;
            var prelimsib:Number;
            var vindex:uint;
            var depthOffset:Number;
            var defaultAncestor:INode;
            var ilfactor:int = 1; // for interleaving
            
            nochild = _stree.getNoChildren(v);
            vindex = _stree.getChildIndex(v);
            
            if ( nochild == 0 ) {
                /* if v's childindex is > 0 then there is a 
                * node with a smaller one, i.e. one on the left and we need to space it */
                if(vindex > 0) { 
                    /* get the left sibling by getting the vindex - 1'th child of
                    * it's parent */
                    sibling = _stree.getIthChildPerNode(_stree.parents[v],vindex - 1);
                    
                    /* get the prelim value of the sibling */
                    prelimsib = _currentDrawing.getPrelim(sibling);
                    
                    /* now set it for this node, but add the spacing */
                    _currentDrawing.setPrelim( v, prelimsib + spacing( sibling, v ) );
                } else {
                    _currentDrawing.setPrelim( v, 0 );
                }  
            } else {
                /* init to the first (0th, leftmost) child of v, 
                * may be modified by apportion() */
                defaultAncestor = _stree.getIthChildPerNode( v, 0 );
                
                depthOffset = 0;
                
                for(i=0; i < nochild; ++i) {
                    child = _stree.getIthChildPerNode(v,i);
                    /* recurse */
                    firstWalk(child);
                    /* and call apportion */
                    defaultAncestor = apportion(child, defaultAncestor);
                    
                    /* apply the depth offset for each child */
                    if(enableSiblingSpread) {
                        _currentDrawing.setDepthOffset(child,depthOffset);
                        // Not so .. Dirty hack for interleaving
                        depthOffset += ilfactor * siblingSpreadDistance;
                        if(interleaveSiblings) {
                            ilfactor = -ilfactor;
                        }
                    }
                }
                
                /* do the shifts */
                executeShifts( v );
                
                /* now center the node above its children */
                
                /* get the prelim value of the leftmost child */
                child    = _stree.getIthChildPerNode( v, 0 );
                midpoint = _currentDrawing.getPrelim( child );
                
                /* now add the prelim of the rightmost child */
                child    = _stree.getIthChildPerNode( v, nochild - 1 );
                midpoint += _currentDrawing.getPrelim( child );
                
                /* now half it to get the center */
                midpoint = 0.5 * midpoint;
                
                /* if v's childindex is > 0 then there is a 
                * node with a smaller one, i.e. one on the left.
                */
                if ( vindex > 0 ) {
                    /* get the left sibling by getting the vindex - 1'th child of
                    * it's parent */
                    sibling = _stree.getIthChildPerNode(_stree.parents[v],vindex - 1);
                    
                    /* get the prelim value of the sibling */
                    prelimsib = _currentDrawing.getPrelim(sibling);
                    
                    /* now set it for this node, but add the spacing */
                    _currentDrawing.setPrelim(v, prelimsib + spacing(sibling,v));
                    
                    /* also set the modifier for v */
                    _currentDrawing.setModifier( v, _currentDrawing.getPrelim( v ) - midpoint );
                } else {
                    _currentDrawing.setPrelim( v, midpoint );
                }
            }
        }
        
        /**
         * This method combines a subtree with other subtrees, traverses
         * their contours/outlines using 'thread' pointers, etc.
         * @param v The node (root of subtree) to work on.
         * @param defaultAncestor (self explaining).
         * */
        private function apportion(v:INode, da:INode):INode {
            var vinsideleft:INode;
            var vinsideright:INode;
            var voutsideleft:INode;
            var voutsideright:INode;
            var sumileft:Number;
            var sumiright:Number;
            var sumoleft:Number;
            var sumoright:Number;
            var shift:Number;
            var vindex:uint;
            var w:INode;
            var defaultAncestor:INode;
            var lgua:INode; // left greatest uncommon ancestor
            
            defaultAncestor = da;
            
            /* if we have a left sibling w */
            vindex = _stree.getChildIndex(v);
            if ( vindex > 0 ) {
                w = _stree.getIthChildPerNode( _stree.parents[ v ], vindex  - 1 );
                
                vinsideright = v;
                voutsideright = v;
                vinsideleft = w;
                
                /* the leftmost sibling of vinsideright which is v */
                voutsideleft = _stree.getIthChildPerNode(_stree.parents[v],0);
                
                sumiright = _currentDrawing.getModifier( vinsideright );
                sumoright = _currentDrawing.getModifier( voutsideright );
                sumileft  = _currentDrawing.getModifier( vinsideleft );
                sumoleft  = _currentDrawing.getModifier( voutsideleft );
                
                while( ( nextRight( vinsideleft ) != null ) && ( nextLeft( vinsideright ) != null ) ) {
                    
                    /* traverse the inside nodes more to the inside
                    * and the outside nodes further out */
                    vinsideright = nextLeft(vinsideright);
                    voutsideright = nextRight(voutsideright);
                    vinsideleft = nextRight(vinsideleft);
                    voutsideleft = nextLeft(voutsideleft);
                    
                    /* adjust the ancestor */
                    _currentDrawing.setAncestor(voutsideright,v);
                    
                    shift = (sumileft + _currentDrawing.getPrelim(vinsideleft)) -
                        (sumiright + _currentDrawing.getPrelim(vinsideright)) +
                        spacing(vinsideleft,vinsideright);
                    
                    if(shift > 0) {
                        /* get the left greatest uncommon ancestor */
                        lgua = leftGrUnAncestor(vinsideleft, v, defaultAncestor);
                        /* now move the subtree by shift */
                        moveSubtree(lgua, v, shift);
                        /* adjust sums */
                        sumiright += shift;
                        sumoright += shift;
                    }
                    
                    sumileft += _currentDrawing.getModifier(vinsideleft);
                    sumiright += _currentDrawing.getModifier(vinsideright);
                    sumoleft += _currentDrawing.getModifier(voutsideleft);
                    sumoright += _currentDrawing.getModifier(voutsideright);
                } // while
            } // if vindex > 0
            
            if((nextRight(vinsideleft) != null) && (nextRight(voutsideright) == null)) {
                /* set the thread pointer */
                _currentDrawing.setThread(voutsideright, nextRight(vinsideleft));
                /* add to the modifier */
                _currentDrawing.addToModifier(voutsideright, (sumileft - sumoright));
            }
            
            if((nextLeft(vinsideright) != null) && (nextLeft(voutsideleft) == null)) {
                /* set the thread pointer */
                _currentDrawing.setThread(voutsideleft, nextLeft(vinsideright));
                /* add to the modifier */
                _currentDrawing.addToModifier(voutsideleft, (sumiright - sumoleft));
                /* update the default ancestor */
                defaultAncestor = v;
            }
			
            return defaultAncestor;
        } // function 
        
        
        /**
         * returns the next node of the left contour/outline
         * of the subtree */
        private function nextLeft(v:INode):INode {
            /* if the node has children we return the leftmost
            * child, if not, we return the thread of the node */
            if(_stree.getNoChildren(v) > 0) {
                return _stree.getIthChildPerNode(v,0);
            } else {
                return _currentDrawing.getThread(v);
            }
        }
        
        /**
         * returns the next node of the right contour/outline
         * of the subtree */
        private function nextRight(v:INode):INode {
            var nochildren:uint;
            
            nochildren = _stree.getNoChildren(v);
            
            /* if the node has children we return the rightmost
            * child, if not, we return the thread of the node */
            if(nochildren > 0) {
                return _stree.getIthChildPerNode(v,nochildren - 1);
            } else {
                return _currentDrawing.getThread(v);
            }
        }
        
        /**
         * Moves the subtree in wright by shift, all other moves
         * are done later, but we remember their change and shift
         * values.
         * */
        private function moveSubtree(wleft:INode, wright:INode, shift:Number):void {
            var subtrees:int;
            
            subtrees = _stree.getChildIndex(wright) - _stree.getChildIndex(wleft);
            
            _currentDrawing.addToChange(wright, -(shift / subtrees));
            _currentDrawing.addToChange(wleft, (shift / subtrees));
            _currentDrawing.addToShift(wright, shift);
            _currentDrawing.addToPrelim(wright, shift);
            _currentDrawing.addToModifier(wright, shift);
        }
        
        /**
         * Finally execute all shifts that were accumulated
         * in previous moveSubtree calls
         * */
        private function executeShifts(v:INode):void {
            var shift:Number;
            var change:Number;
            var w:INode;
            var nochildren:uint;
            var i:int;
            
            shift = 0;
            change = 0;
            
            nochildren = _stree.getNoChildren(v);
            /* need to walk from right to left here */
            for(i=(nochildren -1); i >= 0; --i) {
                w = _stree.getIthChildPerNode(v,i);
                _currentDrawing.addToPrelim(w,shift);
                _currentDrawing.addToModifier(w,shift);
                
                change += _currentDrawing.getChange(w);
                shift += _currentDrawing.getShift(w) + change;
            }
        }
        
        
        /**
         * Finds and returns the left one of the greatest
         * uncommon ancestors of vileft and its right neighbour.
         * */
        private function leftGrUnAncestor(vileft:INode, v:INode, da:INode):INode {
            var avileft:INode;
            
            avileft = _currentDrawing.getAncestor(vileft);
            
            if(_stree.areSiblings(avileft,v)) {
                return avileft;
            } else {
                return da;
            }
        }
        
        /**
         * Computes the real x values from all the saved parameters
         * this is not yet subject to orientation, but could be
         * done here.
         * @param n The node set its coordinates.
         * @param m An accumulated modifier.
         * */
        private function secondWalk( v : INode, m : Number, depthInc : Number = 0.0, d : int = 0 ) : void {
            var breadth  : Number;
            var depth    : Number;
            var children : Vector.<INode>;
            var w        : INode;
            var result   : Point;
            
            /* the depth value is the depth from the root times
            * the layerDistance. */
			depth   = depthInc + linkLengths[ d ];
            breadth = _currentDrawing.getPrelim( v ) + m;
            
            if ( enableSiblingSpread ) {
                depth -= _currentDrawing.getDepthOffset( v );
            }
			 
			switch( orientation ) {
            case LayoutOrientation.TOP_DOWN:
                result = new Point( breadth, depth );
                break;
            case LayoutOrientation.BOTTOM_UP:
                result = new Point( breadth, - depth );
                break;
            case LayoutOrientation.LEFT_RIGHT:
                result = new Point( depth, breadth );
                break;
            case LayoutOrientation.RIGHT_LEFT:
                result = new Point( - depth, breadth );
                break; 
            }
            
            _currentDrawing.setCartCoordinates( v, result ); 
            
            /* recurse over the children */
            children = _stree.getChildren( v );
            for each( w in children ) {
                secondWalk( w, m + _currentDrawing.getModifier( v ), depth, d + 1 );
            }
        }
        
        
        /**
         * @internal
         * Create a new layout drawing object, which is required
         * on any root change (and possibly during other occasions)
         * and intialise various parameters of the drawing.
         * */
        private function initModel():void {		
            _currentDrawing = null;
            _currentDrawing = new HierarchicalLayoutDrawing();
            /* set in super class */
            super.currentDrawing = _currentDrawing;
            
            //_currentDrawing.originOffset = _vgraph.origin;
        }
        
        
        /**
         * @internal
         * Returns a calculated spacing, that can take node size
         * into account.
         * @param l The left node.
         * @param r The right node.
         * */
        private function spacing(l:INode, r:INode):Number {
            
            var result:Number;
            result = breadth;
            
            /* we assume that both INodes, l and r have a vnode and a view */
            if(honorNodeSize) {
                switch(orientation) {
                case LayoutOrientation.LEFT_RIGHT:
                case LayoutOrientation.RIGHT_LEFT:
                    result += 0.5 * (l.vnode.view.height + r.vnode.view.height);
                    break;
                case LayoutOrientation.TOP_DOWN:
                case LayoutOrientation.BOTTOM_UP:
                    result += 0.5 * (l.vnode.view.width + r.vnode.view.width);
                    break;
                default:
                    throw Error("Invalid orientation value found in internal variable");
                }
            }
            return result;
        }
        
		/**
		 * Расстояние между узлами по горизонтали или вертикали, в зависимости от компоновки 
		 */		
        private static const NODES_SPACING : Number = 10.0;
		
		/**
		 * Минимальное расстояние между узлами 
		 */		
		private static const MIN_LINK_LENGTH : Number = 200.0;
		
		/**
		 * Расстояние между узлами на каждом из уровней 
		 */		
		private var linkLengths : Vector.<Number>;
		
		/**
         * @internal
         * do autofitting the layer distance. The node distance cannot
         * be pre-computed, so we leave it alone.
         * */
        protected function calculateAutoFit() : void
		{    
            if ( autoFitEnabled )
			{
				if ( _stree.maxDepth == 0 )
				{
					return;
				}
				
				/*if ( fitToWindow )
				{
					linkLength = DEFAULT_LINK_LENGTH;
					initLinkLengths();
				}
				else
				{*/
					var maxBreadth : Number = 0;
					var node       : INode;
					var size       : Number;
					
					for each( node in _stree.nodes )
					{
						size       = ( orientation == LayoutOrientation.TOP_DOWN || orientation == LayoutOrientation.BOTTOM_UP ) ? size = node.vnode.view.width : node.vnode.view.height;
						maxBreadth = Math.max( maxBreadth, size );
					}
					
					breadth = Math.max( maxBreadth + NODES_SPACING, breadth );
					
					calcLinkLengths();
				//}
			}
			else
			{
				initLinkLengths();
			}
        }
		
		private function initLinkLengths() : void
		{
			linkLengths = new Vector.<Number>( _stree.maxDepth + 1 );
			
			for ( var i : int = 0; i < linkLengths.length; i ++ )
			{
				linkLengths[ i ] = ( i == 0 ) ? 0 : linkLength;
			}
		}
		
		private function calcLinkLengths() : void
		{
			linkLengths = new Vector.<Number>( _stree.maxDepth + 1 );
			var maxLinkLength : Number = 0.0; 
			
			for ( var i : int = 0; i < linkLengths.length; i ++ )
			{
				linkLengths[ i ] = ( i == 0 ) ? 0 : MIN_LINK_LENGTH + _stree.getNumberNodesWithDistance( i ) * 10;
				maxLinkLength    = Math.max( linkLengths[ i ], maxLinkLength );
				
				//trace( 'linkLength', i, linkLengths[ i ] );
			}
			
			linkLength = Math.min( maxLinkLength, linkLength );
		}
    }
}
