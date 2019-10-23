package
{
	public class UIRoutines
	{
		/**
		 * Функция форматирования масштаба 
		 * @param value
		 * @return 
		 * 
		 */		
		public static function scaleDataFormatFunction( value : Number ) : String
		{
			var scaleInPercents : Number = Math.round( value * 100.0 );
			return scaleInPercents.toString() + '%';
		} 
	}
}