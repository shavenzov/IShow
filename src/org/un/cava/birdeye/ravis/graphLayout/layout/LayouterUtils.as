package org.un.cava.birdeye.ravis.graphLayout.layout
{
	import flash.geom.Rectangle;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;

	public class LayouterUtils
	{
		/**
		 * Возвращает строковое описание раскладки 
		 * @param layouter
		 * @return 
		 * 
		 */		
		public static function getLayouterDescription( layouter : ILayoutAlgorithm ) : String
		{
			if ( layouter is ConcentricRadialLayouter )
			{
				return 'Круговая (стандартная)';
			}
			
			if ( layouter is ParentCenteredRadialLayouter )
			{
				return 'Круговая (от родителя)';
			}
			
			if ( layouter is CircularLayouter )
			{
				switch( CircularLayouter( layouter ).style )
				{
					case CircularLayouterStyle.SINGLE_CYCLE       : return 'Круговая (единый круг)';
					case CircularLayouterStyle.BICONNECTED_INSIDE : return 'Круговая (biconnected inside)';
					default                                       : return 'Круговая (неизвестная)';	
				}
				
				
			}
			
			if ( layouter is HierarchicalLayouter )
			{
				switch( HierarchicalLayouter( layouter ).orientation )
				{
					case LayoutOrientation.TOP_DOWN   : return 'Иерархическая (сверху вниз)';
					case LayoutOrientation.BOTTOM_UP  : return 'Иерархическая (снизу вверх)';
					case LayoutOrientation.LEFT_RIGHT : return 'Иерархическая (слева на право)';
					case LayoutOrientation.RIGHT_LEFT : return 'Иерархическая (справа на лево)';
					default                           : return 'Иерархическая (неизвестная)';	
				}
			}
			
			if ( layouter is ForceDirectedLayouter )
			{
				return 'Органическая';
			}
			
			if ( layouter is BubbleLayouter )
			{
				switch( BubbleLayouter( layouter ).orientation )
				{
					case LayoutOrientation.NONE       : return 'Пузырьковая (не направленная)';
					case LayoutOrientation.TOP_DOWN	  : return 'Пузырьковая (сверху вниз)';
					case LayoutOrientation.BOTTOM_UP  : return 'Пузырьковая (снизу вверх)';
					case LayoutOrientation.LEFT_RIGHT : return 'Пузырьковая (слева на право)';
					case LayoutOrientation.RIGHT_LEFT : return 'Пузырьковая (справа на лево)';
					default                           : return 'Пузырьковая (неизвестная)';	
				}
			}
			
			return 'Неизвестная';
		}
		
		public static function getAngularWidth( node : INode, length : Number ) : Number
		{
			var b : Rectangle = node.vnode.view.getBounds( node.vnode.view.parent );
			
			return Math.sqrt( b.width * b.width + b.height * b.height ) / length;
		}
		
		public static function getAngularWidth2( w : Number, h : Number, length : Number ) : Number
		{
			return Math.sqrt( w * w + h * h ) / length;
		}
		
		public static function getLinkLength( w : Number, h : Number, angW : Number ) : Number
		{
			if ( ( w == 0 ) || ( h == 0 ) )
			{
				return 0;
			}
			
			return Math.sqrt( w * w + h * h ) / angW;
		}
	}
}