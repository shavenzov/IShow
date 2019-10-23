package org.un.cava.birdeye.ravis.graphLayout.visual.events
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
    
    public class VisualEdgeEvent extends Event
    {
        public static const CLICK        : String = "edgeClick";
        public static const ROLL_OVER    : String = "edgeRollOver";
        public static const ROLL_OUT     : String = "edgeRollOut";
		public static const DOUBLE_CLICK : String = "edgeDoubleClick";
        
        public var edge:IVisualEdge;
        
		/**
		 * Событие сгенерировавшее это событие 
		 */		
		public var mouseEvent : MouseEvent;
        
        public function VisualEdgeEvent( type : String, edge : IVisualEdge, mouseEvent : MouseEvent )
        {
            super( type );
            this.edge = edge;
            this.mouseEvent = mouseEvent;
        }
        
        public override function clone() : Event
        {
            return new VisualEdgeEvent( type, edge, mouseEvent );
        }
        
    }
}