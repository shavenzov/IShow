package com.bs.amg
{
	public class UnisAPI
	{
		private static var _impl : UnisAPIImplementation;
		
		public static function get impl() : UnisAPIImplementation
		{
			if ( _impl == null )
			{
			  _impl = new UnisAPIImplementation();	
			}
		    
			return _impl;
		}
	}
}