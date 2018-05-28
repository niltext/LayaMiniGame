package config 
{
	import consts.AssertConsts;
	import laya.net.Loader;
	import laya.utils.Handler;
	
	/** 
	 * 表数据合集
	 */
	public class ConfigData 
	{
		/**声音表*/
		public static var soundCfg:Object;
		/**对话内容*/
		public static var dialogue:Object;
		
		/**过场*/
		public static var intro:Object;
		/**场景1独白*/
		public static var mono1:Object;
		/**场景2独白*/
		public static var mono2:Object;
		/**场景3独白*/
		public static var mono3:Object;
		/**场景4独白*/
		public static var mono4:Object;
		/**场景5独白*/
		public static var mono5:Object;
		
		/**分享*/
		public static var shareData:Object;
		/**密码提示*/
		public static var prompt:Object;
		
		public function ConfigData() 
		{
			
		}
		
		public static function initConfig():void{
			var cfg:Object = Laya.loader.getRes(AssertConsts.GAME_CONFIG);
			if(cfg){
				dialogue	= cfg["dialogue.json"].dialogue;
				soundCfg	= cfg["misc.json"].sounds;
				intro		= cfg["misc.json"].intro;
				shareData	= cfg["misc.json"].share;
				prompt		= cfg["misc.json"].prompt;
				mono1		= cfg["mono.json"].scene1;
				mono2		= cfg["mono.json"].scene2;
				mono3		= cfg["mono.json"].scene3;
				mono4		= cfg["mono.json"].scene4;
				mono5		= cfg["mono.json"].scene5;
			}
			
			FindDera.isInitGame = true;
		}
	}
	
}