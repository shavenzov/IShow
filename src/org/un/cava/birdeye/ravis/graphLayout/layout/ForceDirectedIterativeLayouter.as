package org.un.cava.birdeye.ravis.graphLayout.layout {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.data.QuadTree;
	import org.un.cava.birdeye.ravis.graphLayout.data.QuadTreeNode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

	
	public class ForceDirectedIterativeLayouter extends IterativeBaseLayouter implements ILayoutAlgorithm
	{
		public function ForceDirectedIterativeLayouter( vg : IVisualGraph = null )
		{
			super( vg );
		}

		private var force : Point = new Point();
		 
		public var size : Point;
		public var alpha : Number;
		public var friction : Number = 0.9;
		public var linkDistance : Number = 120;
		public var linkStrength : Number = 0.5;
		public var charge : Number = - 2000.0;
		
		private var chargeDistance2 : Number = Infinity; 
		
		public function get chargeDistance() : Number
		{
			return Math.sqrt( chargeDistance2 );
		}
		
		public function set chargeDistance( value : Number ) : void
		{
			chargeDistance2 = value * value;
		}
		
		public var gravity : Number = 0.085;
		
		/**
		 * Чтобы избежать квадратное снижение производительности для больших графов,
		 * макет сила использует приближение Барнс-Hut, которая принимает O (N § п) за тик.
		 *  Для каждого тика, квадро-дерева создается для хранения текущие позиции узлов;
		 *  Затем для каждого узла, сумма заряд силой всех других узлов данного узла вычисляются.
		 *  Для кластеров узлов, которые находятся далеко, заряд силы аппроксимируется лечения расстояние кластер узлов как единый, увеличения узла.
		 *  Тета определяет точность вычисления: если отношение площади квадранте в квадрадерево к расстоянию между узла в центре квадранта в массы меньше тета,
		 *  все узлы в данном квадранте, рассматриваются как один, больше узел, а не вычисляется индивидуально.
		 * 
		 * To avoid quadratic performance slowdown for large graphs, the force layout uses the Barnes–Hut approximation which takes O(n log n) per tick.
		 *  For each tick, a quadtree is created to store the current node positions;
		 *  then for each node, the sum charge force of all other nodes on the given node are computed.
		 *  For clusters of nodes that are far away, the charge force is approximated by treating the distance cluster of nodes as a single, larger node.
		 *  Theta determines the accuracy of the computation: if the ratio of the area of a quadrant in the quadtree to the distance between a node to the quadrant's center of mass is less than theta,
		 *  all nodes in the given quadrant are treated as a single, larger node rather than computed individually. 
		 */			
		private var theta2 : Number = 0.64;
		
		public function get theta() : Number
		{
			return Math.sqrt( theta2 );
		}
		
		public function set theta( value : Number ) : void
		{
			theta2 = value * value;
		}
		
		private var distances : Dictionary = new Dictionary();
		private var strengths : Dictionary = new Dictionary();
		private var charges   : Dictionary = new Dictionary();
		private var weights   : Dictionary = new Dictionary();
		private var px        : Dictionary = new Dictionary();
		private var py        : Dictionary = new Dictionary();
		
		override protected function isStable() : Boolean
		{
			return alpha < 0.005;
		}
		
		private function start() : void
		{
			var e : IEdge;
			var s : IVisualNode;
			var t : IVisualNode;
			
			//Init weights
			for each( s in _vgraph.vnodes )
			{
				weights[ s.node ] = 0.0;
				px[ s.node ]      = s.x;
				py[ s.node ]      = s.y;
				charges[ s.node ] = charge;
			}
			
			for each( e in _vgraph.graph.edges )
			{
				weights[ e.node1 ] ++;
				weights[ e.node2 ] ++;
				distances[ e ] = linkDistance;
				strengths[ e ] = linkStrength;
			}
			
			size = new Point( _vgraph.width, _vgraph.height );
			
			resume();
		}
	    
		private function resume() : void
		{
			alpha = 0.1;
			iterations = 0;
		}
		
		private var iterations : int = 0;
		
		private function stop() : void
		{
			alpha = 0.0;
			iterations = 0.0;
		}
		
		override protected function calculateLayout():void
		{
			for ( var i : int = 0; i < 10; i ++ )
			tick();
		}
		
		private function dump() : void
		{
			var node : IVisualNode;
			var strNodes : Array = new Array();
			var str : String;
			var i   : int = 0;
			
			for each( node in _vgraph.vnodes )
			{
				str = '{';
				
				str += 'id:"' + node.node.stringid + '",'
				str += 'x:' + node.x + ',';
				str += 'y:' + node.y + ',';
				str += 'index:' + i;
				
				str += '}';
				
				strNodes.push( str );
				
				i ++;
			}
			
			var edge : IEdge;
			var strEdges : Array = new Array();
			
			for each( edge in _vgraph.graph.edges )
			{
				str = '{';
				
				str += 'source:"' + edge.node1.stringid + '",';
				str += 'target:"' + edge.node2.stringid + '",';
				str += 'id:"' + edge.stringid + '"';
				
				str += '}';
				
				strEdges.push( str );
			}
			
			trace( 'nodes Data' );
			
			for each( str in strNodes )
			{
				trace( str );
			}
			
			trace( 'edges data' );
			
			for each( str in strEdges )
			{
				trace( str );
			}
			
		}
		
		override public function layoutPass() : Boolean
		{
			//dump();
			
			start();
			
			return super.layoutPass();
		}
		
		private function tick() : void
		{
			alpha *= 0.99;
			
			if ( isStable() )
			{
				return;
			}
			
			// current edge
			var e : IEdge;
			// current source
			var s : IVisualNode;
			// current target
			var t : IVisualNode;
			
			// x-distance
			var x : Number;
			// y-distance
			var y : Number;
			
			// current distance
			var l : Number;
			// current force
			var k : Number;
			
			// -*- Проверено -*-
			
			// gauss-seidel relaxation for links
			for each( e in _vgraph.graph.edges )
			{
				s = e.node1.vnode;
				t = e.node2.vnode;
				
				x = t.x - s.x;
				y = t.y - s.y;
				
				l = x * x + y * y;
				
				if ( l > 0 )
				{
					l    = Math.sqrt( l );
					l    = alpha * strengths[ e ] * ( l - distances[ e ] ) / l;
					
					x   *= l;
					y   *= l;
					
					k    = weights[ s.node ] / ( weights[ t.node ] + weights[ s.node ] );
					t.x -= x * k;
					t.y -= y * k;
					
					k = 1 - k;
					
					s.x += x * k;
					s.y += y * k; 
				}
			}
			
			// apply gravity forces
			k = alpha * gravity;
			
			if ( k != 0 )
			{
				x = size.x / 2;
				y = size.y / 2;
				
				for each( s in _vgraph.vnodes )
				{
					s.x += ( x - s.x ) * k;
					s.y += ( y - s.y ) * k;
				}
			}
			
			// -*- Проверено -*-
			
			
			
			function repulse( quad : QuadTreeNode, bounds : Rectangle ) : Boolean
			{
				if ( quad.point != s )
				{
					var dx : Number = quad.cx - s.x;
					var	dy : Number = quad.cy - s.y;
					var	dw : Number = bounds.width;
					var dn : Number = dx * dx + dy * dy;
					var k  : Number;
					
					/* Barnes-Hut criterion. */
					if ( ( dw * dw / theta2 ) < dn )
					{
						if ( dn < chargeDistance2 )
						{
							k = quad.charge / dn;
							
							px[ s.node ] -= dx * k;
							py[ s.node ] -= dy * k;
							
							/*if ( ( px[ s.node ] > 10000 ) || ( py[ s.node ] > 10000 ) )
							{
								trace( i, px[ s.node ], py[ s.node ], dx, dy, dw, dn, k, quad.charge );
								trace( quad.cx, s.x, quad.cy, s.y, dx, dy );
							}*/
						}
						
						return true;
					}
					
					//trace( Boolean( quad.point && dn && dn < chargeDistance2 ) );
					
					if ( quad.point && Math.abs( dn ) > 0.00000000000001 && dn < chargeDistance2 )
					{
						k = quad.pointCharge / dn;
						px[ s.node ] -= dx * k;
						py[ s.node ] -= dy * k;
						
						/*if ( ( px[ s.node ] > 10000 ) || ( py[ s.node ] > 10000 ) )
						{
							trace( i, px[ s.node ], py[ s.node ], dx, dy, dw, dn, k, quad.pointCharge );
							trace( quad.cx, s.x, quad.cy, s.y, dx, dy );
						}*/
					}
				}
				
				return quad.charge == 0;
			}
			
			//compute quadtree center of mass and apply charge forces
			if ( charge != 0.0 )
			{
				/*var rect : Rectangle = _vgraph.getNodesGroupBoundsV();
				
				trace( rect.x, rect.y, rect.right, rect.bottom );
				trace( rect );*/
				var q : QuadTree = new QuadTree( _vgraph.graph.nodes, _vgraph.getNodesGroupBoundsV() );
				
				//q.traceTree();
				
				forceAccumulate( q.root, alpha, charges );
				
				for each( s in _vgraph.vnodes )
				{
					q.visit( repulse );
				}
			}
			
			// position verlet integration
			for each( s in _vgraph.vnodes )
			{
				//trace( s.x, s.y, x, y, px[ s.node ], py[ s.node ] );
				
				x = ( px[ s.node ] - s.x ) * friction;
				y = ( py[ s.node ] - s.y ) * friction;
				
				px[ s.node ] = s.x;
				py[ s.node ] = s.y;
				
				s.x -= x;
				s.y -= y;
				
				s.commit();
			}
			
			iterations ++;
			
			trace( 'alpha', iterations, alpha );
		}
		
		private function forceAccumulate( quad : QuadTreeNode, alpha : Number, charges : Dictionary ) : void
		{
			var cx  : Number = 0.0;
			var cy  : Number = 0.0;
			var c   : QuadTreeNode;
			
			quad.charge = 0.0;
			
			if ( ! quad.leaf )
			{
				for each( c in quad.nodes )
				{
					if ( c )
					{
						forceAccumulate( c, alpha, charges );
						quad.charge += c.charge;
						cx += c.charge * c.cx;
						cy += c.charge * c.cy;
					}
				}
			}
			
			if ( quad.point )
			{
				// jitter internal nodes that are coincident
				if ( ! quad.leaf )
				{
					quad.point.vnode.x += Math.random() - 0.5;
					quad.point.vnode.y += Math.random() - 0.5;
				}
				
				var k : Number = alpha * charges[ quad.point ];
				  
				quad.charge += k;
				quad.pointCharge = k;
				    
					cx += k * quad.point.vnode.x;
				    cy += k * quad.point.vnode.y;
			}
			
			quad.cx = cx / quad.charge;
			quad.cy = cy / quad.charge;
			
			//trace( 'quad', quad.charge, quad.pointCharge, quad.cx, quad.cy );
		}
		
		/*
		override public function layoutPass() : Boolean
		{
			var q : QuadTree = new QuadTree( _vgraph.graph.nodes, _vgraph.getNodesGroupBoundsV() );
			
			trace( 'test visit function' );
			
			var g : Graphics = Sprite( UIComponent( _vgraph ).getChildAt( 2 ) ).graphics;
			g.clear();
			
			q.visit( visit );    
			
			return true;
		}
		
		private function visit( node : QuadTreeNode, bounds : Rectangle ) : Boolean
		{
			trace( node, node ? node.pos : null, bounds );
			
			var g : Graphics = Sprite( UIComponent( _vgraph ).getChildAt( 2 ) ).graphics;
			g.lineStyle( 4.0, Math.random() * uint.MAX_VALUE );
			g.drawRect( bounds.left, bounds.top, bounds.width, bounds.height );
			
			if ( node.pos )
			{
				g.drawCircle( node.pos.x, node.pos.y, 18 );
			}
			
			return false;
		}
		*/
	}
}
