import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.events.ColorPickerEvent;
import mx.managers.history.History;

import spark.events.IndexChangeEvent;

import org.un.cava.birdeye.ravis.components.renderers.edgeLabels.IEdgeLabelRenderer;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
import org.un.cava.birdeye.ravis.graphLayout.visual.VisualDefaults;
import org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers.ArrowStyle;
import org.un.cava.birdeye.ravis.history.ChangeEdgeProperties;
import org.un.cava.birdeye.ravis.assets.Assets;

import ui.utils.ErrorUtils;

/**
 * Связь св-ва которой необходимо редактировать 
 */
public var edge : IVisualEdge;

private function onCreationComplete() : void
{
	initializeDialog();
}

private function initializeDialog() : void
{
	//Имя
	edgeName.text = edge.data.label;
	//Описание
	edgeDesc.text = edge.data.desc;
	
    //Тип связи
	initializeTypes();
	
	//Цвет
	var color : uint = edge.data.color ? edge.data.color : VisualDefaults.edgeStyle.color;
	
	edgeColor.selectedColor = color;
	edgeColorValue.text     = formatColor( color );
	
	//Толщина
	initializeWeights( edge.data.arrow, color );
	edgeWeight.selectedIndex = edge.data.flow - 1;
	
	
}

private function initializeWeights( arrowStyle : String, color : uint ) : void
{
	var weights    : Array  = new Array();
	var maxWeight  : Number = 8.0;
	var weightStep : Number = 1.0;
	
	for ( var i : Number = weightStep; i <= maxWeight; i += weightStep )
	{
		weights.push( { weight : i, arrow : arrowStyle, color : color, label : i.toString() + ' пикс.' } );
	}
	
	edgeWeight.dataProvider = new ArrayCollection( weights );
}

private function refreshWeights( arrowStyle : String, color : uint ) : void
{
	var index : int = edgeWeight.selectedIndex;
	
	initializeWeights( arrowStyle, color );
	
	edgeWeight.selectedIndex = index;
}

private function initializeTypes() : void
{
	var edgeTypes : Array = [
		                     { label : 'Простая', type : ArrowStyle.NONE },
							 { label : 'Направленная', type : ArrowStyle.SINGLE },
							 { label : 'Направленная (инвертированная)', type : ArrowStyle.SINGLE_INVERTED },
							 { label : 'Двухсторонняя', type : ArrowStyle.DOUBLE }
		                    ];
	
	edgeArrow.dataProvider = new ArrayCollection( edgeTypes );
	
	for ( var i : int = 0; i < edgeTypes.length; i ++ )
	{
		if ( edgeTypes[ i ].type == edge.data.arrow )
		{
			edgeArrow.selectedIndex = i;
			break;
		}
	}
}

private function onEdgeArrowChanged( e : IndexChangeEvent ) : void
{
	refreshWeights( edgeArrow.selectedItem.type, edgeColor.selectedColor );
}

private function onEdgeColorChanged( e : ColorPickerEvent ) : void
{
	edgeColorValue.text = formatColor( e.color );
	refreshWeights( edgeArrow.selectedItem.type, e.color );
}

private function formatColor( color : uint ) : String
{
	return '#' + color.toString( 16 );
}
/*
private function checkObjectNameField() : Boolean
{
	if ( edgeName.text.length == 0 )
	{
		edgeName.errorString = 'Введите название связи';
		return false;
	}
	else
	{
		edgeName.errorString = null;
	}
	
	return true;
}

private function checkFields() : UIComponent
{
	if ( ! checkObjectNameField() )
	{
		return edgeName;
	}
	
	return null;
}
*/

private function apply() : void
{
	var changed   : Boolean;
	var operation : ChangeEdgeProperties = new ChangeEdgeProperties( edge.vgraph, edge );
	    operation.dumpBefore();
	
	//Название
	if ( edge.data.label != edgeName.text )
	{
		edge.data.label = edgeName.text;
		changed = true;
	}
	
	//Описание
	if ( edge.data.desc != edgeDesc.text )
	{
		edge.data.desc = edgeDesc.text;
		changed = true;
	}
	
	//Тип
	if ( edgeArrow.selectedItem && ( edge.data.arrow != edgeArrow.selectedItem.type ) )
	{
		edge.data.arrow = edgeArrow.selectedItem.type;
		changed = true;
	}
	
	//Толщина
	if ( edgeWeight.selectedItem && ( edge.data.flow != edgeWeight.selectedItem.weight ) )
	{
		edge.data.flow = edgeWeight.selectedItem.weight;
		changed = true;
	}
	
	//Цвет
	if ( edge.data.color != edgeColor.selectedColor )
	{
		edge.lineStyle.color = edge.data.color = edgeColor.selectedColor;
		changed = true;
	}
	
	if ( changed )
	{
		operation.dumpAfter();
		History.add( operation );
		
		IEdgeLabelRenderer( edge.labelView ).refresh();
		edge.edge.node1.vnode.updateReleatedEdges();
		edge.edge.node2.vnode.updateReleatedEdges();
	}
	
	operation = null;
}

private function closeButtonClick() : void
{
	dispatchEvent( new CloseEvent( CloseEvent.CLOSE, false, false, Alert.CANCEL ) );
}

private function applyButtonClick() : void
{
	/*var errorField : UIComponent = checkFields();
	
	if ( errorField )
	{
		ErrorUtils.justShow( errorField );
		return;
	}*/
	
	apply();
	dispatchEvent( new CloseEvent( CloseEvent.CLOSE, false, false, Alert.OK ) );
}