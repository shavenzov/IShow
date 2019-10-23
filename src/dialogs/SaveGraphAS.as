package dialogs
{
	import com.amf.events.AMFErrorEvent;
	import com.bs.amg.UnisAPI;
	import com.bs.amg.UnisAPIImplementation;
	import com.bs.amg.events.AMGEvent;
	import com.managers.PopUpManager;
	import com.tasks.IEncodeTask;
	import com.tasks.SaveTask;
	import com.thread.SimpleTask;
	import com.thread.Thread;
	
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.controls.ProgressBarMode;
	import mx.events.CloseEvent;
	
	import dialogs.views.SaveGraphASView;
	
	import org.un.cava.birdeye.ravis.assets.Assets;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.tasks.VisualGraphToBitmap;
	
	public class SaveGraphAS extends SimpleTask
	{
		/**
		 * Получение битмап данных графа 
		 */		
		public static const GETTING_BITMAP_DATA : int = 10;
		
		/**
		 * Кодирование 
		 */		
		public static const ENCODING : int = 20;
		
		/**
		 * Ожидание сохранения ( ждем пока пользователь нажмет на кнопку ) 
		 * 
		 */
		public static const WAITING_FOR_SAVING : int = 30;
		
		/**
		 * Идет процесс сохранения данных на компьютер пользователя 
		 */		
		public static const SAVING : int = 40;
		
		private var vg : IVisualGraph;
		
		/**
		 * Имя файла для сохранения по умолчанию 
		 */		
		private var defaultFileName : String;
		
		private var encoderName : String;
		
		/**
		 * Сохранить ли изображение в облако привязанное к объекту
		 */		
		private var saveToCloud : Boolean;
		
		/**
		 * 
		 * @param vg
		 * @param encoder
		 * @param defaultFileName - если saveToCloud=false, то имя файла по умолчанию для отображения в диалоге,
		 *                               saveToCloud=true, то идентификатор объекта к которому будет привязано изображение графа в БД
		 * @param saveToCloud
		 * 
		 */		
		public function SaveGraphAS( vg : IVisualGraph, encoder : IEncodeTask, defaultFileName : String, saveToCloud : Boolean = false )
		{
			super();
			
			this.vg = vg;
			this.encoder = encoder;
			this.encoderName = encoder.name;
			this.defaultFileName = defaultFileName;
			this.saveToCloud = saveToCloud;
		}
		
		override protected function next() : void
		{
			switch( _status )
			{
				case NONE : getBitmapData();
					break;
				
				case GETTING_BITMAP_DATA : startEncoding();
					break;
				
				case ENCODING : if ( saveToCloud ) //Сохраняем в облако
				                {
					             saveImageToCloud();
				                }
				                else //Сохраняем на компьютер
								{
									_status = WAITING_FOR_SAVING;
									view.currentState = 'readyToSave';
									
									if ( encoderName == 'JPEG' )
									{
										view.saveButton.setStyle( 'icon', Assets.JPEG_ICON );
									}
									else if ( encoderName == 'PNG' )
									{
										view.saveButton.setStyle( 'icon', Assets.PNG_ICON );
									}
									
									view.saveButton.addEventListener( MouseEvent.CLICK, onSaveButtonClick, false, 0, true );
								}	
					break;
				
				case WAITING_FOR_SAVING : saveData();
					break;
				
				case SAVING : hide( Alert.OK );
					break;
			}
			
			
			super.next();
		}
		
		private var bitmapData : BitmapData;
		
		private function getBitmapData()  : void
		{
			_status = GETTING_BITMAP_DATA;
			
			bitmapData = VisualGraphToBitmap.convert( vg );
			callLater( next );
		}
		
		private var encoder  : IEncodeTask;
		private var thread   : Thread;
		private var outData  : ByteArray;
		
		private function createEncoder() : void
		{
			//jpegTask = new JPEGEncodeTask( bitmapData, 100 );
			
			thread = new Thread( encoder );
			thread.addEventListener( Event.COMPLETE, onEncodingComplete );
			thread.addEventListener( ProgressEvent.PROGRESS, onEncodingProgress );
			thread.addEventListener( ErrorEvent.ERROR, onEncodingError );
			
			thread.start();
		}
		
		private function destroyEncoder() : void
		{
			encoder = null;
			
			thread.removeEventListener( Event.COMPLETE, onEncodingComplete );
			thread.removeEventListener( ProgressEvent.PROGRESS, onEncodingProgress );
			thread.removeEventListener( ErrorEvent.ERROR, onEncodingError );
			
			thread = null;
		}
		
		private function startEncoding() : void
		{
			_status = ENCODING;
			
			encoder.setInputData( bitmapData );
			createEncoder();
		}
		
		private var api : UnisAPIImplementation;
		
		private function onSavedToCloud( e : AMGEvent ) : void
		{
			api.removeAllObjectListeners( this );
			next();
		}
		
		private function onSavedToCloudError( e : AMFErrorEvent ) : void
		{
			setError( 'Ошибка сохранения...' );
			Alert.show( e.text, 'Ошибка' );
			api.removeAllObjectListeners( this );
		}
		
		private function saveImageToCloud() : void
		{
			_status = SAVING;
			updateIntermediateProgressBar( 'Сохраняю...' );
			view.currentState = 'saving';
			
			api = UnisAPI.impl;
			
			api.addListener( AMGEvent.IMAGE_SAVED, onSavedToCloud, this );
			api.addListener( AMFErrorEvent.ERROR, onSavedToCloudError, this );
			api.saveGraphAsImage( defaultFileName, outData );
		}
		
		private function onEncodingComplete( e : Event ) : void
		{
			outData = encoder.outData;
			
			destroyEncoder(); 
			
			next();
		}
		
		private function onEncodingProgress( e : ProgressEvent ) : void
		{
		  updateProgressBar( e.bytesLoaded, e.bytesTotal );
		}
		
		private function onEncodingError( e : ErrorEvent ) : void
		{
			destroyEncoder();
			_status = ERROR;
			setError( e.text );
			next();
		}
		
		private var saveTask : SaveTask;
		
		private function createSaveTask() : void
		{
			saveTask = new SaveTask( outData, defaultFileName );
			saveTask.addEventListener( Event.COMPLETE, onSaveComplete );
			saveTask.addEventListener( ProgressEvent.PROGRESS, onSaveProgress );
			saveTask.addEventListener( Event.CANCEL, onSaveCancel );
			saveTask.addEventListener( IOErrorEvent.IO_ERROR, onSaveIOError );
			saveTask.run();
		}
		
		private function destroySaveTask() : void
		{
			saveTask.removeEventListener( Event.COMPLETE, onSaveComplete );
			saveTask.removeEventListener( ProgressEvent.PROGRESS, onSaveProgress );
			saveTask.removeEventListener( Event.CANCEL, onSaveCancel );
			saveTask.removeEventListener( IOErrorEvent.IO_ERROR, onSaveIOError );
			saveTask = null;
		}
		
		private function onSaveIOError( e : IOErrorEvent ) : void
		{
			_status = ERROR;
			setError( e.text );
			next();
		}
		
		private function saveData() : void
		{
			_status = SAVING;
			updateIntermediateProgressBar( 'Сохраняю...' );
			view.currentState = 'saving';
			createSaveTask();
		}
		
		private function onSaveComplete( e : Event ) : void
		{
			destroySaveTask();
			next();
		}
		
		private function onSaveProgress( e : ProgressEvent ) : void
		{
			updateProgressBar( e.bytesTotal, e.bytesLoaded );
		}
		
		private function onSaveCancel( e : Event ) : void
		{
			destroySaveTask();
			next();
		}
		
		private function updateProgressBar( value : Number, total : Number ) : void
		{
			if ( view.progressBar.indeterminate )
			{
				view.progressBar.indeterminate = false;
				view.progressBar.mode = ProgressBarMode.MANUAL;
			}
			
			view.progressBar.setProgress( value, total );
			view.progressBar.label = Math.round( ( value / total ) * 100 ).toString() + '%';
		}
		
		private function updateIntermediateProgressBar( text : String ) : void
		{
			if ( ! view.progressBar.indeterminate )
			{
				view.progressBar.indeterminate = true;
				view.progressBar.mode = ProgressBarMode.EVENT;
			}
			
			view.progressBar.label = text;
		}
		
		private function setError( text : String ) : void
		{
			view.progressBar.setStyle( 'color', 0xff0000 );
			view.progressBar.label = text;
		}
		
		private function clear() : void
		{
			if ( bitmapData )
			{
				bitmapData.dispose();
				bitmapData = null;
			}
			
			if ( thread )
			{
				destroyEncoder();
			}
			
			if ( saveTask )
			{
				destroySaveTask();
			}
		}
		
		private var view : SaveGraphASView;
		
		/**
		 * Отображает диалог сохранения файла JPEG 
		 * 
		 */		
		public function show() : void
		{
			if ( ! view )
			{
				view = new SaveGraphASView();
				view.currentState = 'encoding';
				
				if ( saveToCloud )
				{
					view.setStyle( 'icon', Assets.LINK_IMAGE );
				}
				else
				{
					if ( encoderName == 'JPEG' )
					{
						view.setStyle( 'icon', Assets.JPEG_ICON_SMALL );
					}
					else
						if ( encoderName == 'PNG' )
						{
							view.setStyle( 'icon', Assets.PNG_ICON_SMALL );
						}
				}
				
				PopUpManager.addPopUp( view, null, true );
				PopUpManager.centerPopUp( view );
				
				view.closeButton.visible = false;
				
				view.cancelButton.addEventListener( MouseEvent.CLICK, onCancelClick, false, 0, true );
			}
		}
		
		private function hide( detail : int ) : void
		{
			clear();
			
			if ( view )
			{
				//view.saveButton.removeEventListener( MouseEvent.CLICK, onSaveButtonClick );
				PopUpManager.removePopUp( view );
				view = null;
			}
			
			if ( api )
			{
				api.removeAllObjectListeners( this );
				api = null;	
			}
			
			dispatchEvent( new CloseEvent( CloseEvent.CLOSE, false, false, detail ) );
		}
		
		private function onCancelClick( e : MouseEvent ) : void
		{
			hide( Alert.CANCEL );
		}
		
		private function onSaveButtonClick( e : MouseEvent ) : void
		{
			next();
		}
	}
}