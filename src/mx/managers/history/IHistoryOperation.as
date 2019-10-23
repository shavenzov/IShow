package mx.managers.history
{
	public interface IHistoryOperation
	{
		/**
		 * Отменяет выполнение команды 
		 * 
		 */			
		function undo() : void;
		
		/**
		 * Описание операции выполняемой посредством вызова undo 
		 * @return 
		 * 
		 */		
		function get undoDescription() : String;
		
		/**
		 * Повторяет выполнение ранее отмененной команды 
		 * 
		 */		
		function redo() : void;
		
		/**
		 * Описание операции выполняемой посредством вызова redo 
		 * @return 
		 * 
		 */		
		function get redoDescription() : String;
		
		/**
		 * Если true,  то команда сама отсылает сообщение об изменении History, 
		 *      false, генерируется History, в методе add  
		 * @return 
		 * 
		 */		
		function get dispatchChanged() : Boolean;
		
	}
}