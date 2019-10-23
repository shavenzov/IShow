package org.un.cava.birdeye.ravis.history
{
	import mx.managers.history.IHistoryOperation;
	import mx.managers.history.events.HistoryEvent;
	import mx.utils.ObjectUtil;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	
	public class LayoutParamsChanged extends BaseAsynchrounousOperation implements IHistoryOperation
	{
		/**
		 * Параметры компоновщика до изменений 
		 */		
		private var layouterParamsBefore : Object;
		
		/**
		 * Расположение узлов до изменений 
		 */		
		private var nodesBefore : Array;
		
		/**
		 * Параметры компоновщика после изменений 
		 */		
		private var layouterParamsAfter  : Object;
		
		/**
		 * Расположение узлов после изменений 
		 */		
		private var nodesAfter : Array;
		
		/**
		 *  
		 */		
		private var auto : Boolean;
		
		public function LayoutParamsChanged( vg : IVisualGraph, auto : Boolean = true )
		{
			super( vg, true );
			this.auto = auto;
			dumpBefore();	
		}
		
		public function setAutomation() : void
		{
			if ( auto )
			{
				waitForDraw();	
			}
		}
		
		public function dumpBefore() : void
		{
			layouterParamsBefore = ObjectUtil.clone( vg.layouter.data );
			nodesBefore          = dumpObjects( vg.vnodes );
			
			if ( vg.lastLayouter.animInProgress )
			{
				syncNodesPosWithPreLayout( nodesBefore );
			}
			
			dumpVisualGraphBeforeParams();
			
			setAutomation();
		}
		
		public function dumpAfter() : void
		{
			layouterParamsAfter = ObjectUtil.clone( vg.layouter.data );
			nodesAfter    = dumpObjects( vg.vnodes );
			
			//Синхронизируем координаты узлов с только-что расчитанным layout-ом
			//Если идет процесс анимации, то берем предварительно расчитанные параметры
			if ( phase == 2 )
			{
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
			
			nodesBefore = syncNodes( vg.graph.data.nodes, nodesBefore );
			dumpVisualGraphBeforeParams();
		}
		
		override protected function _undo( updateIndex : Boolean = false ) : void
		{
			//Прерываем анимацию, если идет процесс анимации
			resetAll();
			
			vg.layouter.data = layouterParamsBefore;
			restoreNodesPos( nodesBefore );
			
			commitVisualGraphParamsBefore();
			
			super._undo( updateIndex );
		}
		
		public function undo() : void
		{
			_undo();
		}
		
		public function get undoDescription():String
		{
			return 'Отменить изменения в параметрах раскладки';
		}
		
		public function redo():void
		{
			//Прерываем анимацию, если идет процесс анимации
			resetAll();
			
			vg.layouter.data = layouterParamsAfter;
			restoreNodesPos( nodesAfter );
			
			commitVisualGraphParamsAfter();
		}
		
		public function get redoDescription():String
		{
			return 'Изменить параметры раскладки';
		}
	}
}