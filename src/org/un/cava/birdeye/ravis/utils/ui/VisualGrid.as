package org.un.cava.birdeye.ravis.utils.ui
{
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	
	import mx.core.UIComponent;
	
	import spark.core.IViewport;
	
	public class VisualGrid
	{
		/**
		 * Цвет сетки 
		 */		
		private static const GRID_COLOR : uint = 0x000000;
		/**
		 * Прозрачность сетки 
		 */
		private static const GRID_ALPHA : Number = 0.1;
		
		/**
		 * Шаг по оси X 
		 */		
		private var _stepX : Number = 16;
		/**
		 * Шаг по оси Y 
		 */		
		private var _stepY : Number = 16;
		/**
		 * Отображать сетку или нет 
		 */		
		private var _show  : Boolean;
		
		/**
		 * Привязывать к сетке или нет 
		 */		
		private var _snap : Boolean;
		
		/**
		 * Клиент для которого будет включена поддержка сетки 
		 */		
		private var _client : IViewport;
		private var _ui     : UIComponent;
		
		/**
		 * Текущий масштаб отображения 
		 */		
		private var _scale : Number = 1.0;
		
		public function VisualGrid( client : IViewport )
		{
			super();
			_client = client;
			_ui     = UIComponent( client );
		}
		
		private function invalidateClient() : void
		{
			_ui.invalidateDisplayList();
		}
		
		public function get step() : Number
		{
			return _stepX;
		}
		
		public function set step( value : Number ) : void
		{
			if ( value != _stepX )
			{
				_stepX = _stepY = value;
				invalidateClient();
			}
		}
		
		public function get scale() : Number
		{
			return _scale;
		}
		
		public function set scale( value : Number ) : void
		{
			if ( _scale != value )
			{
				_scale = value;
				invalidateClient();
			}
		}
		
		public function get show() : Boolean
		{
			return _show;
		}
		
		public function set show( value : Boolean ) : void
		{
			if ( _show != value )
			{
				_show = value;
				invalidateClient();
			}
		}
		
		public function get snap() : Boolean
		{
			return _snap;
		}
		
		public function set snap( value : Boolean ) : void
		{
			_snap = value;
		}
		
		/**
		 * Данные для отрисовки 
		 */		
		private var _data     : Vector.<Number> = new Vector.<Number>();
		
		/**
		 * Команды для отрисовки
		 */		
		private var _commands : Vector.<int>    = new Vector.<int>();
		
		/**
		 * Index for drawing commands 
		 */
		private var _ci : int;
		
		/**
		 * Index for data commands 
		 */
		private var _di : int;
		
		public function draw() : void
		{
			if ( _show )
			{
				var scaledStepX : Number = _stepX * _scale;
				var scaledStepY : Number = _stepY * _scale;
				var fromX : Number = Math.floor( _client.horizontalScrollPosition / scaledStepX ) * scaledStepX;
				var fromY : Number = Math.floor( _client.verticalScrollPosition / scaledStepY ) * scaledStepY; 
				var toX   : Number = Math.ceil( ( _client.horizontalScrollPosition + _client.width ) / scaledStepX ) * scaledStepX;
				var toY   : Number = Math.ceil( ( _client.verticalScrollPosition + _client.height ) / scaledStepY ) * scaledStepY;
				
				_ci = 0;
				_di = 0;
				
				var pos : Number = fromX;
				
				//Рисуем полоски по оси x
				while( pos < toX )
				{
					_commands[ _ci ++ ] = GraphicsPathCommand.MOVE_TO;
					_data[ _di ++ ]     = pos;
					_data[ _di ++ ]     = fromY;
					
					_commands[ _ci ++ ] = GraphicsPathCommand.LINE_TO;
					_data[ _di ++ ]     = pos;
					_data[ _di ++ ]     = toY;
					
					pos += scaledStepX;
				}
				
				pos = fromY;
				
				//Рисуем полоски по оси y
				while( pos < toY )
				{
					_commands[ _ci ++ ] = GraphicsPathCommand.MOVE_TO;
					_data[ _di ++ ]     = fromX;
					_data[ _di ++ ]     = pos;
					
					_commands[ _ci ++ ] = GraphicsPathCommand.LINE_TO;
					_data[ _di ++ ]     = toX;
					_data[ _di ++ ]     = pos;
					
					pos += scaledStepY;
				}
				
				if ( _ci < _commands.length )
				{
					_commands.splice( _ci, _commands.length - _ci );
					_data.splice( _di, _data.length - _di );
				}
				
				var g : Graphics = UIComponent( _client ).graphics;
				
				//Отрисовываем
				g.lineStyle( 1.0, GRID_COLOR, GRID_ALPHA );
				g.drawPath( _commands, _data );
			}
		}
		
		public function snapX( value : Number ) : Number
		{
			return _snap ? Math.floor( value / _stepX ) * _stepX : value;
		}
		
		public function snapY( value : Number ) : Number
		{
			return _snap ? Math.floor( value / _stepY ) * _stepY : value;
		}
	}
}