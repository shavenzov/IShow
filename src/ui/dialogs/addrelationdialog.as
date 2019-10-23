import com.amf.events.AMFErrorEvent;
import com.bs.amg.UnisAPI;
import com.bs.amg.UnisAPIImplementation;
import com.bs.amg.events.AMGAddRelationEvent;
import com.bs.amg.events.AMGGetClassRelationEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.utils.ObjectUtil;

import spark.events.IndexChangeEvent;

import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
import org.un.cava.birdeye.ravis.graphLayout.visual.VisualDefaults;
import org.un.cava.birdeye.ravis.graphLayout.visual.VisualGraph;
import org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers.ArrowStyle;

/**
 * Отобразить диалог создания связей между объектами node 1 
 */
public var node1 : IVisualNode

/**
 * и node 2 
 */
public var node2 : IVisualNode;

/**
 * Если пользователь выбрал сохранить изменения в БД, то здесь будет информация о связи 
 */
public var edgeData : Object = VisualGraph.getDefaultEdgeData();

private var unis : UnisAPIImplementation;

private function onCreationComplete() : void
{
	node1View.data = node1;
	node2View.data = node2;
	
	var data : Object = ObjectUtil.clone( VisualDefaults.edgeStyle );
	    data.arrow    = ArrowStyle.DEFAULT_ARROW_STYLE;
		data.weight   = 4;
	
	edgeView.data = data;
	
	unis = UnisAPI.impl;
	unis.addListener( AMGGetClassRelationEvent.GET_CLASS_RELATIONS, onGotClassRelations, this );
	unis.addListener( AMFErrorEvent.ERROR, onAMFError, this );
	unis.getClassRelations( node1.data.type, node2.data.type );
}

private function onGotClassRelations( e : AMGGetClassRelationEvent ) : void
{
	unis.removeAllObjectListeners( this );
	relationTypes.dataProvider = new ArrayCollection( e.relations );
	currentState = 'normal';
}

private function onAMFError( e : AMFErrorEvent ) : void
{
	unis.removeAllObjectListeners( this );
	close();
}

private function onListChanged( e : IndexChangeEvent ) : void
{
	createButton.enabled = e.newIndex != -1;
}

private function close( detail : uint = Alert.CANCEL ) : void
{
	dispatchEvent( new CloseEvent( CloseEvent.CLOSE, false, false, detail ) );
}

private function createEdgeButtonClick() : void
{
	if ( saveToDBCheckBox.selected )
	{
		createEdge();
		return;
	}
	
	edgeData.label = relationTypes.selectedItem.name;
	
	close( Alert.OK );
}

private function createEdge() : void
{
		unis.addListener( AMGAddRelationEvent.ADD_RELATION, onRelationAdded, this );
		unis.addListener( AMFErrorEvent.ERROR, onAMFError, this );
		unis.addRelation( node1.node.stringid, node2.node.stringid, relationTypes.selectedItem.id, relationTypes.selectedItem.name );
		
		currentState = 'loading';
}

private function onRelationAdded( e : AMGAddRelationEvent ) : void
{
	unis.removeAllObjectListeners( this );
	
	edgeData.id = e.relationId;
	edgeData.label = relationTypes.selectedItem.name;
	
	close( Alert.OK );
}