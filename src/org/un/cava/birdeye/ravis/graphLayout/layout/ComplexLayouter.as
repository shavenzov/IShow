package org.un.cava.birdeye.ravis.graphLayout.layout
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.core.UIComponent;
	import mx.utils.ObjectUtil;
	
	import org.un.cava.birdeye.ravis.components.renderers.nodes.INodeRenderer;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	
	public class ComplexLayouter extends AnimatedBaseLayouter
	{
		private static const HORIZONTAL_GAP : Number = 16.0;
		private static const VERTICAL_GAP   : Number = 16.0;
		
		/**
		 * Словарь корневых узлов 
		 */		
		private var _roots   : Vector.<INode>;
		
		public function ComplexLayouter( vg : IVisualGraph = null, data : Object = null )
		{
			super( vg, data );
			
			_roots = new Vector.<INode>();
			
			addEventListener( VisualGraphEvent.BEGIN_ANIMATION, onBeginAnimation );
			addEventListener( VisualGraphEvent.END_ANIMATION, onEndAnimation );
			addEventListener( VisualGraphEvent.LAYOUT_UPDATED, onVisualGraphEvent );
			//addEventListener( VisualGraphEvent.RESET_ALL, onVisualGraphEvent );
		}
		
		/**
		 * Список корневых элементов 
		 * @return 
		 * 
		 */		
		public function get roots() : Vector.<INode>
		{
			return _roots;
		}
		
		/**
		 * Устанавливает новый список корневых элементов 
		 * @param nodes
		 * 
		 */		
		public function set roots( nodes : Vector.<INode> ) : void
		{
			var node : INode;
			
			for each( node in _roots )
			{
				unmarkNodeAsRoot( node );
			}
			
			for each( node in nodes )
			{
				markNodeAsRoot( node );
			}
			
			_roots = nodes;
		}
		
		private function onBeginAnimation( e : VisualGraphEvent ) : void
		{
			layouter.animInProgress = true;
		}
		
		private function onEndAnimation( e : VisualGraphEvent ) : void
		{
		   layouter.animInProgress = false;	
		}
		/*
		private function onResetAll( e : VisualGraphEvent ) : void
		{
			resetAll();
		}
		*/
		private function onVisualGraphEvent( e : VisualGraphEvent ) : void
		{
			layouter.dispatchEvent( e );
		}
		
		private function get layouter() : ILayoutAlgorithm
		{
		   return _vgraph.lastLayouter;
		}
		
		override public function get fitToWindow() : Boolean
		{
			return layouter.fitToWindow;
		}
		
		override public function get autoFitEnabled() : Boolean
		{
			return layouter.autoFitEnabled;
		}
		
		private function get autoFitAndFitToWindow() : Boolean
		{
			return autoFitEnabled && fitToWindow;
		}
		
		private function markNodeAsRoot( node : INode ) : void
		{
			//Помечаем указанный узел как root
			node.data.root = true;
			
			refreshView( node );
		}
		
		private function unmarkNodeAsRoot( node : INode ) : void
		{
			//Удаляем пометку узла как root
			delete node.data.root;
			
			refreshView( node );
		}
		
		private function refreshView( node : INode ) : void
		{
			if ( node.vnode && node.vnode.view )
			{
				INodeRenderer( node.vnode.view ).refresh();
			}
		}
		
		public function setRoot( node : INode ) : void
		{
			//Определяем группы узлов
			var groups     : Vector.<Dictionary> = graph.getNodesGroups();
			
			var group      : Dictionary;
			var rootNode   : INode;
			var i          : int;
			var rootSetted : Boolean;
			
			for each( group in groups )
			{
				//Ищем текущий root в группе
				for ( i = 0; i < _roots.length; i ++ )
				{
					rootNode = _roots[ i ];
					
					//Если для группы уже установлен корневой элемент, то удаляем его
					if ( group[ rootNode ] && group[ node ] )
					{
						if ( rootSetted ) //Если новый root уже установлен, то удаляем второй для группы
						{
							unsetRoot( rootNode );
						}
						else //Заменяем текущий root в группе на новый
						{
							unmarkNodeAsRoot( rootNode );
							
							_roots[ i ] = node;
							rootSetted = true;
							
							markNodeAsRoot( node );
						}
					}
				}
			}
			
			if ( ! rootSetted )
			{
				_roots.push( node );
				markNodeAsRoot( node );
			}
		}
		
		public function unsetRoot( node : INode ) : void
		{
			var index : int = _roots.indexOf( node );
			
			if ( index != -1 )
			{
				_roots.splice( index, 1 );
				unmarkNodeAsRoot( node );
			}
		}
		
		/**
		 * Вычисляет прямоугольные области графов по тайловой системе (Полную реализацию алгоритма смотри TileLayouter) 
		 * @param numGraphs - количество графов
		 * @return прямоугольные области графов
		 * 
		 */		
		private function calcTileBoundingRects( numGraphs : int ) : Vector.<Rectangle>
		{
			var rects      : Vector.<Rectangle> = new Vector.<Rectangle>( numGraphs );
			var w          : Number = _vgraph.width - paddingLeft - paddingRight;
			var h          : Number = _vgraph.height - paddingTop - paddingBottom;
			var numRows    : int    = Math.floor( Math.sqrt( numGraphs ) );
			var numColumns : int    = Math.ceil( numGraphs / numRows );
			
			//Компоновка
			var x       : Number;
			var y       : Number;
			var cRow    : int;
			var cColumn : int;
			
			//Высота каждой прямоугольной области
			var rectHeight : Number = ( h - ( numRows - 1 ) * VERTICAL_GAP ) / numRows;
			var rectWidth  : Number;
			
			//Индекс текущего узла
			var index    : int = 0;
			//Количество прямоугольников в одной строке
			var numRects : int; 
			//Добавка к координатам (зависит от padding и gap)
			var x_add : Number;
			var y_add : Number;
			
			loop : for( cRow = 0; cRow < numRows; cRow ++ ) 
			{
				numRects  = Math.min( numGraphs - index, numColumns );
				rectWidth = ( w - ( numRects - 1 ) * HORIZONTAL_GAP ) / numRects; 
				
				y_add = paddingTop + VERTICAL_GAP * cRow;
				
				//Номер строки
				for ( cColumn = 0; cColumn < numColumns; cColumn ++ )
				{
					x_add = paddingLeft + HORIZONTAL_GAP * cColumn;
					
					rects[ index ] = new Rectangle( x_add + cColumn * rectWidth, y_add + cRow * rectHeight, rectWidth, rectHeight  );
					
					index ++;
					
					//Если графы закончились, то завершаем построение
					if ( index >= numGraphs )
					{
						break loop;
					}
				}
			}
			
			return rects;
		}
		
		private function placeLayoutersFromLeftToRight( layouters : Array ) : void
		{
			//layouters.sort( layouterSortFunctionByBounds );
			
			var layouter : ILayoutAlgorithm;
			var offset   : Point = new Point( paddingLeft, paddingTop ); 
			
			for each( layouter in layouters )
			{
				layouter.bounds.offsetPoint( offset );
				layouter.layoutDrawing.offset( offset );
				offset.x += HORIZONTAL_GAP + layouter.bounds.width;
			}
		}
		
		private function centerTotalLayouter() : void
		{
			var rect     : Rectangle = calculateBounds( graph.nodes );
			var screen   : Rectangle = new Rectangle( 0.0, 0.0, _vgraph.width, _vgraph.height );
			var offset   : Point     = fitTheMiddleRectangleToRectangle( rect, screen, true ); 
			
			if ( offset.length > 0 )
			{
				currentDrawing.offset( offset );
				rect.offsetPoint( offset );
			}
			
			setBounds( rect );
		}
		
		private function setBounds( rect : Rectangle ) : void
		{
			rect.width  += paddingRight;
			rect.height += paddingBottom;
			
			_bounds = rect;
		}
		
		/**
		 * Функция сортировки графов по размеру 
		 * @param a - компоновка графа а
		 * @param b - компоновка графа b
		 * @return 
		 * 
		 */		
		/*private static function layouterSortFunctionByBounds( a : ILayoutAlgorithm, b : ILayoutAlgorithm ) : Number
		{
			var squareA : Number = a.bounds.width * a.bounds.height;
			var squareB : Number = b.bounds.width * b.bounds.height;
			
			if ( squareA == squareB )
				return 0;
			
			if ( squareA > squareB )
				return 1
				
			return -1;	
		}*/
		
		private function mixLayouters( layouters : Array ) : void
		{
			var layouter : ILayoutAlgorithm;
			
			for each( layouter in layouters )
			{
				currentDrawing.add( layouter.layoutDrawing );
			}
		}
		
		/*private function correctNodesPos() : void
		{
			var rect   : Rectangle = calculateBounds( graph.nodes );
			var offset : Point     = new Point();
			
			if ( rect.x < paddingLeft )
			{
				offset.x = Math.abs( rect.x - paddingLeft );
			}
			
			if ( rect.y < paddingTop )
			{
				offset.y = Math.abs( rect.y - paddingTop );
			}
			
			if ( offset.length > 0.0 )
			{
				currentDrawing.offset( offset );
				rect.offsetPoint( offset );
			}
			
			_bounds = rect;
		}*/
		
		/*
		private function justRedraw() : void
		{
			var layouter      : ILayoutAlgorithm = this.layouter.clone();
			
			if ( autoFitAndFitToWindow )
			{
				var boundingRects : Vector.<Rectangle> = calcTileBoundingRects( 1 );
				    layouter.boundingRect              = boundingRects[ 0 ];
			}
			
			layouter.root = _roots[ 0 ];
			layouter.calculate();
			
			currentDrawing.add( layouter.layoutDrawing );
			
			var rect : Rectangle = calculateBounds( graph.nodes );
			
			if ( ! autoFitAndFitToWindow )
			{
			  var offset : Point = fitTheMiddleRectangleToRectangle( rect, new Rectangle( 0.0, 0.0, _vgraph.width, _vgraph.height ), true );
			  
			  if ( offset.length > 0.0 )
			  {
				  rect.offsetPoint( offset );
				  currentDrawing.offset( offset ); 
			  }   
			}
			
			_bounds = rect;
			
			this.layouter.dispatchEvent( new VisualGraphEvent( VisualGraphEvent.LAYOUT_CALCULATED ) ); 
		}
		*/
	    
		override public function commit():void
		{
			if ( ! aStack )
			{
				super.commit();
			}
		}
		
		private var layouters : Array;
		
		override public function calculate() : void
		{
			currentDrawing = new BaseLayoutDrawing();
			
			/*
			Вкл/выкл анимация
			*/
			disableAnimation = this.layouter.disableAnimation;
			
			/*
			Определяем группы узлов
			*/
			var groups      : Vector.<Dictionary> = graph.getNodesGroups();
			var numElements : Dictionary = new Dictionary();
			var group       : Dictionary;
			
			/*
			Создаем словарь "количество узлов в каждой группе"
			*/
			for each( group in groups )
			{
				numElements[ group ] = ObjectUtil.numDictionaryElements( group );
			}
			
			/*
            Удаляем из списка группы в которых присутствует только один узел
			*/
			//Узлы без связей на другие узлы
			var nodesWithoutLink  : Vector.<INode> = new Vector.<INode>();
			var rootNode          : INode;
			var found             : Boolean;
			
			//Словарик групп для которых корневые элементы уже найдены (для случая объединения нескольких графов в один, берется только первый найденный. Все остальные удаляются)
			var groupRoot : Dictionary = new Dictionary();
			
			//Удаляем корневые элементы которые не присутствуют ни в одной из групп
			var i : int = 0;
			
			for ( i = _roots.length - 1; i >= 0; i -- )
			{
				rootNode = _roots[ i ];
			
			    found = false;
				
				for each( group in groups )
				{
					if ( groupRoot[ group ] == null && group[ rootNode ] && ( numElements[ group ] > 1 ) )
					{
						found = true;
						groupRoot[ group ] = rootNode;
						break;
					}
				}
				
				if ( ! found )
				{
					unsetRoot( rootNode );
				}
			}
			
			groupRoot = null;
			
			//Если недостаточно корневых элементов, то устанавливаем их
			if ( groups.length > _roots.length )
			{
				for each( group in groups )
				{
					//Если в группе присутствует, только один узел, то игнорируем эту группу
					if ( numElements[ group ] > 1 )
					{
						found = false;
						
						for each( rootNode in _roots )
						{
							if ( group[ rootNode ] )
							{
								found = true;
								break;
							}
						}
						
						if ( ! found )
						{
							for each( rootNode in group )
							{
								setRoot( rootNode );
								break;
							}
						}
					}
					else
					{
						//Формируем список узлов без связей
						for each( rootNode in group )
						{
							nodesWithoutLink.push( rootNode );
						}
					}
				}
			}
			
			/*
			Если группа всего одна, то просто вызываем перерисовку
			*/
			/*if ( groups.length == 1 )
			{
				justRedraw();
				return;
			}*/
			
			var numTiles : int;
			var noNotSingleGroups : int = groups.length - nodesWithoutLink.length;
			
			if ( nodesWithoutLink.length == groups.length )
			{
				numTiles = 1;
			}
			else
			{
				numTiles = noNotSingleGroups;
				
				if ( nodesWithoutLink.length > 0 )
				{
					numTiles ++;
				}
			}
			
			var boundingRects : Vector.<Rectangle>;
			
			if ( autoFitAndFitToWindow )
			{
			  boundingRects = calcTileBoundingRects( numTiles );	
			}
			
			    layouters = new Array();
			var layouter  : ILayoutAlgorithm;
			
			numTiles = 0;
			
			if ( nodesWithoutLink.length > 0 )
			{
				var tileLayouter : TileLayouter = new TileLayouter( _vgraph, _data );
				    
				    if ( autoFitAndFitToWindow )
					{
						tileLayouter.boundingRect   = boundingRects[ numTiles ];
					}
				    
					tileLayouter.nodes = nodesWithoutLink;
				    tileLayouter.calculate();
				
				layouters.push( tileLayouter );
				numTiles ++;
			}
			 
			var asyncLayouter : Boolean = this.layouter is IAsynchronousLayouter;
			
			if ( nodesWithoutLink.length != groups.length )
			{
				for each( rootNode in _roots )
				{
					layouter      = this.layouter.clone();
					
					if ( autoFitAndFitToWindow )
					{
						layouter.boundingRect = boundingRects[ numTiles ];
					}
					
					layouter.root = rootNode;
					
					//Вычисляем только, если это не асинхронная раскладка
					if ( ! asyncLayouter )
					{
						layouter.calculate();	
					}
					
					layouters.push( layouter );
					numTiles ++;
				}
			}
			else
			{
				afterCalculation( layouters );
				return;
			}
			
			//Асинхронная раскладка
			if ( asyncLayouter )
			{
				startAsynchrounousCalculation( layouters );
			}
			else //Не асинхронная раскладка
			{
				afterCalculation( layouters );
			}
			
			//Только для тестирования
			//drawTestPoints();
		}
		/* Только для тестирования
		private function drawTestPoints() : void
		{
			var g : Graphics = Sprite( UIComponent( vgraph ).getChildAt( 2 ) ).graphics;
			g.clear();
			
			
			
			for each( var b : Object in BaseLayoutDrawing( currentDrawing ).testPoints )
			{
				g.beginFill( b.failed ? 0xff0000 : 0x00ff00, 0.5 );
				g.drawCircle( b.pos.x, b.pos.y, 8 );
				g.endFill();
			}
			
			
		}
		*/
		/**
		 * Стек для вычисления нескольких асинхронных раскладок 
		 */		
		private var aStack : AsynchronousLayoutStack;
		
		private function startAsynchrounousCalculation( layouters : Array ) : void
		{
			//Удаляем не асинхронные раскладки из списка
			var i        : int = 0;
			
			layouters = layouters.slice();
			
			for ( i = 0; i < layouters.length; i ++ )
			{
			  if ( ! ( layouters[ i ] is IAsynchronousLayouter ) )
			  {
				  layouters.splice( i, 1 );
			  }
			}
			
			aStack = new AsynchronousLayoutStack( layouters );
			setAStackListeners();
			aStack.init();
			aStack.calculate();
		}
		
		private function setAStackListeners() : void
		{
			aStack.addEventListener( ProgressEvent.PROGRESS, onProgress );
			aStack.addEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onLayoutCalculated );
			aStack.addEventListener( VisualGraphEvent.START_ASYNCHROUNOUS_LAYOUT_CALCULATION, onStartAsynchrounousLayoutCalculation );
			aStack.addEventListener( VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION, onEndAsynchrounousLayoutCalculation );
		}
		
		private function unsetAStackListeners() : void
		{
			aStack.removeEventListener( ProgressEvent.PROGRESS, onProgress );
			aStack.removeEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onLayoutCalculated );
			aStack.removeEventListener( VisualGraphEvent.START_ASYNCHROUNOUS_LAYOUT_CALCULATION, onStartAsynchrounousLayoutCalculation );
			aStack.removeEventListener( VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION, onEndAsynchrounousLayoutCalculation );
		}
		
		private function onProgress( e : ProgressEvent ) : void
		{
			layouter.dispatchEvent( e );
		}
		
		private function onLayoutCalculated( e : VisualGraphEvent ) : void
		{
			afterCalculation( layouters );
		}
		
		private function onStartAsynchrounousLayoutCalculation( e : VisualGraphEvent ) : void
		{
			layouter.dispatchEvent( e );
		}
		
		private function onEndAsynchrounousLayoutCalculation( e : VisualGraphEvent ) : void
		{
			unsetAStackListeners();
			aStack = null;	
			layouter.dispatchEvent( e );
		}
		
		override public function resetAll() : void
		{
			if ( aStack )
			{
				//Будет сгененрировано событие "VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION" и вызван метод onEndAsynchrounousLayoutCalculation
				aStack.suspend();
				/*unsetAStackListeners();
				aStack = null;*/
			}
			
			super.resetAll();
		}
		
		private function afterCalculation( layouters : Array ) : void
		{
			if ( ! autoFitAndFitToWindow )
			{
				placeLayoutersFromLeftToRight( layouters );
			}
			
			mixLayouters( layouters );
			
			if ( autoFitAndFitToWindow )
			{
				setBounds( calculateBounds( graph.nodes ) );
			}
			else
			{
				centerTotalLayouter(); 	
			}
			
			this.layouter.dispatchEvent( new VisualGraphEvent( VisualGraphEvent.LAYOUT_CALCULATED ) );
			
			//Запускаем применение расчитанных координат узлов с задержкой ( для более корректной работы )
			setTimeout( super.commit, 100 );
			
			this.layouters = null;
		}
	}
}