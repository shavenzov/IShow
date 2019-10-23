package org.un.cava.birdeye.ravis.graphLayout.layout
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;

	public interface ILayoutDrawing
	{
		function get nodeCartCoordinates() : Dictionary;
		function get nodePolarRs() : Dictionary;
		function get nodePolarPhis() : Dictionary;
		
		function get originOffset() : Point;
		function set originOffset( o : Point ) : void;
		
		function get centerOffset() : Point;
		function set centerOffset( o : Point ) : void;
		
		function get centeredLayout() : Boolean;
		function set centeredLayout( c : Boolean ) : void;
		
		function setPolarCoordinates( n : INode, polarR : Number, polarPhi : Number ) : void;
		function setCartCoordinates( n : INode, p : Point ) : void;
		function getPolarR( n : INode ) : Number;
		function getPolarPhi( n : INode) : Number;
		function getRelCartCoordinates( n : INode ) : Point;
		function getAbsCartCoordinates( n : INode ) : Point;
		
		function add( l : ILayoutDrawing ) : void;
		
		/**
		 * Смещает координаты 
		 * @param delta
		 * 
		 */		
		function offset( delta : Point ) : void;
		function scale( value : Number ) : void;
	}
}