package org.un.cava.birdeye.ravis.graphLayout.layout
{
	import flash.events.IEventDispatcher;

	public interface IAsynchronousLayouter extends IEventDispatcher
	{
		/**
		 * Текущая итерация процесса построения 
		 * @return 
		 * 
		 */		
		function get progress() : int;
		
		/**
		 * Общее кол-во итераций необходимых для построения 
		 * @return 
		 * 
		 */		
		function get total()    : int;
		
		/**
		 * Определяет запущен ли процесс или нет 
		 * @return 
		 * 
		 */		
		function get working() : Boolean;
		
		/**
		 * Отменяет процесс построения и завершает все процессы 
		 * 
		 */		
		function suspend() : void;
		
		/**
		 * Инициализирует раскладку перед началом работы 
		 * 
		 */		
		function init() : void;	
	}
}