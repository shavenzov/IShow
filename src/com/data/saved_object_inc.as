protected var _data : Object;

public function get data():Object
{
	return _data;
}

public function set data( value : Object ) : void
{
	if ( _data != value )
	{
		_data = value;
		setDefaults();
		save();
		dispatchEvent( new Event( Event.CHANGE ) );
	}
}

/**
 * Загружает ранее сохраненные данные связанные с этим объектом 
 * 
 */		
protected function load() : void
{
	var so : SharedObject = SharedObject.getLocal( storageName );
	
	_data = so.data.data;
	setDefaults();
}

/**
 * Сохраняет данные связанные с этим объектом 
 * 
 */		
protected function save() : void
{
	var so : SharedObject = SharedObject.getLocal( storageName );
	so.data.data = _data;
	
	so.flush();
}

private var _storageName : String;

/**
 * Имя локального хранилища для хранения данных связанных с этим объектом 
 * @return 
 * 
 */		
private function get storageName() : String
{
	if ( ! _storageName )
	{
		_storageName = StringUtils.replace( getQualifiedClassName( this ), ':', '_' );
	}
	
	return _storageName;
}

/**
 * Установка свойств по умолчанию 
 * 
 */		
protected function setDefaults() : void
{
	if ( ! _data )
	{
		_data = new Object();
	}
}