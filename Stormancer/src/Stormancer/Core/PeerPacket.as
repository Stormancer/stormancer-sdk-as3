package Stormancer.Core
{
	import flash.utils.IDataInput;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class PeerPacket extends Packet
	{
		private var _source:IScenePeer;
		
		public function PeerPacket(source:IScenePeer, data:IDataInput, metadata:Object = null)
		{
			super(data, metadata);
			this._source = source;
		}
		
		public function get source():IScenePeer
		{
			return _source;
		}
	
	}

}