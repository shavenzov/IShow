package org.un.cava.birdeye.ravis.graphLayout.visual.animation
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.history.History;
	import mx.managers.history.events.HistoryEvent;
	
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.easing.Linear;
	import org.libspark.betweenas3.tweens.ITween;
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers.ArrowStyle;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualSelectionChangedEvent;

	public class EdgesDirectionAnimator
	{
		/**
		 * Время анимации ( 1 секунда )
		 */		
		private var _animationTime : Number = 1.0;
		
		/**
		 * Визуальный граф 
		 */		
		private var vg   : IVisualGraph;
		private var uivg : UIComponent;
		
		/**
		 * Список связей направление которых будет анимировано 
		 */		
		private var vedges : Vector.<IVisualEdge>;
		
		/**
		 * Список объектов участвующих в анимации 
		 */		
		private var balls : Vector.<Sprite>;
		
		/**
		 * Главный анимационный твин 
		 */		
		private var tween  : ITween;
		
		/**
		 * Вкл/Выкл 
		 */		
		private var _enabled : Boolean = true;
		
		/**
		 * Контейнер для размещения визуальных объектов анимации 
		 */		
		private var canvas : UIComponent;
		
		public function EdgesDirectionAnimator( vg : IVisualGraph )
		{
		  super();
		  
		  this.vg = vg;
		     uivg = UIComponent( vg );
		  
		  if ( uivg.initialized )
		  {
			  attachToVG();
		  }
		  else
		  {
			 vg.addEventListener( FlexEvent.CREATION_COMPLETE, onVGInitialized );    
		  }
		}
		
		private function onVGInitialized( e : FlexEvent ) : void
		{
			vg.removeEventListener( FlexEvent.CREATION_COMPLETE, onVGInitialized );
			attachToVG();
		}
		
		private function attachToVG() : void
		{
			canvas = new UIComponent();
			onScaled( null );
			
			uivg.addChildAt( canvas, uivg.numChildren - 2 );
			
			vg.addEventListener( VisualSelectionChangedEvent.SELECTION_CHANGED, onSelection );
			vg.addEventListener( VisualSelectionChangedEvent.START_RECT_SELECTION, onResetSelection );
			vg.addEventListener( VisualGraphEvent.BEGIN_NODES_DRAG, onResetSelection );
			vg.addEventListener( VisualGraphEvent.END_NODES_DRAG, onSelection );
			vg.addEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onResetSelection );
			vg.addEventListener( VisualGraphEvent.LAYOUT_UPDATED, onSelection );
			vg.addEventListener( VisualGraphEvent.DELETE, onSelection );
			
			vg.addEventListener( VisualGraphEvent.SCALED, onScaled );
			
			History.listener.addEventListener( HistoryEvent.REDO, onSelection );
			History.listener.addEventListener( HistoryEvent.UNDO, onSelection );
		}
		
		private function onScaled( e : Event ) : void
		{
			canvas.scaleX = vg.scale;
			canvas.scaleY = vg.scale;
		}
		
		private function onSelection( e : Event ) : void
		{
			if ( _enabled )
			{
				animate( vg.selectedNodes );
			}
		}
		
		private function onResetSelection( e : Event ) : void
		{
			if ( _enabled )
			{
				reset();	
			}
		}
		
		public function get enabled() : Boolean
		{
			return _enabled;
		}
		
		public function set enabled( value : Boolean ) : void
		{
			if ( _enabled != value )
			{
				if ( uivg.initialized )
				{
					if ( _enabled )
					{
						reset();
					}
					else
					{
						animate( vg.selectedNodes );
					}	
				}
				
				_enabled = value;
			}
		}
		
		/**
		 * Время анимации 
		 */	
		public function get animationTime() : Number
		{
			return _animationTime;
		}
		
		/**
		 * Запускает процесс анимации всех связей связанных с указанным списком узлов
		 * Если в данный момент, идет процесс анимации связанный с другими узлами, то она останавливается и запускается новая 
		 * @param nodes - список узлов, входящие/выходящие связи которых необходимо анимировать
		 * 
		 */		
		private function animate( nodes : * ) : void
		{
			reset();
			
			//Формируем список связей для анимации
			vedges = new Vector.<IVisualEdge>();
			
			var vnode : IVisualNode;
			var edge  : IEdge;
			
			for each( vnode in nodes )
			{
				for each( edge in vnode.node.inEdges )
				{
					if ( vedges.indexOf( edge.vedge ) == -1 )
					{
						//Добавляем только связи имеющие конкретное направление
						if ( edge.data.arrow == ArrowStyle.SINGLE )
						{
							vedges.push( edge.vedge );	
						}
					}
				}
			}
			
			if ( vedges.length > 0 )
			{
				runAnimation();	
			}
		}
		
		/**
		 * Запускает процесс анимации c определенной позиции 
		 * 
		 */		
		private function runAnimation( position : Number = 0.0 ) : void
		{
			//Создаем необходимое количество визуальных объектов для анимации
			var i      : int;
			var ball   : Sprite; 
			var vedge  : IVisualEdge;
			var tweens : Array = new Array( vedges.length );
			
			var x1     : Number;
			var x2     : Number;
			var y1     : Number;
			var y2     : Number;
			
			balls = new Vector.<Sprite>( vedges.length );
			
			for each( vedge in vedges )
			{
				ball = new GlowBall();
				
				x1 = vedge.edge.node1.vnode.viewCenter.x;
				y1 = vedge.edge.node1.vnode.viewCenter.y;
				x2 = vedge.edge.node2.vnode.viewCenter.x;
				y2 = vedge.edge.node2.vnode.viewCenter.y;
				
				ball.x = x1;
				ball.y = y1;
				
				canvas.addChild( ball );
				
				balls[ i ]  = ball;
				tweens[ i ] = BetweenAS3.tween( ball, { x : x2, y : y2 }, { x : x1, y : y1 }, _animationTime, Linear.easeIn );
				
				i ++;
			}
			
			tween = BetweenAS3.repeat( BetweenAS3.parallelTweens( tweens ), uint.MAX_VALUE );
			tween.play();
		}
		
		/**
		 * Останавливает процесс анимации (если он запущен) 
		 * 
		 */		
		private function reset() : void
		{
			if ( ! animating )
			{
				return;
			}
			
			//Останавливаем анимацию
			tween.stop();
			tween = null;
			
			//Удаляем визуальные объекты
			var ball : Sprite;
			
			for each( ball in balls )
			{
				canvas.removeChild( ball );
				ball = null;
			}
			
			balls  = null;
		}
		
		/**
		 * Обновляет/корректирует направление анимации если произошли изменения в графе 
		 * 
		 */		
		/*
		private function refresh() : void
		{
			if ( ! animating )
			{
				return;
			}
			
			//Удаляем из списка связи которые не существуют
			var vedge : IVisualEdge;
			var i     : int = 0;
			
			for ( i = vedges.length - 1; i >= 0; i -- )
			{
				if ( vg.vEdgeByStringId( vedges[ i ].id ) == null )
				{
					vedges.splice( i, 1 );
				}
			}
			
			var position : Number = tween.position;
			
			reset();
			runAnimation( position );
		}
		*/
		/**
		 * Определяет идет ли в данный момент процесс анимации или нет 
		 * @return 
		 * 
		 */		
		public function get animating() : Boolean
		{
			return tween != null;
		}
	}
}