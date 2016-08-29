package Stormancer.Infrastructure
{
	import Stormancer.Scene;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class Route
	{
		public var metadata:Object = {};
		public var handle:Number;
		public var name:String;
		public var scene:Stormancer.Scene;
		public var handlers:Vector.<Function> = new Vector.<Function>();
		
		public function Route(scene:Stormancer.Scene, name:String, handle:Number = 0, metadata:Object = null)
		{
			if (metadata != null)
			{
				this.metadata = metadata;
			}
			this.handle = handle;
			this.name = name;
			this.scene = scene;
		
		}
	
	}

}