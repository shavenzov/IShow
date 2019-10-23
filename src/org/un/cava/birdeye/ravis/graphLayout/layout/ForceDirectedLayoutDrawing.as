package org.un.cava.birdeye.ravis.graphLayout.layout
{
	import flash.utils.Dictionary;

	public class ForceDirectedLayoutDrawing extends BaseLayoutDrawing
	{
		public var distances : Dictionary;
		public var strengths : Dictionary;
		public var charges   : Dictionary;
		public var weights   : Dictionary;
		public var pPos      : Dictionary;
		
		public function ForceDirectedLayoutDrawing()
		{
			super();
			
			distances = new Dictionary();
			strengths = new Dictionary();
			charges   = new Dictionary();
			weights   = new Dictionary();
			pPos      = new Dictionary();
		}
	}
}