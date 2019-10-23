package com.controls
{
	import flash.text.TextFieldAutoSize;
	
	import mx.controls.Button;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	public class MultilineButton extends Button
	{
		public function MultilineButton()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			textField.multiline = true;
			textField.wordWrap = true;
			textField.autoSize = TextFieldAutoSize.LEFT;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			textField.y = (this.height-textField.height)>>1;
		}
	}
}