package Stormancer.Infrastructure
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class PacketProcessorConfig
	{
		private var _handlers:Object;
		private var _defaultProcessors:Vector.<Function>;
		
		public function PacketProcessorConfig(handlers:Object, defaultProcessors:Vector.<Function>)		
		{
			this._handlers = handlers;
			this._defaultProcessors = defaultProcessors;
		}
		
		/**
		 *
		 * @param	msgId
		 * @param	handler  A bool-returning function that takes a ConnectionPacket parameter
		 */
		public function addProcessor(msgId:*, handler:Function):void
		{
			if (this._handlers[msgId])
			{
				throw new IllegalOperationError("An handler is already registered for id " + msgId);
			}
			this._handlers[msgId] = handler;
		}
		
		public function addCatchAllProcessor(handler:Function):void
		{
			this._defaultProcessors.push(handler);
		}
	}

}