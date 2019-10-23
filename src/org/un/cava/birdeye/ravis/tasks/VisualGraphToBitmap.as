package org.un.cava.birdeye.ravis.tasks
{
	import mx.styles.IStyleClient;
	
	import spark.core.IViewport;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;

	public class VisualGraphToBitmap
	{
		/**
		 * Максимальная ширина Bitmap Data 
		 */		
		//private static const MAX_BITMAP_WIDTH  : Number = 8190.0;
		
		/**
		 * Максимальная высота Bitmap Data 
		 */		
		//private static const MAX_BITMAP_HEIGHT : Number = 8190.0;
		
		/**
		 * Размер отступов по краям 
		 */		
		private static const PADDING : Number = 16.0;
		
		/**
		 * Делает отпечаток графа в BitmapData 
		 * @param vg - граф для которого необходимо сделать отпечаток
		 * @return данные отпечатка
		 * 
		 */		
		public static function convert( vg : IVisualGraph ) : BitmapData
		{
			//Запоминаем текущие настройки графа
			var viewport               : IViewport    = IViewport( vg );
			var style                  : IStyleClient = IStyleClient( vg );
			var clipAndEnableScrolling : Boolean      = viewport.clipAndEnableScrolling;
			var showGrid               : Boolean      = vg.showGrid;
			var showBG                 : Boolean      = style.getStyle( 'backgroundFill' );
			
			//Отключаем отображение сетки, отсечение, задний фон
			viewport.clipAndEnableScrolling = false;
			vg.showGrid = false;
			style.setStyle( 'backgroundFill', false );
			vg.validateNow();
			
			var rect : Rectangle = vg.getNodesGroupBoundsV( vg.vnodes );    
			    Geometry.scaleRect( rect, vg.scale );
						
			    rect.left   -= PADDING;
				rect.top    -= PADDING;
				rect.bottom += PADDING;
				rect.right  += PADDING;
			
			var m      : Matrix = new Matrix( 1, 0, 0, 1, - rect.left, - rect.top ); 
			
			var bitmap : BitmapData = new BitmapData( Math.ceil( rect.width ), Math.ceil( rect.height ) );
			    bitmap.draw( vg, m, null, null, null, true );
			
			//Востанавливаем текущие настройки графа
			if ( viewport.clipAndEnableScrolling != clipAndEnableScrolling )
			{
				viewport.clipAndEnableScrolling = clipAndEnableScrolling;
			}
			
			if ( vg.showGrid != showGrid )
			{
				vg.showGrid = showGrid;
			}
			
			style.setStyle( 'backgroundFill', showBG );
				
			return bitmap;	
		}
	}
}