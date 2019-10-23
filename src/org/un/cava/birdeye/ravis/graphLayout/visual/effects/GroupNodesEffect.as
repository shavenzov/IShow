package org.un.cava.birdeye.ravis.graphLayout.visual.effects
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.easing.Linear;
	import org.libspark.betweenas3.events.TweenEvent;
	import org.libspark.betweenas3.tweens.ITween;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	
	public class GroupNodesEffect extends EventDispatcher
	{
		/**
		 * Время анимации в секундах 
		 */		
		private static const ANIMATION_TIME : Number = 0.5;
		
		public function GroupNodesEffect()
		{
			super();
		}
		
		/**
		 * Список сворачиваемых/разворачиваемых узлов 
		 */		
		private var vnodes : Vector.<IVisualNode>;
		
		/**
		 * Главный анимационный твин 
		 */		
		private var tween  : ITween;
		
		/**
		 * Запускает анимацию группировки объектов 
		 * @param mainNode - узел в который сворачиваются другие узлы
		 * @param nodes    - сворачиваемые узлы
		 * 
		 */		
		public function group( mainNode : IVisualNode, vnodes : Vector.<IVisualNode> ) : void
		{
			this.vnodes = vnodes;
			
			var i       : int   = 0;
			var toPoint : Point = new Point( mainNode.x, mainNode.y );
			
			var tweens : Array = new Array( vnodes.length );
			
			for( i = 0; i < vnodes.length; i ++ )
			{
				tweens[ i ] = BetweenAS3.tween( vnodes[ i ], { x : toPoint.x, y : toPoint.y }, { x : vnodes[ i ].x, y : vnodes[ i ].y }, ANIMATION_TIME, Linear.easeIn );
			}
			
		    tween = BetweenAS3.parallelTweens( tweens );
			
			setTweensListeners();
			
			tween.play();
		}
		
		private function onTweenUpdate( e : TweenEvent ) : void
		{
			var vnode : IVisualNode;
			
			for each( vnode in vnodes )
			{
				vnode.commit();
			}
		}
		
		private function onTweenComplete( e : TweenEvent ) : void
		{
			unsetTweensListeners();
			tween = null;
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function setTweensListeners() : void
		{
			tween.addEventListener( TweenEvent.UPDATE, onTweenUpdate );
			tween.addEventListener( TweenEvent.COMPLETE, onTweenComplete );	
		}
		
		private function unsetTweensListeners() : void
		{
			tween.removeEventListener( TweenEvent.UPDATE, onTweenUpdate );
			tween.removeEventListener( TweenEvent.COMPLETE, onTweenComplete );
		}
	}
}