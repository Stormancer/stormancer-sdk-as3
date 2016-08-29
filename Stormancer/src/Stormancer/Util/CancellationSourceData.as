package Stormancer.Util
{
	
	/**
	 * ...
	 * @author Stormancer
	 */
	internal class CancellationSourceData
	{
		
		public var reason:String = null;
		public var isCancelled:Boolean = false;
		public var listeners:Vector.<Function> = new Vector.<Function>();
		
		public function CancellationSourceData()
		{
		}
	
	}

}