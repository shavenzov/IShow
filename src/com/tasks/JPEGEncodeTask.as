package com.tasks
{
	import cmodule.aircall.CLibInit;
	
	import com.thread.BaseRunnable;
	
	import flash.display.BitmapData;
	import flash.system.System;
	import flash.utils.ByteArray;

	public class JPEGEncodeTask extends BaseRunnable implements IEncodeTask
	{
		/**
		 * Bitmap данные которого необходимо закодировать JPEG 
		 */		
		private var _bitmapData : BitmapData;
		
		/**
		 * Качество кодируемого изображения ( 0 .. 100 ) 
		 */		
		private var _quality : Number;
		
		/**
		 * Данные для кодирования 
		 */		
		private var _inData  : ByteArray;
		
		/**
		 * Кодированные данные JPEG 
		 */		
		private var _outData : ByteArray;
		
		/**
		 * Alchemy библиотека для кодирования 
		 */		
		private var jpeginit : CLibInit;
		
		/**
		 * jpeglib, может быть только в одном экземпляре 
		 */		
		private static var jpeglib  : Object;
		
		public function JPEGEncodeTask( quality : Number = 80.0 )
		{
		  super();
		  
		  _name   = 'JPEG';
		  _total  = 100;
		  
		  _quality    = quality;
		}
		
		public function get outData() : ByteArray
		{
			return _outData;
		}
		
		public function setInputData( data : BitmapData ) : void
		{
			_bitmapData = data;
		}
		
		private function init() : void
		{
		  _inData  = _bitmapData.getPixels( _bitmapData.rect );
		  _inData.position = 0;
		  
		  _outData = new ByteArray();
			
		  if ( ! jpeglib )
		  {
			  jpeginit = new CLibInit(); 
			  jpeglib  = jpeginit.init();  
		  }
		  
		  jpeglib.encodeAsync( encodeComplete, _inData, _outData, _bitmapData.width, _bitmapData.height, _quality );
		}
		
		private function encodeComplete( image_data : ByteArray ) : void
		{
			_progress = _total;
			
			_bitmapData = null;
			
			_inData = null;
			
			System.gc();
		}
		
		override public function process():void
		{
			if ( ! _inData )
			{
				init();
				return;
			}
			
			_progress = ( _inData.position / _inData.length ) * 100;
		}
	}
}