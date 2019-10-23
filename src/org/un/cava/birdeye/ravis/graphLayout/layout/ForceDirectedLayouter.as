package org.un.cava.birdeye.ravis.graphLayout.layout {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.data.QuadTree;
	import org.un.cava.birdeye.ravis.graphLayout.data.QuadTreeNode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

	
	public class ForceDirectedLayouter extends BaseAsynchronousLayouter implements ILayoutAlgorithm
	{   
		public static const ID : String = "ForceDirectedLayouter";
		
		/**
		 * Значение alpha при котором наступает стабилизация раскладки 
		 */		
		private static const STABLE_LAYOUT_ALPHA : Number = 0.005;
		
		/**
		 * Количество итераций необходимых для стабилизации раскладки 
		 */		
		private static const NUM_ITERATIONS : int = 298;
		
		private var size : Point;
		private var alpha : Number;
		
		/*
		private var friction : Number = 0.9;
		private var linkDistance : Number = 120;
		private var linkStrength : Number = 0.5;
		private var charge : Number = - 2000.0;
		private var chargeDistance2 : Number = Infinity;
		private var gravity : Number = 0.085;
		private var theta2 : Number = 0.64;
		*/
		
		private var _currentDrawing : ForceDirectedLayoutDrawing;
		
		public function ForceDirectedLayouter( vg : IVisualGraph, data : Object = null )
		{
			super( vg, data );
		}
		
		private static const DEFAULT_FRICTION        : Number = 0.9;
		private static const DEFAULT_LINK_DISTANCE   : Number = 160.0;
		private static const DEFAULT_LINK_STRENGTH   : Number = 0.5;
		private static const DEFAULT_CHARGE          : Number = - 1000.0;
		private static const DEFAULT_CHARGE_DISTANCE : Number = Infinity;
		private static const DEFAULT_GRAVITY         : Number = 0.085;
		private static const DEFAULT_THETA           : Number = 0.8;
		
		/**
		 * Словарик связей между объектами 
		 */		
		private var _edges : Dictionary;
		
		override protected function setDefaults() : void
		{
			super.setDefaults();
			
			_data.type = ID;
			
			if ( ! _data.hasOwnProperty( 'friction' ) )
			{
				_data.friction = DEFAULT_FRICTION;
			}
			
			if ( ! _data.hasOwnProperty( 'linkDistance' ) )
			{
				_data.linkDistance = DEFAULT_LINK_DISTANCE;
			}
			
			if ( ! _data.hasOwnProperty( 'linkStrength' ) )
			{
				_data.linkStrength = DEFAULT_LINK_STRENGTH;
			}
			
			if ( ! _data.hasOwnProperty( 'charge' ) )
			{
				_data.charge = DEFAULT_CHARGE;
			}
			
			if ( ! _data.hasOwnProperty( 'chargeDistance' ) )
			{
				_data.chargeDistance  = DEFAULT_CHARGE_DISTANCE;
				_data.chargeDistance2 = DEFAULT_CHARGE_DISTANCE * DEFAULT_CHARGE_DISTANCE;
			}
			
			if ( ! _data.hasOwnProperty( 'gravity' ) )
			{
				_data.gravity = DEFAULT_GRAVITY;
			}
			
			if ( ! _data.hasOwnProperty( 'theta' ) )
			{
				_data.theta  = DEFAULT_THETA;
				_data.theta2 = DEFAULT_THETA * DEFAULT_THETA;
			}
		}
		
		public function get friction() : Number
		{
		   return _data.friction;	
		}
		
		public function set friction( value : Number ) : void
		{
		  if ( value != friction )
		  {
			  calculationSuspend();
			  _data.friction = value;
			  sendChange();
		  }	
		}
		
		/**
		 * If distance is specified, sets the target distance between linked nodes to the specified value.
		 *  If distance is not specified, returns the layout's current link distance, which defaults to 120.
		 *  If distance is a constant, then all links are the same distance.
		 *  Otherwise, if distance is a function, then the function is evaluated for each link (in order), being passed the link and its index, with the this context as the force layout;
		 *  the function's return value is then used to set each link's distance. The function is evaluated whenever the layout starts. Typically, the distance is specified in pixels;
		 *  however, the units are arbitrary relative to the layout's size.
         * Links are not implemented as "spring forces", as is common in other force-directed layouts, but as weak geometric constraints.
		 *  For each tick of the layout, the distance between each pair of linked nodes is computed and compared to the target distance;
		 *  the links are then moved towards each other, or away from each other, so as to converge on the desired distance. 
		 * This method of constraints relaxation on top of position Verlet integration is vastly more stable than previous methods using spring forces, and also allows for the flexible implementation of other constraints in the tick event listener, such as hierarchical layering. 
		 * 
		 */		
		public function get linkDistance() : Number
		{
		  return _data.linkDistance;
		}
		
		public function set linkDistance( value : Number ) : void
		{
			if ( value != linkDistance )
			{
				calculationSuspend();
				_data.linkDistance = value;
				sendChange();
			}
		}
		
		/**
		 * If strength is specified, sets the strength (rigidity) of links to the specified value in the range [0,1]. 
		 * If strength is not specified, returns the layout's current link strength, which defaults to 1.
		 * If strength is a constant, then all links have the same strength.
		 * Otherwise, if strength is a function, then the function is evaluated for each link (in order), being passed the link and its index, with the this context as the force layout;
		 * the function's return value is then used to set each link's strength. The function is evaluated whenever the layout starts.
		 * 
		 */		
		public function get linkStrength() : Number
		{
			return _data.linkStrength;
		}
		
		public function set linkStrength( value : Number ) : void
		{
			if ( value != linkStrength )
			{
				calculationSuspend();
				_data.linkStrength = value;
				sendChange();
			}
		}
		
		/**
		 * If charge is specified, sets the charge strength to the specified value.
		 * If charge is not specified, returns the current charge strength, which defaults to - 2000.
		 * If charge is a constant, then all nodes have the same charge.
		 * Otherwise, if charge is a function, then the function is evaluated for each node (in order), being passed the node and its index, with the this context as the force layout; the function's return value is then used to set each node's charge. The function is evaluated whenever the layout starts.
         * A negative value results in node repulsion, while a positive value results in node attraction.
		 * For graph layout, negative values should be used; for n-body simulation, positive values can be used.
		 * All nodes are assumed to be infinitesimal points with equal charge and mass.
		 * Charge forces are implemented efficiently via the Barnes–Hut algorithm, computing a quadtree for each tick.
		 * Setting the charge force to zero disables computation of the quadtree, which can noticeably improve performance if you do not need n-body forces. 
		 * 
		 */		
		public function get charge() : Number
		{
			return _data.charge;
		}
		
		public function set charge( value : Number ) : void
		{
			if ( value != charge )
			{
				calculationSuspend();
				_data.charge = value;
				sendChange();
			}
		}
		
		/**
		 * If distance is specified, sets the maximum distance over which charge forces are applied.
		 * If distance is not specified, returns the current maximum charge distance, which defaults to infinity.
		 * Specifying a finite charge distance improves the performance of the force layout and produces a more localized layout;
		 * distance-limited charge forces are especially useful in conjunction with custom gravity.
		 * For an example, see “Constellations of Directors and their Stars” (The New York Times). 
		 * 
		 */		
		public function get chargeDistance() : Number
		{
			return _data.chargeDistance;
		}
		
		public function set chargeDistance( value : Number ) : void
		{
			if ( value != chargeDistance )
			{
				calculationSuspend();
				
				_data.chargeDistance  = value;
				_data.chargeDistance2 = value * value;
				
				sendChange();
			}
		}
		
		private function get chargeDistance2() : Number
		{
			return _data.chargeDistance2;
		}
		
		/**
		 * If gravity is specified, sets the gravitational strength to the specified value.
		 * If gravity is not specified, returns the current gravitational strength, which defaults to 0.1.
		 * The name of this parameter is perhaps misleading; it does not corresponding to physical gravity (which can be simulated using a positive charge parameter).
		 * Instead, gravity is implemented as a weak geometric constraint similar to a virtual spring connecting each node to the center of the layout's size.
		 * This approach has nice properties: near the center of the layout, the gravitational strength is almost zero, avoiding any local distortion of the layout;
		 * as nodes get pushed farther away from the center, the gravitational strength becomes strong in linear proportion to the distance.
		 * Thus, gravity will always overcome repulsive charge forces at some threshold, preventing disconnected nodes from escaping the layout.
         * Gravity can be disabled by setting the gravitational strength to zero.
		 * If you disable gravity, it is recommended that you implement some other geometric constraint to prevent nodes from escaping the layout, such as constraining them within the layout's bounds.
		 */		
		public function get gravity() : Number
		{
			return _data.gravity;
		}
		
		public function set gravity( value : Number ) : void
		{
			if ( value != gravity )
			{
				calculationSuspend();
				_data.gravity = value;
				
				sendChange();
			}
		}
		
		/**
		 * If theta is specified, sets the Barnes–Hut approximation criterion to the specified value.
		 * If theta is not specified, returns the current value, which defaults to 0.8.
		 * Unlike links, which only affect two linked nodes, the charge force is global: every node affects every other node, even if they are on disconnected subgraphs.
         * To avoid quadratic performance slowdown for large graphs, the force layout uses the Barnes–Hut approximation which takes O(n log n) per tick.
		 * For each tick, a quadtree is created to store the current node positions; then for each node, the sum charge force of all other nodes on the given node are computed.
		 * For clusters of nodes that are far away, the charge force is approximated by treating the distance cluster of nodes as a single, larger node.
		 * Theta determines the accuracy of the computation: if the ratio of the area of a quadrant in the quadtree to the distance between a node to the quadrant's center of mass is less than theta, all nodes in the given quadrant are treated as a single, larger node rather than computed individually.
		 * 
		 */		
		public function get theta() : Number
		{
			return _data.theta;
		}
		
		public function set theta( value : Number ) : void
		{
			if ( theta != value )
			{
				calculationSuspend();
				
				_data.theta  = value;
				_data.theta2 = value * value;
				
				sendChange();
			}
		}
		
		private function get theta2() : Number
		{
			return _data.theta2;
		}
		
		/**
		 * Переопределяем эти методы для совместимости с интерфейсом ILayoutAlgorithm 
		 * @return 
		 * 
		 */		
		override public function get linkLength() : Number
		{
			return linkDistance;
		}
		
		override public function set linkLength( value : Number ) : void
		{
			var k : Number = value / linkDistance;
			
			linkDistance = value;
			charge      *= k * 1.25;
			
			sendChange();
		}
		
		private function get isStable() : Boolean
		{
			return alpha < STABLE_LAYOUT_ALPHA;
		}
		
		override public function init() : void
		{
			if ( autoFitEnabled )
			{
				calcAutofitParams();
			}
			
			super.currentDrawing = _currentDrawing = new ForceDirectedLayoutDrawing();
			
			resetAll();
			
			_stree = graph.getTree( root );
			_edges = new Dictionary();
			
			var e : IEdge;
			var s : INode;
			var t : INode;
			var p : Point; 
			
			size  = _vgraph.center;
			
			//Init weights
			for each( s in _stree.nodes )
			{
				p = new Point( s.vnode.x, s.vnode.y )
					
				if ( autoFitEnabled )
				{
					if ( fitToWindow )
					{
						if ( p.x > _vgraph.width )
						{
							p.x = size.x;
						}
						
						if ( p.y > _vgraph.height )
						{
							p.y = size.y;
						}
					}
				}
				
				_currentDrawing.nodeCartCoordinates[ s ] = p;
				_currentDrawing.weights[ s ]             = 0.0;
				_currentDrawing.pPos[ s ]                = p.clone();
				_currentDrawing.charges[ s ]             = charge;
				
				//Создаем список связей присутствующих в дереве графов
				for each( e in s.inEdges )
				{
					if ( _edges[ e ] == null )
					{
						_edges[ e ] == e;
					}
				}
			}
			
			for each( e in _edges )
			{
				_currentDrawing.weights[ e.node1 ] ++;
				_currentDrawing.weights[ e.node2 ] ++;
				_currentDrawing.distances[ e ] = linkDistance;
				_currentDrawing.strengths[ e ] = linkStrength;
			}
			
			alpha = 0.1;
			
			_total    = NUM_ITERATIONS;
			_progress = 0;
			_numIterationsPerTick = ( NUM_ITERATIONS * 4 ) / _stree.noNodes;
		}
		
		private function calcAutofitParams() : void
		{
			/*if ( fitToWindow )
			{
				var bigSide   : Number = Math.max( _vgraph.width, _vgraph.height );
				var smallSide : Number = Math.min( _vgraph.width, _vgraph.height );
				var side      : Number = smallSide + ( bigSide - smallSide ) / 1.86;
				
				var k : Number = Math.sqrt( _graph.noNodes / ( side * side ) );
				
				charge  = - 10.0 / k;
				gravity = 100 * k;
			}
			else
			{*/
				charge       = DEFAULT_CHARGE;
				gravity      = DEFAULT_GRAVITY;
			//}
			
			linkDistance = DEFAULT_LINK_DISTANCE;
		}
	    
		override protected function tick() : void
		{
			//var time : Number = getTimer();
			
			alpha *= 0.99;
			
			var vn : IVisualNode;
			
			// current edge
			var e : IEdge;
			// current source
			var s    : INode;
			var sPos : Point;
			// current target
			var t : INode;
			var tPos : Point;
			
			// x-distance
			var x : Number;
			// y-distance
			var y : Number;
			
			// current distance
			var l : Number;
			// current force
			var k : Number;
			
			// gauss-seidel relaxation for links
			for each( e in _edges )
			{
				s = e.node1;
				t = e.node2;
				
				sPos = _currentDrawing.nodeCartCoordinates[ s ];
				tPos = _currentDrawing.nodeCartCoordinates[ t ];
				
				x = tPos.x - sPos.x;
				y = tPos.y - sPos.y;
				
				l = x * x + y * y;
				
				if ( l > 0 )
				{
					l    = Math.sqrt( l );
					l    = alpha * _currentDrawing.strengths[ e ] * ( l - _currentDrawing.distances[ e ] ) / l;
					
					x   *= l;
					y   *= l;
					
					k    = _currentDrawing.weights[ s ] / ( _currentDrawing.weights[ t ] + _currentDrawing.weights[ s ] );
					
					tPos.offset( - x * k, - y * k );
					
					k = 1 - k;
					
					sPos.offset( x * k, y * k ); 
				}
			}
			
			// apply gravity forces
			k = alpha * gravity;
			
			if ( k != 0 )
			{
				x = size.x;
				y = size.y;
				
				for each( s in _stree.nodes )
				{
					sPos = _currentDrawing.nodeCartCoordinates[ s ];
					sPos.offset( ( x - sPos.x ) * k, ( y - sPos.y ) * k );
				}
			}
			
			function repulse( quad : QuadTreeNode, bounds : Rectangle ) : Boolean
			{
				if ( quad.point != s )
				{
					var nodePos  : Point = _currentDrawing.nodeCartCoordinates[ s ];
					var pNodePos : Point = _currentDrawing.pPos[ s ];
					
					var dx : Number = quad.cx - nodePos.x;
					var	dy : Number = quad.cy - nodePos.y;
					var	dw : Number = bounds.width;
					var dn : Number = dx * dx + dy * dy;
					var k  : Number;
					
					/* Barnes-Hut criterion. */
					if ( ( dw * dw / theta2 ) < dn )
					{
						if ( dn < chargeDistance2 )
						{
							k = quad.charge / dn;
							
							pNodePos.offset( - dx * k, - dy * k );
						}
						
						return true;
					}
					
					//trace( Boolean( quad.point && dn && dn < chargeDistance2 ) );
					
					if ( quad.point && Math.abs( dn ) > 0.00000000000001 && dn < chargeDistance2 )
					{
						k = quad.pointCharge / dn;
						
						pNodePos.offset( - dx * k, - dy * k );
					}
				}
				
				return quad.charge == 0;
			}
			
			//compute quadtree center of mass and apply charge forces
			if ( charge != 0.0 )
			{
				var q : QuadTree = new QuadTree( _stree.nodes, calculateBounds( _stree.nodes ), _currentDrawing );
				
				forceAccumulate( q.root );
				
				for each( s in _stree.nodes )
				{
					if ( ! s.vnode.fixed )
					{
						q.visit( repulse );	
					}
				}
			}
			
			// position verlet integration
			for each( s in _stree.nodes )
			{
				sPos = _currentDrawing.nodeCartCoordinates[ s ];
				tPos = _currentDrawing.pPos[ s ];
				
				if ( s.vnode.fixed )
				{
					sPos.setTo( tPos.x, tPos.y );
				}
				else
				{
					x = ( tPos.x - sPos.x ) * friction;
					y = ( tPos.y - sPos.y ) * friction;
					
					tPos.setTo( sPos.x, sPos.y );
					sPos.offset( - x, - y );
				}
			}
		}
		
		private function forceAccumulate( quad : QuadTreeNode ) : void
		{
			var cx   : Number = 0.0;
			var cy   : Number = 0.0;
			var c    : QuadTreeNode;
			var nodePos : Point;
			
			quad.charge = 0.0;
			
			if ( ! quad.leaf )
			{
				for each( c in quad.nodes )
				{
					if ( c )
					{
						forceAccumulate( c );
						quad.charge += c.charge;
						cx += c.charge * c.cx;
						cy += c.charge * c.cy;
					}
				}
			}
			
			if ( quad.point )
			{
				nodePos = _currentDrawing.nodeCartCoordinates[ quad.point ];
				
				// jitter internal nodes that are coincident
				if ( ! quad.leaf )
				{
					nodePos.offset( Math.random() - 0.5, Math.random() - 0.5 );
				}
				
				var k : Number = alpha * _currentDrawing.charges[ quad.point ];
				  
				quad.charge += k;
				quad.pointCharge = k;
				    
					cx += k * nodePos.x;
				    cy += k * nodePos.y;
			}
			
			quad.cx = cx / quad.charge;
			quad.cy = cy / quad.charge;
			
			//trace( 'quad', quad.charge, quad.pointCharge, quad.cx, quad.cy );
		}
		
		override public function get layoutDrawing():ILayoutDrawing
		{
			return _currentDrawing;
		}
		
		override public function get needRoot():Boolean
		{
			return false;
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
