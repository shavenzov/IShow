import flash.events.Event;

import mx.events.SliderEvent;

import org.un.cava.birdeye.ravis.assets.icons.EmbeddedIcons;

[Bindable]
public var minimum : Number = 0.0;

[Bindable]
public var maximum : Number = 10.0;

[Bindable]
public var value   : Number = 0.0;

[Bindable]
public var liveDragging : Boolean = false;

[Bindable]
public var tickInterval : Number = 0.0;

[Bindable]
public var tickValues : Array = [];

[Bindable]
public var snapInterval : Number = 0.0;

[Bindable]
public var label : String;

[Bindable]
public var labels : Array = [];

public var dataTipFormatFunction : Function;

private function onSliderChange( e : SliderEvent ) : void
{
	if ( initialized )
	{
		value = e.value;
		updateLabel();
		dispatchEvent( e );
	}
}

private function onButtonUp() : void
{
	if ( ! liveDragging )
	{
		dispatchEvent( new SliderEvent( SliderEvent.CHANGE, false, false, 0, value ) );
	}
}

private function onButtonIncDown() : void
{
	var newValue : Number = value + ( snapInterval == 0 ? 1 : snapInterval );
	    
	newValue = Math.min( newValue, maximum );
	
	if ( value != newValue )
	{
		value = newValue;
		updateLabel();
		
		if ( liveDragging )
		{
			dispatchEvent( new SliderEvent( SliderEvent.CHANGE, false, false, 0, value ) );	
		}
	}
}

private function onButtonDecDown() : void
{
	var newValue : Number = value - ( snapInterval == 0 ? 1 : snapInterval );
	    
	newValue = Math.max( newValue, minimum );
	
	if ( value != newValue )
	{
		value = newValue;
		updateLabel();
		
		if ( liveDragging )
		{
			dispatchEvent( new SliderEvent( SliderEvent.CHANGE, false, false, 0, value ) );	
		}
	}
}	

override protected function commitProperties() : void
{
	super.commitProperties();
	updateLabel();
}

private function _dataTipFormatFunction( value : Number ) : String
{
	if ( dataTipFormatFunction == null )
	{
		
		return Math.round( value ).toString();
	}
	
	return dataTipFormatFunction( value );
}

private function updateLabel() : void
{
	valueLabel.text = ' : ' + _dataTipFormatFunction( value );
}
	