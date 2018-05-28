package laya.customUI
{
	import Utils.MsgMgr;
	import config.ConfigData;
	import laya.events.Event;
	import laya.media.SoundManager;
	import laya.ui.Button;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	/**
	 * 按钮缩放扩展组件I 
	 */	
	public class ButtonScaleI extends Button
	{
		/**按钮点击播放声音类型（类型按表数据索引来定）**/
		public var soundType:int =  0;
		/**鼠标或手指按下的持续时间**/
		public var scaleDownTime:int = 100;
		/**鼠标或手指抬起的持续时间**/
		public var scaleUpTime:int = 200;
		private var bIsMove:Boolean;
		public function ButtonScaleI(skin:String=null, label:String="")
		{
			super(skin, label);
			this.anchorX = anchorY = 0.5;
			this.stateNum = 1;
			initEvent();
		}
		
		/**初始化事件**/
		private function initEvent():void
		{
			//添加鼠标按下事件侦听。按时时缩小按钮。
			this.on(Event.MOUSE_DOWN, this, scaleSmall);
			//添加鼠标抬起事件侦听。抬起时还原按钮。
			this.on(Event.MOUSE_UP, this, scaleBig);
			//添加鼠标离开事件侦听。离开时还原按钮。
			this.on(Event.MOUSE_OUT, this, scaleBig);
		}
		
		/**鼠标按下缩放效果**/
		private function scaleSmall():void{
			if(bIsMove) return;
			bIsMove = true;
			var str:String;
			if (soundType != 0 && ConfigData.soundCfg[soundType] && !MsgMgr.isMute){
				(str = ConfigData.soundCfg[soundType].src) && SoundManager.playSound(str, 1);
			}
			Tween.to(this, {scaleX:1.08, scaleY: 1.08}, scaleDownTime);
		}
		/**鼠标抬起放大恢复效果**/
		private function scaleBig():void{
			Tween.to(this, {scaleX:1, scaleY:1}, scaleUpTime, backOut, Handler.create(this,function():void{
				bIsMove = false;
			}));
		}
		
		public static function backOut(t:Number, b:Number, c:Number, d:Number, s:Number = 10):Number {
			return c * ((t = t / d - 1) * t * ((s + 1) * t + s) + 1) + b;
		}
	}
}