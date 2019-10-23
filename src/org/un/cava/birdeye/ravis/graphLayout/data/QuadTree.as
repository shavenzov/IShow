package org.un.cava.birdeye.ravis.graphLayout.data
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutDrawing;

	public class QuadTree
	{
		/**
		 * Список узлов может иметь тип Dictionary( INode ), Array( INode ), Vector.<INode> 
		 */		
		private var _nodes : *;
		
		/**
		 * Область для построения 
		 */		
		private var _bounds  : Rectangle;
		
		/**
		 * Корневой узел Дерева квадрантов  
		 */		
		public var root : QuadTreeNode;
		
		private var _layoutDrawing : ILayoutDrawing;
		
		public function QuadTree( nodes : *, bounds : Rectangle, layoutDrawing : ILayoutDrawing )
		{
		  super();
		  
		  _nodes         = nodes;
		  _bounds        = bounds;
		  _layoutDrawing = layoutDrawing;
		  
		  calculate();
		}
		
		private function calculate() : void
		{
			//Squarify the bounds.
			if ( _bounds.width > _bounds.height )
			{
				_bounds.height = _bounds.width;
			}
			else
			{
				_bounds.width = _bounds.height;
			}
			
			//Create the root node.
			    root = new QuadTreeNode();
			var node : INode;
			
			//Insert all points.
			for each( node in _nodes )
			{
				insert( root, node, _layoutDrawing.getRelCartCoordinates( node ), _bounds );
			}
		}
		
		// Recursively inserts the specified point p at the node n or one of its
		// descendants. The bounds are defined by [x1, x2] and [y1, y2].
		private function insert( n : QuadTreeNode, d : INode, pos : Point, bounds : Rectangle ) : void
		{
			if ( n.leaf )
			{
				if ( n.pos != null )
				{
					var nx : Number = n.pos.x;
					var ny : Number = n.pos.y;
					
					// If the point at this leaf node is at the same position as the new
					// point we are adding, we leave the point associated with the
					// internal node while adding the new point to a child node. This
					// avoids infinite recursion.
					if ( ( Math.abs( nx - pos.x ) + Math.abs( ny - pos.y ) ) < 0.01 )
					{
						insertChild( n, d, pos, bounds );
					}
					else
					{
						var nPoint : INode = n.point;
						    n.pos   = null;
							n.point = null;
							
							insertChild( n, nPoint, new Point( nx, ny ), bounds );
							insertChild( n, d, pos, bounds );
					}
				}
				else
				{
					n.pos   = pos;
					n.point = d;
				}	
			}
			else
			{
				insertChild( n, d, pos, bounds );
			}
		}
		
		// Recursively inserts the specified point [x, y] into a descendant of node
		// n. The bounds are defined by [x1, x2] and [y1, y2].
		private function insertChild( n : QuadTreeNode, d : INode, pos : Point, bounds : Rectangle ) : void
		{
			// Compute the split point, and the quadrant in which to insert p.
			var sx     : Number  = ( bounds.left + bounds.right )  * 0.5;
			var sy     : Number  = ( bounds.top  + bounds.bottom ) * 0.5;
			var right  : Boolean = pos.x >= sx;
			var bottom : Boolean = pos.y >= sy;
			var i      : int  = ( int( bottom ) << 1 ) + int( right );
			
			// Recursively insert into the child node.
			n.leaf = false;
			
			if ( n.nodes[ i ] == null )
			{
			  n = n.nodes[ i ] = new QuadTreeNode();
			}
			else
			{
				n = n.nodes[ i ];
			}
			
			// Update the bounds as we recurse.
			bounds = bounds.clone();
			
			if ( right )
			{
				bounds.left = sx;
			}
			else
			{
				bounds.right = sx;
			}
			
			if ( bottom )
			{
				bounds.top = sy;
			}
			else
			{
				bounds.bottom = sy;
			}
			
			insert( n, d, pos, bounds );
		}
		
		/** Перебор всех субквадрантов для указанного квадранта ( node ) 
		 * @param f - функция в которую передается текущий квадрант и его обрамляющая область f( node : QuadTreeNode, bounds : Rectangle )
		 * @param node
		 * @param bounds
		 * 
		 */		
		private function _visit( f : Function, node : QuadTreeNode, bounds : Rectangle ) : void
		{
			if ( ! f( node, bounds ) )
			{
				//var sx       : Number = ( bounds.left + bounds.right )  * 0.5;
				//var sy       : Number = ( bounds.top  + bounds.bottom ) * 0.5;
				var children : Array  = node.nodes;
				//var newRect  : Rectangle;
								
				//1-ый квадрант
				if ( children[ 0 ] )
				{
					/*newRect        = new Rectangle();
					newRect.left   = bounds.left;
					newRect.top    = bounds.top;
					newRect.right  = sx;
					newRect.bottom = sy;*/
					
					_visit( f, children[ 0 ], bounds );
				}
				
				//2-ой квадрант
				if ( children[ 1 ] )
				{
					/*newRect = new Rectangle();
					newRect.left   = sx;
					newRect.top    = bounds.top;
					newRect.right  = bounds.right;
					newRect.bottom = sy;*/
					
					_visit( f, children[ 1 ], bounds );
				}
				
				//3-й квадрант
				if ( children[ 2 ] )
				{
					/*newRect = new Rectangle();
					newRect.left   = bounds.left;
					newRect.top    = sy;
					newRect.right  = sx;
					newRect.bottom = bounds.bottom;*/
					
					_visit( f, children[ 2 ], bounds );
				}
				
				//4-й квадрант
				if ( children[ 3 ] )
				{
					/*newRect = new Rectangle();
					newRect.left   = sx;
					newRect.top    = sy;
					newRect.right  = bounds.right;
					newRect.bottom = bounds.bottom;*/
					
					_visit( f, children[ 3 ], bounds );
				}
			}
		}
		
		public function visit( f : Function ) : void
		{
			_visit( f, root, _bounds );
		}
		
		/*public function traceTree() : void
		{
			function _traceTree( node : QuadTreeNode, separator : String = '' ) : void
			{
				trace( separator, node );
				
				var subNode : QuadTreeNode;
				
				for each( subNode in node.nodes )
				{
					_traceTree( subNode, separator + '  ' );
				}
			}
			
			_traceTree( root );
		}*/
	}
}