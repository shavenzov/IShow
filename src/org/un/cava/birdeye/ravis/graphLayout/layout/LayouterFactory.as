package org.un.cava.birdeye.ravis.graphLayout.layout
{
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;

	public class LayouterFactory
	{
		public static function create( vg : IVisualGraph, data : Object ) : ILayoutAlgorithm
		{
			var layouter : ILayoutAlgorithm;
			
			switch( data.type )
			{
				case ConcentricRadialLayouter.ID : layouter = new ConcentricRadialLayouter( vg, data );
					break;
				
				case ParentCenteredRadialLayouter.ID : layouter = new ParentCenteredRadialLayouter( vg, data );
					break;
				
				case CircularLayouter.ID : layouter = new CircularLayouter( vg, data );
					break;
				
				case HierarchicalLayouter.ID : layouter = new HierarchicalLayouter( vg, data );
					break;
				
				case ForceDirectedLayouter.ID : layouter = new ForceDirectedLayouter( vg, data );
					break;
				
				case BubbleLayouter.ID : layouter = new BubbleLayouter( vg, data );
					break;
			}
			
			return layouter;
		}
	}
}