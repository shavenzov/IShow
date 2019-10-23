package com.controls
{
	import com.controls.Preloader;
	import com.dataloaders.GlobalImageCash;
	import com.dataloaders.ImageCash;
	import com.utils.ImageUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	public class CachedImage extends UIComponent
	{
		private var imageCash : ImageCash;
		
		private var _url      : String;
		private var preloader : Preloader;
		protected var image     : DisplayObject;
		
		private var loader : Loader;
		
		//Размер изображения
		private var _size : Number;
		
		public function CachedImage() : void
		{
			super();
			
			imageCash = GlobalImageCash.impl;
		}
		
		public function get size() : Number
		{
			return _size;
		}
		
		public function set size( value : Number ) : void
		{
			if ( _size != value )
			{
				_size = value;
				invalidateSize();
				invalidateDisplayList();	
			}
		}
		
		/**
		 * Определяет было ли изображение отмасштабировано в соответствии с параметром size или нет 
		 * @return 
		 * 
		 */		
		public function get resized() : Boolean
		{
			if ( image )
			{
			   return ( image.scaleX != 1.0 ) || ( image.scaleY != 1.0 );	
			}
			
			return false;
		}
		
		public function get url() : String
		{
			return _url;
		}
		
		public function set url( value : String ) : void
		{
			if ( value == _url )
			{
				return;
			}
			
			_url = value;
			
			unsetLoaderListeners();
			
			if ( image )
			{
				removeChild( image );
				image = null;
			}
			
			if ( preloader )
			{
				removeChild( preloader );
				preloader = null;
			}
			
			if ( _url )
			{
				if ( loaded )
				{
					image = imageCash.getClonedImage( _url );
					addChildAt( image, 0 );
				}
				else
				{
					loader = imageCash.getImage( _url );
					setLoaderListeners();
					if ( ! image )
					{
						preloader = new Preloader();
						addChildAt( preloader, 0 );
						invalidateDisplayList();
					}
				}
			}
			
			invalidateSize();
		}
		
		public function get loaded() : Boolean
		{
			return imageCash.imageIsLoaded( _url );
		}
		
		private function setLoaderListeners() : void
		{
			if ( loader )
			{
				loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, onProgress );
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete );
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onComplete );
				loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onComplete );
			}
		}
		
		private function unsetLoaderListeners() : void
		{
			if ( loader )
			{
				loader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, onProgress );
				loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onComplete );
				loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onComplete );
				loader.contentLoaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onComplete );
				
				loader = null;  
			}
		}
		
		private function onProgress( e : ProgressEvent ) : void
		{
			preloader.setProgress( e.bytesLoaded, e.bytesTotal );
			dispatchEvent( e );
		}
		
		protected function getDummyImage() : DisplayObject
		{
			var s : Shape = new Shape();
			    s.graphics.beginFill( 0x00fff00 );
				s.graphics.drawRect( 0, 0, 1, 1 );
				s.graphics.endFill();
				
				s.width  = 48.0;
				s.height = 48.0;
				
			return s;	
		}
		
		private function onComplete( e : Event ) : void
		{
			unsetLoaderListeners();
			
			if ( preloader )
			{
				removeChild( preloader );
				preloader = null;
			}
			
			if ( e.type == Event.COMPLETE )
			{
				image = imageCash.getClonedImage( url );	
			}
			else
			{
				image = getDummyImage();
			}
			
			addChildAt( image, 0 );
			invalidateSize();
			invalidateDisplayList();
			
			//Уведомляем, что какое-то изображение получено (реальное или "Пустышка", в случае ошибки)
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		/*
		private function onIOError( e : IOErrorEvent ) : void
		{
			unsetLoaderListeners();
			trace( e.text );
		}
		
		private function onSecurityError( e : SecurityErrorEvent ) : void
		{
			unsetLoaderListeners();
		}
		*/
		override protected function measure():void
		{
			if ( preloader )
			{
				if ( isNaN( _size ) )
				{
					measuredWidth  = 48.0;
					measuredHeight = 48.0;
				}
				else
				{
				   measuredWidth = measuredHeight = _size;	
				}
			}
			
			if ( image )
			{
				if ( isNaN( _size ) || ( Math.max( image.width, image.height ) <= _size ) )
				{
					measuredWidth  = image.width;
					measuredHeight = image.height;	
				}
				else
				{
					var scaledSize : Point = ImageUtil.getScaledSize( image, _size );
					
					measuredWidth  = scaledSize.x;
					measuredHeight = scaledSize.y;
				}
			}
		}
		
		override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
		{
			if ( preloader )
			{
				preloader.x = ( unscaledWidth - preloader.width ) / 2;
				preloader.y = ( unscaledHeight - preloader.height ) / 2;
			}
			else
			{
				image.width  = unscaledWidth;
				image.height = unscaledHeight;	
			}
		}
	}
}