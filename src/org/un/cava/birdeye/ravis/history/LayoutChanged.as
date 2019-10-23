package org.un.cava.birdeye.ravis.history
{
	import mx.managers.history.IHistoryOperation;
	import mx.managers.history.events.HistoryEvent;
	import mx.utils.ObjectUtil;
	
	import org.un.cava.birdeye.ravis.graphLayout.layout.BubbleLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.CircularLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ConcentricRadialLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ForceDirectedLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.HierarchicalLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
	import org.un.cava.birdeye.ravis.graphLayout.layout.LayouterFactory;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ParentCenteredRadialLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	
	public class LayoutChanged extends BaseAsynchrounousOperation implements IHistoryOperation
	{
		/**
		 * Параметры компоновщика до изменений 
		 */		
		private var layouterBefore : Object;
		
		/**
		 * Расположение узлов до изменений 
		 */		
		private var nodesBefore : Array;
		
		/**
		 * Параметры компоновщика после изменений 
		 */		
		private var layouterAfter  : Object;
		
		/**
		 * Расположение узлов после изменений 
		 */		
		private var nodesAfter : Array;
		
		public function LayoutChanged( vg : IVisualGraph )
		{
			super( vg, true );
			dumpBefore();
		}
		
		private function dumpBefore() : void
		{
			layouterBefore = ObjectUtil.clone( vg.layouter.data );
			nodesBefore    = dumpObjects( vg.vnodes );
			
			dumpVisualGraphBeforeParams();
			waitForDraw();
		}
		
		private function dumpAfter() : void
		{
			layouterAfter = ObjectUtil.clone( vg.layouter.data );
			nodesAfter    = dumpObjects( vg.vnodes );
			
			if ( phase == 2 )
			{
				//Синхронизируем координаты узлов с только-что расчитанным layout-ом
				syncNodesPosWithPreLayout( nodesAfter );
				
				//Если работаем с асинхронной раскладкой, то
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
			//Прерываем анимацию, если идет процесс анимации
			resetAll();
			
		  restoreNodesPos( nodesBefore );
		  vg.layouter = layouterFromData( layouterBefore );
		  
		  commitVisualGraphParamsBefore();
		  
		  super._undo( updateIndex );
		}
		
		public function undo() : void
		{
			_undo();
		}
		
		public function get undoDescription():String
		{
			return 'Отменить изменение раскладки из "' + getLayoutDescription( layouterBefore ) + '" на "' + getLayoutDescription( layouterAfter ) + '"';
		}
		
		public function redo():void
		{
			//Прерываем анимацию, если идет процесс анимации
			resetAll();
			
		  restoreNodesPos( nodesAfter );
		  vg.layouter = layouterFromData( layouterAfter );
		  
		  commitVisualGraphParamsAfter();
		}
		
		public function get redoDescription():String
		{
			return 'Изменить раскладку с "' + getLayoutDescription( layouterAfter ) + '" на "' + getLayoutDescription( layouterBefore ) + '"';
		}
		
		private function getLayoutDescription( data : Object ) : String
		{
			var desc : String;
			
			switch( data.type )
			{
				case ConcentricRadialLayouter.ID : desc = 'Круговая (стандартная)';
					break;
				
				case ParentCenteredRadialLayouter.ID : desc = 'Круговая (от родителя)';
					break;
				
				case CircularLayouter.ID : desc = 'Круговая (единый круг)';
					break;
				case HierarchicalLayouter.ID : desc = 'Иерархическая';
					break;
				case ForceDirectedLayouter.ID : desc = 'Органическая';
					break;
				case BubbleLayouter.ID : desc = 'Пузырьковая';
					break;
			}
			
			return desc;
		}
		
		private function layouterFromData( data : Object ) : ILayoutAlgorithm
		{
			return LayouterFactory.create( vg, data );
		}
	}
}