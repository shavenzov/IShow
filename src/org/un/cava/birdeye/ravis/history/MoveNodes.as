package org.un.cava.birdeye.ravis.history
{
	import mx.managers.history.IHistoryOperation;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	
	public class MoveNodes extends BaseVisualGraphOperation implements IHistoryOperation
	{
		/**
		 * Информация об узлах до перетаскивания 
		 */		
		private var nodesBefore   : Array;
		
		/**
		 * Информация об узлах после перетаскивания 
		 */		
		private var nodesAfter    : Array;
		
		public function MoveNodes( vg : IVisualGraph )
		{
			super( vg );
		}
		
		/**
		 * Сделать отпечаток "До перетаскивания" 
		 * @param nodes
		 * 
		 */		
		public function dumpBefore() : void
		{
			nodesBefore = dumpObjects( vg.vnodes );
			dumpVisualGraphBeforeParams();
		}
		
		/**
		 * Сделать отпечаток после перетаскивания 
		 * @param nodes
		 * 
		 */		
		public function dumpAfter() : void
		{
			nodesAfter = dumpObjects( vg.vnodes );
			dumpVisualGraphAfterParams();
		}
		
		public function undo():void
		{
			restoreNodesPos( nodesBefore );
			commitVisualGraphParamsBefore();
		}
		
		public function get undoDescription():String
		{
			var str : String = 'Отменить перемещение ';
			
			if ( selectedNodesBefore.length > 1 )
			{
				str += 'группы объектов';
			}
			else
			{
				str += 'объекта "' + selectedNodesBefore[ 0 ].name + '"';
			}
			
			return str;
		}
		
		public function redo():void
		{
		  restoreNodesPos( nodesAfter );
		  commitVisualGraphParamsAfter();
		}
		
		public function get redoDescription():String
		{
			var str : String = 'Переместить ';
			
			if ( selectedNodesAfter.length > 1 )
			{
				str += 'группу объектов';
			}
			else
			{
				str += 'объект "' + selectedNodesAfter[ 0 ].name + '"';
			}
			
			return str;
		}
	}
}