package com.dataloaders
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;

	public class ImageCash extends DataLoader
	{
		private const _cash : Vector.<LoaderRecord> = new Vector.<LoaderRecord>();
		
		public function ImageCash(MAX_PARALLEL_REQUESTS:uint=6)
		{
			super(MAX_PARALLEL_REQUESTS);
		}
		
		public function get cash() : Vector.<LoaderRecord>
		{
			return _cash;
		}
		
		public function getImage( src : String ) : Loader
		{
			var index : int = getObjectIndex( _cash, src );
			
			if ( index != -1 )
			{
				return LoaderInfo( _cash[ index ].loader ).loader;
			}
			
			var loader : Loader = new Loader();
			var record : LoaderRecord = new LoaderRecord( src, loader.contentLoaderInfo );
			
			putToQueue( record );	
			
			_cash.push( record );
			
			return loader;
		}
		
		public function imageIsLoaded( src : String ) : Boolean
		{
			var index : int = getObjectIndex( _cash, src );
			
			return ( index != -1 ) && ( ! isObjectLoading( _cash[ index ].data ) );
		}
		
		public function getClonedImage( src : String ) : DisplayObject
		{
			var index : int = getObjectIndex( _cash, src );
			
			if ( index != -1 )
			{
				return new Bitmap( Bitmap( LoaderInfo( _cash[ index ].loader ).loader.content ).bitmapData );
			}
			else throw new Error( "Can't find image with src " + src );
		}
		
		override protected function itemIOError(e:IOErrorEvent):void
		{
			trace( e );
			
			var loader : Object = e.currentTarget;
			var index  : int = getRecordIndexByLoader( _cash, loader );
			_cash.splice( index, 1 );
			
			super.itemIOError( e );
		}
		
		override protected function itemSecurityError(e:SecurityErrorEvent):void
		{
			trace( e );
			
			var loader : Object = e.currentTarget;
			var index  : int = getRecordIndexByLoader( _cash, loader );
			_cash.splice( index, 1 );
			
			super.itemSecurityError( e );
		}
		
		override protected function initLoad(record:LoaderRecord):void
		{
			super.initLoad( record );
			try
			{
				record.loader.loader.load( new URLRequest( String( record.data ) )/*, new LoaderContext( true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain )*/ );
			}
			catch( error : SecurityError )
			{
				trace( error.message );
			}
		}
	}
}