package Stormancer
{
	import Stormancer.Core.ISerializer;
	import Stormancer.Infrastructure.DefaultDispatcher;
	import Stormancer.Infrastructure.IPacketDispatcher;
	import Stormancer.Infrastructure.ITransport;
	import Stormancer.Infrastructure.MsgPackSerializer;
	import Stormancer.Plugins.IClientPlugin;
	import Stormancer.Transports.WebSocketTransport;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class Configuration
	{
		
		private var _serverEndpoint:String;
		private var _account:String;
		private var _application:String;
		private var _transport:ITransport;
		private var _dispatcher:IPacketDispatcher
		private var _serializers:Vector.<ISerializer> = new Vector.<ISerializer>();
		private var _plugins : Vector.<IClientPlugin> = new Vector.<IClientPlugin>();
		
		public function Configuration()
		{
			this._transport = new WebSocketTransport();
			this._dispatcher = new DefaultDispatcher();
			this._serializers.push(new MsgPackSerializer());
			
						//TODO : add RPCPlugin

		}
		
		internal var metadata:Object = {};
		
		public function Metadata(key:String, value:String):Configuration
		{
			this.metadata[key] = value;
			return this;
		}
		
		public function get application():String
		{
			return _application;
		}
		
		public function set application(value:String):void
		{
			_application = value;
		}
		
		public function get serverEndpoint():String
		{
			return _serverEndpoint;
		}
		
		public function set serverEndpoint(value:String):void
		{
			_serverEndpoint = value;
		}
		
		public function get account():String
		{
			return _account;
		}
		
		public function set account(value:String):void
		{
			_account = value;
		}
		
		public function get dispatcher():IPacketDispatcher
		{
			return _dispatcher;
		}
		
		public function set dispatcher(value:IPacketDispatcher):void
		{
			_dispatcher = value;
		}
		
		public function get serializers():Vector.<ISerializer>
		{
			return _serializers;
		}
		
		public function get transport():ITransport
		{
			return _transport;
		}
		
		public function set transport(value:ITransport):void
		{
			_transport = value;
		}
		
		public function get plugins():Vector.<IClientPlugin> 
		{
			return _plugins;
		}
		
		public static function forAccount(serverEndpoint:String, accountId:String, applicationName:String):Configuration
		{
			var config:Configuration = new Configuration();
			config._serverEndpoint = serverEndpoint;
			config._account = accountId;
			config._application = applicationName;
			return config;
		}
	}

}