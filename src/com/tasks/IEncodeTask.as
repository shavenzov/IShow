package com.tasks
{
	import com.thread.IRunnable;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public interface IEncodeTask extends IRunnable
	{
		function get outData() : ByteArray;
		function setInputData( data : BitmapData ) : void;
	}
}