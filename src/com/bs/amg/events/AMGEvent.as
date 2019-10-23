package com.bs.amg.events
{
	import flash.events.Event;
	
	public class AMGEvent extends Event
	{
		/**
		 * Данные графа сохранены в облаке 
		 */		
		public static const GRAPH_SAVED : String = 'graphSaved';
		
		/**
		 * Данные графа в виде картинки сохранены 
		 */		
		public static const IMAGE_SAVED : String = 'imageSaved';
		
		/**
		 * Связь между объектами удалена 
		 */		
		public static const RELATION_REMOVED : String = 'relationRemoved';
		
		public function AMGEvent( type : String )
		{
			super( type );
		}
		
		override public function clone() : Event
		{
			return new AMGEvent( type );
		}
	}
}