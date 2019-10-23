package org.un.cava.birdeye.ravis.components.renderers.nodes
{
	import flash.display.DisplayObject;
	
	import org.un.cava.birdeye.ravis.assets.Assets;
	
	public class OpenCardButton extends BaseButton
	{
		private var icon : DisplayObject;
		
		public function OpenCardButton()
		{
			super();
			
			icon = new Assets.FORM_ICON_SMALL();
			addChild( icon );
		}
	}
}