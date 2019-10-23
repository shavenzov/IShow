package mx.managers.history.events
{
	import flash.events.Event;
	
	import mx.managers.history.IHistoryOperation;
	
	public class HistoryEvent extends Event
	{
		public static const ADD    : String = 'add';
		//public static const REMOVE : String = 'remove';
		public static const UNDO   : String = 'undo';
		public static const REDO   : String = 'redo';
		
		/**
		 * Операция связанная с этим событием 
		 */		
		public var operation : IHistoryOperation;
		
		public function HistoryEvent( type : String, operation : IHistoryOperation )
		{
			super( type );
			this.operation = operation;
		}
		
		override public function clone() : Event
		{
			return new HistoryEvent( type, operation );
		}
	}
}