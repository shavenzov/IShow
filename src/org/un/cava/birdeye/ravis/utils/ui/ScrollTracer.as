package org.un.cava.birdeye.ravis.utils.ui
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import org.un.cava.birdeye.ravis.utils.ui.events.ScrollTracerEvent;
	
	import spark.core.IViewport;
	
	public class ScrollTracer extends EventDispatcher
	{
		/**
		 * Область срабатывания слева 
		 */		
		public var leftArea   : Number = 25;
		/**
		 * Область срабатывания справа 
		 */		
		public var rightArea  : Number = 25;
		/**
		 * Область срабатывания сверху 
		 */		
		public var topArea    : Number = 25;
		/**
		 * Область срабатывания снизу 
		 */		
		public var bottomArea : Number = 25;
		/**
		 * Смещение по осям 
		 */
		public var offset     : Point  = new Point();
		
		/**
		 * Отслеживать ли движение по оси х 
		 */
		public var scrollX    : Boolean = true;
		
		/**
		 * Отслеживать ли движение по оси y 
		 */
		public var scrollY    : Boolean = true;
		
		/**
		 * Использовать отступ во время перемещения 
		 */		
		public var gapThenMoving : Boolean = true;
		
		/**
		 * Компонент за которым происходит "слежка" 
		 */		
		private var _client     : IViewport;
		
		/**
		 * Идет ли процесс слежения 
		 */		
		private var _tracing    : Boolean;
		
		public function ScrollTracer( client : IViewport )
		{
			super();
			_client = client;
		}
		
		public function get client() : IViewport
		{
			return _client;
		}
		
		/**
		 * Запускает процесс слежения за компонентом 
		 * 
		 */		
		public function startTracing() : void
		{
			if ( ! _tracing )
			{
				DisplayObject( _client ).stage.addEventListener( MouseEvent.MOUSE_MOVE, onScrollStageMouseMove, false, 1000 );
				_tracing = true;
			}
			else throw new Error( 'Tracing have already started.' );
		}
		
		public function stopTracing() : void
		{
			if ( _tracing )
			{
				DisplayObject( _client ).stage.removeEventListener( MouseEvent.MOUSE_MOVE, onScrollStageMouseMove );
				stopMoving();
				_tracing = false;
			}
			else throw new Error( 'Tracing have already stopped.' );
		}
		
		/**
		 * Текущее смещение по осям 
		 */		
		private var dX : Number = 0;
		private var dY : Number = 0;
		
		/**
		 * Коэффициент ускорения 
		 */		
		private var _accX : Number = 0.15;
		private var _accY : Number = 0.35;
		
		private var _lastScrollEvent : MouseEvent;
		
		/**
		 * Идентификатор таймера 
		 */		
		private var _timerId : int = -1;
		
		private function onScrollStageMouseMove( e : MouseEvent ) : void
		{
			//Если это событие само-сгенерированное, то не обрабатываем его
			if ( e.relatedObject == _client )
			{
				return;
			}	
			
			var localPos : Point = DisplayObject( _client ).globalToLocal( new Point( e.stageX, e.stageY ) );
			    localPos.x = localPos.x - _client.horizontalScrollPosition;
				localPos.y = localPos.y - _client.verticalScrollPosition;
				
			//По горизонтали справа
			if ( scrollX )
			{
				if ( ( localPos.x > _client.width - rightArea ) &&
					( _client.horizontalScrollPosition < _client.contentWidth - _client.width )
				)
				{	
					dX = localPos.x - ( _client.width - rightArea );
				}
				else //По горизонтали слева
					if ( ( localPos.x < leftArea ) && ( _client.horizontalScrollPosition > 0 ) )
					{
						dX = localPos.x - leftArea;
					}
					else
					{
						dX = 0;
					}
			}	
			
			//По вертикали снизу
			if ( scrollY )
			{
				if ( ( localPos.y > _client.height - bottomArea ) &&
					( _client.verticalScrollPosition < _client.contentHeight - _client.height )
				)
				{
					dY = localPos.y - ( _client.height - bottomArea );
				}
				else //По вертикали сверху
					if ( ( localPos.y < topArea ) && ( _client.verticalScrollPosition > 0 ) )
					{
						dY = localPos.y - topArea;
					}
					else
					{
						dY = 0;
					}
			}	
			
			if ( ( dX != 0.0 ) || ( dY != 0.0 ) )
			{
				e.stopImmediatePropagation(); 
				
				if ( gapThenMoving )
				{
					_lastScrollEvent = new MouseEvent( e.type, e.bubbles, e.cancelable,
						e.stageX - dX, e.stageY - dY, InteractiveObject( _client ) ); 
				}	 
				else
				{
					_lastScrollEvent = new MouseEvent( e.type, e.bubbles, e.cancelable,
						e.stageX, e.stageY, InteractiveObject( _client ) ); 
				}	 
				
				dX *= _accX;
				dY *= _accY;
				
				startMoving();
			}
			else
			{
				stopMoving();
			}
		}
		
		private function startMoving() : void
		{
			if ( _timerId == -1 )
			{
				_timerId = setInterval( moving, 50.0 );
				dispatchEvent( new ScrollTracerEvent( ScrollTracerEvent.START_MOVING ) );
			}
		}
		
		private function stopMoving() : void
		{
			if ( _timerId != -1 )
			{
				clearInterval( _timerId );
				_timerId = -1;
				dX = 0;
				dY = 0;
				
				dispatchEvent( new ScrollTracerEvent( ScrollTracerEvent.STOP_MOVING ) );
			}	
		}	
		
		private function moving() : void
		{
			_client.horizontalScrollPosition += dX;
			_client.verticalScrollPosition += dY;
			
			DisplayObject( _client ).stage.dispatchEvent( _lastScrollEvent );
		}	
	}
}