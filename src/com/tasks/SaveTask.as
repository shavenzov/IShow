package com.tasks
{
	import com.thread.SimpleTask;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	public class SaveTask extends SimpleTask
	{
		/**
		 * Ожидаем пока пользователь выберет место для сохранения 
		 */		
		public static const WAITING_USER_SELECTION : int = 10;
		
		/**
		 * Идет процесс сохранения файла на компьютер пользователя 
		 */		
		public static const SAVING : int = 20;
		
		/**
		 * Пользователь отменил сохранение, нажав кнопку "Cancel", в диалоге сохранения файла 
		 */		
		public static const CANCELED : int = 30;
		
		/**
		 * Данные для сохранения 
		 */		
		private var _data : ByteArray;
		
		/**
		 * Доступ к диалоговому окну выбора места для сохранения 
		 */		
		private var _file : FileReference;
		
		/**
		 * Имя файла 
		 */		
		private var _fileName : String; 
		
		public function SaveTask( data : ByteArray, fileName : String )
		{
		  super();
		  _data     = data;
		  _fileName = fileName;
		}
		
		override protected function next():void
		{
			switch( _status )
			{
				case SimpleTask.NONE :
					_status = WAITING_USER_SELECTION;
					constructFileReference();
					_file.save( _data, _fileName );
					break;
				
				case CANCELED         :
				case SimpleTask.ERROR :
				case SimpleTask.DONE  :
					destructFileReference();
					break;
					
			}
			
			super.next();
		}
		
		private function constructFileReference() : void
		{
			_file = new FileReference();
			_file.addEventListener( ProgressEvent.PROGRESS, onProgress );
			_file.addEventListener( Event.COMPLETE, onComplete );
			_file.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			_file.addEventListener( Event.CANCEL, onCancel );
			_file.addEventListener( Event.SELECT, onSelect );
		}
		
		private function destructFileReference() : void
		{	
			_file.removeEventListener( ProgressEvent.PROGRESS, onProgress );
			_file.removeEventListener( Event.COMPLETE, onComplete );
			_file.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );
			_file.removeEventListener( Event.CANCEL, onCancel );
			_file.removeEventListener( Event.SELECT, onSelect );
			_file = null;
		}
		
		private function onProgress( e : ProgressEvent ) : void
		{
			dispatchEvent( e );
		}
		
		private function onComplete( e : Event ) : void
		{
			_status =  SimpleTask.DONE;
			dispatchEvent( e );
			next();
		}
		
		private function onIOError( e : IOErrorEvent ) : void
		{
			_status = SimpleTask.ERROR;
			dispatchEvent( e );
			next();
		}
		
		private function onCancel( e : Event ) : void
		{
			_status = CANCELED;
			dispatchEvent( e );
			next();
		}
		
		private function onSelect( e : Event ) : void
		{
			_status = SAVING;
			dispatchEvent( e );
			next();
		}
	}
}