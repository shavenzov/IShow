import com.bs.amg.tasks.UnisRelationsRemover;
import com.managers.PopUpManager;
import com.thread.SimpleTask;
import com.thread.events.StatusChangedEvent;

import mx.controls.Alert;
import mx.events.CloseEvent;

import org.un.cava.birdeye.ravis.assets.Assets;

public var selectedEdges : Array;
public var selectedNodes : Array;

private function onCreationComplete() : void
{
	if ( selectedEdges.length > 1 )
	{
		promptText.text = 'Действительно удалить выбранные связи?';
	}
	else
	{
		promptText.text = 'Действительно удалить выбранную связь?';
	}
}

private function close( detail : uint = Alert.CANCEL ) : void
{
	dispatchEvent( new CloseEvent( CloseEvent.CLOSE, false, false, detail ) );
}

private function removeButtonClick() : void
{
	if ( saveToDBCheckBox.selected )
	{
		runRemover();
		return;
	}
	
	close( Alert.OK );
}

private var remover : UnisRelationsRemover;

private function runRemover() : void
{
	visible = false;
	
	remover = new UnisRelationsRemover( selectedEdges );
	remover.addEventListener( StatusChangedEvent.STATUS_CHANGED, onRemoverStatusChanged );
	remover.run();
	
	PopUpManager.showLoading( 'Удаление' );
}

private function onRemoverStatusChanged( e : StatusChangedEvent ) : void
{
	if ( e.status != SimpleTask.DONE )
	{
		PopUpManager.changeLoadingLabel( remover.statusString );
		return;
	}
	
	if ( e.status == SimpleTask.DONE )
	{
		remover.removeEventListener( StatusChangedEvent.STATUS_CHANGED, onRemoverStatusChanged );
		remover = null;
		
		PopUpManager.hideLoading();
		close( Alert.OK );
	}
}