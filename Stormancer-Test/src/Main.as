package
{
	import Stormancer.Client;
	import Stormancer.Configuration;
	import Stormancer.Plugins.RpcService;
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
			scene.onDisconnection.push(function(reason:String) : void
			{
				trace(reason);
			});
			return scene.connect();
		}
		
		private function CreateSceneAndConnect():void
		{
			var accountId:String = "localtest";
			//var accountId:String = "jn-test";
			
			var appId:String = "echo";
			var sceneId:String = "echo-main";
			
			var config:Configuration = Configuration.forAccount("http://192.168.1.138:8081/", accountId, appId);
			
			//var config:Configuration = Configuration.forAccount("https://api.stormancer.com/", accountId, appId);
			
			var client:Client = new Client(config);
			
			client.getPublicScene(sceneId, 1).then(initAndConnectScene).then(sendSomething).then(onSuccess, onfailure);
		}
		
		private function sendSomething():void
		{
			this._scene.send("echo.in", "test");
		}
		
		private function onSuccess():void
		{
			trace("success!");
		//	this._scene.disconnect().then(onDisconnectedSuccess, onfailure);
		}
		
		private function onDisconnectedSuccess():void
		{
			trace("disconnected from scene");		
		}
		
		private function onfailure(error:*):void
		{
			trace("failure!");
			trace(error);
		}
	
	}

}