package org.un.cava.birdeye.ravis.graphLayout.visual.events
{
	import flash.events.Event;
	
	public class VisualGraphRemoveObjectEvent extends Event
	{
		public static const REMOVE_OBJECT : String = 'removeObject';
		
		/**
		 * Массив IVisualNode, которые удаляются 
		 */		
		public var nodes : Array;
		
		/**
		 * Массив IVisualEdge, которые удаляются 
		 */		
		public var edges : Array;
		
		public function VisualGraphRemoveObjectEvent( type : String, nodes : Array, edges : Array )
		{
			super( type, false, true );
			
			this.nodes = nodes;
			this.edges = edges;
		}
		
		override public function clone() : Event
		{
			return new VisualGraphRemoveObjectEvent( type, nodes, edges );
		}
	}
}