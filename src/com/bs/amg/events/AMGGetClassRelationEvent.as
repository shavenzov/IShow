package com.bs.amg.events
{
	import com.bs.amg.types.ClassRelation;
	
	import flash.events.Event;
	
	public class AMGGetClassRelationEvent extends Event
	{
		public static const GET_CLASS_RELATIONS : String = 'getClassRelations';
		
		public var relations : Array;
		
		public function AMGGetClassRelationEvent( type : String, relations : Array )
		{
			super( type );
			
			this.relations = relations;
		}
		
		override public function clone() : Event
		{
			return new AMGGetClassRelationEvent( type, relations );
		}
	}
}