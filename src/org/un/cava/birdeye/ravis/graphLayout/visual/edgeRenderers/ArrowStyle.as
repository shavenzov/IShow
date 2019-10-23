package org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers
{
	public class ArrowStyle
	{
		public static const NONE            : String = 'none';
		public static const SINGLE          : String = 'single';
		public static const SINGLE_INVERTED : String = 'single_inverted';
		public static const DOUBLE          : String = 'double';
		
		public static const ARROW_STYLES : Array = [ NONE, SINGLE, SINGLE_INVERTED, DOUBLE ];
		public static const DEFAULT_ARROW_STYLE : String = SINGLE;
		
		public static function check( style : String ) : String
		{
			for each( var s : String in ARROW_STYLES )
			{
				if ( style == s )
				{
					return s;
				}
			}
			
			return DEFAULT_ARROW_STYLE;
		}
		
	}
}