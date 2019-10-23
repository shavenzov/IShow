package org.un.cava.birdeye.ravis.graphLayout.layout
{
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
	
	public class AsynchronousLayoutStack extends EventDispatcher implements IAsynchronousLayouter
	{
		private var _layouters : Array;
		private var _current   : IAsynchronousLayouter;
		private var _index     : int;
		
		public function AsynchronousLayoutStack( layouters : Array )
		{
			super();
			
			_layouters = layouters;
		}
		
		public function get layouters() : Array
		{
			return _layouters;
		}
		
		private var _progress  : int;
		private var _cProgress : int;
		
		public function get progress() : int
		{
			return _progress;
		}
		
		private var _total : int;
		
		public function get total()    : int
		{
			return _total;
		}
		
		private var _working : Boolean;
		
		public function get working() : Boolean
		{
			return _working;
		}
		
		public function suspend() : void
		{
			if ( _current )
			{
				_current.suspend();
			}
		}
		
		public function init() : void
		{
			_index = 0;
			_total = 0;
			_progress = 0;
			_cProgress = 0;
			
			var _layouter : IAsynchronousLayouter;
			
			for each( _layouter in _layouters )
			{
				_layouter.init();
				_total += _layouter.total;
			}
		}
		
		public function calculate() : void
		{
			_working = true;
			next();
		}
		
		private function next() : void
		{
			if ( _current )
			{
				unsetListeners( _current );
			}
			
			_current = _layouters[ _index ];
			
			setListeners( _current );
			
			//Запускаем асинхронный процесс вычисления раскладки
			ILayoutAlgorithm( _current ).calculate();
		}
		
		private function setListeners( layouter : IAsynchronousLayouter ) : void
		{
		   layouter.addEventListener( ProgressEvent.PROGRESS, onProgress );
		   layouter.addEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onLayoutCalculated );
		   layouter.addEventListener( VisualGraphEvent.START_ASYNCHROUNOUS_LAYOUT_CALCULATION, onStartAsynchrounousLayoutCalculation );
		   layouter.addEventListener( VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION, onEndAsynchrounousLayoutCalculation );
		}
		
		private function unsetListeners( layouter : IAsynchronousLayouter ) : void
		{
			layouter.removeEventListener( ProgressEvent.PROGRESS, onProgress );
			layouter.removeEventListener( VisualGraphEvent.LAYOUT_CALCULATED, onLayoutCalculated );
			layouter.removeEventListener( VisualGraphEvent.START_ASYNCHROUNOUS_LAYOUT_CALCULATION, onStartAsynchrounousLayoutCalculation );
			layouter.removeEventListener( VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION, onEndAsynchrounousLayoutCalculation );
		}
		
		private function onStartAsynchrounousLayoutCalculation( e : VisualGraphEvent ) : void
		{
		   if ( _index == 0 )
		   {
			   dispatchEvent( e );	   
		   }
		}
		
		private function onEndAsynchrounousLayoutCalculation( e : VisualGraphEvent ) : void
		{
			dispatchEvent( e );
		}
		
		private function onProgress( e : ProgressEvent ) : void
		{
			_progress = _cProgress + e.bytesLoaded;
			
			dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, _progress, _total ) );
		}
		
		private function onLayoutCalculated( e : VisualGraphEvent ) : void
		{
			_cProgress += _current.total;
			_index ++;
			
			if ( _index >= _layouters.length )
			{
				_working = false;
				dispatchEvent( e );
				return;
			}
			
			next();
		}
	}
}