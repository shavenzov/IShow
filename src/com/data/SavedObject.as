package com.data
{
	import com.utils.StringUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IDataRenderer;
	
	
	public class SavedObject extends EventDispatcher implements IDataRenderer
	{
		public function SavedObject()
		{
			super();
			
			load();
		}
		
		include "saved_object_inc.as";
	}
}