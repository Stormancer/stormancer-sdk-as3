package Stormancer.Plugins 
{
	import Stormancer.Scene;
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class RpcClientPlugin implements IClientPlugin 
	{		
		public static const NextRouteName : String = "stormancer.rpc.next";
		public static const ErrorRouteName : String = "stormancer.rpc.error";
		public static const CompletedRouteName :String = "stormancer.rpc.completed";
		public static const CancellationRouteName : String = "stormancer.rpc.cancel";
		public static const Version: String = "1.1.0";
		public static const PluginName :String = "stormancer.plugin.rpc";
		public static const ServiceName :String = "rpcService";
			
		
		public function RpcClientPlugin() 
		{
			
		}		
		
		/* INTERFACE Stormancer.Plugins.IClientPlugin */
		
		public function build(ctx:PluginBuildContext):void 
		{
			ctx.sceneCreated.push(OnSceneCreated);
			ctx.sceneDisconnected.push(OnSceneDisconnected);
		}		
		
		private function OnSceneCreated(scene: Scene):void 
		{
			var rpcParams : String = scene.getHostMetadata(PluginName);
			
			if (rpcParams)
			{
				var processor : RpcService = new RpcService(scene);
				scene.dependencyResolver.registerComponent(ServiceName, processor);
				
				scene.addRoute(NextRouteName, processor.next);
				scene.addRoute(CancellationRouteName, processor.cancel);
				scene.addRoute(ErrorRouteName, processor.error);
				scene.addRoute(CompletedRouteName, processor.complete);
			}
		}
		
		private function OnSceneDisconnected(scene: Scene):void 
		{
			var processor :RpcService = scene.dependencyResolver.getComponent(ServiceName);
			processor.disconnected();
		}
		
	}

}