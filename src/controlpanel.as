import com.amf.events.AMFErrorEvent;
import com.bs.amg.UnisAPI;
import com.bs.amg.UnisVisualGraphMediator;
import com.bs.amg.events.AMGEvent;
import com.bs.amg.features.IShowFeatures;
import com.managers.HintManager;
import com.managers.HintShell;
import com.managers.PopUpManager;
import com.managers.events.HintEvent;
import com.tasks.IEncodeTask;
import com.tasks.JPEGEncodeTask;
import com.tasks.PNGEncodeTask;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.controls.Alert;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.events.IndexChangedEvent;
import mx.events.MenuEvent;
import mx.events.SliderEvent;
import mx.managers.history.History;

import spark.events.IndexChangeEvent;

import dialogs.SaveGraphAS;

import org.un.cava.birdeye.ravis.assets.Assets;
import org.un.cava.birdeye.ravis.assets.icons.EmbeddedIcons;
import org.un.cava.birdeye.ravis.components.renderers.nodes.ExpandButton;
import org.un.cava.birdeye.ravis.components.renderers.nodes.INodeRenderer;
import org.un.cava.birdeye.ravis.graphLayout.data.INode;
import org.un.cava.birdeye.ravis.graphLayout.layout.BubbleLayouter;
import org.un.cava.birdeye.ravis.graphLayout.layout.CircularLayouter;
import org.un.cava.birdeye.ravis.graphLayout.layout.ConcentricRadialLayouter;
import org.un.cava.birdeye.ravis.graphLayout.layout.ForceDirectedLayouter;
import org.un.cava.birdeye.ravis.graphLayout.layout.HierarchicalLayouter;
import org.un.cava.birdeye.ravis.graphLayout.layout.ILayoutAlgorithm;
import org.un.cava.birdeye.ravis.graphLayout.layout.LayoutOrientation;
import org.un.cava.birdeye.ravis.graphLayout.layout.LayouterUtils;
import org.un.cava.birdeye.ravis.graphLayout.layout.ParentCenteredRadialLayouter;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
import org.un.cava.birdeye.ravis.graphLayout.visual.animation.EdgesDirectionAnimator;
import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualSelectionChangedEvent;
import org.un.cava.birdeye.ravis.graphLayout.visual.operation.VisualGraphMode;
import org.un.cava.birdeye.ravis.history.LayoutChanged;
import org.un.cava.birdeye.ravis.history.LayoutParamsChanged;
import org.un.cava.birdeye.ravis.history.SimpleDataParamChanged;
import org.un.cava.birdeye.ravis.history.SimpleLayotParamChanged;
import org.un.cava.birdeye.ravis.history.VisualGraphParamsChanged;

import ui.save.InputGraphNameDialog;

private var _vg         : IVisualGraph;

public var vgMediator : UnisVisualGraphMediator;

override protected function setDefaults() : void
{
	super.setDefaults();
	
	if ( ! _data.hasOwnProperty( 'navigatorVisible' ) )
	{
		_data.navigatorVisible = false;
	}
	
	if ( ! _data.hasOwnProperty( 'settingsVisible' ) )
	{
		_data.settingsVisible = false;
	}
	
	if ( ! _data.hasOwnProperty( 'searchVisible' ) )
	{
		_data.searchVisible = false;
	}
}

public function get navigatorVisible() : Boolean
{
	return _data.navigatorVisible;
}

public function set navigatorVisible( value : Boolean ) : void
{
	_data.navigatorVisible = value;
	openNavigatorButton.selected = value;
	
	save();
}

public function get settingsVisible() : Boolean
{
	return _data.settingsVisible;
}

public function set settingsVisible( value : Boolean ) : void
{
	_data.settingsVisible = value;
	openSettingsButton.selected = value;
	
	save();
}

public function get searchVisible() : Boolean
{
	return _data.searchVisible;
}

public function set searchVisible( value : Boolean ) : void
{
	_data.searchVisible = value;
	searchButton.selected = value;
	
	save();
}

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
			_vg.removeEventListener( VisualGraphEvent.LAYOUT_CHANGED, onVGLayoutChanged );
			_vg.removeEventListener( VisualGraphEvent.VISUAL_GRAPH_DATA_CHANGED, onVGDataChanged );
			_vg.removeEventListener( VisualSelectionChangedEvent.SELECTION_CHANGED, onSelectionChanged );
			_vg.removeEventListener( VisualGraphEvent.DELETE, onDelete);
		}
		
		_vg = value;
		
		_vg.addEventListener( VisualGraphEvent.SCALED, onVGScaled );
		_vg.addEventListener( VisualGraphEvent.LAYOUT_CHANGED, onVGLayoutChanged );
		_vg.addEventListener( VisualGraphEvent.VISUAL_GRAPH_DATA_CHANGED, onVGDataChanged );
		_vg.addEventListener( VisualSelectionChangedEvent.SELECTION_CHANGED, onSelectionChanged );
		_vg.addEventListener( VisualGraphEvent.DELETE, onDelete );
	}
}

private function onSelectionChanged( e : VisualSelectionChangedEvent ) : void
{
	updateExpandButton();
}

private function onDelete( e : VisualGraphEvent ) : void
{
	updateExpandButton();
}

private function undoButtonClick() : void
{
	History.undo();
}

private function redoButtonClick() : void
{
	History.redo();
}

private function onInitialized() : void
{
	History.listener.addEventListener( Event.CHANGE, onHistoryChanged );
	setFeaturesPermision();
}

private function setFeaturesPermision() : void
{
	var features : IShowFeatures = UnisAPI.impl.features;
	
	if ( features.isDenied( IShowFeatures.SAVE_GRAPH ) )
	{
		saveButton.visible       = saveButton.includeInLayout = 
		saveButtonSpacer.visible = saveButtonSpacer.includeInLayout = false;	
	}
	
	if ( features.isDenied( IShowFeatures.UNDO_AND_REDO ) )
	{
		History.enabled =
		historyButtons.visible = historyButtons.includeInLayout =
		historyButtonsSpacer.visible = historyButtonsSpacer.includeInLayout = false;  	
	}
	
	if ( features.isDenied( IShowFeatures.SCROLL_MODE ) )
	{
		scrollModeButton.visible = scrollModeButton.includeInLayout =
		scrollModeButtonSpacer.visible = scrollModeButtonSpacer.includeInLayout = false;	
	}
	
	if ( features.isDenied( IShowFeatures.EXPAND ) )
	{
		expandButtonGroup.visible = expandButtonGroup.includeInLayout = 
		expandButtonGroupSpacer.visible = expandButtonGroupSpacer.includeInLayout = false;	
	}
	
	if ( features.isDenied( IShowFeatures.ANIMATE_DIRECTION_RELATIONS ) )
	{
		animateEdgesDirectionButtonGroup.visible = animateEdgesDirectionButtonGroup.includeInLayout =
		animateEdgesDirectionButtonSpacer.visible = animateEdgesDirectionButtonSpacer.includeInLayout = false;	
	}
	
	if ( features.isDenied( IShowFeatures.CHANGE_SCALE ) )
	{
		zoomGroup.visible = zoomGroup.includeInLayout =
		zoomGroupSpacer.visible = zoomGroupSpacer.includeInLayout = false;	
	}

	if ( features.isDenied( IShowFeatures.NAVIGATOR ) )
	{
		openNavigatorButton.visible = openNavigatorButton.includeInLayout =
		openNavigatorSpacer.visible = openNavigatorSpacer.includeInLayout = false;	
	}
	
	if ( features.isDenied( IShowFeatures.CHANGE_LAYOUT ) && ( features.isDenied( IShowFeatures.CHANGE_SCALE ) || ( features.isDenied( IShowFeatures.ZOOM_IN ) && features.isDenied( IShowFeatures.ZOOM_OUT ) ) ) )
	{
		layoutAndScaleGroup.visible = layoutAndScaleGroup.includeInLayout =
		layoutAndScaleSpacer.visible = layoutAndScaleSpacer.includeInLayout = false;	
	}
	else
	{
		if ( features.isDenied( IShowFeatures.CHANGE_LAYOUT ) )
		{
			layoutGroup.visible = layoutGroup.includeInLayout = false;	
		}
		else
		if ( features.isDenied( IShowFeatures.CHANGE_SCALE ) )
		{
			scaleGroup.visible = scaleGroup.includeInLayout = false;
		}
	}
	
	if ( features.isDenied( IShowFeatures.LAYOUT_SETTINGS ) )
	{
		openSettingsGroup.visible = openSettingsGroup.includeInLayout = false;
	}
	
	if ( features.isDenied( IShowFeatures.SEARCH ) )
	{
		searchButton.visible = searchButton.includeInLayout =
		searchButtonSpacer.visible = searchButtonSpacer.includeInLayout = false;	
	}
	
	if ( features.isDenied( IShowFeatures.APPLICATION_INFORMATION ) )
	{
		helpButton.visible = helpButton.includeInLayout =
		helpButtonSpacer.visible = helpButtonSpacer.includeInLayout = false;	
	}
}

private function onHistoryChanged( e : Event ) : void
{
	updateHistoryButtons();
}

private function updateHistoryButtons() : void
{
	undoButton.enabled = History.isCanUndo();
	redoButton.enabled = History.isCanRedo();
}

/**
 * Инициализация 
 * 
 */
private function onCreationComplete() : void
{
	//Обновляем кнопки отмены действий
	updateHistoryButtons();
	//Обновляем значение масштаба
	updateScaleControl();
	//Обновляем кнопку вкл/выкл анимировать направление связей
	updateEdgesDirectionButton();
	//Обновляем кнопку меню выбора раскладки
	updateLayouterButton();
	//Делаем видимыми те панели которые должны быть открыты
	updateDialogsVisisbility();
	
	updateHandModeButton();
	updateExpandButton();
}

private function updateDialogsVisisbility() : void
{
	var features : IShowFeatures = UnisAPI.impl.features;
	
	if ( navigatorVisible )
	{
		if ( features.isAllow( IShowFeatures.NAVIGATOR ) )
		{
			openNavigatorButton.selected = navigatorVisible;
			dispatchEvent( new Event( 'openNavigator' ) );
		}
	}
	
	if ( settingsVisible )
	{
		if ( features.isAllow( IShowFeatures.LAYOUT_SETTINGS ) )
		{
			openSettingsButton.selected = settingsVisible;
			dispatchEvent( new Event( 'openSettingsDialog' ) );
		}
	}
	
	if ( searchVisible )
	{
		if ( features.isAllow( IShowFeatures.SEARCH ) )
		{
			searchButton.selected = searchVisible;
			dispatchEvent( new Event( 'openSearchDialog' ) );
		}
	}
}

private function updateScaleControl() : void
{
	scaleButton.label = UIRoutines.scaleDataFormatFunction( _vg.scale );
}

private function updateEdgesDirectionButton() : void
{
	animateEdgesDirectionButton.selected = _vg.animateEdgesDirection;
}

private function updateLayouterButton() : void
{
	layoutSelector.label = LayouterUtils.getLayouterDescription( vg.layouter );
}

private function onVGScaled( e : VisualGraphEvent ) : void
{
	updateScaleControl();
}

private function updateExpandButton() : void
{
	expandButton.enabled = _vg.noSelectedNodes > 0;
}

private function expandButtonClick( e : MouseEvent ) : void
{
	var expandedNodes  : Vector.<IVisualNode> = new Vector.<IVisualNode>();
	var expandingNodes : Vector.<IVisualNode> = new Vector.<IVisualNode>();
	var nodes          : Vector.<IVisualNode> = new Vector.<IVisualNode>();
	
	var node           : IVisualNode;
	var view           : INodeRenderer;
	var okNode         : Boolean;
	
	//Проверяем раскрыты ли выбранные объекты
	if ( _vg.noSelectedNodes > 0 )
	{
		for each( node in _vg.selectedNodes )
		{
			okNode = true;
			
			if ( node.data.expanded )
			{
				expandedNodes.push( node );
				okNode = false;
			}
			
			if ( node.view )
			{
				view = INodeRenderer( node.view );
				
				if ( view )
				{
					if ( view.progress )
					{
						expandingNodes.push( node );
						okNode = false;
					}
				}
			}
			
			if ( okNode )
			{
				nodes.push( node );
			}
		}
	}
	
	if ( nodes.length == 0 )
	{
		if ( expandingNodes.length > 0 ) //Проверка на раскрываемые объекты
		{
			if ( expandingNodes.length == 1 )
			{
				HintManager.show( 'Выбранный объект уже в процессе раскрытия', true, e.currentTarget, true );
			}
			else
			{
				HintManager.show( 'Выбранные объекты уже в процессе раскрытия', true, e.currentTarget, true );
			}
		}	
		//Проверка на уже раскрытые объекты
		else if ( expandedNodes.length > 0 )
		{
			if ( expandedNodes.length == 1 )
			{
				HintManager.show( 'Выбранный объект уже раскрыт', true, e.currentTarget, true );
			}
			else
			{
				HintManager.show( 'Выбранные объекты уже раскрыты', true, e.currentTarget, true );
			}
			
			return;
		}	
	}
	
	//Запускаем процесс раскрытия узлов
	vgMediator.expandNodes( nodes );
}

private function scaleDataTipFormatFunction( value : Number ) : String
{
	var scaleInPercents : Number = Math.round( value * 100.0 );
	return scaleInPercents.toString() + '%';
}

private function updateScale( value : Number ) : void
{
	_vg.scale = value;
}

private function openNavigator() : void
{
	navigatorVisible = ! navigatorVisible;
	
	if ( navigatorVisible )
	{
		dispatchEvent( new Event( 'openNavigator' ) );
	}
	else
	{
		dispatchEvent( new Event( 'closeNavigator' ) );
	}
}

private function openSettings() : void
{
	settingsVisible = ! settingsVisible;
	
	if ( settingsVisible )
	{
		dispatchEvent( new Event( 'openSettingsDialog' ) );
	}
	else
	{
		dispatchEvent( new Event( 'closeSettingsDialog' ) );
	}
}

private function onVGLayoutChanged( e : VisualGraphEvent ) : void
{
	updateLayouterButton();
}

private function onVGDataChanged( e : VisualGraphEvent ) : void
{
	updateEdgesDirectionButton();
}

private function updateHandModeButton() : void
{
	if ( _vg.mode == VisualGraphMode.SCROLL )
	{
		handScrollModeButton.selected = true;
		handScrollModeButton.toolTip = 'Отключить режим прокрутки';
		return;
	}
	
	handScrollModeButton.selected = false;
	handScrollModeButton.toolTip = 'Включить режим прокрутки';
}

private function onHandScrollModeButtonClick() : void
{
	if ( _vg.mode == VisualGraphMode.SELECTION )
	{
		_vg.mode = VisualGraphMode.SCROLL;
	}
	else
	{
		_vg.mode = VisualGraphMode.SELECTION;
	}
	
	updateHandModeButton();
}

/*Отображение диалогов*/

//Далог сохранения VisualGraph в png/jpeg

private var saveGraphAsTask : SaveGraphAS;

private function saveToJPEG() : void
{
  showEncoderDialog( new JPEGEncodeTask( 100 ), 'graph.jpg' );
}

private function saveToPNG() : void
{
   showEncoderDialog( new PNGEncodeTask(), 'graph.png' );	
}

public function saveImageToCloud( objectId : String ) : void
{
	showEncoderDialog( new JPEGEncodeTask( 100 ), objectId, true );
}

private function showEncoderDialog( encoder : IEncodeTask, defaultFileName : String, saveToCloud : Boolean = false ) : void
{
	saveGraphAsTask = new SaveGraphAS( _vg, encoder, defaultFileName, saveToCloud );
	//saveGraphAsTask.addEventListener( CloseEvent.CLOSE, onCloseSaveGraphDialog );
	saveGraphAsTask.show();
	saveGraphAsTask.run();
}

/*Отображение диалогов*/

private function searchButtonClick() : void
{
	searchVisible = ! searchVisible;
	
	if ( searchVisible )
	{
		dispatchEvent( new Event( "openSearchDialog" ) );
	}
	else
	{
		dispatchEvent( new Event( "closeSearchDialog" ) );
	}
}

private var inputGraphNameDialog : InputGraphNameDialog;

private function showInputGraphNameDialog() : void
{
	if ( ! inputGraphNameDialog )
	{
		inputGraphNameDialog = new InputGraphNameDialog();
		inputGraphNameDialog.addEventListener( CloseEvent.CLOSE, hideInputGraphNameDialog );
		
		PopUpManager.addPopUp( inputGraphNameDialog, null, true );
		PopUpManager.centerPopUp( inputGraphNameDialog );
	}
}

private function hideInputGraphNameDialog( e : CloseEvent ) : void
{
	if ( inputGraphNameDialog )
	{
		inputGraphNameDialog.removeEventListener( CloseEvent.CLOSE, hideInputGraphNameDialog );
		PopUpManager.removePopUp( inputGraphNameDialog );
		
		if ( e.detail == Alert.OK )
		{
			UnisAPI.impl.addListener( AMGEvent.GRAPH_SAVED, onGraphSaved, this );
			UnisAPI.impl.addListener( AMFErrorEvent.ERROR, onSaveGraphError, this );
			UnisAPI.impl.saveGraph( inputGraphNameDialog.selectedName, _vg.graph.data );
			
			PopUpManager.showLoading( 'Сохранение ' + inputGraphNameDialog.selectedName + '...' );
		}
		
		inputGraphNameDialog = null;
	}
}

private function onGraphSaved( e : AMGEvent ) : void
{
	UnisAPI.impl.removeAllObjectListeners( this );
	PopUpManager.hideLoading();
}

private function onSaveGraphError( e : AMFErrorEvent ) : void
{
	UnisAPI.impl.removeAllObjectListeners( this );
}

/**
 * Всплывающее меню выбора раскладки 
 */
private var layoutSelectorHintShell : HintShell;

private function onLayoutButtonClick( e : MouseEvent ) : void
{
	if ( layoutSelectorHintShell )
	{
		onHideLayoutSelectorHintShell( null );
		HintManager.hideAll();
	}
	
	var tip : LayoutSelector = new LayoutSelector();
	    tip.vg = _vg;
	
	layoutSelectorHintShell = HintManager.show( tip, false, e.currentTarget, true );
	layoutSelectorHintShell.addEventListener( HintEvent.HIDE, onHideLayoutSelectorHintShell );
}

private function onHideLayoutSelectorHintShell( e : HintEvent ) : void
{
	layoutSelectorHintShell.removeEventListener( HintEvent.HIDE, onHideLayoutSelectorHintShell );
	layoutSelectorHintShell = null;
}

/**
 * Всплывающее меню изменения масштаба 
 */
private var scaleSliderHintShell : HintShell;

private function onScaleButtonClick( e : MouseEvent ) : void
{
	if ( scaleSliderHintShell )
	{
		onHideScaleSliderHint( null );
		HintManager.hideAll();
	}
	
	var tip : ScaleSlider = new ScaleSlider();
	    tip.vg = _vg;
	
	scaleSliderHintShell = HintManager.show( tip, false, e.currentTarget, true );
	scaleSliderHintShell.addEventListener( HintEvent.HIDE, onHideScaleSliderHint );
}

private function onHideScaleSliderHint( e : HintEvent ) : void
{
	scaleSliderHintShell.removeEventListener( HintEvent.HIDE, onHideScaleSliderHint );
	scaleSliderHintShell = null;
}

/**
 * Всплывающее меню выбора вариантов сохранения графа 
 */
private var saveAsHintShell : HintShell;

private function onSaveAsButtonClick( e : MouseEvent ) : void
{
	if ( saveAsHintShell )
	{
		onHideSaveAsHint( null );
		HintManager.hideAll();
	}
	
	var tip : SaveAsSelector = new SaveAsSelector();
	    tip.addEventListener( SaveAsSelector.SAVE_TO_CLOUD_CLICK, onSomeButtonInSaveAsMenuClick );
		tip.addEventListener( SaveAsSelector.SAVE_AS_JPEG_CLICK, onSomeButtonInSaveAsMenuClick );
		tip.addEventListener( SaveAsSelector.SAVE_AS_PNG_CLICK, onSomeButtonInSaveAsMenuClick );
	    
	saveAsHintShell = HintManager.show( tip, false, e.currentTarget, true );
	saveAsHintShell.addEventListener( HintEvent.HIDE, onHideSaveAsHint );
}

private function onHideSaveAsHint( e : HintEvent ) : void
{
	saveAsHintShell.removeEventListener( HintEvent.HIDE, onHideSaveAsHint );
	saveAsHintShell.client.removeEventListener( SaveAsSelector.SAVE_TO_CLOUD_CLICK, onSomeButtonInSaveAsMenuClick );
	saveAsHintShell.client.removeEventListener( SaveAsSelector.SAVE_AS_JPEG_CLICK, onSomeButtonInSaveAsMenuClick );
	saveAsHintShell.client.removeEventListener( SaveAsSelector.SAVE_AS_PNG_CLICK, onSomeButtonInSaveAsMenuClick );
	
	saveAsHintShell = null;
}

private function onSomeButtonInSaveAsMenuClick( e : Event ) : void
{
	HintManager.hideAll();	
	
	if ( e.type == SaveAsSelector.SAVE_TO_CLOUD_CLICK )
	{
		saveGraphToCloud();
		return;
	}
	
	if ( e.type == SaveAsSelector.SAVE_AS_JPEG_CLICK )
	{
		saveToJPEG();
		return;
	}
	
	if ( e.type == SaveAsSelector.SAVE_AS_PNG_CLICK )
	{
		saveToPNG();
		return;
	}
}

private function saveGraphToCloud() : void
{
	showInputGraphNameDialog();
}

private function zoomInClick() : void
{
	_vg.zoomIn();
}

private function zoomOutClick() : void
{
	_vg.zoomOut();
}

private function animateEdgesDirectionButtonClick() : void
{
	var operation : VisualGraphParamsChanged = new VisualGraphParamsChanged( _vg );
	    operation.dumpBefore(); 
	
	    _vg.animateEdgesDirection = animateEdgesDirectionButton.selected;
		
		operation.dumpAfter();
		
		History.add( operation );
}

private function helpClick() : void
{
	dispatchEvent( new Event( 'openHelp' ) );
}