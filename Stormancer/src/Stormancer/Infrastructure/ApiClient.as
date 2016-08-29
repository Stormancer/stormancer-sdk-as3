package Stormancer.Infrastructure
{
	import Stormancer.Configuration;
	import Stormancer.Core.ISerializer;
	import Stormancer.Util.Helpers;
	import com.codecatalyst.promise.Deferred;
	import com.codecatalyst.promise.Promise;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class ApiClient
	{
		private var _config:Configuration;
		private var _tokenHandler:TokenHandler;
		
		private static const createTokenUri:String = "/{0}/{1}/scenes/{2}/token";
		
		public function ApiClient(config:Configuration, tokenHandler:TokenHandler)
		{
			this._tokenHandler = tokenHandler;
			this._config = config;
		
		}
		
		public function getSceneEndpoint(accountId:String, applicaionName:String, sceneId:String, userData:*):Promise
		{
			var serializer:ISerializer = new MsgPackSerializer();
			
			var url:String = this._config.serverEndpoint + Helpers.stringFormat(createTokenUri, accountId, applicaionName, sceneId);
			
			var requestData:ByteArray = new ByteArray();
			serializer.serialize(userData, requestData);
			
			var request:URLRequest = new URLRequest(url);
			request.data = requestData;
			request.method = "POST";
			request.contentType = "application/msgpack";
			request.requestHeaders = [new URLRequestHeader("Accept", "application/json"), new URLRequestHeader("x-version", "1.0.0")];
			
			var deferred:Deferred = new Deferred();
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			var that:ApiClient = this;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				try
				{
					var token:Object = JSON.parse(e.target.data);
					
					var result:SceneEndpoint = that._tokenHandler.decodeToken(token as String);
					
					deferred.resolve(result);
				}
				catch (err:Error)
				{
					deferred.reject(err);
				}
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
			{
				deferred.reject(new Error(e.text, e.errorID));
			});
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void
			{
				deferred.reject(new Error(e.text, e.errorID));
			});
			
			loader.load(request);
			return deferred.promise;
		}
	}

}