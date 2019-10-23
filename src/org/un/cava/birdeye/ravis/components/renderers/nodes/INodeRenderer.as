package org.un.cava.birdeye.ravis.components.renderers.nodes
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import mx.core.IUIComponent;

	public interface INodeRenderer extends IUIComponent
	{
		function getVisualBounds( targetCoordinateSpace : DisplayObject  ) : Rectangle;
		
		function get visualWidth()  : Number;
		function get visualHeight() : Number;
		
		function get progress() : Boolean;
		function set progress( value : Boolean ) : void;
		
		function get iconResized() : Boolean;
		
		function get selected() : Boolean;
		function set selected( value : Boolean ) : void;
		function get hovered() : Boolean;
		function set hovered( value : Boolean ) : void;
		
		function refresh() : void;
	}
}