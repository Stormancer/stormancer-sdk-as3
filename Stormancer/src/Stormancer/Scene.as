package Stormancer
{
	import Stormancer.Client;
	import Stormancer.Core.IConnection;
	import Stormancer.Infrastructure.Route;
	
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
		
		//TODO implement scene
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
		}
		
		public function get id():String
		{
			return _id;
		}
	
	}

}