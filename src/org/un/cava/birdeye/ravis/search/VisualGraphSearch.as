package org.un.cava.birdeye.ravis.search
{
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	import mx.utils.StringUtil;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.effects.BlinkEffect;

	public class VisualGraphSearch
	{
		/**
		 * Граф в котором будет произведен поиск 
		 */		
		private var _vg : IVisualGraph;
		
		/**
		 * Строка поиска 
		 */		
		private var _queryString : String;
		
		/**
		 * Список найденных узлов 
		 */		
		private var _resultNodes : Array;
		
		/**
		 * Осуществлять поиск по узлам 
		 */		
		private var _searchInNodes : Boolean;
		
		/**
		 * Список найденных связей 
		 */		
		private var _resultEdges : Array;
		
		/**
		 * Осуществлять поиск по связям 
		 */		
		private var _searchInEdges : Boolean;
		
		/**
		 * Учитывать ли регистр символов при поиске 
		 */		
		private var _caseSensitive : Boolean;
		
		/**
		 * Искать фразу целиком 
		 */		
		private var _wholeWord : Boolean;
		
		public function VisualGraphSearch( vg : IVisualGraph, queryString : String = null, searchInNodes : Boolean = true, searchInEdges : Boolean = true, caseSensitive : Boolean = false, wholeWord : Boolean = false )
		{
		  _vg                = vg;
		  this.queryString   = queryString;
		  this.searchInNodes = searchInNodes;
		  this.searchInEdges = searchInEdges;
		  this.caseSensitive = caseSensitive;
		  this.wholeWord     = wholeWord;
		}
		
		/**
		 * Осуществлять поиск по узлам 
		 */	
		public function get searchInNodes() : Boolean
		{
			return _searchInNodes;
		}
		
		public function set searchInNodes( value : Boolean ) : void
		{
			_searchInNodes = value;
		}
		
		public function get searchInEdges() : Boolean
		{
			return _searchInEdges;
		}
		
		/**
		 * Осуществлять поиск по связям 
		 */	
		public function set searchInEdges( value : Boolean ) : void
		{
			_searchInEdges = value;
		}
		
		/**
		 * Учитывать ли регистр символов при поиске 
		 */
		public function get caseSensitive() : Boolean
		{
			return _caseSensitive;
		}
		
		public function set caseSensitive( value : Boolean ) : void
		{
			_caseSensitive = value;
		}
		
		/**
		 * Искать фразу целиком 
		 */	
		public function get wholeWord() : Boolean
		{
			return _wholeWord;
		}
		
		public function set wholeWord( value : Boolean ) : void
		{
			_wholeWord = value;
		}
		
	    public function get queryString() : String
		{
			return _queryString;
		}
		
		public function set queryString( value : String ) : void
		{
			_queryString = StringUtil.trim( value );
		}
			
		/**
		 * Список найденных узлов 
		 */	
		public function get resultNodes() : Array
		{
			return _resultNodes;
		}
		
		/**
		 * Список найденных узлов в виде словарика 
		 * @return 
		 * 
		 */		
		private var _resultDictionaryNodes : Dictionary;
		
		public function get resultDictionaryNodes() : Dictionary
		{
			return _resultDictionaryNodes;
		}
		
		/**
		 * Список найденных связей 
		 */	
		public function get resultEdges() : Array
		{
			return _resultEdges;
		}
		
		/**
		 * Список найденных связей в виде словарика 
		 * @return 
		 * 
		 */		
		private var _resultDictionaryEdges : Dictionary;
		
		public function get resultDictionaryEdges() : Dictionary
		{
			return _resultDictionaryEdges;
		}
		
		/**
		 * Список найденных связей и узлов. ( Все вместе ) 
		 * @return 
		 * 
		 */		
		public function get result() : Array
		{
			var r : Array = _resultNodes.slice();
			    r = r.concat( _resultEdges );
				
			return r;	
		}
		
		/**
		 * Общее количество найденных совпадений 
		 * @return 
		 * 
		 */		
		public function get numResults() : uint
		{
			return _resultNodes.length + _resultEdges.length;
		}
		
		/**
		 * Ищет
		 * @param query
		 * @param nodes
		 * @param edges
		 * @param caseSensitive
		 * @param wholeWord
		 * @return 
		 * 
		 */		
		public function search() : void 
		{
		  	_resultNodes = new Array();
			_resultEdges = new Array();
			_resultDictionaryNodes = new Dictionary();
			_resultDictionaryEdges = new Dictionary();
			
			var data  : Object;
			var match : Boolean;
			
			if ( _searchInNodes )
			{
				var node : IVisualNode;
				
				for each( node in _vg.vnodes )
				{
					data = node.data;
					
					//В узлах ищем по name и desc
					
					//name
					if ( data.hasOwnProperty( 'name' ) )
					{
						match = stringMatch( data.name );
					}
					
					if ( ! match )
					{
						//desc
						if ( data.hasOwnProperty( 'desc' ) )
						{
							match = stringMatch( data.desc );
						}
					}
					
					if ( match )
					{
						_resultNodes.push( node );
						_resultDictionaryNodes[ node ] = node;
					}
				}
			}
			
			if ( _searchInEdges )
			{
				var edge : IVisualEdge;
				
				for each( edge in _vg.vedges )
				{
					data = edge.data;
					
					//В связях ищем по label и desc
					
					//label
					if ( data.hasOwnProperty( 'label' ) )
					{
						match = stringMatch( data.label );
					}
					
					//desc
					if ( ! match )
					{
						if ( data.hasOwnProperty( 'desc' ) )
						{
							match = stringMatch( data.desc );
						}
					}
					
					if ( match )
					{
						_resultEdges.push( edge );
						_resultDictionaryEdges[ edge ] = edge;
					}
				}
			}
			
			/*_resultNodes.sort();
			_resultEdges.sort();*/
			
			_vg.selectedNodes = _resultDictionaryNodes;
			_vg.selectedEdges = _resultDictionaryEdges;
		}
		
		/**
		 * Определяет есть ли в указанной строке queryString 
		 * @param where - строка в которой будет произеден поиск
		 * @return true - если строка найдена
		 *         false- если не найдена
		 * 
		 */		
		private function stringMatch( where : String ) : Boolean
		{
			var what : String = _queryString;
			
			//Если поиск без учета регистра
			if ( ! _caseSensitive )
			{
				what  = what.toLocaleLowerCase();
				where = where.toLocaleLowerCase();
			}
			
			//Если искать слово целиком
			if ( _wholeWord )
			{
				var words : Array = where.split( ' ' );
				var word  : String;
				
				for each( word in words )
				{
					//trace( word, what );
					
					if ( word == what )
					{
						return true;
					}
				}
			}
			else
			{
				return where.indexOf( what ) != -1;
			}
			
			return false;
		}
		
		private var blink : BlinkEffect;
		
		/**
		 * Запускает анимацию "Мигания" указанного объекта, узла или связи
		 * Если узла или связи не видно в данный момент на экране, прокручивает до него 
		 * @param obj
		 * 
		 */		
		public function highlightObject( obj : Object ) : void
		{
			var view    : UIComponent;
			
			if ( obj is IVisualNode )
			{
				view    = IVisualNode( obj ).view;
			}
			else if ( obj is IVisualEdge )
			{
				view    = UIComponent( IVisualEdge( obj ).edgeView );
			}
			
			if ( view )
			{
				if ( blink )
				{
					blink.stop();
				}
				
				blink = new BlinkEffect();
				blink.start( view );
				
				_vg.scrollToObject( obj );
			}
		}
	}
}