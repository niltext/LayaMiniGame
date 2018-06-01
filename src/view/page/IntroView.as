package view.page 
{
	import Utils.MsgMgr;
	import Utils.ResCacheMgr;
	import config.ConfigData;
	import consts.AssertConsts;
	import effect.EffectUtils;
	import laya.events.Event;
	import laya.media.SoundManager;
	import laya.net.Loader;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import ui.hall.IntroUI;
	import view.UIMgr;
	
	/**
	 * 过渡页
	 */
	public class IntroView extends IntroUI
	{
		private static var _sceneIdx:int = 0;
		private static var _lastRes:Array;
		private static var _introLock:Boolean = false;
		public function IntroView() 
		{
			
		}
		
		public static function onShow(sceneIdx:int):void{
			_sceneIdx = sceneIdx;
			if (_introLock) return;
			_introLock = true;
			UIMgr.openUI(IntroView, UIMgr.LAYER_POP3);
		}
		
		override public function onCreated():void 
		{
			super.onCreated();
		}
		
		override public function onOpen():void 
		{
			super.onOpen();
			addToParent(this);
			bg.on(Event.CLICK, this, function():void{});
			ClueScene.instance && (ClueScene.instance.whiteBg.visible = true);
			this.alpha = t0.alpha = title.alpha = 0;
			
			UIMgr.whiteBg && (UIMgr.whiteBg.visible = true);
			if (_sceneIdx == 1){
				bg.skin = "layaNativeDir/i1.jpg";
				//title. pos(168, 436);
			}else{
				bg.skin = "hall/i" + _sceneIdx + ".jpg";
				//var posArr:Array = ConfigData.intro[_sceneIdx].posArr;
				//title.pos(posArr[0], posArr[1]);
			}
			
			bg.y = 0;
			_lastRes = [];
			_lastRes.push(bg.skin);
			if (_sceneIdx > 1){
				title.skin = "intro/t" + _sceneIdx + ".png";
				t.pos(376, 88);
				t.skin = "intro/d" + _sceneIdx + ".png";
				var sceneRes:String = "cluescene/scene" + (_sceneIdx - 1) + ".jpg";
				_lastRes.push(sceneRes);
				sceneRes = "cluescene/wb" + (_sceneIdx - 1) + ".jpg";
				_lastRes.push(sceneRes);
			}
			
			if (_sceneIdx == 1){
				if (!MsgMgr.isMute) MsgMgr.decMusicVol("res/sounds/intro.mp3");
				t0.skin = "layaNativeDir/dbg.png";
				t.pos(190, 284);
				t.skin = "layaNativeDir/d1.png";
				tSp.visible = true;
				tSp.alpha = 1;
				//时间动画
				stepTime(c0, 1, 1, 10);
				stepTime(c1, 10, 1, 6);
				stepTime(c2, 60, 2, 10);
				Tween.to(tSp, {alpha:0}, 3000, Ease.circOut, Handler.create(this, function():void{
					Laya.timer.clearAll(this);
				}), 4500);
				Tween.to(t0, {alpha:1}, 1000, Ease.circIn,null, 5500);
				bg.height = 2360;
				var len:Number = Laya.stage.height - 2360;
			}else{
				t0.skin = "intro/dbg1.png";
				tSp.visible = false;
				bg.height = 1560;
			}
			Tween.to(this, {alpha:1}, 1000, Ease.linearIn, Handler.create(this, function():void{
				if (_sceneIdx == 1){
					UIMgr.whiteBg && (UIMgr.whiteBg.skin = "layaNativeDir/dark.png");
					Tween.to(bg, {y: len}, 7500, Ease.linearIn, Handler.create(this, onGoClue));
				}else{
					UIMgr.whiteBg && (UIMgr.whiteBg.skin = "layaNativeDir/white.png");
					Tween.to(t0, {alpha:1}, 1500, Ease.circOut, Handler.create(this, function():void{
						Tween.to(t0, {alpha:0}, 1000, Ease.circIn, Handler.create(this, function():void{
							if(_sceneIdx == 2) EffectUtils.tada(sun);
							Tween.to(title, { alpha:1 }, 630, Ease.circOut,Handler.create(this,onGoClue), 630);
						}),1000);
					}));
				}
			}));
		}
		
		/**
		 * 数字时钟计时
		 * @param	curI 当前对象
		 * @param	tStemp 延时
		 * @param	idx 开始索引
		 * @param	endSp 结束索引
		 */
		private function stepTime(curI:Image, tStemp:int, idx:int, endSp:int):void
		{
			Laya.timer.frameLoop(tStemp, this, function _fly():void{
				curI.skin = "intro/" + idx + ".png";
				idx++;
				if (idx == endSp){
					idx = 0;
				}
			});
		}
		
		private function onGoClue():void
		{
			if (_introLock){
				_introLock = false;
				if(_sceneIdx == 1) Tween.to(t0, {alpha:0}, 2000);
				Tween.to(title, {alpha:0}, 2000, Ease.circIn, Handler.create(this, function():void{
					if (_sceneIdx == 1){
						if (!MsgMgr.isMute) MsgMgr.decMusicVol();
						var resArr:Array = [
								{url: AssertConsts.ATLAS_INTRO, type: Loader.ATLAS},
								{url:"hall/i2.jpg", type:Loader.IMAGE},
								{url:"hall/i3.jpg", type:Loader.IMAGE},
								{url:"hall/i4.jpg", type:Loader.IMAGE},
								{url:"hall/i5.jpg", type:Loader.IMAGE}
							];
						Laya.loader.load(resArr);	
					}
				}));
				
				Tween.to(this, {alpha:0}, 3000, Ease.circIn, Handler.create(this, function():void{
					if (_sceneIdx == 1){
						ClueScene.onShow(0);
					}else{
						ClueScene.instance && ClueScene.instance.onEnter();
					}
					ClueScene.instance && (ClueScene.instance.whiteBg.visible = false);
					sun.visible = false;
					ResCacheMgr.I.clearResList(_lastRes);
					UIMgr.closeUI(IntroView);
				}));
			}
		}
		
		override public function createBj():void {}
		
		override public function onClose():void 
		{
			super.onClose();
			bg.skin = "";
			title.skin = "";
			this.alpha = t0.alpha = title.alpha = 0;
		}
		
	}
}