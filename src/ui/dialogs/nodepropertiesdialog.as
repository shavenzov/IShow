import com.amf.events.AMFErrorEvent;
import com.bs.amg.UnisAPI;
import com.bs.amg.UnisAPIImplementation;
import com.bs.amg.events.AMGAllIconsEvent;
import com.dataloaders.GlobalImageCash;
import com.dataloaders.ImageCash;
import com.dataloaders.LoaderRecord;
import com.managers.HintManager;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.managers.history.History;

import org.un.cava.birdeye.ravis.assets.Assets;
import org.un.cava.birdeye.ravis.components.renderers.nodes.INodeRenderer;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
import org.un.cava.birdeye.ravis.history.ChangeNodeProperties;

import ui.utils.ErrorUtils;

/**
 * Узел св-ва которого необходимо редактировать 
 */
public var node : IVisualNode;

private var api : UnisAPIImplementation;

private function onCreationComplete() : void
{
	initializeDialog();
}

private function initializeDialog() : void
{
	//Имя
	objectName.text = node.data.name;
	//Описание
	objectDesc.text = node.data.desc;
	
	api = UnisAPI.impl;
	
	if ( api.icons )
	{
		updateIcons();
	}
	else
	{
		loadIcons();
	}
}

private function onGotAllIcons( e : AMGAllIconsEvent ) : void
{
	api.removeAllObjectListeners( this );
	currentState = 'normal';
	updateIcons();
}

private function onGetAllIconsError( e : AMFErrorEvent ) : void
{
	api.removeAllObjectListeners( this );
	Alert.show( 'Ошибка получения списка иконок!', 'Ошибка' );
	currentState = 'normal';
	updateIconsFromCash();
}

private function loadIcons() : void
{
	currentState = 'loading';
	
	api.addListener( AMGAllIconsEvent.GET_ALL_ICONS, onGotAllIcons, this );
	api.addListener( AMFErrorEvent.ERROR, onGetAllIconsError, this );
	api.getAllIcons();
}

private function updateIcons() : void
{
	//Список доступных иконок
	var icons     : Array  = api.icons.slice();
	var iconIndex : int    = -1;
	var url       : String = node.data.icon.split( '::' )[ 1 ];
	
	for ( var i : int = 0; i < icons.length; i ++ )
	{
		if ( icons[ i ] == url )
		{
			iconIndex = i;
		}
	}
	
	this.icons.dataProvider = new ArrayCollection( icons );
	this.icons.selectedIndex = iconIndex;
}

private function updateIconsFromCash() : void
{
	//Список доступных иконок
	var icons     : Array = new Array();
	var iconIndex : int = -1;
	var imageCash : ImageCash = GlobalImageCash.impl;
	var data      : Object;
	var record    : LoaderRecord;
	var url       : String = node.data.icon.split( '::' )[ 1 ];
	
	for ( var i : int = 0; i < imageCash.cash.length; i ++ )
	{
		record = imageCash.cash[ i ];
		
		icons.push( record.data );
		
		if ( url == record.data )
		{
			iconIndex = i;
		}
	}
	
	this.icons.dataProvider = new ArrayCollection( icons );
	this.icons.selectedIndex = iconIndex;
}

private function checkObjectNameField() : Boolean
{
	if ( objectName.text.length == 0 )
	{
		objectName.errorString = 'Введите название объекта';
		return false;
	}
	else
	{
		objectName.errorString = null;
	}
	
	return true;
}

private function checkFields() : UIComponent
{
	if ( ! checkObjectNameField() )
	{
		return objectName;
	}
	
	return null;
}

private function apply() : void
{
	var changed : Boolean;
	
	var operation : ChangeNodeProperties = new ChangeNodeProperties( node.vgraph, node );
	    operation.dumpBefore();
	
	//Название
	if ( node.data.name != objectName.text )
	{
		node.data.name = objectName.text;
		changed = true;
	}
	
	//Описание
	if ( node.data.desc != objectDesc.text )
	{
		node.data.desc = objectDesc.text;
		changed = true;
	}
	
	//Иконка
	if ( icons.selectedIndex != -1 )
	{
		var selectedIcon : String = icons.selectedItem;
		var currentIcon  : String = node.data.icon.split( '::' )[ 1 ];
		
		if ( selectedIcon != currentIcon )
		{
			node.data.icon = 'url::' + selectedIcon;
			changed = true;
		}
	}
	
	//Если произошли изменения
	if ( changed )
	{
		//добавляем их в историю
		operation.dumpAfter();
		History.add( operation );
		
		INodeRenderer( node.view ).refresh();
		node.view.validateNow();
		node.updateReleatedEdges();
	}
	
	operation = null;
}

private function closeButtonClick() : void
{
	dispatchEvent( new CloseEvent( CloseEvent.CLOSE, false, false, Alert.CANCEL ) );
}

private function applyButtonClick() : void
{
	var errorField : UIComponent = checkFields();
	
	if ( errorField )
	{
		ErrorUtils.justShow( errorField );
		return;
	}
	
	apply();
	dispatchEvent( new CloseEvent( CloseEvent.CLOSE, false, false, Alert.OK ) );
}
 