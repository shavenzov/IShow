package org.un.cava.birdeye.ravis.components.renderers.nodes
{
    import com.bs.amg.UnisAPI;
    import com.bs.amg.features.IShowFeatures;
    import com.controls.CachedImage;
    import com.controls.Indicator;
    
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.geom.Rectangle;
    
    import mx.core.IDataRenderer;
    import mx.core.UIComponent;
    import mx.core.UIFTETextField;
    
    import org.un.cava.birdeye.ravis.components.renderers.RendererIconFactory;
    import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
    import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualNodeEvent;
	
	public class TextIconNodeRenderer extends UIComponent implements INodeRenderer, IDataRenderer
	{
		/**
		 * Максимальная длина текста 
		 */		
		private static const MAX_LABEL_WIDTH  : Number = 128.0;
		/**
		 * Максимальная высота текста 
		 */		
		private static const MAX_LABEL_HEIGHT : Number = 68.0;
		/**
		 * Максимальный размер иконки 
		 */		
		public static const MAX_ICON_SIZE    : Number = 48.0;
		
		/**
		 * Размер индикатора загрузки 
		 */		
		private static const INDICATOR_SIZE   : Number = 16.0;
		
		private var _label : UIFTETextField;
		private var _icon  : UIComponent;
		private var _indicator : Indicator;
		private var _rootIndicator : RootIndicator;
		private var _expandButton : ExpandButton;
		private var _openCardButton : OpenCardButton;
		
		/**
		 * Указывает, что с этим узлом в настоящий момент связан какой-то процесс 
		 */		
		private var _progress : Boolean;
		
		private var _data        : Object;
		private var _dataChanged : Boolean;
		
		private var _text       : String;
		private var _tipText    : String;
		private var _textWidth  : Number;
		private var _textHeight : Number;
		
		private var _features : IShowFeatures;
		
		private var _selected : Boolean;
		private var _hovered  : Boolean;
		
		/**
		 * Горизонтальное расстояние между иконкой и текстом 
		 */		
		private static const _vgap : Number = 4.0;
		
		public function TextIconNodeRenderer()
		{
			super();
			
			_features = UnisAPI.impl.features;
			
			addEventListener( MouseEvent.ROLL_OVER, onRollOver );
			addEventListener( MouseEvent.ROLL_OUT, onRollOut );
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown, false, 5 );
		}
		
		public function get selected()  : Boolean
		{
			return _selected;
		}
		
		public function set selected( value : Boolean ) : void
		{
			if ( _selected != value )
			{
				_selected = value;
				invalidateDisplayList();
			}
		}
		
		public function get hovered() : Boolean
		{
			return _hovered;
		}
		
		public function set hovered( value : Boolean ) : void
		{
			if ( _hovered != value )
			{
				_hovered = value;
				invalidateDisplayList();
			}
		}
		
		/**
		 * Определяет раскрыт ли этот объект 
		 * @return 
		 * 
		 */		
		private function get expanded() : Boolean
		{
			return _data.data.hasOwnProperty( 'expanded' ) && _data.data.expanded;
		}
		
		private function onRollOver( e : MouseEvent ) : void
		{
			showExpandButton();
		}
		
		private function onRollOut( e : MouseEvent ) : void
		{
			hideExpandButton();
		}
		
		private function onMouseDown( e : MouseEvent ) : void
		{
			if ( _expandButton || _openCardButton )
			{
				if ( ( e.target == _expandButton ) || ( e.target == _openCardButton ) )
				{
					e.stopImmediatePropagation();
				}
			}
		}
		
		private function showExpandButton() : void
		{
			if ( ! expanded && ! _progress && ! _expandButton )
			{
				if ( _features.isAllow( IShowFeatures.EXPAND ) )
				{
					_expandButton = new ExpandButton();
					_expandButton.addEventListener( MouseEvent.CLICK, onExpandButtonClick );
					
					addChild( _expandButton );
					
					invalidateDisplayList();
				}
			}
			
			if ( ! _openCardButton )
			{
				if ( _features.isAllow( IShowFeatures.SHOW_INFO ) )
				{
					_openCardButton = new OpenCardButton();
					_openCardButton.addEventListener( MouseEvent.CLICK, onOpenCardButtonClick );
					
					addChild( _openCardButton );
					
					invalidateDisplayList();
				}
			}
		}
		
		private function hideExpandButton() : void
		{
			if ( _expandButton )
			{
				_expandButton.removeEventListener( MouseEvent.CLICK, onExpandButtonClick );
				removeChild( _expandButton );
				_expandButton = null;
			}
			
			if ( _openCardButton )
			{
				_openCardButton.removeEventListener( MouseEvent.CLICK, onOpenCardButtonClick );
				removeChild( _openCardButton );
				_openCardButton = null;
			}
		}
		
		private function onExpandButtonClick( e : MouseEvent ) : void
		{
			dispatchEvent( new VisualNodeEvent( VisualNodeEvent.EXPAND_CLICK, e, IVisualNode( _data ) ) );
		}
		
		private function onOpenCardButtonClick( e : MouseEvent ) : void
		{
			dispatchEvent( new VisualNodeEvent( VisualNodeEvent.OPEN_CARD_CLICK, e, IVisualNode( _data ) ) );
		}
		
		public function get data() : Object
		{
			return _data;
		}
		
		public function set data( value : Object ) : void
		{
			_data = value;
			_dataChanged = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function refresh() : void
		{
			_dataChanged = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function getVisualBounds( targetCoordinateSpace : DisplayObject ) : Rectangle
		{
			if ( _icon )
			{
				var bb : Rectangle = _icon.getBounds( targetCoordinateSpace );
				
				return new Rectangle( bb.x, bb.y, _icon.getExplicitOrMeasuredWidth(), _icon.getExplicitOrMeasuredHeight() );
			}
			
			return _label.getBounds( targetCoordinateSpace );
		}
		
		public function get visualWidth() : Number
		{
			if ( _icon )
			{
				return _icon.width;
			}
			
			return _label.width;
		}
		
		public function get visualHeight() : Number
		{
			if ( _icon )
			{
				return _icon.height;
			}
			
			return _label.height;
		}
		
		public function get progress() : Boolean
		{
			return _progress;
		}
		
		public function set progress( value : Boolean ) : void
		{
			if ( _progress != value )
			{
				_progress = value;
				hideExpandButton();
				invalidateProperties();
				invalidateDisplayList();
			}
		}
		
		public function get iconResized() : Boolean
		{
			if ( _icon )
			{
				var cachedImage : CachedImage = _icon as CachedImage;
				    
				if ( cachedImage )
				{
					return cachedImage.resized;
				}
			}
			
			return false;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			_label = UIFTETextField( createInFontContext( UIFTETextField ) );
			_label.mouseEnabled = false;
			_label.wordWrap = true;
			_label.textColor = 0xffffff;
			
			//_label.autoSize = TextFieldAutoSize.LEFT;
			
			addChild( _label );
		}
		
		override protected function measure() : void
		{
			super.measure();
			
			if ( _label.textWidth > MAX_LABEL_WIDTH )
			{
				_textWidth  = MAX_LABEL_WIDTH;
				_textHeight = MAX_LABEL_HEIGHT; 
			}
			else
			{
				if ( _label.textHeight > MAX_LABEL_HEIGHT )
				{
					_textWidth  = MAX_LABEL_WIDTH;
					_textHeight = MAX_LABEL_HEIGHT;
				}
				else
				{
					_textWidth  = _label.measuredWidth;
					_textHeight = _label.measuredHeight;
				}
			}
			
			if ( _icon )
			{
				measuredWidth  = Math.max( _icon.measuredWidth, _textWidth ); 
				measuredHeight = _icon.measuredHeight + _textHeight;
				
				return;
			}
			
			measuredWidth  = _textWidth;
			measuredHeight = _textHeight;
		}
		
		private function clearIcon() : void
		{
			if ( _icon )
			{
				removeChild( _icon );
				_icon = null;
			}
		}
		
		private function clearRootIndicator() : void
		{
		  if ( _rootIndicator )
		  {
			  removeChild( _rootIndicator );
			  _rootIndicator = null; 
		  }
		}
		
		private function createRootIndicator() : void
		{
			if ( ! _rootIndicator )
			{
				_rootIndicator = new RootIndicator();
				addChild( _rootIndicator );
			}
		}
		
		override protected function commitProperties() : void
		{
			super.commitProperties();
			
			if ( _dataChanged )
			{
				if ( _data && _data.data )
				{
					//Текст надписи
					if ( _data.data.name )
					{
						setText( _data.data.name );
					}
					else
					{
						setText( null );
					}
					
					//Описание
					if ( _data.data.desc )
					{
						setTipText( _data.data.desc );
					}
					else
					{
						setTipText( null );
					}
					
					//Иконка
					if ( _data.data.icon )
					{
						clearIcon();
						_icon = RendererIconFactory.createIcon( _data.data.icon, MAX_ICON_SIZE );
						
						var cImage : CachedImage = _icon as CachedImage;
						
						if ( cImage && ! cImage.loaded )
						{
						  setIconListeners();	
						}
						
						addChildAt( _icon, 0 );
						setStyle( 'toolTipTarget', _icon );
					}
					
					//Если это корневой элемент, создаем соответствующий индикатор
					if ( _data.data.hasOwnProperty( 'root' ) && _data.data.root )
					{
						createRootIndicator();
					}
					else
					{
						clearRootIndicator();
					}
				}
				else
				{
					setText( null );
					setTipText( null );
					clearIcon();
					clearRootIndicator();
				}
				
				_dataChanged = false;
			}
			
			if ( _progress && _indicator == null ) //отобразить индикатор
			{
				_indicator        = new Indicator();
				_indicator.width  = INDICATOR_SIZE;
				_indicator.height = INDICATOR_SIZE;
				_indicator.filters = [ new GlowFilter( 0x000000 ) ];
				
				addChild( _indicator );
			}
			else if ( ! _progress && _indicator != null ) //скрыть индикатор
			{
				removeChild( _indicator );
				_indicator = null;
			}
		}
		
		private function setIconListeners() : void
		{
			_icon.addEventListener( Event.COMPLETE, onImageLoaded );
			_icon.addEventListener( Event.REMOVED_FROM_STAGE, onImageRemoved );	
		}
		
		private function unsetIconListeners() : void
		{
			_icon.removeEventListener( Event.COMPLETE, onImageLoaded );
			_icon.removeEventListener( Event.REMOVED_FROM_STAGE, onImageRemoved );
		}
		
		private function onImageLoaded( e : Event ) : void
		{
			unsetIconListeners();
			
			_icon.validateNow();
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			validateNow();
			
			//Перерисовываем связи
			if ( _data is IVisualNode )
			{
				IVisualNode( _data ).refresh();
			}
		}
		
		private function onImageRemoved( e : Event ) : void
		{
			unsetIconListeners();
		}
		
		/**
		 * Фильтр применяемый к узлу при его выделении
		 */		
		private static const nodeSelectionFilter : GlowFilter = new GlowFilter( 0x0000FF, 1.0, 6.0, 6.0, 2 );
		
		/**
		 * Фильтр применяемый к узлу при наведении на него 
		 */		
		private static const nodeRollOverFilter  : GlowFilter = new GlowFilter( 0x0000FF, 0.5, 6.0, 6.0, 3 );
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			/*if ( _label.textWidth > MAX_LABEL_WIDTH )
			{
				_label.setActualSize( MAX_LABEL_WIDTH, MAX_LABEL_HEIGHT );
			}
			else
			{
				if ( _label.textHeight > MAX_LABEL_HEIGHT )
				{
					_label.setActualSize( _label.measuredWidth, MAX_LABEL_HEIGHT );
				}
				else
				{
					_label.setActualSize( _label.measuredWidth, _label.measuredHeight );
				}
			}*/
			
			_label.setActualSize( _textWidth, _textHeight );
			
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
			
			if ( _icon )
			{
				_icon.setActualSize( _icon.getExplicitOrMeasuredWidth(), _icon.getExplicitOrMeasuredHeight() );
				
				if ( _icon.width > _label.width )
				{
					_icon.move( 0.0, 0.0 );
					_label.move( ( _icon.width - _label.width ) / 2.0, _icon.width + _vgap );
				}
				else
				{
					_icon.move( ( _label.width - _icon.width ) / 2.0, 0.0 );
					_label.move( 0.0, _icon.width + _vgap );
				}
			}
			else
			{
				_label.move( 0.0, 0.0 );
			}
			
			if ( _indicator )
			{
				_indicator.x = _icon.x;
				_indicator.y = 0;
			}
			
			if ( _rootIndicator )
			{
				_rootIndicator.x = _icon.x + _icon.width;
				_rootIndicator.y = _icon.y;
			}
			
			if ( _expandButton )
			{
				_expandButton.x = _icon.x - _expandButton.width / 2.0;
				_expandButton.y = _icon.y - _expandButton.height / 2.0;
			}
			
			if ( _openCardButton )
			{
				_openCardButton.x = _icon.x + _icon.width - _openCardButton.width / 2.0;
				_openCardButton.y = _icon.y - _openCardButton.height / 2.0;
			}
			
			//Прозрачная заливка, для более точного попадания мышью
			graphics.clear();
			graphics.beginFill( 0x00ff00, 0.0 );
			graphics.drawRect( 0.0, 0.0, unscaledWidth, unscaledHeight );
			graphics.endFill();
			
			/*
			graphics.clear();
			
			graphics.beginFill( 0x0000ff, 0.5 );
			graphics.drawRect( 0, 0, unscaledWidth, unscaledHeight );
			graphics.endFill();
			
			
			graphics.beginFill( 0xff0000, 0.25 );
			graphics.drawCircle( unscaledWidth / 2, unscaledHeight / 2, 10 );
			graphics.endFill();
			*/
			
			var bgAlpha : Number;
			
			graphics.clear();
			
			if ( _selected )
			{
				bgAlpha = 0.65;
				_label.textColor = 0xFFFFFF;
				
				if ( _icon )
				_icon.filters = [ nodeSelectionFilter ];
			}
			else if ( _hovered )
			{
				bgAlpha = 0.45;
				_label.textColor = 0xFFFFFF;
				
				if ( _icon )
				_icon.filters = [ nodeRollOverFilter ];
			}
			else
			{
				_label.textColor = 0x000000;
				
				if ( _icon )
				_icon.filters    = null;
			}
			
			
			graphics.beginFill( 0x000000, 0.0 );
			graphics.drawRect( -4.0, -4.0, unscaledWidth + 8.0, unscaledHeight + 8.0 );
			graphics.endFill();
			
			if ( _selected || _hovered )
			{
				graphics.beginFill( 0x0000FF, bgAlpha );
				graphics.drawRoundRect( _label.x - 4.0, _label.y, _label.width + 6.0, _label.height + 2.0, 16.0, 16.0 );
				graphics.endFill();
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
			
			_label.invalidateSize();
			_label.validateNow();
		}
		
		private function setTipText( value : String ) : void
		{
			_tipText = value;
			toolTip  = value;
		}
		
		private function get textTruncated() : Boolean
		{
			return _label.height >= MAX_LABEL_HEIGHT;
		}
	}
}