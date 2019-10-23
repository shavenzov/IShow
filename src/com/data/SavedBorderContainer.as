package com.data
{
	import mx.core.IDataRenderer;
	
	import spark.components.BorderContainer;
	
	public class SavedBorderContainer extends BorderContainer implements IDataRenderer
	{
		public function SavedBorderContainer()
		{
			super();
			load();
		}
		
		include "saved_object_inc.as";
	}
}