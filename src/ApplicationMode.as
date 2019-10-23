package
{
	/**
	 * Перечисление режимов работы визуализатора 
	 * @author Shavenzov
	 * 
	 */	
	public class ApplicationMode
	{
		/**
		 * Стандартный  
		 */		
		public static const STANDARD      : String = 'standard';
		
		/**
		 * Поиск цепочек между объектами
		 */		
		public static const RELATIONSHIPS : String = 'relationships';
		
		/**
		 * Отобразить граф с определенным идентификатором 
		 */		
		public static const GRAPH         : String = 'graph';
		
		/**
		 * Режим работы по умолчанию 
		 */		
		public static const DEFAULT_MODE  : String = STANDARD;
		
		/**
		 * Перечисление возможных режимов работы 
		 */		
		private static const modes         : Array = [ STANDARD, RELATIONSHIPS, GRAPH ];
		
		/**
		 * Проверяет режим работы, если указан не поддерживаемый возвращает режим по умолчанию 
		 * @param mode
		 * @return 
		 * 
		 */		
		public static function getMode( mode : String ) : String
		{
			if ( modes.indexOf( mode ) == -1 )
			{
				return DEFAULT_MODE;
			}
			
			return mode;
		}
	}
}