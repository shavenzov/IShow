package org.un.cava.birdeye.ravis.history
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import mx.managers.history.History;
	import mx.utils.ObjectUtil;
	
	import spark.core.IViewport;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	
	public class BaseVisualGraphOperation
	{
		protected var _dispatchChanged : Boolean;
		
		protected var vg       : IVisualGraph;
		protected var viewport : IViewport;
		
		/**
		 * Параметры VisualGraph, до операции 
		 */		
		protected var scrollXBefore : Number;
		protected var scrollYBefore : Number;
		protected var boundsBefore  : Rectangle;
		protected var selectedNodesBefore : Array;
		protected var selectedEdgesBefore : Array;
		protected var currentRootsBefore : Array;
		
		/**
		 * Параметры VisualGraph, после операции 
		 */		
		protected var scrollXAfter  : Number;
		protected var scrollYAfter  : Number;
		protected var boundsAfter   : Rectangle;
		protected var selectedNodesAfter : Array;
		protected var selectedEdgesAfter : Array;
		protected var currentRootsAfter : Array;
		
		public function BaseVisualGraphOperation( vg : IVisualGraph, dispatchChanged : Boolean = false )
		{
			super();
			
			this.vg = vg;
			this.viewport = IViewport( vg );
			
			_dispatchChanged = dispatchChanged;
		}
		
		public function get dispatchChanged() : Boolean
		{
			return _dispatchChanged;
		}
		
		private function dumpCurrentRoots() : Array
		{
			var result : Array = new Array( vg.complexLayouter.roots.length );
			
			for ( var i : int = 0; i < vg.complexLayouter.roots.length; i ++ )
			{
				result[ i ] = ObjectUtil.clone( vg.complexLayouter.roots[ i ].data );
			}
			
			return result;
		}
		
		protected function dumpVisualGraphBeforeParams() : void
		{
			scrollXBefore = viewport.horizontalScrollPosition;
			scrollYBefore = viewport.verticalScrollPosition;
			boundsBefore  = vg.bounds.clone();
			
			//Текущий корневой узел
			currentRootsBefore = dumpCurrentRoots();
			
			//Копируем список выделенных узлов
			selectedNodesBefore = dumpObjects( vg.selectedNodes );
			
			//Копируем список выделенных связей
			selectedEdgesBefore = dumpObjects( vg.selectedEdges );
		}
		
		protected function dumpVisualGraphAfterParams() : void
		{
			scrollXAfter = viewport.horizontalScrollPosition;
			scrollYAfter = viewport.verticalScrollPosition;
			boundsAfter  = vg.bounds.clone();
			
			//Текущий корневой узел
			currentRootsAfter = dumpCurrentRoots();
			
			//Копируем список выделенных узлов
			selectedNodesAfter = dumpObjects( vg.selectedNodes );
			
			//Копируем список выделенных связей
			selectedEdgesAfter = dumpObjects( vg.selectedEdges );
		}
		
		private function commitCurrentRoots( roots : Array ) : void
		{
			var vRoots : Vector.<INode> = new Vector.<INode>( roots.length );
			
			for ( var i : int = 0; i < roots.length; i ++ )
			{
				vRoots[ i ] = getNodeByData( roots[ i ] );
			}
			
			vg.complexLayouter.roots = vRoots;
		}
		
		protected function commitVisualGraphParamsBefore() : void
		{
			vg.bounds = boundsBefore;
			vg.validateNow();
			
			viewport.horizontalScrollPosition = scrollXBefore;
			viewport.verticalScrollPosition   = scrollYBefore;
			
			commitCurrentRoots( currentRootsBefore );
			
			setSelection( selectedNodesBefore, selectedEdgesBefore );
		}
		
		protected function commitVisualGraphParamsAfter() : void
		{
			vg.bounds = boundsAfter;
			vg.validateNow();
			
			viewport.horizontalScrollPosition = scrollXAfter;
			viewport.verticalScrollPosition   = scrollYAfter;
			
			commitCurrentRoots( currentRootsAfter );
			
			setSelection( selectedNodesAfter, selectedEdgesAfter );
		}
		
		/**
		 * Возвращает VisualNode, по его данным 
		 * @param data
		 * @return 
		 * 
		 */		
		protected function getVNodeByData( data : Object ) : IVisualNode
		{
			var node : INode = vg.graph.nodeByStringId( data.id );
			
			return node ? node.vnode : null;
		}
		
		/**
		 * Возвращает Node, по его данным 
		 * @param data
		 * @return 
		 * 
		 */		
		protected function getNodeByData( data : Object ) : INode
		{
			return vg.graph.nodeByStringId( data.id );
		}
		
		/**
		 * Возвращает VisualEdge, по его данным 
		 * @param data
		 * @return 
		 * 
		 */		
		protected function getVEdgeByData( data : Object ) : IVisualEdge
		{
			var edge : IEdge = vg.graph.edgeByStringId( data.id );
			
			return edge ? edge.vedge : null;
		}
		
		/**
		 * Возвращает Edge, по его данным 
		 * @param data
		 * @return 
		 * 
		 */		
		protected function getEdgeByData( data : Object ) : IEdge
		{
			return vg.graph.edgeByStringId( data.id );
		}
		
		/**
		 * Ищет в списке объектов объект с указанным id 
		 * @param id      - идентификатор объекта который необходимо найти
		 * @param objects - список объектов для поиска
		 * @return возвращает копию найденного объекта
		 * 
		 */		
		protected function getDataById( id : String, objects : * ) : Object
		{
			var data : Object;
			
			for each( data in objects )
			{
				if ( data.id == id )
					return ObjectUtil.clone( data );
			}
			
			return null;
		}
		
		/**
		 * Выделяет указанные узлы и связи 
		 * @param nodes
		 * @param edges
		 * 
		 */		
		private function setSelection( nodes : Array, edges : Array ) : void
		{
			var o  : Object;
			var vn : IVisualNode;
			var ve : IVisualEdge;
			var selectedNodes : Dictionary = new Dictionary();
			var selectedEdges : Dictionary = new Dictionary();
			
			for each( o in nodes )
			{
				vn = getVNodeByData( o );
				
				if ( vn )
				{
					selectedNodes[ vn ] = vn;
				}
			}
			
			for each( o in edges )
			{
				ve = getVEdgeByData( o );
				
				if ( ve )
				{
					selectedEdges[ ve ] = ve;	
				}
			}
			
			vg.selectedNodes = selectedNodes;
			vg.selectedEdges = selectedEdges;
		}
		
		protected function restoreNodesPos( nodes : Array ) : void
		{
			var vn   : IVisualNode;
			var data : Object;
			
			for each( data in nodes )
			{
				vn  = getVNodeByData( data );
				
				if ( vn )
				{
					vn.data.x = data.x;
					vn.data.y = data.y;
					vn.commit();
				}
			}
			
			vg.dispatchEvent( new VisualGraphEvent( VisualGraphEvent.NODES_UPDATED ) );
		}
		
		/**
		 * Синхронизирует координаты указанных узлов, с предварительно расчитанными координатами layouter 
		 * @param nodes
		 * 
		 */		
		protected function syncNodesPosWithPreLayout( nodes : Array ) : void
		{
			var node : INode;
			var data : Object;
			var pos  : Point;
			
			for each( data in nodes )
			{
				node = getNodeByData( data );
				
				if ( node )
				{
					pos  = vg.complexLayouter.layoutDrawing.getAbsCartCoordinates( node );
					
					if ( pos )
					{
						data.x = pos.x;
						data.y = pos.y;
					}
				}
			}
		}
		
		/**
		 * Синхронизирует координаты dstNodes с sNodes 
		 * @param sNodes
		 * @param dstNodes
		 * 
		 */		
		protected function syncNodesPos( srcNodes : Array, dstNodes : Array ) : void
		{
			var src : Object;
			var dst : Object
			
			for each( dst in dstNodes )
			{
				for each( src in srcNodes )
				{
					if ( src.id == dst.id )
					{
						dst.x = src.x;
						dst.y = src.y;
					}
				}
			}
		}
		
		/**
		 * Синхронизирует объекты dstNodes с sNodes 
		 * @param sNodes
		 * @param dstNodes
		 * 
		 */		
		protected function syncNodes( srcNodes : Array, dstNodes : Array ) : Array
		{
			var src : Object;
			var dst : Object
			var i   : int = 0;
			var j   : int = 0;
			
			for ( i = 0; i < dstNodes.length; i ++ )
			{
				dst = dstNodes[ i ];
				
				for ( j = 0; j < srcNodes.length; j ++ )
				{
					src = srcNodes[ j ];
					
					if ( src.id == dst.id )
					{
						dstNodes[ i ] = ObjectUtil.clone( src );
					}
				}
			}
			
			return dstNodes;
		}
		
		/**
		 * Возвращает массив копии данных переданных объектов 
		 * @param vnodes
		 * @return 
		 * 
		 */		
		protected function dumpObjects( objects : * ) : Array
		{
			var result : Array = new Array();
			
			for each( var o : Object in objects )
			{
				result.push( ObjectUtil.clone( o.data ) );
			}
			
			return result;
		}
		
		/**
		 * Прерывает анимацию, если идет процесс анимации 
		 * 
		 */		
		protected function resetAll() : void
		{
			/*if ( vg.layouter.animInProgress )
			{*/
			vg.complexLayouter.resetAll();
			//}
			
			vg.stopAllUserInteractions();
		}
		
		/**
		 * Уведомляет историю о произошедших изменениях (Команда добавлена в стек) 
		 * 
		 */		
		protected function sendChangedEvent() : void
		{
			History.listener.dispatchEvent( new Event( Event.CHANGE ) );
		}
	}
}