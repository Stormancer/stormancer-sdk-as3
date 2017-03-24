package Stormancer.Transports
{
	import Stormancer.Core.ConnectionState;
	import Stormancer.Core.IConnection;
	import Stormancer.Core.ISerializer;
	import com.worlize.websocket.WebSocket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class WebSocketConnection implements IConnection
	{
		private var _id:Number;
		private var _connectionDate:Date;
		private var _metadata:Object = {};
		private var _account:String;
		private var _serializer:ISerializer;
		private var _serializerChosen:Boolean = false;
		private var _socket:WebSocket;
		private var _state:Number;
		private var _application:String;
		
		private var _onDisconnection : Vector.<Function> = new Vector.<Function>();
		public function get onDisconnection():Vector.<Function> 
		{
			return _onDisconnection;
		}
		
		public function WebSocketConnection(id:Number, socket:WebSocket)
		{
			this._socket = socket;
			this._id = id;
			this._connectionDate = new Date();
			this._state = ConnectionState.Connected;
		}
		
		/* INTERFACE Stormancer.Core.IConnection */
		
		public function get id():Number
		{
			return _id;
		}
		
		public function get connectionDate():Date
		{
			return _connectionDate;
		}
		
		public function get metadata():Object
		{
			return _metadata;
		}
		
		public function get account():String
		{
			return _account;
		}
		
		public function get serializer():ISerializer
		{
			return _serializer;
		}
		
		public function set serializer(value:ISerializer):void
		{
			_serializer = value;
		}
		
		public function get serializerChosen():Boolean
		{
			return _serializerChosen;
		}
		
		public function set serializerChosen(value:Boolean):void
		{
			_serializerChosen = value;
		}
		
		public function get connectionState():Number
		{
			return this._state;
		}
		
		public function get application():String
		{
			return this._application;
		}
		
		public function close():void
		{
			this._socket.close();
		}
		
		public function sendSystem(msgId:Number, writer:Function):void
		{
			var buffer:ByteArray = new ByteArray();
			buffer.writeByte(msgId);
			writer(buffer);
			buffer.position = 0;
			
			this._socket.sendBytes(buffer);
		}
		
		public function sendToScene(sceneIndex:Number, route:Number, writer:Function):void
		{
			var buffer:ByteArray = new ByteArray();
			buffer.writeByte(sceneIndex);
			buffer.endian = Endian.LITTLE_ENDIAN;
			buffer.writeShort(route);
			buffer.endian = Endian.BIG_ENDIAN;
			writer(buffer);
			buffer.position = 0;
			
			this._socket.sendBytes(buffer);
		}
		
		public function setApplication(account:String, application:String):void
		{
			this._account = account;
			this._application = application;
		}
		
		public function void onDisconnect(reason:String):void
		{
			this._state = ConnectionState.Disconnected;
			for (var i:int; i < _onDisconnection.length; i++)
			{
				var callback : Function = _onDisconnection[i];
				if (callback != null)
				{
					callback(reason);
				}
			}
		}
	}
}