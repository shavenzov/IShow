package com.bs.amg.tasks
{
	import com.amf.events.AMFErrorEvent;
	import com.bs.amg.UnisAPI;
	import com.bs.amg.UnisAPIImplementation;
	import com.bs.amg.events.AMGGraphDataEvent;
	import com.bs.amg.tasks.events.GraphTreeExpandErrorEvent;
	import com.bs.amg.tasks.events.GraphTreeExpandEvent;
	import com.thread.SimpleTask;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGTree;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	
	/**
	 * Задача - раскрытие дерева объектов до указанной глубины
	 * Параметры : Список идентификаторов объектов
	 *             Глубина раскрытия объектов 
	 * @author Shavenzov
	 * 
	 */
	public class UnisGraphExpander extends SimpleTask
	{
		/**
		 * Запущен процесс раскрытия 
		 */		
		public static const EXPANDING : int = 10;
		
		/**
		 * Глобальный визуализируемый граф 
		 */		
		private var _graph : IGraph;
		
		/**
		 *  Словарь идентификаторов уже раскрытых узлов ( за все время работы )
		 */		
		private var _expandedNodes : Object;
		
		/**
		 * Глубина раскрытия узлов 
		 */		
		private var _depth : uint;
		
		/**
		 * Двухмерный массив состоящий из групп раскрываемых объектов и их идентификаторов
		 */		
		private var _groups : Array;
		
		
		/**
		 * Текущая раскрываемая группа объектов 
		 */		
		private var _currentGroup : Array;
		
		/**
		 * Текущий раскрываемый узел и граф с ним связанный
		 */		
		private var _currentResult : NodeExpandResult;
		
		/**
		 *  Список результатов раскрытия для определенной группы
		 */		
		private var _currentGroupResult : Vector.<NodeExpandResult>;
		
		/**
		 * Идентификатор текущего раскрываемого подузла 
		 */		
		private var _currentExpandingObjectId : String;
		
		/**
		 * UNIS API 
		 */		
		private var _unis : UnisAPIImplementation;
		
		/**
		 * Последняя ошибка 
		 */		
		private var _lastError : AMFErrorEvent;
		
		public function UnisGraphExpander( depth : uint = 1, graph : IGraph = null )
		{
			super();
			
			_depth  = depth;
			_groups = new Array();
			
			_graph  = graph ? graph : new Graph();
		} 
		
		public function get depth() : uint
		{
			return _depth;
		}
		
		public function set depth( value : uint ) : void
		{
			_depth = value;
		}
		
		public function add( nodeId : * ) : void
		{
			if ( nodeId is String )
			{
				_groups.push( [ nodeId ] );
				return;
			}
			
			if ( nodeId is Array )
			{
				_groups.push( nodeId );
				
				return;
			}
			
			throw new Error( 'not suported data for add' ); 
		}
		
		public function get groups() : Array
		{
			return _groups;
		}
		
		public function get graph() : IGraph
		{
			return _graph;
		}
		
		/**
		 * Определяет раскрыт ли узел с указанным идентификатором или нет 
		 * @param nodeId
		 * 
		 */		
		public function isNodeExpanded( nodeId : String ) : Boolean
		{
			return _expandedNodes[ nodeId ] != null;
		}
		
		override protected function next() : void
		{
			switch( _status )
			{
				case SimpleTask.NONE : _status = EXPANDING;
					                   init();
					                   expandNextGroup();
					                   break;
				
				case EXPANDING : expandNextNode();
					             break;
				
				case SimpleTask.ERROR :
				case SimpleTask.DONE  : uninit();
					                    break; 
					
			}
			
			super.next();
		}
		
		/**
		 * Прерывает операцию раскрытия и удаляет все узлы из списка раскрываемых 
		 * 
		 */		
		public function cancel() : void
		{
			if ( _status == EXPANDING )
			{
				_status = SimpleTask.DONE;
				next();
			}
		}
		
		/**
		 * Запускает процесс раскрытия следующей группы объектов и его потомков, до указанной глубины 
		 * 
		 */		
		private function expandNextGroup() : void
		{
			if ( _groups.length == 0 )
			{
				if ( ( _graph.noNodes == 0 ) && ( _lastError != null ) )
				{
					_statusString = _lastError.text;
					_status       = SimpleTask.ERROR;
				}
				else
				{
					_status = SimpleTask.DONE;
				}
				
				next();
				
				return;
			}
			
			_currentGroupResult = new Vector.<NodeExpandResult>();
			_currentGroup       = _groups.shift();
			
			expandNextObject();
		}
		
		/**
		 * Запускает процесс ракрытия следуюего объекта в текущей группе объектов 
		 * 
		 */		
		private function expandNextObject() : void
		{
			if ( _currentGroup.length == 0 )
			{
				var addToGlobalGraph : Boolean = true;
				
				//Отсылаем событие "Дерево раскрыто"
				if ( hasEventListener( GraphTreeExpandEvent.EXPANDED ) )
				{
					addToGlobalGraph = dispatchEvent( new GraphTreeExpandEvent( GraphTreeExpandEvent.EXPANDED, _currentGroupResult ) ); 
				}
				
				if ( addToGlobalGraph )
				{
					//Добавляем новое сформированное дерево в глобальный граф
					_graph.safeInitFromVO( NodeExpandResult.resultUnion( _currentGroupResult ).data );
				}
				
				expandNextGroup();
				
				return;
			}
			
			_currentResult = new NodeExpandResult( _currentGroup.shift() );
			_currentGroupResult.push( _currentResult );
			
			expandNode( _currentResult.nodeId );
		}
		
		/**
		 * Раскрывает ещё не раскрытые узлы объекта до указанной глубины 
		 * 
		 */		
		private function expandNextNode() : void
		{
			var node : INode;
			
			//Помечаем текущий раскрытый узел, как раскрытый
			if ( _currentExpandingObjectId )
			{
				node = _currentResult.graph.nodeByStringId( _currentExpandingObjectId );
				
				if ( node )
				{
					node.data.expanded = true;
				}
			}
			
			node = _currentResult.graph.nodeByStringId( _currentResult.nodeId );
			
			if ( node )
			{
				var tree : IGTree = _currentResult.graph.getTree( node );
				
				//Ищем следующий узел для раскрытия
				for each( node in tree.nodes )
				{
					//Если узла нету в глобальном графе
					if ( _graph.nodeByStringId( node.stringid ) == null )
					{
						//Если узел не раскрыт
						if ( ! nodeExpanded( node.stringid ) )
						{
							//И его глубина меньше depth
							if ( tree.getDistance( node ) < _depth )
							{
								//Раскрываем его и выходим
								expandNode( node.stringid );
								return;
							}
						}
					}
				}
			}
			else //Во время загрузки информации об корневом узле произошла ошибка
			{
				//Переходим к следующему объекту
				expandNextObject();
				return;
			}
			
			/*
			Если мы здесь, значит все дерево раскрыто
			*/
			
			
			//Переходим к раскрытию следующего объекта
			expandNextObject();
		}
		
		private static const defaultStatusString : String = 'Раскрытие объектов...'; 
		
		private function expandNode( nodeId : String ) : void
		{
			//Если имеется информация о текущем раскрываемом узле,
			var node : INode = _currentResult.graph.nodeByStringId( nodeId );
			
			if ( ! node )
			{
				node = _graph.nodeByStringId( nodeId );
			}
			
			if ( node )
			{
				//то указываем имя текущего раскрываемого узла
				_statusString = 'Раскрываю : ' + node.data.name + '...';
			}
			else
			{
				_statusString = defaultStatusString;
			}
			
			_expandedNodes[ nodeId ] = nodeId;
			_currentExpandingObjectId = nodeId;
			
			_unis.getShowGraph( nodeId );
		}
		
		/**
		 * Определяет был ли этот узел развернут уже 
		 * @param nodeId - идентификатор узла для проверки
		 * @return true  - был
		 *         false - не был
		 * 
		 */		
		private function nodeExpanded( nodeId : String ) : Boolean
		{
			return _expandedNodes.hasOwnProperty( nodeId );
		}
		
		private function init() : void
		{
			_unis = UnisAPI.impl;
			_unis.addListener( AMFErrorEvent.ERROR, onUnisError, this );
			_unis.addListener( AMGGraphDataEvent.GRAPH_DATA, onGraphData, this ); 
			
			_currentExpandingObjectId = null;
			_currentGroup = null;
			_currentResult = null;
			_currentGroupResult = null;
			
			_expandedNodes   = new Object();
			_statusString    = defaultStatusString;
			
			operationStart();
		}
		
		private function uninit() : void
		{
			_unis.removeAllObjectListeners( this );
			_unis = null;
			
			_currentGroup = null;
			_currentResult = null;
			_currentGroupResult = null;
			_currentExpandingObjectId = null;
			_expandedNodes = null;
			
			operationComplete();
		}
		
		private function onUnisError( e : AMFErrorEvent ) : void
		{
			_statusString = 'Ошибка : ' + e.text;
			
			_lastError = e;
			
			dispatchEvent( new GraphTreeExpandErrorEvent( GraphTreeExpandErrorEvent.ERROR, e.call.params[ 1 ], e.text, e.errorID ) ); 
			
			next();
		}
		
		private function onGraphData( e : AMGGraphDataEvent ) : void
		{
			_currentResult.graph.safeInitFromVO( e.data );
			
			next();
		}
	}
}