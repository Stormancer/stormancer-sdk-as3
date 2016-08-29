package Stormancer.Core
{
	import flash.utils.IDataInput;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public class Packet
	{
		private var _metadata:Object = {};
		
		private var _data:IDataInput;
		
		public function Packet(data:IDataInput, metadata:Object = null)
		{
			if (metadata != null)
			{
				this._metadata = metadata;
			}
			this._data = data;
		}
		
		public function get metadata():Object
		{
			return _metadata;
		}
		
		public function get data():IDataInput
		{
			return _data;
		}
		
		public function setMetadataValue(key:String, value:*):void
		{
			this._metadata[key] = value;
		}
		
		public function getMetadataValue(key:String):*
		{
			return this._metadata[key];
		}
		
		internal var toto : Number;
	
	}

}