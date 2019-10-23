package org.un.cava.birdeye.ravis.containers
{
	import mx.core.UIComponent;
	
	public class Container extends UIComponent
	{
		public function Container()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			var child : UIComponent;
			
			for ( var i : int = 0; i < numChildren; i ++ )
			{
				child = UIComponent( getChildAt( i ) );
				child.setActualSize( child.getExplicitOrMeasuredWidth(), child.getExplicitOrMeasuredHeight() );
			}
		}
	}
}