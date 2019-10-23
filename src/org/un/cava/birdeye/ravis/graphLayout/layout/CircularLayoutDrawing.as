package org.un.cava.birdeye.ravis.graphLayout.layout
{
	import flash.utils.Dictionary;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IGTree;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;

	public class CircularLayoutDrawing extends BaseLayoutDrawing
	{
		public var biconnectedNodes     : Dictionary;
		public var singleConnectedNodes : Dictionary;
		
		public var indexes : Dictionary;
		
		public function CircularLayoutDrawing()
		{
			super();
		}
		
		public function initialize( tree : IGTree ) : void
		{
			biconnectedNodes     = new Dictionary();
			singleConnectedNodes = new Dictionary();
			indexes              = new Dictionary();
			
			var node       : INode;
			var noChildren : int;
			
			for each( node in tree.nodes )
			{
				noChildren = tree.getNoChildren( node );
				
				if ( ( noChildren > 0 ) && ( node.inEdges.length > 1 ) )
				{
					biconnectedNodes[ node ] = node;
				}
				else
				{
					singleConnectedNodes[ node ] = node;
				}
			}
		}
	}
}