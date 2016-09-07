package Stormancer.Infrastructure
{
	import flash.utils.ByteArray;
	import org.msgpack.MsgPack;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	internal final class ConnectionData
	{
		public var Endpoints:Object;
		public var AccountId:String;
		public var Application:String;
		public var SceneId:String;
		public var Routing:String;
		public var Issued:Number;
		public var Expiration:Number;
		public var UserData:ByteArray;
		public var ContentType:String;
		public var Version:Number;
		
		public function ConnectionData(dynamicData:* = null)
		{
			if (dynamicData != null)
			{
				this.Endpoints = dynamicData.Endpoints;
				this.AccountId = dynamicData.AccountId;
				this.Application = dynamicData.Application;
				this.SceneId = dynamicData.SceneId;
				this.Routing = dynamicData.Routing;
				this.Issued = dynamicData.Issued;
				this.Expiration = dynamicData.Expiration;
				
				if (dynamicData.UserData is ByteArray)
				{
					this.UserData = dynamicData.UserData;
				}
				
				this.ContentType = dynamicData.ContentType;
				this.Version = dynamicData.Version;
			}
		}
	
	}

}