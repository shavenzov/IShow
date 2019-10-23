package com.bs.amg.events
{
	import flash.events.Event;
	
	public class AMGAddRelationEvent extends Event
	{
		public static const ADD_RELATION : String = 'addRelation';
		
		public var relationId : String;
		
		public function AMGAddRelationEvent( type : String, relationId : String )
		{
			super( type );
			
			this.relationId = relationId;
		}
		
		override public function clone() : Event
		{
			return new AMGAddRelationEvent( type, relationId );
		}
	}
}