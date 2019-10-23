package org.un.cava.birdeye.ravis.graphLayout.visual.events
{
	import flash.events.Event;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	
	public class VisualGraphCreateEdgeEvent extends Event
	{
		public static const CREATE_EDGE : String = 'createEdge';
		
		public var node1 : IVisualNode;
		public var node2 : IVisualNode;
		
		public function VisualGraphCreateEdgeEvent( type : String, node1 : IVisualNode, node2 : IVisualNode )
		{
			super( type, false, true );
			
			this.node1 = node1;
			this.node2 = node2;
		}
		
		override public function clone() : Event
		{
			return new VisualGraphCreateEdgeEvent( type, node1, node2 );
		}
	}
}