package org.un.cava.birdeye.ravis.graphLayout.data
{
	import flash.geom.Point;

	public class QuadTreeNode
	{
		public var leaf   : Boolean = true;
		public var nodes  : Array = new Array();
		public var point  : INode;
		public var pos    : Point;
		
		public var charge : Number = 0.0;
		public var pointCharge : Number = 0.0;
		
		public var cx     : Number = 0.0;
		public var cy     : Number = 0.0;
		
		public function QuadTreeNode()
		{
		  super();
		}
		
		public function toString() : String
		{
			var str : String = 'leaf="' + leaf.toString() + '"; ';
			    str += 'nodes="' + ( nodes ? nodes.length : 'null' ) + '"; ';
			    str += 'point="' + ( point ? point.stringid : 'null' ) + '"; ';
				str += 'pos="' + pos + '"; ';
				str += 'cx="' + cx + '"; ';
				str += 'cy="' + cy + '"; ';
				str += 'charge="' + charge + '"; ';
				str += 'pointCharge="' + pointCharge + '"; ';
				
			return str;	
		}
	}
}