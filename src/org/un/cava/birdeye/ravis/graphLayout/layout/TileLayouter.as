package org.un.cava.birdeye.ravis.graphLayout.layout
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	
	public class TileLayouter extends BaseLayouter
	{
		private var _nodes : Vector.<INode>;
		
		private static const HORIZONTAL_GAP : Number = 16.0;
		private static const VERTICAL_GAP   : Number = 16.0;
		
		public function TileLayouter( vg : IVisualGraph = null, data : Object = null )
		{
			super( vg, data );
		}
		
		/**
		 * Список узлов для раскладки 
		 * @return 
		 * 
		 */		
		public function get nodes() : Vector.<INode>
		{
			return _nodes;
		}
		
		public function set nodes( value : Vector.<INode> ) : void
		{
			_nodes = value;
		}
		
		override protected function get actualNodes() : *
		{
			return _nodes ? _nodes : graph.nodes;
		}
		
		override public function calculate() : void
		{
			currentDrawing = new BaseLayoutDrawing();
			
			var nn : Vector.<INode> = actualNodes;
			
			//Сортируем узлы
			nn = Graph.sortNodes( nn );
			
			//Количество узлов в одной строке
			var numRows    : int = Math.floor( Math.sqrt( nn.length ) );
			//Количество столбцов
			var numColumns : int = Math.ceil( nn.length / numRows );
			
			//Максимальная ширина узла
			var maxWidth : Number = 0.0;
			
			//Максимальная высота узла
			var maxHeight : Number = 0.0;
			
			var node   : INode;
			var bounds : Rectangle;
			
			for each( node in nn )
			{
				bounds    = node.vnode.view.getBounds( node.vnode.view.parent );
				maxWidth  = Math.max( bounds.width, maxWidth );
				maxHeight = Math.max( bounds.height, maxHeight );
			}
			
			//Компоновка
			var x       : Number;
			var y       : Number;
			var cRow    : int;
			var cColumn : int;
			//Индекс текущего узла
			var index   : int = 0;
			
			loop : for( cRow = 0; cRow < numRows; cRow ++ ) 
			{
				//Номер строки
				for ( cColumn = 0; cColumn < numColumns; cColumn ++ )
				{
					node   = nn[ index ];
					bounds = node.vnode.view.getBounds( node.vnode.view.parent );
					
					x = cColumn * maxWidth + ( maxWidth - bounds.width ) / 2.0 + HORIZONTAL_GAP;
					y = cRow * maxHeight + VERTICAL_GAP;
					
					currentDrawing.setCartCoordinates( node, new Point( x, y ) );
					
					index ++;
					
					//Если следующего узла не существует, то завершаем построение
					if ( index >= nn.length )
					{
						break loop;
					}
				}
			}
			
			super.calculate();
		}
		
		override public function get needRoot() : Boolean
		{
			return false;
		}
	}
}