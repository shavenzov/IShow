package org.un.cava.birdeye.ravis.history
{
	import mx.managers.history.IHistoryOperation;
	import mx.utils.ObjectUtil;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	
	public class SimpleLayotParamChanged extends BaseVisualGraphOperation implements IHistoryOperation
	{
		/**
		 * Параметры компоновщика до изменений 
		 */		
		private var layouterParamsBefore : Object;
		
		/**
		 * Параметры компоновщика после изменений 
		 */		
		private var layouterParamsAfter  : Object;
		
		public function SimpleLayotParamChanged( vg : IVisualGraph )
		{
		  super( vg );
		}
		
		public function dumpBefore() : void
		{
			layouterParamsBefore = ObjectUtil.clone( vg.layouter.data );
		}
		
		public function dumpAfter() : void
		{
			layouterParamsAfter = ObjectUtil.clone( vg.layouter.data );
		}
		
		public function undo() : void
		{
			vg.layouter.data = layouterParamsBefore;
		}
		
		public function get undoDescription() : String
		{
			return 'Отменить изменения в параметрах раскладки';
		}
		
		public function redo()  :void
		{
			vg.layouter.data = layouterParamsAfter;
		}
		
		public function get redoDescription() : String
		{
			return 'Изменить параметры раскладки';
		}
	}
}