package org.un.cava.birdeye.ravis.history
{
	import mx.core.IDataRenderer;
	import mx.managers.history.IHistoryOperation;
	import mx.utils.ObjectUtil;

	public class SimpleDataParamChanged implements IHistoryOperation
	{
		private var dataItem : IDataRenderer;
		
		private var dataBefore : Object;
		private var dataAfter  : Object;
		
		public function SimpleDataParamChanged( dataItem : IDataRenderer )
		{
		  super();
		  this.dataItem = dataItem;
		}
		
		public function dumpBefore() : void
		{
			dataBefore = ObjectUtil.clone( dataItem.data );
		}
		
		public function dumpAfter() : void
		{
			dataAfter = ObjectUtil.clone( dataItem.data );
		}
		
		public function undo() : void
		{
			dataItem.data = ObjectUtil.clone( dataBefore );
		}
		
		public function get undoDescription() : String
		{
			return 'Отменить изменения в параметрах';
		}
		
		public function redo()  :void
		{
			dataItem.data = ObjectUtil.clone( dataAfter );
		}
		
		public function get redoDescription() : String
		{
			return 'Изменить параметры';
		}
		
		public function get dispatchChanged() : Boolean
		{
			return false;
		}
	}
}