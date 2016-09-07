package Stormancer.Core
{
	import flash.errors.IllegalOperationError;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class DefaultDependencyResolver implements IDependencyResolver
	{
		private var _dependencies:Object = {};
		private var _parent : IDependencyResolver;
		
		public function DefaultDependencyResolver(parent : IDependencyResolver = null )
		{
			this._parent = parent;
		}
		
		/* INTERFACE Stormancer.Core.IDependencyResolver */
		
		public function getComponent(componentName:String):*
		{
			var factory : Function = _dependencies[componentName];
			if (factory != null)
			{
				return factory();
			}
			else if (_parent !== null)
			{
				return _parent.getComponent(componentName);
			}
			else
			{
				throw new IllegalOperationError("component " + componentName + " has not been registered in the dependency resolver");
			}
		}
		
		public function registerComponentFactory(componentName:String, factory:Function):void
		{
			_dependencies[componentName] = factory;
		}
		
		public function registerComponent(componentName:String, component:Object):void
		{
			_dependencies[componentName] = function():*
			{
				return component;
			};
		}
		
		public function  createChildResolver():IDependencyResolver
		{
			return new DefaultDependencyResolver(this);
		}	
	}
}