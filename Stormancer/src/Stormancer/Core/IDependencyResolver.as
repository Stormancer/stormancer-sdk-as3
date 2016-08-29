package Stormancer.Core 
{
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public interface IDependencyResolver 
	{
		function getComponent(componentName:String) : * ;
		function registerComponenet(componentName : String, factory : Function):void;
	}
	
}