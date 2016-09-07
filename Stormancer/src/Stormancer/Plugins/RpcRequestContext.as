package Stormancer.Plugins 
{
	import Stormancer.Core.IScenePeer;
	import Stormancer.Core.ISerializer;
	import Stormancer.Processors.RequestProcessor;
	import Stormancer.Scene;
	import Stormancer.Util.CancellationToken;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class RpcRequestContext 
	{
		private var _scene : Scene;
		private var _peer : IScenePeer;
		private var _id : Number;
		private var _data: IDataInput;
		private var _token: CancellationToken;
		private var _msgSent : Number = 0;
		
		public function RpcRequestContext(peer: IScenePeer, scene: Scene, id: Number, data: IDataInput, token: CancellationToken) 
		{
			this._scene = scene;
			this._peer = peer;
			this._id = id;
			this._data = data;
			this._token = token;
		}
		
		public function get peer():IScenePeer 
		{
			return _peer;
		}
		
		public function get data():IDataInput 
		{
			return _data;
		}
		
		public function get cancellationToken():CancellationToken 
		{
			return _token;
		}
		
		private function writeRequestId(stream : IDataOutput) : void
		{
			stream.writeShort(this._id);
		}
		
		public function sendValue(writer: Function): void
		{
			var self : RpcRequestContext = this;
			this._scene.sendPacket(RpcClientPlugin.NextRouteName, function(stream : IDataOutput) : void
			{
				self.writeRequestId(stream);
				writer(stream);
			});
			this._msgSent = 1;
		}
		
		public function sendError(errorMsg : String): void
		{
			var self: RpcRequestContext = this;
			this._scene.sendPacket(RpcClientPlugin.ErrorRouteName, function (stream:IDataOutput): void
			{
				self.writeRequestId(stream);
				(ISerializer)(self._peer.dependencyResolver.getComponent("serializer")).serialize(errorMsg, stream);
			});
		}
		
		public function sendCompleted() :void
		{
			var self: RpcRequestContext = this;
			this._scene.sendPacket(RpcClientPlugin.CompletedRouteName, function(stream : IDataOutput) : void
			{
				stream.writeByte(self._msgSent);
				self.writeRequestId(stream);				
			});
		}
	}

}