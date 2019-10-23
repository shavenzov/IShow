package org.un.cava.birdeye.ravis.components.renderers.edgeLabels
{
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	import mx.core.UIFTETextField;
	
	public class TextEdgeLabelRenderer extends UIComponent implements IDataRenderer, IEdgeLabelRenderer
	{
		private var _label : UIFTETextField;
		
		private var _data        : Object;
		private var _dataChanged : Boolean;
		
		private var _text    : String;
		private var _tipText : String;
		
		public function TextEdgeLabelRenderer()
		{
			super();
		}
		
		public function refresh() :void
		{
			_dataChanged = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function get data() : Object
		{
			return _data;
		}
		
		public function set data( value : Object ) : void
		{
			_data = value;
			_dataChanged = true;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			_label = UIFTETextField( createInFontContext( UIFTETextField ) );
			_label.mouseEnabled = false;
			
			addChild( _label );
		}
		
		override protected function measure() : void
		{
			super.measure();
			
			//trace( _label.textWidth, _label.textHeight, maxWidth );
			
			measuredWidth  = _label.measuredWidth/* + 6*/;
			measuredHeight = _label.measuredHeight;
		}
		
		override protected function commitProperties() : void
		{
			super.commitProperties();
			
			if ( _dataChanged )
			{
				if ( _data && _data.data )
				{
					if ( _data.data.label )
					{
						setText( _data.data.label );
					}
					else
					{
						setText( null );
					}
					
					if ( _data.data.desc )
					{
						setTipText( _data.data.desc );
					}
					else
					{
						setTipText( null );
					}
				}
				else
				{
					setText( null );
					setTipText( null );
				}
				
				_dataChanged = false;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			/*graphics.clear();
			graphics.beginFill( 0x00ff00, 0.25 );
			graphics.drawRect( 0, 0, unscaledWidth, unscaledHeight );
			graphics.endFill();*/
			
			_label.setActualSize( unscaledWidth, unscaledHeight );
			
			
			//Если весь текст не помещается в _label, то
			//включаем отображение всплывающей подсказки
			if ( textTruncated )
			{
				if ( _tipText == null )
				{
					if ( toolTip != _text )
					{
						toolTip = _text;
					}
				}
			}
			else //Если текст, уже помещается, то отключаем отображение подсказки
			{
				if ( _tipText == null )
				{
					if ( toolTip != null )
					{
						toolTip = null;
					}
				}
			}
		}
		
		private function setText( value : String ) : void
		{
			_label.width = NaN;
			_label.height = NaN;
			_label.explicitWidth = NaN;
			_label.explicitHeight = NaN;
			
			_text       = value;
			_label.text = value;
		}
		
		private function setTipText( value : String ) : void
		{
			_tipText = value;
			toolTip  = value;
		}
		
		private function get textTruncated() : Boolean
		{
			return _label.textWidth > measuredWidth;
		}
	}
}