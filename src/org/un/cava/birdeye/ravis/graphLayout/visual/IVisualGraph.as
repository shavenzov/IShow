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
package org.un.cava.birdeye.ravis.graphLayout.visual {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import mx.core.IFactory;
	import mx.core.IInvalidating;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ComplexLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.IAsynchronousLayouter;
	import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
	
	/**
	 * Interface to the VisualGraph Flex Component,
	 * which also has to implement the IUIComponent
	 * and the IInvalidating interface.
	 * */
	public interface IVisualGraph extends IUIComponent, IInvalidating {
		
		/**
		 * Access to the underlying Graph datastructure object.
		 * */
		function get graph():IGraph;
		
		/**
		 * @private
		 * */
		function set graph(g:IGraph):void
		
		
		/**
		 * Allow the provision of an ItemRenderer (which is
		 * more precisely an IFactory). This is important to allow
		 * the Drawing of the items in a customised way.
		 * Note that any ItemRenderer will have to be a UIComponent.
		 * */
		function set itemRenderer(ifac:IFactory):void;
		
		/**
		 * @private
		 * */
		function get itemRenderer():IFactory;
		
		
		/**
		 * Allow the provision of an EdgeRenderer to
		 * allow drawing of edges in a customised way.
		 * The edgeRenderer has to implement the IEdgeRenderer interface.
		 * */
		function set edgeRendererFactory(er:IFactory):void;
		
		/**
		 * @private
		 * */
		function get edgeRendererFactory():IFactory;
		
		/**
		 * Allow to provide an EdgeLabelRenderer in order to
		 * display edge labels. The created instances must be
		 * UIComponents.
		 * */
		function set edgeLabelRenderer(elr:IFactory):void;
		
		/**
		 * @private
		 * */
		function get edgeLabelRenderer():IFactory;
		
		/**
		 * Specify whether to display edge labels or not.
		 * If no edge label renderer is present a default
		 * will be used.
		 * */
		function set displayEdgeLabels(del:Boolean):void;
		
		/**
		 * @private
		 * */
		function get displayEdgeLabels():Boolean;
		
		/**
		 * Access to the layouter to be used for the
		 * layout of the graph.
		 * */
		function get layouter():ILayoutAlgorithm;

		/**
		 * @private
		 * */		
		function set layouter(l:ILayoutAlgorithm):void;
		
		/**
		 * Алгоритм раскладки который был использован при последней перерисовке 
		 */		
		function get lastLayouter() : ILayoutAlgorithm;
		
		/**
		 *   Если lastLayouter асинхронный, то возвращает ссылку на интерфейс асинхронного lastLayouter
		 */		
		function get lastAsynchrounousLayouter() : IAsynchronousLayouter;
		
		/**
		 * Если layouter асинхронный, то возвращает ссылку на интерфейс асинхронного layouter
		 */		
		function get asynchrounousLayouter() : IAsynchronousLayouter;
		
		function get complexLayouter() : ComplexLayouter;

		/**
		 * Provide access to the current origin of the of the Visual Graph
		 * which is required for proper drawing.
		 * */
		function get origin():Point;
		
		/**
		 * Provide access to the center point of the VGraph's
		 * drawing surface, used by layouters to properly center
		 * their layout.
		 * */
		function get center():Point;
		
		/**
		 * Provide access to a list of currently visible VNodes.
		 * This is very important for layouters, if we have many many
		 * nodes, but only a few of them are visible at a time. Layouters
		 * typically will only layout the currently visible nodes.
		 * */
		function get vnodes() : Dictionary;
		
		/**
		 * Returns the number of currently visible nodes.
		 * */
		function get noVNodes() : uint;
		
		/**
		 * Provide access to a list of currently visible edges,
		 * i.e. edges whose both nodes are visible and thus need
		 * to be drawn. Likewise this can save a lot of CPU if
		 * the layouter only needs to consider the currently visible
		 * edges.
		 * */
		function get vedges() : Dictionary;

		/**
		 * Set or get the current root node (or focused node). Setting
		 * this property will result in a redraw of the graph to reflect
		 * the change (if it was actually a change).
		 * */
		function get currentRootVNode():IVisualNode;

		/**
		 * @private
		 * */
		function set currentRootVNode(vn:IVisualNode):void;
		
		/**
		 * The scale property of VGraph will affect
		 * the scaleX and scaleY properties and also
		 * will ensure drag&drop works properly.
		 * */
		function get scale():Number;
		
		/**
		 * @private
		 * */
		function set scale( s : Number ) : void;
		
		
		function zoomIn() : void
		
		function zoomOut() : void;	
		
		function getVNodeByView( view : UIComponent ) : IVisualNode
		
		/**
		 * Initializes the VisualGraph from its currently set Graph object,
		 * basically removing all existing VNodes and VEdges and
		 * recreating them based on the information found in the associated
		 * Graph object.
		 * */
		function initFromGraph( creationPoint : Point = null, setVisibilityTo : Boolean = true ):void;
		
		/**
		 * Create a new Node in this VisualGraph, this automatically
		 * creates an underlying Node in the Graph object. It does not
		 * link the node to any other node, yet and it does not trigger
		 * a layout pass. The reason is that currently all layouters require
		 * a CONNECTED graph, since the new node would create a disconnected
		 * graph (since it is not linked, yet) this would break things.
		 * @param sid The string id of the new node.
		 * @param o The data object of this new node.
		 * @return The created VisualNode object.
		 * */
		function createNode(sid:String = "", o:Object = null, creationPoint : Point = null, createView : Boolean = true):IVisualNode;
		
		/**
		 * Removes a node from this VisualGraph. This removes any associated
		 * VEdges and Edges with the node and of course the underlying Node from
		 * the Graph datastructure.
		 * @param vn The VisualNode to be removed.
		 * */
		function removeNode(vn:IVisualNode):void;
		
		/**
		 * Удаляет указанную связь из графа 
		 * @param e the VisualEdge to be removed
		 * 
		 */		
		function removeEdge( e : IVisualEdge ) : void; 
		
		/**
		 * Links two nodes, thus creating an edge. If the underlying Graph
		 * is directional, the order matters, not otherwise. If the nodes are
		 * already linked, simply returns the existing edge between them.
		 * @param v1 The first node (from node) to link.
		 * @param v2 The second node (to node) to link.
		 * @return The created VisualEdge.
		 * */
		function linkNodes(v1:IVisualNode, v2:IVisualNode, data : Object = null):IVisualEdge;
		
		/**
		 * Unlinks two nodes, thus removing the edge between them, if it
		 * exists. Does nothing if the nodes were not linked.
		 * Again, order matters of the graph is directional.
		 * @param v1 The first node to unlink.
		 * @param v2 The second node to unlink.
		 * */
		function unlinkNodes(v1:IVisualNode, v2:IVisualNode):void;
	
		/**
		 * Calling this results in a redrawing of all edges during the next
		 * update cycle (and only the edges).
		 * */
		function refresh():void;
		
		/**
		 * Calling this forces a full calculation and redraw of the layout
		 * including all edges.
		 * */
		function draw( l : ILayoutAlgorithm  = null ) : void;

		/**
		 * This forces a redraw of all edges */
		function redrawEdges():void;
		
		/**
         * This forces a redraw of all nodes and their renderers */
		function redrawNodes():void;
		
		/**
		 * Scrolls all objects according to the specified coordinates
		 * (used as an offset).
		 * */
		function scroll(sx:Number, sy:Number/*, reset:Boolean*/):void;
		
		/**
		 * Вычисляет обрамляющую область группы узлов 
		 * @param nodes группа узлов для которых необходимо вычисление, может быть Vector.<IVisualNode> или Vector.<INode> или Dictionary.<INode>
		 * @return прямоугольная область занимаемая узлами
		 * 
		 */			
		function getNodesGroupBoundsV( nodes : * = null ) : Rectangle;
		
		/**
		 * Устанавливает размер рабочей области (!!!Внимание только для внутреннего использования!!!) 
		 * @param bounds
		 * 
		 */
		function set bounds( value : Rectangle ) : void
		function get bounds() : Rectangle;	
		
		/**
		 * Режим работы, прокрутка "Лапой" или выделение 
		 * @return 
		 * 
		 */		
		function get mode() : int;
		function set mode( value : int ) : void;
		
		/**
		 * Включить / выключить отображение сетки 
		 */
		function get showGrid() : Boolean;
		function set showGrid( value : Boolean ) : void;
		
		/**
		 * Словарь выбранных узлов IVisualNode 
		 * @return 
		 * 
		 */		
		function get selectedNodes() : Dictionary;
		function set selectedNodes( value : Dictionary ) : void;
		
		/**
		 * Количество выбранных узлов 
		 * @return 
		 * 
		 */		
		function get noSelectedNodes() : uint;
		
		/**
		 * Словарь выбранных связей IVisualEdge 
		 * @return 
		 * 
		 */		
		function get selectedEdges() : Dictionary;
		function set selectedEdges( value : Dictionary ) : void
		
		/**
		 * Количество выбранных связей 
		 * @return 
		 * 
		 */			
		function get noSelectedEdges() : uint;	
			
		/**
		 * 
		 * Если, имеются узлы с отрицательными значениями x или y, то смещаем все узлы, так что-бы все узлы имели положительные значения
		 * Корректирует прямоугольную область занимаемую компонентом после перетаскивания ( например, если перетаскиваемый узел ушел за границы экрана ) 
		 * 
		 */	
		function correctNodesPositionAndBounds() : void
			
		/**
		 * Все параметры графа в одном объекте 
		 * @return 
		 * 
		 */		
		function get data() : Object;
		function set data( value : Object ) : void
		
		/**
		 * Если указанный узел или связь не видны на экране, прокручивает так что-бы они были видны 
		 * @param object - IVisualNode или IVisualEdge
		 * 
		 */		
		function scrollToObject( object : Object ) : void
		function scrollToNodes( nodes : *, baseNode : IVisualNode = null, usePreBounds : Boolean = false  ) : void	
		
		/**
		 * Сбрасывает весь интерактив связанный с пользователем 
		 * 
		 */	
		function stopAllUserInteractions() : void;
		
		function vEdgeByStringId( id : String ) : IVisualEdge
		function vNodeByStringId( id : String ) : IVisualNode
			
		function get animateEdgesDirection() : Boolean
		function set animateEdgesDirection( value : Boolean ) : void	
	}
}