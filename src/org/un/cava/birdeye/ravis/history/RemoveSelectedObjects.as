package org.un.cava.birdeye.ravis.history
{
	import flash.utils.Dictionary;
	
	import mx.managers.history.IHistoryOperation;
	import mx.utils.ObjectUtil;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	
	public class RemoveSelectedObjects extends BaseVisualGraphOperation implements IHistoryOperation
	{
		/**
		 * Список удаленных объектов 
		 */		
		private var nodes : Array;
		
		/**
		 * Список удаленных связей 
		 */		
		private var edges : Array;
		
		public function RemoveSelectedObjects( vg : IVisualGraph )
		{
			super( vg );
		}
		
		private function addRelationalEdges( nodes : Dictionary, edges : Dictionary ) : void
		{
			var vn      : IVisualNode;
			var e       : IEdge;
			var ve      : IVisualEdge;
			
			//Копируем все связи в новый словарь
			for each( vn in nodes )
			{
			  for each( e in vn.node.inEdges )
			  {
				  ve = e.vedge;
				  
				  if ( ! edges[ ve ] )
				  {
					  edges[ ve ] = ve;
				  }
			  }
			}
		}
		
		public function dumpBefore() : void
		{
			var edges : Dictionary = ObjectUtil.cloneDictionary( vg.selectedEdges );
			var nodes : Dictionary = ObjectUtil.cloneDictionary( vg.selectedNodes );
			
			if ( edges )
			{
				addRelationalEdges( nodes, edges );
				
				this.edges = dumpObjects( edges );
			}
			
			if ( nodes )
			{
				this.nodes = dumpObjects( nodes );
			}
			
			dumpVisualGraphBeforeParams();
		}
		
		public function dumpAfter() : void
		{
			dumpVisualGraphAfterParams();
		}
		
		public function undo():void
		{
		   var data : Object = { nodes : [], edges : [] };
		   var v    : Object;
		   
		   //Создаем ранее удаленные узлы
		   if ( nodes )
		   {
			   for each( v in nodes )
			   {
				   data.nodes.push( v );
			   }
		   }
			
		   //Создаем ранее удаленные связи
		   if ( edges )
		   {
			   for each( v in edges )
			   {
				   data.edges.push( v );
			   }
		   }
		   
		   resetAll();
		   
		   vg.graph.initFromVO( data );
		   vg.initFromGraph();
		   
		   //Востанавливаем предыдущие координаты узлов
		   restoreNodesPos( nodes );
		   
		   commitVisualGraphParamsBefore();
		}
		
		public function get undoDescription():String
		{
			var numObjects : int = ( edges ? edges.length : 0 ) + ( nodes ? nodes.length : 0 );
			var str        : String = 'Отменить удаление ';
			
			if ( numObjects > 1 )
			{
				str += ' (объектов ' + numObjects + ')';
			}
			else
			{
				if ( nodes )
				{
					str += '"' + nodes[ 0 ].name + '"'; 
				}
				else
				if ( edges )
				{
					if ( edges[ 0 ].label )
					{
						str += '"' + edges[ 0 ].label + '"';
					}
					else
					{
						str += 'связи';
					}
				}
			}
			
			return str;
		}
		
		public function redo():void
		{
			resetAll();
			
			var v : Object;
			
			//Удаляем связи
			if ( edges )
			{
				var ve : IVisualEdge; 
				
				for each( v in edges )
				{
					ve = vg.graph.edgeByStringId( v.id ).vedge;
					vg.removeEdge( ve );
				}
			}
			
		    //Удаляем узлы
			if ( nodes )
			{
				var vn : IVisualNode;
				
				for each( v in nodes )
				{
					vn = vg.graph.nodeByStringId( v.id ).vnode;
					vg.removeNode( vn );
				}
			}
			
			commitVisualGraphParamsAfter();
		}
		
		public function get redoDescription():String
		{
			var numObjects : int = ( edges ? edges.length : 0 ) + ( nodes ? nodes.length : 0 );
			var str        : String = 'Удалить ';
			
			if ( numObjects > 1 )
			{
				str += ' (объектов ' + numObjects + ')';
			}
			else
			{
				if ( nodes )
				{
					str += '"' + nodes[ 0 ].name + '"'; 
				}
				else
					if ( edges )
					{
						if ( edges[ 0 ].label )
						{
							str += '"' + edges[ 0 ].label + '"';
						}
						else
						{
							str += 'связь';
						}
					}
			}
			
			return str;
		}
	}
}