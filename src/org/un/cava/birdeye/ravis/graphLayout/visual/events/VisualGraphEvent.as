package org.un.cava.birdeye.ravis.graphLayout.visual.events
{
	import flash.events.Event;

	public class VisualGraphEvent extends Event
	{
		public static const BEGIN_ANIMATION : String = "beginAnimation";
        public static const END_ANIMATION   : String = "endAnimation";
        
		/**
		 * Во время расчета или анимации раскладки был вызван метод resetAll 
		 */		
		public static const RESET_ALL : String = 'resetAll';
		
		/**
		 * Был вызван метод draw объекта IVisualGraph 
		 */		
		public static const DRAW : String = 'draw';
		
		/**
		 * Изменились параметры VisualGraph, путем установки св-ва data 
		 */		
		public static const VISUAL_GRAPH_DATA_CHANGED : String = 'visualGraphDataChanged';
		
		/**
		 * Изменились параметры layouterа путем установки св-ва data 
		 */		
		public static const LAYOUT_DATA_CHANGED : String = 'layoutDataChanged';
		
		/**
		 * Изменился один из параметров раскладки 
		 */		
		public static const LAYOUT_PARAM_CHANGED : String = 'layoutParamChanged';
		
		/**
		 * Изменилось св-во layouter 
		 */		
		public static const LAYOUT_CHANGED : String = 'layoutChanged';
		
		/**
		 * Координаты узлов компоновки уже просчитаны, осталось только отрисовать или запустить анимацию 
		 */		
		public static const LAYOUT_CALCULATED : String = 'layoutCalculated';
		
		/**
		 * Произошла перерисовка узлов и связей компоновщиком 
		 */		
		public static const LAYOUT_UPDATED : String = 'layoutUpdated';
		
		/**
		 * Произошло изменение масштаба 
		 */        
		public static const SCALED : String = "scaled";
		
		/**
		 * Начало перетаскивания какого-либо или нескольких узлов пользователем 
		 */		
		public static const BEGIN_NODES_DRAG : String = 'beginNodesDrag'; 
		
		/**
		 * Окончание перетаскивания какого-либо или нескольких узлов пользователем  
		 */		
		public static const END_NODES_DRAG   : String = 'endNodesDrag';
		
		/**
		 * Координаты узлов были изменены 
		 */		
		public static const NODES_UPDATED : String = 'nodesUpdated';
		
		/**
		 * Какой-то из объектов node и/или edge были удалены 
		 */		
		public static const DELETE : String = 'delete';
		
		/**
		 * Запустился асинхронный процесс расчета раскладки 
		 */		
		public static const START_ASYNCHROUNOUS_LAYOUT_CALCULATION : String = 'startAsynchrounousLayoutCalculation';
		
		/**
		 * Асинхронный процесс расчета раскладки завершен 
		 */		
		public static const END_ASYNCHROUNOUS_LAYOUT_CALCULATION : String = 'endAsynchrounousLayoutCalculation';
		
		public function VisualGraphEvent( type : String )
		{
			super( type );
		}
		
		override public function clone() : Event
		{
			return new VisualGraphEvent( type );
		}
		
	}
}