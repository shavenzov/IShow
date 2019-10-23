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
	import flash.geom.Rectangle;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.utils.Geometry;
	
	/**
	 * This is an implementation of the 
	 * parent centered radial layouter
	 * as described in the 2006 paper by
	 * Andy Pavlo, Christopher Homan and Jon Schull. It is not
	 * yet working perfectly. 
	 * */
	public class ParentCenteredRadialLayouter
		extends BaseLayouter
		implements IAngularLayouter {
		
		public static const ID : String = 'ParentCenteredRadialLayouter';
		
		/* this holds the data for the ParentCentered layout drawing */
		private var _currentDrawing : ParentCenteredDrawingModel;
		/**
		 * The constructor only initialises some data structures.
		 * @inheritDoc
		 * */
		public function ParentCenteredRadialLayouter( vg : IVisualGraph, data : Object = null ) 
		{
			super( vg, data );
			//animationType = ANIM_STRAIGHT; // inherited
			initModel();
		}
		
		override protected function setDefaults() : void
		{
			super.setDefaults();
			
			_data.type = ID;
			
			if ( ! _data.hasOwnProperty( 'phi' ) )
			{
				_data.phi = 360;
			}
			
			if ( ! _data.hasOwnProperty( 'rootR' ) )
			{
				_data.rootR = 10;
			}
		}

		/**
		 * @inheritDoc
		 * */
		override public function resetAll():void {			
			
			super.resetAll();
			
			_stree = null;
			graph.purgeTrees();
			initModel();
		}

		override public function calculate() : void
		{
			_stree = graph.getTree( root, true, false );
			
			initModel();
			
			calculateOptimalLinkLengths();
			
			processNode( root );
			
			super.calculate();
		}
	
		public function get rootR() : Number
		{
			return Number( _data.rootR );
		}
		
		public function set rootR( value : Number ) : void
		{
			_data.rootR = value;
			sendChange();
		}
		
		/**
		 * @inheritDoc
		 * */
		override public function get linkLength():Number {
			return rootR/* * 5*/;
		}
		/**
		 * @private
		 * */
		override public function set linkLength(rr:Number):void {
			rootR = rr/* * 5*/;
			sendChange();
		}
		
		/**
		 * Access to the preset of the starting angle of the layout
		 * */
		public function get phi():Number {
			return Number( _data.phi );
		}
		/**
		 * @private
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
		private function initModel():void {		
			_currentDrawing = null;
			_currentDrawing = new ParentCenteredDrawingModel();
			
			/* set in super class */
			super.currentDrawing = _currentDrawing;
			
			_currentDrawing.originOffset = _vgraph.origin;
			_currentDrawing.centerOffset = _vgraph.center;
			_currentDrawing.centeredLayout = true;
		
		}
		
		/**
		 * Вектор перпендикулярный оси ox 
		 */		
		private static const vx    : Point = new Point( 1.0, 0.0 );
		
		/**
		 * @internal
		 * calculate the coordinates of a node, Requires all nodes in the
		 * parental level to be calculated.
		 * @param vi The current node to inspect v_i
		 * @param i the child index of the current node (beware this starts with 0)
		 * @param m the number of all children of the node's parent
		 * */
		private function processNode( node : INode ) : void
		{
			var numChildren : int    = _stree.getNoChildren( node );
			
			//У узла нету детей
			if ( numChildren == 0 )
			{
				return;
			}
			
			var parentNode  : INode  = _stree.parents[ node ];
			var depth       : int    = _stree.getDistance( node );
			var radius      : Number = _currentDrawing.linkLengths[ depth ];
			var pos         : Point  = _currentDrawing.getRelCartCoordinates( node );
			
			//Корневой элемент
			if ( pos == null )
			{
				pos = new Point();
				_currentDrawing.setNodeCoordinates( node, pos, 0.0, 0.0, 0.0 );
			}
			
			var lAngle    : Number = 0.0;
			var rAngle    : Number = 0.0;
			 
			var angle     : Number = 0.0;
			var offset    : Number = 0.0;
			var child     : INode;
			var nextChild : INode;
			var i         : int;
			var angW      : Number = 0.0;
			//var hasSubChildren : Boolean = nodeHasSubChildren( node );
			
			if ( parentNode /*&& ( hasSubChildren || numChildren < 3 )*/ )
			{
				var parentPos  : Point = _currentDrawing.getRelCartCoordinates( parentNode );
				
				//Вектор перпендикулярный вектору от точки from к точке to
				var v           : Point = Geometry.segmentNormal( parentPos, pos ); 
				
				offset = Geometry.angleBetweenVectors( v, vx ) + Math.PI / 2.0;
				
				var even : Boolean = true;
				
				for ( i = 0; i < numChildren; i ++ )
				{
					child     = _stree.getIthChildPerNode( node, i );
					nextChild = getNextChild( node, i );
					
					_currentDrawing.setNodeCoordinates( child, pos, Geometry.rad2deg( offset ), radius, Geometry.rad2deg( angle ) );
					
					angW = angularWidthBetweenTwoChildren( node, child, nextChild );
					
					//trace( 'angle between ', child.data.name, nextChild ? nextChild.data.name : 'null', angW );
					
					//Распологаем первый узел
					if ( i == 0 )
					{
						lAngle = rAngle = angW;
					}
					else
					{
						if ( even )
						{
							lAngle += angW;
						}
						else
						{
							rAngle += angW;
						}
					}
					
					even   = ! even;
					
					if ( even )
					{
						angle = lAngle;	
					}
					else
					{
						angle = - rAngle;
					}
					
					processNode( child );
				}
			}
			else
			{
				var step   : Number = 2 * Math.PI / numChildren;
				
				for ( i = 0; i < numChildren; i ++ )
				{
					child = _stree.getIthChildPerNode( node, i );
					
					_currentDrawing.setNodeCoordinates( child, pos, Geometry.rad2deg( offset ), radius, Geometry.rad2deg( lAngle ) );
					
					lAngle += step;
					
					processNode( child );
				}
			}
			
			//if ( parentNode != null )
			//{
				
				
				/*
				if ( numChildren > 1 )
				{				  
				  for ( i = 0; i < numChildren; i ++ )
				  {
					  angW += calculateAngularWidth( _stree.getIthChildPerNode( node, i ) );  
				  }
				  
				  if ( offset < 2 * Math.PI )
				  {
					  offset -= angW / 2.0;  
				  }
				}
				*/
			/*}
			else
			{
				
			}*/
		}
		
		private function angularWidthBetweenTwoChildren( parent : INode, child1 : INode, child2 : INode ) : Number
		{
			var angularWidth1 : Number = child1 ? calculateAngularWidth( parent, child1 ) : 0.0; 
			var angularWidth2 : Number = child2 ? calculateAngularWidth( parent, child2 ) : 0.0;
			
			return ( angularWidth1 + angularWidth2 ) / 3.0;
		}
		
		/*
		private function numberIsOdd( number : int ) : Boolean
		{
			return number % 2 == 0 ? false : true; 
		}
		*/
		
		private function getNextChild( parent : INode, index : int ) : INode
		{
			var nextIndex : int = index == 0 ? index + 1 : index + 2;
			
			if ( nextIndex < _stree.getNoChildren( parent ) )
			{
				return _stree.getIthChildPerNode( parent, nextIndex );
			}
			
			return null;
		}
		
		private function nodeHasSubChildren( node : INode ) : Boolean
		{
			var children : Vector.<INode> = _stree.getChildren( node );
			var child    : INode;
			
			if ( children )
			{
				for each( child in children )
				{
					if ( _stree.getNoChildren( child ) > 0 )
					{
						return true;
					}
				}
			}
			
			return false;
		}
		
		/*
		Первый проход определяем оптимальный LinkLength для каждого уровня
		*/
		private function calculateOptimalLinkLengths() : void
		{
			_currentDrawing.initLinkLengths( _stree.maxDepth + 1 );
			
			var i             : int;
			var newLinkLength : Number;
			
			if ( autoFitEnabled )
			{
				calculateLinkLength( root );
				
				_currentDrawing.linkLengths.sort();
				
				newLinkLength = 0.0;
				
				for ( i  = _currentDrawing.linkLengths.length - 1; i >= 0; i -- )
				{
					newLinkLength                    += _currentDrawing.linkLengths[ i ];
					_currentDrawing.linkLengths[ i ]  = newLinkLength;
					
					//trace( 'll', i, _currentDrawing.linkLengths[ i ] );
				}
			}
			else
			{
			  	newLinkLength = rootR;
				
				for ( i = _currentDrawing.linkLengths.length - 1; i >= 0; i -- )
				{
					_currentDrawing.linkLengths[ i ]  = newLinkLength;
					newLinkLength += rootR;
					
					//trace( 'll', i, _currentDrawing.linkLengths[ i ] );
				}
			}
		}
		
		/**
		 * Минимальная рекомендуемая длина связей между объектами 
		 */		
		private var MIN_LINK_LENGTH : Number = 150.0;
		
		private function calculateLinkLength( node : INode ) : void
		{
			var children : Vector.<INode> = _stree.getChildren( node );
			
			if ( children )
			{
				var child          : INode;
				var distance       : int       = _stree.getDistance( node );
				var length         : Number    = getNodesLength( children );
				var lastLinkLength : Number    = _currentDrawing.linkLengths[ distance ];
				var diameter       : Number    = length / Math.PI; 
				
				_currentDrawing.linkLengths[ distance ] = Math.max( MIN_LINK_LENGTH, lastLinkLength, diameter );
				
				for each( child in children )
				{
					calculateLinkLength( child );
				}
			}
		}
		
		/**
		 * Вычисляет общий размер нескольких узлов 
		 * @param nodes список узлов
		 * @return общий размер нескольких узлов
		 * 
		 */		
		private function getNodesLength( nodes : Vector.<INode>, calcSubChildren : Boolean = false ) : Number
		{
			var bounds   : Rectangle;
			var result   : Number = 0.0;
			var node     : INode;
			var children : Vector.<INode>;
			
			for each( node in nodes )
			{
				bounds  = node.vnode.view.getBounds( node.vnode.view.parent );
				result += Math.sqrt( bounds.width * bounds.width + bounds.height * bounds.height ) + 16.0; //+16.0 добавляется для предотвращения неточного определения размера узла
				
				if ( calcSubChildren )
				{
					children = _stree.getChildren( node );
					
					if ( children )
					{
						result += getNodesLength( children, true );
					}
				}
			}
			
			return result;
		}
		
		/*
		Второй проход определяем angularWidth детей каждого родителя
		*/
		private function calculateAngularWidth( parent : INode, child : INode, size : Number = 0.0 ) : Number
		{
			var children : Vector.<INode> = _stree.getChildren( child );
			var depth    : int            = _stree.getDistance( parent );
			var ll       : Number         = _currentDrawing.linkLengths[ depth ] /*/ 2.0*/;
			var length   : Number;  
			var diameter : Number;
            
			/*
			if ( child.data.name == '968 5932204 ' )
			{
				trace( 'i catch it!!' );
			}
			*/
			
			if ( children )
			{
				length   = getNodesLength( children, true );
				
				diameter = length / Math.PI;
				
				size   = LayouterUtils.getAngularWidth2( diameter, diameter, ll );
			}
			else
			{
				size = LayouterUtils.getAngularWidth( child, ll );
			}
			
			return size;
		}
	}
}
