package Stormancer.Infrastructure
{
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public interface IPacketProcessor
	{
		function registerProcessor(config:PacketProcessorConfig):void;
	}

}