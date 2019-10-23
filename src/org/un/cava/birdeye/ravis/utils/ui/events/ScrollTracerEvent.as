package org.un.cava.birdeye.ravis.utils.ui.events
{
	import flash.events.Event;
	
	public class ScrollTracerEvent extends Event
	{
		public static const START_TRACING : String = 'START_TRACING';
		public static const STOP_TRACING  : String = 'STOP_TRACING';
		
		public static const START_MOVING  : String = 'START_MOVING';
		public static const STOP_MOVING   : String = 'STOP_MOVING';
		
		public function ScrollTracerEvent( type : String )
		{
			super( type );
		}
	}
}