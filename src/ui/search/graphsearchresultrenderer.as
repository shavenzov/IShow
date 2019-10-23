import mx.controls.Image;
import mx.core.UIComponent;

import org.un.cava.birdeye.ravis.assets.Assets;
import org.un.cava.birdeye.ravis.components.renderers.RendererIconFactory;
import org.un.cava.birdeye.ravis.components.renderers.nodes.TextIconNodeRenderer;
import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
import org.un.cava.birdeye.ravis.graphLayout.data.INode;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

private var icon : UIComponent;

override public function set data( value : Object ) : void
{
	super.data = value;
	
	var d    : Object;
	
	if ( icon )
	{
		iconGroup.removeElement( icon );
		icon = null;
	}
	
	if ( data is IVisualNode )
	{
		var node : IVisualNode  = IVisualNode( data ); 
		    d = node.data;
		
		icon = RendererIconFactory.createIcon( d.icon, TextIconNodeRenderer.MAX_ICON_SIZE );
		iconGroup.addElementAt( icon, 0 );
		
		nameLabel.text   = d.name;
		toolTip   = d.desc;
		
		return;
	}
	
	if ( data is IVisualEdge )
	{
		var edge : IVisualEdge = IVisualEdge( data );
		    d = edge.data;
		
		icon = new Image();
		Image( icon ).source = Assets.EDGE_ICON;
		iconGroup.addElementAt( icon, 0 );
		
		nameLabel.text = d.label;
		toolTip = d.text;
	}
}