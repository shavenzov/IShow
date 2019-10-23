package org.un.cava.birdeye.ravis.graphLayout.layout
{
	public class LayoutOrientation
	{
		/**
		 * Граф не направленный ( не имеет какого-то конкретного определенного направления ) 
		 */		
		public static const NONE : uint = 0;
		
		/**
		 * Set the orientation to this to result in a
		 * left to right layout.
		 * */
		public static const LEFT_RIGHT:uint = 1;
		
		/**
		 * Set the orientation to this to result in a
		 * right to left layout.
		 * */		
		public static const RIGHT_LEFT:uint = 2;
		
		/**
		 * Set the orientation to this to result in a
		 * top down layout.
		 * */
		public static const TOP_DOWN:uint = 3;
		
		/**
		 * Set the orientation to this to result in a
		 * bottom up layout.
		 * */
		public static const BOTTOM_UP:uint = 4;
	}
}