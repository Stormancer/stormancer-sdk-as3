package Stormancer.Plugins
{
	import Stormancer.Core.ISerializer;
	import Stormancer.Core.PeerPacket;
	import Stormancer.Infrastructure.ISubscription;
	import Stormancer.Infrastructure.Observer;
	import Stormancer.Infrastructure.Route;
	import Stormancer.Infrastructure.Subscription;
	import Stormancer.Scene;
	import Stormancer.Util.CancellationToken;
	import Stormancer.Util.CancellationTokenSource;
	import Stormancer.Util.Helpers;
	import com.codecatalyst.promise.Deferred;
	import flash.errors.IllegalOperationError;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class RpcService
	{
		
		private var _pendingRequests:Object = {};
		private var _runningRequests:Object = {};
		private var _scene:Scene;
		private var _currentRequestId:Number = 0;
		
		private function get serializer():ISerializer
		{
			return this._scene.dependencyResolver.getComponent("serializer");
		}
		
		public function RpcService(scene:Scene)
		{
			this._scene = scene;
		}
		
		public function next(packet:PeerPacket):void
		{
			var request:RpcRequest = this.getPendingRequest(packet);
			
			if (request)
			{
				request.receivedMessages++;
				request.observer.OnNext(packet);
				request.deferred.resolve(null);
			}
		}
		
		private function getPendingRequest(packet:PeerPacket):RpcRequest
		{
			var id:Number = packet.data.readUnsignedShort();
			return this._pendingRequests[id];
		}
		
		public function cancel(packet:PeerPacket):void
		{
			var id:String = this.computeId(packet);
			var cts:CancellationTokenSource = this._runningRequests[id];
			if (cts)
			{
				cts.cancel();
			}
		}
		
		private function computeId(packet:PeerPacket):String
		{
			var requestId:Number = packet.data.readUnsignedShort();
			return packet.source.id.toString() + "-" + requestId.toString();
		}
		
		public function error(packet:PeerPacket):void
		{
			var request:RpcRequest = this.getPendingRequest(packet);
			if (request)
			{
				delete this._pendingRequests[request.id];
				request.observer.OnError((ISerializer)(packet.source.dependencyResolver.getComponent("serializer")).deserialize(packet.data));
			}
		}
		
		public function complete(packet:PeerPacket):void
		{
			var messageSent:Boolean = packet.data.readBoolean();
			var request:RpcRequest = this.getPendingRequest(packet);
			if (request)
			{
				if (messageSent)
				{
					var self:RpcService = this;
					request.deferred.promise.then(function():void
					{
						delete self._pendingRequests[request.id];
						request.observer.OnCompleted();
					});
				}
				else
				{
					delete this._pendingRequests[request.id];
					request.observer.OnCompleted();
				}
			}
		}
		
		public function disconnected():void
		{
			for (var id:String in this._runningRequests)
			{
				if (this._runningRequests.hasOwnProperty(id))
				{
					(CancellationTokenSource)(this._runningRequests[id]).cancel();
				}
			}
		}
		
		public function rpc(route:String, writer:Function, onNext:Function, onError:Function = null, onCompleted:Function = null):ISubscription
		{
			if (onError == null)
			{
				onError = function(error:String):void
				{
				};
			}
			if (onCompleted == null)
			{
				onCompleted = function():void
				{
				};
			}
			
			var remoteRoutes:Object;
			var relevantRoute:Route;
			
			for (var i:String in remoteRoutes)
			{
				if (remoteRoutes[i].name == route)
				{
					relevantRoute = remoteRoutes[i];
					break;
				}
			}
			
			if (!relevantRoute)
			{
				throw new IllegalOperationError("The target route doies not exist on the remote host.");
			}
			
			if (relevantRoute.metadata[RpcClientPlugin.PluginName] != RpcClientPlugin.Version)
			{
				throw new IllegalOperationError("The target remote route does not support the RPC version " + RpcClientPlugin.Version);
			}
			
			var deferred:Deferred = new Deferred();
			var observer:Observer = new Observer(onNext, function(error:String):void
			{
				onError(error);
				deferred.reject(error);
			}, function():void
			{
				onCompleted();
				deferred.resolve(null);
			});
			
			var id:Number = this.reserveId();
			var request:RpcRequest = new RpcRequest(id, observer, deferred);
			
			this._pendingRequests[id] = request;
			this._scene.sendPacket(route, function(stream:IDataOutput):void
			{
				stream.writeShort(id);
				writer(stream);
			});
			
			var self:RpcService = this;
			return new Subscription(function():void
			{
				if (this._pendingRequests[id])
				{
					delete this._pendingRequests[id];
					self._scene.sendPacket(RpcClientPlugin.CancellationRouteName, function(stream:IDataOutput):void
					{
						stream.writeShort(id);
					});
				}
			});
		}
		
		private function reserveId():Number
		{
			for (var i:Number = 0; i < 0xffff; i++)
			{
				this._currentRequestId = (this._currentRequestId + 1) & 0xffff;
				if (!this._pendingRequests[this._currentRequestId])
				{
					return this._currentRequestId;
				}
			}
			
			throw new Error("Too many requests in progress, unable to start a new one");
		}
		
		public function addProcedure(route: String, handler: Function) : void
		{
			var metadatas : Object = {};
			metadatas[RpcClientPlugin.PluginName] = RpcClientPlugin.Version;
			var self : RpcService = this;
			this._scene.addRoute(route, function(packet: PeerPacket) : void 
			{
				var requestId : Number = packet.data.readUnsignedShort();
				var id : String = packet.source.id.toString() +"-" + requestId.toString();
				var cts : CancellationTokenSource = new CancellationTokenSource();
				var ctx : RpcRequestContext = new RpcRequestContext(packet.source, self._scene, requestId, packet.data, cts.token);
				if (!this._runningRequests[id])
				{
					this._runningRequests[id] = cts;
					Helpers.InvokeWrapping(handler, ctx).then(function () :void{
						delete self._runningRequests[id];
						ctx.sendCompleted();
					}, function(reason : * ) : void{
						delete self._runningRequests[id];
						ctx.sendError(reason);
					});					
				}
				else
				{
					throw new Error("Request already exists");
				}
			}, metadatas);
		}
	}
}
import Stormancer.Infrastructure.Observer;
import com.codecatalyst.promise.Deferred;

class RpcRequest
{
	public var observer:Observer;
	public var deferred:Deferred;
	public var receivedMessages:Number = 0;
	public var id:Number;
	
	public function RpcRequest(id:Number, observer:Observer, deferred:Deferred)
	{
		this.id = id;
		this.observer = observer;
		this.deferred = deferred;
	}
}