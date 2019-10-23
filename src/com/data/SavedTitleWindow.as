package com.data
{
	import com.data.BaseSavedTitleWindow;
	
	import spark.events.TitleWindowBoundsEvent;
	
	public class SavedTitleWindow extends BaseSavedTitleWindow
	{
		public function SavedTitleWindow()
		{
			super();
			
			addEventListener( TitleWindowBoundsEvent.WINDOW_MOVE_END, onWindowMoveEnd );
		}
		
		private function onWindowMoveEnd( e : TitleWindowBoundsEvent ) : void
		{
			save();
		}
		
		override protected function load():void
		{
			super.load();
			
			x = _data.x;
			y = _data.y;
		}
		
		override protected function save():void
		{
			_data.x = x;
			_data.y = y;
			
			super.save();
			
			defaultPos = false;
		}
		
		/**
		 * Указывает что значение положение окна не было до этого сохранено 
		 */		
		public var defaultPos : Boolean;
		
		override protected function createChildren():void
		{
			if ( ! defaultPos )
			{
				initialPos = null;
			}
			
			super.createChildren();
		}
		
		override protected function setDefaults():void
		{
			super.setDefaults();
			
			if ( ! _data.hasOwnProperty( 'x' ) )
			{
				_data.x = x;
				defaultPos = true;
			}
			
			if ( ! _data.hasOwnProperty( 'y' ) )
			{
				_data.y = y;
				defaultPos = true;
			}
		}
	}
}