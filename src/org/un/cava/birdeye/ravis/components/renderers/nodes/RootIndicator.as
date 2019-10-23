package org.un.cava.birdeye.ravis.components.renderers.nodes
{
	import flash.display.Shape;
	import flash.filters.GlowFilter;
	
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.easing.Linear;
	import org.libspark.betweenas3.tweens.ITween;
	
	public class RootIndicator extends Shape
	{
		private static const SIZE : Number = 4.0;
		private static const TIME : Number = 1.5;
		
		private var tween : ITween;
		
		public function RootIndicator()
		{
			super();
			
			graphics.beginFill( 0x0000ff, 0.85 );
			graphics.drawCircle( 0.0, 0.0, SIZE );
			graphics.endFill();
			
			
			
			var t : ITween = BetweenAS3.serial(
				
				BetweenAS3.tween( this, { transform : 
					{ colorTransform : {
						greenOffset: 0
					} 
					}
				}, { transform : 
					{ colorTransform : {
						greenOffset: 255
					} 
					}
				}
					,TIME, Linear.easeIn ),
				
				BetweenAS3.tween( this, { transform : 
					{ colorTransform : {
						greenOffset: 255
					} 
					}
				}, { transform : 
					{ colorTransform : {
						greenOffset: 0
					} 
					}
				}
					,TIME, Linear.easeOut )
				
				
			);
										  
			tween = BetweenAS3.repeat( t, uint.MAX_VALUE );
			tween.play();
			
			filters = [ new GlowFilter( 0x000000, 1.0, 8.0, 8.0 ) ];
		}
	}
}