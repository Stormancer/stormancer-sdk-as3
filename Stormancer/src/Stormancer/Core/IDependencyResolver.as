package Stormancer.Core 
{
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public interface IDependencyResolver 
	{
		function getComponent(componentName:String) : * ;
		function registerComponentFactory(componentName : String, factory : Function):void;
		function registerComponent(componentName:String, component:Object) : void;
		function createChildResolver():IDependencyResolver;
	}
	
}