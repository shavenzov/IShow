import mx.collections.ArrayCollection;
import mx.utils.StringUtil;

import org.un.cava.birdeye.ravis.assets.Assets;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
import org.un.cava.birdeye.ravis.search.VisualGraphSearch;

import spark.events.IndexChangeEvent;

import ui.utils.ErrorUtils;

public var vg : IVisualGraph;

private var search : VisualGraphSearch;

private function searchButtonClick() : void
{
	//Удаляем пустые пробелы в начале и в конце 
	searchString.text = StringUtil.trim( searchString.text );
	
	//Если ничего не введено,
	if ( searchString.text.length == 0 )
	{
		searchString.errorString = 'Введите слово для поиска';
		ErrorUtils.justShow( searchString );
		
		return;
	}
	
	//Если не указано где искать
	if ( ! searchInNodes.selected && ! searchInEdges.selected )
	{
		searchParamsGroup.errorString = 'Выберите "Искать в объектах" или "Искать в связях"';
		ErrorUtils.justShow( searchParamsGroup );
		
		return;
	}
	
	search = new VisualGraphSearch( vg, searchString.text, searchInNodes.selected, searchInEdges.selected, caseSensitive.selected, wholeWord.selected );
	search.search();
	
	if ( search.numResults > 0 )
	{
		if ( resultGroup )
		{
			updateResult();
		}
		
		currentState = 'result';
	}
	else
	{
		if ( notFoundGroup )
		{
			updateNotFound();
		}
		
		currentState = 'notFound';
	}
}

private function onSearchStringChanged() : void
{
	searchString.errorString = null;
}

private function checkBoxSelected() : void
{
	searchParamsGroup.errorString = null;
}

private function updateNotFound() : void
{
	notFound.text = 'Не найдено ни одного объекта';
}

private function updateResult() : void
{
	foundCount.text = 'Найдено объектов : ' + search.numResults;
	result.dataProvider = new ArrayCollection( search.result );
	
	updateNextPrevButtonsVisible();
}

private function updateNextPrevButtonsVisible() : void
{
	var listIsNotEmpty : Boolean = result.dataProvider.length > 1;
	
	prevResultButton.enabled = listIsNotEmpty && result.selectedIndex > 0;
	nextResultButton.enabled = listIsNotEmpty && result.selectedIndex < result.dataProvider.length - 1;
}

private function nextResultButtonClick() : void
{
	result.selectedIndex ++;
	result.ensureIndexIsVisible( result.selectedIndex );
	updateNextPrevButtonsVisible();
	
	onResultSelectedIndexChanged( null );
}

private function prevResultButtonClick() : void
{
	result.selectedIndex --;
	result.ensureIndexIsVisible( result.selectedIndex );
	updateNextPrevButtonsVisible();
	
	onResultSelectedIndexChanged( null );
}

private function onResultSelectedIndexChanged( e : IndexChangeEvent ) : void
{
	search.highlightObject( result.selectedItem );
	updateNextPrevButtonsVisible();
}

private function onShow() : void
{
	searchString.setFocus();
}