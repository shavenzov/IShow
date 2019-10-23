package org.un.cava.birdeye.ravis.graphLayout.visual
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;

	public class VisualDefaults
	{
		/**
		 * Стиль отрисовки узлов по умолчанию 
		 */		
		public static const edgeStyle : Object = {
			thickness:1,
			alpha:1.0,
			color:0x008B8B,
			pixelHinting:false,
			scaleMode:LineScaleMode.NORMAL,
			caps:CapsStyle.NONE,
			joints:JointStyle.MITER,
				miterLimit:3
		};
	}
}