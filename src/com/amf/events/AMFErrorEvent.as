package com.amf.events
{
	import com.amf.Call;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	public class AMFErrorEvent extends ErrorEvent
	{
		public static const ERROR : String = 'amfError';
		
		public var call  : Call;
		public var layer : uint;
		
		public function AMFErrorEvent( type : String, text : String, id : int, call : Call, layer : uint = 10 )
		{
			super( type, false, false, text, id );
			
			this.call = call;
			this.layer = layer;
		}
		
		override public function clone() : Event
		{
			return new AMFErrorEvent( type, text, errorID, call, layer );
		}
	}
}