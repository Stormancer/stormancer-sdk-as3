package Stormancer.Util
{
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class CancellationTokenSource
	{
		private var _data:CancellationSourceData = new CancellationSourceData();
		private var _token:CancellationToken;
		
		public function CancellationTokenSource()
		{
			this._token = new CancellationToken(this._data);
		}
		
		public function get token():CancellationToken
		{
			return _token;
		}
		
		public function cancel(reason:String = "Operation Cancelled"):void
		{
			this._data.isCancelled = true;
			setTimeout(function():void
			{				
				for (var i:int = 0; i < this._data.listeners.length; i++)
				{
					this._data.listeners[i](reason);
				}
			}, 0);
		}
	
	}
}