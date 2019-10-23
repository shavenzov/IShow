import com.bs.amg.UnisAPI;
import com.bs.amg.UnisVisualGraphMediator;
import com.bs.amg.features.IShowFeatures;
import com.managers.HintManager;
import com.managers.PopUpManager;
import com.thread.events.StatusChangedEvent;
import com.thread.events.TaskEvent;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.ui.Keyboard;

import mx.controls.Alert;
import mx.effects.Fade;
import mx.events.CloseEvent;
import mx.events.MenuEvent;
import mx.events.PropertyChangeEvent;
import mx.managers.ToolTipManager;
import mx.managers.history.History;
import mx.styles.CSSStyleDeclaration;

import org.un.cava.birdeye.ravis.assets.Assets;
import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualEdgeEvent;
import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphCreateEdgeEvent;
import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphEvent;
import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualGraphRemoveObjectEvent;
import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualNodeEvent;
import org.un.cava.birdeye.ravis.graphLayout.visual.events.VisualSelectionChangedEvent;
import org.un.cava.birdeye.ravis.graphLayout.visual.menu.VisualGraphMenu;
import org.un.cava.birdeye.ravis.history.CreateEdge;
import org.un.cava.birdeye.ravis.history.RemoveSelectedObjects;
import org.un.cava.birdeye.ravis.operations.GroupNodes;
import org.un.cava.birdeye.ravis.utils.Geometry;

import ui.dialogs.AddRelationDialog;
import ui.dialogs.EdgePropertiesDialog;
import ui.dialogs.NodePropertiesDialog;
import ui.dialogs.RemoveRelationDialog;
import ui.group.ResultGroupObjectSelectionDialog;

private var vgMediator : UnisVisualGraphMediator;
private var _features  : IShowFeatures;

override protected function createChildren() : void
{
	super.createChildren();
	
	vgMediator = new UnisVisualGraphMediator( vg );
	vgMediator.addEventListener( TaskEvent.START, onExpandStart );
	vgMediator.addEventListener( TaskEvent.COMPLETE, onExpandComplete );
	vgMediator.addEventListener( StatusChangedEvent.STATUS_CHANGED, onExpandStatusChanged );
	
	controlPanel.vgMediator = vgMediator;
	settings.vgMediator     = vgMediator;
}

private function onInit() : void
{
	ToolTipManager.showEffect = new Fade();
	ToolTipManager.hideEffect = new Fade();
	
	var css1 : CSSStyleDeclaration = styleManager.getStyleDeclaration( '.toolTip' );
	
	if ( css1 )
	{
		var css2 : CSSStyleDeclaration = new CSSStyleDeclaration( 'mx.controls.ToolTip' );
		    css2.defaultFactory = css1.factory;
		    
			styleManager.setStyleDeclaration( 'mx.controls.ToolTip', css2, false );
	}
	
	_features = UnisAPI.impl.features;
}

private function onExpandStart( e : TaskEvent ) : void
{
   statusBar.visible = statusBar.includeInLayout = true;
   statusLabel.text = '';
   cancelButton.enabled = true;
}

private function onExpandComplete( e : TaskEvent ) : void
{
	statusBar.visible = statusBar.includeInLayout = false;
	statusLabel.text = '';
}

private function onExpandStatusChanged( e : StatusChangedEvent ) : void
{
	statusLabel.text = e.statusString;
}

private function cancelClick() : void
{
	vgMediator.cancel();
	cancelButton.enabled = false;
}

private function onCreationComplete() : void
{	
	vgMediator.initialize();
	
	//Отслеживаем изменения размера рабочей области vg
	vg.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, onVGPropertyChanged );
}

private function onVGPropertyChanged( e : PropertyChangeEvent ) : void
{
	if ( e.property == "contentWidth" )
	{
		callLater( updateStatusBarPosition );
	}
}

/**
 * Обновляет положение statusBar в зависимости от наличия полос прокрутки 
 */
private function updateStatusBarPosition() : void
{
	if ( scroller.horizontalScrollBar.visible )
	{
		statusBar.setStyle( 'bottom', scroller.horizontalScrollBar.height );
	}
	else
	{
		statusBar.setStyle( 'bottom', 0.0 );
	}
}

private function onItemClick( e : MenuEvent ) : void
{
	//Показать карточку объекта
	if ( e.item.id == IShowFeatures.SHOW_INFO )
	{
		showInfo( e.item.source );
		return;
	}
	
	//Отобразить диалог редактирования св-в узла
	if ( e.item.id == IShowFeatures.NODE_PROPERTIES )
	{
		showNodePropertiesDialog( e.item.source );
		return;
	}
	
	//Отобразить диалог редактирования св-в связи
	if ( e.item.id == IShowFeatures.EDGE_PROPERTIES )
	{
		showEdgePropertiesDialog( e.item.source );
		return;
	}
	
	//Выбран пункт меню объедиинить ( группировать )
	if ( e.item.id == IShowFeatures.GROUP_SELECTED_NODES )
	{
		if ( e.item.source is IVisualNode )
		{
			showResultGroupObjectSelectionDialog( e.item.source );
		}
		else
		{
			showResultGroupObjectSelectionDialog();
		}
		
		return;
	}
	
	if ( e.item.id == IShowFeatures.DOWNLOAD )
	{
		navigateToURL( new URLRequest( e.item.source.node.pathToFile ), '_blank' );
		return;
	}
	
	if ( e.item.id == IShowFeatures.OPEN_IMAGE )
	{
		navigateToURL( new URLRequest( e.item.source.data.icon.split( '::' )[ 1 ] ), '_blank' );
		return;
	}
	
	if ( e.item.id == IShowFeatures.LINK_OBJECT_TO_GRAPH_IMAGE )
	{
		controlPanel.saveImageToCloud( e.item.source.node.stringid );
		return;
	}
}

private function showInfo( vnode : IVisualNode ) : void
{
	navigateToURL( new URLRequest( UnisAPI.impl.getObjectCardUrl( vnode.node.stringid ) ), '_blank' );
}

/**
 * При двлойном щечке на каком либо из узлов 
 */
private function onNodeDoubleClick( e : VisualNodeEvent ) : void
{
	showNodePropertiesDialog( e.node );
}

private function onEdgeDoubleClick( e : VisualEdgeEvent ) : void
{
	showEdgePropertiesDialog( e.edge );
}

/*Отображение диалогов*/

private function closeNavigator() : void
{
	navigator.visible = navigator.includeInLayout = false;
	controlPanel.navigatorVisible = false;
}

private function openNavigator() : void
{
	navigator.visible = navigator.includeInLayout = true;
	workArea.setElementIndex( navigator, workArea.numElements - 1 );
}

private function closeSearchDialog() : void
{
	search.visible = search.includeInLayout = false;
	controlPanel.searchVisible = false; 
}

private function openSearchDialog() : void
{
	search.currentState = "normal";
	search.visible = search.includeInLayout = true;
	workArea.setElementIndex( search, workArea.numElements - 1 );
}

private function closeSettingsDialog() : void
{
	settings.visible = settings.includeInLayout = false;
	controlPanel.settingsVisible = false;
}

private function openSettingsDialog() : void
{
	if ( settings.defaultPos )
	{
		settings.move( ( width - settings.width ) / 2.0, 0.0 );
	}
	
	settings.visible = settings.includeInLayout = true;
	workArea.setElementIndex( settings, workArea.numElements - 1 );
}

/**
 * Диалог редактирования св-в узла 
 */
private var nodePropertiesDialog : NodePropertiesDialog;

/**
 * Отобразить диалог редиактирования св-в узла 
 * @param node - узел для которого вызывается диалог
 * 
 */
private function showNodePropertiesDialog( node : IVisualNode ) : void
{
	if ( ! nodePropertiesDialog )
	{
		nodePropertiesDialog = new NodePropertiesDialog();
		nodePropertiesDialog.node = node;
		nodePropertiesDialog.addEventListener( CloseEvent.CLOSE, onCloseNodePropertiesDialog );
		PopUpManager.addPopUp( nodePropertiesDialog, null, true );
		PopUpManager.centerToMousePopUp( nodePropertiesDialog );
	}
}

private function hideNodePropertiesDialog() : void
{
	if ( nodePropertiesDialog )
	{
		nodePropertiesDialog.removeEventListener( CloseEvent.CLOSE, onCloseNodePropertiesDialog );
		PopUpManager.removePopUp( nodePropertiesDialog );
		nodePropertiesDialog = null;
	}
}

private function onCloseNodePropertiesDialog( e : CloseEvent ) : void
{
   hideNodePropertiesDialog();	
}

private var edgePropertiesDialog : EdgePropertiesDialog;

private function showEdgePropertiesDialog( edge : IVisualEdge ) : void
{
	if ( ! edgePropertiesDialog )
	{
		edgePropertiesDialog = new EdgePropertiesDialog();
		edgePropertiesDialog.edge = edge;
		edgePropertiesDialog.addEventListener( CloseEvent.CLOSE, onCloseEdgePropertiesDialog );
		PopUpManager.addPopUp( edgePropertiesDialog, null, true );
		PopUpManager.centerToMousePopUp( edgePropertiesDialog );
	}
}

private function hideEdgePropertiesDialog() : void
{
	if ( edgePropertiesDialog )
	{
		edgePropertiesDialog.removeEventListener( CloseEvent.CLOSE, onCloseEdgePropertiesDialog );
		PopUpManager.removePopUp( edgePropertiesDialog );
		edgePropertiesDialog = null;
	}
}

private function onCloseEdgePropertiesDialog( e : CloseEvent ) : void
{
   hideEdgePropertiesDialog();	
}

/**
 * Диалог вызываемый при попытке создать связь 
 */
private var addRelationDialog : AddRelationDialog;

private function showAddRelationDialog( event : VisualGraphCreateEdgeEvent ) : void
{
	if ( ! addRelationDialog )
	{
		addRelationDialog = new AddRelationDialog();
		addRelationDialog.node1 = event.node1;
		addRelationDialog.node2 = event.node2;
		addRelationDialog.addEventListener( CloseEvent.CLOSE, hideAddRelationDialog );
		PopUpManager.addPopUp( addRelationDialog, null, true );
		PopUpManager.centerPopUp( addRelationDialog );
	}
	
	event.preventDefault();
}

private function hideAddRelationDialog( e : CloseEvent ) : void
{
	if ( addRelationDialog )
	{
		if ( e.detail == Alert.OK )
		{
			var ve : IVisualEdge = vg.linkNodes( addRelationDialog.node1, addRelationDialog.node2, addRelationDialog.edgeData );
			
			//Добавляем событие в историю
			History.add( new CreateEdge( vg, ve.data ) );
		}
		
		addRelationDialog.removeEventListener( CloseEvent.CLOSE, hideAddRelationDialog );
		PopUpManager.removePopUp( addRelationDialog );
		addRelationDialog = null;
	}
}

private var removeRelationDialog : RemoveRelationDialog;

private function showRemoveRelationDialog( event : VisualGraphRemoveObjectEvent ) : void
{
	if ( _features.isDenied( IShowFeatures.REMOVE_EDGE ) || ( event.edges == null ) || ( event.edges.length == 0 ) )
	{
		return;
	}
	
	if ( ! removeRelationDialog )
	{
		removeRelationDialog = new RemoveRelationDialog();
		removeRelationDialog.selectedEdges = event.edges;
		removeRelationDialog.selectedNodes = event.nodes;
		removeRelationDialog.addEventListener( CloseEvent.CLOSE, hideRemoveRelationDialog );
		PopUpManager.addPopUp( removeRelationDialog, null, true );
		PopUpManager.centerPopUp( removeRelationDialog );
	}
	
	event.preventDefault();
}

private function hideRemoveRelationDialog( event : CloseEvent ) : void
{
	if ( removeRelationDialog )
	{
		removeRelationDialog.removeEventListener( CloseEvent.CLOSE, hideRemoveRelationDialog );
		PopUpManager.removePopUp( removeRelationDialog );
		
		if ( event.detail == Alert.OK )
		{
			//Добавляем действие в историю
			var operation : RemoveSelectedObjects = new RemoveSelectedObjects( vg );
			    operation.dumpBefore();
				
			var vedge        : IVisualEdge;
			
			for each( vedge in removeRelationDialog.selectedEdges )
			{
				vg.removeEdge( vedge );
			}
			
			var vnode : IVisualNode;
			
			for each( vnode in removeRelationDialog.selectedNodes )
			{
				vg.removeNode( vnode );
			}
			
			operation.dumpAfter();
			History.add( operation );
			
			vg.dispatchEvent( new VisualGraphEvent( VisualGraphEvent.DELETE ) );
		}
		
		removeRelationDialog = null;
	}
}

private var resultGroupObjectSelectionDialog : ResultGroupObjectSelectionDialog;

/**
 * Отображает диалог выбора результирующего объекта объединения 
 * 
 */
private function showResultGroupObjectSelectionDialog( mainObject : IVisualNode = null ) : void
{
	//Для объединения, необходимо выбрать хотя-бы два объекта
	if ( vg.noSelectedNodes < 2 )
	{
		HintManager.show( 'Для объединения необходимо выбрать хотя-бы два объекта', true );
		return;
	}
	
	//Проверяем выделенные узлы одного типа или нет
	if ( GroupNodes.nodesHasSimilarType( vg.selectedNodes ) )
	{
		if ( ! resultGroupObjectSelectionDialog )
		{
			resultGroupObjectSelectionDialog            = new ResultGroupObjectSelectionDialog();
			resultGroupObjectSelectionDialog.objects    = vg.selectedNodes;
			resultGroupObjectSelectionDialog.mainObject = mainObject;
			resultGroupObjectSelectionDialog.addEventListener( CloseEvent.CLOSE, onCloseResultGroupObjectSelectionDialog );
			
			PopUpManager.addPopUp( resultGroupObjectSelectionDialog, null, true );
			PopUpManager.centerToMousePopUp( resultGroupObjectSelectionDialog );
		}
		
		return;
	}
	
	HintManager.show( 'Для объединения выбранные объекты должны быть одного типа', true );
}

private var groupNodesOperation : GroupNodes;

private function onCloseResultGroupObjectSelectionDialog( e : CloseEvent ) : void
{
	if ( e.detail == Alert.OK )
	{
		groupNodesOperation = new GroupNodes( vg );
		groupNodesOperation.addEventListener( Event.COMPLETE, onGroupOperationComplete );
		groupNodesOperation.group( resultGroupObjectSelectionDialog.mainObject, resultGroupObjectSelectionDialog.objects, ! vgMediator.useSubExpandLayouter );
	}
	
	hideResultGroupObjectSelectionDialog();
}

private function onGroupOperationComplete( e : Event ) : void
{
	groupNodesOperation.removeEventListener( Event.COMPLETE, onGroupOperationComplete );
	groupNodesOperation = null;
	
	//Только если включена опция "Перестраивать при раскрытии"
	if ( ! vgMediator.useSubExpandLayouter )
	{
		vgMediator.draw();
	}
}

/**
 * Скрывает диалог выбора результирующего объекта объединения 
 * 
 */
private function hideResultGroupObjectSelectionDialog() : void
{
	if ( resultGroupObjectSelectionDialog )
	{
		resultGroupObjectSelectionDialog.removeEventListener( CloseEvent.CLOSE, onCloseResultGroupObjectSelectionDialog );
		PopUpManager.removePopUp( resultGroupObjectSelectionDialog );
		
		resultGroupObjectSelectionDialog = null;
	}
}

/*Отображение диалогов*/

/*Отображения диалога "Информация о версии приложения" */

private function onAddedToStage() : void
{
	stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
}

private function onKeyUp( e : KeyboardEvent ) : void
{
	//Отображения диалога "Информация о версии приложения ctrl+shift+F8
	if ( e.ctrlKey )
	{
		if ( e.shiftKey )
		{
			if ( e.keyCode == Keyboard.F8 )
			{
				showApplicationInfo();
				return;
			}
		}
		
		if ( e.keyCode == Keyboard.F )
		{
			openSearchDialog();
			return;
		}
		
		if ( e.keyCode == Keyboard.G )
		{
			showResultGroupObjectSelectionDialog();
			return;
		}
	}
	
	/*var node : IVisualNode;
	var groupNodeOperation : GroupNodes;
	
	if ( e.keyCode == Keyboard.NUMPAD_1 )
	{
		for each( node in vg.selectedNodes )
		{
			break;
		}
		
		groupNodeOperation = new GroupNodes( vg );
		groupNodeOperation.ungroup( node );
		
		return;
	}*/
}

private function showApplicationInfo() : void
{
	Alert.show( 'Визуализатор IShow.\nВерсия : ' + BUILD.VERSION + '\nДата сборки : ' + BUILD.TIME, 'Информация о версии приложения', 4, null, null, Assets.HELP_ICON );
}

/*Отображения диалога "Информация о версии приложения" */