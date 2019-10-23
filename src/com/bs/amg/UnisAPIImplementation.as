package com.bs.amg
{
	import com.amf.AMFApi;
	import com.amf.Call;
	import com.amf.events.AMFErrorEvent;
	import com.amf.events.AMFErrorLayer;
	import com.bs.amg.events.AMGAddRelationEvent;
	import com.bs.amg.events.AMGAllIconsEvent;
	import com.bs.amg.events.AMGEvent;
	import com.bs.amg.events.AMGGetClassRelationEvent;
	import com.bs.amg.events.AMGGraphDataEvent;
	import com.bs.amg.features.IShowFeatures;
	import com.bs.amg.types.ClassRelation;
	import com.utils.Base64;
	
	import flash.display.Stage;
	import flash.external.ExternalInterface;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	public class UnisAPIImplementation extends AMFApi
	{
		/**
		 * Список иконок доступных в приложении для объектов, Обновляется методом getAllIcons 
		 */		
		public var icons : Array;
		
		/**
		 * Разрешенный функционал приложения 
		 */		
		public var features : IShowFeatures; 
		
		/**
		 * Относительный путь до AMF шлюза 
		 */		
		public static const AMF_GATEWAY_PATH : String = '/gateway';
		
		private static const URL_PARAM_SEPARATOR : String = '?';
		
		private var _params      : Object;
		private var _host        : String;
		
		//Имя приложения в котором запущен компонент
		private var _appName : String;
		
		public function UnisAPIImplementation()
		{
			super();
		}
		
		public function get initialized() : Boolean
		{
			return _host != null;
		}
		
		public function get host() : String
		{
			return _host;
		}
		
		public function get gateway() : String
		{
			return _host + _appName + AMF_GATEWAY_PATH;
		}
		
		public function get params() : Object
		{
			return _params;
		}
		
		public function get mode() : String
		{
			return ApplicationMode.getMode( _params.mode );
		}
		
		/**
		 * Устанавливает новый режим работы приложения 
		 * @param mode
		 * 
		 */		
		public function setMode( mode : String ) : void
		{
			_params.mode = mode;
		}
		
		private function extractAppName( url : String ) : String
		{
			var spl : Array = url.slice( 10 ).split( '/' );
			
			return spl[ 1 ];
		}
		
		private function connect() : void
		{
			if ( initialized )
			{
				nc.connect( gateway );
			}
		}
		
		public function initFromFlashVars( stage : Stage ) : void
		{
			_params = stage.loaderInfo.parameters;
			
			/*var index : int;
			
			
			for ( var s : String in _params )
			{
				index = s.indexOf( 'defaultRootContext' ); 
				
				if ( index != -1 )
				{
				  _params.defaultRootContext = s.slice( index + 18 );
				  break;
				}
			}*/
			
			/*
			0 objectId = http://www.amg-bs.ru/2011/11/Objects/SemObject/ID_4570720
			1 defaultRootContext = http://127.0.0.1:8080/UnisExplorer/
			*/
			
			features = new IShowFeatures( _params );
			
			if ( _params.hasOwnProperty( 'defaultRootContext' ) )
			{
				var index : int = _params.defaultRootContext.indexOf( '/', 10 );
				
				_host    = _params.defaultRootContext.slice( 0, index + 1 );
				_appName = extractAppName(  _params.defaultRootContext );
				
				connect();
			}
		}
		
		public function initFromURL() : void
		{
			if ( ExternalInterface.available )
			{
				var url : String = /*ExternalInterface.call( "window.location.href.toString" );*/ 'http://127.0.0.1:8080/ServiceNote/IShow/IShow.html?objectId=http://www.amg-bs.ru/2011/11/Objects/SemObject/ID_23021,http://www.amg-bs.ru/2011/11/Objects/SemObject/ID_21964&defaultRootContext=http://127.0.0.1:8080/UnisExplorer/&agm=0'; 
				//,http://www.amg-bs.ru/2011/11/Objects/SemObject/ID_216772,http://www.amg-bs.ru/2011/11/Objects/SemObject/ID_216786
				if ( url.indexOf( URL_PARAM_SEPARATOR ) != -1 )
				{
					var spl : Array = url.split( URL_PARAM_SEPARATOR );
					
					var index : int = spl[ 0 ].indexOf( '/', 10 );
					
					_host    = spl[ 0 ].slice( 0, index + 1 );
					_params  = new URLVariables( spl[ 1 ] );
					_appName = extractAppName( _params.hasOwnProperty( 'defaultRootContext' ) ? _params.defaultRootContext : url );
					features = new IShowFeatures( _params ); 
					
					connect();
				}
			}
		}
		
		private function onGotGraph( responds : Object, call : Call ) : void
		{
			try
			{
				if ( ! responds )
				{
					throw new Error( 'Нет данных.', - 10 );
				}
				
				if ( responds.hasOwnProperty( 'errorMessage' ) && responds.errorMessage != null )
				{
					throw new Error( responds.errorMessage, - 200 );
				}
				
				if ( ! responds.hasOwnProperty( 'nodes' ) )
				{
					throw new Error( 'Ошибка UNIS API. Не найден список nodes.', -300 );
				}
				
				if ( ! responds.hasOwnProperty( 'edges' ) )
				{
					throw new Error( 'Ошибка UNIS API. Не найден список edges.', -400 );
				}
				
				dispatchEvent( new AMGGraphDataEvent( AMGGraphDataEvent.GRAPH_DATA, responds, call ) );
			}
			catch( error : Error )
			{
				dispatchEvent( new AMFErrorEvent( AMFErrorEvent.ERROR, error.message, error.errorID, call, AMFErrorLayer.COMMAND ) );
			}
		}
		
		public function getObjectCardUrl( objectId : String ) : String
		{
			return params.defaultRootContext + _appName + '.html#visCardObjectShowselectedObjectId=' + objectId + '&';
		}
		
		public function getShowGraph( objectId : String, defaultRootContext : String = null ) : void
		{
			if ( defaultRootContext == null )
			{
				defaultRootContext = _params.defaultRootContext;
			}
			
			//Если указан параметр alternative gate methods
			if ( _params.hasOwnProperty( 'agm' ) && _params.agm == 1 )
			{
				call( 'com.bs.amg.unis.ishow.ws.ShowSession.getShowGraphA', onGotGraph, defaultRootContext, objectId );
			}
			else
			{
				call( 'com.bs.amg.unis.ishow.ws.ShowSession.getShowGraph', onGotGraph, defaultRootContext, objectId );
			}
		}
		
		private function onGotAllIcons( responds : Object, call : Call ) : void
		{
			if ( responds is Array )
			{
				icons = new Array();
				
				var url : String;
				
				for each( url in responds )
				{
					icons.push( url.split( '::' )[ 1 ] );
				}
				
				dispatchEvent( new AMGAllIconsEvent( AMGAllIconsEvent.GET_ALL_ICONS, icons ) );
				return;
			}
			
			dispatchEvent( new AMFErrorEvent( AMFErrorEvent.ERROR, String( responds ), -100, call, AMFErrorLayer.COMMAND ) );
		}
		
		/**
		 * Метод возвращающий все иконки 
		 * @param rootPath
		 * 
		 */		
		public function getAllIcons( rootPath : String = null ) : void
		{
			if ( rootPath == null )
			{
				rootPath = _params.defaultRootContext;
			}
			
			call( 'com.bs.amg.unis.ishow.ws.ShowSession.getAllIcons', onGotAllIcons, rootPath );
		}
		
		/**
		 * Запрашивает данные ранее сохраненного графа из "Облака" 
		 * @param graphId - идентификатор графа
		 * 
		 */		
		public function loadGraph( graphId : String ) : void
		{
			call( 'com.bs.amg.unis.ishow.ws.ShowSession.loadGraph', onGotGraph, graphId );
		}
		
		private function onGraphSaved( responds : Object, call : Call ) : void
		{
			dispatchEvent( new AMGEvent( AMGEvent.GRAPH_SAVED ) );
		}
		
		/**
		 * Сохраняет граф в "Облако"
		 * @param name  - имя графа, для последующей загрузки из облака
		 * @param graph - сериализованные данные графа в виде объекта
		 * 
		 */		
		public function saveGraph( name : String, graph : Object, userName : String = null ) : void
		{
			if ( userName == null )
			{
				userName = _params.userName;
			}
			
			var json : String = JSON.stringify( graph );
			
			call( 'com.bs.amg.unis.ishow.ws.ShowSession.saveGraph', onGraphSaved, name, /*graph*/ json, userName );
		}
		
		private function onSavedGraphAsImage( responds : Object, call : Call ) : void
		{
			if ( responds )
			{
				dispatchEvent( new AMFErrorEvent( AMFErrorEvent.ERROR, String( responds ), -100, call, AMFErrorLayer.COMMAND ) );
				return;
			}
			
			dispatchEvent( new AMGEvent( AMGEvent.IMAGE_SAVED ) );
		}
		
		public function saveGraphAsImage( rootId : String, data : ByteArray ) : void
		{
			//var tt : Number = getTimer();
			
			var b : String = Base64.encode( data );
			
			//trace( 'Обработка к Base64', getTimer() - tt, 'ms' );
			
			
			call( 'com.bs.amg.unis.ishow.ws.ShowSession.saveImageWithId', onSavedGraphAsImage, rootId, b );
		}
		
		/**
		 * Ищет цепочку между объектами
		 * @param --objects массив идентификаторов объектов для которых необходимо найти цепочку или-- строка идентификаторов объектов разделенных запятой
		 * @param depth глубина поиска
		 * @param defaultRootContext корневая директория 
		 * 
		 */		
		public function getRelationships( objects : *, depth : int, defaultRootContext : String = null ) : void
		{
			if ( defaultRootContext == null )
			{
				defaultRootContext = _params.defaultRootContext;
			}
			
			//Если objects, строка идентификаторов объектов разделенных запятой, то преобразуем их в массив
			/*if ( objects is String )
			{
				objects = objects.split( ',' );
			}*/
			
			call( 'com.bs.amg.unis.ishow.ws.ShowSession.getRelationships', onGotGraph, objects, depth, defaultRootContext );
		}
		
		private function onGotClassRelations( responds : Object, call : Call ) : void
		{
			var items : Array = responds as Array;
			
			if ( items && items.length > 0 )
			{
				var relations : Array = new Array( items.length );
				var i         : int;
				
				for ( i = 0; i < items.length; i ++ )
				{
					relations[ i ] = new ClassRelation( items[ i ] );
				}
				
				dispatchEvent( new AMGGetClassRelationEvent( AMGGetClassRelationEvent.GET_CLASS_RELATIONS, relations ) );
				
				return;
			}
			
			dispatchEvent( new AMFErrorEvent( AMFErrorEvent.ERROR, 'Связи между выбранными объектами невозможны.', -100, call, AMFErrorLayer.COMMAND ) );
		}
		
		/**
		 * Возвращает список возможных связей между объектами 
		 * @param classId1 - тип первого объекта
		 * @param classId2 - тип второго объекта
		 * 
		 */		
		public function getClassRelations( classId1 : String, classId2 : String ) : void
		{
			call( 'com.bs.amg.unis.ishow.ws.ShowSession.getClassRelations', onGotClassRelations, classId1, classId2 );
		}
			
		private function onRelationAdded( responds : Object, call : Call ) : void
		{
			if ( responds )
			{
				dispatchEvent( new AMGAddRelationEvent( AMGAddRelationEvent.ADD_RELATION, String( responds ) ) );
				return;
			}
			
			dispatchEvent( new AMFErrorEvent( AMFErrorEvent.ERROR, 'Ошибка сохранения в базе данных.', -100, call, AMFErrorLayer.COMMAND ) ); 
		}
		
		/**
		 * Создает связь между объектами и возвращает Id, вновь созданной связи
		 * @param object1Id - идентификатор первого объекта
		 * @param object2Id - идентификатор второго объекта
		 * @param classRelationDbId - идентификатор выбранного типа связи 
		 * @param name - название связи
		 * 
		 */		
		public function addRelation( object1Id : String, object2Id : String, classRelationDbId : String, name : String ) : void
		{
			call( 'com.bs.amg.unis.ishow.ws.ShowSession.addRelation', onRelationAdded, object1Id, object2Id, classRelationDbId, name );
		}
		
		/**
		 * 
		 * @param responds = null, если удаление прошло успешно. Или строка с описанием ошибки, если произошла ошибка
		 * @param call
		 * 
		 */		
		private function onRelationRemoved( responds : Object, call : Call ) : void
		{
			if ( responds == null )
			{
				dispatchEvent( new AMGEvent( AMGEvent.RELATION_REMOVED ) );
				return;
			}
			
			dispatchEvent( new AMFErrorEvent( AMFErrorEvent.ERROR, String( responds ), -100, call, AMFErrorLayer.COMMAND ) );
		}
		
		/**
		 * Удаляет связь 
		 * @param relationDbId - идентификатор удаляемой связи
		 * 
		 */		
		public function removeRelation( relationDbId : String ) : void
		{
			call( 'com.bs.amg.unis.ishow.ws.ShowSession.removeRelation', onRelationRemoved, relationDbId );
		}
	}
}