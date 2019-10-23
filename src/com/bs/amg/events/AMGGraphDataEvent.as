package com.bs.amg.events
{
	import com.amf.Call;
	
	import flash.events.Event;
	
	public class AMGGraphDataEvent extends Event
	{
		public static const GRAPH_DATA : String = 'graphData';
		
		public var data   : Object;
		public var call   : Call; 
		
		public function AMGGraphDataEvent( type : String, data : Object, call : Call )
		{
			super( type );
			this.data = data;
			this.call = call;
		}
		
		override public function clone() : Event
		{
			return new AMGGraphDataEvent( type, data, call );
		}
	}
}