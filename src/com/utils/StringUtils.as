package com.utils
{
	public class StringUtils
	{
		public static function replace( str : String, search : String, replace : String ) : String
		{
			return str.split(search).join(replace);
		}
	}
}