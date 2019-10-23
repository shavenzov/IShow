package com.thread
{
	import com.thread.events.StatusChangedEvent;
	import com.thread.events.TaskEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	
	public class SimpleTask extends EventDispatcher
	{
		private static const TIMEOUT : Number = 50.0;
		
		/**
		 * Произошла ошибка 
		 */		
		public static const ERROR : int = -10;
		
		/**
		 * Объект не инициализирован 
		 */		
		public static const NONE : int = 0;
		
		/**
		 * Работа успешно завершена 
		 */		
		public static const DONE : int = 10000;
		
		protected var _status : int = NONE;
		protected var _statusString : String;
		
		public function SimpleTask()
		{
			super();
		}
		
		public function get status() : int
		{
			return _status;
		}
		
		public function get statusString() : String
		{
			return _statusString;
		}
		
		public function run() : void
		{
			if ( ! _running )
			{
				_status = NONE;
				next();	
			}
		}
		
		protected function next() : void
		{
			dispatchEvent( new StatusChangedEvent( StatusChangedEvent.STATUS_CHANGED, _status, _statusString ) );
		}
		
		protected function callLater( func : Function, ...params ) : void
		{
			params.unshift( func, TIMEOUT );
			
			setTimeout.apply( this, params );
		}
		
		private var _running : Boolean;
		
		public function get running() : Boolean
		{
			return _running;
		}
		
		protected function operationStart() : void
		{
			_running = true;
			dispatchEvent( new TaskEvent( TaskEvent.START ) );
		}
		
		protected function operationComplete() : void
		{
			_running = false;
			dispatchEvent( new TaskEvent( TaskEvent.COMPLETE ) );
		}
	}
}