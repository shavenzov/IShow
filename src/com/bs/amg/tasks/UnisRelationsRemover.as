package com.bs.amg.tasks
{
	import com.amf.events.AMFErrorEvent;
	import com.bs.amg.UnisAPI;
	import com.bs.amg.UnisAPIImplementation;
	import com.bs.amg.events.AMGEvent;
	import com.thread.SimpleTask;
	
	import flash.events.Event;
	
	public class UnisRelationsRemover extends SimpleTask
	{
		public static const REMOVING : int = 10;
		
		/**
		 * Список связей которые необходимо удалить из БД 
		 */		
		private var _edges : Array;
		private var _index : int;
		
		private var unis : UnisAPIImplementation;
		
		public function UnisRelationsRemover( edges : Array )
		{
			super();
			
			_edges = edges;
		}
		
		override protected function next() : void
		{
			switch( _status )
			{
				case SimpleTask.NONE : _status = REMOVING;
					                   init();
									   
				case REMOVING        : removeNext();
					                   break;
				
				case SimpleTask.DONE : uninit();
					                   break; 
			}
			
			super.next();
		}
		
		private function removeNext() : void
		{
			_index ++;
			
			if ( _index == _edges.length )
			{
				_status = SimpleTask.DONE;
				next();
				return;
			}
			
			_statusString = 'Удаляю : ' + _edges[ _index ].data.label;
			
			unis.removeRelation( _edges[ _index ].data.id );
		}
		
		private function init() : void
		{
			_index = -1;
			unis = UnisAPI.impl;
			unis.addListener( AMGEvent.RELATION_REMOVED, onRelationRemoved, this );
			unis.addListener( AMFErrorEvent.ERROR, onRelationRemoved, this );
		}
		
		private function uninit() : void
		{
			unis.removeAllObjectListeners( this );
			unis = null;
		}
		
		private function onRelationRemoved( e : Event ) : void
		{
			next();
		}
		
	}
}