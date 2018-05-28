package effect
{
	import laya.display.Node;
	import laya.events.Event;
	import laya.ui.Component;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.TimeLine;
	import laya.utils.Tween;
	
	import view.UIMgr;

	/**
	 * 时间线管理类
	 */	
	public class EffectUtils
	{
		public static var CURRENTWIDTH:Number =0;
		public static var CURRENTHEIGHT:Number =0;
		
		/**是否在运动**/
		private static var _isMove:Boolean = false;
		/**时间线动画类**/
		private static var _timeLine:TimeLine = new TimeLine();
		public function EffectUtils()
		{
			
		}
		
		/**
		 * 缓动隐藏 
		 * @param target
		 * @param complete
		 */		
		public static function alphaHideEffect(target:Component,complete:Handler,time:Number = 500):void
		{
			if(_isMove)
				return;
			_isMove = true;
			_timeLine.addLabel("sacle1.1",0).to(target,{alpha:0},time,null,0);
			_timeLine.play(0,false);
			_timeLine.on(Event.COMPLETE,EffectUtils,EffectUtils.onTLAComplete,[complete,target]);
		}
		
		private static function onTLAComplete(complete:Handler,target:Component):void
		{
			_isMove = false;		
			_timeLine.reset();
			target.alpha = 1;
			target.visible = false;
			Laya.timer.once(1000,EffectUtils,function():void{
				complete != null && complete.run();
			});
			_timeLine.off(Event.COMPLETE,EffectUtils,EffectUtils.onTLAComplete);
		}
		
		/**缓动结束**/
		private static function onTimeLineComplete(complete:Handler=null,target:Component=null,evt:Event =null):void
		{
			_isMove = false;		
			_timeLine.reset();
			complete&& complete.run();
		}
		
		/**
		 * 缓动打开弹窗 
		 * @param target
		 */		
		public static function openDialog(target:Component, compH:Handler = null):void
		{
			//关闭队列加载跟数据请求
			target.cacheAs = "none";//"normal";
			target&&(target.mouseEnabled = false);
			target.pivot(target.width/2,target.height/2);
			target.pos(CURRENTWIDTH/UIMgr.scale/2,CURRENTHEIGHT/UIMgr.scale/2);
			target.scale(0,0);
			Tween.to(target,{ scaleX: 1, scaleY:1}, 250, Ease.backOut,Handler.create(EffectUtils,function():void{			
				if (target) {
					target.mouseEnabled = true;
					target.cacheAs = "none";
					compH && compH.run();
				}
			}));
		}
		
		/**
		 * 缓动关闭弹窗 
		 * @param target
		 */		
		public static function closeDialog(target:Component,callBack:Handler):void
		{
			target&&(target.mouseEnabled = false);
			Tween.to(target, {scaleX: 0, scaleY: 0}, 250, Ease.backIn, Handler.create(EffectUtils,function():void{
				target&&(target.mouseEnabled = true);
				callBack&&callBack.run();
			}));
		}
		
		public static function gantan(target:Image):TimeLine
		{
			var tl:TimeLine = new TimeLine();
			tl.reset();
			tl.to(target, {scaleY: 0.4}, 85)
			.to(target, {scaleY: 1.2}, 250)
			.to(target, {scaleY: 0.9}, 210)
			.to(target, {scaleY: 1}, 170)
			tl.play();
			return tl;
		}
		
		public static function  tada(target:Image):TimeLine
		{
			var tl:TimeLine = new TimeLine();
			tl.reset();
			target.y = 382;
			target.visible = true;
			tl.to(target, {y:418, alpha: 0.58}, 300)
			.to(target, {y:393, alpha: 1}, 200)
			.to(target, {y:397, alpha:1}, 126)
			.to(target, {y:404, alpha:1}, 200)
			.to(target, {y:418, alpha:1}, 100);
			tl.play(0);
			return tl;
		}
		
		public static function  shak(target:Image):TimeLine
		{
			var tl:TimeLine = new TimeLine();
			tl.reset();
			tl.to(target, {alpha: 1}, 80)
			.to(target, {alpha: 0}, 110)
			.to(target, {alpha:1}, 90)
			.to(target, {alpha:1}, 700);
			tl.play(0);
			return tl;
		}
		
	}
}