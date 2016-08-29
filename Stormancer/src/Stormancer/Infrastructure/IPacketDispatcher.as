package Stormancer.Infrastructure
{
	import Stormancer.Core.ConnectionPacket;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public interface IPacketDispatcher
	{
		function dispatchPacket(packet:ConnectionPacket):void;
		function addProcessor(processor:IPacketProcessor):void;
	}

}