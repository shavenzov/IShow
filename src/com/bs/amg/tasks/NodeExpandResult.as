package com.bs.amg.tasks
{
	import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;

	public class NodeExpandResult
	{
		/**
		 * Идентификатор раскрываемого узла 
		 */		
		public var nodeId : String;
		
		/**
		 * Раскрытый граф связанный с этим узлом 
		 */		
		public var graph : IGraph;
		
		public function NodeExpandResult( nodeId : String, graph : IGraph = null )
		{
		  this.nodeId = nodeId;
		  this.graph  = graph ? graph : new Graph();
		}
		
		public static function resultUnion( results : Vector.<NodeExpandResult> ) : IGraph
		{
			var graph  : IGraph = new Graph();
			var result : NodeExpandResult;
			
			for each( result in results )
			{
				graph.safeInitFromVO( result.graph.data );
			}
			
			return graph;
		}
	}
}