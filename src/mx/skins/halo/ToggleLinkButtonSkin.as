/**
 * http://blog.flexexamples.com/2008/09/06/creating-a-toggleable-linkbutton-control-in-flex/
 */
package mx.skins.halo{
	import mx.skins.halo.LinkButtonSkin;
	
	public class ToggleLinkButtonSkin extends LinkButtonSkin {
		public function ToggleLinkButtonSkin() {
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w, h);
			
			var cornerRadius:Number = getStyle("cornerRadius");
			var rollOverColor:uint = getStyle("rollOverColor");
			var selectionColor:uint = getStyle("selectionColor");
			
			graphics.clear();
			
			if ( name != 'upSkin' && name != "disabledSkin" && name != "selectedDisabledSkin" )
			{
				graphics.lineStyle( 1.0, 0x9e9e9e );
			}
			
			switch (name) {
				case "upSkin":
					// Draw invisible shape so we have a hit area.
					drawRoundRect(
						0, 0, w, h, cornerRadius,
						0, 0);
					break;
				
				case "selectedOverSkin":
					drawRoundRect(
						0, 0, w, h, cornerRadius,
						rollOverColor, 1);
					break;
				
				case "selectedUpSkin":
				case "overSkin":
					drawRoundRect(
						0, 0, w, h, cornerRadius,
						rollOverColor, 1.0);
					break;
				
				
				case "selectedDownSkin":
				case "downSkin":
					drawRoundRect(
						0, 0, w, h, cornerRadius,
						selectionColor, 1);
					break;
				
				
				case "selectedDisabledSkin":
				case "disabledSkin":
					// Draw invisible shape so we have a hit area.
					drawRoundRect(
						0, 0, w, h, cornerRadius,
						0, 0);
					break;
			}
		}
	}
}