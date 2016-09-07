package Stormancer.Transports
{
	import Stormancer.Core.ConnectionPacket;
	import Stormancer.Infrastructure.MessageIDTypes;
	import Stormancer.Util.CancellationToken;
	import Stormancer.Infrastructure.IConnectionManager;
	import Stormancer.Infrastructure.ITransport;
	import com.codecatalyst.promise.Deferred;
	import com.codecatalyst.promise.Promise;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class WebSocketTransport implements ITransport
	{
		private var _isRunning:Boolean = false;
		private const _name:String = "websocket";
		private var _id:ByteArray;
		
		private var _connectionManager:IConnectionManager;
		private var _socket:WebSocket = null;
		private var _connecting:Boolean = false;
		private var _connection:WebSocketConnection = null;
		
		private var _packetReceived:Vector.<Function> = new Vector.<Function>();
		private var _connectionOpened:Vector.<Function> = new Vector.<Function>();
		private var _ConnectionClosed:Vector.<Function> = new Vector.<Function>();
		
		public function WebSocketTransport()
		{
		}
		
		/* INTERFACE Stormancer.Infrastructure.ITransport */
		
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get id():ByteArray
		{
			return _id;
		}
		
		public function get packetReceived():Vector.<Function>
		{
			return _packetReceived;
		}
		
		public function get connectionOpened():Vector.<Function>
		{
			return _connectionOpened;
		}
		
		public function get ConnectionClosed():Vector.<Function>
		{
			return _ConnectionClosed;
		}
		
		public function start(type:String, handler:IConnectionManager, token:CancellationToken):Promise
		{
			this._connectionManager = handler;
			this._isRunning = true;
			
			token.onCancelled(this.stop);
			
			return Promise.when(null);
		}
		
		private function stop():void
		{
			this._isRunning = false;
			if (this._socket != null)
			{
				this._socket.close();
				this._socket = null;
			}
		}
		
		public function connect(endpoint:String):Promise
		{
			if (this._socket == null && !this._connecting)
			{
				this._connecting = true;
				var socket:WebSocket = new WebSocket(endpoint + "/", "*");
				
				var deferred:Deferred = new Deferred();
				var self:WebSocketTransport = this;
				
				socket.addEventListener(WebSocketEvent.OPEN, function(e:WebSocketEvent):void
				{
					self.onOpen(deferred);
				});
				socket.addEventListener(WebSocketEvent.MESSAGE, onMessage);
				socket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, function(e:WebSocketErrorEvent):void
				{
					self.onClosed(deferred);
				});
				socket.addEventListener(WebSocketEvent.CLOSED, function(e:WebSocketEvent):void
				{
					self.onClosed(deferred);
				});
				
				this._socket = socket;
				socket.connect();
				return deferred.promise;
			}
			else
			{
				throw new Error("This transport is already connected.");
			}
		}
		
		private function createNewConnection(socket:WebSocket):WebSocketConnection
		{
			var cid:Number = this._connectionManager.generateNewConnectionId();
			return new WebSocketConnection(cid, socket);
		}
		
		private function onOpen(deferred:Deferred):void
		{
			this._connecting = false;
			var connection:WebSocketConnection = this.createNewConnection(this._socket);
			
			this._connectionManager.newConnection(connection);
			for (var i:Number = 0; i < this._connectionOpened.length; i++)
			{
				this.connectionOpened[i](connection);
			}
			
			this._connection = connection;
			deferred.resolve(connection);
		}
		
		private function onClosed(deferred:Deferred):void
		{
			if (this._connection == null)
			{
				deferred.reject(new Error("Can't connect WebSocket to server."));
				this._socket = null;
			}
			else
			{
				this._connectionManager.closeConnection(this._connection, "DISCONNECTED");
				
				for (var i:Number = 0; i < this._ConnectionClosed.length; i++)
				{
					this._ConnectionClosed[i](this._connection);
				}
			}
		}
		
		private function onMessage(e:WebSocketEvent):void
		{
			var data :ByteArray = e.message.binaryData;
			if (this._connection != null)
			{
				var packet :ConnectionPacket = new ConnectionPacket(this._connection, data);
				
				if (data[0] == MessageIDTypes.ID_CONNECTION_RESULT)
				{
					var id :ByteArray = new ByteArray();
					data.position = 1;
					data.readBytes(id, 0, 8); 
					_id = id;
				}
				else
				{
					for (var i :Number = 0; i < this.packetReceived.length; i++)
					{
						this.packetReceived[i](packet);
					}
				}
			}
		}
	}

}