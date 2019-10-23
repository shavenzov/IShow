package org.un.cava.birdeye.ravis.components.navigator
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;
	import mx.events.ResizeEvent;
	import mx.utils.ObjectUtil;
	
	import spark.core.IViewport;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	
	public class Navigator extends UIComponent
	{
		private static const NONE          : int = 0;
		private static const MOVE          : int = 20;
		/*
		private static const RESIZE_RIGHT  : int = 30;
		private static const RESIZE_LEFT   : int = 40;
		private static const RESIZE_TOP    : int = 50;
		private static const RESIZE_BOTTOM : int = 60;*/
		
		/**
		 * Текущее выполняемое действие 
		 */		
		private var _currentAction : int = NONE;
		
		/**
		 * Смещение относительно компонента во время перетаскивания 
		 */		
		private var _dragOffset : Point;
		
		/**
		 * Цвет узла отображаемый в наигаторе по умолчанию 
		 */		
		private static const DEFAULT_NODE_COLOR : uint = 0x00ff00;
		
		/**
		 * Цвет заднего фона 
		 */		
		private static const VISIBLE_AREA_COLOR : uint = 0xffffff;
		
		/**
		 * Цвет затемнения невидимой в данный момент области 
		 */		
		private static const INVISIBLE_AREA_COLOR : uint = 0xCCCCCC;
		
		/**
		 * Размер узла 
		 */		
		private static const NODE_SIZE : Number = 4.0;
		
		private var _vg : IVisualGraph
		private var _viewport : IViewport;
		
		private var _thumb : Thumb;
		/**
		 * Индикатор перемещения тамба 
		 */		
		private var _dragging : Boolean;
		/**
		 * Событие инициировавшее перетаскивание 
		 */		
		private var _actionInitiatorEvent : MouseEvent;
		
		/**
		 * Смещение инициирующее процесс перетаскивания
		 */
		private static const START_MOUSE_ACTION_OFFSET : Number = 2.0;
		
		/**
		 * Слой для отрисовки графа 
		 */		
		private var _graphLayer : Shape;
		
		public function Navigator()
		{
			super();
		}
		
		override protected function createChildren() : void
		{
			super.createChildren();
			
			_graphLayer = new Shape();
			
			_thumb       = new Thumb();
			_thumb.addEventListener( MouseEvent.MOUSE_DOWN, onThumbMouseDown );
		
			addChild( _graphLayer );
			addChild( _thumb );
			
			addEventListener( MouseEvent.MOUSE_UP, onNavigatorMouseUp, false, 1000 );
		}
		
		private function onNavigatorMouseUp( e : MouseEvent ) : void
		{
			if ( _dragging )
			{
				return;
			}
			
			var pos      : Point = globalToLocal( new Point( e.stageX, e.stageY ) );
			    pos.x -= _thumb.width / 2.0;
				pos.y -= _thumb.height / 2.0;
				
				pos = correctPos( pos );
				
			var graphPos : Point = navigatorPosToGraphPos( pos );
			
			setGraphPos( graphPos );
			invalidateDisplayList();
		}
		
		private function onThumbMouseDown( e : MouseEvent ) : void
		{
			/*switch( e.target )
			{
				//Перемещение окна
				case _thumb : _currentAction = MOVE;
					break;
					
				//Изменение размера влево
				case _thumb.leftResizer : _currentAction = RESIZE_LEFT;
					break;
					
				//Изменение размера вправо
				case _thumb.rightResizer : _currentAction = RESIZE_RIGHT;
				    break;
					
				//Изменение размера вверх	
				case _thumb.topResizer : _currentAction = RESIZE_TOP;
				   break;
					
				//Изменение размера вниз	
				case _thumb.bottomResizer : _currentAction = RESIZE_BOTTOM;
					break;
			}*/
			_currentAction = MOVE;
			
			_actionInitiatorEvent = e;
			_dragOffset = _thumb.globalToLocal( new Point( e.stageX, e.stageY ) );
			
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onThumbMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_UP, onThumbMouseUp );
		}
		
		private function correctPos( pos : Point ) : Point
		{
			if ( pos.x < 0.0 )
			{
				pos.x = 0.0;
			}
			else if ( pos.x > width )
			{	
				pos.x = width;
			}
			
			if ( pos.y < 0.0 )
			{
				pos.y = 0.0;
			}
			else if ( pos.y > height )
			{
				pos.y = height;
			}
			
			return pos;
		}
		
		private function onThumbMouseMove( e : MouseEvent ) : void
		{
			if ( _dragging )
			{
				var pos : Point = globalToLocal( new Point( e.stageX, e.stageY ) );
				
				if ( _currentAction == MOVE )
				{
					pos.offset( - _dragOffset.x, - _dragOffset.y );
				}
				
				pos = correctPos( pos );
				
				moveHandler( pos );
				
				/*switch( _currentAction )
				{
					case MOVE : moveHandler( pos );
						break;
					
					case RESIZE_LEFT : resizeLeftHandler( pos );
						break;
					
					case RESIZE_RIGHT : resizeRightHandler( pos );
						break;
					
					case RESIZE_TOP : resizeTopHandler( pos );
						break;
					
					case RESIZE_BOTTOM : resizeBottomHandler( pos );
						break;
				}*/
			}
			else
			{
				if ( ( Math.abs( _actionInitiatorEvent.stageX - e.stageX ) > START_MOUSE_ACTION_OFFSET ) ||
					( Math.abs( _actionInitiatorEvent.stageY - e.stageY ) > START_MOUSE_ACTION_OFFSET )
				)
				{
					_dragging = true;
					_actionInitiatorEvent = null;
				}
			}
		}
		
		private function onThumbMouseUp( e : MouseEvent ) : void
		{
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onThumbMouseMove );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onThumbMouseUp );
			
			_dragging      = false;
			_dragOffset    = null;
			_currentAction = NONE;
		}
		
		private function moveHandler( pos : Point ) : void
		{
			if ( ( pos.x + _thumb.width ) > width )
			{
				pos.x = width - _thumb.width;
			}
			
			if ( ( pos.y + _thumb.height ) > height )
			{
				pos.y = height - _thumb.height;
			}	
			
			var graphPos : Point = navigatorPosToGraphPos( pos );
			
			setGraphPos( graphPos );
			
			invalidateDisplayList();
		}
		
		/*private function resizeLeftHandler( pos : Point ) : void
		{
			
		}*/
		
		/*
		private function resizeRightHandler( pos : Point ) : void
		{
			var samplesPerWindow : Number = _vg.width * _vg.scale;
			
			var offset          : Number = pos.x - ( _thumb.x + _thumb.width );
			var offsetInSamples : Number = samplesPerWindow + ( ( offset * _vGraphWidth ) / width );
			var newScale        : Number = ( offsetInSamples / samplesPerWindow ) * _vg.scale; 
			
			var graphOffset : Number = navigatorPosToGraphPos( new Point( offset, 0.0 ) ).x;
			
			trace( 'scale', newScale );
			
			
				_vg.scale = newScale;
				
				_vg.validateNow();
				invalidateDisplayList();
				validateDisplayList();
		
			
			
			
			invalidateDisplayList();
		}
		
		private function resizeTopHandler( pos : Point ) : void
		{
			
		}
		
		private function resizeBottomHandler( pos : Point ) : void
		{
			
		}
		*/
		
		private function setGraphPos( pos : Point ) : void
		{
			_viewport.horizontalScrollPosition = pos.x;
			_viewport.verticalScrollPosition   = pos.y;
		}
		
		public function get vg() : IVisualGraph
		{
			return _vg;
		}
		
		public function set vg( value : IVisualGraph ) : void
		{
			if ( _vg != value )
			{
				if ( _vg ) 
				{
					_vg.removeEventListener( VisualGraphEvent.NODES_UPDATED, onGraphLayoutUpdated );
					_vg.removeEventListener( VisualGraphEvent.SCALED, onGraphLayoutUpdated );
					_vg.removeEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onVGPropertyChanged );
					_vg.removeEventListener( ResizeEvent.RESIZE, onVGPropertyChanged );
				}
				
				_vg = value;
				
				if ( _vg )
				{
					_viewport = IViewport( _vg );
					_vg.addEventListener( VisualGraphEvent.NODES_UPDATED, onGraphLayoutUpdated );
					_vg.addEventListener( VisualGraphEvent.SCALED, onGraphLayoutUpdated );
					_vg.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onVGPropertyChanged );
					_vg.addEventListener( ResizeEvent.RESIZE, onVGPropertyChanged );
				}
				
				invalidateDisplayList();
			}
		}
		
		private function onVGPropertyChanged( e : Event ) : void
		{
			invalidateDisplayList();
		}
		
		private function onGraphLayoutUpdated( e : Event ) : void
		{
			_needRedraw = true;
			invalidateDisplayList();
		}
		
		override protected function measure():void
		{
			super.measure();
			
			measuredWidth  = 250;
			measuredHeight = 250;
		}
		
		private var _vGraphWidth  : Number;
		private var _vGraphHeight : Number;
		private var _needRedraw   : Boolean = true;
		
		override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if ( ! _vg )
			{
				return;
			}
			
			_vGraphWidth  = Math.max( _viewport.width, _viewport.contentWidth );
			_vGraphHeight = Math.max( _viewport.height, _viewport.contentHeight );
			
			var pos  : Point = graphPosToNavigatorPos( new Point( _viewport.horizontalScrollPosition, _viewport.verticalScrollPosition ) );
			var size : Point = graphPosToNavigatorPos( new Point( _viewport.width, _viewport.height ) );
			
			_thumb.move( pos.x, pos.y );
			_thumb.setActualSize( size.x, size.y );
			
			redrawBackground( pos.x, pos.y, size.x, size.y );
			
			if ( _needRedraw )
			{
				_graphLayer.graphics.clear();
				redrawEdges();
				redrawNodes();
				
				_needRedraw = false;
			}
		}
		
		private function graphPosToNavigatorPos( pos : Point, scale : Number = 1.0 ) : Point
		{
			return new Point( ( pos.x * scale * width ) /  _vGraphWidth, ( pos.y * scale * height ) /  _vGraphHeight );
		}
		
		private function navigatorPosToGraphPos( pos : Point, scale : Number = 1.0 ) : Point
		{
			return new Point( ( ( _vGraphWidth * pos.x ) / width ) * scale, ( ( _vGraphHeight * pos.y ) / height ) * scale );
		}
		
		/**
		 * Перерисовка заднего фона и видимой области 
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 * 
		 */		
		private function redrawBackground( x : Number, y : Number, w : Number, h : Number ) : void
		{
			graphics.clear();
			
			//Невидимая область
 			graphics.beginFill( INVISIBLE_AREA_COLOR );
			graphics.drawRect( 0.0, 0.0, width, height );
			graphics.endFill();
			
			//Видимая область
			graphics.beginFill( VISIBLE_AREA_COLOR );
			graphics.drawRect( x, y, w, h );
			graphics.endFill();
		}
		
		/**
		 * Перерисовывает вся связи 
		 * 
		 */		
		private function redrawEdges() : void
		{
			var ve    : IVisualEdge;
			var color : uint;
			var pos1  : Point;
			var pos2  : Point;
			var g     : Graphics = _graphLayer.graphics;
			
			//trace( 'Navigator numEdges', ObjectUtil.numDictionaryElements( _vg.vedges ) );
			
			for each( ve in _vg.vedges )
			{
				color = ve.lineStyle.color;
				
				pos1 = graphPosToNavigatorPos( ve.edge.node1.vnode.viewCenter, _vg.scale );
				pos2 = graphPosToNavigatorPos( ve.edge.node2.vnode.viewCenter, _vg.scale );
				
				g.lineStyle( 1.0, color, 0.5 );
				g.moveTo( pos1.x, pos1.y );
				g.lineTo( pos2.x, pos2.y );
			}
		}
		
		/**
		 * Перерисовывает все узлы 
		 * 
		 */		
		private function redrawNodes() : void
		{
			var vn    : IVisualNode;
			var color : uint;
			var pos   : Point;
			var g     : Graphics = _graphLayer.graphics;
			
			graphics.lineStyle();
			
			//trace( 'Navigator numNodes', ObjectUtil.numDictionaryElements( _vg.vnodes ) );
			
			for each( vn in _vg.vnodes )
			{
				color = DEFAULT_NODE_COLOR;
				
				if ( vn.data )
				{
					if ( vn.data.color )
					{
						color = vn.data.color;
					}
				}
				
				g.beginFill( color );
				
				pos = graphPosToNavigatorPos( vn.viewCenter, _vg.scale );
				
				g.drawCircle( pos.x, pos.y, NODE_SIZE );
				
				g.endFill();
			}
		}
	}
}