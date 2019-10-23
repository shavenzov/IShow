package org.un.cava.birdeye.ravis.graphLayout.layout
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;

	public class BubbleLayoutDrawing extends BaseLayoutDrawing
	{
		/*
		Пройденное расстояние в радианах влево
		*/
		public var lAngles : Dictionary;
		
		/*
		Пройденное расстояние в радианах вправо
		*/
		public var rAngles : Dictionary;
		
		public var linkLengths : Dictionary;
		public var angleOffsets : Dictionary;
		public var startAngles : Dictionary;
		 
		public function BubbleLayoutDrawing()
		{
			super();
			
			lAngles      = new Dictionary();
			rAngles      = new Dictionary();
			
			linkLengths  = new Dictionary();
			angleOffsets = new Dictionary();
			startAngles  = new Dictionary();
		}
		
		/*
		public function traceNodes() : void
		{
			for each( var pos : Point in nodeCartCoordinates )
			{
				trace( 'pos', pos );
			}
		}
		*/
		
		/**
		 * Определяет прямоугольную область узла 
		 * @param n - узел
		 * @return занимаемая им прямоугольная область в пространстве или null, если область не удалось определить
		 * 
		 */	
		
		/*
		!!!!!!!!!!!!!!!!!!!!  Необходимо использовать параметр fitToWindow, для определения Bounds
		*/
		public function getBounds( node : INode ) : Rectangle
		{
			var rect  : Rectangle;
			
			/*if ( rect )
			{
				return rect;
			}*/
			
			var pos : Point = nodeCartCoordinates[ node ];
			
			//Прямоугольная область node
			if ( pos )
			{
				//if ( node.vnode && node.vnode.view )
				//{
					var bounds : Rectangle = node.vnode.view.getBounds( node.vnode.view.parent );
					
					rect = new Rectangle( pos.x, pos.y, bounds.width, bounds.height );
				/*}
				else
				{
					rect = new Rectangle( pos.x, pos.y, BaseLayouter.MINIMUM_NODE_WIDTH, BaseLayouter.MINIMUM_NODE_HEIGHT );
				}*/
			}
			
			return rect;
		}
	}
}