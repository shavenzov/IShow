package com.tasks
{
	import com.thread.BaseRunnable;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.system.System;
	import flash.utils.ByteArray;
	
	public class PNGEncodeTask extends BaseRunnable implements IEncodeTask
	{
		/**
		 * Bitmap данные которого необходимо закодировать в PNG 
		 */		
		private var _bitmapData : BitmapData;
		
		/**
		 * Уровень сжатия
		 */		
		private var _compressionLevel : CompressionLevel = CompressionLevel.GOOD;
		
		/**
		 * Кодированные данные PNG 
		 */		
		private var _outData : ByteArray;
		
		/**
		 * Кодер 
		 */		
		private var _encoder : PNGEncoder2;
		
		public function PNGEncodeTask( compressionLevel : CompressionLevel = null )
		{
			super();
			
			_name   = 'PNG';
			_total  = 100;
			
			if ( compressionLevel )
			{
				_compressionLevel = compressionLevel;	
			}
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
			PNGEncoder2.level = _compressionLevel;
			
			_encoder = PNGEncoder2.encodeAsync( _bitmapData );
			
			_encoder.addEventListener( Event.COMPLETE, encodeComplete );
			_encoder.addEventListener( ProgressEvent.PROGRESS, encodeProgress );
		}
		
		private function encodeComplete( e : Event ) : void
		{
			_outData = _encoder.png;
			
			_progress = _total;
			
			_bitmapData = null;
			
			_encoder.removeEventListener( Event.COMPLETE, encodeComplete );
			_encoder.removeEventListener( ProgressEvent.PROGRESS, encodeProgress );
			
			System.gc();
		}
		
		private function encodeProgress( e : ProgressEvent ) : void
		{
			_progress = ( e.bytesLoaded / e.bytesTotal ) * 100;
		}
		
		override public function process():void
		{
			if ( ! _encoder )
			{
				init();
				return;
			}
		}
	}
}