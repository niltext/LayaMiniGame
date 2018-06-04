package view
{
	import laya.display.Sprite;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import view.page.ClueScene;
	
	public class Danmu
	{
		private var dmAmount:int = 50;

		private var tick:Number = 0;		
		private var danmus:Array = [];
		private var dmContainer:Sprite;
		private var dmTex:*;
		
		public function Danmu()
		{
			
		}
		
		public function initDanmu():void 
		{
			Laya.loader.load("layaNativeDir/cg.png", Handler.create(this, onTexLoaded));
		}
		
		private function onTexLoaded(e:*=null):void
		{
			dmTex = Laya.loader.getRes("layaNativeDir/cg.png");
			dmContainer = new Sprite();
			dmContainer.size(Browser.clientWidth,Browser.clientHeight);
			UIMgr.getLayer(UIMgr.LAYER_TIPS).addChild(dmContainer);
			
			for (var i:int = 0; i < dmAmount; i++)
			{
				var dm:Dm = newDanmu();
				dmContainer.addChild(dm);
				danmus.push(dm);
			}
			Laya.timer.frameLoop(1, this, animate);
		}
		
		private function newDanmu():Dm
		{
			var dmSp:Dm = new Dm();
			dmSp.graphics.drawTexture(dmTex, 0, 0);
			var rndScale:Number = 0.3 + Math.random() * 0.7;
			dmSp.scale(rndScale, rndScale);
			dmSp.speed = (Math.random() * 4 + 6) | 0;
			dmSp.x = Math.random() * Laya.stage.width * 2;
			dmSp.y = Math.random() * Laya.stage.height;
			return dmSp;
		}
		
		private function animate():void
		{
			var dm:Dm;
			var x:Number;
			for (var i:int = 0; i < dmAmount; i++)
			{
				dm = danmus[i];
				
				dm.x -= dm.speed;
				
				x = dm.x;
				
				if (x < -600)
					x += Laya.stage.width - x;
					
				dm.x = x;
			}
			
			tick += 0.1;
			if (tick > 50){
				Laya.timer.clear(this, animate);
				Laya.timer.frameLoop(1, ClueScene.instance, ClueScene.instance._incMask);
				dmContainer.removeChildren();
				dmContainer = null;
			}
		}
	}
}

import laya.display.Sprite;
class Dm extends Sprite
{
	public var speed:int;
}