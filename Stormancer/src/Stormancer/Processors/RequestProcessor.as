package Stormancer.Processors
{
	import Stormancer.Core.ConnectionPacket;
	import Stormancer.Core.IConnection;
	import Stormancer.Infrastructure.IPacketProcessor;
	import Stormancer.Infrastructure.MessageIDTypes;
	import Stormancer.Infrastructure.Observer;
	import Stormancer.Infrastructure.PacketProcessorConfig;
	import com.codecatalyst.promise.Deferred;
	import com.codecatalyst.promise.Promise;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class RequestProcessor implements IPacketProcessor
	{
		private var _pendingRequests:Object = {};
		private var _isRegistered:Boolean = false;
		private var _handlers:Object = {};
		private var _currentId:Number = 0;
		
		public function RequestProcessor()
		{
		
		}
		
		/* INTERFACE Stormancer.Infrastructure.IPacketProcessor */
		
		public function registerProcessor(config:PacketProcessorConfig):void
		{
			this._isRegistered = true;
			for (var key:String in this._handlers)
			{
				var handler:Function = this._handlers[key];
				config.addProcessor(key, function(p:ConnectionPacket):Boolean
				{
					var context:RequestContext = new RequestContext(p);
					
					var continuation:Function = function(fault:*):void
					{
						if (!context.isComplete)
						{
							if (fault)
							{
								context.error(function(stream:IDataOutput):void
								{
									p.source.serializer.serialize(fault, stream);
								});
							}
							else
							{
								context.complete();
							}
						}
					};
					
					var handlerPromise:Promise = handler(context);
					
					handlerPromise.then(function():void
					{
						continuation(null);
					}, continuation);
					
					return true;
				});
			}
			
			config.addProcessor(MessageIDTypes.ID_REQUEST_RESPONSE_MSG, processRequestResponse);
			config.addProcessor(MessageIDTypes.ID_REQUEST_RESPONSE_COMPLETE, processRequestComplete);
			config.addProcessor(MessageIDTypes.ID_REQUEST_RESPONSE_ERROR, processRequestError);
		}
		
		private function processRequestResponse(packet:ConnectionPacket):Boolean
		{
			var id:Number = packet.data.readShort();
			
			var request:SystemRequest = this._pendingRequests[id];
			if (request)
			{
				packet.setMetadataValue("request", request);
				request.lastRefresh = new Date();
				request.observer.OnNext(packet);
				request.deferred.resolve(null);
			}
			else
			{
				trace("Unknow request id.");
			}
			
			return true;
		}
		
		private function processRequestComplete(packet:ConnectionPacket):Boolean
		{
			var id:Number = packet.data.readShort();
			
			var request:SystemRequest = this._pendingRequests[id];
			if (request)
			{
				packet.setMetadataValue("request", request);
				
			}
			else
			{
				trace("Unknow request id.");
				return true;
			}
			
			delete this._pendingRequests[id];
			if (packet.data.readBoolean())
			{
				request.deferred.promise.always(request.observer.OnCompleted);
			}
			else
			{
				request.observer.OnCompleted();
			}
			return true;
		}
		
		private function processRequestError(packet:ConnectionPacket):Boolean
		{
			var id:Number = packet.data.readShort();
			
			var request:SystemRequest = this._pendingRequests[id];
			if (request)
			{
				packet.setMetadataValue("request", request);
			}
			else
			{
				trace("Unknow request id.");
				return true;
			}
			
			delete this._pendingRequests[id];
			
			var msg:* = packet.source.serializer.deserialize(packet.data);
			request.observer.OnError(new Error(msg));
			return true;
		}
		
		private function reserveRequestSlot(observer:Observer):SystemRequest
		{
			var i:Number = 0;
			while (i < 0xFFFF)
			{
				i++;
				this._currentId = (this._currentId + 1) & 0xFFFF;
				if (!this._pendingRequests[this._currentId])
				{
					var request:SystemRequest = new SystemRequest(this._currentId, observer, new Deferred());
					this._pendingRequests[this._currentId] = request;
					return request;
				}
			}
			
			throw new Error("Unable to create new request: Too many pending requests.");
		}
		
		public function sendSystemRequest(peer:IConnection, msgId:Number, writer:Function):Promise
		{
			var deferred:Deferred = new Deferred();
			
			var request:SystemRequest = this.reserveRequestSlot(new Observer(deferred.resolve, deferred.reject, function():void
			{
				deferred.resolve(null);
			}));
			
			peer.sendSystem(MessageIDTypes.ID_SYSTEM_REQUEST, function(stream:IDataOutput):void
			{
				stream.writeByte(msgId);
				stream.writeShort(request.id);
				writer(stream);
			});
			
			return deferred.promise;
		}
	}
}

import Stormancer.Infrastructure.Observer;
import com.codecatalyst.promise.Deferred;

class SystemRequest
{
	public var lastRefresh:Date;
	public var id:Number;
	public var observer:Observer;
	public var deferred:Deferred;
	
	public function SystemRequest(id:Number, observer:Observer, deferred:Deferred)
	{
		this.lastRefresh = new Date();
		this.id = id;
		this.observer = observer;
		this.deferred = deferred;
	}
}