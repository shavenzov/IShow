package
{
	import com.bs.amg.UnisAPI;
	
	import flash.events.Event;
	
	import mx.preloaders.SparkDownloadProgressBar;
	
	public class MainPreloader extends SparkDownloadProgressBar
	{
		public function MainPreloader()
		{
			super();
			
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}
		
		private function onAddedToStage( e : Event ) : void
		{
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			
			//UnisAPI.impl.initFromFlashVars( stage );
			UnisAPI.impl.initFromURL();
		}
        
		/*
		override protected function initCompleteHandler( event : Event ) : void
		{
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		*/
		
	}
}