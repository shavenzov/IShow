import flash.events.Event;

import mx.events.SliderEvent;

import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;

private var _vg : IVisualGraph;

public function get vg() : IVisualGraph
{
	return _vg;
}

public function set vg( value : IVisualGraph ) : void
{
	if ( value != _vg )
	{
		if ( _vg )
		{
			_vg.removeEventListener( VisualGraphEvent.SCALED, onVGScaled );
		}
		
		_vg = value;
		
		_vg.addEventListener( VisualGraphEvent.SCALED, onVGScaled );
	}
}

private function onVGScaled( e : Event = null ) : void
{
	scaleSlider.value = _vg.scale;
}

private function onCreationComplete() : void
{
	if ( _vg )
	{
		navigator.vg = _vg;
		onVGScaled();
	}
	
	closeButton.toolTip = 'Закрыть';
}

private function dataTipFormatFunction( value : Number ) : String
{
	var scaleInPercents : Number = Math.round( value * 100.0 );
	return scaleInPercents.toString() + '%';
}

private function onScaleChanged( e : SliderEvent ) : void
{
	_vg.scale = e.value;
}