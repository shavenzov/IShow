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

	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IDataRenderer;
	import mx.utils.ObjectUtil;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IGTree;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	
	/**
	 * This is an base class to various layout implementations
	 * it does not really do any layouting but implements
	 * everything required by the Interface.
	 * */
	public class BaseLayouter extends EventDispatcher implements IDataRenderer, ILayoutAlgorithm {
		
		/**
		 * Все данные компоновщика, по которым его можно восстановить 
		 */		
		protected var _data : Object;
		
		/**
		 * The default minimum node height to be used if the exact node
		 * height cannot be determined yet.
		 * */
		public static const MINIMUM_NODE_HEIGHT:Number = 5;
		
		/**
		 * The default minimum node width to be used if the exact node
		 * height cannot be determined yet.
		 * */
		public static const MINIMUM_NODE_WIDTH:Number = 5;
		
		/**
		 * If set to true, animation is disabled and direct
		 * node location setting occurs (instantaneously).
		 * @default false
		 * */
		//protected var _disableAnimation:Boolean = false;
		
		/**
		 * All layouters need access to the VisualGraph.
		 * */
		protected var _vgraph:IVisualGraph = null;
		
		/**
		 * All layouters need access to the Graph.
		 * */
		//protected var _graph:IGraph = null;
		
		/**
		 * This keeps track if the layout has changed
		 * and can be accessed by any derived layouter.
		 * */
		protected var _layoutChanged:Boolean = false;

		/** 
		 * A spanning tree of the graph, since probably every layout 
		 * will work on a spanning tree, we keep this one in this
		 * base class.
		 * */
		protected var _stree:IGTree;

		/**
		 * The current root node of the layout.
		 * */
		//protected var _root:INode;
		
		/**
		 * The indicator if AutoFit should currently be used or not.
		 * */
		//protected var _autoFitEnabled:Boolean = false;

		/**
		 * this holds the data for a layout drawing.
		 * */
		private var _currentDrawing : ILayoutDrawing;
        
        /**
         * Отступ слева
         * */
         //private var _paddingLeft   : Number = 30;
		 /**
		  * Отступ справа 
		  */		 
		 //private var _paddingRight  : Number = 30;
		 /**
		  * Отступ сверху 
		  */		 
		 //private var _paddingTop    : Number = 30;
		 /**
		  * Отступ снизу 
		  */		 
		 //private var _paddingBottom : Number = 30;
        
         protected var _bounds:Rectangle;
		 
		 /**
		  * Область построения раскладки ( 0.0, 0.0, width, height ) 
		  * @return 
		  * 
		  */	
		 private var _boundingRect : Rectangle;
		 
		 /**
		  * Indicator if there is currently an animation in progress
		  * */
		 protected var _animInProgress:Boolean;
		 
		/**
		 * The constructor initializes the layouter and may assign
		 * already a VisualGraph object, but this can also be set later.
		 * @param vg The VisualGraph object on which this layouter should work on.
		 * */
		public function BaseLayouter( vg : IVisualGraph, data : Object = null )
		{	
			_vgraph = vg;
			//_graph  = vg.graph;
			
			_data = data ? data : new Object();
			
			//Для тех параметров, которые не указаны задаем значения, по умолчанию
			setDefaults();
		}
		
		protected function setDefaults() : void
		{
			if ( ! _data.hasOwnProperty( 'autoFitEnabled' ) )
			{
				_data.autoFitEnabled = true;
			}
			
			if ( ! _data.hasOwnProperty( 'fitToWindow' ) )
			{
				_data.fitToWindow = true;
			}
			
			if ( ! _data.hasOwnProperty( 'disableAnimation' ) )
			{
				_data.disableAnimation = false;
			}
			
			if ( ! _data.hasOwnProperty( 'paddingLeft' ) )
			{
				_data.paddingLeft = 16;
			}
			
			if ( ! _data.hasOwnProperty( 'paddingRight' ) )
			{
				_data.paddingRight = 16;
			}
			
			if ( ! _data.hasOwnProperty( 'paddingTop' ) )
			{
				_data.paddingTop = 16;
			}
			
			if ( ! _data.hasOwnProperty( 'paddingBottom' ) )
			{
				_data.paddingBottom = 16;
			}
			
			if ( ! _data.hasOwnProperty( 'rootId' ) )
			{
				_data.rootId = null;
			}
		}
		
		public function get data() : Object
		{
			return _data;
		}
		
		public function set data( value : Object ) : void
		{
			_data = value;
			dispatchEvent( new VisualGraphEvent( VisualGraphEvent.LAYOUT_DATA_CHANGED ) );
		}
		
		protected function sendChange() : void
		{
			dispatchEvent( new VisualGraphEvent( VisualGraphEvent.LAYOUT_PARAM_CHANGED ) );
		}
		
		public function get paddingLeft() : Number
		{
			return _data.paddingLeft;
		}
		
		public function set paddingLeft( value : Number ) : void
		{
			_data.paddingLeft = value;
			sendChange();
		}
		
		public function get paddingRight() : Number
		{
			return _data.paddingRight;
		}
		
		public function set paddingRight( value : Number ) : void
		{
			_data.paddingRight = value;
			sendChange();
		}
		
		public function get paddingTop() : Number
		{
			return _data.paddingTop;
		}
		
		public function set paddingTop( value : Number ) : void
		{
			_data.paddingTop = value;
			sendChange();
		}
		
		public function get paddingBottom() : Number
		{
			return _data.paddingBottom;
		}
		
		public function set paddingBottom( value : Number ) : void
		{
			_data.paddingBottom = value;
			sendChange();
		}
		
		public function get margin() : Number
		{
			return ( paddingLeft + paddingRight + paddingBottom + paddingTop ) / 4;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get root() : INode
		{
			return _data.rootId ? graph.nodeByStringId( _data.rootId ) : null;
		}
		
		public function set root( value : INode ) : void
		{
			_data.rootId = value.stringid;
			sendChange();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get boundingRect() : Rectangle
		{
			return _boundingRect;
		}
		
		public function set boundingRect( value : Rectangle ) : void
		{
			_boundingRect = value;
		}

		/**
		 * @inheritDoc
		 * */
		public function resetAll() : void
		{
			_layoutChanged = true;
			dispatchEvent( new VisualGraphEvent( VisualGraphEvent.RESET_ALL ) );
		}
        
        public function get vgraph() : IVisualGraph
		{ 
            return _vgraph;
        }
        
		/**
		 * @inheritDoc
		 * @throws An error if the vgraph was already set.
		 * */
		public function set vgraph(vg:IVisualGraph):void {
			if(_vgraph == null) {
				_vgraph = vg;
				//_graph = _vgraph.graph;
			} else {
				//LogUtil.warn(_LOG, "vgraph was already set in layouter");
			}
		}
		
		public function get graph() : IGraph
		{
			return _vgraph.graph;
		}
		
		/**
		 * @inheritDoc
		 * */	
		public function get layoutChanged():Boolean {
			return _layoutChanged;
		}
		
		/**
		 * @private
		 * */
		public function set layoutChanged(lc:Boolean):void {
			_layoutChanged = lc;
		}
		
		/**
		 * @inheritDoc
		 * */ 
		public function get autoFitEnabled():Boolean {
			return _data.autoFitEnabled;	
		}
		
		/**
		 * @private
		 * */
		public function set autoFitEnabled(af:Boolean):void {
			_data.autoFitEnabled = af;
			sendChange();
		}
		
		public function get fitToWindow() : Boolean
		{
			return _data.fitToWindow;
		}
		
		public function set fitToWindow( ftw : Boolean ) : void
		{
			_data.fitToWindow = ftw;
			sendChange();
		}

		/**
		 * This is a NOP in the BaseLayouter class. It does not set
		 * anything and always returns 0.
		 * 
		 * @inheritDoc
		 * */
		public function set linkLength(r:Number):void {
			/* NOP */
		}
		
		/**
		 * @private
		 * */
		public function get linkLength():Number {
			/* NOP
			 * but must not return 0, since some layouter
			 * do not care about LL, but the vgraph will
			 * not draw if LL is 0
			 * so default is something else, like 1
			 */
			return 1;
		}

		/**
		 * @inheritDoc
		 * */
		public function get animInProgress() : Boolean
		{
			return _animInProgress;
		}
		
		public function set animInProgress( value : Boolean ) : void
		{
			_animInProgress = value;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function set disableAnimation( d : Boolean ) : void
		{
			_data.disableAnimation = d;
			sendChange();
		}
		
		/**
		 * @private
		 * */
		public function get disableAnimation() : Boolean
		{
			return _data.disableAnimation;
		}
		
		/**
		 * This always returns true, dispatches the graph updated event.
		 * 
		 * @inheritDoc
		 * */
		public function layoutPass() : void
		{
		  calculate();
		  commit();
		}
		
		public function calculate() : void
		{
			calcFitToWindow( actualNodes );
			calculateFullBounds( actualNodes );
			dispatchEvent( new VisualGraphEvent( VisualGraphEvent.LAYOUT_CALCULATED ) );
		}
		
		public function commit() : void
		{
			
		}
        
		public function calculateBounds( nodes : * ) : Rectangle
        {
            var retVal : Rectangle;
			var p      : Point;
			var right  : Number;
			var bottom : Number;
			var bounds : Rectangle;
			
			for each( var node : INode in nodes )
            {
				p      = _currentDrawing.nodeCartCoordinates[ node ];
				
				//Если координат для указааного узла не найдено, то игнорируем его
				if ( ! p )
				{
					continue;
				}
				
				bounds = node.vnode.view.getBounds( node.vnode.view.parent );
				
				p = p.clone();
				p.offset( - node.vnode.rendererView.visualWidth / 2.0, - node.vnode.rendererView.visualHeight / 2.0 );
				
				right  = p.x + bounds.width;
				bottom = p.y + bounds.height;
				
				if ( retVal )
				{
					retVal.left   = Math.min( retVal.left, p.x );
					retVal.right  = Math.max( retVal.right, right );
					retVal.top    = Math.min( retVal.top, p.y )
					retVal.bottom = Math.max( retVal.bottom, bottom );
				}
				else
				{
					retVal = new Rectangle( p.x, p.y, Math.max( MINIMUM_NODE_WIDTH, bounds.width ), Math.max( MINIMUM_NODE_HEIGHT, bounds.height ) );
				}
            }
			
            return retVal;
        }
		
		/**
		 * Если граф состоит из нескольких сетей, то по возможности применяем компоновку
		 * к узлам с учетом их текущего положения 
		 * 
		 */		
		/*private function correctNodesGroupPos() : void
		{
			//Если граф состоит из нескольких параллельных сетей, то задаем смещение для выбранной сети
			var groups : Vector.<Dictionary> = _graph.getNodesGroups();
			
			if ( groups.length > 1 )
			{
				var nodes : * = _stree ? _stree.nodes : _graph.nodes;
				var from : Rectangle = _vgraph.getNodesGroupBoundsV( nodes );
				
				//Если прямоугольная область сети слишком маленькая, то ничего не делаем
				if ( ( from.width <= MINIMUM_NODE_WIDTH ) || ( from.height <= MINIMUM_NODE_HEIGHT ) )
				{
					return;
				}
				
				var to   : Rectangle = calculateBounds( nodes );
				var pos  : Point;
				
				for each( var node : INode in nodes )
				{
					pos    = _currentDrawing.getRelCartCoordinates( node );
					pos.x += from.x - to.x;
					pos.y += from.y - to.y;
					
					_currentDrawing.setCartCoordinates( node, pos );  
				}
			}
		}*/
		
		/**
		 * Вычисляет размер области визуального графа с учетом отступов 
		 * устанавливает точку смещения, так что-бы координаты всех узлов были положительными
		 * для предотвращения "ухода" узлов за границы экрана
		 */		
		protected function calculateFullBounds( nodes : * ) : void
		{
			var rect       : Rectangle = calculateBounds( nodes );
			
			//Если координаты по оси x или у, имеют не нулево значение, то необходимо сдвинуть граф, в положение (0,0)
			var offset     : Point     = new Point( - rect.left, - rect.top );
			
			//Размещаем граф в центре boundingRect
			if ( autoFitEnabled && fitToWindow && _boundingRect )
			{
				var newRect : Rectangle = rect.clone();
				
				if ( offset.length > 0.0 )
				{
					newRect.offsetPoint( offset );	
				}
				
				offset = offset.add( fitTheMiddleRectangleToRectangle( newRect, _boundingRect ) );
			}
			
			//Устанавливаем новое значение точки смещения
			if ( offset.length > 0.0 )
			{
				_currentDrawing.offset( offset );
				rect.offsetPoint( offset );
			}
			
			/*
			var g : Graphics = UIComponent( UIComponent( vgraph ).getChildAt( 0 ) ).graphics;
			    g.lineStyle( 1.0, 0x00ff00 );
				g.drawRect( rect.x, rect.y, rect.width, rect.height );
				
				if ( _boundingRect )
				{
					g.lineStyle( 2.0, 0x0000ff );
					g.drawRect( _boundingRect.x, _boundingRect.y, _boundingRect.width, _boundingRect.height ); 	
				}	
			*/
			
			_bounds = rect;
		}
		
		/**
		 * Возвращает смещение координат по осям x и y, которое необходимо применить для того-чтобы вписать rect в bounds  
		 * @param rect   - прямоугольник который необходимо вписать в bounds
		 * @param bounds - прямоугольник в который необходимо вписать rect
		 * @param onlyIfFitToBounds - определяет как обрабатывать случай если какая либо из сторон вписываемого прямоугольника rect не влезает в bounds 
		 * @return - смещение координат по осям x и y, которое необходимо применить для того-чтобы вписать rect в bounds
		 * 
		 */		
		protected function fitTheMiddleRectangleToRectangle( rect : Rectangle, bounds : Rectangle, onlyIfFitToBounds : Boolean = false ) : Point
		{
			var offset : Point = new Point();
			
			if ( ! onlyIfFitToBounds || ( rect.width < bounds.width ) )
			{
				offset.x = ( bounds.x + ( bounds.width - rect.width ) / 2.0 ) - rect.x;
		    }
			
			if ( ! onlyIfFitToBounds || ( rect.height < bounds.height ) )
			{
				offset.y = ( bounds.y + ( bounds.height - rect.height ) / 2.0 ) - rect.y;
			}
			
			/*if ( offset.x < 0 || offset.y < 0 )
			{
				trace( 'incorectOffset', offset );
			}*/
			
			return offset;
		}
		
        public function get bounds():Rectangle
        {
            if ( _bounds )
			{
				return _bounds;
			}
                
            calculateFullBounds( actualNodes );
            
            return _bounds;
        }
		
		protected function get actualNodes() : *
		{
			return _stree ? _stree.nodes : graph.nodes;
		}
        
		/**
		 * This is a NOP for this layouter.
		 * @inheritDoc
		 * */
		//public function refreshInit():void {
			/* NOP */
		//}
		
		/**
		 * Allow to set the reference to the drawing object from
		 * derived classes. This is important because of the 
		 * type issue, the _currentDrawing variable will be declared
		 * separately in each derived layouter, but this one must
		 * have access to it anyway, to do the animation
		 * @param dr The drawing object that needs to be assigned.
		 * */
		protected function set currentDrawing( dr  : ILayoutDrawing ) : void
		{
			_currentDrawing = dr;
		}
		
		protected function get currentDrawing() : ILayoutDrawing
		{
			return _currentDrawing;
		}
		
		/**
		 * Sets the current absolute target coordinates of a node
		 * in the node's vnode. This does not yet move the node,
		 * as for this the vnode's commit() method must be called.
		 * @param n The node to get its target coordinates updated.
		 * */ 
		protected function applyTargetCoordinates(n:INode):void {
			
			var coords:Point;
			/* add the points coordinates to its origin */		
			coords = _currentDrawing.getAbsCartCoordinates(n);
		
			n.vnode.x = coords.x;
			n.vnode.y = coords.y;
		}
		
		/**
		 * Applies the target coordinates to all nodes that
		 * are in the Dictionary object passed as argument.
		 * The items are expected to be VNodes (as typically
		 * a list of currently visible VNodes is passed).
		 * */ 
		protected function applyTargetToNodes( nodes : * ):void {
			var n : INode;
			
			for each( n in  nodes )
			{			
				applyTargetCoordinates( n );
				n.vnode.commit();
			}			
		}
		
		/**
		 * Масштабирует предварительно расчитанные координаты узлов, так что-бы они умещались на экране ( без полос прокрутки )
		 * 
		 */		
		protected function calcFitToWindow( nodes : *, calculatedBounds : Rectangle = null ) : void
		{
			if ( autoFitEnabled && fitToWindow && _boundingRect )
			{
				var bounds : Rectangle = calculatedBounds ? calculatedBounds : calculateBounds( nodes );
					
				var scaleX : Number    = _boundingRect.width  / bounds.width;      
				var scaleY : Number    = _boundingRect.height / bounds.height;
				var scale  : Number    = Math.min( scaleX, scaleY );
				
				if ( scale < 0.99 )
				{
					_currentDrawing.scale( scale );
					
					//Вычисляем обрамляющую область повторно
					var afterBounds : Rectangle = calculateBounds( nodes );
					
					//Если граф все ещё не вписан в прямоугольную область, то вычисляем повторно, до тех пор пока граф не будет окончательно вписан
					if ( ( afterBounds.width > _boundingRect.width ) ||
						 ( afterBounds.height > boundingRect.height )
						)
					{
						calcFitToWindow( nodes, afterBounds );
					}
				}
			}
		}
		
		public function get layoutDrawing() : ILayoutDrawing
		{
			return _currentDrawing;
		}
		
		public function get needRoot() : Boolean
		{
			return true; 
		}
		
		public function clone() : ILayoutAlgorithm
		{
			var c : Class = Class( getDefinitionByName( getQualifiedClassName( this ) ) );
			
			return new c( _vgraph, ObjectUtil.clone( _data ) );
		}
	}
}
