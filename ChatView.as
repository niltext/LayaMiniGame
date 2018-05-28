package view.page 
{
	import Utils.MsgMgr;
	import config.ConfigData;
	import consts.AssertConsts;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.media.SoundManager;
	import laya.net.Loader;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;
	import ui.chatList.ChatPageUI;
	import view.UIMgr;
	import view.page.chat.ChatLineUI;
	import view.page.chat.DiasUI;
	
	/**
	 * Phone
	 */
	public class ChatView extends ChatPageUI 
	{
		/**聊天内容条目UI存放容器 **/
		//private static var _chatLineArr:Array;
		/**聊天内容条目总高度 **/
		private static var _chatMsgTotalHeight:Number = 10;
		/**聊天内容条目 **/
		private static var _dialogCfg:Array;
		/**聊天表索引 **/
		private static var _tipsIdx:int;
		/**聊天内容索引 **/
		private static var _dialogIdx:int = 0;
		//分享解锁计数
		private var _lockNum:int;
		//手动解锁计数
		private var _hlockNum:int;
		//场景按钮
		private var _btnBox:Box;
		//场景背景
		private var _sceneBg:Image;
		
		private static var instance:ChatView;
		
		public function ChatView() 
		{
			resList = [ 			
				{url:AssertConsts.ATLAS_CHAT, type:Loader.ATLAS}
			];
		}
		
		private function shareUnlock():void
		{
			if(!MsgMgr.isMute) SoundManager.playSound(ConfigData.soundCfg[1].src, 1);
			var rdm:int = (Math.random() * 4 + 1)|0;
			var obj:Object = ConfigData.shareData[rdm];
			__JS__('wx').shareAppMessage({
				title:obj.title,
				imageUrl:obj.url,
				success:function(data:Object):void{
					//trace("----------------shareSuccess------------------------");
					ClueScene.instance.clueArr[3] = "t5_3";
					btnShare.off(Event.CLICK, this, shareUnlock);
					Laya.timer.frameLoop(30, ChatView.instance, unLockOne);
					//trace(data);
				}
				//,fail:function(data:Object):void{
					//trace("------------shareFail-----------------");
					//trace(data);
				//}
			});
		}
		
		private var secretStr:String = "180109";
		private function unLockOne():void
		{
			//var rdm:int = Math.random() * 10 | 0;
			var num:String = secretStr[_lockNum];
			(this["pot" + num] as Image).alpha = 1;
			this["poi" + _lockNum].visible = true;
			_lockNum++;
			Laya.timer.once(100, this, function():void{
				(this["pot" + num] as Image).alpha = 0;
			});
			
			if (_lockNum == 6){
				Laya.timer.clear(this, unLockOne);
				Tween.to(lockBg, {y : -900}, 600, Ease.circIn, Handler.create(this, function():void{
					lockBox.visible = false;
					lockBg.y = 0;
					_dialogCfg = ConfigData.dialogue[4].data;
					_dialogIdx = 0;
					_tipsIdx = 4;
					Laya.timer.once(500, this, onSendMsgClick);
				}));
				poi0.visible = poi1.visible = poi2.visible = poi3.visible = poi4.visible = poi5.visible = false;
			}
		}
		
		private var locSec:String;
		private var errCount:int = 0;
		private var diasTalk:DiasUI;
		private var _topSp:Sprite;
		private function onPot(idx:int):void
		{
			if (_hlockNum == 0){
				locSec = "";
				sTips.skin = "chat/sTips.png";
			}
			(this["pot" + idx] as Image).alpha = 1;
			this["poi" + _hlockNum].visible = true;
			Laya.timer.once(100, this, function():void{
				(this["pot" + idx] as Image).alpha = 0;
			});
			locSec = locSec + idx + "";
			_hlockNum++;
			
			if (_hlockNum == 6){
				if (locSec == secretStr){
					diasTalk.bg.skin = "layaNativeDir/blank.png";
					diasTalk.bg.alpha = 1;
					_topSp && _topSp.offAll(Event.CLICK);
					_topSp && _topSp.removeSelf();
					ClueScene.instance.addChild(diasTalk);
					errCount = 0;
					for (var i:int = 0, sz:int = 10; i < sz; i++){
						(this["pot" + i] as Image).off(Event.CLICK, this, onPot);
					}
					Tween.to(lockBg, {y : -900}, 600, Ease.circIn, Handler.create(this, function():void{
						btnShare.visible = false;
						lockBox.visible = false;
						lockBg.y = 0;
						_dialogCfg = ConfigData.dialogue[4].data;
						_dialogIdx = 0;
						_tipsIdx = 4;
						Laya.timer.once(500, this, onSendMsgClick);
					}));
				}else{
					errCount += 1;
					switch(errCount){
						case 1:
							btnShare.visible = true;
							btnShare.on(Event.CLICK, this, shareUnlock);
							diasTalk.verbDias(ConfigData.prompt[1]);
							break;
						case 2:
							diasTalk.verbDias(ConfigData.prompt[2]);
							break;
						case 3:
							diasTalk.verbDias(ConfigData.prompt[3]);
							break;
						default:
							diasTalk.verbDias(ConfigData.prompt[3]);
							break;
					}
					if (!_topSp){
						_topSp = new Sprite();
						_topSp.size(Laya.stage.width, Laya.stage.height);
						this.addChild(_topSp);
						_topSp.visible = false;
						_topSp.on(Event.CLICK, this, function():void{
							diasTalk.onHide();
							Laya.timer.once(200, this, function():void{
								_topSp.visible = false;
							});
						});
					}
					Laya.timer.once(1000, this, function():void{
						_topSp.visible = true;
					});
					sTips.skin = "chat/sError.png";
					_hlockNum = 0;
				}
				poi0.visible = poi1.visible = poi2.visible = poi3.visible = poi4.visible = poi5.visible = false;
			}
		}
		
		private var _preChatLine:ChatLineUI;
		private function onSendMsgClick():void
		{
			var chatContent:Object = _dialogCfg[_dialogIdx];
			if (!chatContent) return;
			
			switch(chatContent.id){
				case 0:
				case 1:
					//从对象池创建ChatLineUI的实例
					//var chatLineUI:ChatLineUI = Pool.getItemByClass("chatLineUI",ChatLineUI);
					var chatLineUI:ChatLineUI = new ChatLineUI();
					chatLineUI.init(chatContent, _tipsIdx);
					//添加聊天条目到panel
					chatPanel.addChild(chatLineUI);
					
					_preChatLine = chatLineUI;
					//设置聊天单条内容的位置
					chatLineUI.y = _chatMsgTotalHeight;
					//_chatLineArr.push(chatLineUI);
					//设置聊天内容的总高度 30是气泡间的间距
					_chatMsgTotalHeight += chatLineUI.contentP.height + 30;
					break;
				case 2:
					var dat:Image = new Image();
					dat.skin = "chat/" + chatContent.photo;
					chatPanel.addChild(dat);
					dat.centerX = 0;
					dat.y = _chatMsgTotalHeight;
					_chatMsgTotalHeight += 60;
					break;
				case 3:
					_preChatLine.emoj.visible = true;
					_preChatLine.emoj.skin = "chat/" + chatContent.photo;
					_preChatLine.emoj.pos(chatContent.pos[0], chatContent.pos[1]);
					break;
			}
			
			_dialogIdx++;
			if (_dialogIdx < _dialogCfg.length){
				if (_tipsIdx == 3){
					onSendMsgClick();
				}else{
					Laya.timer.once(1500, this, onSendMsgClick);
				}
			}else{
				//对话结束
				//chatPanel.mouseEnabled = true;
				if(_tipsIdx == 1 || _tipsIdx == 4){
					btnClose.visible = true;
					btnClose.on(Event.CLICK, this, onHide);
				}
				if (_tipsIdx == 2){
					Laya.timer.once(2000, this, function():void{
						var img:Image = new Image();
						img.skin = "cluescene/scene4.jpg";
						img.size(72, 156);
						ChatView.instance.addChild(img);
						img.anchorX = 0.5;
						img.anchorY = UIMgr.CENT_Y / 1560;
						img.pos(300, UIMgr.CENT_Y + 300);
						maskBg.visible = true;
						Tween.to(img, {scaleX:10, scaleY:10, x:360, y:UIMgr.CENT_Y}, 300, null, Handler.create(this, function():void{
							if (_sceneBg){
								Tween.to(_sceneBg, {alpha:0}, 1000, Ease.linearIn, Handler.create(this, function():void{
									_sceneBg && (_sceneBg.skin = "cluescene/scene4.jpg");
									Tween.to(_sceneBg, {alpha:1}, 1000, Ease.linearOut, Handler.create(this, function():void{
										_btnBox && (_btnBox.visible = true);
										maskBg.visible = false;
										UIMgr.closeUI(ChatView);
										img.removeSelf();
									}));
								}));
							}
						}));
					});
				}
			}
			
			//滚动条滑块永远位于最下方
			chatPanel.vScrollBar.max = chatPanel.contentHeight;
			chatPanel.vScrollBar.value = chatPanel.vScrollBar.max;
			chatPanel.reCache();
		}
		
		private function onHide():void
		{
			if (_tipsIdx == 4){
				EndView.endResPre();
				ClueScene.instance.btnBack.visible = false;
				if (!MsgMgr.isMute) MsgMgr.decMusicVol();
			}
			Tween.to(this, {y:2000, alpha:0.1}, 500, Ease.cubicIn, Handler.create(this, function():void{
				if (_sceneBg){
					Tween.to(_sceneBg, {alpha:0}, 1000, Ease.linearIn, Handler.create(this, function():void{
						if (_tipsIdx == 1){
							_sceneBg.skin = "cluescene/scene3_1.jpg";
						}else if (_tipsIdx == 2){
							_sceneBg.skin = "cluescene/scene4.jpg";
						}
						if (_tipsIdx == 4){
							FindDera.instance.onEndGame();
							UIMgr.closeUI(ClueScene);
							UIMgr.closeUI(ChatView);
							return;
						}
						Tween.to(_sceneBg, {alpha:1}, 2000, Ease.linearOut, Handler.create(this, function():void{
							_btnBox && (_btnBox.visible = true);
							UIMgr.closeUI(ChatView);
						}));
					}));
				}
			}));
		}
		
		public static function onShow(tipsIdx:int):void{
			_dialogCfg = ConfigData.dialogue[tipsIdx].data;
			_tipsIdx = tipsIdx;
			_dialogIdx = 0;
			UIMgr.openUI(ChatView, UIMgr.LAYER_TIPS);
		}
		
		override public function onCreated():void 
		{
			super.onCreated();
		}
		
		override public function onOpen():void 
		{
			super.onOpen();
			addToParent(this);
			
			pBox.y = UIMgr.CENT_Y;
			this.y = 2000;
			alpha = 1;
			btnClose.visible = false;
			//chatPanel.mouseEnabled = false;
			chatPanel.vScrollBarSkin = "";
			chatPanel.vScrollBar.isVertical = true;
			chatPanel.cacheAs = "bitmap";
			//chatPanel.vScrollBar.elasticBackTime = 600;
			//chatPanel.vScrollBar.elasticDistance = 100;
			instance = this;
			switch(_tipsIdx){
				case 1:
				case 2:
					pBg.skin = "chat/ph1.png";
					lockBox.visible = false;
					Laya.timer.once(500, this, onSendMsgClick);
					break;
				case 3:
					pBg.skin = "chat/ph2.png";
					_lockNum = 0;
					_hlockNum = 0;
					locSec = "";
					lockBox.visible = true;
					onSendMsgClick();
					
					diasTalk = ClueScene.instance.diasTalk;
					this.addChild(diasTalk);
					diasTalk.bg.skin = "layaNativeDir/dark.png";
					diasTalk.bg.alpha = 0.7;
					diasTalk.visible = false;
					//设置锁屏页裁剪
					lockBox.scrollRect || (lockBox.scrollRect = new Rectangle(0, 0, 500, lockBg.height));
					for (var i:int = 0, sz:int = 10; i < sz; i++){
						(this["pot" + i] as Image).on(Event.CLICK, this, onPot, [i]);
					}
					break;
			}
			
			var pop1Child:Array = UIMgr.getLayer(UIMgr.LAYER_POP1)._childs;
			var clueBox:Box = pop1Child[pop1Child.length - 1];
			if (clueBox){
				if(clueBox["btnClue"]){
					_btnBox = clueBox["btnClue"];
					_btnBox.visible = false;
				}
				if (clueBox["clueBg"]){
					_sceneBg = clueBox["clueBg"];
				}
			}
			
			Tween.to(this, {y:0}, 500, Ease.cubicOut);
		}
		
		override public function createBj():void {}
		
		override public function onClose():void 
		{
			btnClose.off(Event.CLICK, this, onHide);
			chatPanel.removeChildren();
			_chatMsgTotalHeight = 10;
			_btnBox = null;
			_sceneBg = null;
			super.onClose();
		}
	}

}