package org.un.cava.birdeye.ravis.operations
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.managers.history.History;
	import mx.utils.ObjectUtil;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGTree;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.effects.GroupNodesEffect;
	import org.un.cava.birdeye.ravis.history.GroupNodes;

	public class GroupNodes extends EventDispatcher
	{
		private var vg : IVisualGraph;
		
		public function GroupNodes( vg : IVisualGraph )
		{
		  super();
		  this.vg = vg;
		}
		
		private var effect : GroupNodesEffect;
		
		private var mainNode            : IVisualNode;
		private var vGroupNodes         : Vector.<IVisualNode>;
		private var vGroupDeletedEdges  : Vector.<IVisualEdge>;
		private var vGroupModifiedEdges : Vector.<IVisualEdge>;
		
		/**
		 * Один из удаленных объектов является root, поэтому при перестроении необходимо поменять currentRootVNode на mainNode 
		 */		
		private var changeRoot          : Boolean;
		
		private var historyOp           : org.un.cava.birdeye.ravis.history.GroupNodes;
		
		/**
		 * Группирует список указанных узлов ( nodes ) в mainNode
		 * @param mainNode - главный узел "в который" будет произведена группировка
		 * @param nodes    - список групируемых узлов ( в списке должно быть, как минимум, 2 узла ) (все узлы должны быть одного типа)
		 * 
		 */		
		public function group( mainNode : IVisualNode, nodes : *, redraw : Boolean ) : void
		{
			this.mainNode = mainNode;
			
			var groupNodes  : Array = new Array();
			    vGroupNodes = new Vector.<IVisualNode>();
			
			//Список связей которые необходимо удалить 
			var groupDeletedEdges  : Array = new Array();
			//Список связей которые необходимо модифицировать
			var groupModifiedEdges : Array = new Array();    
			
			vGroupDeletedEdges  = new Vector.<IVisualEdge>();
			vGroupModifiedEdges = new Vector.<IVisualEdge>();
			
			//Словарик для определения какие связи уже есть в списке	
			var	edgesIds    : Dictionary = new Dictionary();    
			
			//Формируем список узлов
			var vnode          : IVisualNode;
			var node           : INode;
			var relationalNode : INode;
			var edge           : IEdge;
			
			//Дерево графа
			var tree : IGTree = vg.graph.getTree( vg.currentRootVNode.node );
			
			for each( vnode in nodes )
			{
				node = vnode.node;
				
				//Пропускаем главный узел, его не должно быть в списке
				if ( node.stringid != mainNode.node.stringid )
				{
					vGroupNodes.push( vnode );
					groupNodes.push( vnode.data );
					
					if ( ! changeRoot )
					{
						changeRoot = ( vnode == vg.currentRootVNode );
					}
					
					//Формируем список связей
					for each( edge in node.inEdges )
					{
						if ( ! edgesIds[ edge.stringid ] )
						{
							relationalNode = edge.node1.stringid != node.stringid ? edge.node1 : edge.node2;
							
							//Связи соединяющие узлы на одном уровне и ниже помечаем к "удалению"
							//if ( tree.getDistance( node ) >= tree.getDistance( relationalNode ) )
							//{
							//	groupDeletedEdges.push( edge.data );
							//	vGroupDeletedEdges.push( edge.vedge );
								
								//trace( 'deleted', node.stringid, tree.getDistance( node ), relationalNode.stringid, tree.getDistance( relationalNode ) ); 
							//}
							//else
							//{
								groupModifiedEdges.push( edge.data );
								vGroupModifiedEdges.push( edge.vedge );
								
								//trace( 'modified', node.stringid, tree.getDistance( node ), relationalNode.stringid, tree.getDistance( relationalNode ) ); 
							//}
							
							edgesIds[ edge.stringid ] = edge;
						}
					}
				}
			}
			
			if ( groupNodes.length == 0 )
			{
				throw new Error( "Can't group mainNode with mainNode." );
			}
			
			var group : Object = { nodes : groupNodes, edges : { deleted : groupDeletedEdges, modified : groupModifiedEdges } };
			
			historyOp = new org.un.cava.birdeye.ravis.history.GroupNodes( vg, mainNode, group, redraw );
			
			if ( redraw )
			{
				History.add( historyOp );
				historyOp = null;
			}
			
			mainNode.node.group = group;
			
			//Если изменился root, добавляем идентификатор рута который был до этого
			if ( changeRoot )
			{
				mainNode.node.group.rootId = vg.currentRootVNode.node.stringid;
			}
			
			//Запускаем анимацию сворачивания
			effect = new GroupNodesEffect();
			effect.addEventListener( Event.COMPLETE, onGroupEffectComplete );
			effect.group( mainNode, vGroupNodes );
		}
		
		private function onGroupEffectComplete( e : Event ) : void
		{
		  effect.removeEventListener( Event.COMPLETE, onGroupEffectComplete );
		  effect = null;
		  
		  removeVisualGroupElements();
		  
		  if ( historyOp )
		  {
			  historyOp.dumpAfter();
			  History.add( historyOp );
			  historyOp = null;
		  }
		  
		  vGroupDeletedEdges  = null;
		  vGroupModifiedEdges = null;
		  vGroupNodes = null;
		  mainNode = null;
		  
		  dispatchEvent( e );
		}
		
		/**
		 * Удаляет визуальные объекты группы 
		 * @param group - св-во group, которое будет назначено элементу
		 */		
		private function removeVisualGroupElements() : void
		{
			//Удаляю связи помеченные к удалению + модифицированные
			var edge     : IVisualEdge;
			
			//Словарь айдишников удаленных узлов
			var nodesIds : Dictionary = new Dictionary();
			
			for each( edge in vGroupDeletedEdges )
			{
				vg.removeEdge( edge );
				vg.graph.addEdgeIdToIgnoreList( edge.edge.stringid );
			}
			
			for each( edge in vGroupModifiedEdges )
			{
				vg.removeEdge( edge );
			}
			
			//Удаляю узлы
			var node : IVisualNode;
			
			for each( node in vGroupNodes )
			{
				nodesIds[ node.node.stringid ] = node;
				vg.graph.addNodeIdToIgnoreList( node.node.stringid );
				vg.removeNode( node );
			}
			
			//Создаю новые "модифицированные связи"
			var edges   : Array = new Array();
			var data    : Object;
			var subEdge : IEdge;
			var edgeId1 : String;
			var edgeId2 : String;
			var add     : Boolean;
			
			for each( edge in vGroupModifiedEdges )
			{
				data = ObjectUtil.clone( edge.data );
				
				if ( nodesIds[ data.fromId ] )
				{
					data.fromId = mainNode.node.stringid;
					edgeId1 = data.toId;
				}
				else
				{
					data.toId = mainNode.node.stringid;
					edgeId1 = data.fromId;
				}
				
				add = true;
				
				//Не добавляем связь, если в результате объединения связь будет совпадать с уже имеющимися у mainNode
				/*for each( subEdge in mainNode.node.inEdges )
				{
					edgeId2 = subEdge.node1.stringid != mainNode.node.stringid ? subEdge.node1.stringid : subEdge.node2.stringid;
					add = edgeId1 != edgeId2;
				}*/
				
				if ( add )
				{
					edges.push( data );	
				}
				else
				{
					vg.graph.addEdgeIdToIgnoreList( data.id );
				}
			}
			
			if ( edges.length > 0 )
			{
				vg.graph.initFromVO( { nodes : [], edges : edges } );
				vg.initFromGraph();
			}
			
			if ( changeRoot )
			{
				vg.currentRootVNode = mainNode;
			}
			
			//vg.draw();
		}
		
		/**
		 * Разгруппировывает узел, если в нем есть другие узлы 
		 * @param node - узел который необходимо разгруппировать
		 * 
		 */		
		public function ungroup( node : IVisualNode ) : void
		{
			var group : Object = node.node.group;
			
			if ( ! group )
			{
				throw new Error( "Can't ungroup because node with stringid=" + node.node.stringid + " doesn't have group." );
		 	}
		    
			var data  : Object;
			var vedge : IVisualEdge; 
			
			//Удаляем все модифицированные связи
			for each( data in group.edges.modified )
			{
				vedge = vg.vEdgeByStringId( data.id );
				vg.removeEdge( vedge );
			}
			
			//Объединяем модифицированные и удаленные связи в один массив
			var edges : Array = group.edges.modified.concat( group.edges.deleted );
			
			//Удаляем из игнора все связи
			for each( data in edges )
			{
				vg.graph.removeEdgeIdFromIgnoreList( data.id );
			}
			
			//Удаляем из игнора все узлы
			for each( data in group.nodes )
			{
			  vg.graph.removeNodeIdFromIgnoreList( data.id );	
			}
					
			vg.graph.initFromVO( { nodes : group.nodes, edges : edges } );
			vg.initFromGraph();
			
			if ( group.hasOwnProperty( 'rootId' ) )
			{
				vg.currentRootVNode = vg.vNodeByStringId( group.rootId );
			}
			
			node.node.group = null;
			
			//vg.draw();
		}
		
		/**
		 * Проверяет переданный список узлов одного типа или нет ( в списке должно быть, как минимум, 2 узла ) 
		 * @return true  - одного типа
		 *         false - не одного типа
		 * 
		 */		
		public static function nodesHasSimilarType( nodes : * ) : Boolean
		{
			var type : String;
			var node : IVisualNode;
			
			for each( node in nodes )
			{
				if ( ! type )
				{
					type = node.data.type;
					continue;
				}
				
				if ( type != node.data.type )
				{
					return false;
				}
			}
			
			return true;
		}
	}
}