package Stormancer.Core
{
	import Stormancer.Infrastructure.Route;
	import Stormancer.Scene;
	import flash.errors.IllegalOperationError;
	import flash.utils.IDataInput;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class ScenePeer implements IScenePeer
	{
		private var _id:Number;
		private var _connection:IConnection;
		private var _sceneHandle:Number;
		private var _routeMapping:Object;
		private var _scene:Scene;
		private var _serializer:ISerializer;
		private var _dependencyResolver : IDependencyResolver;
		
		public function ScenePeer(connection:IConnection, sceneHandle:Number, routeMapping:Object, scene:Scene)
		{
			this._connection = connection;
			this._sceneHandle = sceneHandle;
			this._routeMapping = _routeMapping;
			this._scene = scene;
			this._serializer = connection.serializer;
			this._id = this._connection.id;
			this._dependencyResolver = scene.dependencyResolver.createChildResolver();
		}
		
		/* INTERFACE Stormancer.Core.IScenePeer */
		
		public function get id():Number
		{
			return _id;
		}
		
		public function get serializer():ISerializer
		{
			return _serializer;
		}
		
		public function get dependencyResolver():IDependencyResolver 
		{
			return _dependencyResolver;
		}
		
		public function send(route:String, writer:Function):void
		{
			var r : Route = this._routeMapping[route];
			if (!r)
			{
				throw new IllegalOperationError("The route " + route +" is not declared on the server"); 
			}
			this._connection.sendToScene(this._sceneHandle, r.handle, writer);
		}	
	}

}