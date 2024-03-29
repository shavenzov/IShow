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
package org.un.cava.birdeye.ravis.graphLayout.layout {
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	
	
	/**
	 * this interface defines all function calls
	 * that are needed to rearrange/layout a visualised
	 * graph.
	 * It also handles mouse interaction for moving objects
	 * (not for other stuff)
	 * */
	
	/**
	 * The interface to all layout algorithms that should work
	 * with VisualGraph components and underlying Graph data
	 * structures. This interface defines all the methods required
	 * to control the aspects of a layouter.
	 * */
	public interface ILayoutAlgorithm extends IEventDispatcher {
		
        function get layoutDrawing() : ILayoutDrawing;
		
		function get bounds():Rectangle
        
		function get paddingLeft():Number
		function set paddingLeft(value:Number):void
		
		function get paddingRight() : Number
		function set paddingRight( value : Number ) : void
			
		function get paddingTop() : Number
		function set paddingTop( value : Number ) : void
			
		function get paddingBottom() : Number
		function set paddingBottom( value : Number ) : void	
			
		/**
		 * Assign a VisualGraph object to the layouter,
		 * every layouter will need one to work, some may
		 * also offer to set it in their constructor.
		 * The layouter may choose to implicitly also set the
		 * graph object if it is found within the VisualGraph object.
		 * @param vg The VisualGraph object to assign.
		 * @see org.un.cava.birdeye.ravis.graphLayout.visual.VisualGraph#graph
		 * */
		function set vgraph( vg : IVisualGraph ) : void;
		function get vgraph() : IVisualGraph;
		
		/**
		 * Assign a Graph datastructure object to the
		 * layouter, every layouter will need one to work
		 * and some may allow to set it in their constructor
		 * @param g The Graph object to assign.
		 * */
		function get graph() : IGraph;
		
		/**
		 * Access to a value that controls the length
		 * of links (or rather edges). It is up to the
		 * layouter what to do with it, and some may ignore
		 * this value under certain circumstances (like autoFit).
		 * The interface requires the value to be between 0 and 100;
		 * @default 10
		 * @param r The value to set.
		 * */
		function set linkLength(r:Number):void;
		
		/**
		 * @private
		 * */
		function get linkLength():Number;
		
		/**
		 * Flag to indicate whether the Layouter should attempt
		 * to automatically fit the layout to the screen.
		 * */
		function set autoFitEnabled(af:Boolean):void;
		
		/**
		 * @private
		 * */
		function get autoFitEnabled():Boolean;
		
		/**
		 * ( Это св-во имеет смысл только при autoFitEnabled = true )
		 * true  - компоновщик должен уместить все элементы в видимом окне
		 * false - компоновщик должен разместить узлы, так что-бы они не заезжади друг на друга
		 * 
		 */		
		function get fitToWindow() : Boolean;
		function set fitToWindow( ftw : Boolean ) : void;
		
		/**
		 * Идентификатор корневого элемента раскладки 
		 * @return 
		 * 
		 */		
		function get root() : INode;
		function set root( value : INode ) : void;
		
		/**
		 * Область построения раскладки ( 0.0, 0.0, width, height ) 
		 * @return 
		 * 
		 */		
		function get boundingRect() : Rectangle;
		function set boundingRect( value : Rectangle ) : void;
		
		/**
		 * Indicator if the layout has changed or not. This
		 * can be used to notify the layouter, that some external
		 * means (like dragging & dropping a node) has changed the
		 * layout, and it will also be set by the layouter itself
		 * when the layouter updated the layout. This is used by
		 * the VisualGraphs "updateDisplayList()" method, to see
		 * whether to redraw all edges using the EdgeRenderer.
		 * @see org.un.cava.birdeye.ravis.graphLayout.visual.VisualGraph#updateDisplayList()
		 * */
		function set layoutChanged(lc:Boolean):void;
		
		/**
		 * @private
		 * */
		function get layoutChanged():Boolean;
		
		/**
		 * Indicator if currently an animation sequence is still
		 * in progress. During certain animation sequences, drag&drop
		 * might be disabled
		 * */
		function get animInProgress() : Boolean;
		function set animInProgress( value : Boolean ) : void;
		
		/**
		 * If set to true, animation is disabled and direct
		 * node location setting occurs (instantaneously).
		 * @default false
		 * */
		function set disableAnimation(d:Boolean):void;
		
		/**
		 * @private
		 * */
		function get disableAnimation():Boolean;
		
		
		/**
		 * This should reset all parameters of the layouter,
		 * which might not be needed for all layouters, and it is
		 * up to each layouter to do something with it.
		 * It would also stop any existing layouting loops/timers.
		 * */
		function resetAll():void;
		
		/**
		 * This is the main method of the layouter, that actually
		 * implements the calculation of the layout. It will be called
		 * by the VisualGraph on any significant change that will
		 * require a layout to be recomputed.
		 * @return true if something was done successfully, false otherwise.
		 * */
		function layoutPass() : void;
		
		/**
		 * Вычисляет координаты узлов для раскладки 
		 * 
		 */		
		function calculate() : void;
		
		/**
		 * Применяет предварительно расчитанные координаты к визуальным узлам 
		 * 
		 */		
		function commit()    : void;
		
		function get data() : Object;
		function set data( value : Object ) : void;
		
		/**
		 * Указывает, что для раскладки необходим корневой элемент 
		 * @return 
		 * 
		 */		
		function get needRoot() : Boolean;
		
		/**
		 * Возвращает прямоугольную область которую будет занимать раскладка ( предварительный расчет. До того как раскладка будет применена к узлам ) 
		 * @param nodes
		 * @return 
		 * 
		 */		
		function calculateBounds( nodes : * ) : Rectangle;
		
		/**
		 * Возвращает клон алгоритма раскладки 
		 * @return 
		 * 
		 */		
		function clone() : ILayoutAlgorithm;
	}
}