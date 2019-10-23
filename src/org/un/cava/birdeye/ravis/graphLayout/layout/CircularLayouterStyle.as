package org.un.cava.birdeye.ravis.graphLayout.layout
{
	public class CircularLayouterStyle
	{
		/**
		 * Все узлы распологаются вдоль окружности 
		 */		
		public static const SINGLE_CYCLE        : uint = 0;
		
		/**
		 * Узлы имеющие две и более связей распологаются на окружности. Узлы имеющие всего одну связь, вне окружности 
		 */		
		public static const BICONNECTED_INSIDE  : uint = 10;
		
		/**
		 * Узлы имеющие одну связь распологаются на окружности. Узлы имеющие две и более связей, вне окружности ( удаленность зависит от глубины вложения ) 
		 */	
		public static const BICONNECTED_OUTSIDE : uint = 20;
	}
}