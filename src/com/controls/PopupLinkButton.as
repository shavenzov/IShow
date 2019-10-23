package com.controls
{
	import mx.controls.LinkButton;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	public class PopupLinkButton extends LinkButton
	{
		private static const GAP : Number = 2.0;
		
		/**
		 * Время анимации в секундах 
		 */		
		private static const ANIMATION_TIME : Number = 0.25;
		
		/**
		 * Треугольник отрисован так чтобы его центр был в центре треугольника (Для поворота) 
		 */		
		private var triangle : BlackTriangle;
		
		/**
		 * Отображается ли в данный момент всплывающее меню 
		 */		
		//private var _opened : Boolean;
		
		//private var t : ITween;
		
		public function PopupLinkButton()
		{
			super();
			
			buttonMode    = false;
		}
		/*
		public function get opened() : Boolean
		{
			return _opened;
		}
		
		public function set opened( value : Boolean ) : void
		{
			if ( _opened != value )
			{
				_opened = value;
				animate();
			}
		}
		
		override protected function clickHandler( event : MouseEvent ) : void
		{
			super.clickHandler( event );
			
			if ( ! _opened )
			{
				_opened = ! _opened;
				animate();
			}
		}
		
		private function animate() : void
		{
			if ( t )
			{
				if ( t.isPlaying )
				{
					t.stop();
					t = null;
				}
			}
			
			var from : Number = triangle.rotation;
			var to   : Number = _opened ? 0.0 : 90.0; 
			
			t = BetweenAS3.tween( triangle, { rotation : to }, { rotation : from }, ANIMATION_TIME );
			t.play();
		}
		*/
		override protected function createChildren() : void
		{
			super.createChildren();
			
			triangle = new BlackTriangle( getStyle( 'color' ) );
			
			addChild( triangle );
			
			setStyle( 'paddingLeft', 0.0 );
			setStyle( 'paddingRight', 4.0 );
			setStyle( 'paddingTop', 0.0 );
			setStyle( 'paddingBottom', 0.0 );
		}
		
		override protected function measure() : void
		{
			super.measure();
			
			measuredWidth += GAP + triangle.measuredWidth + getStyle("paddingRight");
		}
		
		override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			setChildIndex( triangle, numChildren - 1 );
			
			var w : Number = textField.width + triangle.measuredWidth + GAP;
			
			textField.x = ( unscaledWidth - w ) / 2.0;
			
			triangle.setActualSize( triangle.measuredWidth, triangle.measuredHeight );
			triangle.move( textField.x + textField.width + GAP + triangle.width / 2.0,
				           unscaledHeight / 2.0  + 1.0
						   );
			
			
		}
		
	}
}