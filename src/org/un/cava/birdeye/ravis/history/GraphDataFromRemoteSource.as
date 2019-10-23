package org.un.cava.birdeye.ravis.history
{
	import com.bs.amg.tasks.NodeExpandResult;
	
	import mx.managers.history.History;
	import mx.managers.history.IHistoryOperation;
	import mx.managers.history.events.HistoryEvent;
	import mx.utils.ObjectUtil;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	
	public class GraphDataFromRemoteSource extends BaseAsynchrounousOperation implements IHistoryOperation
	{
		private var beforeData   : Object;
		private var afterData    : Object;
		
		//От каких узлов происходит разворот
		private var fromNodesData : Array;
		
		/**
		 * 
		 * @param vg
		 * @param fromNodes - список идентификаторов узлов которые были раскрыты
		 * 
		 */		
		public function GraphDataFromRemoteSource( vg : IVisualGraph, fromNodes : Vector.<NodeExpandResult> )
		{
		  super( vg, true );
		  dumpBefore( fromNodes );
		}
		
		/** 
		 * @param fromNodes - список идентификаторов узлов которые были раскрыты
		 * 
		 */		
		private function dumpBefore( fromNodes : Vector.<NodeExpandResult> ) : void
		{ 
			this.beforeData   = ObjectUtil.clone( vg.graph.data );
			
			this.fromNodesData = new Array( fromNodes.length );
			
			for ( var i : int = 0; i < fromNodes.length; i ++ )
			{
				fromNodesData[ i ] = ObjectUtil.clone( vg.graph.nodeByStringId( fromNodes[ i ].nodeId ).data );
			}
			
			dumpVisualGraphBeforeParams();
			
			waitForDraw();
		}
		
		private function dumpAfter() : void
		{
			this.afterData = ObjectUtil.clone( vg.graph.data );
			
			//Синхронизируем координаты узлов с только-что расчитанным layout-ом
			if ( phase == 2 )
			{
				syncNodesPosWithPreLayout( this.afterData.nodes );
				
				//Если работаем с асинхронной раскладкой, то
				moveOperationToEnd();
			}
			
			dumpVisualGraphAfterParams();
			
			sendChangedEvent();
		}
		
		/**
		 * Раскладка полностью расчитана  
		 * @param e
		 * 
		 */		
		override protected function onLayoutCalculated( e : VisualGraphEvent ) : void
		{
			super.onLayoutCalculated( e );
			dumpAfter();
		}
		
		//----------------------------------Для асинхронных раскладок--------------------------------------------------------
		
		/**
		 * Запустился асинхронный процесс расчета раскладки 
		 * @param e
		 * 
		 */		
		override protected function onStartAsyncLayoutCalculation( e : VisualGraphEvent ) : void
		{
			super.onStartAsyncLayoutCalculation( e );
			dumpAfter();
		}
		
		/**
		 * Если во время просчета раскладки были "развернуты" ещё какие-то данные, то 
		 * @param e
		 * 
		 */
		override protected function onAddedNewOperation( e : HistoryEvent ) : void
		{
			if ( e.operation is GraphDataFromRemoteSource )
			{
				//Убеждаемся, что в данный момент идет расчет раскладки
				if ( phase == 1 )
				{
					phase = 0;
					//Удаляем вновь добавленное событие из истории
					GraphDataFromRemoteSource( e.operation ).release();
					History.remove( e.operation );
					
					//Удаляем слушатели, что-бы при вызове onStartAsyncLayoutCalculation они не добавились вновь
					vg.removeEventListener( VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION, onEndAsyncLayoutCalculation );
					History.listener.removeEventListener( HistoryEvent.ADD, onAddedNewOperation );
				}
			}
			
			//Во время асинхронной операции произошли какие-то изменения
			beforeData.nodes = syncNodes( vg.graph.data.nodes, beforeData.nodes );
			dumpVisualGraphBeforeParams();
		}
		
		//----------------------------------Для асинхронных раскладок--------------------------------------------------------
		
		override protected function _undo( updateIndex : Boolean = false ) : void
		{
			//Необходимо удалить все VisualNode, которые не присутствуют в beforeData
			//Для оставшихся узлов установить новые координаты
			var before : Object;
			var after  : Object;
			var found  : Boolean;
			
			var  n : INode;
			var vn : IVisualNode;
			var  e : IEdge;
			var ve : IVisualEdge;
			
			//Просмотр списка связей
			for each( after in afterData.edges )
			{
				found = false;
				
				for each( before in beforeData.edges )
				{
					if ( before.id == after.id )
					{
						found = true;
					}
				}
				
				if ( ! found )
				{
					//Удаляем связь
					e  = vg.graph.edgeByStringId( after.id );
					
					if ( e )
					{
						ve = e.vedge;
						vg.removeEdge( ve );
					}
				}
			}
			
			//Просмотр списка узлов
			for each( after in afterData.nodes )
			{
				found = false;
				
				for each( before in beforeData.nodes )
				{
					if ( before.id == after.id )
					{
						found = true;
					}
				}
				
				if ( ! found )
				{
					//Удаляем узел
					n  = vg.graph.nodeByStringId( after.id );
					vn = n.vnode;
					
					vg.removeNode( vn );
				}
			}
			
			//Удаляем св-во expanded у раскрытых элементов
			for each( before in fromNodesData )
			{
				n = getNodeByData( before );
				delete n.data.expanded;
			}
			
			//Прерываем анимацию, если идет процесс анимации
			resetAll();
			
			//Востанавливаем предыдущие координаты узлов
			restoreNodesPos( beforeData.nodes );
			
			commitVisualGraphParamsBefore();
			
			super._undo( updateIndex );
		}
		
		public function undo() : void
		{
			_undo( false );
		}
		
		public function get undoDescription():String
		{
			return 'Отменить разворот "' /*+ fromNodeData.name + '"'*/;
		}
		
		public function redo() : void
		{
			var before : Object;
			var after  : Object;
			var found  : Boolean;
			
			var  e : IEdge;
			var ve : IVisualEdge;
			
			var data : Object = { nodes : [], edges : [] };
			
		   //Добавляем раннее удаленные узлы
			for each( after in afterData.nodes )
			{
				found = false;
				
				for each( before in beforeData.nodes )
				{
					if ( before.id == after.id )
					{
						found = true;
					}
				}
				
				if ( ! found )
				{
					//Добавляем узел
					data.nodes.push( ObjectUtil.clone( after ) );
				}
			}	
			
		   //Добавляем ранее удаленные связи
		   for each( after in afterData.edges )
			{
				found = false;
				
				for each( before in beforeData.edges )
				{
					if ( before.id == after.id )
					{
						found = true;
					}
				}
				
				if ( ! found )
				{
					//Добавляем связь
					data.edges.push( ObjectUtil.clone( after ) );
				}
			}	
		
			//Прерываем анимацию, если идет процесс анимации
			resetAll();
			
		   //Добавляем
		   vg.graph.initFromVO( data );
		   vg.initFromGraph();
		   
		   //Добавляем св-во expanded к раскрываемым узлам
		   var n : INode;
		   
		   for each( before in fromNodesData )
		   {
			   n = getNodeByData( before );
			   n.data.expanded = true;
		   }
		   
		   //Восстанавливаем координаты узлов
		   restoreNodesPos( afterData.nodes );
		   
		   commitVisualGraphParamsAfter();
		}
		
		public function get redoDescription():String
		{
			return 'Развернуть "'/* + fromNodeData.name + '"'*/;  
		}
	}
}