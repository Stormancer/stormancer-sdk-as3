package Stormancer.Infrastructure 
{
	import Stormancer.Core.ISerializer;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import org.msgpack.MsgPack;
	import org.msgpack.MsgPackFlags;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class MsgPackSerializer implements ISerializer 
	{
		private var _msgPack : MsgPack = new MsgPack(MsgPackFlags.READ_STRING_AS_BYTE_ARRAY);
		
		public function MsgPackSerializer() 
		{
			
		}
		
		
		/* INTERFACE Stormancer.Core.ISerializer */
		
		public function serialize(data:*, stream:IDataOutput):void 
		{
			_msgPack.write(data, stream);
		}
		
		public function deserialize(stream:IDataInput):* 
		{
			return _msgPack.read(stream);
		}
		
		public function get name():String 
		{
			return "msgpack/map";
		}
		
	}

}