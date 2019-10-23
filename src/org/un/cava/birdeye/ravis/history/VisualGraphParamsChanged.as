package org.un.cava.birdeye.ravis.history
{
	import mx.managers.history.IHistoryOperation;
	import mx.utils.ObjectUtil;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	
	public class VisualGraphParamsChanged extends BaseVisualGraphOperation implements IHistoryOperation
	{
		private var dataBefore : Object;
		private var dataAfter  : Object;
		
		public function VisualGraphParamsChanged( vg : IVisualGraph )
		{
			super( vg );
		}
		
		public function dumpBefore() : void
		{
			dataBefore = ObjectUtil.clone( vg.data );
		}
		
		public function dumpAfter() : void
		{
			dataAfter = ObjectUtil.clone( vg.data );
		}
		
		public function undo():void
		{
		  vg.data = ObjectUtil.clone( dataBefore );
		}
		
		public function get undoDescription():String
		{
			return 'Отменить изменения параметров отображения графа';
		}
		
		public function redo():void
		{
		  vg.data = ObjectUtil.clone( dataAfter );
		}
		
		public function get redoDescription():String
		{
			return 'Изменить параметры отображения графа';
		}
	}
}