package org.un.cava.birdeye.ravis.graphLayout.visual.events
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class VisualSelectionChangedEvent extends Event
	{
		/**
		 * Произошли изменения связанные с выделением
		 */		
		public static const SELECTION_CHANGED    : String = 'selectionChanged';
		
		/**
		 * Начался процесс выделения рамочкой
		 */		
		public static const START_RECT_SELECTION : String = 'startRectSelection';
		
		/**
		 * Завершился процесс выделения рамочкой
		 */		
		public static const END_RECT_SELECTION   : String = 'endRectSelection';
		
		/**
		 * Словарь выбранных узлов 
		 */		
		public var selectedNodes : Dictionary;
		
		/**
		 * Количество выбранных узлов 
		 */		
		public var noSelectedNodes : int;
		
		/**
		 * Словарь выбранных связей 
		 */		
		public var selectedEdges : Dictionary;
		
		/**
		 * Количество выбранных связей 
		 */		
		public var noSelectedEdges : int;
		
		public function VisualSelectionChangedEvent( type : String, selectedNodes : Dictionary, selectedEdges : Dictionary, noSelectedNodes : int, noSelectedEdges : int )
		{
			super( type );
			
			this.selectedNodes   = selectedNodes;
			this.selectedEdges   = selectedEdges;
			this.noSelectedNodes = noSelectedNodes;
			this.noSelectedEdges = noSelectedEdges;
		}
		
		override public function clone() : Event
		{
			return new VisualSelectionChangedEvent( SELECT, selectedNodes, selectedEdges, noSelectedNodes, noSelectedEdges );
		}
	}
}