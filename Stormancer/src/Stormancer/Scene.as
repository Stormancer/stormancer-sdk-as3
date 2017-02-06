package Stormancer
{
	import Stormancer.Client;
	import Stormancer.Core.ConnectionPacket;
	import Stormancer.Core.IConnection;
	import Stormancer.Core.IDependencyResolver;
	import Stormancer.Core.IScenePeer;
	import Stormancer.Core.PeerPacket;
	import Stormancer.Core.ScenePeer;
	import Stormancer.Infrastructure.Route;
	import adobe.utils.CustomActions;
	import com.codecatalyst.promise.Promise;
	import flash.errors.IllegalOperationError;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class Scene
	{
		private var _id:String;
		private var _token:String;
		private var _client:Client;
		private var _hostConnection:IConnection;
		private var _metadata:Object;
		private var _remoteRoutes:Object = {};
		private var _handle:Number = undefined;
		private var _connected:Boolean = false;
		private var _localRoutes:Object = {};
		private var _handlers:Object = {};
		private var _packetReceived:Vector.<Function> = new Vector.<Function>();
		private var _dependencyResolver : IDependencyResolver;
		
		private var _onDisconnection : Vector.<Function> = new Vector.<Function>();
		public function get onDisconnection():Vector.<Function> 
		{
			return _onDisconnection;
		}
		
		public function Scene(connection:IConnection, client:Client, id:String, token:String, dto:*)
		{
			this._hostConnection = connection;
			this._client = client;
			this._token = token;
			this._id = id;
			this._metadata = dto.Metadata;
			
			for (var i:Number = 0; i < dto.Routes.length; i++)
			{
				var route:* = dto.Routes[i];
				this._remoteRoutes[route.Name] = new Route(this, route.Name, route.Handle, route.Metadata);
			}
			
			this._dependencyResolver = client.dependencyResolver.createChildResolver();
			this._dependencyResolver.registerComponent("scene", this);
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get handle():Number
		{
			return _handle;
		}
		
		public function get connected():Boolean
		{
			return _connected;
		}
		
		public function get host():IScenePeer
		{
			return new ScenePeer(this._hostConnection, this._handle, this._remoteRoutes, this);
		}
		
		public function get dependencyResolver():IDependencyResolver 
		{
			return _dependencyResolver;
		}
		
		public function getHostMetadata(key:String):String
		{
			return this._metadata[key];
		}
		
		public function addRoute(route:String, handler:Function, metadata:Object = null):void
		{
			if (!metadata)
			{
				metadata = {};
			}
			if (route.charAt(0) === '@')
			{
				throw new IllegalOperationError("A route cannot start with the @ character");
			}
			
			if (this.connected)
			{
				throw new IllegalOperationError("You cannot register handles once the scene is connected.");
			}
			
			var routeObj:Route = this._localRoutes[route];
			if (!routeObj)
			{
				routeObj = new Route(this, route, 0, metadata);
				this._localRoutes[route] = routeObj;
			}
			
			this.onMessageImpl(routeObj, handler);
		}
		
		public function registerRoute(route:String, handler:Function, metadata:Object = null):void
		{
			var self:Scene = this;
			this.addRoute(route, function(packet:PeerPacket):void
			{
				var data:* = self._hostConnection.serializer.deserialize(packet.data);
				handler(data);
			}, metadata);
		}
		
		private function onMessageImpl(route:Route, handler:Function):void
		{
			var self:Scene = this;
			var action:Function = function(p:ConnectionPacket):void
			{
				var packet:PeerPacket = new PeerPacket(self.host, p.data, p.metadata);
				handler(packet);
			};
			
			route.handlers.push(action);
		}
		
		public function sendPacket(route:String, writer:Function):void
		{
			if (!route)
			{
				throw new ArgumentError("route cannot be null or undefined.");
			}
			if (writer == null)
			{
				throw new ArgumentError("data to send cannot be null or undefined.");
			}
			if (!this.connected)
			{
				throw new IllegalOperationError("The scene must be conneced to perform this operation.");
			}
			
			var routeObj:Route = this._remoteRoutes[route];
			if (!routeObj)
			{
				throw new IllegalOperationError("The route " + route + " doesn't exist on this scene.");
			}
			
			this._hostConnection.sendToScene(this._handle, routeObj.handle, writer);
		}
		
		public function send(route:String, data:*):void
		{
			var self:Scene = this;
			return this.sendPacket(route, function(stream:IDataOutput):void
			{
				self._hostConnection.serializer.serialize(data, stream);
			});
		}
		
		public function connect():Promise
		{
			var routes:Vector.<Route> = new Vector.<Route>();
			for (var key:String in this._localRoutes)
			{
				routes.push(this._localRoutes[key]);
			}
			
			return this._client.connectToScene(this, this._token, routes).then(connectCallback);
		}
		
		public function completeConnectionInitialization(connectionResult:*):void
		{
			this._handle = connectionResult.SceneHandle;
			
			for (var key:String in this._localRoutes)
			{
				var route:Route = this._localRoutes[key];
				route.handle = connectionResult.RouteMappings[key];
				this._handlers[route.handle] = route.handlers;
			}
		}
		
		public function handleMessage(packet:ConnectionPacket):void
		{
			var apply:Function = function(value:Function):void
			{
				value(packet);
			};
			
			this._packetReceived.map(apply);
			
			packet.data.endian = Endian.LITTLE_ENDIAN;
			var routeId:Number = packet.data.readUnsignedShort();
			packet.data.endian = Endian.BIG_ENDIAN;
			
			packet.setMetadataValue("routeId", routeId);
			
			var observer:Vector.<Function> = this._handlers[routeId];
			if (observer)
			{
				for (var i : Number = 0; i < observer.length; i++)
				{
					observer[i](packet);
				}
			}
		}
		
		private function connectCallback():void
		{
			this._connected = true;
		}
		
		public function addPacketReceivedHandler(handler:Function):void
		{
			this._packetReceived.push(handler);
		}
		
		public function disconnect() : Promise
		{
			this._connected = false;
			return this._client.disconnect(this, this._handle, true);
		}
		
		public function onDisconnect(reason:String):void 
		{
			this._connected = false;
			for (var i:int; i < _onDisconnection.length; i++)
			{
				var callback : Function = _onDisconnection[i];
				if (callback)
				{
					callback(reason);
				}
			}
			this._client.disconnect(this, this._handle, false); 
		}
	}

}