package
{
	import Stormancer.Client;
	import Stormancer.Configuration;
	import Stormancer.Infrastructure.ApiClient;
	import Stormancer.Infrastructure.TokenHandler;
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
		public function Main()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			var accountId:String = "local-test";
			var appId:String = "wsstring";
			var sceneId:String = "echo-main";
			
			var config:Configuration = Configuration.forAccount("http://127.0.0.1:8081/", accountId, appId);
			
			var client :Client = new Client(config);
			client.getPublicScene(sceneId, "").then(onssuccess, onfailure);
			//var apiClient:ApiClient = new ApiClient(config, new TokenHandler());
			//
			//apiClient.getSceneEndpoint(accountId, appId, sceneId, {blah: 4, chombier: "toto"}).then(onSuccess, onFailure);
		
	
		}
		
		private function onssuccess(scene : *):void 
		{
			trace(scene);
		}
		
		private function onfailure(error:*):void 
		{
			trace(error);
		}
		
		
		//private function onSuccess(endpoint:*):void
		//{
			//var msgpack:MsgPack = new MsgPack();
			//try
			//{
				//var userData:* = msgpack.read(endpoint.tokenData.UserData);
				//
			//}
			//catch (err:Error)
			//{
				//trace(err);
			//}
		//}
		//
		//private function onFailure(error:Error):void
		//{
			//trace(error);
		//}
	
	}

}