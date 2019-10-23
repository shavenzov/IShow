import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.utils.ObjectUtil;

import org.un.cava.birdeye.ravis.assets.Assets;
import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

/**
 * Список объектов для отображения Dictionary.<IVisulaNode> 
 */
public var objects : Dictionary;

/**
 * Выбранный объект по умолчанию. При выборе объектов в списке это св-во меняется. 
 */
public var mainObject : IVisualNode;

private function creationComplete() : void
{
	var objectsArray : Array = ObjectUtil.dictionaryToArray( objects );
	    objectsArray.sort( Graph.nodesSortCompareFunction );
	
	objectList.dataProvider = new ArrayCollection( objectsArray );
	objectList.selectedItem = mainObject;
	objectList.validateNow();
	
	objectList.scrollToIndex( objectList.selectedIndex );
	
	selectButton.enabled = mainObject != null;
}

private function onObjectListChanged() : void
{
	selectButton.enabled = objectList.selectedItem != null;
	mainObject           = objectList.selectedItem;
}

private function onSelect() : void
{
	dispatchEvent( new CloseEvent( CloseEvent.CLOSE, false, false, Alert.OK ) );
}