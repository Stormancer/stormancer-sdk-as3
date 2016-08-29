package Stormancer.Processors
{
	import Stormancer.Core.ConnectionPacket;
	import Stormancer.Infrastructure.MessageIDTypes;
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	internal final class RequestContext
	{
		private var _packet:ConnectionPacket;
		private var _requestId:ByteArray;
		private var _didSendValues:Boolean = false;
		
		private var _inputData:IDataInput;
		private var _isComplete:Boolean = false;
		
		public function RequestContext(packet:ConnectionPacket)
		{
			this._packet = packet;
			var requestId:ByteArray = new ByteArray();
			packet.data.readBytes(requestId, 0, 2);
			requestId.position = 0;
			this._requestId = requestId;
			
			var data:ByteArray = new ByteArray();
			packet.data.readBytes(data);
			data.position = 0;
			_inputData = data;
		}
		
		public function get isComplete():Boolean
		{
			return _isComplete;
		}
		
		public function get inputData():IDataInput
		{
			return _inputData;
		}
		
		public function get packet():ConnectionPacket
		{
			return _packet;
		}
		
		/**
		 *
		 * @param	writer Function taking an IDataOutput stream as a parameter to write data to send as a response to the request.
		 */
		public function send(writer:Function):void
		{
			if (this.isComplete)
			{
				throw new IllegalOperationError("The request is already completed");
			}
			this._didSendValues = true;
			
			this._packet.source.sendSystem(MessageIDTypes.ID_REQUEST_RESPONSE_MSG, function(stream:IDataOutput):void
			{
				stream.writeBytes(_requestId);
				writer(stream);
			});
		}
		
		public function complete():void
		{
			this._packet.source.sendSystem(MessageIDTypes.ID_REQUEST_RESPONSE_COMPLETE, this.writeComplete);
		}
		
		private function writeComplete(stream:IDataOutput):void
		{
			stream.writeBytes(this._requestId);
			stream.writeBoolean(this._didSendValues);
		}
		
		public function error(writer:Function):void
		{
			this._packet.source.sendSystem(MessageIDTypes.ID_REQUEST_RESPONSE_ERROR, function(stream:IDataOutput):void
			{
				stream.writeBytes(_requestId);
				writer(stream);
			});		
		}
	}

}