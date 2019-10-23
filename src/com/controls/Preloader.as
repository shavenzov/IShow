package com.controls
{
	import com.controls.ProgressIndicator;
	
	import flash.filters.GlowFilter;
	
	import mx.core.UIComponent;
	
	public class Preloader extends UIComponent
	{
		private var _percent  : int = 0;
		private var indicator : ProgressIndicator;
		
		public function Preloader()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			indicator = new ProgressIndicator();
			addChild( indicator );
			
			filters = [ new GlowFilter( 0x000000 ) ];
		}
		
		/**
		 * Процент отображения индикации 
		 * @return 
		 * 
		 */		
		public function get percent() : int
		{
			return _percent;
		}
		
		public function set percent( value : int ) : void
		{
			_percent = value;
			invalidateProperties();
		}
		
		public function setProgress( value : int, total : int ) : void
		{
			percent = Math.round( value * 100 / total );
		}	
		
		override protected function commitProperties() : void
		{
			indicator.progress.gotoAndStop( _percent );
		}
		
		override protected function measure() : void
		{
			measuredWidth = 17.5;
			measuredHeight = 17.5;
		}	
	}
}