package Stormancer.Infrastructure 
{
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class Subscription implements ISubscription 
	{
		
		private var _callback : Function;
		
		public function Subscription(callback : Function) 
		{
			this._callback = callback;
		}
		
		
		/* INTERFACE Stormancer.Infrastructure.ISubscription */
		
		public function unsubscribe():void 
		{
			if (this._callback != null)
			{
				this._callback();
			}
		}
		
	}

}