package org.un.cava.birdeye.ravis.history
{
	import mx.managers.history.IHistoryOperation;
	import mx.utils.ObjectUtil;
	
	import org.un.cava.birdeye.ravis.components.renderers.nodes.INodeRenderer;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	
	public class ChangeNodeProperties extends BaseVisualGraphOperation implements IHistoryOperation
	{
		private var node : IVisualNode;
		
		private var dataBefore : Object;
		private var dataAfter  : Object;
		
		public function ChangeNodeProperties( vg : IVisualGraph, node : IVisualNode )
		{
			super(vg);
			
			this.node = node;
		}
		
		public function dumpBefore() : void
		{
			dataBefore = ObjectUtil.clone( node.data );
		}
		
		public function dumpAfter() : void
		{
			dataAfter = ObjectUtil.clone( node.data );
		}
		
		public function undo() : void
		{
			var node : IVisualNode = getVNodeByData( dataBefore );
			    node.data = node.node.data = ObjectUtil.clone( dataBefore );
			     
				INodeRenderer( node.view ).refresh();
				node.view.validateNow();
				node.updateReleatedEdges();	
		}
		
		public function redo() : void
		{
			var node : IVisualNode = getVNodeByData( dataAfter );
			    node.data = node.node.data = ObjectUtil.clone( dataAfter );
			    
			
			INodeRenderer( node.view ).refresh();
			node.view.validateNow();
			node.updateReleatedEdges();
		}
		
		public function get undoDescription():String
		{
			return 'Отменить изменение свойств объекта';
		}
		
		public function get redoDescription():String
		{
			return 'Изменить свойства объекта';
		}
	}
}