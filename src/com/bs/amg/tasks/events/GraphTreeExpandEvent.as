package com.bs.amg.tasks.events
{
	import com.bs.amg.tasks.NodeExpandResult;
	
	import flash.events.Event;
	
	public class GraphTreeExpandEvent extends Event
	{
		public static const EXPANDED : String = 'treeExpanded';
		
		/**
		 * Результат выполнения раскрытия узлов 
		 */		
		public var result : Vector.<NodeExpandResult>
		
		public function GraphTreeExpandEvent( type : String, result : Vector.<NodeExpandResult> )
		{
			super( type, false, true );
			
			this.result = result;
		}
		
		override public function clone() : Event
		{
			return new GraphTreeExpandEvent( type, result );
		}
	}
}