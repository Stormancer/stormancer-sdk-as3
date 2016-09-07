package
{
	import Stormancer.Client;
	import Stormancer.Configuration;
	import Stormancer.Scene;
	import Stormancer.Infrastructure.ApiClient;
	import Stormancer.Infrastructure.TokenHandler;
	import com.codecatalyst.promise.Promise;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import org.msgpack.MsgPack;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public class Main extends Sprite
	{
		private var _scene:Scene;
		
		public function Main()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			CreateSceneAndConnect();
		
		}
		
		private function initAndConnectScene(scene:Scene):Promise
		{
			_scene = scene;
			scene.registerRoute("echo.out", function(value:*):void
			{
				trace(value);
			});
			return scene.connect();
		}
		
		private function CreateSceneAndConnect():void
		{
			var accountId:String = "local-test";
			var appId:String = "wsstring";
			var sceneId:String = "echo-main";
			
			var config:Configuration = Configuration.forAccount("http://127.0.0.1:8081/", accountId, appId);
			
			var client:Client = new Client(config);
			
			client.getPublicScene(sceneId, 1).then(initAndConnectScene).then(sendSomething).then(onssuccess, onfailure);
		}
		
		private function sendSomething():void
		{
			this._scene.send("echo.in", "test");
		}
		
		private function onssuccess():void
		{
			trace("success!");
		}
		
		private function onfailure(error:*):void
		{
			trace(error);
		}
	
	}

}