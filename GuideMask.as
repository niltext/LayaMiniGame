package view.page.guide 
{
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.resource.Texture;
	import laya.ui.Button;
	import laya.ui.Image;
	import ui.clueScene.ArrowUI;
	import view.UIMgr;
	import laya.utils.HitArea;
	import view.page.ClueScene;
	/**
	 * 引导层
	 */
	public class GuideMask 
	{
		private var guideContainer:Sprite;
		private var hitArea:HitArea;
		//private var interactionArea:Sprite;
		private var maskArea:Sprite;
		private var guideSp:Image;
		private var btnSp:Image;
		private var arrow:*;
		
		public static var _instance:GuideMask;
		
		public function GuideMask() 
		{
		}
		
		public static function getInstance():GuideMask
		{
			_instance ||= new GuideMask();
			return _instance;
		}
		
		/**清理*/
		public static function clearAll():void
		{
			if (_instance)
			{
				_instance.clear();
			}
		}
		
		/**初始化*/
		public function  init():void
		{
			// 设置容器为画布缓存
			var w:Number = UIMgr.AllLayer.width;
			var h:Number = UIMgr.AllLayer.height;
			//var w:Number = Laya.stage.width;
			//var h:Number = Laya.stage.height;
			if (!guideContainer)
			{
				guideContainer = new Sprite();
				guideContainer.cacheAs = "bitmap";
				
				//绘制遮罩区，含透明度，可见游戏背景
				maskArea = new Sprite();
				maskArea.alpha = 0.5;
				
				guideContainer.addChild(maskArea);
				
				hitArea = new HitArea();
				
				arrow = new ArrowUI();
				guideContainer.addChild(arrow);
				arrow.pos( -100, -100);
				
				guideContainer.hitArea = hitArea;
				guideContainer.mouseEnabled = true;
				////绘制一个区域，利用叠加模式，从遮罩区域抠出可交互区
				//interactionArea = new Sprite();
				////设置叠加模式
				//interactionArea.blendMode = "destination-out";
				//guideContainer.addChild(interactionArea);
				guideSp = new Image();
				btnSp = new Image();
				guideSp.visible = btnSp.visible = false;
				guideSp.anchorX = guideSp.anchorY = btnSp.anchorX = 0.5;
				btnSp.anchorY = 0.7;
				guideSp.addChild(btnSp);
				guideContainer.addChild(guideSp);
			}
			guideContainer.size(w, h);
			maskArea.graphics.clear();
			maskArea.graphics.drawRect(0, 0, w, h, "#000000");
			hitArea.hit.clear();
			hitArea.hit.drawRect(0, 0, w, h, "#000000");	
		}
		
		//public function maskCircle(x:Number, y:Number, r:Number /*,tipStr:String*/):void
		//{
			//init();
			//arrow.pos(x - 240, y - 30);
			//arrow.ani1.play();
			//hitArea.unHit.clear();
			//hitArea.unHit.drawCircle(x, y, r, "#ff0000");
			//interactionArea.graphics.clear();
			//interactionArea.graphics.drawCircle(x, y, r, "#ff0000");
			//
			//UIMgr.getLayer(UIMgr.LAYER_GUIDE).addChild(guideContainer);
		//}
		
		public function maskSprite(sp:Button, func:Function, isBtnMask:Boolean):void
		{
			init();
			var p:Point = new Point(110, UIMgr.BTN_Y +70);
			arrow.pos(sp.x - 30, sp.y - 236);
			arrow.ani1.play();
			hitArea.unHit.clear();
			
			if (isBtnMask){
				guideSp.skin = sp.skin;
				guideSp.once(Event.CLICK, this, function():void{
					arrow.ani1.stop();
					arrow.pos( -100, -100);
					btnSp.visible = true;
					btnSp.skin = "common/ok.png";
					btnSp.pos( -100, 30);
					btnSp.on(Event.CLICK, ClueScene.instance, func);
				});
			}else{
				btnSp.visible = false;
				guideSp.skin = "common/1_12.png";
				guideSp.on(Event.CLICK, ClueScene.instance, func);
			}
			guideSp.pos(sp.x, sp.y);
			guideSp.visible = true;
			
			UIMgr.getLayer(UIMgr.LAYER_GUIDE).addChild(guideContainer);
			guideContainer.pos(0, 0);
		}
		
		//public function maskRect(x:Number, y:Number, w:Number, h:Number /*,tipStr:String*/):void
		//{
			//init();
			//arrow.pos(x - 50, y - 230);
			//arrow.ani1.play();
			//
			//hitArea.unHit.clear();
			//hitArea.unHit.drawRect(x, y, w, h, "#000000");
			//interactionArea.graphics.clear();
			//interactionArea.graphics.drawRect(x, y, w, h, "#ff0000");
			//
			//UIMgr.getLayer(UIMgr.LAYER_GUIDE).addChild(guideContainer);
		//}
		
		public function clear():void
		{
			if (guideContainer)
			{
				btnSp.offAll(Event.CLICK);
				guideSp.offAll(Event.CLICK);
				guideContainer.removeSelf();
				arrow.ani1.stop();
				arrow.pos( -100, -100);
			}
		}
		
	}
}