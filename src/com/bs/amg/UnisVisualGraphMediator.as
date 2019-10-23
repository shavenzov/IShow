package com.bs.amg
{
	import com.amf.events.AMFErrorEvent;
	import com.amf.events.AMFErrorLayer;
	import com.bs.amg.events.AMGGraphDataEvent;
	import com.bs.amg.features.IShowFeatures;
	import com.bs.amg.tasks.NodeExpandResult;
	import com.bs.amg.tasks.UnisGraphExpander;
	import com.bs.amg.tasks.events.GraphTreeExpandErrorEvent;
	import com.bs.amg.tasks.events.GraphTreeExpandEvent;
	import com.data.SavedObject;
	import com.managers.PopUpManager;
	import com.thread.SimpleTask;
	import com.thread.events.StatusChangedEvent;
	import com.thread.events.TaskEvent;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.MenuEvent;
	import mx.managers.history.History;
	
	import org.un.cava.birdeye.ravis.components.renderers.nodes.INodeRenderer;
	import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.data.NodesAndEdges;
	import org.un.cava.birdeye.ravis.graphLayout.layout.BubbleLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.HierarchicalLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.LayoutOrientation;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualNodeEvent;
	import org.un.cava.birdeye.ravis.history.GraphDataFromRemoteSource;
	
	import ui.search.DepthDialog;

	public class UnisVisualGraphMediator extends SavedObject
	{
		private var vg   : IVisualGraph;
		private var unis : UnisAPIImplementation;
		
		/**
		 * Раскладка для расчета раскрытых узлов 
		 */		
		private var expandLayouter : BubbleLayouter;
		
		/**
		 * Данные получены впервые, во время вызова метода initialize 
		 */		
		private var firstData : Boolean;
		
		/**
		 * Список добавленных узлов 
		 */		
		private var addedNodes : Vector.<INode>;
		
		public function UnisVisualGraphMediator( vg : IVisualGraph )
		{
		  super();
		  
		  this.vg = vg;
		  this.vg.addEventListener( MenuEvent.ITEM_CLICK, onItemClick );
		  this.vg.addEventListener( VisualNodeEvent.EXPAND_CLICK, onExpandButtonClick );
		  this.vg.addEventListener( VisualGraphEvent.DRAW, onVgDraw );
		}
		
		/**
		 * Устанавливает недостающие/не установленные параметры по умолчанию  
		 */		
		override protected function setDefaults() : void
		{
			super.setDefaults();
			
			if ( ! _data.hasOwnProperty( 'useSubExpandLayouter' ) )
			{
				_data.useSubExpandLayouter = false;
			}
			
			if ( ! data.hasOwnProperty( 'depth' ) )
			{
				_data.depth = 1;
			}
		}
		
		override public function set data( value : Object ) : void
		{
			super.data = value;
			
			commitData();
		}
		
		private function commitData() : void
		{
			for ( var prop : String in data )
			{
				this[ prop ] = data[ prop ];
			}
		}
		
		public function get useSubExpandLayouter() : Boolean
		{
			return _data.useSubExpandLayouter;
		}
		
		public function set useSubExpandLayouter( value : Boolean ) : void
		{
			_data.useSubExpandLayouter = value;
			
			save();
		}
		
		public function get depth() : uint
		{
			return _data.depth;
		}
		
		public function set depth( value : uint ) : void
		{
		   _data.depth = value;
		   
		   if ( graphExpander )
		   {
			   graphExpander.depth = value;
		   }
		   
		   save();
		}
		
		private function initAPI( graph : IGraph = null ) : void
		{
			if ( ! graphExpander )
			{
				graphExpander = new UnisGraphExpander( depth, graph );
			}
			else
			{
				graphExpander.depth = depth;
			}
			
			graphExpander.addEventListener( StatusChangedEvent.STATUS_CHANGED, onExpandStatusChanged );
			graphExpander.addEventListener( TaskEvent.START, onExpandOperationStart );
			graphExpander.addEventListener( TaskEvent.COMPLETE, onExpandOperationComplete );
			graphExpander.addEventListener( GraphTreeExpandEvent.EXPANDED, onNodeExpanded );
			graphExpander.addEventListener( GraphTreeExpandErrorEvent.ERROR, onNodeExpandedError );
		}
		
		public function initialize() : void
		{
			unis = UnisAPI.impl;
			
			//Если переданы параметры отображения объекта, по умолчанию, то делаем первый запрос во время загрузки
			if ( unis.params )
			{
				/*if ( unis.params.objectId && unis.params.defaultRootContext )
				{*/
					firstData = true;
					
					switch( unis.mode )
					{
						case ApplicationMode.RELATIONSHIPS : if ( unis.params.objectId && unis.params.defaultRootContext ) { showDepthDialog( 'Укажите глубину поиска цепочек', 2, initRelationshipsMode ) };
							                                 break;
						
						case ApplicationMode.GRAPH : initGraphMode();
							                         break;
						
						default      : if ( unis.params.objectId && unis.params.defaultRootContext ) { /*showDepthDialog( 'Укажите глубину раскрытия объектов', 1, initStandardMode )*/ initStandardMode( 1 ) };
					}
				//}
			}
		}
		
		/*
		start standrard mode implementation
		*/
		
		private var graphExpander : UnisGraphExpander;
		
		private function initStandardMode( depth : int ) : void
		{
			graphExpander = new UnisGraphExpander( depth );
			graphExpander.addEventListener( StatusChangedEvent.STATUS_CHANGED, onExpandStandardModeStatusChanged );
			graphExpander.addEventListener( TaskEvent.COMPLETE, onExpandStandardModeComplete );
			graphExpander.addEventListener( GraphTreeExpandErrorEvent.ERROR, onExpandStandardModeError );
			
			graphExpander.add( unis.params.objectId.split( ',' ) );
			graphExpander.run();
			
			PopUpManager.showLoading( 'Раскрытие объектов...' );
		}
		
		private function onExpandStandardModeStatusChanged( e : StatusChangedEvent ) : void
		{
			PopUpManager.changeLoadingLabel( graphExpander.statusString );
		}
		
		private function onExpandStandardModeError( e : GraphTreeExpandErrorEvent ) : void
		{
			Alert.show( e.message, 'Ошибка' );
		}
		
		private function onExpandStandardModeComplete( e : TaskEvent ) : void
		{
			graphExpander.removeEventListener( StatusChangedEvent.STATUS_CHANGED, onExpandStandardModeStatusChanged );
			graphExpander.removeEventListener( TaskEvent.COMPLETE, onExpandStandardModeComplete );
			graphExpander.removeEventListener( GraphTreeExpandErrorEvent.ERROR, onExpandStandardModeError );
			
			if ( graphExpander.status == SimpleTask.ERROR )
			{
				PopUpManager.changeLoadingLabel( graphExpander.statusString );
			}
			else
			{
				vg.graph = graphExpander.graph;
				vg.initFromGraph();
				
				setRoots( unis.params.objectId );
				
				PopUpManager.hideLoading();
				draw();
				
				initAPI();
				
				firstData = false;
			}
		}
		
		/*
		end standard mode implementation
		*/
		
		private function setRoots( roots : String ) : void
		{
			var rootIds : Array = roots.split( ',' );
			var objId   : String;
			var vnode   : IVisualNode;
			
			for each( objId in rootIds )
			{
				vnode = vg.vNodeByStringId( objId );
				
				if ( vnode )
				{
					vg.currentRootVNode = vnode;
				}
			}
		}
		
		/*
		start relationships mode implementation
		*/
		
		private function initRelationshipsMode( depth : int ) : void
		{
			unis.addListener( AMGGraphDataEvent.GRAPH_DATA, onRelationShipGraphData, this );
			unis.addListener( AMFErrorEvent.ERROR, onRelationShipError, this );
			unis.getRelationships( unis.params.objectId, depth, unis.params.defaultRootContext );
			
			PopUpManager.showLoading( 'Поиск цепочек между объектами...' );
		}
		
		private function onRelationShipGraphData( e : AMGGraphDataEvent ) : void
		{
			unis.removeAllObjectListeners( this );
			
			vg.graph = new Graph();
			vg.graph.safeInitFromVO( e.data );
			vg.initFromGraph();
			
			setRoots( unis.params.objectId );	
			
			if ( vg.currentRootVNode == null )
			{
				vg.currentRootVNode = vg.graph.nodes[ 0 ].vnode;
			}
			
			PopUpManager.hideLoading();
			firstData = false;
			initAPI( vg.graph );
			
			draw();
		}
		
		private function onRelationShipError( e : AMFErrorEvent ) : void
		{
			unis.removeAllObjectListeners( this );
			
			if ( e.layer == AMFErrorLayer.AMF )
			{
				PopUpManager.changeLoadingLabel( 'Ошибка выполнения запроса.\n' + e.text + '\n' );
				return;
			}
			
			Alert.show( e.text, 'Сообщение', Alert.OK, null, onRelationShipErrorCloseHandler );
		}
		
		private function onRelationShipErrorCloseHandler( e : CloseEvent ) : void
		{
			unis.setMode( ApplicationMode.STANDARD );
			initStandardMode( 1 );
		}
		
		/*
		end relationships mode implementation
		*/
		
		/*
		start graph mode implementaion
		*/
		
		private function initGraphMode() : void
		{
			unis.addListener( AMGGraphDataEvent.GRAPH_DATA, onGraphModeData, this );
			unis.addListener( AMFErrorEvent.ERROR, onGraphModeError, this ); 
				
			unis.loadGraph( unis.params.graph );
			PopUpManager.showLoading( 'Загружаю граф...' );
		}
		
		private function onGraphModeData( e : AMGGraphDataEvent ) : void
		{
			unis.removeAllObjectListeners( this );
			
			vg.graph = new Graph();
			
			//В режиме GRAPH учитываем координаты узлов
			vg.graph.initFromVO( e.data );
			vg.initFromGraph();
			
			if ( vg.currentRootVNode == null )
			{
				vg.currentRootVNode = vg.graph.nodes[ 0 ].vnode;
			}
			
			//В режиме GRAPH, не перерисовываем. Координаты узлов передаются
			vg.correctNodesPositionAndBounds();
			
			firstData = false;
			initAPI( vg.graph );
			
			PopUpManager.hideLoading();
		}
		
		private function onGraphModeError( e : AMFErrorEvent ) : void
		{
			unis.removeAllObjectListeners( this );
			PopUpManager.changeLoadingLabel( 'Ошибка выполнения запроса.\n' + e.text + '\n' );
		}
		
		/*
		end graph mode implementation
		*/
		
		private var depthDialog : DepthDialog; 
		
		private function showDepthDialog( title : String, defaultValue : int, closeAction : Function ) : void
		{
			if ( ! depthDialog )
			{
				depthDialog = new DepthDialog();
				depthDialog.title = title;
				depthDialog.defaultValue = defaultValue;
				depthDialog.closeAction = closeAction;
				depthDialog.addEventListener( CloseEvent.CLOSE, hideDepthDialog );
				PopUpManager.addPopUp( depthDialog, null, true );
				PopUpManager.centerPopUp( depthDialog );
			}
		}
		
		private function hideDepthDialog( e : CloseEvent ) : void
		{
			if ( depthDialog )
			{
				depthDialog.removeEventListener( CloseEvent.CLOSE, hideDepthDialog );
				PopUpManager.removePopUp( depthDialog );
				depthDialog.closeAction.call( this, depthDialog.value );
				depthDialog = null;
			}
		}
		
		private function onNodeExpandedError( e : GraphTreeExpandErrorEvent ) : void
		{
			Alert.show( e.message, 'Ошибка' );
			hideIndicator( e.nodeId );
				
			return;
		}
		
		private function onExpandStatusChanged( e : StatusChangedEvent ) : void
		{
			dispatchEvent( e );
		}
		
		private function onExpandOperationStart( e : TaskEvent ) : void
		{
			dispatchEvent( e );
		}
		
		private function onExpandOperationComplete( e : TaskEvent ) : void
		{
			dispatchEvent( e );
		}
		
		private function addTreeExpandResultToGraph( results : Vector.<NodeExpandResult>, graph : IGraph ) : NodesAndEdges
		{
			var expand  : NodeExpandResult;
			var result  : NodesAndEdges;
			var cResult : NodesAndEdges;
			
			for each( expand in results )
			{
				cResult = graph.safeInitFromVO( expand.graph.data );
				
				if ( result )
				{
					result.nodes  = result.nodes.concat( cResult.nodes );
					result.edges  = result.edges.concat( cResult.edges );
				}
				else
				{
					result = cResult;
				}
			}
			
			return result;
		}
		
		private function onNodeExpanded( e : GraphTreeExpandEvent ) : void
		{
				var node           : IVisualNode;
				var operation      : GraphDataFromRemoteSource = new GraphDataFromRemoteSource( vg, e.result ); 
				var result         : NodeExpandResult;
				var objects        : NodesAndEdges;
				var addedToHistory : Boolean;
				
				for each( result in e.result )
				{
					objects = vg.graph.safeInitFromVO( result.graph.data );
					
					//Выполняем действие, только если в результате были получены данные
					if ( ( objects.nodes.length > 0 ) || ( objects.edges.length > 0 ) )
					{
						//Добавляем действие в историю
						if ( ! addedToHistory )
						{
							History.add( operation );
							addedToHistory = true;
						}
						
						node = vg.vNodeByStringId( result.nodeId );
						
						vg.initFromGraph( node ? new Point( node.viewX, node.viewY ) : null, false );
						
						//Перерисовку графа осуществляем только в том случае, когда были добавлены узлы
						if ( objects.nodes.length > 0 )
						{
							//Добавляем вновь полученные узлы в список
							if ( addedNodes )
							{
								addedNodes = addedNodes.concat( objects.nodes );
							}
							else
							{
								addedNodes = objects.nodes;
							}
						}	
					}
				}
				
				if ( addedToHistory )
				{
					if ( useSubExpandLayouter )
					{	
						markNodesAsFixed( true );	
					}
					
					draw();
				}
				else
				{
					//Если операция не была добавлена в History, высвобождаем ресурсы операции
					operation.release();
				}
				
			hideIndicators( e.result );
			firstData = false;
			
			e.preventDefault();
		}
		
		public function draw() : void
		{
			drawUsingMe = true;
			
			//Если данные получены во время инициализации или использования дополнительной компоновки при раскрытии запрещено
			if ( firstData || ! useSubExpandLayouter )
			{
				//Устанавливаем слушатели перерисовки раскладки
				if ( ( addedNodes != null ) && ( ! vgListenersSetted ) )
				{
					vg.addEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onLayoutCalculated );
					vg.addEventListener( VisualGraphEvent.LAYOUT_UPDATED, onLayoutUpdated );
					vgListenersSetted = true;
				}
				
				vg.draw();
				
				return;
			}
			
			if ( ! expandLayouter )
			{
				expandLayouter = new BubbleLayouter( vg );
				expandLayouter.useAsSubLayouter = true;
				expandLayouter.addEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onLayoutCalculated );
				expandLayouter.addEventListener( VisualGraphEvent.LAYOUT_UPDATED, onLayoutUpdated );
			}
			
			expandLayouter.autoFitEnabled   = vg.layouter.autoFitEnabled;
			expandLayouter.fitToWindow      = vg.layouter.fitToWindow;
			expandLayouter.disableAnimation = vg.layouter.disableAnimation;
			
			if ( vg.layouter is HierarchicalLayouter )
			{
				expandLayouter.orientation = HierarchicalLayouter( vg.layouter ).orientation;
			}
			else if ( vg.layouter is BubbleLayouter )
			{
				expandLayouter.orientation = BubbleLayouter( vg.layouter ).orientation;
			}
			else
			{
				expandLayouter.orientation = LayoutOrientation.NONE;
			}
			
			vg.draw( expandLayouter );
		}
		
		/**
		 * Указывает что установлены слушатели на IVisualGraph, которые в последствии необходимо удалить 
		 */		
		private var vgListenersSetted : Boolean = false;
		
		/**
		 *  Перерисовка инициирована "Этим объектом" - true
		 */		
		private var drawUsingMe : Boolean;
		
		/**
		 * Перед перерисовкой раскладки 
		 * @param e
		 * 
		 */		
		private function onVgDraw( e : VisualGraphEvent ) : void
		{
			//Если мы вызвали перерисовку, то ничего не делаем
			if ( drawUsingMe )
			{
				drawUsingMe = false;
				return;
			}
			
			//Отменяем "фиксированность" узлов
			addedNodes = null;
			markNodesAsFixed( false );
			
			
			//Если установлены слушатели "перерисовки" на IVisualGraph, то перед перерисовкой удаляем их
			if ( vgListenersSetted )
			{
				vg.removeEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onLayoutCalculated );
				vg.removeEventListener( VisualGraphEvent.LAYOUT_UPDATED, onLayoutUpdated );
				vgListenersSetted = false;
			}
		}
		
		private function onLayoutCalculated( e : VisualGraphEvent ) : void
		{
			if ( vg.lastLayouter == expandLayouter )
			{
				markNodesAsFixed( false );
			}
			
			scrollToAddedNodes();
		}
		
		private function scrollToAddedNodes() : void
		{
			if ( addedNodes && addedNodes.length != 0 )
			{
				vg.scrollToNodes( addedNodes, null, true );	
			}
		}
		
		private function onLayoutUpdated( e : VisualGraphEvent ) : void
		{
			addedNodes = null;
		}
		
		/**
		 * Маркирует/снимает маркировку "Зафиксирован" со всех визуальных узлов графа  
		 * 
		 */		
		private function markNodesAsFixed( fixed : Boolean ) : void
		{
			var vnode : IVisualNode;
			
			for each( vnode in vg.vnodes )
			{
				if ( ! addedNodes || ( addedNodes.indexOf( vnode.node ) == -1 ) )
				{
					vnode.fixed = fixed;	
				}
			}
		}
		
		private function onItemClick( e : MenuEvent ) : void
		{
			//Развернуть
			if ( e.item.id == IShowFeatures.EXPAND )
			{
				expandNode( e.item.source );
				return;
			}
		}
		
		private function onExpandButtonClick( e : VisualNodeEvent ) : void
		{
			var renderer : INodeRenderer = INodeRenderer( e.node.view );
			
			//Проверяем не находимся ли мы сейчас в состоянии загрузки
			if ( ! renderer.progress )
			{
				expandNode( e.node );	
			}
		}
		
		private function markNodeRendererAsProgress( vn : IVisualNode ) : void
		{
			var indicator : INodeRenderer = INodeRenderer( vn.view );
			    indicator.progress = true;
				
				indicators[ vn.node.stringid ] = indicator;	
		}
		
		public function expandNode( vn : IVisualNode ) : void
		{
			markNodeRendererAsProgress( vn ); 
			
			graphExpander.add( vn.node.stringid );
			graphExpander.run();
		}
		
		public function expandNodes( vns : * ) : void
		{
			var vn    : IVisualNode;
			var group : Array = new Array();
			
			for each( vn in vns )
			{
				group.push( vn.node.stringid );
				markNodeRendererAsProgress( vn );
			}
			
			graphExpander.add( group );
			graphExpander.run();
		}
		
		/**
		 * Словарь текущих открытых индикаторов раскрытия 
		 */		
		private var indicators : Dictionary = new Dictionary();
		
		private function hideIndicator( nodeId : String ) : void
		{
			var indicator : INodeRenderer = indicators[ nodeId ];
			
			if ( indicator )
			{
				indicator.progress = false;
				indicator = null;
				
				delete indicators[ nodeId ];
			}
		}
		
		private function hideIndicators( results : Vector.<NodeExpandResult> ) : void
		{
			for each( var result : NodeExpandResult in results )
			{
				hideIndicator( result.nodeId );
			}
		}
		
		private function clearAllIndicators() : void
		{
			for ( var prop : String in indicators )
			{
				hideIndicator( prop );
			}
		}
		
		/**
		 * Отменяет текущие операции раскрытия объектов 
		 * 
		 */		
		public function cancel() : void
		{
			graphExpander.cancel();
			clearAllIndicators();
		}
	}
}