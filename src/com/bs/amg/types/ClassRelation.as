package com.bs.amg.types
{
	

	public class ClassRelation
	{
		/**
		 * Идентификатор класса (типа) связи 
		 */		
		public var id   : String;
		public var name : String; 
		
		public function ClassRelation( data : Object )
		{
		   super();
			
		   id   = data.dbId;
		   name = data.name;	   
		}
	}
}