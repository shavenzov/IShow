/* 
* The MIT License
*
* Copyright (c) 2007 The SixDegrees Project Team
* (Jason Bellone, Juan Rodriguez, Segolene de Basquiat, Daniel Lang).
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

package org.un.cava.birdeye.ravis.graphLayout.data {
    
    import com.utils.HTML;
    
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    
    import mx.utils.ObjectUtil;
    
    import org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers.ArrowStyle;
    
    /**
     * Graph implements a graph datastructure G(V,E)
     * with vertices V and edges E, except that we call the
     * vertices nodes, which is here more in line with similar
     * implementations. A graph may be associated with a 
     * VisualGraph object, which can visualize graph components
     * in Flash.
     * @see VisualGraph
     * @see Node
     * @see Edge
     * */
    public class Graph extends EventDispatcher implements IGraph
	{
        /**
         * @internal
         * attributes of a graph
         * */
        private var _id:String;
        
		private var _nodes : Vector.<INode>;
		private var _edges : Vector.<IEdge>;
		
		/**
		 * Список игнорируемых ( "не добавляемых" ) идентификаторов узлов 
		 */		
		private var _ignoredNodesIds : Dictionary;
		
		/**
		 * Список игнорируемых ( "не добавляемых" ) идентификаторов связей 
		 */		
		private var _ignoredEdgesIds : Dictionary;
        
        /* lookup by string id and by id */
		private var _nodesByStringId:Object;
		
		/* Поиск по stringID среди edges, node1.stringID + '/' + node2.stringID */
		private var _edgesByStringId : Object;
        
        /** 
         * @internal
         * these two serve as id for nodes and
         * and edges the id's will start from 1 (not 0) !!
         * and are always increased.
         * */
		/*private var _currentNodeId:int;
		private var _currentEdgeId:int;*/
         
        /**
         * @internal
         * for several algorithms we might need
         * BFS and DFS implementations, all related
         * to a specific root node.
         * */
		private var _treeMap:Dictionary;
        
        /**
         * @internal
         * Provide a function to be used for sorting the
         * graph items. This is used by GTree.
         * */
		private var _nodeSortFunction:Function = null;
	
        /**
         * Constructor method that creates the graph and can
         * initialise it directly from an XML object, if one is specified.
         * 
         * @param id The id (or rather name) of the graph. Every graph has to have one.
         * @param directional Indicator if the graph is directional or not. Directional graphs have not been tested so far.
         * @param xmlsource an XML object that contains node and edge items that define the graph.
         * @param xmlnames an optional Array that contains XML tag and attribute names that define the graph. 
         * */
        public function Graph( source : Object = null, id : String = 'defaultGraph' )
		{
            _id = id
            
            _nodes = new Vector.<INode>();
            _edges = new Vector.<IEdge>();
            _treeMap = new Dictionary();
            
            _nodesByStringId = new Object();
			_edgesByStringId = new Object();
			
			_ignoredEdgesIds = new Dictionary();
			_ignoredNodesIds = new Dictionary();
            
            /*_currentNodeId = 0;
            _currentEdgeId = 0;*/
           
			
            if ( source )
			{
				if ( source is XML )
				{
					initFromXML( source as XML );
				}
				else
				{
					safeInitFromVO( source );
				}
			}
			
			nodeSortFunction = sortNodes;
        }
		
		/**
		 * @inheritDoc
		 * */
		public function get data() : Object
		{
			var result : Object = { nodes : [], edges : [] };
			
			//Копируем узлы
			for each( var node : INode in _nodes )
			{
				result.nodes.push( ObjectUtil.clone( node.data ) );
			}
			
			//Копируем связи
			for each( var edge : IEdge in _edges )
			{
				result.edges.push( ObjectUtil.clone( edge.data ) );
			}
			
			return result;
		}
        
		public function addEdgeIdToIgnoreList( edgeId : String ) : void
		{
			_ignoredEdgesIds[ edgeId ] = edgeId;
		}
		
		public function removeEdgeIdFromIgnoreList( edgeId : String ) : void
		{
			delete _ignoredEdgesIds[ edgeId ];
		}
		
		private function edgeIdInIgnoreList( edgeId : String ) : Boolean
		{
			return _ignoredEdgesIds[ edgeId ] != null;
		}
		
		public function addNodeIdToIgnoreList( nodeId : String ) : void
		{
			_ignoredNodesIds[ nodeId ] = nodeId;
		}
		
		public function removeNodeIdFromIgnoreList( nodeId : String ) : void
		{
			delete _ignoredNodesIds[ nodeId ];
		}
		
		private function nodeIdInIgnoreList( nodeId : String ) : Boolean
		{
			return _ignoredNodesIds[ nodeId ] != null;
		}
		
        /**
         * @inheritDoc
         * */
        public function get id():String {
            return _id;
        }		
         
        /**
         * @inheritDoc
         * */
        public function get nodes() : Vector.<INode> {
            return _nodes;
        }
        
        /**
         * @inheritDoc
         * */
        public function get edges() : Vector.<IEdge> {
            return _edges;
        }
        
        /**
         * @inheritDoc
         * */
        public function get noNodes() : int {
            return _nodes.length;
        }
        
        /**
         * @inheritDoc
         * */
        public function get noEdges() : int {
            return _edges.length;
        }
        
        /**
         * @inheritDoc
         * */
        public function set nodeSortFunction(f:Function):void {
            _nodeSortFunction = f;
        }
        
        /**
         * @private
         * */
        public function get nodeSortFunction():Function	{
            return _nodeSortFunction;
        }
        
        /**
         * @inheritDoc
         * */
        public function nodeByStringId( sid : String ) : INode
		{
            if ( _nodesByStringId.hasOwnProperty( sid ) )
			{
				return _nodesByStringId[ sid ];
			}
			
			return null;
        }
        
		/**
		 * @inheritDoc
		 * */
        public function edgeByStringId( sid : String ) : IEdge
		{
			if ( _edgesByStringId.hasOwnProperty( sid ) )
			{
				return _edgesByStringId[ sid ];
			}
			
			return null;
		}
        
        /**
         * @inheritDoc
         * */
        public function getTree(n:INode,restr:Boolean = false, nocache:Boolean = false, direction : int = 2 ):IGTree{
            /* If nocache is set, we just return a new tree */
            if(nocache) {
                return new GTree(n,this,restr,direction);
            }
            
            if(!_treeMap.hasOwnProperty(n)) {
                _treeMap[n] = new GTree(n,this,restr,direction);
                /* do the init now, not lazy */
                (_treeMap[n] as IGTree).initTree();
            }
            return (_treeMap[n] as IGTree);
        }
        
        /**
         * @inheritDoc
         * */
        public function purgeTrees():void {
            _treeMap = new Dictionary;
        }
        
		/**
		 * Функция сравнения для сортировки узлов по алфавиту 
		 * @param node1 - узел 1
		 * @param node2 - узел 2
		 * @return 
		 * 
		 */		
		public static function nodesSortCompareFunction( node1 : Object, node2 : Object ) : Number
		{
			var str1 : String = ' '; 
			var str2 : String = ' ';
			
			if ( node1.data.hasOwnProperty( 'name' ) )
			{
				str1 = node1.data.name;
			}
			
			if ( node2.data.hasOwnProperty( 'name' ) )
			{
				str2 = node2.data.name;
			}
			
			var r : int =  str1.charAt( 0 ).localeCompare( str2.charAt( 0 ) );
			
			return r == 0 ? r : r / Math.abs( r );
		}
		
		/**
		 * Сортирует список узлов по типу и алфафвиту 
		 * 
		 */		
        public static function sortNodes( nodes : * ) : Vector.<INode>
		{
			var typeGroup  : Vector.<Vector.<INode>> = new Vector.<Vector.<INode>>();
			var node       : INode;
			var subNode    : INode;
			var type       : String;
			var groupIndex : int;
			var i          : int; 
			
			for each( node in nodes )
			{
				type = node.data.type;
				
				groupIndex = -1;
				
				//Ищем группу типов узлов
				for ( i = 0; i < typeGroup.length; i ++ )
				{
					subNode = typeGroup[ i ][ 0 ];
					
					if ( subNode.data.type == type )
					{
						groupIndex = i;
						break;
					}
				}
				
				//Если группа не существует, то создаем новую группу
				if ( groupIndex == -1 )
				{
					typeGroup.push( Vector.<INode>( [ node ] ) );
				}
				//Если группа существует, то добавляем узел в эту группу
				else
				{
				   typeGroup[ groupIndex ].push( node );	
				}	
			}
			
			var group  : Vector.<INode>;
			var result : Vector.<INode> = new Vector.<INode>();
			
			//Сортируем узлы в каждой группе по алфавиту
			for each( group in typeGroup )
			{
				//Формируем отсортированный массив
				result = result.concat( group.sort( nodesSortCompareFunction ) );
			}
			
			/*trace();
			
			for ( i = 0; i < result.length; i ++ )
			{
				trace( result[ i ].data.type, result[ i ].data.name );
			}*/
			
			return result;
		}
		
		/**
		 * Копирует все существующие значения полей из src в dst
		 * Игнорирует поля "x" и "y"
		 * @param src
		 * @param dst
		 * @return 
		 * 
		 */		
		private function combineData( src : Object, dst : Object ) : Object
		{
			for ( var prop : String in dst )
			{
				if ( ( prop != 'x' ) && ( prop != 'y' ) )
				{
					src[ prop ] = dst[ prop ];
				}
			}
			
			return src;
		}
		
		public function safeInitFromVO( vo : Object ) : NodesAndEdges
		{
			var data     : Object;
			
			for each( data in vo.nodes )
			{
				data.x = NaN;
				data.y = NaN;
			}
			
			return initFromVO( vo );
		}
		
		/**
		 * 
		 * @param vo
		 * @param combineExistsData - если узел с указанным идентификатором существует, то
		 *        true  - заменяет существующие св-ва data
		 *        false - полностью заменяет св-во data существующего объекта
		 * @return 
		 * 
		 */		
		public function initFromVO( vo : Object ) : NodesAndEdges
		{
			var result : NodesAndEdges = new NodesAndEdges();
			
			var fromNode : INode;
			var toNode   : INode;
			var data     : Object;
				
			//Просмотр списка узлов
			for each( data in vo.nodes )
			{
				//Идентификатор
				if ( ! data.hasOwnProperty( 'id' ) )
					throw new Error( 'Не указан обязательный атрибут id, объекта Node' );
				
				//Если идентификатор узла в списке "игнорируемых", то не добавляем его
				if ( nodeIdInIgnoreList( data.id ) )
				{
					continue;
				}
				
				//Отображаемое имя
				if ( ! data.hasOwnProperty( 'name' ) )
					throw new Error( 'Не указан обязательный атрибут name, объекта Node' );
				
				//Заменяем HTML эквиваленты, если есть такие
				if ( data.hasOwnProperty( 'name' ) )
				{
					data.name = HTML.decode( data.name );
				}
				
				if ( data.hasOwnProperty( 'desc' ) )
				{
					data.desc = HTML.decode( data.desc );
				}
				
				//Проверяем существует ли узел с таким идентификатором
				fromNode = nodeByStringId( data.id );
				
				//Если есть обновляем св-во data
				if ( fromNode )
				{
					combineData( fromNode.data, data );
					
				}//Создаем новый узел
				else
				{
					result.nodes.push( createNode( data.id, data ) );
				}
			}
			
			//Просмотр списка связей
			for each( data in vo.edges )
			{
				//Идентификатор
				if ( ! data.hasOwnProperty( 'id' ) )
					throw new Error( 'Не указан обязательный атрибут id, объекта Edge' );
				
				//Если идентификатор связи в списке "игнорируемых", то не добавляем её
				if ( edgeIdInIgnoreList( data.id ) )
				{
					continue;
				}
				
				//Откуда
				if ( ! data.hasOwnProperty( 'fromId' ) )
					throw new Error( 'Не указан обязательный атрибут fromId, объекта Edge' );
				
				//Куда
				if ( ! data.hasOwnProperty( 'toId' ) )
					throw new Error( 'Не указан обязательный атрибут toId, объекта Edge' );
				
				fromNode   = nodeByStringId( data.fromId );
				toNode     = nodeByStringId( data.toId );
				
				//Если каких то из узлов не существует, то не создаем связь
				if ( ! fromNode || ! toNode )
				{
					continue;
				}
				
				//Заменяем HTML эквиваленты, если есть такие
				if ( data.hasOwnProperty( 'label' ) )
				{
					data.label = HTML.decode( data.label );
				}
				
				if ( data.hasOwnProperty( 'desc' ) )
				{
					data.desc = HTML.decode( data.desc );
				}
				
				var edge : IEdge = edgeByStringId( data.id );
				
				//Если связь существует, то обновляем св-ао data
				if ( edge )
				{
					combineData( edge.data, data );
				}
				else //Создаем новую связь
				{
					result.edges.push( link( fromNode, toNode, data.id, data ) );
				}
			}
			
			//trace( 'numObjects', nodes.length + edges.length, 'nodes', nodes.length, 'edges', edges.length );
			
			return result;
		}
		
		/**
         * @inheritDoc
         * */
        public function initFromXML( xml : XML ) : void
		{
            var xnode:XML;
            var xedge:XML;
            
            var fromNodeId:String;
            var toNodeId:String;
            
            var fromNode:INode;
            var toNode:INode;
            
			//Данные присоединяемые к каждому объекту ( св-ва объекта )
			var data : Object;
			
            //Просмотр списка узлов
			for each( xnode in xml.descendants( 'Node' ) )
			{
                data = new Object();
				
				//Идентификатор
				if ( xnode.@id == undefined )
					throw new Error( 'Не указан обязательный атрибут id, объекта Node' );
				
				data[ 'id' ] = xnode.@id.toString();
				
				//Отображаемое имя
				if ( xnode.@name == undefined )
					throw new Error( 'Не указан обязательный атрибут name, объекта Node' );
				
				data[ 'name' ] = xnode.@name.toString();
				
				//Описание
				data[ 'desc' ] = xnode.@desc.toString();
				
				
				//Цвет
				data[ 'color' ] = parseInt( xnode.@color );
				
				//Размер
				data[ 'size' ]  = parseFloat( xnode.@size );
				
				//Иконка
				data[ 'icon' ]  = xnode.@icon.toString(); 
				
				//Координата x
				data[ 'x' ] = parseFloat( xnode.@x );
				
				//Координата y
				data[ 'y' ] = parseFloat( xnode.@y );
				
				fromNode = createNode( data.id, data );
            }
            
			//Просмотр списка связей
            for each( xedge in xml.descendants( 'Edge' ) )
			{
                fromNodeId = xedge.attribute( 'fromID' );
                toNodeId   = xedge.attribute( 'toID' );
                
                fromNode   = nodeByStringId( fromNodeId );
                toNode     = nodeByStringId( toNodeId );
                
                /* we do not throw an error here, because the data
                * is often inconsistent. In this case we just ignore
                * the edge */
                if( fromNode == null )
				{    
                    continue;
                }
                
				if( toNode == null )
				{
                    continue;
                }
				
				data = new Object();
				
				if ( xedge.@id == undefined )
				{
					data[ 'id' ]     = calcUniqEdgeStringID( fromNodeId, toNodeId );
				}
				else
				{
					data[ 'id' ]     = xedge.@id.toString();
				}
				
				data[ 'fromId' ] = fromNodeId;
				data[ 'toId' ]   = toNodeId;
				data[ 'label' ]  = xedge.@label.toString();
				data[ 'flow' ]   = parseFloat( xedge.@flow );
				data[ 'color' ]  = parseInt( xedge.@color );
				data[ 'arrow' ]  = ArrowStyle.check( xedge.@arrow.toString() );
				
                link( fromNode, toNode, data.id, data );
            }
        }
        
        /**
         * @inheritDoc
         * */
        public function createNode( sid : String = "", o : Object = null ) : INode
		{
            
            /* we allow to pass a string id, e.g. it can originate
            * from the XML file.*/
            
            //var myid:int = ++_currentNodeId;
            //var mysid:String = sid;
            var myNode:Node;
            //var myaltid:int = myid;
            
			/*
            if( mysid == "" )
			{
                mysid = myid.toString();
            }
			*/
            
			//trace( 'sid', mysid );
			
			if ( _nodesByStringId.hasOwnProperty( sid ) )
			{
				return _nodesByStringId[ sid ]; 
			}
			
            myNode = new Node( sid, null, o );
            
            _nodes.unshift(myNode);
            _nodesByStringId[sid] = myNode;
            
            /* a new node means all potentially existing
            * trees in the treemap need to be invalidated */
            purgeTrees();
            
            return myNode;
        }
        
        /**
         * @inheritDoc
         * */
        public function removeNode(n:INode):void {
            /* we check if inEdges or outEdges
            * are not empty. This also works for
            * non directional graphs, even though one
            * comparison would be sufficient */
            if(n.inEdges.length != 0 || n.outEdges.length != 0) {
                throw Error("Attempted to remove Node: "+n.stringid+" but it still has Edges");
            } else {
                /* XXXX searching like this through arrays takes
                * LINEAR time, so at one point we might want to add
                * associative arrays (possibly Dictionaries) to map
                * the objects back to their index... */
                var myindex:int = _nodes.indexOf(n);
                
                /* check if node was not found */
                if(myindex == -1) {
                    throw Error("Node: "+n.stringid+" was not found in the graph's" +
                        "node table while trying to delete it");
                }
                
               
                
                /* remove node from list */
                _nodes.splice(myindex,1);
                
                
                
                delete _nodesByStringId[n.stringid];
                
				
                
                /* we need to do something about vnodes */
                if(n.vnode != null) {
                    throw Error("Node is still associated with its vnode, this leaves a dangling reference and a potential memory leak");
                }
                
                /* node should have no longer a reference now
                * so the GarbageCollector will get it */
                
                /* invalidate trees */
                purgeTrees()
            }
        }
        
		/**
		 * Вычисляет идентификатор связи по идентификаторам узлов которые он соединяет 
		 * @param id1 - идентификатор первого узла
		 * @param id2 - идентификатор второго узла
		 * @return идентификатор связи
		 * 
		 */		
		public static function calcEdgeStringID( id1 : String, id2 : String, num : String = '' ) : String
		{
			return id1 + '/' + id2 + '/' + num;
		}
		
		/**
		 * Инкрементор уникальных идентификаторов связей 
		 */		
		private var _uniqEdgeIdInc : uint = 1;
		
		/**
		 * Вычисляет уникальный идентификатор связи 
		 * @param node1 - узел 1
		 * @param node2 - узел 2
		 * @return 
		 * 
		 */		
		private function calcUniqEdgeStringID( id1 : String, id2 : String ) : String
		{
			var eid : String;
			
			do
			{
				eid = calcEdgeStringID( id1, id2, _uniqEdgeIdInc.toString() );
				
				_uniqEdgeIdInc ++;	
			}
			while( _edgesByStringId[ eid ] != null );
			
			return eid;
		}
		
		/**
		 * Ищет  
		 * @param node1
		 * @param node2
		 * @return 
		 * 
		 */		
		/*private function getEdgeFromNodes( node1 : INode, node2 : INode ) : IEdge
		{
			var edgeID : String = calcEdgeStringID( node1.stringid, node2.stringid );
			
			if ( _edgesByStringId.hasOwnProperty( edgeID ) )
			{
				return _edgesByStringId[ edgeID ];
			}
			
			return null;
		}*/
		
		/**
         * @inheritDoc
         * */
        public function link( node1 : INode, node2 : INode, sid : String = null, o : Object = null ):IEdge
		{
            var retEdge:IEdge;
            
            if ( node1 == null )
			{
                throw Error("link: node1 was null");
            }
			
            if ( node2 == null )
			{
                throw Error("link: node2 was null");
            }
            
			//Если id не указан, генерируем уникальный идентификатор ( идентификатор будет сгенерирован, даже если связь связывающая
			//два одинаковых узла в одном направлении уже существует )
			if ( sid == null )
			{
			    sid = calcUniqEdgeStringID( node1.stringid, node2.stringid );
				o.id = sid;
			}
			
			//Если уже имеется свзь, связывающая два таких же узла, то ничего не создаем
			retEdge = _edgesByStringId[ sid ];
			
			if ( retEdge )
			{
				return retEdge;
			}
			
			//Если в dataSource, не указаны св-ва fromId, toId - указываем их
            if ( ! o.hasOwnProperty( 'fromId' ) )
			{
				o[ 'fromId' ] = node1.stringid;
			}
			
			if ( ! o.hasOwnProperty( 'toId' ) )
			{
				o[ 'toId' ] = node2.stringid;
			}
				
			
			    // link does not exist, so we can create it
                //var newEid:int = ++_currentEdgeId;
                /* not sure where we will be able to set the visual edge
                * as it must exist first, for now we pass null 
                * since the attribute has also a setter */
                var newEdge:Edge = new Edge( this, null, sid, node1, node2, o );
                _edges.unshift( newEdge );
                //++_numberOfEdges;
                
                /* now register the edge with its nodes */
                node1.addOutEdge(newEdge);
                node2.addInEdge(newEdge);
                
                /* if we are a NON directional graph we would have
                * to add another edge also vice versa (in the other
                * direction), but that leaves us with the question
                * which of the edges to return.... maybe it can be
                * handled using the same edge, if the in the directional
                * case, the edge returns always the other node */
                //LogUtil.debug(_LOG, "Graph is directional? "+_directional.toString());
                
                    node1.addInEdge(newEdge);
                    node2.addOutEdge(newEdge);
                    //LogUtil.debug(_LOG, "graph is not directional adding same edge:"+newEdge.id+
                    //" the other way round");
                
                retEdge = newEdge;
				
				_edgesByStringId[ sid ] = retEdge;
            //}
            
            /* invalidate trees */
            purgeTrees()
            return retEdge;
        }
        
        /**
         * @inheritDoc
         * */
        public function unlink(node1:INode, node2:INode):void {
            
            /* find the corresponding edge first */
            var e:IEdge;
            
            e = getEdge(node1,node2);
            
            if(e == null) {
                throw Error("Could not find edge, Nodes: "+node1.stringid+" and "
                    +node2.stringid+" may not be linked.");
            } else {
                removeEdge(e);
            }
        }
        
        /**
         * @inheritDoc
         * */
        public function getEdge(n1:INode, n2:INode):IEdge {
            var outedges : Vector.<IEdge> = n1.outEdges;
            var e:IEdge = null;
            for each (var edge:Edge in outedges) {
                if(edge.othernode(n1) == n2) {
                    e = edge;
                    return e;
                }
            }
            return null;
        }
        
        /**
         * @inheritDoc
         * */
        public function removeEdge(e:IEdge):void {
            var n1:INode = e.node1;
            var n2:INode = e.node2;
            var edgeIndex:int = _edges.indexOf(e);
            
            if(edgeIndex == -1) {
                throw Error("Edge: "+e.stringid+" does not seem to exist in graph "+_id);
                // here we would need to abort the script
            }
            
            n1.removeOutEdge(e);
            n2.removeInEdge(e);
            n1.removeInEdge(e);
            n2.removeOutEdge(e);
            
            
            /* now remove from the list of edges */
            _edges.splice(edgeIndex,1);
            
			delete _edgesByStringId[ e.stringid ];
            
            /* invalidate trees */
            purgeTrees()
        }
        
        /**
         * @inheritDoc
         * */
        public function purgeGraph():void {
            
            while(_edges.length > 0) {
                removeEdge(_edges[0]);
            }
            
            while(_nodes.length > 0) {
                removeNode(_nodes[0]);
            }
            purgeTrees();
        }
			
		/*Возвращает все группы узлов не связанных друг с другом*/
		public function getNodesGroups() : Vector.<Dictionary>
		{
			var groups : Vector.<Dictionary> = new Vector.<Dictionary>();
			
			if ( _nodes.length > 0 )
			{
				var t : IGTree = new GTree( _nodes[ 0 ], this );
				    t.initTree();    
				
				groups.push( t.nodes );
				
				var found   : Boolean;
				var subNode : INode;
				var cNode   : INode;
				var group   : Dictionary;
				var i       : int = 0;
				
				for( i = 1; i < _nodes.length; i ++ )
				{
					cNode = _nodes[ i ];
					found = false;
					
					//Проверяем есть ли указанный узел в какой либо из групп
					loop : for each( group in groups )
					{
						for each( subNode in group )
						{
							if ( subNode == cNode )
							{
								found = true;
								break loop;
							}
						}
					}
					
					//Если узел не найден ни в одной из групп, создаем новую
					if ( ! found )
					{
						t.root = cNode;
						t.initTree();
						
						groups.push( t.nodes );
					}
				}
			}
			
			return groups;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function getNodesWithoutLinks() : Vector.<INode>
		{
			var result  : Vector.<INode> = new Vector.<INode>();
			var node    : INode;
			var edge    : IEdge;
			var noLinks : Boolean;
			
			for each( node in _nodes )
			{
				noLinks = true;
				
				for each( edge in _edges )
				{
					if ( ( edge.node1.stringid == node.stringid ) || ( edge.node2.stringid == node.stringid ) )
					{
						noLinks = false;
						break;
					}
				}
				
				if ( noLinks )
				{
					result.push( node );
				}
			}
			
			
			return result.length == 0 ? null : result;
		}
		
		/*--------------------------*/
    }
}
