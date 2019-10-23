package org.un.cava.birdeye.ravis.history
{
	import mx.managers.history.IHistoryOperation;
	import mx.utils.ObjectUtil;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	
	public class RemoveEdge extends BaseVisualGraphOperation implements IHistoryOperation
	{
		/**
		 * Данные о вновь создаваемой связи 
		 */		
		private var edge : Object;
		
		public function RemoveEdge( vg : IVisualGraph, edge : Object )
		{
			super( vg );
			
			this.edge = ObjectUtil.clone( edge );
			
			sendChangedEvent();
		}
		
		public function undo():void
		{
		  var v1 : IVisualNode = vg.graph.nodeByStringId( edge.fromId ).vnode; 
		  var v2 : IVisualNode = vg.graph.nodeByStringId( edge.toId ).vnode;
		
		  resetAll();
		  
		  //Создаем связь
		  vg.linkNodes( v1, v2, edge ); 	  
		}
		
		public function get undoDescription() : String
		{
			var str : String = 'Отменить удаление связи';
			
			if ( edge.label )
			{
				str += ' "' + edge.label + '"';
			}
			
			return str;
		}
		
		public function redo():void
		{
			resetAll();
			
			//Удаляем связь
			var ve : IVisualEdge = vg.graph.edgeByStringId( edge.id ).vedge;
			vg.removeEdge( ve );
		}
		
		public function get redoDescription():String
		{
			var str : String = 'Создать связь';
			
			if ( edge.label )
			{
				str += ' "' + edge.label + '"';
			}
			
			return str;
		}
	}
}