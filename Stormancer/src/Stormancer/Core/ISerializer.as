package Stormancer.Core
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public interface ISerializer
	{
		function serialize(data:*, stream:IDataOutput):void;
		function deserialize(stream:IDataInput):*;
		function get name():String;
	}

}