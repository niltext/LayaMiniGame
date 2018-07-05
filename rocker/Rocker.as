package rocker
{
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	
	import view.UIMgr;
	/**
	 * ...
	 */
	public class Rocker extends Sprite
	{
		private var baseRocket:Sprite;
		private var base_width:Number = 200;
		private var base_height:Number = 200;
		
		private var knobRocket:Sprite;
		private var knob_width:Number = 95;
		private var knob_height:Number = 95;
		
		private var rockerAlpha:Number = 0.5;
		
		private var type:int = 1;
		private var _angle:Number = 0;
		private var _radians:Number = -1;
		
		private var _direction:int = -1;
		
		//	瞬间弹到中间位置
		private var _elastic:Boolean = true;
		private var _localDeltaX:int;
		private var _localDeltaY:int;
		
		private var _deltaX:int = 0;
		public  var baseX:int = 0;
		public  var baseY:int = 0;
		private var _deltaY:int = 0;
		public  var  lastRadians:int;
		
		public var  isAttack:Boolean;
		
		// 触摸区域
		private var _touchRect:Sprite;
		
		// 点击状态 0为取消 1为点击 2为移动 3为结束
		private var _touchState:int = -1;
		public static const TOUCH_NONE:int = -1;
		public static const TOUCH_OUT:int = 0;
		public static const TOUCH_DOWN:int = 1;
		public static const TOUCH_MOVE:int = 2;
		public static const TOUCH_UP:int = 3;
		
		public function Rocker(touchRect:Sprite) 
		{
			super();
			loadImg();
			
			if (touchRect)
			{
				_touchRect = touchRect;
				_touchRect.on(Event.MOUSE_DOWN, this, onTouchBegan);
			}
		}
		
		public function initRocker():void
		{
			stage.on(Event.MOUSE_MOVE, this, onTouchMove);
		}
		
		public function isPress():Boolean
		{
			return _touchState==TOUCH_DOWN || _touchState==TOUCH_MOVE;
		}
		
		public static const ctr_base:String = "layaNativeDir/base.png";
		public static const ctr_knob:String = "layaNativeDir/knob.png";
		
		private function loadImg():void{
			
			baseRocket = new Sprite();
			baseRocket.loadImage(ctr_base);
			baseRocket.pivot(base_width/2, base_height/2);
			baseRocket.alpha = rockerAlpha;
			this.addChild(baseRocket);
			
			knobRocket = new Sprite();
			knobRocket.loadImage(ctr_knob);
			knobRocket.pivot(knob_width/2, knob_height/2);
			knobRocket.pos(base_width/2, base_height/2);
			baseRocket.addChild(knobRocket);
		}
		
		private var _unmoverange:Number = 2;
		private var _beginPos:Point = new Point();
		private var _touchId:int = -1;
		private var _touchIndex:int;
		private var _mouseMoveAccuracy:int = 8;
		
		private var _touchIDArr:Array = [];
		
		private var stoped:Boolean = false;
		
	
		public function onTouchBegan(e:Event = null):void {
			if (stoped) return;
			_touchId = e.touchId;
			if(_touchIDArr.indexOf(_touchId) == -1)
				_touchIDArr.push(_touchId);
			
			_touchState = TOUCH_DOWN;
			
			_beginPos.x = Laya.stage.mouseX;
			_beginPos.y = Laya.stage.mouseY;
			
			stage.on(Event.MOUSE_UP, this, onTouchEnd);
			_elastic = true;
			if (type == 0){
				stage.on(Event.MOUSE_MOVE, this, onTouchMove);
			}else{
				baseRocket.visible = true;
				if (name == "_attackCtrl")
				{
					var b:Sprite = e.target.parent as Sprite;
					if (b)
					{
						this.pos(b.x + (b as Object).offx, b.y + (b as Object).offy);
					}
					else
					{
						this.pos(_beginPos.x, _beginPos.y);
					}
				}
				else
				{
					var bx:int = _beginPos.x;
					var by:int = _beginPos.y;
					var dx:int = bx - baseX;
					var dy:int = by - baseY;
					if (dx * dx + dy * dy < 10000)
					{
						this.pos(baseX, baseY); 
					}
					else
					{
						_angle = Math.atan2(dy, dx) * 57.29577951;
						if (_angle < 0) _angle += 360;
						_radians = Math.PI / 180 * _angle;
						var x:int = Math.floor(Math.cos(_radians) * base_width/2);
						var y:int = Math.floor(Math.sin(_radians) * base_height/2);
						this.pos(bx - x, by - y);
					}
				}
				stage.on(Event.MOUSE_MOVE, this, onTouchMove);
			}
			
			
			var lx:Number, ly:Number;
			lx = _beginPos.x - this.x + baseRocket.pivotX;
			ly = _beginPos.y - this.y + baseRocket.pivotY;
			
			_localDeltaX = lx - base_width / 2;
			_localDeltaY = ly - base_height / 2;
			var _sqx:int = _localDeltaX * _localDeltaX;
			var _sqy:int = _localDeltaY * _localDeltaY;
			
			if (_elastic && Math.abs(_localDeltaX) <= _mouseMoveAccuracy && Math.abs(_localDeltaY) <= _mouseMoveAccuracy)
			{
				_radians = -1/*Rocker.TOUCH_NONE*/;
				return;
			}
			_deltaX = _localDeltaX;
			_deltaY = _localDeltaY;
			
			_angle = Math.atan2(_localDeltaY, _localDeltaX) * 57.29577951;
			if (_angle < 0) _angle += 360;
			_radians = Math.PI / 180 * _angle;
			//	摇杆鼠标离中心的最远距离
			var _dis:int = base_width / 2 + 20;
			if (_sqy + _sqx >= _dis * _dis){
				x = Math.floor(Math.cos(_radians) * _dis + base_width / 2);
				y = Math.floor(Math.sin(_radians) * _dis + base_width / 2);
				knobRocket.pos(x, y);
			}else{
				knobRocket.pos(lx, ly);
			}
		}
		
		private function onTouchMove(e:Event = null):void{
			if (stoped) return;
			
			if (_touchId == -1/*Rocker.TOUCH_NONE*/)
			{
				if(!isAttack && e.stageX<=_touchRect.width)onTouchBegan(e);
				return;
			}
			else if (!e.nativeEvent.buttons)
			{
				return;
			}
			if (_touchId == e.touchId)
			{
				_touchState = TOUCH_MOVE;
				var touchPosX:Number= Laya.stage.mouseX;
				var touchPosY:Number = Laya.stage.mouseY;
				var lx:Number, ly:Number;
				var halfW:Number = base_width / 2;
				var halfH:Number = base_height / 2;
				
				if (Math.abs(touchPosX - _beginPos.x) <= _unmoverange && Math.abs(touchPosY - _beginPos.y) <= _unmoverange)
					return;
				lx = touchPosX - this.x+baseRocket.pivotX;
			    ly = touchPosY - this.y+baseRocket.pivotY;
				_localDeltaX = lx - halfW;
				_localDeltaY = ly - halfH;
				if (_elastic && Math.abs(_localDeltaX) <= _mouseMoveAccuracy && Math.abs(_localDeltaY) <= _mouseMoveAccuracy){
					_radians = -1/*Rocker.TOUCH_NONE*/;
					//_angle = -1;
					return;
				}
				var _sqx:int = _localDeltaX * _localDeltaX;
				var _sqy:int = _localDeltaY * _localDeltaY;
				
				_deltaX = _localDeltaX;
				_deltaY = _localDeltaY;
				_elastic = false;
				_angle = Math.atan2(_localDeltaY, _localDeltaX) * 57.29577951;
				if (_angle < 0) _angle += 360;
				_radians = Math.PI / 180 * _angle;
				//	摇杆鼠标离中心的最远距离
				var _dis:int = base_width / 2 + 20;
				if (_sqy + _sqx >= _dis * _dis){
					lx = 0 | (Math.cos(_radians) * _dis + halfW);
					ly = 0 | (Math.sin(_radians) * _dis + halfW);
				}
				
				knobRocket.pos(lx, ly, true);
			}
		}
		
		public function getRadiu():Number
		{
			var r:Number= Math.sqrt(_deltaX * _deltaX + _deltaY * _deltaY);
			return Math.min(r,120);
		}
		
		private function onTouchEnd(e:Event = null):void{
			//txtE.text = "onTouchEnd : " + e.touchId + "_touchIDArr.length : "+_touchIDArr.length + "e.touches.length : "+e.touches.length;
			if (e.touches && e.touches.length){
				var index:int = _touchIDArr.indexOf(e.touchId) ;
				if (index == -1) return ;
				_touchIDArr.splice(index, 1);
				if(_touchIDArr.length)
				{
					_touchId = -1;
					_touchState = TOUCH_UP;
					knobRocket.pos(base_width/2, base_height/2);
					return ;
				}
			}
			else 
			{
				_touchIDArr.length = 0;
			}
			if (!isAttack && e.stageX > _touchRect.width)
			return;
			
			if (_touchId == e.touchId)
			{
				_touchId = -1;
				_touchState = TOUCH_UP;
				//if (sys.isMobile() && e.touches.length != 0)
					//return;
				//_touchRect.off(Event.MOUSE_MOVE, this, onTouchMove);
				//_touchRect.off(Event.MOUSE_OUT, this, onTouchCancel);
				//_touchRect.off(Event.MOUSE_UP, this, onTouchEnd);
				stage.off(Event.MOUSE_MOVE, this, onTouchMove);
				stage.off(Event.MOUSE_OUT, this, onTouchCancel);
				stage.off(Event.MOUSE_UP, this, onTouchEnd);
				
				if (name == "_moveCtrl")
				{
					this.pos(baseX, baseY);
				}
				knobRocket.pos(base_width/2, base_height/2);
				if (type == 1){
					//txtE.text = "baseRocket.visible = false";
					//baseRocket.visible = false;
				}
				_direction = -1;
				lastRadians = angle;
				_radians = -1/*Rocker.TOUCH_NONE*/;
				_angle = -1/*Rocker.TOUCH_NONE*/;
				
				if (isAttack)_touchRect.event("skill", e);
				_deltaX = 0;
				_deltaY = 0;
				//alert("end");
			}
		}
		
		private function onTouchCancel(e:Event = null):void
		{
			
			if (_touchId == e.touchId)
			{
				_touchId = -1;
				_touchState = TOUCH_OUT;
				
				stage.off(Event.MOUSE_MOVE, this, onTouchMove);
				stage.off(Event.MOUSE_OUT, this, onTouchCancel);
				stage.off(Event.MOUSE_UP, this, onTouchEnd);
				if (name == "_moveCtrl")
				{
					this.pos(baseX, baseY);
				}
				knobRocket.pos(base_width/2, base_height/2);
				if (type == 1){
					//baseRocket.visible = false;
				}
				_direction = -1;
				
				_radians = -1/*Rocker.TOUCH_NONE*/;
				_angle = -1/*Rocker.TOUCH_NONE*/;
				
				_touchRect.event("skill", e);
				_deltaX = 0;
				_deltaY = 0;
				//alert("out");
			}
		}
		
		public function setStoped(value:Boolean):void
		{
			stoped = value;
		}
		
		public function clearRocker():void{
			_angle = -1/*Rocker.TOUCH_NONE*/ ;
			_direction = -1;
			_radians = -1/*Rocker.TOUCH_NONE*/;
			_deltaX = 0;
			_deltaY = 0;
			angle = -1/*Rocker.TOUCH_NONE*/;
			_touchState = -1/*Rocker.TOUCH_NONE*/;
			_touchIDArr.length = 0;
			
			//清理事件
			stage.off(Event.MOUSE_MOVE, this, onTouchMove);
			stage.off(Event.MOUSE_OUT, this, onTouchCancel);
			stage.off(Event.MOUSE_UP, this, onTouchEnd);
			
			//stage.on(Event.MOUSE_UP, _moveCtrl, _moveCtrl.onTouchEnd);
			if (name == "_moveCtrl")
			{
				stage.on(Event.MOUSE_MOVE, this, onTouchMove);
			}
			//复原 摇杆 ;
			knobRocket.pos(base_width/2, base_height/2);
		}
		
		/**弧度*/
		public function get radians():Number 
		{
			return _radians;
		}
		public function set radians(value:Number):void 
		{
			_radians = value;
		}
		
		public static var ANGLEDETAL:int = 2;
		/**角度*/
		public function get angle():Number 
		{
			return _angle ==-1/*Rocker.TOUCH_NONE*/? -1/*Rocker.TOUCH_NONE*/:(0|(_angle / ANGLEDETAL)) * ANGLEDETAL ;
		}
		public function set angle(value:Number):void 
		{
			_angle = value;
		}
		/**根据 _deltaX _deltaY计算角度 -- 一般情况下与angle结果一致，但是新需求，停止时会导致angle为-1。此时使用此函数即可获得正确的摇杆角度*/
		public function get deltaAngle():Number{
			var a_angle:Number = Math.atan2(_deltaX, _deltaY) * 57.29577951;
			if (a_angle < 0) a_angle += 360;
			return a_angle ==-1/*Rocker.TOUCH_NONE*/? -1/*Rocker.TOUCH_NONE*/:Math.round(a_angle / ANGLEDETAL) * ANGLEDETAL;
		}
	}

}