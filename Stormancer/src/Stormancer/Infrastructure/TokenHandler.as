package Stormancer.Infrastructure
{
	import Stormancer.Core.ISerializer;
	import Stormancer.Util.Helpers;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public class TokenHandler
	{
		private var _tokenSerializer:ISerializer = new MsgPackSerializer();
		
		public function TokenHandler()
		{
		}
		
		public function decodeToken(token:String):SceneEndpoint
		{
			token = token.replace(/"/g, '');
			var data:String = token.split('-')[0];
			var buffer:ByteArray = Helpers.base64ToByteArray(data);
			var rawConnectionData:* = this._tokenSerializer.deserialize(buffer);
			var connectionData:ConnectionData = new ConnectionData(rawConnectionData);
			
			return new SceneEndpoint(token, connectionData);
		}
	}

}