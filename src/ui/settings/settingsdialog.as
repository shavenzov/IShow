import com.bs.amg.UnisVisualGraphMediator;
import com.managers.HintManager;
import com.managers.HintShell;
import com.managers.events.HintEvent;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.events.CloseEvent;
import mx.managers.history.History;

import org.un.cava.birdeye.ravis.assets.Assets;
import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
import org.un.cava.birdeye.ravis.history.LayoutParamsChanged;
import org.un.cava.birdeye.ravis.history.SimpleDataParamChanged;
import org.un.cava.birdeye.ravis.history.SimpleLayotParamChanged;
import org.un.cava.birdeye.ravis.history.VisualGraphParamsChanged;

import ui.settings.SelectDepth;

private var _vg : IVisualGraph;

public function get vg() : IVisualGraph
{
	return _vg;
}

public function set vg( value : IVisualGraph ) : void
{
	if ( _vg != value )
	{
		if ( _vg != null )
		{
			_vg.removeEventListener( VisualGraphEvent.LAYOUT_PARAM_CHANGED, onLayoutParamsChanged );
			_vg.removeEventListener( VisualGraphEvent.LAYOUT_DATA_CHANGED, onLayoutParamsChanged );
			_vg.removeEventListener( VisualGraphEvent.VISUAL_GRAPH_DATA_CHANGED, onVisualGraphParamsChanged );
		}
		
		_vg = value;
		
		_vg.addEventListener( VisualGraphEvent.LAYOUT_PARAM_CHANGED, onLayoutParamsChanged );
		_vg.addEventListener( VisualGraphEvent.LAYOUT_DATA_CHANGED, onLayoutParamsChanged );
		_vg.addEventListener( VisualGraphEvent.VISUAL_GRAPH_DATA_CHANGED, onVisualGraphParamsChanged );
	}
}

private function onLayoutParamsChanged( e : VisualGraphEvent ) : void
{
	updateLayouterParams()
}

private function onCreationComplete() : void
{
	updateLayouterParams();
	updateVisualGraphParams();
	updateVGMediatorParams();
}

private var _vgMediator : UnisVisualGraphMediator;

public function get vgMediator() : UnisVisualGraphMediator
{
	return _vgMediator;
}

public function set vgMediator( value : UnisVisualGraphMediator ) : void
{
	if ( value != _vgMediator )
	{
		if ( _vgMediator != null )
		{
			_vgMediator.removeEventListener( Event.CHANGE, onVGMediatorDataChanged );	
		}
		
		_vgMediator = value;
		
		_vgMediator.addEventListener( Event.CHANGE, onVGMediatorDataChanged );
	}
}

private function onVGMediatorDataChanged( e : Event ) : void
{
	updateVGMediatorParams();
}

private function onVisualGraphParamsChanged( e : VisualGraphEvent ) : void
{
	updateVisualGraphParams();
}

private function updateLayouterParams() : void
{
	var l : ILayoutAlgorithm = _vg.layouter;
	
	if ( l.autoFitEnabled )
	{
		linkLengthButton.label = 'авто';
	}
	else
	{
		linkLengthButton.label    = l.linkLength.toString();
	}
	
	autoFitEnabledButton.selected = l.autoFitEnabled && ! l.fitToWindow;
	fitToWindowButton.selected    = l.autoFitEnabled &&   l.fitToWindow;
	animateButton.selected        = ! l.disableAnimation;
}

private function updateVisualGraphParams() : void
{
	showEdgeLabelsButton.selected = _vg.displayEdgeLabels;
}

private function updateVGMediatorParams() : void
{
	refreshOnRedrawButton.selected = ! _vgMediator.useSubExpandLayouter;
	depthButton.label              =   _vgMediator.depth.toString();
}

private function autoFitEnabledButtonClick() : void
{
	if ( ! autoFitEnabledButton.selected )
	{
		//Поддержка History
		History.add( new LayoutParamsChanged( _vg ) );
		
		_vg.layouter.fitToWindow    = false;
		_vg.layouter.autoFitEnabled = true;
		_vg.draw();
	}
}

private function fitToWindowButtonClick() : void
{
	if ( ! fitToWindowButton.selected )
	{
		//Поддержка History
		History.add( new LayoutParamsChanged( _vg ) );
		
		_vg.layouter.fitToWindow    = true;
		_vg.layouter.autoFitEnabled = true;
		_vg.draw();	
	}
}

private function refreshOnRedrawButtonClick() : void
{
	var operation : SimpleDataParamChanged = new SimpleDataParamChanged( _vgMediator );
	    operation.dumpBefore();
	
	    _vgMediator.useSubExpandLayouter = refreshOnRedrawButton.selected;
		
		operation.dumpAfter();
		History.add( operation );
		
	updateVGMediatorParams();
}

private function animateButtonClick() : void
{
	var operation : SimpleLayotParamChanged = new SimpleLayotParamChanged( _vg );
	    operation.dumpBefore();
	
	    _vg.layouter.disableAnimation = animateButton.selected;
		
		operation.dumpAfter();
		History.add( operation );
		
        updateLayouterParams();
}

private function showEdgeLabelsButtonClick() : void
{
	var operation : VisualGraphParamsChanged = new VisualGraphParamsChanged( _vg );
	    operation.dumpBefore(); 
	
	_vg.displayEdgeLabels = ! showEdgeLabelsButton.selected;
	
	    operation.dumpAfter();
	    History.add( operation );
	
	updateVisualGraphParams();
}

private var linkLengthHintShell : HintShell;

private function onLinkLengthButtonClick( e : MouseEvent ) : void
{
	if ( linkLengthHintShell )
	{
		onHideLinkLengthHint( null );
		HintManager.hideAll();
	}
	
	var tip : LinkLengthSlider = new LinkLengthSlider();
	    tip.vg = _vg;
		
		linkLengthHintShell = HintManager.show( tip, false, e.currentTarget, true );
		linkLengthHintShell.addEventListener( HintEvent.HIDE, onHideLinkLengthHint );	
}

private function onHideLinkLengthHint( e : HintEvent ) : void
{
	linkLengthHintShell.removeEventListener( HintEvent.HIDE, onHideLinkLengthHint );
	linkLengthHintShell = null;
}

private var depthHintShell : HintShell;

private function depthButtonClick( e : MouseEvent ) : void
{
	if ( depthHintShell )
	{
		onHideDepthHint( null );
		HintManager.hideAll();
	}
	
	var tip : SelectDepth = new SelectDepth();
	    tip.vgMediator    = _vgMediator;
		tip.addEventListener( CloseEvent.CLOSE, onDepthSelectedOnHint );
		
		depthHintShell    = HintManager.show( tip, false, e.currentTarget, true );
		depthHintShell.addEventListener( HintEvent.HIDE, onHideDepthHint );
}

private function onDepthSelectedOnHint( e : CloseEvent ) : void
{
	updateVGMediatorParams();
}

private function onHideDepthHint( e : HintEvent ) : void
{
	depthHintShell.client.removeEventListener( CloseEvent.CLOSE, onDepthSelectedOnHint );
	
	depthHintShell.removeEventListener( HintEvent.HIDE, onHideDepthHint );
	depthHintShell = null;
}