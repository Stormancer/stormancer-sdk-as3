package Stormancer.Infrastructure
{
	import Stormancer.Util.CancellationToken;
	import com.codecatalyst.promise.Promise;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public interface ITransport
	{
		function get isRunning():Boolean;
		function get name():String;
		function get id():ByteArray;
		function get packetReceived():Vector.<Function>;
		function get connectionOpened():Vector.<Function>;
		function get ConnectionClosed():Vector.<Function>;
		function start(type:String, handler:IConnectionManager, token:CancellationToken):Promise;
		function connect(endpoint:String):Promise;
	
	}

}