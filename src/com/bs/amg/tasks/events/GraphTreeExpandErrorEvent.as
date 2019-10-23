package com.bs.amg.tasks.events
{
	import flash.events.Event;
	
	public class GraphTreeExpandErrorEvent extends Event
	{
		public static const ERROR : String = 'graphTreeExpandError';
		
		public var message : String;
		public var code    : int;
		public var nodeId  : String;
		
		public function GraphTreeExpandErrorEvent( type : String, nodeId : String, message : String, code : int )
		{
			super( type );
			
			this.nodeId  = nodeId;
			this.message = message;
			this.code    = code;
		}
		
		override public function clone() : Event
		{
			return new GraphTreeExpandErrorEvent( type, nodeId, message, code );
		}
	}
}