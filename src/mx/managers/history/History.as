package mx.managers.history
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.managers.history.events.HistoryEvent;

	public class History
	{
		/**
		 * Максимальное количество запоминаемых событий 
		 */		
		private static const MAX_HISTORY : int = 100;
		
		/**
		 * Череда операций 
		 */		
		public static var operations : Vector.<IHistoryOperation> = new Vector.<IHistoryOperation>();
		
		/**
		 * Текущий индекс в списке истории 
		 */		
		private static var _index : int = -1;
		
		
		public static const listener : EventDispatcher = new EventDispatcher();
		
		/**
		 * Вкл/Выкл 
		 */		
		public static var enabled : Boolean = true;
		
		/**
		 * В данный момент идет процесс undo или redo, какой-то из операций 
		 */		
		public static var _working : Boolean;
		
		/**
		 * Добавляет событие в список 
		 * @param event
		 * 
		 */		
		public static function add( operation : IHistoryOperation ) : void
		{	
			if ( ! enabled ) return;
			
			//Отсекаем все события после индекса
			if ( _index < operations.length - 1 )
			{
				operations = operations.slice( 0, _index + 1 );
			}
			
			//Если количество операций превысило максимальное, то удаляем самую первую запись
			if ( operations.length == MAX_HISTORY )
			{
				operations.shift();
			}
			else
			{
				_index ++;
			}
			
			operations.push( operation );
			
			if ( ! operation.dispatchChanged )
			{
				listener.dispatchEvent( new Event( Event.CHANGE ) );	
			}
			
			listener.dispatchEvent( new HistoryEvent( HistoryEvent.ADD, operation ) );
			
			/*
			trace( 'add', operation );
			
			for each( var o : IHistoryOperation in operations )
			{
				trace( o );
			}
			
			trace( '' );
			*/
		}
		
		/**
		 * Удаляет событие из списка 
		 * @param operation   - операцию которую необходимо удалить из history
		 * @param updateIndex - указывает обновлять ли index текущей операции при удалении ( необходимо устанавливать в false при вызове этого метода из операции undo )
		 * 
		 */		
		public static function remove( operation : IHistoryOperation, updateIndex : Boolean = true ) : void
		{
			if ( ! enabled )
			{
				return;
			}
			
			var i : int = operations.indexOf( operation );
			
			if ( i == -1 )
			{
				throw new Error( 'Operation ' + operation + ' not found in history.' );
			}
			
			if ( updateIndex && ( i <= _index ) )
			{
				_index --;
			}
			
			operations.splice( i, 1 );
			
			//trace( 'remove', _index, operations.length );
			
			if ( ! operation.dispatchChanged )
			{
				listener.dispatchEvent( new Event( Event.CHANGE ) );	
			}
		}
		
		/**
		 * Проверяет существует ли операция в History 
		 * @param operation - проверяемая операция
		 * @return true  - существует
		 *         false - не существует
		 * 
		 */		
		public static function exists( operation : IHistoryOperation ) : Boolean
		{
			return operations.indexOf( operation ) != -1;
		}
		
		public static function indexOf( operation : IHistoryOperation ) : int
		{
			return operations.indexOf( operation );
		}
		
		/**
		 * Индекс курсора истории 
		 * @return 
		 * 
		 */		
		public static function get index() : int
		{
		  return _index;
		}
		
		/**
		 * Количество событий в списке истории 
		 * @return 
		 * 
		 */		
		public static function get length() : int
		{
			return operations.length;
		}	
		
		/**
		 * Проверяет можно ли откатиться назад по истории  
		 * @return 
		 * 
		 */		
		public static function isCanUndo() : Boolean
		{	
			return _index != -1;
		}
		
		/**
		 * Проверяет можно ли продвинуться вперед по истории 
		 * @return 
		 * 
		 */		
		public static function isCanRedo() : Boolean
		{
			return _index < operations.length - 1;
		}
		
		/**
		 * Название операции которая будет повторять действие
		 * @return 
		 * 
		 */		
		public static function undoDescription() : String
		{
			return operations[ _index ].undoDescription;
		}
		
		/**
		 * Название операции которая будет выполнять отмену действия 
		 * @return 
		 * 
		 */	
		public static function redoDescription() : String
		{
			return operations[ _index + 1 ].redoDescription;
		}	
		
		/**
		 * Назад на одно действие 
		 * 
		 */		
		public static function undo( sendChangeEvent : Boolean = true ) : void
		{
			_working = true;
			 
			var operation : IHistoryOperation = operations[ _index ];
	            operation.undo();
			
			_index --;
			
			if ( sendChangeEvent )
			{
				listener.dispatchEvent( new Event( Event.CHANGE ) );
			}
			
			_working = false;
			
			listener.dispatchEvent( new HistoryEvent( HistoryEvent.UNDO, operation ) );
		}
		
		/**
		 * Вперед на одно действие 
		 * 
		 */		
		public static function redo( sendChangeEvent : Boolean = true ) : void
		{	
			_working = true;
			
			_index ++;
			
			var operation : IHistoryOperation = operations[ _index ];
			    operation.redo();
			
			if ( sendChangeEvent )
			{
				listener.dispatchEvent( new Event( Event.CHANGE ) );
			}
			
			_working = false;
			
			listener.dispatchEvent( new HistoryEvent( HistoryEvent.REDO, operation ) );
		}
		
		public static function get working() : Boolean
		{
			return _working;
		}
		
		/**
		 * Очищает историю событий 
		 */		
		public static function clear() : void
		{	
			operations.length = 0;
			_index        = -1;
			listener.dispatchEvent( new Event( Event.CHANGE ) );
		}
	}
}