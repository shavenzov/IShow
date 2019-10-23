package com.bs.amg.events
{
	import flash.events.Event;
	
	public class AMGAllIconsEvent extends Event
	{
		public static const GET_ALL_ICONS : String = 'GET_ALL_ICONS';
		
		public var icons : Array;
		
		public function AMGAllIconsEvent( type : String, icons : Array )
		{
			super( type );
			
			this.icons = icons;
		}
		
		override public function clone() : Event
		{
			return new AMGAllIconsEvent( type, icons );
		}
	}
}