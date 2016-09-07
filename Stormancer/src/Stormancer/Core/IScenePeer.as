package Stormancer.Core
{
	import flash.utils.IDataInput;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public interface IScenePeer
	{
		function get id():Number;
		function send(route:String, writer:Function):void;	
		function get dependencyResolver() : IDependencyResolver;
	}

}