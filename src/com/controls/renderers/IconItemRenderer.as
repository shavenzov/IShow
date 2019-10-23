package com.controls.renderers
{
	import com.controls.CachedImage;
	
	import spark.components.supportClasses.ItemRenderer;
	
	public class IconItemRenderer extends ItemRenderer
	{
		private var _icon : CachedImage;
		
		public function IconItemRenderer()
		{
			super();
		}
		
		override protected function createChildren() : void
		{
			_icon = new CachedImage();
			addElement( _icon );
		}
		
		override public function set data(value:Object):void
		{
		  super.data = value;
		  
		  if ( data )
		  {
			  _icon.url = String( data );
		  }
		  
		  invalidateSize();
		  invalidateDisplayList();
		}
		
		private static const PADDING : Number = 10.0;
		
		override protected function measure() : void
		{
			super.measure();
			
			measuredWidth  = _icon.measuredWidth  + 2 * PADDING;
			measuredHeight = _icon.measuredHeight + 2 * PADDING;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			_icon.setActualSize( _icon.measuredWidth, _icon.measuredHeight );
			_icon.move( PADDING, PADDING );
		}
	}
}