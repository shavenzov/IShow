package org.un.cava.birdeye.ravis.history
{
	import mx.managers.history.IHistoryOperation;
	import mx.managers.history.events.HistoryEvent;
	import mx.utils.ObjectUtil;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	
	public class GroupNodes extends BaseAsynchrounousOperation implements IHistoryOperation
	{
		private var beforeData   : Object;
		private var afterData    : Object;
		
		private var mainNode     : Object;
		private var group        : Object;
		
		public function GroupNodes( vg : IVisualGraph, mainNode : IVisualNode, group : Object, auto : Boolean )
		{
			super( vg, auto );
			
			dumpBefore( mainNode, group, auto );
		}
		
		private function dumpBefore( mainNode : IVisualNode, group : Object, auto : Boolean = false ) : void
		{
			this.group = ObjectUtil.clone( group );
			
			this.mainNode   = ObjectUtil.clone( mainNode.data );
			this.beforeData = ObjectUtil.clone( vg.graph.data );
			
			dumpVisualGraphBeforeParams();
			
			if ( auto )
			{
				waitForDraw();	
			}
		}
		
		public function dumpAfter() : void
		{
			this.afterData = ObjectUtil.clone( vg.graph.data );
			
			//Синхронизируем координаты узлов с только-что расчитанным layout-ом
			if ( phase == 2 )
			{
				syncNodesPosWithPreLayout( afterData.nodes );
				moveOperationToEnd();
			}
			
			dumpVisualGraphAfterParams();
			sendChangedEvent();
		}
		
		override protected function onLayoutCalculated( e : VisualGraphEvent ) : void
		{
			super.onLayoutCalculated( e );
			dumpAfter();
		}
		
		override protected function onStartAsyncLayoutCalculation( e : VisualGraphEvent ) : void
		{
			super.onStartAsyncLayoutCalculation( e );
			dumpAfter();
		}
		
		override protected function onAddedNewOperation( e : HistoryEvent ) : void
		{
			super.onAddedNewOperation( e );
			
			beforeData.nodes = syncNodes( vg.graph.data.nodes, beforeData.nodes );
			
			dumpVisualGraphBeforeParams();
		}
		
		override protected function _undo( updateIndex : Boolean = false ) : void
		{
		  var data : Object;	
		  
		  //Удаляем сгруппированные узлы из списка игнорируемых
		  for each( data in group.nodes )
		  {
			  vg.graph.removeNodeIdFromIgnoreList( data.id );
		  }
			
		  //Удалить модифицированные связи
		  var vedge : IVisualEdge;
		  
		  for each( data in group.edges.modified )
		  {
			 vedge = getVEdgeByData( data );
			 vg.removeEdge( vedge );
		  }
		  
		  //Создаем список связей для добавления
		  var edges : Array = group.edges.modified.concat( group.edges.deleted );
		  
		  //Удаляем из игнора все связи
		  for each( data in edges )
		  {
			  vg.graph.removeEdgeIdFromIgnoreList( data.id );
		  }
		  
		  //Указываем св-во group, для объекта
		  var node : INode = getNodeByData( mainNode );
		      node.group = null;
		  
		  //Прерываем анимацию, если идет процесс анимации
		  resetAll();
		  
		  //Добавить все в граф
		  vg.graph.initFromVO( { nodes : group.nodes, edges : edges } );
		  vg.initFromGraph();
		  
		  //Восстанавливаем координаты узлов
		  restoreNodesPos( beforeData.nodes );
		  
		  commitVisualGraphParamsBefore();
		  
		  super._undo();
		}
		
		public function undo() : void
		{
			_undo();
		}
		
		public function redo() : void
		{
			var data      : Object;
			var subData   : Object;
			
			var vedge : IVisualEdge;
			
			//Добавляю удаленные связи в список игнорируемых и удаляю
			for each( data in group.edges.deleted )
			{
				vg.graph.addEdgeIdToIgnoreList( data.id );
				vedge = getVEdgeByData( data );
				vg.removeEdge( vedge );
			}
			
			//Удаляю модифицированные связи + формирую список модифицированных связей для добавления
			var addedEdges : Array = new Array();
			
			for each( data in group.edges.modified )
			{
				addedEdges.push( getDataById( data.id, afterData.edges ) );
				
				vedge = getVEdgeByData( data );
				vg.removeEdge( vedge );
			}
			
			//Удаляю узлы + добавляю их в список игнорируемых
			var vnode : IVisualNode;
			
			for each( data in group.nodes )
			{
				vg.graph.addNodeIdToIgnoreList( data.id );
				vnode = getVNodeByData( data );
				vg.removeNode( vnode );
			}
			
			//Указываем св-во group, для объекта
			vnode = getVNodeByData( mainNode );
			vnode.node.group = ObjectUtil.clone( group );
			
			//Прерываем анимацию, если идет процесс анимации
			resetAll();
			
			if ( addedEdges.length > 0 )
			{
				vg.graph.initFromVO( { nodes : [], edges : addedEdges } );
				vg.initFromGraph();
			}
			
			//Восстанавливаем координаты узлов
			restoreNodesPos( afterData.nodes );
			
			commitVisualGraphParamsAfter();
		}
		
		public function get undoDescription() : String
		{
			return 'Отменить группировку в "' + mainNode.data.name + '"';
		}
		
		public function get redoDescription() : String
		{
			return 'Группировать объекты в "' + mainNode.data.name + '"';
		}
	}
}