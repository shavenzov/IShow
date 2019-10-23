package com.thread.events
{
	import flash.events.Event;
	
	public class StatusChangedEvent extends Event
	{
		public static const STATUS_CHANGED : String = 'statusChanged';
		
		public var status : int;
		public var statusString : String;
		
		public function StatusChangedEvent( type : String, status : int, statusString : String )
		{
			super(type);
			this.status = status;
			this.statusString = statusString;
		}
		
		override public function clone() : Event
		{
			return new StatusChangedEvent( type, status, statusString );
		}
	}
}