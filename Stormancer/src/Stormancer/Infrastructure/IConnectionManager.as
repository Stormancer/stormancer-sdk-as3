package Stormancer.Infrastructure
{
	import Stormancer.Core.IConnection;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public interface IConnectionManager
	{
		function generateNewConnectionId():Number;
		function newConnection(connection:IConnection):void;
		function closeConnection(connection:IConnection, reason:String):void;
		function getConnection(id:Number):IConnection;
		function get ConnectionCount():Number;
	}

}