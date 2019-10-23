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
package org.un.cava.birdeye.ravis.graphLayout.visual
{
    import flash.display.DisplayObject;
    import flash.events.EventDispatcher;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.core.IDataRenderer;
    import mx.core.UIComponent;
    
    import org.un.cava.birdeye.ravis.components.renderers.nodes.INodeRenderer;
    import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
    import org.un.cava.birdeye.ravis.graphLayout.data.INode;
    
    /**
     * The VisualNode to be used in the Graph.
     * */
    public class VisualNode extends EventDispatcher implements IVisualNode, IDataRenderer {
        
        private static const _LOG:String = "graphLayout.visual.VisualNode";
        /* The associated VisualGraph */
        private var _vgraph:IVisualGraph;
        
        /* Internal id of the VisualNode */
        private var _id:String;
        
        /* Data object of the VisualNode */
        private var _data:Object;
        
        /* Indicates if the node shall be moveable or not
        * current UNUSED !!! */
        //private var _moveable:Boolean;
        
        /* Indicates of the node is currently visible */
        private var _visible:Boolean;
        
        /* the related Graph Node */
        private var _node:INode;
        
        /* the VisualNode's anticipated target X and Y coordinates.
        * Will be applied using the commit() method */
        //private var _x:Number;
        //private var _y:Number;
        
        /* The node's view which is the UIComponent that will
        * be displayed in Flashplayer */
        private var _view : UIComponent;
        
        /* instead of a left/top corner orientation
        * we can implicitly do a centered orientation 
        * this will be applied during the commit() method
        * and will be reversed during refresh() */
        private var _centered:Boolean = true;
        
        /*
        * A layouter can optionally set an orientation angle 
        * paramter in the node. Right now we hardcode this as
        * one single parameter. If we need more in the future,
        * we can replace this by a hash with multiple keys.
        * This parameter may be accessed by the nodeRenderer for instance.
        * The value is in degrees.
        */
        private var _orientAngle:Number = 0;
		
		/**
		 * Определяет, может ли алгоритм раскладки перемещать этот узел или нет ( только для раскладок, поддерживающих этот параметр ).  
		 */	
		private var _fixed : Boolean;
        
        /**
         * The constructor presets the VisualNode's data structures
         * and requires most parameters already present.
         * @param vg The VisualGraph that this VisualNode lives in.
         * @param node The associated Graph Node.
         * @param id The internal id of this node.
         * @param view The view/UIComponent of this node (if already present).
         * @param data The VisualNode's associated data object.
         * @param mv Indicator if the node is moveable (currently ignored).
         * */
        public function VisualNode( vg : IVisualGraph, node : INode, id : String, view : UIComponent = null, data : Object = null )
		{
            _vgraph = vg;
            _node = node;
            _id = id;
            
			if ( ! data )
			{
				_data = { x : 0.0, y : 0.0};
			}
			else
			{
				_data = data;	
			}
			
           this.view = view;
        }
        
        /**
         * Access to the associated VisualGraph, that this VisualNode lives in.
         * */
        public function get vgraph():IVisualGraph {
            return _vgraph;
        }
        
        /**
         * Access to the internal id of this VisualNode.
         * */
        public function get id():String {
            return _id;
        }
        
        /**
         * Access to the indicator if the node is currently
         * visible or not. If this is set to false, any
         * associated view will be removed in order to 
         * save resources.
         * */
        public function get isVisible():Boolean {
            return _visible;
        }
        
        /**
         * @private
         * */
        public function set isVisible(v:Boolean):void {
            _visible = v;
            
            /* set the views visibility, if we currently
            * have one */
            if( _view )
			{
                _view.visible = v;
            }
        }
        
        /**
         * @inheritDoc
         * */
        public function get node():INode {
            return _node;
        }
        
        /**
         * @inheritDoc
         * */
        public function get data() : Object
		{
			return _node && _node.data ? _node.data : _data;	
        }
        
        /**
         * @private
         * */
        public function set data(o:Object):void	{
            //_data = o;
			_node.data = o;
        }
        
        /**
         * @inheritDoc
         * */
        public function get centered():Boolean {
            return _centered;
        }
        
        /**
         * @private
         * */
        public function set centered(c:Boolean):void {
            _centered = c;
        }
        
        /**
         * @inheritDoc
         * */
        public function get x():Number {
            return /*_*/data.x;
        }
        
        /**
         * @private
         * */
        public function set x(n:Number):void
		{
            /*_*/data.x = n;
        }
        
        /**
         * @inheritDoc
         * */		
        public function get y():Number {
            return /*_*/data.y;
        }
        
        /**
         * @private
         * */
        public function set y(n:Number):void
		{
            /*_*/data.y = n;
        }
        
        /**
         * @inheritDoc
         * */		
        public function get viewX():Number {
            return this.view.x;
        }
        
        /**
         * @private
         * */
        public function set viewX(n:Number):void
		{
           
                if( n != this.view.x) {
                    this.view.x = n;
                }
            
        }
        
        
        /**
         * @inheritDoc
         * */
        public function get viewY():Number {
            return this.view.y;
        }
        
        /**
         * @private
         * */
        public function set viewY(n:Number):void
		{
           if( n != this.view.y )
		   {
              this.view.y = n;
           }
        }
         
        /**
         * @inheritDoc
         * */
        public function get view() : UIComponent {
            return _view;
        }
        
        /**
         * @private
         * */
        public function set view( v : UIComponent ):void
		{    
			_view = v;
        }
		
		public function get rendererView() : INodeRenderer
		{
			if ( _view )
			{
				return _view as INodeRenderer;
			}
			
			return null;
		}
        
        /**
         * @inheritDoc
         * */
        public function get viewCenter():Point {
            
			if ( _view )
			{
				if( _centered )
				{
					var bounds : Rectangle = getVisualBounds( _view.parent );
					
					return new Point( bounds.x + ( bounds.width / 2.0 ), bounds.y + ( bounds.height / 2.0 ) );
				} else
				{
					return new Point( _view.x, _view.y );
				}
			}
			
			return new Point( /*_*/data.x, /*_*/data.y );
        }
		
		public function getVisualBounds( targetCoordinateSpace : DisplayObject ) : Rectangle
		{
			if ( rendererView )
			{
				return rendererView.getVisualBounds( targetCoordinateSpace );	
			}
			
			if ( _view )
			{
				return _view.getBounds( targetCoordinateSpace );
			}
			
			return new Rectangle();
		}
        
        /**
         * @inheritDoc
         * */
        public function get orientAngle():Number {
            return _orientAngle;
        }
        
        /**
         * @private
         * */
        
		public function set orientAngle(oa:Number):void {
            _orientAngle = oa;
            /*if(this.view is IEventDispatcher) {
                (this.view as IEventDispatcher).dispatchEvent(new VGraphEvent(VGraphEvent.VNODE_UPDATED));
            }*/
        }
        
        /**
         * @inheritDoc
         * */			
        public function commit() : void
		{
            if( _view == null )
                return;
            
            if( UIComponent( view ).initialized == false)
            {
				UIComponent( view ).callLater(commit);
                return;
            }  
            
            /* if we have the centered orientation we apply
            * some corrections */
            if(_centered) {
				this.viewX = /*_*/data.x - ( rendererView.visualWidth / 2.0 );
                this.viewY = /*_*/data.y - ( rendererView.visualHeight / 2.0 );
                
            } else {
                this.viewX = /*_*/data.x;
                this.viewY = /*_*/data.y;
            }
            
            updateReleatedEdges();
            
            /*if(this.view is IEventDispatcher) {
                (this.view as IEventDispatcher).dispatchEvent(new VGraphEvent(VGraphEvent.VNODE_UPDATED));
            }*/
        }
        
        
        /**
         * @inheritDoc
         * */
        public function refresh():void {
            
            if(view == null)
                return;
            
            if( UIComponent( view ).initialized == false)
            {
				UIComponent( view ).callLater(refresh);
                return;
            }  
            
            /* have to recompensate for centered */
            if(_centered) {
                /*_*/data.x = this.viewX + ( rendererView.visualWidth / 2.0  );
                /*_*/data.y = this.viewY + ( rendererView.visualHeight / 2.0 );
            } else {
                /*_*/data.x = this.viewX;
                /*_*/data.y = this.viewY;
            }
			
            updateReleatedEdges();
        }
        
        public function updateReleatedEdges():void
        {
            for each(var edge:IVisualEdge in vedges)
            {
                if ( edge.edgeView )
				{
					edge.edgeView.render();	
				}
            }
        }
		
        public function get vedges() : Vector.<IVisualEdge>
        {
            var edge   : IEdge;
            var retVal : Vector.<IVisualEdge> = new Vector.<IVisualEdge>();
            
            for each( edge in node.inEdges )
            {
                if ( retVal.indexOf( edge.vedge ) == -1 )
                    retVal.push( edge.vedge );
            }
            
            for each( edge in node.outEdges )
            {
                if( ! retVal.indexOf( edge.vedge ) == -1 )
                    retVal.push( edge.vedge );
            }
            
            return retVal;
        }
		
		public function get fixed() : Boolean
		{
			return _fixed;
		}
		
		public function set fixed( value : Boolean ) : void
		{
			_fixed = value;
		}
    }
}