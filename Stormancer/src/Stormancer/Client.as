package Stormancer
{
	import Stormancer.Core.ConnectionPacket;
	import Stormancer.Core.ConnectionState;
	import Stormancer.Core.DefaultDependencyResolver;
	import Stormancer.Core.IConnection;
	import Stormancer.Core.IDependencyResolver;
	import Stormancer.Core.ISerializer;
	import Stormancer.Infrastructure.ApiClient;
	import Stormancer.Infrastructure.IPacketDispatcher;
	import Stormancer.Infrastructure.ITransport;
	import Stormancer.Infrastructure.MsgPackSerializer;
	import Stormancer.Infrastructure.Route;
	import Stormancer.Infrastructure.SceneEndpoint;
	import Stormancer.Infrastructure.SystemRequestIDTypes;
	import Stormancer.Infrastructure.TokenHandler;
	import Stormancer.Plugins.PluginBuildContext;
	import Stormancer.Processors.RequestProcessor;
	import Stormancer.Processors.SceneDispatcher;
	import Stormancer.Util.CancellationTokenSource;
	import Stormancer.Util.Helpers;
	import com.codecatalyst.promise.CancellationError;
	import com.codecatalyst.promise.Promise;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class Client
	{
		private var _apiClient:ApiClient;
		private var _accountId:String;
		private var _applicationName:String;
		
		private var _transport:ITransport;
		private var _dispatcher:IPacketDispatcher;
		
		private var _initialized:Boolean;
		private var _tokenHandler:TokenHandler = new TokenHandler();
		
		private var _requestProcessor:RequestProcessor = new RequestProcessor();
		private var _scenesDispatcher:SceneDispatcher;
		
		private var _serializers:Object = {"msgpack/map": new MsgPackSerializer()};
		
		private var _cts:CancellationTokenSource;
		private var _metadata:Object = {};
		
		private var _pluginCtx:PluginBuildContext = new PluginBuildContext();
		private var _id:Number = undefined;
		private var _serverTransportType:String = null;
		private var _serverConnection:IConnection = null;
		private var _systemSerializer:ISerializer = new MsgPackSerializer();
		
		private var _dependencyResolver:IDependencyResolver = new DefaultDependencyResolver();
		
		//TODO: sync clock
		
		public function Client(config:Configuration)
		{
			this._accountId = config.account;
			this._applicationName = config.application;
			this._apiClient = new ApiClient(config, this._tokenHandler);
			this._transport = config.transport;
			this._dispatcher = config.dispatcher;
			this._requestProcessor = new RequestProcessor();
			
			this._scenesDispatcher = new SceneDispatcher();
			this._dispatcher.addProcessor(this._requestProcessor);
			this._dispatcher.addProcessor(this._scenesDispatcher);
			
			this._metadata = config.metadata;
			
			for (var i:int = 0; i < config.serializers.length; i++)
			{
				var serializer:ISerializer = config.serializers[i];
				this._serializers[serializer.name] = serializer;
			}
			
			this._metadata["serializers"] = Helpers.mapKeys(this._serializers).join(',');
			this._metadata["transport"] = this._transport.name;
			this._metadata["version"] = "1.0.0a";
			this._metadata["platform"] = "AS";
			this._metadata["protocol"] = "2";
			
			for (var j:int = 0; j < config.plugins.length; j++)
			{
				config.plugins[j].build(this._pluginCtx);
			}
			
			for (var k:int = 0; k < this._pluginCtx.clientCreated.length; k++)
			{
				this._pluginCtx.clientCreated[k](this);
			}
			
			this._dependencyResolver.registerComponent("client", this);
			
			this.initialize();
		}
		
		public function get applicationName():String
		{
			return _applicationName;
		}
		
		public function get id():Number
		{
			return _id;
		}
		
		public function get serverTransportType():String
		{
			return _serverTransportType;
		}
		
		public function get dependencyResolver():IDependencyResolver
		{
			return _dependencyResolver;
		}
		
		public function getPublicScene(sceneId:String, userData:*):Promise
		{
			return this._apiClient.getSceneEndpoint(this._accountId, this._applicationName, sceneId, userData).then(function(ci:SceneEndpoint):Promise
			{
				return getSceneImpl(sceneId, ci);
			});
		}
		
		public function getScene(token:String):Promise
		{
			var ci:SceneEndpoint = this._tokenHandler.decodeToken(token);
			return this.getSceneImpl(ci.tokenData.SceneId, ci);
		}
		
		public function connectToScene(scene:Scene, token:String, localRoutes:Vector.<Route>):Promise
		{
			var parameter:* = {Token: token, Routes: [], ConnectionMetadata: this._serverConnection.metadata};
			
			for (var i:Number = 0; i < localRoutes.length; i++)
			{
				var r:Route = localRoutes[i];
				parameter.Routes.push({Handle: r.handle, Metadata: r.metadata, Name: r.name});
			}
			
			var self:Client = this;
			
			return this.sendSystemRequest(SystemRequestIDTypes.ID_CONNECT_TO_SCENE, parameter).then(function(result:*):void
			{
				scene.completeConnectionInitialization(result);
				self._scenesDispatcher.addScene(scene);
				for (var i:Number = 0; i < self._pluginCtx.sceneConnected.length; i++)
				{
					self._pluginCtx.sceneConnected[i](scene);
				}
			});
		}
		
		public function disconnect(scene:Scene, handle:Number, notifyServer:Boolean):Promise
		{
			SetConnectionState(Stormancer.Core.ConnectionState.Disconnecting);			
			var self:Client = this;
			var result : Promise;
			if (notifyServer)
			{
				
				result = this.sendSystemRequest(SystemRequestIDTypes.ID_DISCONNECT_FROM_SCENE, handle).then(function():void				
				{
					self.cleanSceneForDisconnection(scene, handle);
				});
			}
			else
			{
				this.cleanSceneForDisconnection(scene, handle);
				result = Promise.when(true);
			}
			
			return result.Then(function() :void
			{
				self.SetConnectionState(Stormancer.Core.ConnectionState.Disconnected);
			});
		}
		
		public function cleanSceneForDisconnection(scene:Scene, handle:Number):void
		{
			this._scenesDispatcher.removeScene(handle);
			for (var i:int = 0; i < this._pluginCtx.sceneDisconnected.length; i++)
			{
				this._pluginCtx.sceneDisconnected[i](scene);
			}
		}
		
		private function initialize():void
		{
			if (!this._initialized)
			{
				this._initialized = true;
				this._transport.packetReceived.push(transportPacketReceived);
					// TODO: add sync clock
			}
		}
		
		private function transportPacketReceived(packet:ConnectionPacket):void
		{
			for (var i:int = 0; i < this._pluginCtx.packetReceived.length; i++)
			{
				this._pluginCtx.packetReceived[i](packet);
			}
			this._dispatcher.dispatchPacket(packet);
		}
		
		private function getSceneImpl(sceneId:String, ci:SceneEndpoint):Promise
		{
			var self:Client = this;
			
			return this.ensureTransportStarted(ci).then(function():Promise
			{
				var parameter:* = {Metadata: self._serverConnection.metadata, Token: ci.token};
				return self.sendSystemRequest(SystemRequestIDTypes.ID_GET_SCENE_INFOS, parameter);
			}).then(handleSceneInfosDto).then(function(sceneInfosDto:*):Stormancer.Scene
			{
				var scene:Stormancer.Scene = new Stormancer.Scene(self._serverConnection, self, sceneId, ci.token, sceneInfosDto);
				
				for (var i:Number = 0; i < self._pluginCtx.sceneCreated.length; i++)
				{
					this._pluginCtx.sceneCreated[i](scene);
				}
				return scene;
			});
		
		}
		
		private function handleSceneInfosDto(sceneInfosDto:*):Promise
		{
			if (!this._serverConnection.serializerChosen)
			{
				var selectedSerializer:String = sceneInfosDto.SelectedSerializer;
				if (!selectedSerializer)
				{
					throw new Error("No serializer selected.");
				}
				this._serverConnection.serializer = this._serializers[selectedSerializer];
				this._serverConnection.metadata["serializer"] = selectedSerializer;
				this._serverConnection.serializerChosen = true;
				this._dependencyResolver.registerComponent("serializer", this._serializers[selectedSerializer]);
			}
			
			return this.updateMetadata().then(function():*
			{
				return sceneInfosDto;
			});
		}
		
		private function ensureTransportStarted(ci:SceneEndpoint):Promise
		{
			var self:Client = this;
			return Helpers.promiseIf(this._serverConnection == null, function():Promise
			{
				return Helpers.promiseIf(!this._transport.isRunning, this.startTransport, this).then(function():Promise
				{
					return self._transport.connect(ci.tokenData.Endpoints[self._transport.name]);
				}).then(function(c:IConnection):Promise
				{
					self.registerConnection(c);
					return self.updateMetadata();
				}).then(function():void
				{
					self.SetConnectionState(Stormancer.Core.ConnectionState.Connected);
				});
			}, this);
		}
		
		private function updateMetadata():Promise
		{
			var self:Client = this;
			return this._requestProcessor.sendSystemRequest(this._serverConnection, SystemRequestIDTypes.ID_SET_METADATA, function(stream:IDataOutput):void
			{
				self._systemSerializer.serialize(self._serverConnection.metadata, stream);
			});
		}
		
		private function registerConnection(connection:IConnection):void
		{
			this._serverConnection = connection;
			
			for (var key:String in this._metadata)
			{
				this._serverConnection.metadata[key] = this._metadata[key];
			}
			var self : Client = this;
			connection.onDisconnection.push(function(reason:String) :void{
				self.SetConnectionState(Stormancer.Core.ConnectionState.Disconnected);
			});
		}
		
		private function startTransport():Promise
		{
			this.SetConnectionState(Stormancer.Core.ConnectionState.Connecting);
			this._cts = new CancellationTokenSource();
			return this._transport.start("client", new ConnectionHandler(), this._cts.token);
		}
		
		private function sendSystemRequest(id:Number, parameter:*):Promise
		{
			var self:Client = this;
			return this._requestProcessor.sendSystemRequest(this._serverConnection, id, function(stream:IDataOutput):void
			{
				self._systemSerializer.serialize(parameter, stream);
			}).then(deserializeSystemResponse);
		}
		
		private function deserializeSystemResponse(packet:ConnectionPacket):*
		{
			if (packet != null)
			{
				return this._systemSerializer.deserialize(packet.data);
			}
			else
			{
				return null;
			}
		}
		
		private var _connectionState:Number = Stormancer.Core.ConnectionState.Disconnected;
		
		public function get ConnectionState():Number
		{
			return _connectionState;
		}
		
		private var _onConnectionStateChanged:Vector.<Function> = new Vector.<Function>();
		
		public function get OnConnectionStateChanged():Vector.<Function>
		{
			return _onConnectionStateChanged;
		}
		
		private function SetConnectionState(connectionState:Number):void
		{
			if (connectionState != this._connectionState)
			{
				this._connectionState = connectionState;
				
				for (var i:int; i < _onConnectionStateChanged.length; i++)
				{
					var callback:Function = _onConnectionStateChanged[i];
					if (callback != null)
					{
						callback(connectionState);
					}
				}
			}
		}
	}

}
import Stormancer.Core.IConnection;
import Stormancer.Infrastructure.IConnectionManager;

class ConnectionHandler implements IConnectionManager
{
	private var _current:Number = 0;
	
	public function ConnectionHandler()
	{
	
	}
	
	/* INTERFACE Stormancer.Infrastructure.IConnectionManager */
	
	public function generateNewConnectionId():Number
	{
		return this._current++;
	}
	
	public function newConnection(connection:IConnection):void
	{
	
	}
	
	public function closeConnection(connection:IConnection, reason:String):void
	{
	
	}
	
	public function getConnection(id:Number):IConnection
	{
		throw new Error("not implemented");
	}
	
	public function get ConnectionCount():Number
	{
		throw new Error("not implemented");
	}
}