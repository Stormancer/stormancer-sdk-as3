package Stormancer.Core
{
	import flash.utils.IDataInput;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class ConnectionPacket extends Packet
	{
		private var _source:IConnection;
		
		public function ConnectionPacket(source:IConnection, data:IDataInput, metadata:Object = null)
		{
			super(data, metadata);
			this._source = source;
		}
		
		public function get source():IConnection 
		{
			return _source;
		}
	
	}

}