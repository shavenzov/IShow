import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;

private var _vg : IVisualGraph;

public function get vg() : IVisualGraph
{
	return _vg;
}

public function set vg( value : IVisualGraph ) : void
{
	if ( _vg != value )
	{
		_vg = value;
		invalidateProperties();
	}
}