package Stormancer.Processors
{
	import Stormancer.Core.ConnectionPacket;
	import Stormancer.Infrastructure.IPacketProcessor;
	import Stormancer.Infrastructure.MessageIDTypes;
	import Stormancer.Infrastructure.PacketProcessorConfig;
	import Stormancer.Scene;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class SceneDispatcher implements IPacketProcessor
	{
		private var _scenes:Object = {};
		private var _buffers:Object = {};
		
		public function SceneDispatcher()
		{
		}
		
		/* INTERFACE Stormancer.Infrastructure.IPacketProcessor */
		
		public function registerProcessor(config:PacketProcessorConfig):void
		{
			config.addCatchAllProcessor(handler);
		}
		
		private function handler(sceneHandle:Number, packet:ConnectionPacket):Boolean
		{
			if (sceneHandle < MessageIDTypes.ID_SCENES)
			{
				return false;
			}
			
			var sceneIndex:Number = sceneHandle - MessageIDTypes.ID_SCENES;
			var scene:Scene = this._scenes[sceneIndex];
			if (!scene)
			{
				var buffer:Vector.<ConnectionPacket> = this._buffers[sceneIndex];
				if (buffer != null)
				{
					buffer = new Vector.<ConnectionPacket>();
					this._buffers[sceneIndex] = buffer;
				}
				
				buffer.push(packet);
				return true;
			}
			else
			{
				packet.setMetadataValue("scene", scene);
				scene.handleMessage(packet);
				return true;
			}
		}
		
		public function addScene(scene:Scene):void
		{
			var sceneIndex:Number = scene.handle - MessageIDTypes.ID_SCENES;
			this._scenes[sceneIndex] = scene;
			var buffer:Vector.<ConnectionPacket> = this._buffers[sceneIndex];
			if (buffer)
			{
				delete this._buffers[sceneIndex];
				while (buffer.length > 0)
				{
					var packet:ConnectionPacket = buffer.pop();
					packet.setMetadataValue("scene", scene);
					scene.handleMessage(packet);
				}
			}
		}
		
		public function removeScene(sceneHandle:Number):void
		{
			delete this._scenes[sceneHandle - MessageIDTypes.ID_SCENES];
		}
	
	}

}