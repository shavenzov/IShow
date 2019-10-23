package com.data
{
	import com.utils.StringUtils;
	
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	
	public class SavedUIComponent extends UIComponent implements IDataRenderer
	{
		public function SavedUIComponent()
		{
			super();
			load();
		}
		
		include "saved_object_inc.as";
	}
}