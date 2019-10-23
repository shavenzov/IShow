package com.data
{
	import com.utils.StringUtils;
	
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IDataRenderer;
	
	import spark.components.TitleWindow;
	
	public class BaseSavedTitleWindow extends TitleWindow implements IDataRenderer
	{
		public function BaseSavedTitleWindow()
		{
			super();
			load();
		}
		
		include "saved_object_inc.as";
	}
}