package org.un.cava.birdeye.ravis.graphLayout.visual.menu
{
	import com.bs.amg.UnisAPI;
	import com.bs.amg.features.IShowFeatures;
	
	import flash.display.DisplayObjectContainer;
	
	import mx.controls.Menu;
	import mx.core.FlexGlobals;
	
	import org.un.cava.birdeye.ravis.assets.Assets;
	import org.un.cava.birdeye.ravis.components.renderers.nodes.INodeRenderer;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.VisualGraph;

	public class VisualGraphMenu
	{
		
		
		/**
		 * Создает контекстное меню для указанного узла 
		 * @param node
		 * @return ссылка на экземпляр Menu, для отображения
		 * 
		 */		
		public static function createNodeMenu( node : IVisualNode ) : Menu
		{
			var features : IShowFeatures = UnisAPI.impl.features;
			
			var nodeRenderer : INodeRenderer = INodeRenderer( node.view );
			
			var items : Array = new Array();
				
			    //Только если узел еще не раскрыт
			    if ( ! node.data.hasOwnProperty( 'expanded' ) && ! node.data.expanded )
				{
					if ( features.isAllow( IShowFeatures.EXPAND ) )
					{
						items.push( { label : "Раскрыть", id : IShowFeatures.EXPAND, source : node, enabled : ! nodeRenderer.progress, icon : Assets.EXPAND_ICON } );	
					}
				}
		        
				if ( features.isAllow( IShowFeatures.SHOW_INFO ) )
				{
					items.push( { label : "Открыть карточку", id : IShowFeatures.SHOW_INFO, source : node, icon : Assets.FORM_ICON_SMALL } );
				}
				
			    //Если есть ссылка для скачивания
				if ( node.node.pathToFile )
				{
					if ( features.isAllow( IShowFeatures.DOWNLOAD ) )
					{
						items.push( { label : "Загрузить", id : IShowFeatures.DOWNLOAD, source : node, icon : Assets.DOWNLOAD_SMALL } );
					}
				}
				
				//Если пиктограмма узла увеличена, то отображаем пункт меню 'Открыть фото'
				if ( INodeRenderer( node.node.vnode.view ).iconResized )
				{
					if ( features.isAllow( IShowFeatures.OPEN_IMAGE ) )
					{
						items.push( { label : 'Открыть фото', id : IShowFeatures.OPEN_IMAGE, source : node } );
					}
				}
				
				if ( features.isAllow( IShowFeatures.EXPAND ) || features.isAllow( IShowFeatures.SHOW_INFO ) || features.isAllow( IShowFeatures.DOWNLOAD ) || features.isAllow( IShowFeatures.OPEN_IMAGE ) )
				{
					if ( items.length > 0 )
					items.push( { type : "separator" } );
				}
				
				if ( features.isAllow( IShowFeatures.CREATE_EDGE ) )
				{
					items.push( { label : "Создать связь", id : IShowFeatures.CREATE_EDGE, source : node, icon : Assets.EDGE_ICON } );
				}
				
				//Если для раскладки необходим корневой элемент
				if ( node.vgraph.layouter.needRoot )
				{
					if ( features.isAllow( IShowFeatures.SET_NODE_AS_ROOT ) )
					{
						items.push( { label : "Сделать главным", id : IShowFeatures.SET_NODE_AS_ROOT, source : node, enabled : node.vgraph.currentRootVNode != node, icon : Assets.ROOT_SMALL } );
					}
				}
				
				if ( features.isAllow( IShowFeatures.REMOVE_NODE ) )
				{
					items.push( { label : "Удалить", id : IShowFeatures.REMOVE_NODE, source : node, icon : Assets.DELETE_SMALL } );
				}
				
				
				if ( features.isAllow( IShowFeatures.CREATE_EDGE ) || features.isAllow( IShowFeatures.SET_NODE_AS_ROOT ) || features.isAllow( IShowFeatures.REMOVE_NODE ) )
				{
					if ( items.length > 0 )
					items.push( { type : "separator" } );
				}
				
				if ( features.isAllow( IShowFeatures.SELECT_ALL_NET_NODES ) )
				{
					items.push( { label : "Выделить все объекты", id : IShowFeatures.SELECT_ALL_NET_NODES, source : node, icon : Assets.SELECT_ALL_SMALL } );
				}
				
				if ( features.isAllow( IShowFeatures.SELECT_ALL_RELATIONAL_EDGES ) )
				{
					items.push( { label : "Выделить все связи связанные с объектом", id : IShowFeatures.SELECT_ALL_RELATIONAL_EDGES, source : node, icon : Assets.SELECT_RELATIONAL_EDGES_SMALL } );	
				}
							
			
			//Схлопнуть выделенные объекты
			if ( node.vgraph.noSelectedNodes > 1 )
			{
				if ( features.isAllow( IShowFeatures.GROUP_SELECTED_NODES ) )
				{
					items.push( { label : "Объединить", id : IShowFeatures.GROUP_SELECTED_NODES, source : node, icon : Assets.UNION_SMALL } );
				}
			}
			
			if ( features.isAllow( IShowFeatures.LINK_OBJECT_TO_GRAPH_IMAGE ) )
			{
				items.push( { label : "Привязать изображение графа", id : IShowFeatures.LINK_OBJECT_TO_GRAPH_IMAGE, source : node, icon : Assets.LINK_IMAGE } );
			}
			
			if ( features.isAllow( IShowFeatures.SELECT_ALL_NET_NODES ) || features.isAllow( IShowFeatures.SELECT_ALL_RELATIONAL_EDGES ) || features.isAllow( IShowFeatures.GROUP_SELECTED_NODES ) || features.isAllow( IShowFeatures.LINK_OBJECT_TO_GRAPH_IMAGE ) )
			{
				if ( items.length > 0 )
				items.push( { type : "separator" } );
			}
			
			if ( features.isAllow( IShowFeatures.NODE_PROPERTIES ) )
			{
				items.push( { label : "Редактировать...", id : IShowFeatures.NODE_PROPERTIES, source : node, icon : Assets.EDIT_SMALL } );
			}
			
			if ( items.length == 0 )
				return null;
			
			removeEndSeparators( items );
			
			return Menu.createMenu( DisplayObjectContainer( FlexGlobals.topLevelApplication ), items );
		}
		
		/**
		 * Создает контекстное меню для указанной связи 
		 * @param edge
		 * @return ссылка на экземпляр Menu, для отображения
		 * 
		 */		
		public static function createEdgeMenu( edge : IVisualEdge ) : Menu
		{
			var features : IShowFeatures = UnisAPI.impl.features;
			
			var items : Array = new Array();
			
			if ( features.isAllow( IShowFeatures.REMOVE_EDGE ) )
			{
				items.push( { label : "Удалить", id : IShowFeatures.REMOVE_EDGE, source : edge, icon : Assets.DELETE_SMALL } );
				items.push( { type : "separator" } );
			}
			
			
			if ( features.isAllow( IShowFeatures.EDGE_PROPERTIES ) )
			{
				items.push( { label : "Редактировать...", id : IShowFeatures.EDGE_PROPERTIES, source : edge, icon : Assets.EDIT_SMALL } );
			}
			
			if ( items.length == 0 )
				return null;
			
			removeEndSeparators( items );
			
			return Menu.createMenu( DisplayObjectContainer( FlexGlobals.topLevelApplication ), items );
		}
		
		/**
		 * Создает контекстное меня для рабочей области 
		 * @param vg - visual graph для которого создается меню
		 * @return ссылка на экземпляр Menu, для отображения
		 * 
		 */		
		public static function createBackgroundMenu( vg : IVisualGraph ) : Menu
		{
			var features : IShowFeatures = UnisAPI.impl.features;
			var items    : Array = new Array();
			    
			if ( features.isAllow( IShowFeatures.CHANGE_SCALE ) )
			{
				items.push( { label : "Увеличить   	+", id : IShowFeatures.ZOOM_IN, source : vg, enabled : vg.scale != VisualGraph.MAX_SCALE, icon : Assets.ZOOM_IN_SMALL } );
				items.push( { label : "Уменьшить              -", id : IShowFeatures.ZOOM_OUT, source : vg, enabled : vg.scale != VisualGraph.MIN_SCALE, icon : Assets.ZOOM_OUT_SMALL } );
			}
			
			if ( features.isAllow( IShowFeatures.CHANGE_SCALE ) )
			{
				if ( items.length > 0 )
				items.push( { type : "separator" } );
			}
			
			if ( features.isAllow( IShowFeatures.SELECT_ALL ) )
			{
				items.push( { label : "Выделить всё  	ctrl+A", id : IShowFeatures.SELECT_ALL, source : vg, icon : Assets.SELECT_ALL_SMALL } );
			}
				
			if ( features.isAllow( IShowFeatures.REFRESH ) )
			{
				items.push( { label : "Перерисовать         ctrl+R", id : IShowFeatures.REFRESH, source : vg, icon : Assets.REFRESH_SMALL } );
			}
			
			//Схлопнуть выделенные объекты
			if ( vg.noSelectedNodes > 1 )
			{
				if ( features.isAllow( IShowFeatures.GROUP_SELECTED_NODES ) )
				{
					items.push( { type : "separator" } );
					items.push( { label : "Объединить            ctrl+G", id : IShowFeatures.GROUP_SELECTED_NODES, source : vg, icon : Assets.UNION_SMALL } );
				}	
			}
			
			if ( items.length == 0 )
				return null;
			
			removeEndSeparators( items );
			
			return Menu.createMenu( DisplayObjectContainer( FlexGlobals.topLevelApplication ), items );
		}
		
		private static function removeEndSeparators( items : Array ) : void
		{
			for ( var i : int = items.length - 1; i >= 0; i -- )
			{
				if ( items[ i ].type == 'separator' )
				{
					items.splice( i );
				}
				else
				{
					break;
				}
			}
		}
		
		/**
		 * Создает меню отменяющее создание связи ( во время процесса интерактивного создания связи ) 
		 * @return ссылка на экземпляр Menu, для отображения
		 * 
		 */		
		public static function createCancelEdgeCreatingMenu() : Menu
		{
			var items : Array = [
				{ label : "Отменить", id : IShowFeatures.CANCEL, icon : Assets.CANCEL_SMALL }
			];
			
			return Menu.createMenu( DisplayObjectContainer( FlexGlobals.topLevelApplication ), items );
		}
	}
}