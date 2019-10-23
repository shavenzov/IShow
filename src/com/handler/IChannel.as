package com.handler
{
	import com.events.ICustomEventDispatcher;
	
	public interface IChannel extends ICustomEventDispatcher
	{
		function repair() : void;
		function next()   : void;
	}
}