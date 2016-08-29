package Stormancer.Util
{
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class CancellationToken
	{
		private var _data:CancellationSourceData;
		
		public function CancellationToken(data:CancellationSourceData)
		{
			this._data = data;
		}
		
		public function get isCancelled():Boolean
		{
			return this._data.isCancelled;
		}
		
		public function throwIfCancelled():void
		{
			if (this.isCancelled)
			{
				throw new Error(this._data.reason);
			}
		}
		
		public function onCancelled(callBack:Function):void
		{
			if (this.isCancelled)
			{
				setTimeout(function():void
				{
					callBack(this._data.reason);
				}, 0);
			}
			else
			{
				this._data.listeners.push(callBack);
			}
		}
	}

}