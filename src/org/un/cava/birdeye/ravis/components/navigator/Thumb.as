package org.un.cava.birdeye.ravis.components.navigator
{
	import mx.core.UIComponent;
	
	public class Thumb extends UIComponent
	{
		/**
		 * Верхняя кнопка изменения размера 
		 */		
		//public var topResizer : ResizeButton;
		
		/**
		 * Нижняя кнопка изменения размера 
		 */		
		//public var bottomResizer : ResizeButton;
		
		/**
		 * Кнопка изменения размера слева 
		 */		
		//public var leftResizer : ResizeButton;
		
		/**
		 * Кнопка изменения размера справа 
		 */		
		//public var rightResizer : ResizeButton;
		
		private static const RESIZER_SIZE : Number = 8.0;
		
		public function Thumb()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			/*topResizer    = new ResizeButton();
			bottomResizer = new ResizeButton();
			leftResizer   = new ResizeButton();
			rightResizer  = new ResizeButton();
			
			addChild( topResizer );
			addChild( bottomResizer );
			addChild( leftResizer );
			addChild( rightResizer );*/
		}
		
		override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			/*topResizer.x = 0.0;
			topResizer.y = 0.0;
			topResizer.width = unscaledWidth;
			topResizer.height = RESIZER_SIZE;
			
			bottomResizer.x = 0.0;
			bottomResizer.y = unscaledHeight - RESIZER_SIZE;
			bottomResizer.width = unscaledWidth;
			bottomResizer.height = RESIZER_SIZE;
			
			leftResizer.x = 0.0;
			leftResizer.y = 0.0;
			leftResizer.width = RESIZER_SIZE;
			leftResizer.height = unscaledHeight;
			
			rightResizer.x = unscaledWidth - RESIZER_SIZE;
			rightResizer.y = 0.0;
			rightResizer.width = RESIZER_SIZE;
			rightResizer.height = unscaledHeight;*/
			
			//Задний фон
			graphics.clear();
			graphics.lineStyle( 2.0, 0x330099, 0.35 );
			graphics.beginFill( 0x00ff00, 0.0 );
		    graphics.drawRect( 0, 0, unscaledWidth, unscaledHeight );
			graphics.endFill();
		}
	}
}