package org.un.cava.birdeye.ravis.components.renderers.nodes
{
	import flash.display.DisplayObject;
	
	import org.un.cava.birdeye.ravis.assets.Assets;

	public class ExpandButton extends BaseButton
	{
		private var icon : DisplayObject;
		
		public function ExpandButton()
		{
			super();
			
			icon = new Assets.EXPAND_ICON();
			addChild( icon );
		}
	}
}