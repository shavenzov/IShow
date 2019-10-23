import flash.events.ProgressEvent;

import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;

private var _vg : IVisualGraph;

public function get vg() : IVisualGraph
{
	return _vg;
}

public function set vg( value : IVisualGraph ) : void
{
	if ( _vg )
	{
		_vg.removeEventListener( VisualGraphEvent.START_ASYNCHROUNOUS_LAYOUT_CALCULATION, onStartCalculation );
		_vg.removeEventListener( VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION, onEndCalculation );
		_vg.removeEventListener( ProgressEvent.PROGRESS, onProgress );
	}
		
	_vg = value;
	
	_vg.addEventListener( VisualGraphEvent.START_ASYNCHROUNOUS_LAYOUT_CALCULATION, onStartCalculation );
	_vg.addEventListener( VisualGraphEvent.END_ASYNCHROUNOUS_LAYOUT_CALCULATION, onEndCalculation );
	_vg.addEventListener( ProgressEvent.PROGRESS, onProgress );
}

private function onStartCalculation( e : VisualGraphEvent ) : void
{
	visible = includeInLayout = true;
	updateProgressBar( 0, 100 );
}

private function onEndCalculation( e : VisualGraphEvent ) : void
{
    visible = includeInLayout = false;	
}

private function onProgress( e : ProgressEvent ) : void
{
	updateProgressBar( e.bytesLoaded, e.bytesTotal );
}

private function updateProgressBar( _progress : Number, _total : Number ) : void
{
	var percent : Number = Math.round( ( _progress / _total ) * 100.0 );
	
	progress.setProgress( _progress, _total );
	progress.label = 'Расчет раскладки - ' + percent + '%';
}

private function onInit() : void
{
	onEndCalculation( null );
}

private function onCreationComplete() : void
{
	updateProgressBar( 0.0, 100.0 );
}