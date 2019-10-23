package com.bs.amg.features
{
	public class IShowFeatures
	{
		/*----------------------------------Пункты контекстного меню графа-------------------------------------------------------*/
		
		/**
		 * Создать связь 
		 */		
		public static const CREATE_EDGE : String = 'CREATE_EDGE';
		
		/**
		 * Удалить связь 
		 */		
		public static const REMOVE_EDGE : String = 'REMOVE_EDGE';
		
		/**
		 * Удалить узел 
		 */		
		public static const REMOVE_NODE : String = 'REMOVE_NODE';
		
		/**
		 * Выбрать все узлы 
		 */		
		public static const SELECT_ALL  : String = 'SELECT_ALL';
		
		/**
		 * Выбрать все узлы определенной сети 
		 */		
		public static const SELECT_ALL_NET_NODES : String = 'SELECT_ALL_NET_NODES';
		
		/**
		 * Выделить все связи связанные с объектом 
		 */		
		public static const SELECT_ALL_RELATIONAL_EDGES : String = 'SELECT_ALL_RELATIONAL_EDGES';
		
		/**
		 * Сделать узел корневым 
		 */		
		public static const SET_NODE_AS_ROOT : String = 'SET_NODE_AS_ROOT';
		
		/**
		 * Отмена текущей операции 
		 */		
		public static const CANCEL      : String = 'CANCEL';
		
		/**
		 * Развернуть узел 
		 */		
		public static const EXPAND      : String = 'EXPAND';
		
		/**
		 * Отобразить информацию об объекте 
		 */		
		public static const SHOW_INFO   : String = 'SHOW_INFO';
		
		/**
		 * Увеличить масштаб 
		 */		
		public static const ZOOM_IN : String = 'ZOOM_IN';
		
		/**
		 * Уменьшить масштаб 
		 */		
		public static const ZOOM_OUT : String = 'ZOOM_OUT';
		
		/**
		 * Обновить 
		 */		
		public static const REFRESH : String = 'REFRESH';
		
		/**
		 * Свойства узла 
		 */		
		public static const NODE_PROPERTIES : String = 'NODE_PROPERTIES';
		
		/**
		 * Свойства связи 
		 */		
		public static const EDGE_PROPERTIES : String = 'EDGE_PROPERTIES';
		
		/**
		 * Сгрупировать выделенные объекты 
		 */		
		public static const GROUP_SELECTED_NODES : String = 'GROUP_SELECTED_NODES';
		
		/**
		 * Загрузить объект асоциированный с узлом 
		 */		
		public static const DOWNLOAD : String = 'DOWNLOAD';
		
		/**
		 * Открыть изображение 
		 */		
		public static const OPEN_IMAGE : String = 'SHOW_PHOTO';
		
		/**
		 * Привязать изображение графа
		 */		
		public static const LINK_OBJECT_TO_GRAPH_IMAGE : String = 'LINK_OBJECT_TO_GRAPH_IMAGE';
		
		/*----------------------------------------------------------------------------------------------------------------*/
		
		/*-----------------------------------Остальной функционал----------------------------------------------------------*/
		
		/**
		 * Функционал сохранения графа в каком либо из форматов 
		 */		
		public static const SAVE_GRAPH : String = 'SAVE_GRAPH';
		
		/**
		 * Сохранить граф в базе данных 
		 */		
		public static const SAVE_GRAPH_IN_DATABASE : String = 'SAVE_GRAPH_IN_DATABASE';
		
		/**
		 * Сохранить граф на компьютере как изображение PNG 
		 */		
		public static const SAVE_GRAPH_AS_PNG_IMAGE : String = 'SAVE_GRAPH_AS_PNG_IMAGE';
		
		/**
		 * Сохранить граф как изображение JPEG 
		 */		
		public static const SAVE_GRAPH_AS_JPEG_IMAGE : String = 'SAVE_GRAPH_AS_JPEG_IMAGE';
		
		/**
		 * Функционал отмены действий 
		 */		
		public static const UNDO_AND_REDO : String = 'UNDO_AND_REDO';
		
		/**
		 * Функционал прокрутки "лапкой" 
		 */		
		public static const SCROLL_MODE : String = 'SCROLL_MODE';
		
		/**
		 * Анимировать направление связей 
		 */		
		public static const ANIMATE_DIRECTION_RELATIONS : String = 'ANIMATE_DIRECTION_RELATIONS';
		
		/**
		 * Функционал навигатор 
		 */		
		public static const NAVIGATOR : String = 'NAVIGATOR';
		
		/**
		 * Изменять раскладку 
		 */		
		public static const CHANGE_LAYOUT : String = 'CHANGE_LAYOUT';
		
		/**
		 * Функционал настройки раскладки 
		 */		
		public static const LAYOUT_SETTINGS : String = 'LAYOUT_SETTINGS';
		
		/**
		 * Изменять длину связи раскладки вручную
		 */		
		public static const CHANGLE_LAYOUT_LINK_LENGTH : String = 'CHANGLE_LAYOUT_LINK_LENGTH';
		
		/**
		 * Изменить параметр оптимальная длина связи для раскладки 
		 */		
		public static const CHANGE_LAYOUT_AUTO_FIT : String = 'CHANGE_LAYOUT_AUTO_FIT';
		
		/**
		 * Изменить параметр "подбирать размер связи под размер рабочей области" для раскладки 
		 */		
		public static const CHANGE_LAYOUT_FIT_TO_WINDOW : String = 'CHANGE_LAYOUT_FIT_TO_WINDOW';
		
		/**
		 * Перерисовывать объект при раскрытии 
		 */		
		public static const CHANGE_REDRAW_WHEN_EXPAND : String = 'REDRAW_WHEN_EXPAND';
		
		/**
		 * Изменить параметр глубина раскрытия объектов 
		 */		
		public static const CHANGE_EXPAND_DEPTH : String = 'CHANGE_EXPAND_DEPTH';
		
		/**
		 * Анимация перерисовки графа 
		 */		
		public static const CHANGE_REDRAW_ANIMATION : String = 'REDRAW_ANIMATION';
		
		/**
		 * Показывать/не показывать имена связей 
		 */		
		public static const CHANGE_SHOW_EDGE_LABELS : String = 'CHANGE_SHOW_EDGE_LABELS';
		
		/**
		 * Изменять масштаб 
		 */		
		public static const CHANGE_SCALE : String = 'CHANGE_SCALE';
		
		/**
		 * Функционал поиска 
		 */		
		public static const SEARCH : String = 'SEARCH';
		
		/**
		 * Функционал отображения информации о приложении 
		 */		
		public static const APPLICATION_INFORMATION : String = 'APPLICATION_INFORMATION';
		
		/**
		 * Выделение связей 
		 */		
		public static const EDGES_SELECTION : String = 'EDGES_SELECTION';
		
		/**
		 * Выделение узлов 
		 */		
	    public static const NODES_SELECTION : String = 'NODES_SELECTION';
		
		/**
		 * Функционал выделения рамочкой 
		 */		
		public static const RECT_SELECTION : String = 'RECT_SELECTION';
		
		/*----------------------------------------------------------------------------------------------------------------*/
		
		/**
		 * Перечисление всех доступных возможностей 
		 */		
		private static const features : Vector.<String> = Vector.<String>( [
		    
			CREATE_EDGE,
			REMOVE_EDGE,
			REMOVE_NODE,
			SELECT_ALL,
			SELECT_ALL_NET_NODES,
			SELECT_ALL_RELATIONAL_EDGES,
			SET_NODE_AS_ROOT,
			/*CANCEL,*/
			EXPAND,
			SHOW_INFO,
			/*ZOOM_IN,
			ZOOM_OUT,*/
			REFRESH,
			NODE_PROPERTIES,
			EDGE_PROPERTIES,
			GROUP_SELECTED_NODES,
			DOWNLOAD,
			OPEN_IMAGE,
			LINK_OBJECT_TO_GRAPH_IMAGE,
			
			SAVE_GRAPH,
			SAVE_GRAPH_IN_DATABASE,
			SAVE_GRAPH_AS_PNG_IMAGE,
			SAVE_GRAPH_AS_JPEG_IMAGE,
			UNDO_AND_REDO,
			SCROLL_MODE, 
			ANIMATE_DIRECTION_RELATIONS,
			NAVIGATOR,
			CHANGE_LAYOUT,
			LAYOUT_SETTINGS,
			CHANGLE_LAYOUT_LINK_LENGTH,
			CHANGE_LAYOUT_AUTO_FIT,
			CHANGE_LAYOUT_FIT_TO_WINDOW,
			CHANGE_REDRAW_WHEN_EXPAND,
			CHANGE_EXPAND_DEPTH,
			CHANGE_REDRAW_ANIMATION,
			CHANGE_SHOW_EDGE_LABELS,
			CHANGE_SCALE,
			SEARCH,
			APPLICATION_INFORMATION,
			
			EDGES_SELECTION,
			NODES_SELECTION,
			RECT_SELECTION
			
		                                                         ] );
		
		
		private static const PERMISSIONS_SEPARATOR : String = ',';
		
		/**
		 * Перечисление того что разрешено/запрещено
		 * Например allow[ EDGES_SELECTION ] вернет true, если разрешено. false если нет. 
		 */		
		private var _allow  : Object;
		
		public function IShowFeatures( params : Object )
		{
		  var featureId  : String;
		  var permisions : Array;
		  
		  /*
		  Все разрешено, кроме запрещенного
		  */
		  if ( params.hasOwnProperty( 'denied' ) )
		  {
			  initAllowList( true );
			  
			  permisions = String( params.denied ).toUpperCase().split( PERMISSIONS_SEPARATOR );
			  
			  for each( featureId in permisions )
			  {
				  if ( _allow.hasOwnProperty( featureId ) )
				  {
					  _allow[ featureId ] = false; 
				  }
			  }
		  }
		  /*
		  Все запрещено кроме разрешенного
		  */
		  else if ( params.hasOwnProperty( 'allow' ) )
		  {
			  initAllowList( false );
			  
			  permisions = String( params.allow ).toUpperCase().split( PERMISSIONS_SEPARATOR );
			  
			  for each( featureId in permisions )
			  {
				  if ( _allow.hasOwnProperty( featureId ) )
				  {
					  _allow[ featureId ] = true; 
				  }
			  }
		  }
		  /*
		  Если ничего не указано, то все разрешено
		  */
		  else
		  {
			  initAllowList( true );
		  }
		  
		}
		
		private function initAllowList( value : Boolean ) : void
		{
			_allow = new Object();
			
			var featureId : String;
			
			for each( featureId in features )
			{
				_allow[ featureId ] = value;
			}
		}
		
		/**
		 * Проверяет разрешена ли указанная возможность 
		 * @param featureId
		 * @return 
		 * 
		 */		
		public function isAllow( featureId : String ) : Boolean
		{
			if ( _allow.hasOwnProperty( featureId ) )
			{
				return _allow[ featureId ];
			}
			
			return false;
		}
		
		/**
		 * Проверяет запрещена ли указанная возможность 
		 * @param featureId
		 * @return 
		 * 
		 */		
		public function isDenied( featureId : String ) : Boolean
		{
			return ! isAllow( featureId );
		}
	}
}