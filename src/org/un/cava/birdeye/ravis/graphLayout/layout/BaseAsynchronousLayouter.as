package org.un.cava.birdeye.ravis.graphLayout.layout
{
	import flash.events.ProgressEvent;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	
	public class BaseAsynchronousLayouter extends BaseLayouter implements IAsynchronousLayouter
	{
		/**
		 * Текущая итерация процесса построения  
		 */		
		protected var _progress : int = 0;
		
		/**
		 * Общее кол-во итераций необходимых для построения  
		 */		
		protected var _total    : int;
		
		/**
		 * Количество итераций за один проход
		 */		
		protected var _numIterationsPerTick : int = 1;
		
		/**
		 * Идентификатор таймера 
		 */		
		private var _timerId : int = -1;
		
		/**
		 * Время ( задержка между итерациями ) 
		 */		
		private var _timeout : Number = 50.0;
		
		public function BaseAsynchronousLayouter( vg : IVisualGraph = null, data : Object = null )
		{
			super( vg, data );
		}
		
		protected function calculationStart() : void
		{
			if ( ! working )
			{
				setDelay();
				dispatchEvent( new VisualGraphEvent( VisualGraphEvent.START_ASYNCHROUNOUS_LAYOUT_CALCULATION ) );
			}
		}
		
		override public function calculate() : void
		{
			calculationStart();
		}
		
		private function setDelay() : void
		{	
			_timerId = setTimeout( _tick, _timeout );	
		}
		
		protected function calculationSuspend() : void
		{
			if ( working )
			{
				clearDelay();
				_timerId = -1;
				dispatchEvent( new VisualGraphEvent( VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION ) );
			}
		}
		
		private function clearDelay() : void
		{
			if ( _timerId != -1 )
			{
				clearTimeout( _timerId );
			}
		}
		
		public function get working() : Boolean
		{
			return _timerId != -1;
		}
		
		private function _tick() : void
		{
			var numIterations : int = Math.min( _numIterationsPerTick, _total - _progress );
			var i             : int;
			
			for( i = 0; i <= numIterations; i ++ )
			{
				//Если во время "пакета" итераций вычисление было прервано, завершаем 
				if ( ! working )
				{
					break;
				}
				
				tick();
				
				_progress ++;
			}
			
			dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, _progress, _total ) );
			
			if ( _progress >= _total )
			{
				onEndProcess();
				calculationSuspend();
				return;
			}
			
			setDelay();
		}
		
		protected function onEndProcess() : void
		{
			super.calculate();
			
			_layoutChanged = true;
		}
		
		/**
		 * Вызывается при каждой итерации 
		 * 
		 */		
		protected function tick() : void
		{
			//Нет реализации, должно быть переопределено в классах наследниках
		}
		
		/**
		 * @inheritDoc
		 * */	
		public function get progress() : int
		{
			return _progress;
		}
		
		/**
		 * @inheritDoc
		 * */	
		public function get total() : int
		{
			return _total;
		}
		
		/**
		 * @inheritDoc
		 * */	
		public function suspend() : void
		{
			calculationSuspend();
		}
		
		/**
		 * no operation 
		 * 
		 */		
		public function init() : void
		{
			
		}
		
		override public function resetAll() : void
		{
			calculationSuspend();
			super.resetAll();
		}
	}
}