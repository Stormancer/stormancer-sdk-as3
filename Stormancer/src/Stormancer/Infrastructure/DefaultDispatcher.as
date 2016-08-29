package Stormancer.Infrastructure
{
	import Stormancer.Core.ConnectionPacket;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class DefaultDispatcher implements IPacketDispatcher
	{
		private var _handlers:Object = {};
		private var _defaultProcessors:Vector.<Function> = new Vector.<Function>();
		
		public function DefaultDispatcher()
		{
		
		}
		
		/* INTERFACE Stormancer.Infrastructure.IPacketDispatcher */
		
		public function dispatchPacket(packet:ConnectionPacket):void
		{
			var processed:Boolean = false;
			var count:Number = 0;
			var msgType:Number = 0;
			while (!processed && count < 40)
			{
				msgType = packet.data.readUnsignedByte();
				if (this._handlers[msgType])
				{
					processed = this._handlers[msgType](packet);
					count++;
				}
				else
				{
					break;
				}
			}
			
			for (var i : Number = 0; i < this._defaultProcessors.length; i++)
			{
				if (this._defaultProcessors[i](msgType, packet))
				{
					processed = true;
					break;
				}
			}
			
			if (!processed)
			{
				throw new Error("Couldn't process message. msgId: " + msgType);				
			}
		}
		
		public function addProcessor(processor:IPacketProcessor):void
		{
			processor.registerProcessor(new PacketProcessorConfig(this._handlers, this._defaultProcessors));
		}	
	}

}