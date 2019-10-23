package org.un.cava.birdeye.ravis.history
{
	import mx.managers.history.History;
	import mx.managers.history.IHistoryOperation;
	import mx.managers.history.events.HistoryEvent;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	
	public class BaseAsynchrounousOperation extends BaseVisualGraphOperation
	{
		/**
		 * Текущая фаза расчета раскладки
		 * -1  - раскладка не расчитана
		 *  0  - раскладка не расчитана ( вызван метод draw )
		 *  1  - данные получены, но раскладка ещё не раcчитана ( асинхронная раскладка )
		 *  2  -  раскладка расчитана
		 */		
		protected var phase : int = -1;
		
		public function BaseAsynchrounousOperation( vg : IVisualGraph, dispatchChanged : Boolean = false )
		{
			super( vg, dispatchChanged );
		}
		
		protected function moveOperationToEnd() : void
		{
			//Если работаем с асинхронной раскладкой, то
			if ( vg.asynchrounousLayouter )
			{
				var op : IHistoryOperation = IHistoryOperation( this );
				
				//Если эта операция не в конце списка, то добавляем её в конец
				if ( History.indexOf( op ) != ( History.length - 1 ) )
				{
					//Удаляем эту опреацию из истории
					History.remove( IHistoryOperation( this ) );
					//И добавляем её в самый конец
					History.add( IHistoryOperation( this ) );
				}
			}
		}
		
		/**
		 * Запускает процесс ожидания перерисовки раскладки, для того что-бы установить слушатели для асинхронной раскладки 
		 * 
		 */		
		protected function waitForDraw() : void
		{
			phase = -1;
			vg.addEventListener( VisualGraphEvent.DRAW, onVGDraw );
		}
		
		private function onVGDraw( e : VisualGraphEvent ) : void
		{
			vg.removeEventListener( VisualGraphEvent.DRAW, onVGDraw );
			phase = 0;
			setAsyncListeners();
		}
		
		/**
		 * Устанавливает слушатели, для работы с асинхронным расчетом раскладки 
		 * 
		 */		
		private function setAsyncListeners() : void
		{
			vg.addEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onLayoutCalculated );
			
			//Запоминаем полученные данные ещё до применения раскладки (для асинхронных раскладок)
			if ( vg.lastAsynchrounousLayouter )
			{
				if ( phase == 0 )
				{
					vg.addEventListener( VisualGraphEvent.START_ASYNCHROUNOUS_LAYOUT_CALCULATION, onStartAsyncLayoutCalculation );
				}
			}
		}
		
		protected function onLayoutCalculated( e : VisualGraphEvent ) : void
		{
			vg.removeEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onLayoutCalculated );
			
			if ( phase == 1 )
			{
				vg.removeEventListener( VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION, onEndAsyncLayoutCalculation );
				vg.removeEventListener( VisualGraphEvent.START_ASYNCHROUNOUS_LAYOUT_CALCULATION, onStartAsyncLayoutCalculation );
				History.listener.removeEventListener( HistoryEvent.ADD, onAddedNewOperation );
			}
			
			phase = 2;
		}
		
		/**
		 * Запустился асинхронный процесс расчета раскладки 
		 * @param e
		 * 
		 */		
		protected function onStartAsyncLayoutCalculation( e : VisualGraphEvent ) : void
		{
			vg.addEventListener( VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION, onEndAsyncLayoutCalculation );
			History.listener.addEventListener( HistoryEvent.ADD, onAddedNewOperation );
			
			phase = 1;
		}
		
		/**
		 * Если расчет раскладки был прерван, то удаляем слушатели 
		 * @param e
		 * 
		 */		
		protected function onEndAsyncLayoutCalculation( e : VisualGraphEvent ) : void
		{
			release();
			_undo( true );
			//Отменяем текущую операцию
			/*History.remove( IHistoryOperation( this ) );
			sendChangedEvent();*/
		}
		
		/**
		 * Если во время просчета раскладки были "развернуты" ещё какие-то данные, то 
		 * @param e
		 * 
		 */
		protected function onAddedNewOperation( e : HistoryEvent ) : void
		{
			
		}
		
		/**
		 * Удаляет все установленные слушатели ( высвобождает выделенные ресурсы ) ( только для асинхронных раскладок )
		 * 
		 */		
		public function release() : void
		{
			if ( phase == -1 )
			{
				vg.removeEventListener( VisualGraphEvent.DRAW, onVGDraw );
			    return;
			}
			
			if ( phase == 0 )
			{
				vg.removeEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onLayoutCalculated );
				return;
			}
			
			if ( phase == 1 )
			{
				vg.removeEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onLayoutCalculated );
				vg.removeEventListener( VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION, onEndAsyncLayoutCalculation );
				vg.removeEventListener( VisualGraphEvent.START_ASYNCHROUNOUS_LAYOUT_CALCULATION, onStartAsyncLayoutCalculation );
				History.listener.removeEventListener( HistoryEvent.ADD, onAddedNewOperation );
			}
		}
		
		protected function _undo( updateIndex : Boolean = false ) : void
		{
			//Если расчет раскладки был прерван операцией undo
			if ( phase == 1 )
			{
				History.remove( IHistoryOperation( this ), updateIndex );
				sendChangedEvent();
			}
		}
		
		override protected function resetAll() : void
		{
			if ( phase < 2 )
			{
				release();
			}
			
			super.resetAll();
		}
	}
}