package org.un.cava.birdeye.ravis.graphLayout.visual.events
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

	public class VisualNodeEvent extends Event
	{
		public static const CLICK        : String = "nodeClick";
        public static const DOUBLE_CLICK : String = "nodeDoubleClick";
		public static const DRAG_START   : String = "nodeDragStart";
		public static const DRAG_END     : String = "nodeDragEnd";
		
		public static const EXPAND_CLICK : String = 'expandClick';
		public static const OPEN_CARD_CLICK : String = 'openCardClick';
		
		/**
		 * Событие сгенерировавшее это событие 
		 */		
		public var mouseEvent : MouseEvent;
		
		/**
		 * Узел асоциированный с событием 
		 */		
		public var node : IVisualNode;
       
		public function VisualNodeEvent( type:String, mouseEvent : MouseEvent, node : IVisualNode )
		{
			super( type );
			
			this.mouseEvent = mouseEvent;
			this.node       = node;
		}
		
		public override function clone():Event
		{
			return new VisualNodeEvent( type, mouseEvent, node );
		}
		
	}
}