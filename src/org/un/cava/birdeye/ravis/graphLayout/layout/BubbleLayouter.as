package org.un.cava.birdeye.ravis.graphLayout.layout
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.utils.Geometry;
	
	public class BubbleLayouter extends BaseLayouter
	{
		public static const ID : String = 'BubbleLayout';
		
		private var _currentDrawing : BubbleLayoutDrawing;
		
		/**
		 * Длина связей по умолчанию 
		 */		
		private static const DEFAULT_LINK_LENGTH : Number = 150;
		
		/**
		 * Вектор перпендикулярный оси ox 
		 */		
		private static const vx    : Point = new Point( 1.0, 0.0 );
		
		/**
		 * Pi / 20 
		 */		
		private static const PI_20 : Number = Math.PI / 20.0;
		private static const A_PI  : Number = Math.PI + PI_20;
		
		public function BubbleLayouter( vg : IVisualGraph, data : Object = null )
		{
			super( vg, data );
		}
		
		override protected function setDefaults() : void
		{
			super.setDefaults();
			
			_data.type = ID;
			
			if ( ! _data.hasOwnProperty( 'linkLength' ) )
			{
				_data.linkLength = DEFAULT_LINK_LENGTH;
			}
			
			if ( ! _data.hasOwnProperty( 'orientation' ) )
			{
				_data.orientation = LayoutOrientation.NONE;
			}
			
			if ( ! _data.hasOwnProperty( 'useAsSubLayouter' ) )
			{
				_data.useAsSubLayouter = false;
			}
		}
		
		override public function get linkLength() : Number
		{
			return _data.linkLength;
		}
		
		override public function set linkLength( value : Number ) : void
		{
			_data.linkLength = value;
			sendChange();
		}
		
		public function get orientation() : uint
		{
			return _data.orientation;
		}
		
		public function set orientation( value : uint ) : void
		{
			_data.orientation = value;
			sendChange();
		}
		
		public function get useAsSubLayouter() : Boolean
		{
			return _data.useAsSubLayouter;
		}
		
		public function set useAsSubLayouter( value : Boolean ) : void
		{
			_data.useAsSubLayouter = value;
			sendChange();
		}
		
		private function init() : void
		{
			//killTimer();
			
			super.currentDrawing = _currentDrawing = new BubbleLayoutDrawing();
			
			/*if ( _root != _vgraph.currentRootVNode.node )
			{
				
				_root = _vgraph.currentRootVNode.node;
				_layoutChanged = true;
			}*/
			
			_stree = graph.getTree( root );
			
			var node : INode;
			
			//Устанавливаем координаты фиксированных узлов
			for each( node in _stree.nodes )
			{
				if ( node.vnode.fixed )
				{
					_currentDrawing.nodeCartCoordinates[ node ] = new Point( node.vnode.x, node.vnode.y );
				}
			}
		}
		
		private function autoFit() : void
		{
			if ( autoFitEnabled )
			{
				/*if ( fitToWindow )
				{
					linkLength = DEFAULT_LINK_LENGTH;
				}
				else
				{*/
					//Если раскладка используется для раскрытия узлов
					if ( useAsSubLayouter )
					{
						linkLength = DEFAULT_LINK_LENGTH;
					}
					else
					{
						//Необходимо что-бы потомки корневого элемента образовали полный круг, при этом визуальные узлы не должны пересекаться
						var ll : Number = DEFAULT_LINK_LENGTH;
						
						while( ! checkRadius( ll ) )
						{
							ll += 10.0;
						}
						
						linkLength = ll;
					}
				//}	
			}	
		}
		
		/**
		 * Проверяет уместятся ли все узлы, не пересекаясь на круговой компоновке указанного радиуса 
		 * @param r радиус круговой компоновки
		 * @return true  - умещаются
		 *         false - не умещаются  
		 * 
		 */		
		private function  checkRadius( r : Number ) : Boolean
		{
			var visVNodes : Vector.<INode> = _stree.getChildren( root );
			var node      : INode;
			var nodesL    : Number = 0.0;
			var b         : Rectangle;
			var l         : Number
			
			for each( node in visVNodes )
			{
				b       = node.vnode.view.getBounds( node.vnode.view.parent );
				nodesL += Math.sqrt( b.width * b.width + b.height * b.height );
			}
			
			l = 2 * Math.PI * r;
			
			return l > nodesL;
		}
		
		override public function calculate() : void
		{
			init();
			autoFit();
			
			//calculation
			placeRootNode();
			calcLevel( root );
			
			super.calculate();
		}
		
		/**
		 * Вычисляет координаты узлов одного уровня 
		 * @param root
		 * 
		 */		
		private function calcLevel( root : INode ) : void
		{
			var numChildren : int = _stree.getNoChildren( root );
			var angleLimit : Number;
			var step       : Number; 
			
			//Не направленный
			if ( ! useAsSubLayouter && ( orientation == LayoutOrientation.NONE ) )
			{
				//Ограничения угла разворота ( для root 360, для всех остальных 180 )
				angleLimit = ( root == this.root ) ? 2 * Math.PI : A_PI;
				step       = ( root == this.root ) ? 2 * Math.PI / numChildren : -1.0;
			}
			else
			{
				angleLimit = A_PI;
				step       = - 1.0;
			}
			
			var i    : int;
			var node : INode;
			
			for ( i = 0; i < numChildren; i ++ )
			{
				node = _stree.getIthChildPerNode( root, i );
				
				if ( ! node.vnode.fixed )
				{
					//Ищем положение узла при котором он не пересекается с другими узлами
					do{} 
					while( calcNodePos( root, node, i, angleLimit, step ) );
					
				}
			}
			
			var children   : Vector.<INode> = _stree.getChildren( root );
			
			for each( node in children )
			{
				if ( _stree.getNoChildren( node ) > 0 )
				{
					calcLevel( node );
				}
			}
		}
		
		/**
		 * Определение направления размещения объектов, 
		 */		
		private var even : Boolean; 
		
		/**
		 * Вычисляет возможное расположение узла относительно родителя 
		 * @param root - родитель
		 * @param node - узел для которого необходимо найти его положение
		 * @param index - индекс узла
		 * @param angleLimit - ограничение окружности вдоль которой будут выстраиваться узлы
		 * @param step - шаг между узлами в радианах, если не указано ( -1.0 ), то шаг вычисляется для каждого узла отдельно на основании его углового размера
		 * @return true - координаты узла не найдены, false - координаты для узла не найдены
		 * 
		 */			
		private function calcNodePos( root : INode, node : INode, index : int, angleLimit : Number, step : Number = -1.0 ) : Boolean
		{
			var startAngle  : Number;
			
			var lAngle      : Number;
			var rAngle      : Number;
			
			var ll          : Number; 
			
			if ( _currentDrawing.linkLengths[ root ] != null )
			{
				ll = _currentDrawing.linkLengths[ root ];
			}
			else
			{
				ll = _currentDrawing.linkLengths[ root ] = linkLength;
			}
			
			if ( _currentDrawing.startAngles[ root ] != null )
			{
				startAngle = _currentDrawing.startAngles[ root ];
			}
			else
			{
				startAngle = _currentDrawing.startAngles[ root ] = getStartAngle( root, 0, linkLength );
			}
			
			if ( _currentDrawing.lAngles[ root ] != null )
			{
				lAngle = _currentDrawing.lAngles[ root ];
			}
			else
			{
				lAngle = _currentDrawing.lAngles[ root ] = 0.0;
			}
			
			if ( _currentDrawing.rAngles[ root ] != null )
			{
				rAngle = _currentDrawing.rAngles[ root ];
			}
			else
			{
				rAngle = _currentDrawing.rAngles[ root ] = 0.0;
			}
			
			var pos      : Point;
			var rootPos  : Point  = _currentDrawing.nodeCartCoordinates[ root ];
			
			/*
			Нечетные индексы - двигаемся вправо, четные индексы - двигаемся влево
			*/
			even = ! even;
			
			var rotation  : Number = even ? - ( startAngle - lAngle ) :  - ( startAngle + lAngle ); 
			
			//Располагаем узлы вдоль окружности по часовой стрелке
			_currentDrawing.nodeCartCoordinates[ node ] = new Point( rootPos.x + Math.sin( rotation ) * ll, rootPos.y + Math.cos( rotation ) * ll );
			
			var result : Boolean = hitTestNode( node );
			
			//Разместить в указанном месте объект не получится
			if ( result )
			{
				
					if ( even ) lAngle += PI_20;
					else rAngle += PI_20;
				
			}
			else //Разместить в указанном месте объект получится
			{
				var angW : Number = ( step == -1.0 ) ? getAngularWidth( node, ll ) : step;
				
				
					if ( even ) lAngle += angW;
					else rAngle += angW;
				
			}
			
			if ( ( lAngle >= angleLimit / 2.0 ) && ( rAngle >= angleLimit / 2.0 ) )
			{
				ll   += 40; //modified 
				
				lAngle = 0.0;
				rAngle = 0.0;
				even   = false;
				
				_currentDrawing.linkLengths[ root ] = ll;
				_currentDrawing.startAngles[ root ] = getStartAngle( root, index + 1, ll );
			}
			
			_currentDrawing.lAngles[ root ] = lAngle;
			_currentDrawing.rAngles[ root ] = rAngle;
			
			return result;
		}
		/*
		private function getAngleOffset( lastOffset : Number ) : Number
		{
			return 0.0;//lastOffset == 0.0 ? Math.PI / 10 : 0.0;
		}
		*/
		/**
		 * Определяет стартовый угол для отрисовки детей корневого узла 
		 * @param root - корневой узел
		 * @param childrenOffset - смещение индекса детей родителя принимаемых участие в расчете
		 * @param ll - длина связи на данном уровне
		 * @return стартовый угол
		 * 
		 */		
		private function getStartAngle( root : INode, childrenOffset : int, ll : Number ) : Number
		{
			//Только для не направленного варианта
			if ( orientation == LayoutOrientation.NONE )
			{
				//Если это корневой элемент
				if ( _stree.getDistance( root ) < 1 )
				{
					return 0.0;
				}	
			}
			
			switch( orientation )
			{
				case LayoutOrientation.TOP_DOWN   : return calcAnglesOffset( root, childrenOffset, 0.0, ll );
				case LayoutOrientation.BOTTOM_UP  : return calcAnglesOffset( root, childrenOffset, Math.PI, ll  );
				case LayoutOrientation.LEFT_RIGHT : return calcAnglesOffset( root, childrenOffset, - Math.PI / 2, ll );
				case LayoutOrientation.RIGHT_LEFT : return calcAnglesOffset( root, childrenOffset, Math.PI / 2, ll );
			}
			
			return calcStartAngleForNoneOrientation( root, childrenOffset, ll );
		}
		
		private function calcAnglesOffset( root : INode, childrenOffset : int, theta : Number, ll : Number ) : Number
		{
			/*var node         : INode;
			var angularWidth : Number = 0.0;
			var numChildren  : int = _stree.getNoChildren( root );
			
			//Количество детей для которых был вычислен угловой размер
			var processedChildren : int = 0;
			var i                 : int;
			
			//Вычисляем угловой размер всех детей
			for ( i = childrenOffset; i < numChildren; i ++ )
			{
				node = _stree.getIthChildPerNode( root, i );
				
				if ( ! node.vnode.fixed )
				{
					angularWidth += getAngularWidth( node, ll );
					processedChildren ++;
				}	
			}
			
			if ( angularWidth >= A_PI )
			{
				return theta - Math.PI / 2.0;
			}
			
			//Если только один ребенок
			if ( processedChildren == 1 )
			{
				return theta;
			}
			
			return theta - angularWidth / 3.0;*/
			
			return theta;
		}
		
		private function calcStartAngleForNoneOrientation( root : INode, childrenOffset : int, ll : Number ) : Number
		{
				var from         : Point = _currentDrawing.nodeCartCoordinates[ _stree.parents[ root ] ];
				var to           : Point = _currentDrawing.nodeCartCoordinates[ root ];
				
			    //Вектор перпендикулярный вектору от точки from к точке to
				var v           : Point = Geometry.segmentNormal( from, to ); 
				
				//Угол между векторами
				var theta        : Number = Geometry.angleBetweenVectors( v, vx );
				
				return calcAnglesOffset( root, childrenOffset, theta, ll );
		}
		
		private function getAngularWidth( node : INode, length : Number ) : Number
		{
			var b : Rectangle = node.vnode.view.getBounds( node.vnode.view.parent );
			
			return Math.sqrt( b.width * b.width + b.height * b.height ) / length;
		}
		
		/**
		 *  Устанавливает положение корневого узла, в зависимости от его положения граф будет выглядить по разному
		 */		
		private function placeRootNode() : void
		{
			if ( root.vnode && root.vnode.fixed  )
			{
				_currentDrawing.nodeCartCoordinates[ root ] = new Point( root.vnode.x, root.vnode.y );
			}
			else
			{
				_currentDrawing.nodeCartCoordinates[ root ] = new Point();
			}
		}
		
		private function hitTestNode( testNode : INode ) : Boolean
		{
			var node  : INode;
			var obj   : Object;
			
			var rect1 : Rectangle = _currentDrawing.getBounds( testNode );
			var rect2 : Rectangle;
			
			var result : Boolean = false;
			
			if ( rect1 )
			{
				for ( obj in _currentDrawing.nodeCartCoordinates )
				{
					node  = INode( obj );
					
					if ( node != testNode )
					{
						rect2 = _currentDrawing.getBounds( node );
						
						if ( rect1.intersects( rect2 ) )
						{
							result = true;
							break;
						}
					}
				}
			}
			
			//result = hitTestEdge( testNode );
			
			//_currentDrawing.testPoints.push( { pos : new Point( rect1.x, rect1.y ), failed : result  } );
			return result;
		}
		
		/*
		private function hitTestEdge( testNode : INode ) : Boolean
		{
			var node  : INode;
			var edge  : IEdge;
			var obj   : Object;
			var pos1  : Point;
			var pos2  : Point;
			
			var rect : Rectangle = _currentDrawing.getBounds( testNode );
			
			if ( rect )
			{
				for ( obj in _currentDrawing.nodeCartCoordinates )
				{
					node  = INode( obj );
					
					if ( node != testNode )
					{
						for each( edge in node.inEdges )
						{
							if ( ( edge.node1 != testNode ) && ( edge.node2 != testNode ) )
							{
								pos1 = _currentDrawing.nodeCartCoordinates[ edge.node1 ];
								pos2 = _currentDrawing.nodeCartCoordinates[ edge.node2 ];
								
								if ( pos1 && pos2 )
								{
									trace( 'zz', pos1, pos2 );
									
									if ( Geometry.hitTestRectAndSegment( pos1, pos2, rect ) )
									{
										return true;
									}	
								}
							}
						}
					}
				}
			}
			
			return false;
		}
		
		private var lastTestNode : INode;
		private var numHit : int;
		
		private function hitTestEdge2( testNode : INode ) : Boolean
		{
			var node  : INode;
			var edge  : IEdge;
			var obj   : Object;
			var pos1  : Point;
			var pos2  : Point;
			
			var rect : Rectangle;
			
			if ( testNode == lastTestNode )
			{
				numHit ++;
			}
			else
			{
				lastTestNode = testNode;
				numHit ++;
			}
			
			if ( numHit >= 100 )
			{
				return false;
			}
			
				for ( obj in _currentDrawing.nodeCartCoordinates )
				{
					node  = INode( obj );
					
					if ( node != testNode )
					{
						rect = _currentDrawing.getBounds( node );
						
						for each( edge in testNode.inEdges )
						{
							if ( ( edge.node1 != node ) && ( edge.node2 != node ) )
							{
								pos1 = _currentDrawing.nodeCartCoordinates[ edge.node1 ];
								pos2 = _currentDrawing.nodeCartCoordinates[ edge.node2 ];
								
								if ( pos1 && pos2 )
								{
									//trace( 'zz', pos1, pos2, rect );
									
									if ( Geometry.hitTestRectAndSegment( pos1, pos2, rect ) )
									{
										//trace( 'test', true );
										return true;
									}
									//else trace( 'test', false );
								}
							}
						}
					}
				}
			
			return false;
		}
		*/
		
	}
}