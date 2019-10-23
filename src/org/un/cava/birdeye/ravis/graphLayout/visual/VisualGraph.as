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
package org.un.cava.birdeye.ravis.graphLayout.visual {
	
	import com.bs.amg.UnisAPI;
	import com.bs.amg.features.IShowFeatures;
	import com.data.SavedUIComponent;
	import com.managers.PopUpManager;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.controls.Menu;
	import mx.core.ClassFactory;
	import mx.core.IDataRenderer;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.effects.Effect;
	import mx.events.EffectEvent;
	import mx.events.MenuEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.ResizeEvent;
	import mx.managers.CursorManager;
	import mx.managers.history.History;
	import mx.utils.ObjectUtil;
	
	import spark.core.IViewport;
	
	import org.un.cava.birdeye.ravis.assets.Assets;
	import org.un.cava.birdeye.ravis.components.renderers.edgeLabels.IEdgeLabelRenderer;
	import org.un.cava.birdeye.ravis.components.renderers.edgeLabels.TextEdgeLabelRenderer;
	import org.un.cava.birdeye.ravis.components.renderers.nodes.INodeRenderer;
	import org.un.cava.birdeye.ravis.components.renderers.nodes.TextIconNodeRenderer;
	import org.un.cava.birdeye.ravis.containers.Container;
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGTree;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ComplexLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ConcentricRadialLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.IAsynchronousLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
	import org.un.cava.birdeye.ravis.graphLayout.layout.LayouterFactory;
	import org.un.cava.birdeye.ravis.graphLayout.visual.animation.EdgesDirectionAnimator;
	import org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers.ArrowStyle;
	import org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers.BaseEdgeRenderer;
	import org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers.DirectedArrowEdgeRenderer;
	import org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers.DirectedCurveEdgeRenderer;
	import org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers.EdgeOrientation;
	import org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers.IEdgeRenderer;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualEdgeEvent;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphCreateEdgeEvent;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphRemoveObjectEvent;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualNodeEvent;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualSelectionChangedEvent;
	import org.un.cava.birdeye.ravis.graphLayout.visual.menu.VisualGraphMenu;
	import org.un.cava.birdeye.ravis.graphLayout.visual.operation.VisualGraphMode;
	import org.un.cava.birdeye.ravis.history.ChangeRootNode;
	import org.un.cava.birdeye.ravis.history.CreateEdge;
	import org.un.cava.birdeye.ravis.history.LayoutParamsChanged;
	import org.un.cava.birdeye.ravis.history.MoveNodes;
	import org.un.cava.birdeye.ravis.history.RemoveEdge;
	import org.un.cava.birdeye.ravis.history.RemoveSelectedObjects;
	import org.un.cava.birdeye.ravis.utils.Geometry;
	import org.un.cava.birdeye.ravis.utils.HitTestUtils;
	import org.un.cava.birdeye.ravis.utils.ui.ScrollTracer;
	import org.un.cava.birdeye.ravis.utils.ui.VisualGrid;
	
	/**
	 * Заливать ли задний фон 
	 */	
	[Style(name="backgroundFill", type="Boolean", inherit="no")]
	
	/**
	 * Цвет заднего фона
	 */	
	[Style(name="backgroundColor", type="uint", inherit="no")]
	
	/**
	 * Прозрачность заднего фона 
	 */	
	[Style(name="backgroundAlpha", type="Number", inherit="no")]
	
	
	/**
	 * При выборе кастомных пунктов из меню 
	 */	
	[Event( name = "itemClick", type="mx.events.MenuEvent")]
	
	/**
	 * При изменении свойства scale 
	 */	
	[Event( name = "scaled", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent" )]
	
	/**
	 * При двойном щелчке на каком либо узлов 
	 */	
	[Event( name = "nodeDoubleClick", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualNodeEvent" )]
	
	/**
	 * При двойном щелчке на каком либо из связей 
	 */	
	[Event( name = "edgeDoubleClick", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualEdgeEvent" )]
	
	/**
	 * Данные компоновки расчитаны, но не применены 
	 */	
	[Event( name = "layoutCalculated", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent" )]
	
	/**
	 * При полной перерисовке компоновщиком 
	 */	
	[Event( name = "layoutUpdated", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent" )]
	
	/**
	 * При изменении св-ва layouter 
	 */	
	[Event( name = "layoutChanged", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent" )]
	
	/**
	 * Изменились параметры layouter'а путем установки св-ва data 
	 */	
	[Event( name = "layoutDataChanged", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent" )]
	
	/**
	 * Изменились координаты одного или нескольких узлов 
	 */	
	[Event( name = "nodesUpdated", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent" )]
	
	/**
	 * Произошли изменения связанные с выделением 
	 */	
	[Event( name = "selectionChanged", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualSelectionChangedEvent" )]
	
	/**
	 * Начался процесс выделения рамочкой 
	 */	
	[Event( name = "startRectSelection", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualSelectionChangedEvent" )]
	
	/**
	 */	
	[Event( name = "endRectSelection", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualSelectionChangedEvent" )]
	
	/**
	 * Завершился процесс выделения рамочкой 
	 */	
	[Event( name = "endRectSelection", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualSelectionChangedEvent" )]
	
	/**
	 * Начался процесс перетаскивания какого-либо или нескольких узлов пользователем 
	 */
	[Event( name = "beginNodesDrag", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent" )]
	
	/**
	 * Окончание перетаскивания какого-либо или нескольких узлов пользователем  
	 */	
	[Event( name = "endNodesDrag", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent" )]
	
	/**
	 * Какой-то из объектов node и/или edge были удалены 
	 */		
	[Event( name = "delete", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent" )]
	
	/**
	 * Запустился асинхронный процесс расчета раскладки
	 */		
	[Event( name = "startAsynchrounousLayout", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent" )]
	
	/**
	 * Завершился асинхронный процесс расчета раскладки
	 */		
	[Event( name = "endAsynchrounousLayoutCalculation", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent" )]
	
	/**
	 * Информация о прогрессе расчета текущей раскладки
	 */		
	[Event( name = "progress", type="flash.events.ProgressEvent" )]
	
	/**
	 *  Пользователь пытается создать связь
	 */	
	[Event( name = "createEdge", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphCreateEdgeEvent" )]
	
	/**
	 *  Пользователь пытается удалить объекты
	 */
	[Event( name = "removeObject", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphRemoveObjectEvent" )]
	
	/**
	 *  Пользователь щелкнул на кнопке, открыть карточку объекта
	 */
	[Event( name = "openCardClick", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualNodeEvent" )]
	
	/**
	 * Был вызван метод initfromGraph объекта IVisualGraph 
	 */		
	//[Event( name = "initFromGraph", type="org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent" )]
	
	/**
	 * This component can visualize and layout a graph data structure in 
	 * a Flex application. It is derived from canvas and thus behaves much
	 * like that in general.
	 * 
	 * Currently the graphs are required to be connected. And for most layouts
	 * a root node is required (as they are tree based).
	 * 
	 * A graph object needs to be specified as well as a layouter object
	 * that implements the ILayoutAlgorithm interface.
	 * 
	 * XXX provide example code here
	 * */
	public class VisualGraph extends SavedUIComponent implements IVisualGraph, IViewport {
		
		/**
		 * Минимальный допустимый масштаб 25%
		 */	    
		public static const MIN_SCALE : Number = 0.25;
		
		/**
		 * Максимальный допустимый масштаб 200%
		 */		
		public static const MAX_SCALE : Number = 2.0;
		
		/**
		 * Приращение масштаба, при вызовах методов zoomIn, zoomOut ( 5% )
		 */		
		public static const ZOOM_INC : Number = 0.05;
		
		/**
		 * Приращение масштаба, при Zoom'е колесиком мышки ( 1% ) 
		 */		
		public static const WHEEL_ZOOM_INC : Number = 0.01;
		
		/**
		 * This property holds the Graph object with the graph
		 * data, that is supposed to be visualised. This is also
		 * the only data structure that keeps track of nodes and
		 * edges.
		 * */
		private var _graph:IGraph = null;
		
		/**
		 * This property holds the layouter object. The layouter does the 
		 * calculation of the layout and the placement of the nodes.
		 * It may be exchanged on the fly.
		 * */
		private var _layouter:ILayoutAlgorithm;
		
		/**
		 * Алгоритм раскладки который был использован при последней перерисовке 
		 */		
		private var _lastLayouter : ILayoutAlgorithm;
		
		/**
		 * Глобальный алгоритм раскладки для поодержки визуализации нескольких графов 
		 */		
		private var _complexLayouter : ComplexLayouter;
		
		/**
		 * for cleanup we also need a reference source for
		 * vnodes and vedges
		 * */
		private var _vnodes:Dictionary;
		private var _vedges:Dictionary;
		
		/**
		 * Every visual node is associated with an UIComponent that 
		 * will be the actual visual representation of the node in the
		 * Flashplayer. This UIComponent (which is typically an ItemRenderer)
		 * is called a "view". Node's views are now mainly created on
		 * demand and destroyed if the node is currently not visible
		 * to save resources. This map keeps track of which VNode belongs
		 * to which view. This is required as in certain events, we get
		 * only access to the UIComponent and we need to get hold of
		 * the corresponding node.
		 * */
		private var _nodeViewToVNodeMap:Dictionary;
		
		/**
		 * A similar map needs to exist for edges
		 * */
		private var _edgeLabelViewToVEdgeMap:Dictionary;
		
		private var _edgeViewToVEdgeMap:Dictionary;
		
		/**
		 * The standard origin is the upper left corner, but if
		 * the graph is scrolled, this origin may change, so we keep
		 * track of that here.
		 * 
		 * Не используется, поэтому сейчас реализовано в виде заглушки для поддержки IVisualGraph
		 * */
		private static const _origin : Point = new Point();
		
		/**
		 * The current zooming scale of the vgraph.
		 * This is used to facilitate the use of scaleX/scaleY
		 * and take it into account for drag and drop.
		 * Supported by getter/setting methods.
		 * (Contributed by Ivan Bulanov)
		 * */
		private var _scale:Number = 1;
		
		/* Rendering */
		
		/**
		 * We allow the specification of an EdgeRenderer (i.e. an IFactory)
		 * that allows us to specify the view's for each edge in MXML
		 * */
		private var _edgeRendererFactory:IFactory = null;
		
		/**
		 * We allow the specification of an ItemRenderer (i.e. an IFactory)
		 * that allows us to specify the view's for each node in MXML
		 * */
		private var _itemRendererFactory:IFactory = null;
		
		/**
		 * Also allow the specification of an IFactory for edge
		 * labels.
		 * */
		private var _edgeLabelRendererFactory:IFactory = null;
		
		/**
		 * Flag to force a redraw of all edge even if the layout
		 * has not changed
		 * */
		private var _forceUpdateEdges:Boolean = false;
		
		/**
		 * Flag to force a redraw of all nodes even if the layout
		 * has not changed
		 * */
		private var _forceUpdateNodes:Boolean = false;
		/**
		 * Specify whether edge labels should be displayed or not
		 * */
		//private var _displayEdgeLabels:Boolean = true;
		
		/**
		 * We keep the default parameters
		 * to draw edges (line width, color, alpha channel)
		 * in this object. The params to be expected are all
		 * params which can be accepted by the lineStyle()
		 * method of the Graphics class.
		 * We keep a separate default set for regular edges and
		 * for distinguished edges.
		 * */
		private var _defaultEdgeStyle:Object = VisualDefaults.edgeStyle;
		
		/* root nodes, distinguished nodes and history */
		
		/**
		 * This is the current focused / root node. It will be
		 * used as the root for any tree computations and
		 * currently all layouters depend on this.
		 * Typically the root node is selected by double-click.
		 * */
		private var _currentRootVNode : IVisualNode;
		
		private var edgeLayer:UIComponent;
		private var edgeLabelLayer : Container;
		private var nodeLayer : Container;
		
		/**
		 * Текущий режим работы компонета, возможные варианты перечислены в VisualGraphMode 
		 */		
		private var _mode : int;
		
		
		/* public attributes */
		
		/**
		 * enable bitmap caching in renderer components
		 * */
		public var cacheRendererObjects:Boolean = false;
		
		/**
		 * If set, this effect will be applied if a view
		 * is created (e.g. while a node becomes visible
		 * or if a new node is created).
		 * */
		public var addItemEffect:Effect;
		
		/**
		 * If set, this effect will be applied if a view
		 * is removed (e.g. a node becomes invisible or
		 * is removed).
		 * */
		public var removeItemEffect:Effect;
		
		/**
		 * Аниматор направления связей 
		 */		
		private var _edgesDirectionAnimator : EdgesDirectionAnimator;
		
		private var _features : IShowFeatures;
		
		/**
		 * The constructor just initialises most data structures, but not all
		 * required. Currently it does neither set a Graph object, nor a 
		 * Layouter object. Reasonable defaults may be added as an option.
		 * */
		public function VisualGraph() 
		{
			super();
			
			_features = UnisAPI.impl.features;
			
			/* initialise view/ItemRenderer and visibility mapping */
			_vnodes = new Dictionary;
			_vedges = new Dictionary;
			
			_selectedNodes = new Dictionary();
			_noSelectedNodes = 0;
			
			_selectedEdges = new Dictionary();
			_noSelectedEdges = 0;
			
			_nodeViewToVNodeMap = new Dictionary;            
			_edgeLabelViewToVEdgeMap = new Dictionary;
			_edgeViewToVEdgeMap = new Dictionary;
			
			/* set an edge renderer, for now we use the Default,
			* but at a later stage this could be set externally */
			_edgeRendererFactory = new ClassFactory( DirectedArrowEdgeRenderer );
			
			
			//Прокрутка колесиком мыши вверх/вниз
			addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			//Изменение размеров компонента
			addEventListener( ResizeEvent.RESIZE, onResized );
			
			_complexLayouter = new ComplexLayouter( this );
		}
		
		override protected function load() : void
		{
			super.load();
			
			if ( data.hasOwnProperty( 'layouter' ) )
			{
				layouter = LayouterFactory.create( this, data.layouter );
			}
			else
			{
				layouter      = new ConcentricRadialLayouter( this );
				data.layouter = layouter.data;
			}
		}
		
		override protected function setDefaults() : void
		{
			super.setDefaults();
			
			if ( ! data.hasOwnProperty( 'displayEdgeLabels' ) )
			{
				data.displayEdgeLabels = true;
			}
			
			if ( ! data.hasOwnProperty( 'animateEdgesDirection' ) )
			{
				data.animateEdgesDirection = false;
			}
		}
		
		private function commitData() : void
		{
			for ( var prop : String in data )
			{
				if ( prop == 'layouter' )
				{
					layouter = LayouterFactory.create( this, data[ prop ] );
					
					continue;
				}
				
				this[ prop ] = data[ prop ];
			}
		}
		
		override public function set data( value : Object ) : void
		{
			_data = value;

			setDefaults();
			commitData();
			
			save();			
			
			dispatchEvent( new VisualGraphEvent( VisualGraphEvent.VISUAL_GRAPH_DATA_CHANGED ) );
		}
		
		override protected function save() : void
		{
			data.layouter = layouter.data;
			
			super.save();
		}
		
		private function onAddedToStage( e : Event ) : void
		{
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			
		    stage.addEventListener( MouseEvent.RIGHT_CLICK, onVisualGraphRightClick );
			
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
			
			//Set default mode
			mode = VisualGraphMode.SELECTION;
		}
		
		private function onResized( e : ResizeEvent ) : void
		{
			setCliping( clipAndEnableScrolling );
		}
		
		/*Перемещение выделенных объектов*/
		
		/**
		 * Перетаскиваемые в данный момент узлы 
		 */		
		private var _movingNodes : Dictionary;
		
		//Текущее направление движения
		private var _moveDirection : Point; 
		
		/**
		 * Задержка перед добавлением события "перемещение" в историю 
		 */		
		private static const ADD_TO_HISTORY_DELAY : Number = 500.0;
		
		/**
		 * Приращение координат при кажом нажатии клавиши или залипании 
		 */		
		private static const MOVE_INC : Number = 2.0;
			
		/**
		 * Определяет идет ли сейчас процесс перетаскивания узлов с помощью клавиатуры 
		 * @return 
		 * 
		 */		
		private function get nodesMovingByKeyboard() : Boolean
		{
			return _moveDirection != null;
		}
		
		private function moveNodes() : void
		{
			//Если во время перемещения запустилась анимация, то прерываем процесс перетаскивания
			if ( animInProgress )
			{
			  cancelMoveNodes();
			  return;
			}
			
			for each ( var node : IVisualNode in _movingNodes )
			{
				node.x += _moveDirection.x * MOVE_INC;
				node.y += _moveDirection.y * MOVE_INC;
				
				node.commit();
			}
		}
		
		private function moveX( direction : Number ) : void
		{
			startMoveNodes();
			
			_moveDirection.x = direction;
			
			moveNodes();
			stopMoveNodes();
		}
		
		private function moveY( direction : Number ) : void
		{
			startMoveNodes();
			
			_moveDirection.y = direction;
			
			moveNodes();
			stopMoveNodes();
		}
		
		private function startMoveNodes() : void
		{
			if ( ! _moveDirection )
			{
				_moveDirection = new Point();
				//trace( 'startMoveNodes' );
				if ( ! moveNodesOperation )
				{
					moveNodesOperation = new MoveNodes( this );
					moveNodesOperation.dumpBefore();	
				}
				
				_movingNodes = ObjectUtil.cloneDictionary( _selectedNodes );
			}
		}
		
		private function stopMoveNodes() : void
		{
			if ( _moveDirection.length == 0 )
			{
				//trace( 'stopMoveNodes' );
				
				correctNodesPositionAndBounds();
				scrollToNodes( _movingNodes );
				
				_movingNodes = null;
				_moveDirection = null;
				
				if ( timeoutNodesToHistoryTimer != -1 )
				{
					clearTimeout( timeoutNodesToHistoryTimer );
				}
				
				timeoutNodesToHistoryTimer = setTimeout( addMoveNodesToHistory, ADD_TO_HISTORY_DELAY );
				
				dispatchEvent( new VisualGraphEvent( VisualGraphEvent.NODES_UPDATED ) );
			}
		}
		
		private function cancelMoveNodes() : void
		{
			_movingNodes       = null;
			_moveDirection     = null;
			moveNodesOperation = null;
		}
		
		private var timeoutNodesToHistoryTimer : int = -1;
		
		private function addMoveNodesToHistory() : void
		{
			timeoutNodesToHistoryTimer = -1;
			
			if ( ! nodesMovingByKeyboard )
			{
				moveNodesOperation.dumpAfter();
				History.add( moveNodesOperation );
				moveNodesOperation = null;
			}
		}
		
		/*Перемещение выделенных объектов
		
		/**
		 * Клавиша на клавиатуре нажата 
		 * @param e
		 * 
		 */		
		private function onKeyDown( e : KeyboardEvent ) : void
		{
			//Если откыты диалоговые окна, то ничего не делаем
			if ( PopUpManager.numWindows > 0 )
			{
				return;
			}
			
			//Во время анимации ничего не делаем
			if ( animInProgress )
			{
				return;
			}
			
			//Перемещение выделенных узлов
			if ( _noSelectedNodes > 0 )
			{
				//Влево
				if ( e.keyCode == Keyboard.LEFT )
				{
					moveX( -1.0 );
					return;
				}
				
				//Вправо
				if ( e.keyCode == Keyboard.RIGHT )
				{
					moveX( 1.0 );
					return;
				}
				
				//Вниз
				if ( e.keyCode == Keyboard.DOWN )
				{
					moveY( 1.0 );
					return;
				}
				
				//Вверх
				if ( e.keyCode == Keyboard.UP )
				{
					moveY( -1.0 );
					return;
				}
			}
		}
		
		/**
		 * Клавиша на клавиатуре отпущена 
		 * @param e
		 * 
		 */		
		private function onKeyUp( e : KeyboardEvent ) : void
		{
			//Если откыты диалоговые окна, то ничего не делаем
			if ( PopUpManager.numWindows > 0 )
			{
				return;
			}
			
			//Отключаем перемещение узлов, если ранее они перемещались
			if ( _noSelectedNodes > 0 )
			{
				//Влево-Вправо
				if ( ( e.keyCode == Keyboard.LEFT ) || ( e.keyCode == Keyboard.RIGHT ) )
				{
					moveX( 0.0 );
					return;
				}
				
				//Вниз-Вверх
				if ( ( e.keyCode == Keyboard.DOWN ) || ( e.keyCode == Keyboard.UP ) )
				{
					moveY( 0.0 );
					return;
				}
			}
			
			if ( e.ctrlKey )
			{
				//Выделить все узлы и связи
				if ( e.keyCode == Keyboard.A )
				{
					selectAll();
					sendVisualSelectionChangedEvent( VisualSelectionChangedEvent.SELECTION_CHANGED );
					return;
				}
				
				//Перерисовать
				if ( e.keyCode == Keyboard.R )
				{
					if ( _features.isAllow( IShowFeatures.REFRESH ) )
					{
						draw();
					}
					
					return;
				}
				
				//Оменить
				if ( e.keyCode == Keyboard.Z )
				{
					if ( _features.isAllow( IShowFeatures.UNDO_AND_REDO ) )
					{
						if ( History.isCanUndo() )
						{
							History.undo();
						}
						
						return;
					}
				}
				
				//Повторить
				if ( e.keyCode == Keyboard.Y )
				{
					if ( _features.isAllow( IShowFeatures.UNDO_AND_REDO ) )
					{
						if ( History.isCanRedo() )
						{
							History.redo();
						}
					}
				}
			}
			
			//Снять выделение с выделенных объектов
			if ( e.keyCode == Keyboard.ESCAPE )
			{
				clearSelection();
				return;
			}
			
			//Удалить выделенные объекты
			if ( e.keyCode == Keyboard.DELETE )
			{
				//Создаем отменяемое событие
				var event : VisualGraphRemoveObjectEvent = new VisualGraphRemoveObjectEvent( VisualGraphRemoveObjectEvent.REMOVE_OBJECT, ObjectUtil.dictionaryToArray( _selectedNodes ), ObjectUtil.dictionaryToArray( _selectedEdges ) );
				
				if ( dispatchEvent( event ) )
				{
					removeSelected();	
				}
				
				return;
			}
			
			//Увеличить масштаб
			if ( ( e.keyCode == Keyboard.NUMPAD_ADD ) || ( e.keyCode == Keyboard.EQUAL ) )
			{
				if ( _features.isAllow( IShowFeatures.CHANGE_SCALE ) )
				{
					zoomIn();
				}
				
				return;
			}
			
			//Уменьшить масштаб
			if ( ( e.keyCode == Keyboard.NUMPAD_SUBTRACT ) || ( e.keyCode == Keyboard.MINUS ) )
			{
				if ( _features.isAllow( IShowFeatures.CHANGE_SCALE ) )
				{
					zoomOut();
				}
				
				return;
			}
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			edgeLayer = new UIComponent();
			addChild(edgeLayer);
			
			edgeLabelLayer = new Container();
			addChild(edgeLabelLayer);
			
			nodeLayer = new Container();
			addChild(nodeLayer);
			
			_grid = new VisualGrid( this );
			
			_edgesDirectionAnimator = new EdgesDirectionAnimator( this );
		}
		
		
		public function get animateEdgesDirection() : Boolean
		{
			return _data.animateEdgesDirection;
		}
		
		public function set animateEdgesDirection( value : Boolean ) : void
		{
			data.animateEdgesDirection = value;
			invalidateProperties();
			save();
		}
		
		public function getVNodeByView( view : UIComponent ) : IVisualNode
		{
			return _nodeViewToVNodeMap[ view ];
		}
		
		public function get vnodes() : Dictionary
		{
			return _vnodes;
		}
		
		public function get noVNodes() : uint
		{
			return _graph ? _graph.nodes.length : 0;
		}
		
		public function get vedges() : Dictionary
		{
			return _vedges;
		}
		
		/**
		 * Обработка колесиком мышки вниз/вверх 
		 * @param e
		 * 
		 */		
		private function onMouseWheel( e : MouseEvent ) : void
		{
			scale += ( e.delta / Math.abs( e.delta ) ) * WHEEL_ZOOM_INC;
		}
		
		/**
		 * This property allows access and setting of the underlying
		 * graph object. If set, it will automatically initialise the VGraph
		 * from the Graph object, i.e. create VNodes and VEdges for each
		 * Graph node and Graph edge.
		 * If there was already a Graph present, the VGraph is purged, but no other
		 * cleanup is done, which means that there could still be
		 * some references floating around thus leaking memory.
		 * For now, avoid setting it more than once in the same
		 * VGraph.
		 * @param g The Graph object to be assigned.
		 * */
		public function set graph(g:IGraph):void {
			
			if(_graph != null) {
				
				/* this cleanes the VGraph so we are pristine */
				
				purgeVGraph();
				_graph.purgeGraph();
				
				
				/* this may have been removed already before */
				if(_layouter) {
					_layouter.resetAll();
				}
			}
			
			/* assign defaults */
			_graph = g;
			
			/* IMPORTANT: a layouter also has a graph reference
			* separate, this must be updated in order for
			* this to work properly
			*/
			/*if(_layouter) {
				_layouter.graph = g;
			}*/
			
			/* better safe than sorry even if it is an empty one */
			//initFromGraph();
			
			/* invalidate old root node */
			_currentRootVNode = null;
			
			/* now use the first node as the new default root node */
			if(_graph.nodes.length > 0) {
				_currentRootVNode = (_graph.nodes[0] as INode).vnode;
			}
		}
		
		/**
		 * @private
		 * */
		public function get graph():IGraph {
			return _graph;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function set itemRenderer(ifac:IFactory):void {
			if(ifac != _itemRendererFactory) {
				_itemRendererFactory = ifac;
				
				/* if that has changed, we would need to recreate all
				* currently visible nodes */
				setAllInVisible();
				updateVisibility();
			}
		}
		
		/**
		 * @private
		 * */
		public function get itemRenderer():IFactory {
			return _itemRendererFactory;
		}
		
		
		/**
		 * @inheritDoc
		 * */
		public function set edgeRendererFactory(er:IFactory):void {
			if(er != _edgeRendererFactory) {
				
				setAllEdgesInVisible();
				
				_edgeRendererFactory = er;
				
				updateEdgeVisibility();
			}
		}
		/**
		 * @private
		 * */
		public function get edgeRendererFactory():IFactory {
			return _edgeRendererFactory;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function set edgeLabelRenderer(elr:IFactory):void {
			/* if the factory was changed, then we have to remove all
			* instances of vedgeViews to have them updated */
			if(elr != _edgeLabelRendererFactory) {
				/* set all edges invisible, this should delete all instances
				* of view components */
				setAllEdgesInVisible();
				
				/* set the new renderer */
				_edgeLabelRendererFactory = elr;	
				
				/* update i.e. recreate the instances */
				updateEdgeVisibility();
			}
		}
		
		/**
		 * @private
		 * */
		public function get edgeLabelRenderer():IFactory {
			return _edgeLabelRendererFactory;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function set displayEdgeLabels( del : Boolean ) : void
		{
			/*if ( displayEdgeLabels == del )
			{
				return;
			}*/
			
			data.displayEdgeLabels = del;
			
			for each( var edge : IVisualEdge in _vedges )
			{
				setEdgeLabelVisibility( edge, del );
			}
			
			save();
		}
		
		/**
		 * @private
		 * */
		public function get displayEdgeLabels():Boolean {
			return _data.displayEdgeLabels;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get layouter():ILayoutAlgorithm {
			return _layouter;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get asynchrounousLayouter() : IAsynchronousLayouter
		{
			return _layouter as IAsynchronousLayouter;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get lastLayouter() : ILayoutAlgorithm
		{
			return _lastLayouter ? _lastLayouter : _layouter;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get lastAsynchrounousLayouter() : IAsynchronousLayouter
		{
			return lastLayouter as IAsynchronousLayouter;
		}
		
		/**
		 * @private
		 * */
		public function set layouter( l : ILayoutAlgorithm ) : void
		{
			if ( _layouter )
			{
				_complexLayouter.resetAll(); // to stop any pending animations
				unsetListenersForLayouter( _layouter );
			}
			
			_layouter = l;
			
			if ( _layouter )
			{
				setListenersForLayouter( _layouter );
			}
			
			save();
			
			dispatchEvent( new VisualGraphEvent( VisualGraphEvent.LAYOUT_CHANGED ) );
		}
		
		public function get complexLayouter() : ComplexLayouter
		{
			return _complexLayouter;
		}
		
		/**
		 * Устанавливает необходимые слушатели для алгоритма раскладки 
		 * @param l - алгоритм раскладки для которого необходимо установить слушатели
		 * 
		 */		
		private function setListenersForLayouter( l : ILayoutAlgorithm ) : void
		{
			l.addEventListener( VisualGraphEvent.LAYOUT_UPDATED, onLayoutUpdated );
			l.addEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onLayoutCalculated, false, int.MAX_VALUE );
			
			l.addEventListener( VisualGraphEvent.LAYOUT_DATA_CHANGED, onLayoutDataChanged );
			l.addEventListener( VisualGraphEvent.LAYOUT_PARAM_CHANGED, onLayoutParamChanged );
			
			l.addEventListener( VisualGraphEvent.START_ASYNCHROUNOUS_LAYOUT_CALCULATION, onStartAsynchrounousLayoutCalculation );
			l.addEventListener( VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION, onEndAsynchrounousLayoutCalculation );
			l.addEventListener( ProgressEvent.PROGRESS, onAsynchrounousLayoutProgress );
		}
		
		/**
		 * Удаляет слушатели установленные ранее для алгоритма раскладки 
		 * @param l - алгоритм раскладки для которого необходимо удалить слушатели
		 * 
		 */		
		private function unsetListenersForLayouter( l : ILayoutAlgorithm ) : void
		{
			l.removeEventListener( VisualGraphEvent.LAYOUT_UPDATED, onLayoutUpdated );
			l.removeEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onLayoutCalculated );
			
			l.removeEventListener( VisualGraphEvent.LAYOUT_DATA_CHANGED, onLayoutDataChanged );
			l.removeEventListener( VisualGraphEvent.LAYOUT_PARAM_CHANGED, onLayoutParamChanged );
			
			l.removeEventListener( VisualGraphEvent.START_ASYNCHROUNOUS_LAYOUT_CALCULATION, onStartAsynchrounousLayoutCalculation );
			l.removeEventListener( VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION, onEndAsynchrounousLayoutCalculation );
			l.removeEventListener( ProgressEvent.PROGRESS, onAsynchrounousLayoutProgress );
		}
		
		private function onAsynchrounousLayoutProgress( e : ProgressEvent ) : void
		{
			dispatchEvent( e );
		}
		
		private function onStartAsynchrounousLayoutCalculation( e : VisualGraphEvent ) : void
		{
			dispatchEvent( e );
		}
		
		private function onEndAsynchrounousLayoutCalculation( e : VisualGraphEvent ) : void
		{
			dispatchEvent( e );
		}
		
		private function onLayoutDataChanged( e : VisualGraphEvent ) : void
		{
			save();
			dispatchEvent( e );
		}
		
		private function onLayoutParamChanged( e : VisualGraphEvent ) : void
		{
			save();
			dispatchEvent( e );
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get origin():Point {
			return _origin;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get center() : Point {
			return new Point( this.width / 2.0, this.height / 2.0 );
		}
		
		/**
		 * This was added for testing. It may be removed
		 * again.
		 * */
		public function get currentRootSID():String {
			return _currentRootVNode.node.stringid;
		}
		
		/**
		 * @inheritDoc
		 * */
		/* [Bindable]  */
		public function get currentRootVNode():IVisualNode {
			return _currentRootVNode;
		}
		/**
		 * @private
		 * */
		public function set currentRootVNode(vn:IVisualNode):void {
			/* check for a change */
			if ( _currentRootVNode != vn )
			{
				/* apply the change */
				_currentRootVNode = vn;
				_complexLayouter.setRoot( vn.node );
			}	
		}
		
		private function getNodesAsDictionary():Dictionary {
			var retVal:Dictionary = new Dictionary();
			for each(var node:INode in _graph.nodes)
			{
				retVal[node] = node;
			}
			
			return retVal;
		}		
			
		/**
		 * @inheritDoc
		 * */
		public function get scale():Number {
			return _scale;
		}
		
		/**
		 * @private
		 * */
		public function set scale( s : Number ) : void
		{
			if ( s != _scale )
			{
				if ( s < MIN_SCALE )
				{
					s = MIN_SCALE;
				}
				else
				if ( s > MAX_SCALE )
				{
					s = MAX_SCALE;
				}
				
				_scale = s;
				
				nodeLayer.scaleX = s;
				nodeLayer.scaleY = s;
				
				edgeLayer.scaleX = s;
				edgeLayer.scaleY = s;
				
				edgeLabelLayer.scaleX = s;
				edgeLabelLayer.scaleY = s;
				
				_grid.scale = s;
				
				correctNodesPositionAndBounds();
				
				dispatchEvent( new VisualGraphEvent( VisualGraphEvent.SCALED ) );
			}
		}
		
		/**
		 * Увеличивает масштаб на ZOOM_INC 
		 * 
		 */		
		public function zoomIn() : void
		{
			scale += ZOOM_INC;
		}
		
		/**
		 * Уменьшает масштаб на ZOOM_INC 
		 * 
		 */		
		public function zoomOut() : void
		{
			scale -= ZOOM_INC;
		}
		
		
		/**
		 * This initialises a VGraph from a Graph object.
		 * I.e. it crates a VNode for every Node found in
		 * the Graph and a VEdge for every Edge in the Graph.
		 * Careful, this currently does not check if the VGraph
		 * was already initialised and it does not purge anything.
		 * Things could break if used on an already initialized VGraph.
		 * */
		public function initFromGraph( creationPoint : Point = null, setVisibilityTo : Boolean = true ) : void
		{
			var node  : INode;
			var vnode : IVisualNode;
			
			var edge  : IEdge;
			var vedge : IVisualEdge;
			
			/* create the vnode from the node */
			for each( node in _graph.nodes )
			{
				if ( node.vnode == null )
				{
					vnode = this.createVNode( node, creationPoint );
					vnode.isVisible = setVisibilityTo;
				}
			}
			
			/* we also create the edge objects, since they
			* may carry additional label information or something
			* like that, but they do not have a view */
			for each( edge in _graph.edges )
			{
				if ( edge.vedge == null )
				{
					vedge = this.createVEdge( edge );
					vedge.isVisible = setVisibilityTo;
				}
			}
		}
		
		/** 
		 * @inheritDoc
		 * */
		public function createNode( sid : String = "", o : Object = null, creationPoint : Point = null, createView : Boolean = true ) : IVisualNode
		{
			var gnode : INode;
			var vnode : IVisualNode;
			
			/* first add a new node to the underlying graph */
			gnode = _graph.createNode( sid, o );
			
			/* Then create the VNode with associated with the graph node */
			vnode = createVNode( gnode, creationPoint, createView );
			
			/* Если текущий root не установлен, устанавливаем его */
			if ( _currentRootVNode == null )
			{
				_currentRootVNode = vnode;	
			}
			
			return vnode;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function removeNode(vn:IVisualNode):void {
			
			var n:INode;
			var e:IEdge;
			var ve:IVisualEdge;
			var i:int;
			
			n = vn.node;
			
			/* if the current root node is the
			* node to be removed it must be
			* changed.
			*
			* First, we set it to null, then we remove the
			* node, then at the end we reset it
			* to the first node still in the
			* nodes array */
			if(vn == _currentRootVNode) {
				/* temporary set to null */
				_currentRootVNode = null;
			}
			
			/* remove all incoming edges */
			while(n.inEdges.length > 0) {
				e = n.inEdges[0] as IEdge;
				ve = e.vedge;
				removeVEdge(ve);
				_graph.removeEdge(e);
			}
			
			/* remove all outgoing edges */
			while(n.outEdges.length > 0) {
				e = n.outEdges[0] as IEdge;
				ve = e.vedge;
				removeVEdge(ve);
				_graph.removeEdge(e);
			}
			
			//Если узел выделен, то удаляем выделение
			if ( _selectedNodes[ vn ] )
			{
				delete _selectedNodes[ vn ];
				_noSelectedNodes --;
			}
			
			/* remove the vnode */
			removeVNode(vn);
			
			/* remove the node from the graph */
			_graph.removeNode(n);
			
			/* now set a new root node, implies that there is
			* still a node */
			if(_currentRootVNode == null && _graph.noNodes > 0) {
				_currentRootVNode = (_graph.nodes[0] as INode).vnode;
			}
			
			/* since we removed also edges, we need a refresh */
			refresh();
		}
		
		/**
		 * Возвращает data для EdgeRenderer, по умолчанию ( Для случая динамического создания связей ) 
		 * @return 
		 * 
		 */		
		public static function getDefaultEdgeData() : Object
		{
			return {
				flow  : 1,
				arrow : ArrowStyle.DEFAULT_ARROW_STYLE
			}
		}
		
		/** 
		 * @inheritDoc
		 * */
		public function linkNodes( v1 : IVisualNode, v2 : IVisualNode, data : Object = null ) : IVisualEdge
		{
			if ( ! data )
			{
				data = getDefaultEdgeData();
			}
			
			var e  : IEdge       = _graph.link( v1.node, v2.node, data.id, data );
			var ve : IVisualEdge = createVEdge( e );
			
			refresh();
			
			return ve;
		}
		
		/**
		 * Удаляет указанную связь из графа 
		 * @param e
		 * 
		 */		
		public function removeEdge( e : IVisualEdge ) : void
		{
			//Если связь выделена, то удаляем выделение
			if ( _selectedEdges[ e ] )
			{
				delete _selectedEdges[ e ];
				_noSelectedEdges --;
			}
			
			removeVEdge( e );
			_graph.removeEdge( e.edge );
			
			/*
			Обновляем связи связывающие одинаковые объекты ( Костыль :)
			*/
			var similarEdges : Vector.<IEdge> = getSimilarEdges( e );
			var edge         : IEdge;
			
			if ( similarEdges.length > 0 )
			{
				for each( edge in similarEdges )
				{
					if ( edge.vedge )
					{
						refreshEdge( edge.vedge );
					}
				}
			}
			
			refresh();
		}
		
		/**
		 * Обновляет связь 
		 */		
		private function refreshEdge( ve : IVisualEdge ) : void
		{
			setEdgeVisibility( ve, false );
			setEdgeVisibility( ve, true );
			refresh();
		}
		
		/** 
		 * @inheritDoc
		 * */
		public function unlinkNodes(v1:IVisualNode, v2:IVisualNode):void {
			
			var n1:INode;
			var n2:INode;
			var e:IEdge;
			var ve:IVisualEdge;
			
			/* make sure both nodes exist */
			if(v1 == null || v2 == null) {
				throw Error("unlink nodes: one of the nodes does not exist");
				return;
			}
			
			n1 = v1.node;
			n2 = v2.node;
			
			/* find the graph edge */
			e = _graph.getEdge(n1,n2);
			
			/* if we do not get an edge, it may simply not exist */
			if(e == null) {
				return;
			}
			
			/* now get and remove the VEdge first */
			ve = e.vedge;			
			removeVEdge(ve);
			
			/* now remove the edge itself, basically
			* unlinking the nodes */
			_graph.removeEdge(e);
			
			refresh();
		}
		
		
		/**
		 * @inheritDoc
		 * */
		public function scroll(deltaX:Number, deltaY:Number):void {
			horizontalScrollPosition += deltaX;
			verticalScrollPosition   += deltaY;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function redrawNodes():void
		{
			if(_graph == null) {
				return;
			}
			
			for each(var node:INode in _graph.nodes) {
				if(node.vnode !=null && node.vnode.view != null) {
					node.vnode.commit();
					node.vnode.view.invalidateDisplayList();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 * */
		public function refresh() : void
		{
			
			if ( _graph == null )
			{
				return;
			}
			
			/* this forces the next call of updateDisplayList()
			* to redraw all edges and all nodes*/
			_forceUpdateEdges = true;
			_forceUpdateNodes = true;
			
			//we want this because we have our own 
			//specific display list things in updateDisplayList
			invalidateDisplayList();
		}
		
		/**
		 * Идентификатор таймера ( задержка перед отрисовкой ) 
		 */		
		private var _timeoutTimer : int = -1;
		
		/**
		 * Задержка перед отрисовкой ( 50 мс )
		 */			
		private static const REDRAW_DELAY : Number = 50.0;
		
		/**
		 * @inheritDoc
		 * */
		public function draw( l : ILayoutAlgorithm  = null ) : void
		{
			/*
			Каждый раз отрисовываем с задержкой, для того, чтобы если есть ещё не инициализированные визуальные узлы, они успели инициализироваться
			( Если этого не делать, размер рабочей области может быть вычислен некорректно )
			*/
			
			if ( _timeoutTimer != -1 )
			{
				clearTimeout( _timeoutTimer );
				_timeoutTimer = -1;
			}
			
			_complexLayouter.resetAll();
			
			//Указан алгоритм раскладки
			if ( l )
			{
				//Удаляем предыдущие слушатели
				if ( _lastLayouter != _layouter )
				{
					unsetListenersForLayouter( _lastLayouter );
				}
				
				_lastLayouter = l;
				
				//Устанавливаем слушатели для нового алгоритма раскладки
				if ( _lastLayouter != _layouter )
				{
					setListenersForLayouter( _lastLayouter );	
				}
			}
			else //Не указан алгоритм раскладки
			{
				_lastLayouter = _layouter;
			}
			
			_timeoutTimer = setTimeout( _draw, REDRAW_DELAY );
			dispatchEvent( new VisualGraphEvent( VisualGraphEvent.DRAW ) );
			
			invalidateDisplayList();
		}
		
		/**
		 * @inheritDoc
		 * */
		private function _draw() : void
		{	
			//Указываем, что предыдущий таймер отработал	
			_timeoutTimer = -1;	
				
			/* first refresh does layoutChanges to true and
			* invalidate display list */
			refresh();
			
			stopAllUserInteractions();
			
			//
			//_lastLayouter.root = _currentRootVNode.node;
			//
			
			//_lastLayouter.layoutPass();
			_complexLayouter.layoutPass();
			
			invalidateDisplayList();
		}
		
		/**
		 * this function takes the node with the specified
		 * string id and selects it as a root
		 * node, automatically centering the layout around it
		 * */
		public function centerNodeByStringId(nodeID:String):IVisualNode {
			
			var newroot:INode;
			
			if(_graph == null) {
				return null;
			}
			
			newroot = _graph.nodeByStringId(nodeID);
			
			/* if we have a node, set its vnode as the new root */
			if(newroot) {
				/* is it really a new node */
				if(newroot.vnode != _currentRootVNode) {
					/* set it */
					this.currentRootVNode = newroot.vnode;
					return newroot.vnode;
				} else {
					return _currentRootVNode;
				}
			}
			
			return null;
		}
		
		
		
		/**
		 * This calls the base updateDisplayList() method of the
		 * Canvas and in addition redraws all edges if the layouter
		 * indicates that the layout has changed.
		 * 
		 * @inheritDoc
		 * */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			/* call the original function */
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			//Отрисовка заднего фона
			var showBG  : Boolean = getStyle( 'backgroundFill' );
			var bgColor : uint    = 0x000000;
			var bgAlpha : Number  = 0.0;
			
			if ( showBG )
			{
				bgColor = getStyle( 'backgroundColor' );
				bgAlpha = getStyle( 'backgroundAlpha' );
			}
			
			//Прозрачный прямоугольник ( Задний фон )
			graphics.clear();
			graphics.beginFill( bgColor, bgAlpha );
			graphics.drawRect( _hsp, _vsp, unscaledWidth, unscaledHeight );
			graphics.endFill();
			
			//Отрисовываем сетку, если необходимо
			_grid.draw();
			
			/* now add part to redraw edges */
			if ( lastLayouter ) {
				
				/*if(_layouter.layoutChanged) {
					
					redrawEdges();
					redrawNodes();
					
					_forceUpdateNodes = false;
					_forceUpdateEdges = false;
					lastLayouter.layoutChanged = false;
				}*/
				
				if(_forceUpdateNodes) {
					redrawNodes();
					_forceUpdateNodes = false;
				}
				
				if(_forceUpdateEdges) {
					redrawEdges();
					_forceUpdateEdges = false;
				}
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if ( _showGrid != _grid.show )
			{
				_grid.show = _showGrid;
			}
			
			if ( _snapToGrid != _grid.snap )
			{
				_grid.snap = _snapToGrid;
			}
			
			if ( animateEdgesDirection != _edgesDirectionAnimator.enabled )
			{
				_edgesDirectionAnimator.enabled = animateEdgesDirection;
			}
		}
		
		/* private methods */
		
		/**
		 * Creates VNode and requires a Graph node to associate
		 * it with. Originally also created the view, but we no
		 * longer do that directly but only on demand.
		 * @param n The graph node to be associated with.
		 * @return The created VisualNode.
		 * */
		private function createVNode( n : INode, creationPoint : Point = null , createView : Boolean = true ):IVisualNode {
			
			var vnode : IVisualNode;
			
			/* as an id we use the id of the graph node for simplicity
			* for now, it is not really used separately anywhere
			* we also use the graph data object as our data object.
			* the view is set to null and remains so. */
			vnode = new VisualNode(this, n, n.stringid, null, n.data);
			
			//Если координаты узла не указаны
			if ( isNaN( vnode.x ) || isNaN( vnode.y ) )
			{
				//Если указаны координаты вновь создаваемых узлов
				if ( creationPoint )
				{
					vnode.x = creationPoint.x;
					vnode.y = creationPoint.y;
				}
				else //Если не указаны
				{
					//Располагаем вновь созданный node, по центру
					var center : Point = this.center;
					
					vnode.x = center.x;
					vnode.y = center.y;
				}
			}
			
			
			
			/* if the node should be visible by default 
			* we need to make sure that the view is created */
			if( createView ) {
				setNodeVisibility(vnode, true);
			}
			
			/* now set the vnode in the node */
			n.vnode = vnode;
			/* add the node to the hash to keep track */
			_vnodes[vnode] = vnode;
			
			return vnode;
		}
		
		/**
		 * Removes a VNode, this also removes the node's view
		 * if it existed, but does not touch the Graph node.
		 * @param vn The VisualNode to be removed.
		 * */
		private function removeVNode(vn:IVisualNode):void {
			
			var view:UIComponent;
			
			/* get access to the node's view, but get the 
			* raw view to avoid unnecessary creation of a view
			*/
			view = vn.view;
			
			/* delete reference to the view from the node */
			vn.view = null;
			
			/* remove the reference to this node from the graph node */
			vn.node.vnode = null;
			
			/* now remove the view component if it existed */
			if(view != null) {
				removeNodeView(view);
			}
			
			/* remove from tracking hash */
			delete _vnodes[vn];
			
			/* this should clean up all references to this VNode
			* thus freeing it for garbage collection */
		}
		
		
		private function deleteVisibleVNode(vn:IVisualNode):void
		{
			vn.isVisible = false;

			/* remove the view if there is one */
			if(vn.view != null) {
				removeNodeView(vn.view, false);
			}
		}
		
		/**
		 * Creates a VEdge from a graph Edge.
		 * @param e The Graph Edge.
		 * @return The created VEdge.
		 * */
		private function createVEdge(e:IEdge):IVisualEdge {
			
			var vedge:IVisualEdge;
			var n1:INode;
			var n2:INode;
			var lStyle:Object;
			var edgeAttrs:XMLList;
			var attr:XML;
			var attname:String;
			var attrs:Array;
			
			/* create a copy of the default style */
			lStyle = ObjectUtil.copy(_defaultEdgeStyle);
			
			/* extract style data from associated XML data for each parameter */
			attrs = ObjectUtil.getClassInfo(lStyle).properties;
			
			//Переопределяем св-ва отрисовки по умолчанию
			for each( attname in attrs )
			{
				if ( e.data )
				{
					if ( e.data.hasOwnProperty( attname ) )
					{
						if ( e.data[ attname ] )
						{
							lStyle[ attname ] = e.data[ attname ];
						} 
					}
				}
			}
			
			vedge = new VisualEdge(this, e, e.stringid, e.data, null, lStyle);
			
			/* set the VisualEdge reference in the graph edge */
			e.vedge = vedge;
			
			/* check if the edge is supposed to be visible */
			n1 = e.node1;
			n2 = e.node2;
			
			/* if both nodes are visible, the edge should
			* be made visible, which may also create a label
			*/
			//if(n1.vnode.isVisible && n2.vnode.isVisible) {
				setEdgeVisibility(vedge, true);
			//}
			
			/* add to tracking hash */
			_vedges[vedge] = vedge;
			return vedge;
		}
		
		/**
		 * Remove a VisualEdge, but leaves the Graph Edge alone.
		 * @param ve The VisualEdge to be removed.
		 * */
		private function removeVEdge(ve:IVisualEdge):void {
			
			/* just in case */
			if(ve == null) {
				return;
			}
			
			/* first turn it invisible, which should
			* remove the labelview */
			setEdgeVisibility(ve, false);
			
			delete _edgeViewToVEdgeMap[ve.edgeView];
			
			/* remove the reference from the real edge */
			ve.edge.vedge = null;
			
			/* remove from tracking hash */
			delete _vedges[ve];
		}
		
		/**
		 * Purges the VGraph by dropping all VNodes and VEdges.
		 * This is a bit tricky, since we do not really
		 * keep track of them in the VGraph, they are only referenced
		 * by the Graph nodes and egdes.
		 * */
		private function purgeVGraph():void {
			
			var ves:Array = new Array;
			var vns:Array = new Array;
			var ve:IVisualEdge;
			var vn:IVisualNode;
			
			//Очищаем список выделенных узлов
			_selectedNodes = new Dictionary();
			_noSelectedNodes = 0;
			
			//Очищаем список выделенных связей
			_selectedEdges = new Dictionary();
			_noSelectedEdges = 0;
			
			/* this appears rather inefficient, however
			* ObjectUtil.copy does not work on dictionaries
			* currently I have no other solution
			*/
			for each(ve in _vedges) {
				ves.unshift(ve);
			}
			for each(vn in _vnodes) {
				vns.unshift(vn);
			}
			
			if(_graph != null) {
				for each(ve in ves) {
					removeVEdge(ve);
				}
				for each(vn in vns) {
					removeVNode(vn);
				}
			} 			
		}
		
		/**
		 * Redraw all edges, this is called from the updateDisplayList()
		 * method.
		 * @inheritDoc
		 * */
		public function redrawEdges():void {
			
			var vn1:IVisualNode;
			var vn2:IVisualNode;
			var vedge:IVisualEdge;
			
			/* make sure we have a graph */
			if(_graph == null) {
				return;
			}
			
			for each(vedge in _edgeViewToVEdgeMap)
			{
				IEdgeRenderer(vedge.edgeView).render();
			}
			
		}
		
		/**
		 * Create a "view" object (UIComponent) for the given node and
		 * return it. These methods are only exported to be used by
		 * the VisualNode. Alas, AS does not provide the "friend" directive.
		 * Not sure how to get around this problem right now.
		 * @param vn The node to replace/add a view object.
		 * @return The created view object.
		 * */
		private function createVNodeComponent(vn:IVisualNode):UIComponent {
			
			var mycomponent:UIComponent = null;
			
			if(_itemRendererFactory != null) {
				mycomponent = _itemRendererFactory.newInstance();
			} else {
				mycomponent = new TextIconNodeRenderer();
			}			
			
			/* assigns the item (VisualNode) to the IDataRenderer part of the view
			* this is important to access the data object of the VNode
			* which contains information for rendering. */		
			if(mycomponent is IDataRenderer) {
				(mycomponent as IDataRenderer).data = vn;
			}
			
			/* set initial x/y values */
			mycomponent.x = vn.x; 
			mycomponent.y = vn.y;
			
			/* add event handlers for dragging and double click */			
			mycomponent.doubleClickEnabled = true;
			mycomponent.addEventListener( MouseEvent.DOUBLE_CLICK, nodeDoubleClick );
			mycomponent.addEventListener( MouseEvent.MOUSE_DOWN, nodeMouseDown );
			mycomponent.addEventListener( MouseEvent.ROLL_OVER, nodeRollOver, false, 1000 );
			mycomponent.addEventListener( MouseEvent.ROLL_OUT, nodeRollOut, false, 1000 );
			mycomponent.addEventListener( VisualNodeEvent.EXPAND_CLICK, nodeExpandClick );
			mycomponent.addEventListener( VisualNodeEvent.OPEN_CARD_CLICK, nodeOpenCardClick );
			
			//mycomponent.addEventListener( MouseEvent.CLICK, nodeClick );
			
			/* enable bitmap cachine if required */
			mycomponent.cacheAsBitmap = cacheRendererObjects;
			
			/* add the component to its parent component */
			nodeLayer.addChild(mycomponent);
			mycomponent.validateNow();
			
			/* do we have an effect set for addition of
			* items? If yes, create and start it. */
			if(addItemEffect != null) {
				addItemEffect.createInstance(mycomponent).startEffect();
			}
			
			/* register it the view in the vnode and the mapping */
			vn.view = mycomponent;
			_nodeViewToVNodeMap[mycomponent] = vn;
			
			/* we need to invalidate the display list since
			* we created new children */
			refresh();
			
			return mycomponent;
		}
		
		/**
		 * Remove a "view" object (UIComponent) for the given node and specify whether
		 * this should honor any specified add/remove effects.
		 * These methods are only exported to be used by
		 * the VisualNode. Alas, AS does not provide the "friend" directive.
		 * Not sure how to get around this problem right now.
		 * @param component The UIComponent to be removed.
		 * @param honorEffect To specify whether the effect should be applied or not.
		 * */
		private function removeNodeView(component:UIComponent, honorEffect:Boolean = true):void {
			
			var vn:IVisualNode;
			
			/* if there is an effect, start the effect and register a
			* handler that actually calls this method again, but
			* with honorEffect set to false */
			if(honorEffect && (removeItemEffect != null)) {
				removeItemEffect.addEventListener(EffectEvent.EFFECT_END,
					removeEffectDone);
				removeItemEffect.createInstance(component).startEffect();
			} else {
				/* remove the component from it's parent (which should be the canvas) */
				if(component.parent != null) {
					component.parent.removeChild(component);
				}
				
				/* remove event mouse listeners */
				component.removeEventListener( MouseEvent.DOUBLE_CLICK, nodeDoubleClick );
				component.removeEventListener( MouseEvent.MOUSE_DOWN, nodeMouseDown );
				component.removeEventListener( MouseEvent.ROLL_OVER, nodeRollOver );
				component.removeEventListener( MouseEvent.ROLL_OUT, nodeRollOut );
				//component.removeEventListener( MouseEvent.CLICK, nodeClick );
				
				/* get the associated VNode and remove the view from it
				* and also remove the map entry */
				vn = _nodeViewToVNodeMap[component];
				vn.view = null;
				delete _nodeViewToVNodeMap[component];
			}
		}
		
		/**
		 * Create a "view" object (UIComponent) for the given edge and
		 * return it.
		 * @param ve The edge to replace/add a view object.
		 * @return The created view object.
		 * */
		private function createVEdgeLabelView( ve : IVisualEdge ) : UIComponent
		{
			var mycomponent:UIComponent = null;
			
			if ( _edgeLabelRendererFactory != null )
			{
				mycomponent = _edgeLabelRendererFactory.newInstance();
			} 
			else
			{
				/* this is only for the basic default */
				mycomponent = new TextEdgeLabelRenderer(); 
			}			
			
			/* assigns the edge to the IDataRenderer part of the view
			* this is important to access the data object of the VEdge
			* which contains information for rendering. */		
			if(mycomponent is IDataRenderer) {
				(mycomponent as IDataRenderer).data = ve;
			}
			
			/* enable bitmap cachine if required */
			mycomponent.cacheAsBitmap = cacheRendererObjects;
			mycomponent.doubleClickEnabled = true;
			
			mycomponent.addEventListener( MouseEvent.CLICK, edgeClicked );
			mycomponent.addEventListener( MouseEvent.ROLL_OVER, edgeRollOver );
			mycomponent.addEventListener( MouseEvent.ROLL_OUT, edgeRollOut );
			mycomponent.addEventListener( MouseEvent.DOUBLE_CLICK, edgeDoubleClick );
			
			/* add the component to its parent component
			* this can create problems, we have to see where we
			* check for all children
			* Add after the edges layer, but below all other elements such as nodes */
			edgeLabelLayer.addChild(mycomponent);
			
			ve.labelView = mycomponent;
			_edgeLabelViewToVEdgeMap[mycomponent] = ve;
			
			/* we need to invalidate the display list since
			* we created new children */
			refresh();
			
			return mycomponent;
		}
		
		/**
		 * Remove a "view" object (UIComponent) for the given edge.
		 * @param component The UIComponent to be removed.
		 * */
		private function removeVEdgeLabelView(component:UIComponent):void {
			
			var ve:IVisualEdge;
			
			
			/* remove the component from it's parent (which should be the canvas) */
			if(component.parent != null) {
				component.parent.removeChild(component);
			}
			
			component.removeEventListener( MouseEvent.CLICK, edgeClicked );
			component.removeEventListener( MouseEvent.ROLL_OVER, edgeRollOver );
			component.removeEventListener( MouseEvent.ROLL_OUT, edgeRollOut );
			component.removeEventListener( MouseEvent.DOUBLE_CLICK, edgeDoubleClick );
			
			/* get the associated VEdge and remove the view from it
			* and also remove the map entry */
			ve = _edgeLabelViewToVEdgeMap[component];
			ve.labelView = null;
			delete _edgeLabelViewToVEdgeMap[component];
		}
		
		private function getSimilarEdges( ve : IVisualEdge ) : Vector.<IEdge>
		{
			var edge          : IEdge
			var edges : Vector.<IEdge> = new Vector.<IEdge>();
			
			//Перебираем ребра в обратном порядке, т.к. последние всегда в начале
			for ( var i : int = _graph.edges.length - 1; i >= 0; i -- )  
			{
				edge = _graph.edges[ i ];
				
				//В одну сторону
				var direction1 : Boolean = ( edge.node1 == ve.edge.node1 ) && ( edge.node2 == ve.edge.node2 );
				//В другую сторону
				var direction2 : Boolean = ( edge.node1 == ve.edge.node2 ) && ( edge.node2 == ve.edge.node1 );
				
				if ( direction1 || direction2 ) 
				{
					/*
					similarEdgeNo ++;
					
					if ( ve.edge == edge )
					{
						break;
					}
					*/
					
					edges.push( edge );
				}
			}
			
			return edges;
		}
		
		/**
		 * Create a "view" object (UIComponent) for the given edge and
		 * return it.
		 * @param ve The edge to replace/add a view object.
		 * @return The created view object.
		 * */
		private function createVEdgeView(ve:IVisualEdge):IEdgeRenderer {
			
			//Проверяем есть ли уже такие связи
			//Если есть их необходимо рендерить по особому
			//Также узнаем номер связи
			var similarEdges  : Vector.<IEdge> = getSimilarEdges( ve );
			var similarEdgeNo : int            = similarEdges.indexOf( ve.edge );
			
			var mycomponent : IEdgeRenderer = null;
			
			//Ребер связывающих два узла (один или это первая связь из нескольких)
			if ( similarEdgeNo <= 0 )
			{
				if(_edgeRendererFactory != null) {
					mycomponent = edgeRendererFactory.newInstance();
				} else {
					/* this is only for the basic default */
					mycomponent = new BaseEdgeRenderer(); // this is our default label.
				}
			} //Ребер связывающих два узла (несколько)
			else
			{
				mycomponent = new DirectedCurveEdgeRenderer();
				ve.data[ 'depth' ]       = Math.ceil( similarEdgeNo / 2 ); 
				ve.data[ 'orientation' ] = ( ( similarEdgeNo + 1 ) % 2 ) == 0 ? EdgeOrientation.TOP : EdgeOrientation.BOTTOM; 
			}
			
			UIComponent( mycomponent ).doubleClickEnabled = true;
			
			mycomponent.addEventListener( MouseEvent.DOUBLE_CLICK, edgeDoubleClick );
			mycomponent.addEventListener( MouseEvent.CLICK, edgeClicked );
			mycomponent.addEventListener( MouseEvent.ROLL_OVER, edgeRollOver );
			mycomponent.addEventListener( MouseEvent.ROLL_OUT, edgeRollOut );
			
			/* assigns the edge to the IDataRenderer part of the view
			* this is important to access the data object of the VEdge
			* which contains information for rendering. */		
			if(mycomponent is IDataRenderer) {
				(mycomponent as IDataRenderer).data = ve;
			}
			
			/* enable bitmap cachine if required */
			mycomponent.cacheAsBitmap = cacheRendererObjects;
			
			/* add the component to its parent component
			* this can create problems, we have to see where we
			* check for all children
			* Add after the edges layer, but below all other elements such as nodes */
			edgeLayer.addChild(DisplayObject(mycomponent));
			
			ve.edgeView = mycomponent;
			_edgeViewToVEdgeMap[mycomponent] = ve;
			
			/* we need to invalidate the display list since
			* we created new children */
			refresh();
			
			return mycomponent;
		}
		
		/**
		 * Remove a "view" object (UIComponent) for the given edge.
		 * @param component The UIComponent to be removed.
		 * */
		private function removeVEdgeView(component:IEdgeRenderer):void {
			
			var ve:IVisualEdge;
			
			component.removeEventListener( MouseEvent.DOUBLE_CLICK, edgeDoubleClick );
			component.removeEventListener( MouseEvent.CLICK, edgeClicked );
			component.removeEventListener( MouseEvent.ROLL_OVER, edgeRollOver );
			component.removeEventListener( MouseEvent.ROLL_OUT, edgeRollOut );
			
			/* remove the component from it's parent (which should be the canvas) */
			if(component.parent != null) {
				component.parent.removeChild(DisplayObject(component));
			}
			
			/* get the associated VEdge and remove the view from it
			* and also remove the map entry */
			ve = _edgeViewToVEdgeMap[component];
			ve.edgeView = null;
			delete _edgeViewToVEdgeMap[component];
		}
		
		
		/**
		 * Event handler for a removal node procedure. Calls
		 * removeComponent with a flag to avoid doing the effect again.
		 * */
		private function removeEffectDone(event:EffectEvent):void {
			var mycomponent:UIComponent = event.effectInstance.target as UIComponent;
			/* call remove component again, but specify to ignore the effect */
			removeNodeView(mycomponent, false);
		}
		
		/**
		 * This needs to walk through all nodes in the graph, as some nodes
		 * have become invisible and other have become visible. There may be
		 * a better way to do this, when adjusting the visibility but it is
		 * not that clear.
		 * 
		 * walk through the graph and the limitedGraph and
		 * turn off visibility for those that are not listed in
		 * both
		 * beware that the limited graph has no VItems, so 
		 * we don't really need it, we would rather need
		 * an array of node ids....
		 * */
		private function updateVisibility():void {
			var n:INode;
			var e:IEdge;
			var edges:Array;
			var treeparents:Dictionary;
			var vn:IVisualNode;
			var vno:IVisualNode;
			
			var newVisibleNodes:Dictionary;
			var potentialInvisibleNodes:Dictionary;
			
			/* since a layouter that uses timer based iterations
			* might find itself on a changing node set, we need
			* to stop/reset anything before altering the node
			* visibility */
			if ( lastLayouter ) {
				_complexLayouter.resetAll();
			}
			
			/* and all new visible nodes to visible */
			for each( vn in _vnodes ) {
				setNodeVisibility(vn, true);
			}
			
			/* and all new visible nodes to visible */
			for each( vn in _vnodes ) {
				updateConnectedEdgesVisibility(vn);
			}
		}
		
		/**
		 * This methods walks through all nodes and updates
		 * the edge visibility (only the edge visibility)
		 * taking into account three factors:
		 * visibility of adjacent nodes and
		 * if we want edge labels or not at all
		 * */
		private function updateEdgeVisibility():void {
			
			var vn:IVisualNode;
			
			for each( vn in _vnodes ) {
				updateConnectedEdgesVisibility(vn);
			}
		}
		
		/**
		 * Reset visibility of all nodes, all nodes are INVISIBLE.
		 * */
		private function setAllInVisible():void {
			
			var vn:IVisualNode;			
			var ve:IVisualEdge;
			
			/* not sure if this is really, really needed, but
			* since similar code was added, I optimise it a bit.
			*/
			if(_graph == null) {
				return;
			}
			
			/* since a layouter that uses timer based iterations
			* might find itself on a changing node set, we need
			* to stop/reset anything before altering the node
			* visibility */
			if ( lastLayouter ) {
				_complexLayouter.resetAll();
			}
			
			for each( vn in _vnodes ) {
				setNodeVisibility(vn, false);
			}
			
			for each( ve in _vedges ) {
				setEdgeVisibility(ve, false);
			}
		}
		
		/**
		 * Reset visibility of all edges to INVISIBLE.
		 * */
		private function setAllEdgesInVisible():void {
			var ve:IVisualEdge;
			
			for each(ve in _vedges ) {
				setEdgeVisibility(ve, false);
			}
		}
		
		/**
		 * This sets a VNode visible or invisible, updating all related
		 * data.
		 * @param vn The VisualNode to be turned invisible or not.
		 * @param visible The indicator if visible or not.
		 * */
		private function setNodeVisibility(vn:IVisualNode, visible:Boolean):void {
			
			var comp:UIComponent;
			
			/* was there actually a change, if not issue a warning */
			/*if ( vn.isVisible == visible ) {
				return;
			}*/
			
			if ( visible )
			{
				/* create the node's view */
				comp = createVNodeComponent(vn);
			} 
			else
			{ 
				// i.e. set to invisible 
				deleteVisibleVNode(vn);
			}
		}
		
		
		/**
		 * This sets a VEdge visible or invisible, updating all related
		 * data.
		 * @param ve The VisualEdge to be turned invisible or not.
		 * @param visible The indicator if visible or not.
		 * */	
		private function setEdgeVisibility(ve:IVisualEdge, visible:Boolean):void {
			
			var labelComp:UIComponent;
			var edgeComp:IEdgeRenderer;
			
			/* was there actually a change, if not issue a warning */
			//if(ve.isVisible == visible) {
				//LogUtil.warn(_LOG, "Tried to set vedge:"+ve.id+" visibility to:"+visible.toString()+" but it was already.");
				//return;
			//}
			
			if(visible == true) {
				
				/* check if there is no view and we need one */
				if( displayEdgeLabels && ve.labelView == null) {
					labelComp = createVEdgeLabelView( ve );
				}
				
				if(ve.edgeView == null)
					edgeComp = createVEdgeView(ve);
				
				
			} else { // i.e. set to invisible 
				/* render node invisible, thus potentially destroying its view */
				ve.isVisible = false;
				
				deleteVisibleVEdge(ve);
			}
		}
		
		/**
		 * Включает/выключает видимость всех edgeLabel, VisualEdge 
		 * @param ve The VisualEdge to be turned invisible or not.
		 * @param visible The indicator if visible or not.
		 */		
		private function setEdgeLabelVisibility( ve : IVisualEdge, visible : Boolean ) : void
		{
			if( visible )
			{
				if( ve.labelView == null )
				{
					createVEdgeLabelView( ve );
				}
			}
			else
			{ 
				if ( ve.labelView )
				{
					removeVEdgeLabelView( ve.labelView );	
				}
			}
		}
		
		private function deleteVisibleVEdge(ve:IVisualEdge):void
		{
			ve.isVisible = false;
			
			/* remove the view if there is one */
			if(ve.labelView != null) {
				removeVEdgeLabelView(ve.labelView);
			}
			
			if(ve.edgeView != null) {
				removeVEdgeView(ve.edgeView);
			}
		}
		
		/**
		 * This methods walks through all edges connected
		 * to a node and sets them either visible or invisible
		 * depending on the visibility of the given node and
		 * the node on the other end. An edge is only visible
		 * if both nodes are visible.
		 * @param vn The VisualNode of which connected edges should be updated.
		 * */
		private function updateConnectedEdgesVisibility(vn:IVisualNode):void {
			
			var edges : Vector.<IEdge>;
			var ovn:IVisualNode;
			var e:IEdge;
			
			/* now here we have to test each edges othernode
			* if it is also visible */
			edges = vn.node.inEdges;
			
			/* concat might lead to duplication in the case of
			* undirected graphs... :( not sure how to efficiently
			* only add items which are not there, yet?
			*/
			edges = edges.concat(vn.node.outEdges);
			
			for each(e in edges) {
				
				/* get the other node at the end of the edge */
				ovn = e.othernode(vn.node).vnode;
				
				/* if this node either is still visible or in the
				* list to become visible, then the edge is also
				* visible */
				if(vn.isVisible && ovn.isVisible) {
					setEdgeVisibility(e.vedge,true);
				} else {
					setEdgeVisibility(e.vedge,false);
				}
			}
		}
		
		public function get mode() : int
		{
			return _mode;
		}
		
		public function set mode( value : int ) : void
		{
			if ( value != _mode )
			{
				//unset previous mode
				//SCROLLING
				if ( _mode == VisualGraphMode.SCROLL )
				{
					unsetScrollMode();
				}
				else
				//SELECTION	
				if ( _mode == VisualGraphMode.SELECTION )
				{
					unsetSelectionMode();
				}
				
				_mode = value;
				
				//set new mode
				//SCROLLING
				if ( _mode == VisualGraphMode.SCROLL )
				{
					setScrollMode();
				}
				else
				//SELECTION	
				if ( _mode == VisualGraphMode.SELECTION )
				{
					setSelectionMode();
				}
			}
		}
		
		/*
		start VisualGraphMode.SELECTION support
		*/
		
		/**
		 * Фильтр применяемый к связи при выделении
		 */		
		private static const edgeSelectionFilter : GlowFilter = new GlowFilter( 0x0000FF, 1.0, 6.0, 6.0, 2 );
		
		/**
		 * Фильтр применяемый к связи при на ведении на неё 
		 */		
		private static const edgeRollOverFilter  : GlowFilter = new GlowFilter( 0x0000FF, 0.5, 6.0, 6.0, 3 );
		
		/**
		 * Словарь выбранных узлов 
		 */		
		private var _selectedNodes : Dictionary;
		
		/**
		 * Количество выбранных узлов 
		 */		
		private var _noSelectedNodes : uint;
		
		/**
		 * Словарь выбранных связей 
		 */		
		private var _selectedEdges : Dictionary;
		
		/**
		 * Количество выбранных связей 
		 */		
		private var _noSelectedEdges : uint;
		
		private function setSelectionMode() : void
		{
			addEventListener( MouseEvent.MOUSE_DOWN, onBackgroundSelectionMouseDown );
		}
		
		private function unsetSelectionMode() : void
		{
			removeEventListener( MouseEvent.MOUSE_DOWN, onBackgroundSelectionMouseDown );
		}
		
		public function get selectedNodes() : Dictionary
		{
			return _selectedNodes;
		}
		
		public function set selectedNodes( value : Dictionary ) : void
		{
			clearNodesSelection();
			selectNodes( value );
			sendVisualSelectionChangedEvent( VisualSelectionChangedEvent.SELECTION_CHANGED );
		}
		
		public function get noSelectedNodes() : uint
		{
			return _noSelectedNodes;
		}
		
		/**
		 * Заносит указанный узел в список выбранных и выделяет его визуально
		 * Если указанный узел уже есть в списке, то ничего не происходит  
		 * @param node
		 * 
		 */		
		private function selectNode( node : IVisualNode ) : void
		{
			if ( ! _selectedNodes[ node ] )
			{
				_selectedNodes[ node ] = node;
				_noSelectedNodes ++;
				highlightVNode( node, true, false );
			}
		}
		
		/**
		 * Заносит указанные узлы в список выбранных и выделяет их визуально
		 * Если какой-либо из указанных узлов уже есть в списке, то ничего не происходит  
		 * @param node
		 * 
		 */
		private function selectNodes( nodes : * ) : void
		{
			var vnode : IVisualNode;
			
			for each ( var node : * in nodes )
			{
				vnode = ( node is IVisualNode ) ? node : node.vnode;
				selectNode( vnode );
			}
		}
		
		private function selectAllRelationNodes( node : IVisualNode ) : void
		{
			var t : IGTree = _graph.getTree( node.node );
			
			clearSelection();
			selectNodes( t.nodes );
		}
		
		private function selectAllRelationalEdges( node : IVisualNode ) : void
		{
			var edges : Vector.<IVisualEdge> = new Vector.<IVisualEdge>( node.node.inEdges.length );
			
			for ( var i : int = 0; i < edges.length; i ++ )
			{
				edges[ i ] = node.node.inEdges[ i ].vedge;
			}
			
			clearEdgesSelection();
			selectEdges( edges );
		}
		
		/**
		 * Выделяет указанный узел и снимает выделение со всех остальных выделенных узлов 
		 * @param node
		 * 
		 */		
		private function selectNodeAndClearOther( node : IVisualNode ) : void
		{
			if ( ! _selectedNodes[ node ] )
			{
				clearSelection();
				selectNode( node );
			}
		}
		
		/**
		 * Удаляет выделение всех узлов 
		 * 
		 */		
		private function clearNodesSelection() : void
		{
			//Снимаем визуальное выделение со всех выбранных узлов
			for each( var node : IVisualNode in _selectedNodes )
			{
				unhighlightVNode( node, true );
			}
			
			_selectedNodes = new Dictionary();
			_noSelectedNodes = 0;
		}
		
		/**
		 *  Корректно снимает визуальное выделение с узла
		 *  
		 */		
		private function unhighlightVNode( node : IVisualNode, checkHovered : Boolean ) : void
		{
			if ( node.view )
			{
				//Проверяем находится ли курсор над узлом в данный момент
				if ( checkHovered && node.view.hitTestPoint( stage.mouseX, stage.mouseY ) )
				{
					highlightVNode( node, false, true )
				}
				else
				{
					highlightVNode( node, false, false );
				}
			}
		}
		
		/**
		 * Корректно устанавливает визуальное выделение узла 
		 * @param node
		 * 
		 */		
		private function highlightVNode( node : IVisualNode, selected : Boolean, hovered : Boolean ) : void
		{
			if ( node.view )
			{
				var nodeRenderer : INodeRenderer = node.view as INodeRenderer;
				
				if ( nodeRenderer )
				{
					nodeRenderer.selected = selected;
					nodeRenderer.hovered  = hovered;
				}
			}
		}
		
		/**
		 * Удаляет указанный узел из списка выбранных и отключает его выделение
		 * Если указанный узел уже есть в списке, то ничего не происходит 
		 * @param node
		 * 
		 */		
		private function unselectNode( node : IVisualNode ) : void
		{
			if ( _selectedNodes[ node ] )
			{
				delete _selectedNodes[ node ];
				_noSelectedNodes --;
			    unhighlightVNode( node, true );
			}
		}
		
		/**
		 * Выбирает все узлы в указанной области
		 * @param rect
		 * 
		 */		
		private function selectNodesUnderRect( rect : Rectangle ) : void
		{
			var rectNodes : Vector.<IVisualNode> = new Vector.<IVisualNode>();
			
			for each( var node : IVisualNode in _vnodes )
			{
				if ( node.isVisible )
				{
					//Под выделение попадает связь
					if ( HitTestUtils.rectIntersectsObject( DisplayObject( node.view ), rect ) )
					{
						rectNodes.push( node );
					}
				} 
			}
			
			selectNodes( rectNodes );
		}
		
		/**
		 * Очищает выделение всех узлов и связей 
		 * 
		 */		
		public function clearSelection() : void
		{
			clearNodesSelection();
			clearEdgesSelection();
		}
		
		/**
		 * Выделяет все узлы и связи 
		 * 
		 */		
		public function selectAll() : void
		{
			selectNodes( vnodes );
			selectEdges( vedges );
		}
		
		/**
		 * Удаляет все выделенные узлы и связи 
		 * 
		 */		
		public function removeSelected() : void
		{
			//Если выбран хотя-бы один узел или связь
			if ( _noSelectedNodes > 0 || _noSelectedEdges > 0 )
			{
				//Добавляем действие в историю
				var operation : RemoveSelectedObjects = new RemoveSelectedObjects( this );
				    operation.dumpBefore(); 
					
				//Удаляем связи
				if ( _features.isAllow( IShowFeatures.REMOVE_EDGE ) )
				{
					removeSelectedEdges();
				}
					
				//Удаляем узлы
				if ( _features.isAllow( IShowFeatures.REMOVE_NODE ) )
				{
					removeSelectedNodes();
				}
				
				 operation.dumpAfter();
				 History.add( operation );
					
				dispatchEvent( new VisualGraphEvent( VisualGraphEvent.DELETE ) );	
			}
		}
		
		/**
		 * Удаляет все выбранные связи 
		 * 
		 */		
		public function removeSelectedEdges() : void
		{
			//Удаляем связи
			var edge : IVisualEdge;
			
			for each( edge in _selectedEdges )
			{
				removeEdge( edge );
				delete _selectedEdges[ edge ];
				_noSelectedEdges --;
			}
		}
		
		/**
		 * Удаляет все выбранные узлы 
		 * 
		 */		
		public function removeSelectedNodes() : void
		{
			//Удаляем узлы
			var node : IVisualNode;
			
			for each( node in _selectedNodes )
			{
				removeNode( node );
				delete _selectedNodes[ node ];
				_noSelectedNodes --;
			}
			
			correctNodesPositionAndBounds();
		}
		
		/**
		 * Выбирает все узлы и связи под прямоугольником 
		 * @param rect
		 * 
		 */		
		private function selectUnderRect( rect : Rectangle, clear : Boolean ) : void
		{
			if ( clear )
			{
				clearSelection();	
			}
			
			selectNodesUnderRect( rect );
			selectEdgesUnderRect( rect );
		}
		
		public function get selectedEdges() : Dictionary
		{
			return _selectedEdges;
		}
		
		public function set selectedEdges( value : Dictionary ) : void
		{
			clearEdgesSelection();
			selectEdges( value );
		}
		
		public function get noSelectedEdges() : uint
		{
			return _noSelectedEdges;
		}
		
		/**
		 * Заносит указанную связь в список выбранных и выделяет его визуально
		 * Если указанная связь уже есть в списке, то ничего не происходит  
		 * @param edge
		 * 
		 */		
		private function selectEdge( edge : IVisualEdge ) : void
		{
			if ( ! _selectedEdges[ edge ] )
			{
				_selectedEdges[ edge ] = edge;
				_noSelectedEdges ++;
				highlightVEdge( edge, edgeSelectionFilter );
			}
		}
		
		/**
		 * Заносит указанные связи в список выбранных и выделяет их визуально
		 * Если указанные связи уже есть в списке, то ничего не происходит  
		 * @param edges
		 * 
		 */		
		private function selectEdges( edges : * ) : void
		{
			for each( var edge : IVisualEdge in edges )
			{
				selectEdge( edge );
			}
		}
		
		/**
		 * Выделяет указанный узел и снимает выделение со всех остальных выделенных узлов 
		 * @param node
		 * 
		 */		
		private function selectEdgeAndClearOther( edge : IVisualEdge ) : void
		{
			if ( ! _selectedEdges[ edge ] )
			{
				clearSelection();
				selectEdge( edge );
			}
		}
		
		/**
		 * Удаляет выделение всех связей 
		 * 
		 */		
		private function clearEdgesSelection() : void
		{
			//Снимаем визуальное выделение со всех выбранных узлов
			for each( var edge : IVisualEdge in _selectedEdges )
			{
				unhighlightVEdge( edge, false );
			}
			
			_selectedEdges = new Dictionary();
			_noSelectedEdges = 0;
		}
		
		/**
		 * Корректно устанавливает визуальное выделение связи 
		 * @param node
		 * 
		 */		
		private function highlightVEdge( edge : IVisualEdge, filter : Object ) : void
		{
			if ( edge.edgeView )
			{
				edge.edgeView.filters = [ filter ];
			}
			/*
			if ( edge.labelView )
			{
				edge.labelView.filters = [ filter ];
			}*/
		}
		
		/**
		 *  Корректно снимает визуальное выделение со связи
		 *  
		 */		
		private function unhighlightVEdge( edge : IVisualEdge, checkHovered : Boolean ) : void
		{
			if ( edge.edgeView )
			{
				var hovered : Boolean;
				
				if ( checkHovered )
				{
					hovered = edge.edgeView.hitTestPoint( stage.mouseX, stage.mouseY );
					
					if ( ! hovered && edge.labelView )
					{
						hovered = edge.labelView.hitTestPoint( stage.mouseX, stage.mouseY );
					}
				}
				
				//Проверяем находится ли курсор над узлом в данный момент
				if ( hovered )
				{
					edge.edgeView.filters = [ edgeRollOverFilter ];
					/*
					if ( edge.labelView )
					{
						edge.labelView.filters = [ edgeRollOverFilter ];
					}*/
				}
				else
				{
					edge.edgeView.filters = null;
					/*
					if ( edge.labelView )
					{
						edge.labelView.filters = null;
					}*/
				}
			}
		}
		
		/**
		 * Удаляет указанную связь из списка выбранных и отключает её выделение
		 * Если указанная связь уже есть в списке, то ничего не происходит 
		 * @param node
		 * 
		 */		
		private function unselectEdge( edge : IVisualEdge ) : void
		{
			if ( _selectedEdges[ edge ] )
			{
				delete _selectedEdges[ edge ];
				_noSelectedEdges --;
				unhighlightVEdge( edge, true );
			}
		}
		
		/**
		 * Выбирает все узлы в указанной области
		 * Отменяет выделение всех узлов не попавших в эту область 
		 * @param rect
		 * 
		 */		
		private function selectEdgesUnderRect( rect : Rectangle ) : void
		{
			var rectEdges : Vector.<IVisualEdge> = new Vector.<IVisualEdge>();
			
			edgeLayer.graphics.clear();
			
			for each( var edge : IVisualEdge in _vedges )
			{
				if ( edge.isVisible )
				{
					//Под выделение попадает связь
					if ( HitTestUtils.rectIntersectsObjectComplex( DisplayObject( edge.edgeView ), rect ) )
					{
						rectEdges.push( edge );
					} //Под выделение попадает label связи
					else
					if ( edge.labelView != null && HitTestUtils.rectIntersectsObject( DisplayObject( edge.labelView ), rect ) )
					{
					  rectEdges.push( edge );	
					}
				}
			}
			
			selectEdges( rectEdges );
		}
		
		/* begin mouse node interaction */
		
		/**
		 * При щелчке отменяем выделение всех узлов и связей 
		 * @param e
		 * 
		 */		
		private function onBackgroundSelectionMouseDown( e : MouseEvent ) : void
		{
			if ( nodesSelectionDisabled )
			{
				return;
			}
			
			//Работает только при щелчке на пустой области
			if ( e.target != this )
			{
				return;
			}
			
			_actionInitiatorEvent = e;
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onBackgroundRectSelectionMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_UP, onBackgroundRectSelectionMouseUp );
			
			//При нажатой клавише shift или ctrl - не работает
			if ( e.ctrlKey || e.shiftKey )
			{
				return;
			}
			
			clearSelection();
			sendVisualSelectionChangedEvent( VisualSelectionChangedEvent.SELECTION_CHANGED );
		}
		
		/**
		 * Обработка события "Двойной щелчок на узле"
		 * */
		private function nodeDoubleClick( e : MouseEvent ) : void
		{
			if ( _mode != VisualGraphMode.SELECTION )
			{
				return;
			}
			
			if ( _features.isDenied( IShowFeatures.NODE_PROPERTIES ) )
			{
				return;
			}
			
			var view : UIComponent = UIComponent( e.currentTarget );
			var node : IVisualNode = _nodeViewToVNodeMap[ view ];
			
			dispatchEvent( new VisualNodeEvent( VisualNodeEvent.DOUBLE_CLICK, e, node ) );
		}
		
		/*
		При щелчке на кнопке раскрытия
		*/
		private function nodeExpandClick( e : VisualNodeEvent ) : void
		{
			dispatchEvent( e );
		}
		
		/**
		 * При щелчке на кнопке "Открыть карточку объекта" 
		 * @param e
		 * 
		 */		
		private function nodeOpenCardClick( e : VisualNodeEvent ) : void
		{
			dispatchEvent( e );
		}
		
		/**
		 * This is the event handler for a mouse down event on a node
		 * event. Currently does only one thing:
		 * - Starts a drag operation of this node.
		 * @param e The associated event.
		 * */
		private function nodeMouseDown( e : MouseEvent ) : void
		{
			if ( nodesSelectionDisabled )
			{
				return;
			}
			
			var view : UIComponent = UIComponent( e.currentTarget );
			var node : IVisualNode = _nodeViewToVNodeMap[ view ];
			
			
			handleNodeSelection( node, e );
			
			dragBegin( node, e );
		}
		
		/**
		 * Генерирует событие изменения связанные с выделением 
		 * 
		 */		
		private function sendVisualSelectionChangedEvent( type : String ) : void
		{
			dispatchEvent( new VisualSelectionChangedEvent( type, _selectedNodes, _selectedEdges, _noSelectedNodes, _noSelectedEdges ) );
		}
		
		/**
		 * 
		 * @param node
		 * @param e
		 * 
		 */		
		private function handleNodeSelection( node : IVisualNode, e : MouseEvent ) : void
		{
			//При нажатой клавише ctrl, 
			//если узел выделен, снимаем выделение
			//если узел не выделен - устанавливаем
			//При этом, не снимается выделение с других узлов
			if ( e.ctrlKey )
			{
				if ( _selectedNodes[ node ] )
				{
					unselectNode( node );
				}
				else
				{
					selectNode( node );
				}
				
				sendVisualSelectionChangedEvent( VisualSelectionChangedEvent.SELECTION_CHANGED );
				
				return;
			}
			//При нажатой клавише shift,
			//если узел не выделен - устанавливаем
			//если узел выделен - ничего не делаем
			//При этом, не снимается выделение с других узлов
			if ( e.shiftKey )
			{
				selectNode( node );
				sendVisualSelectionChangedEvent( VisualSelectionChangedEvent.SELECTION_CHANGED );
				
				return;
			}
			//Если при щелчке контрольные клавиши не удерживались, то
			//выделяем узел, если он ещё не выделен
			//снимаем выделение, со всех остальных узлов
			else
			{
				selectNodeAndClearOther( node );
				sendVisualSelectionChangedEvent( VisualSelectionChangedEvent.SELECTION_CHANGED );
			}
		}
		
		private function nodeRollOver( e : MouseEvent ) : void
		{
			if ( nodesSelectionDisabled )
			{
				//Для предотвращения интерактива с узлами во время каких-либо действий
				e.stopImmediatePropagation();
			}
			
			if ( nodesHighlightingDisabled )
			{
				return;
			}
			
			var view : UIComponent = UIComponent( e.currentTarget );
			var node : IVisualNode = _nodeViewToVNodeMap[ view ]; 
			
			if ( node )
			{
				if ( ! _selectedNodes[ node ] )
				{
					highlightVNode( node, false, true );	
				}
			}
			
			nodeLayer.setChildIndex( view, nodeLayer.numChildren - 1 );
		}
		
		private function nodeRollOut( e : MouseEvent ) : void
		{
			if ( nodesSelectionDisabled )
			{
				//Для предотвращения интерактива с узлами во время каких-либо действий
				e.stopImmediatePropagation();
			}
			
			if ( nodesHighlightingDisabled )
			{
				return;
			}
			
			var view : UIComponent = UIComponent( e.currentTarget );
			var node : IVisualNode = _nodeViewToVNodeMap[ view ]; 
			
			if ( node )
			{
				if ( ! _selectedNodes[ node ] )
				{
					unhighlightVNode( node, false );	
				}
			}
		}
		
		/**
		 * Определяет, доступно ли в данный момент подсвечивание связей при наведении 
		 * @return 
		 * 
		 */		
		private function get edgesHighlightingDisabled() : Boolean
		{
			return _mode != VisualGraphMode.SELECTION || _rectSelection || _nodesDragging || _creatingEdge;
		}
		
		/**
		 * Определяет, доступно ли в данный момент подсвечивание узлов при наведении 
		 * @return 
		 * 
		 */		
		private function get nodesHighlightingDisabled() : Boolean
		{
			return _mode != VisualGraphMode.SELECTION || _rectSelection || _nodesDragging;
		}
		
		/**
		 * Определяет доступно ли в данный момент выделение узлов щелчком мыши
		 * @return 
		 * 
		 */		
		private function get nodesSelectionDisabled() : Boolean
		{
			return _mode != VisualGraphMode.SELECTION || _rectSelection || _nodesDragging || _creatingEdge;
		}
		
		/**
		 * Определяет доступно ли в данный момент выделение связей щелчком мыши
		 * @return 
		 * 
		 */		
		private function get edgesSelectionDisabled() : Boolean
		{
			return _mode != VisualGraphMode.SELECTION || _rectSelection || _nodesDragging || _creatingEdge;
		}
		
		/* end mouse node interaction */
		
		/* begin mouse node rect selection interaction */
		
		/**
		 * Цвет заливки рамки 
		 */		
		private static const RECT_SELECTION_FILL_COLOR : uint = 0x0000FF;
		/**
		 * Прозрачность заливки рамки 
		 */		
		private static const RECT_SELECTION_FILL_ALPHA : Number = 0.25;
		/**
		 * Цвет контура рамки 
		 */
		private static const RECT_SELECTION_BORDER_COLOR : uint = 0x0000FF;
		/**
		 * Прозрачность контура рамки 
		 */
		private static const RECT_SELECTION_BORDER_ALPHA : Number = 0.5;
		/**
		 * Толщина контура рамки 
		 */		
		private static const RECT_SELECTION_BORDER_THICKNESS : Number = 1.0;
		
		/**
		 * Определяет идет ли в данный момент выделение рамочкой 
		 */		
		private var _rectSelection : Boolean;
		
		/**
		 * Слой предназначенный для отрисовки выделяющей рамки
		 */		
		private var _selectionRectLayer : Shape;
		
		/**
		 * Точка относительно которой началось выделение 
		 */		
		private var _selectionRectStartPont : Point;
		
		/**
		 * Прямоугольная область выделенеия
		 */		
		private var _selectionRect : Rectangle;
		
		private function onBackgroundRectSelectionMouseMove( e : MouseEvent ) : void
		{
			if ( _rectSelection )
			{
				var p : Point = _selectionRectLayer.globalToLocal( new Point( e.stageX, e.stageY ) );
				
				_selectionRect.left   = Math.min( _selectionRectStartPont.x, p.x );
				_selectionRect.top    = Math.min( _selectionRectStartPont.y, p.y );
				_selectionRect.right  = Math.max( _selectionRectStartPont.x, p.x );
				_selectionRect.bottom = Math.max( _selectionRectStartPont.y, p.y );
				
				var g : Graphics = _selectionRectLayer.graphics;
				    g.clear();
					
					g.lineStyle( RECT_SELECTION_BORDER_THICKNESS, RECT_SELECTION_BORDER_COLOR, RECT_SELECTION_BORDER_ALPHA );
					g.beginFill( RECT_SELECTION_FILL_COLOR, RECT_SELECTION_FILL_ALPHA );
					g.drawRect( _selectionRect.left, _selectionRect.top, _selectionRect.width - RECT_SELECTION_BORDER_THICKNESS, _selectionRect.height - RECT_SELECTION_BORDER_THICKNESS );
					g.endFill();
					
			   selectUnderRect( _selectionRect, ! e.ctrlKey && ! e.shiftKey );		
			}
			else
			{
				if ( ( Math.abs( _actionInitiatorEvent.stageX - e.stageX ) > START_MOUSE_ACTION_OFFSET ) ||
					( Math.abs( _actionInitiatorEvent.stageY - e.stageY ) > START_MOUSE_ACTION_OFFSET )
				)
				{
					_selectionRectLayer = new Shape();
					_selectionRectLayer.scaleX = _scale;
					_selectionRectLayer.scaleY = _scale;
					addChild( _selectionRectLayer );
					
					_selectionRectStartPont = _selectionRectLayer.globalToLocal( new Point( _actionInitiatorEvent.stageX, _actionInitiatorEvent.stageY ) );
					_selectionRect = new Rectangle();
					
					scrollTracer = new ScrollTracer( this );
					scrollTracer.startTracing();
					
					_rectSelection  = true;
					
					//Вызываем ещё раз этот метод для немедленной перерисовки прямоугольника
					onBackgroundRectSelectionMouseMove( e );
					
					sendVisualSelectionChangedEvent( VisualSelectionChangedEvent.START_RECT_SELECTION );
				}
			}
		}
		
		private function onBackgroundRectSelectionMouseUp( e : MouseEvent ) : void
		{
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onBackgroundRectSelectionMouseMove );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onBackgroundRectSelectionMouseUp );
			
			if ( _rectSelection )
			{
				scrollTracer.stopTracing();
				scrollTracer = null;
				
				removeChild( _selectionRectLayer );
				
				_selectionRectLayer = null;
				_selectionRect = null;
				_selectionRectStartPont = null;
				
				_rectSelection = false;
				
				sendVisualSelectionChangedEvent( VisualSelectionChangedEvent.END_RECT_SELECTION );
				sendVisualSelectionChangedEvent( VisualSelectionChangedEvent.SELECTION_CHANGED );
			}
			
			_actionInitiatorEvent = null;
		}
		
		/* end mouse node rect selection interaction */
		
		/* begin mouse edge interaction */
		
		private function edgeDoubleClick( e : MouseEvent ) : void
		{
			if ( _features.isDenied( IShowFeatures.EDGE_PROPERTIES ) )
			{
				return;
			}
			
			var view : UIComponent = UIComponent( e.currentTarget );
			var edge : IVisualEdge = _edgeViewToVEdgeMap[ view ]; //Щелчок на visualEdge.view
			
			if ( ! edge )
			{
				edge = _edgeLabelViewToVEdgeMap[ view ]; //Щелчок на на visualEdgeLabel.view
			}
			
			dispatchEvent( new VisualEdgeEvent( VisualEdgeEvent.DOUBLE_CLICK, edge, e ) );
		}
		
		private function edgeClicked( e : MouseEvent ) : void
		{
			if ( edgesSelectionDisabled )
			{
				return;
			}
			
			var view : UIComponent = UIComponent( e.currentTarget );
			var edge : IVisualEdge = _edgeViewToVEdgeMap[ view ]; //Щелчок на visualEdge.view
			
			if ( ! edge )
			{
				edge = _edgeLabelViewToVEdgeMap[ view ]; //Щелчок на на visualEdgeLabel.view
			}
			
			//При нажатой клавише ctrl, 
			//если узел выделен, снимаем выделение
			//если узел не выделен - устанавливаем
			//При этом, не снимается выделение с других узлов
			if ( e.ctrlKey )
			{
				if ( _selectedEdges[ edge ] )
				{
					unselectEdge( edge );
				}
				else
				{
					selectEdge( edge );
				}
				
				return;
			}
			//При нажатой клавише shift,
			//если узел не выделен - устанавливаем
			//если узел выделен - ничего не делаем
			//При этом, не снимается выделение с других узлов
			if ( e.shiftKey )
			{
				selectEdge( edge );
				return;
			}
				//Если при щелчке контрольные клавиши не удерживались, то
				//выделяем узел, если он ещё не выделен
				//снимаем выделение, со всех остальных узлов
			else
			{
				selectEdgeAndClearOther( edge );
			}
		}
		
		private function edgeRollOver( e : MouseEvent ) : void
		{
			if ( edgesHighlightingDisabled )
			{
				return;
			}
			
			var view : UIComponent = UIComponent( e.currentTarget );
			var edge : IVisualEdge = _edgeViewToVEdgeMap[ view ]; 
			
			if ( ! edge )
			{
				edge = _edgeLabelViewToVEdgeMap[ view ]; //Щелчок на на visualEdgeLabel.view
			}
			
			if ( edge )
			{
				if ( ! _selectedEdges[ edge ] )
				{
					highlightVEdge( edge, edgeRollOverFilter );	
				}
			}
			
			edgeLayer.setChildIndex( DisplayObject( edge.edgeView ), edgeLayer.numChildren - 1 );
			
			if ( edge.labelView )
			{
				edgeLabelLayer.setChildIndex( DisplayObject( edge.labelView ), edgeLabelLayer.numChildren - 1 );
			}
		}
		
		private function edgeRollOut( e : MouseEvent ) : void
		{
			if ( edgesHighlightingDisabled )
			{
				return;
			}
			
			var view : UIComponent = UIComponent( e.currentTarget );
			var edge : IVisualEdge = _edgeViewToVEdgeMap[ view ]; 
			
			if ( ! edge )
			{
				edge = _edgeLabelViewToVEdgeMap[ view ]; //Щелчок на на visualEdgeLabel.view
			}
			
			if ( edge )
			{
				if ( ! _selectedEdges[ edge ] )
				{
					unhighlightVEdge( edge, false );
				}
			}
		}
		
		/* end mouse edge interaction */
		
		/* begin dragging nodes interaction */
		
		/**
		 * Смещение инициирующее процесс перетаскивания или выделение рамочкой
		 */
		private static const START_MOUSE_ACTION_OFFSET : Number = 3.0;
		
		/**
		 * Определяет перетаскивает ли в данный момент пользователь узлы или нет 
		 */		
		private var _nodesDragging : Boolean;
		
		/**
		 * Список перетаскиваемых в данный момент узлов 
		 */		
		private var _dragNodes : Vector.<IVisualNode>;
		
		/**
		 * Операция добавляемая в history, после успешного перетаскивания одного или нескольких узлов
		 */		
		private var moveNodesOperation : MoveNodes;
		
		/**
		 * Узел за который осуществляется перетаскивание в данный момент 
		 */		
		private var _capturedNode : IVisualNode;
		
		/**
		 * Событие инициировавшее перетаскивание 
		 */		
		private var _actionInitiatorEvent : MouseEvent;
		
		/**
		 * Корректировка при перетаскивании узла 
		 */		
		private var _dragOffset : Point;
		
		/**
		 * Объект для автоматической подкрутки отображаемой области при перетаскивании узла за пределы видимости 
		 */		
		private var scrollTracer : ScrollTracer;
		
		/**
		 * Проверяет идет ли процесс анимации в данный момент 
		 * @return 
		 * 
		 */		
		private function get animInProgress() : Boolean
		{
			return lastLayouter && lastLayouter.animInProgress;
		}
		
		private function dragBegin( node : IVisualNode, e : MouseEvent ) : void
		{
			//Запрещаем перетаскивание во время анимации и во время процесса перетаскивания с помощью клавиатуры
			if ( animInProgress || nodesMovingByKeyboard )
			{
				return;
			}
			
			_capturedNode = node;
			_actionInitiatorEvent = e;
			_dragOffset   = new Point( e.localX * _scale, e.localY * _scale );
			
			stage.addEventListener( MouseEvent.MOUSE_MOVE, dragMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_WHEEL, dragMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_UP, dragMouseUp );
			
			_capturedNode.view.dispatchEvent( new MouseEvent( MouseEvent.ROLL_OUT ) );
		}
		
		private function dragMouseMove( e : MouseEvent ) : void
		{
			//Если запустилась анимация
			if ( animInProgress )
			{
				//Завершаем процесс перетаскивания
				cancelDragging();
				return;
			}
			
			var node : IVisualNode;
			
			if ( _nodesDragging )
			{
				var pos : Point = nodeLayer.globalToLocal( new Point( e.stageX - _dragOffset.x, e.stageY - _dragOffset.y ) );
				var dP  : Point = new Point( _grid.snapX( pos.x - _capturedNode.viewX ), _grid.snapY( pos.y - _capturedNode.viewY ) );
				
				for each( node in _dragNodes )
				{
					node.x += dP.x;
					node.y += dP.y;
					
					node.commit();
				}
			}
			else //Пользователь ещё не знает хочет он перетаскивать или нет
			{
				if ( ( Math.abs( _actionInitiatorEvent.stageX - e.stageX ) > START_MOUSE_ACTION_OFFSET ) ||
					 ( Math.abs( _actionInitiatorEvent.stageY - e.stageY ) > START_MOUSE_ACTION_OFFSET )
				)
				{
					//Создаем список перетаскиваемых узлов
					_dragNodes = new Vector.<IVisualNode>();
					
					for each( node in _selectedNodes )
					{
						nodeLayer.setChildIndex( node.view, nodeLayer.numChildren - 1 );
						_dragNodes.push( node );
					}
					
					//Создаем "слепок" узлов до начала перетаскивания
					moveNodesOperation = new MoveNodes( this );
					moveNodesOperation.dumpBefore();
					
					scrollTracer = new ScrollTracer( this );
					scrollTracer.offset = _dragOffset;
					scrollTracer.startTracing();
					
					_nodesDragging = true;
					dispatchEvent( new VisualGraphEvent( VisualGraphEvent.BEGIN_NODES_DRAG ) );
				}

			}
		}
		
		private function dragMouseUp( e : MouseEvent ) : void
		{
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, dragMouseMove );
			stage.removeEventListener( MouseEvent.MOUSE_WHEEL, dragMouseMove );
			stage.removeEventListener( MouseEvent.MOUSE_UP, dragMouseUp );
			
			if ( _nodesDragging )
			{
				scrollTracer.stopTracing();
				scrollTracer = null;
				
				correctNodesPositionAndBounds();
				scrollToNodes( _dragNodes, _capturedNode );
				
				//Если операция перетаскивания не была отменена, из-за анимации
				if ( e )
				{
					//Добавляем слепок после перетаскивания
					moveNodesOperation.dumpAfter();
					//Добавляем действие в историю
					History.add( moveNodesOperation );
					
					moveNodesOperation = null;
				}
				
				_dragNodes = null;
				_nodesDragging = false;
				dispatchEvent( new VisualGraphEvent( VisualGraphEvent.END_NODES_DRAG ) );
				dispatchEvent( new VisualGraphEvent( VisualGraphEvent.NODES_UPDATED ) );
			}
			
			if ( _capturedNode.view.hitTestPoint( e.stageX, e.stageY ) )
			{
				_capturedNode.view.dispatchEvent( new MouseEvent( MouseEvent.ROLL_OVER ) );
			}
			
			_capturedNode = null;
			_dragOffset   = null;
			_actionInitiatorEvent = null;
		}
		
		private function cancelDragging() : void
		{
			if ( _nodesDragging )
			{
				dragMouseUp( null );
			}
		}
		
		/* end dragging nodes interaction */
		
		/*
		end VisualGraphMode.SELECTION support
		*/
		
		/*
		 start VisualGraphMode.SCROLL mode suport
		*/
		
		/**
		 * Определяет прокручивает ли пользователь в данный момент компонент 
		 */		
		private var _backgroundDragInProgress : Boolean;
		
		/**
		 * Стартовая позиция начала прокручивания компонента и предыдущего смещения 
		 */		
		private var _backgroundDragCursorStart : Point;
		
		/**
		 * Идентификатор курсора 
		 */		
		private var _cursorID : int = -1;
	
		
		private function setScrollMode() : void
		{
			addEventListener( MouseEvent.MOUSE_DOWN, onBackgroundMouseDown );
			addEventListener( MouseEvent.ROLL_OVER, onBackgroundRollOver );
			addEventListener( MouseEvent.ROLL_OUT, onBackgroundRollOut );
			
			setHandCursorIfNeed();
		}
		
		private function unsetScrollMode() : void
		{
			removeEventListener( MouseEvent.MOUSE_DOWN, onBackgroundMouseDown );
			removeEventListener( MouseEvent.ROLL_OVER, onBackgroundRollOver );
			removeEventListener( MouseEvent.ROLL_OUT, onBackgroundRollOut );
			
			CursorManager.removeAllCursors();
		}
		
		private function setHandCursorIfNeed() : void
		{
			if ( hitTestPoint( stage.mouseX, stage.mouseY ) )
			{
				setCursor( Assets.HAND_CURSOR );
				return;
			}
			
			cursorManager.removeAllCursors();
		}
		
		private function setCursor( cursorClass : Class ) : void
		{
			cursorManager.setCursor( cursorClass );
			clearCursor();
			_cursorID = cursorManager.currentCursorID;
		}
		
		private function clearCursor() : void
		{
			if ( _cursorID != -1 )
			{
				cursorManager.removeCursor( _cursorID );
				_cursorID = -1;
			}
		}
		
		/**
		 * Нажатие правой клавиши мыши на компоненте
		 * @param e
		 * 
		 */		
		private function onBackgroundMouseDown( e : MouseEvent ) : void
		{
			stage.addEventListener( MouseEvent.MOUSE_UP, onBackgroundMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onBackgroundMouseMove );
			
			_backgroundDragCursorStart = new Point( e.stageX, e.stageY );
			
			setCursor( Assets.HAND_SQUEEZED_CURSOR );
			_backgroundDragInProgress = true;
		}
		
		/**
		 * Пользователь отпускает правую кнопку мыши, завершая скролирование объекта 
		 * @param e
		 * 
		 */		
		private function onBackgroundMouseUp( e : MouseEvent ) : void
		{
			_backgroundDragInProgress = false;
			
			stage.removeEventListener( MouseEvent.MOUSE_UP, onBackgroundMouseUp );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onBackgroundMouseMove );
			
			setHandCursorIfNeed();
		}
		
		/**
		 * Пользователь перемещает курсор мыши с правой нажатой клавишей 
		 * @param e
		 * 
		 */		
		private function onBackgroundMouseMove( e : MouseEvent ) : void
		{
			var dX : Number = _backgroundDragCursorStart.x - e.stageX;
			var dY : Number = _backgroundDragCursorStart.y - e.stageY;
			
			scroll( dX, dY );
			
			_backgroundDragCursorStart = new Point( e.stageX, e.stageY );
		}
		
		/**
		 * Наведение курсора на компонент 
		 * @param e
		 * 
		 */		
		private function onBackgroundRollOver( e : MouseEvent ) : void
		{
			if ( ! _backgroundDragInProgress )
			{
				setHandCursorIfNeed();
			}
		}
		
		/**
		 * Уводим курсор мыши с компонента 
		 * @param e
		 * 
		 */		
		private function onBackgroundRollOut( e : MouseEvent ) : void
		{
			if ( ! _backgroundDragInProgress )
			{
				cursorManager.removeAllCursors();
			}
		}
		
		/*
		end VisualGraphMode.SCROLL mode suport
		*/
		
		/* begin grid support */
		
		private var _grid : VisualGrid;
		
		private var _snapToGrid : Boolean;
		
		public function get snapToGrid() : Boolean
		{
			return _snapToGrid;
		}
		
		public function set snapToGrid( value : Boolean ) : void
		{
			if ( value != _snapToGrid )
			{
				_snapToGrid = value;
				invalidateProperties();
			}
		}
		
		private var _showGrid : Boolean;
		
		public function get showGrid() : Boolean
		{
			return _showGrid;
		}
		
		public function set showGrid( value : Boolean ) : void
		{
			if ( value != _showGrid )
			{
				_showGrid = value;
				invalidateProperties();
			}
		}
		
		/*end grid support */
		
		/*
		start IViewport implementation
		*/
		
		/**
		 * Вычисляет обрамляющую область группы узлов 
		 * @param nodes группа узлов для которых необходимо вычисление, может быть Vector.<IVisualNode> или Vector.<INode> или Dictionary.<INode>
		 * @return прямоугольная область занимаемая узлами
		 * 
		 */		
		public function getNodesGroupBoundsV( nodes : * = null ) : Rectangle
		{
			//Вычисляем обрамляющую область
			var bounds : Rectangle;
			var rect   : Rectangle;
			var view   : UIComponent;
			var obj    : Object;
			
			if ( ! nodes )
			{
				nodes = _vnodes;
			}
			
			for each( obj in nodes )
			{
				view = obj is IVisualNode ? obj.view : obj.vnode.view;
				rect = view.getBounds( view.parent );
				
				if( view.visible )
				{
					if ( bounds )
					{
						bounds.left   = Math.min( bounds.left, rect.left );
						bounds.right  = Math.max( bounds.right, rect.right );
						bounds.top    = Math.min( bounds.top, rect.top )
						bounds.bottom = Math.max( bounds.bottom, rect.bottom );
					}
					else
					{
						bounds = rect;
					}
				}
			}
			
			return bounds;
		}
		
		/**
		 * Если указанный узел или связь не видны на экране, прокручивает так что-бы она была видна 
		 * @param object - IVisualNode или IVisualEdge
		 * 
		 */		
		public function scrollToObject( object : Object ) : void
		{
			var view : UIComponent;
			
			if ( object is IVisualNode )
			{
				view = IVisualNode( object ).view;
			}
			else if ( object is IVisualEdge )
			{
				view = UIComponent( IVisualEdge( object ).edgeView );
			}
			
			var bounds : Rectangle = view.getBounds( view.parent );
			
			horizontalScrollPosition = bounds.x + ( bounds.width - width ) / 2;
			verticalScrollPosition   = bounds.y + ( bounds.height - height ) / 2;
		}
		
		/**
		 * Прокручивает окно таким образом, что-бы указанная группа узлов была видна на экране  
		 * @param nodes
		 * 
		 */		
		public function scrollToNodes( nodes : *, baseNode : IVisualNode = null, usePreBounds : Boolean = false ) : void
		{
			//Если полос прокруток нет, то ничего не делаем
			if ( ! clipAndEnableScrolling )
			{
				return;
			}
			
			//Вычисляем обрамляющую область
			var bounds : Rectangle = usePreBounds ? _complexLayouter.calculateBounds( nodes ) : getNodesGroupBoundsV( nodes );
			
			//Масштабируем с учетом значения scale
			Geometry.scaleRect( bounds, _scale );
			
			//Проверяем все ли  узлы в настоящий момент видны
			if ( scrollRect.containsRect( bounds ) )
			{
				return; //Все видно, ничего не делаем
			}
				
			//Проверяем по каким координатам необходимо прокрутить
			var hspOK : Boolean = ( scrollRect.left < bounds.left ) && ( scrollRect.right  > bounds.right ); 
			var vspOK : Boolean = ( scrollRect.top  < bounds.top  ) && ( scrollRect.bottom > bounds.bottom );
			var delta : Number;
			
			//Прокручиваем горизонтально
			if ( ! hspOK )
			{
				//справа
				if ( bounds.right > scrollRect.right )
				{
					delta = ( bounds.right - scrollRect.right ) + _complexLayouter.paddingRight;					
				}
				else //Слева
				{
					delta = - ( ( scrollRect.left - bounds.left ) + _complexLayouter.paddingLeft );
				}
				
				horizontalScrollPosition += delta;
			}
			
			//Прокручиваем вертикально
			if ( ! vspOK ) 
			{
				//снизу
				if ( bounds.right > scrollRect.right )
				{
					delta = ( bounds.bottom - scrollRect.bottom ) + _complexLayouter.paddingBottom;					
				}
				else //сверху
				{
					delta = - ( ( scrollRect.top - bounds.top ) + _complexLayouter.paddingTop );
				}
				
				verticalScrollPosition += delta;
			}
			
			//Проверяем поместились ли наши узлы на экране
			if ( baseNode )
			{
				//!!!!Написать здесь проверку, помещаются ли все узлы?? 
				//!!!!Только если не помещаются - вызывать этот метод ( оптимизация )
				scrollToNodes( Vector.<IVisualNode>( [ baseNode ] ) );
			}
		}
		
		/**
		 * Смещает все узлы графа на dP 
		 * @param dP
		 * 
		 */		
		private function moveAllNodesTo( dP : Point ) : void
		{
			for each ( var node : IVisualNode in _vnodes )
			{
				node.x += dP.x;
				node.y += dP.y;
				node.commit();
			}
		}
		
		/**
		 * 
		 * Если, имеются узлы с отрицательными значениями x или y, то смещаем все узлы, так что-бы все узлы имели положительные значения
		 * Корректирует прямоугольную область занимаемую компонентом после перетаскивания ( например, если перетаскиваемый узел ушел за границы экрана ) 
		 * 
		 */		
		public function correctNodesPositionAndBounds() : void
		{
			var bounds : Rectangle = getNodesGroupBoundsV( _vnodes );
			
			if ( ! bounds )
			{
				return;
			}
			
			var offset : Point = new Point();
			
			//Если координаты узлов имеют отрицательное значение, то необходимо их сдвинуть
			//для того что-бы все точки имели положительное значение
			
			//Смещение по оси X ( не допускаем уход узлов за границу экрана )
			if ( bounds.x < 0 )
			{
				offset.x = Math.abs( bounds.x );
			}
			/*else if ( horizontalScrollBarEnabled && ( bounds.x > _layouter.paddingLeft ) ) //Если слева остается много свободного пространства - смещаем
			{
				offset.x = _layouter.paddingLeft - bounds.x;
			}*/
			
			//Смещение по оси Y ( не допускаем уход узлов за границу экрана )
			if ( bounds.y < 0 )
			{
				offset.y = Math.abs( bounds.y );
			}
			/*else if ( verticalScrollBarEnabled && ( bounds.y > _layouter.paddingTop ) )
			{
				offset.y = _layouter.paddingTop - bounds.y;
			}*/
			
			//Если смещение имеет место быть - смещаем все узлы
			if ( offset.x != 0 || offset.y != 0 ) //Если сверху остается много свободного пространства - смещаем
			{
				bounds.x += offset.x;
				bounds.y += offset.y;
				moveAllNodesTo(  offset );
			}
			
			//Добавляем отступы, там где это необходимо
			var delta : Number;
			
			//Слева
			if ( bounds.x < _complexLayouter.paddingLeft )
			{
				delta = _complexLayouter.paddingLeft - bounds.x;
				
				bounds.width += delta;
			}
			
			//Сверху
			if ( bounds.y < _complexLayouter.paddingTop )
			{
				delta = _complexLayouter.paddingTop - bounds.y;
				
				bounds.height += delta;
				offset.y      += delta;
			}
			
			//Справа
			delta = width - bounds.right;
			
			if ( delta < _complexLayouter.paddingRight )
			{
				if ( delta < 0 )
				{
					bounds.width += _complexLayouter.paddingRight;
				}
				else
				{
					bounds.width += _complexLayouter.paddingRight - delta;
				}
			}
			
			//Снизу	
			delta = height - bounds.bottom;
			
			if ( delta < _complexLayouter.paddingBottom )
			{
				if ( delta < 0 )
				{
					bounds.height += _complexLayouter.paddingBottom;
				}
				else
				{
					bounds.height += _complexLayouter.paddingBottom - delta;
				}
			}
			
			_bounds = bounds;
			
			fireSizeChaged();
			invalidateDisplayList();
		}
		
		/**
		 * Диспачит события contentWidth changed и contentHeight changed 
		 */		
		private function fireSizeChaged() : void
		{
			dispatchEvent( new PropertyChangeEvent( PropertyChangeEvent.PROPERTY_CHANGE, false, false, null, "contentWidth" ) );
			dispatchEvent( new PropertyChangeEvent( PropertyChangeEvent.PROPERTY_CHANGE, false, false, null, "contentHeight" ) );
		}
		
				
		private function onLayoutUpdated( e : VisualGraphEvent ) : void
		{
			dispatchEvent( new VisualGraphEvent( VisualGraphEvent.NODES_UPDATED ) );
			dispatchEvent( e );
		}
		
		/**
		 * Вызывается при пересчете узлов графа компоновщиком ( layouter ) 
		 * @param e
		 * 
		 */
		private function onLayoutCalculated( e : VisualGraphEvent ) : void
		{
			_bounds = _complexLayouter.bounds;
			
			setCliping( clipAndEnableScrolling );
			
			fireSizeChaged();
			
			dispatchEvent( e );
		}
		
		private var _hsp : Number = 0.0;
		private var _vsp : Number = 0.0;
		
		/**
		 * Прямоугольная область занимая компонентом 
		 */		
		private var _bounds : Rectangle;
		
		/**
		 * Устанавливает размер рабочей области (!!!Внимание только для внутреннего использования!!!) 
		 * @param bounds
		 * 
		 */		
		public function set bounds( value : Rectangle ) : void
		{
			_bounds = value;
			
			fireSizeChaged();
			invalidateDisplayList();
		}
		
		public function get bounds() : Rectangle
		{
			return _bounds;
		}
		
		public function get contentWidth() : Number
		{
			return _bounds ? _bounds.right * _scale : 0;
		}
		
		public function get contentHeight() : Number
		{
		   return _bounds ? _bounds.bottom * _scale : 0;	
		}
		
		public function get horizontalScrollPosition() : Number
		{
			return _hsp;
		}
		
		public function set horizontalScrollPosition( value : Number ) : void
		{
			if ( value != _hsp )
			{
				_hsp = value;
				setCliping( clipAndEnableScrolling );
				dispatchEvent( new PropertyChangeEvent( PropertyChangeEvent.PROPERTY_CHANGE, false, false, null, "horizontalScrollPosition", value, value ) );
			}
		}
		
		public function get verticalScrollPosition() : Number
		{
			return _vsp;
		}
		
		public function set verticalScrollPosition( value : Number ) : void
		{
			if ( value != _vsp )
			{
				_vsp = value;
				setCliping( clipAndEnableScrolling );
				dispatchEvent( new PropertyChangeEvent( PropertyChangeEvent.PROPERTY_CHANGE, false, false, null, "verticalScrollPosition", value, value ) );
			}
		}
		
		public function getHorizontalScrollPositionDelta( navigationUnit : uint ) : Number
		{
			return 0;
		}
		
		public function getVerticalScrollPositionDelta( navigationUnit : uint ) : Number
		{
			return 0;
		}
		
		public function get clipAndEnableScrolling() : Boolean
		{
			return scrollRect != null;
		}
			
		public function set clipAndEnableScrolling( value : Boolean ) : void
		{
			setCliping( value );
		}
		
		private function setCliping( value : Boolean ) : void
		{
			invalidateDisplayList();
			
			if ( value )
			{
				scrollRect = new Rectangle( _hsp, _vsp, width, height );
				return;
			}
			
			scrollRect = null;
		}
		
		/**
		 * Определяет отображается ли горизонтальная полоса прокрутки 
		 * @return 
		 * 
		 */		
		private function get horizontalScrollBarEnabled() : Boolean
		{
			return width < contentWidth;
		}
		
		/**
		 * Определяет отображается ли вертикальная полоса прокрутки 
		 * @return 
		 * 
		 */		
		private function get verticalScrollBarEnabled() : Boolean
		{
			return height < contentHeight;
		}
		
		/*
		end IViewport implementation
		*/
		
		/*
		start right context menu implementation
		Requires Flash Player 11.2 or above!
		*/
		
		/**
		 * Текущее активное меню 
		 */		
		private var _currentMenu       : Menu;
		private var _clickItemListener : Function; 
		
		/**
		 * Проверяем имеет ли объект сгенерировавший событие родственные связи с VisualGraph
		 * @param p   - объект для проверки
		 * @return true - если имеет
		 * 
		 */		
		private function isObjectInWorkArea( obj : DisplayObject ) : Boolean
		{
			while ( obj && ( obj != stage ) )
			{
				if ( obj == this )
				{
					return true;
				}
				
				obj = obj.parent;
			}
			
			return false;
		}
		
		private function setMenuListeners( handler : Function ) : void
		{
			_clickItemListener = handler;
			
			_currentMenu.addEventListener( MenuEvent.ITEM_CLICK, _clickItemListener );
			_currentMenu.addEventListener( MenuEvent.MENU_HIDE, onHideMenu );
		}
		
		private function unsetMenuListeners() : void
		{
			_currentMenu.removeEventListener( MenuEvent.ITEM_CLICK, _clickItemListener );
			_currentMenu.removeEventListener( MenuEvent.MENU_HIDE, onHideMenu );
			
			_clickItemListener = null;
		}
		
		private function onVisualGraphRightClick( e : MouseEvent ) : void
		{
			if ( _mode != VisualGraphMode.SELECTION )
			{
				return;
			}
			
			//Если есть активное меню, удаляем его
			if ( _currentMenu )
			{
				_currentMenu.hide();
			}
			
			if ( isObjectInWorkArea( DisplayObject( e.target ) ) )
			{
				var view : UIComponent = e.target is UIComponent ? UIComponent( e.target ) : UIComponent( e.target.parent );
				var node : IVisualNode;
				var edge : IVisualEdge;
				
				//Идет процесс создания связи между узлами
				if ( _creatingEdge )
				{
					_currentMenu = VisualGraphMenu.createCancelEdgeCreatingMenu();
					setMenuListeners( onClickToItemCancelCreatingEdge );
				}
				else
				//Щелчок на узле
				if ( view is INodeRenderer )
				{
					node = _nodeViewToVNodeMap[ view ];
					
					_currentMenu = VisualGraphMenu.createNodeMenu( node );
					
					if ( _currentMenu )
					 setMenuListeners( onNodeMenuItemClick );
				}
				else
				//Щелчок на связи
				if ( view is IEdgeRenderer )
				{
					edge = _edgeViewToVEdgeMap[ view ];
					
					_currentMenu = VisualGraphMenu.createEdgeMenu( edge );
					
					if ( _currentMenu )
					 setMenuListeners( onEdgeMenuItemClick );
				}
				else
				//Щелчок на метке связи
				if ( view is IEdgeLabelRenderer )
				{
					edge = _edgeLabelViewToVEdgeMap[ view ];
					
					_currentMenu = VisualGraphMenu.createEdgeMenu( edge );
					
					if ( _currentMenu )
					 setMenuListeners( onEdgeMenuItemClick );
				}
				else
				//Щелчок на рабочей области
				if ( e.target == this )
				{
					_currentMenu = VisualGraphMenu.createBackgroundMenu( this );
					
					if ( _currentMenu )
					 setMenuListeners( onBackgroundMenuItemClick );
				}
				
				if ( _currentMenu )
				{
					_currentMenu.show( e.stageX, e.stageY );	
				}
			}
		}
		
		private function onHideMenu( e : MenuEvent ) : void
		{
			unsetMenuListeners();
			_currentMenu = null;
		}
		
		private function onNodeMenuItemClick( e : MenuEvent ) : void
		{
			var node : IVisualNode = IVisualNode( e.item.source );
			
			switch( e.item.id )
			{
				case IShowFeatures.CREATE_EDGE :
					beginCreateEdgeInteraction( node );
				break;
				
				case IShowFeatures.SELECT_ALL_NET_NODES :
					selectAllRelationNodes( e.item.source );
					sendVisualSelectionChangedEvent( VisualSelectionChangedEvent.SELECTION_CHANGED );
				break;
				
				case IShowFeatures.SELECT_ALL_RELATIONAL_EDGES :
					selectAllRelationalEdges( e.item.source );
					break;
				
				case IShowFeatures.REMOVE_NODE :
					
					//Добавляем действие в историю
					var operation : RemoveSelectedObjects = new RemoveSelectedObjects( this );
					    operation.dumpBefore(); 
						
						removeNode( e.item.source );
						
						operation.dumpAfter();
						History.add( operation );
						
						dispatchEvent( new VisualGraphEvent( VisualGraphEvent.DELETE ) );
						
					break;
				
				case IShowFeatures.SET_NODE_AS_ROOT :
					
					//Добавляем действие в историю
					History.add( new ChangeRootNode( this ) );
					
					currentRootVNode = node;
					draw();
					break;
				
				//Все пункты меню не связанные с графом
				default : dispatchEvent( e );
			}
		}
		
		private function onEdgeMenuItemClick( e : MenuEvent ) : void
		{
			var edge : IVisualEdge = IVisualEdge( e.item.source );
			
			switch( e.item.id )
			{
				case IShowFeatures.REMOVE_EDGE :
				    
					var event : VisualGraphRemoveObjectEvent = new VisualGraphRemoveObjectEvent( VisualGraphRemoveObjectEvent.REMOVE_OBJECT, null, [ edge ] );
					
					if ( dispatchEvent( event ) )
					{
						//Перед удаление добавляем это действие в историю
						History.add( new RemoveEdge( this, edge.data ) );
						//Удаляем
						removeEdge( edge );
						dispatchEvent( new VisualGraphEvent( VisualGraphEvent.DELETE ) );
					}
					
					
				break;
				
				//Все пункты меню не связанные с графом
				default : dispatchEvent( e );
			}
		}
		
		private function onBackgroundMenuItemClick( e : MenuEvent ) : void
		{
			switch( e.item.id )
			{
				case IShowFeatures.ZOOM_IN :
					zoomIn();
					break;
				
				case IShowFeatures.ZOOM_OUT :
					zoomOut();
					break;
				
				case IShowFeatures.SELECT_ALL :
					selectAll();
					sendVisualSelectionChangedEvent( VisualSelectionChangedEvent.SELECTION_CHANGED );
					break;
				
				case IShowFeatures.REFRESH :
					History.add( new LayoutParamsChanged( this ) );
					draw();
					break;
				
				//Все пункты меню не связанные с графом
				default : dispatchEvent( e );
			}
		}
		
		/**
		 * При выборе пункта меню, установить корневой узел 
		 * @param node
		 * 
		 */		
		private function setNodeAsRootInteraction( node : IVisualNode ) : void
		{
			
		}
		
		/*
		end right context menu implementation
		*/
		
		/*
		start edge creation interaction
		*/
		
		/**
		 * Стартовый узел связывания 
		 */		
		private var _fromNode : IVisualNode;
		
		/**
		 * Пустышка узел, 
		 */		
		private var _dummyNode : IVisualNode;
		
		/**
		 * Создаваемая в данный момент связь 
		 */		
		private var _newEdge : IVisualEdge;
		
		/**
		 * Указывает, что в данный момент идет процесс создания связи 
		 */		
		private var _creatingEdge : Boolean;
		
		/**
		 * Запкускает процесс интерактивного связывания двух узлов 
		 * @param fromNode - первый узел связывания ( второй выберет пользователь, во время интерактива )
		 * 
		 */		
		private function beginCreateEdgeInteraction( fromNode : IVisualNode ) : void
		{
			_fromNode = fromNode;
			
			_dummyNode = createNode( 'dummyNode', null, null, false );
			_dummyNode.isVisible = true; //Обманываем VisualGraph, пускай думает что nodeRenderer существует
			    
			var mousePos : Point = new Point( nodeLayer.mouseX, nodeLayer.mouseY );
			    
			_dummyNode.x = mousePos.x;
			_dummyNode.y = mousePos.y;
				
			_newEdge = linkNodes( fromNode, _dummyNode );
			
			_creatingEdge = true;
			
			scrollTracer = new ScrollTracer( this );
			scrollTracer.startTracing();
			
			addEventListener( MouseEvent.CLICK, onBackgroundCreatingEdgeClick );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onCreatingNewEdgeMouseMove );
		}
		
		private function cancelCreatingEdgeInteraction() : void
		{
			if ( _creatingEdge )
			{
				removeEdge( _newEdge );
				removeNode( _dummyNode );
				
				endCreatingEdgeInteraction();
			}
		}
		
		private function endCreatingEdgeInteraction() : void
		{
			scrollTracer.stopTracing();
			scrollTracer = null;
			
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onCreatingNewEdgeMouseMove );
			removeEventListener( MouseEvent.CLICK, onBackgroundCreatingEdgeClick );
			
			_dummyNode    = null;
			_newEdge      = null;
			_creatingEdge = false;
		}
		
		private function onBackgroundCreatingEdgeClick( e : MouseEvent ) : void
		{
			var view : UIComponent = UIComponent( e.target );
			var node : IVisualNode = _nodeViewToVNodeMap[ view ];
			
			if ( node )
			{
				if ( node != _fromNode )
				{
					//Генерируем событие, пользователь хочет создать связь
					var event : VisualGraphCreateEdgeEvent = new VisualGraphCreateEdgeEvent( VisualGraphCreateEdgeEvent.CREATE_EDGE, _fromNode, node );
					
					if ( dispatchEvent( event )  )
					{
						var ve : IVisualEdge = linkNodes( _fromNode, node );
						
						//Добавляем событие в историю
						History.add( new CreateEdge( this, ve.data ) );
					}
				}
			}
			
			cancelCreatingEdgeInteraction();
		}
		
		private function onClickToItemCancelCreatingEdge( e : MenuEvent ) : void
		{
			cancelCreatingEdgeInteraction();
		}
		
		private function onCreatingNewEdgeMouseMove( e : MouseEvent ) : void
		{
			var mousePos : Point = nodeLayer.globalToLocal( new Point( e.stageX, e.stageY ) );
			
			    _dummyNode.x = mousePos.x;
				_dummyNode.y = mousePos.y;
				
				_dummyNode.updateReleatedEdges();
		}
		
		/*
		end edge creation interaction
		*/
		
		/*
		start css styles suporting
		*/
		
		override public function stylesInitialized():void
		{
			super.stylesInitialized();
			
			if ( getStyle( 'backgroundFill' ) === undefined ) setStyle( 'backgroundFill', true );
			if ( getStyle( 'backgroundColor' ) === undefined ) setStyle( 'backgroundColor', 0xF5F5F5 );
			if ( getStyle( 'backgroundAlpha' ) === undefined ) setStyle( 'backgroundAlpha', 1.0 );
		}
		
		/*
		end css style suporting
		*/
		
		/**
		 * Сбрасывает весь интерактив связанный с пользователем 
		 * 
		 */		
		public function stopAllUserInteractions() : void
		{
			//Если идет процесс перетаскивания с помощью клавиатуры отменяем его
			cancelMoveNodes();
			//Отменяем процесс перетаскивания узлов мышью
			cancelDragging();
			//Отменяем создание интерактив создания связи
			cancelCreatingEdgeInteraction();
		}
		
		public function vEdgeByStringId( id : String ) : IVisualEdge
		{
			var edge : IEdge = _graph.edgeByStringId( id );
			
			if ( edge ) return edge.vedge;
			
			return null;
		}
		
		public function vNodeByStringId( id : String ) : IVisualNode
		{
			var node : INode = _graph.nodeByStringId( id );
			
			if ( node ) return node.vnode;
			
			return null;
		}
	}
	
}
