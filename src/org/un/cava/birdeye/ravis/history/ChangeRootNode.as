package org.un.cava.birdeye.ravis.history
{
	import mx.managers.history.IHistoryOperation;
	import mx.managers.history.events.HistoryEvent;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	
	public class ChangeRootNode extends BaseAsynchrounousOperation implements IHistoryOperation
	{
		private var nodesBefore : Array;
		private var nodesAfter  : Array;
		
		public function ChangeRootNode(vg:IVisualGraph)
		{
			super( vg, true );
			dumpBefore();
		}
		
		private function dumpBefore() : void
		{
			nodesBefore = dumpObjects( vg.vnodes );
			
			dumpVisualGraphBeforeParams();
			
			waitForDraw();
		}
		
		private function dumpAfter() : void
		{
			nodesAfter = dumpObjects( vg.vnodes );
			
			if ( phase == 2 )
			{
				//Синхронизируем координаты узлов с только-что расчитанным layout-ом
				syncNodesPosWithPreLayout( nodesAfter );
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
			
			nodesBefore    = syncNodes( vg.graph.data.nodes, nodesBefore );
			
			dumpVisualGraphBeforeParams();
		}
		
		override protected function _undo( updateIndex : Boolean = false ) : void
		{
			resetAll();
			restoreNodesPos( nodesBefore );
			commitVisualGraphParamsBefore();
			
			super._undo();
		}
		
		public function undo() : void
		{
			_undo();
		}
		
		public function redo() : void
		{
			resetAll();
			restoreNodesPos( nodesAfter );
			commitVisualGraphParamsAfter();
		}
		
		public function get undoDescription():String
		{
			return 'Сделать корневым "' /*+ currentRootNodeBefore.name + '"'*/;
		}
		
		public function get redoDescription():String
		{
			return 'Сделать корневым "' /*+ currentRootNodeAfter.name + '"'*/;
		}
	}
}