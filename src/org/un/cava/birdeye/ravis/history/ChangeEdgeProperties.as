package org.un.cava.birdeye.ravis.history
{
	import mx.managers.history.IHistoryOperation;
	import mx.utils.ObjectUtil;
	
	import org.un.cava.birdeye.ravis.components.renderers.edgeLabels.IEdgeLabelRenderer;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	
	public class ChangeEdgeProperties extends BaseVisualGraphOperation implements IHistoryOperation
	{
		private var edge : IVisualEdge;
		
		private var dataBefore : Object;
		private var lineStyleBefore : Object;
		
		private var dataAfter  : Object;
		private var lineStyleAfter : Object;
		
		public function ChangeEdgeProperties( vg : IVisualGraph, edge : IVisualEdge )
		{
			super(vg);
			this.edge = edge;
		}
		
		public function dumpBefore() : void
		{
			dataBefore      = ObjectUtil.clone( edge.data );
			lineStyleBefore = ObjectUtil.clone( edge.lineStyle );
		}
		
		public function dumpAfter() : void
		{
			dataAfter      = ObjectUtil.clone( edge.data );
			lineStyleAfter = ObjectUtil.clone( edge.lineStyle );
		}
		
		public function undo() : void
		{
			var edge : IVisualEdge = getVEdgeByData( dataBefore );
			    edge.data = edge.edge.data = ObjectUtil.clone( dataBefore );
			   
				edge.lineStyle = ObjectUtil.clone( lineStyleBefore );
				
				IEdgeLabelRenderer( edge.labelView ).refresh();
				edge.edge.node1.vnode.updateReleatedEdges();
				edge.edge.node2.vnode.updateReleatedEdges();	
		}
		
		public function redo() : void
		{
			var edge : IVisualEdge = getVEdgeByData( dataAfter );
			    edge.data = edge.edge.data = ObjectUtil.clone( dataAfter );
			 
			    edge.lineStyle = ObjectUtil.clone( lineStyleAfter );
			
			    IEdgeLabelRenderer( edge.labelView ).refresh();
			    edge.edge.node1.vnode.updateReleatedEdges();
			    edge.edge.node2.vnode.updateReleatedEdges();
		}
		
		public function get undoDescription():String
		{
			return 'Отменить изменение свойств связи';
		}
		
		public function get redoDescription():String
		{
			return 'Изменить свойства связи';
		}
	}
}