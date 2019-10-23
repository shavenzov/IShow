package com.bs.amg.events
{
	import flash.events.Event;
	
	public class AMGErrorEvent extends Event
	{
		public static const ERROR : String = 'amgError';
		
		public var message   : String;
		public var errorCode : int;
		
		public function AMGErrorEvent( type : String, message : String, errorCode : int )
		{
			super( type );
			
			this.message   = message;
			this.errorCode = errorCode;
		}
		
		override public function clone() : Event
		{
			return new AMGErrorEvent( type, message, errorCode );
		}
	}
}