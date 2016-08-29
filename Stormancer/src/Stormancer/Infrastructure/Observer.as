package Stormancer.Infrastructure
{
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class Observer
	{
		private var onNext:Function;
		private var onCompleted:Function;
		private var onError:Function;
		
		public function Observer(onNext:Function = null, onError:Function=null, onCompleted:Function=null)
		{
			this.onNext = onNext;
			this.onError = onError;
			this.onCompleted = onCompleted;		
		}
		
		public function OnCompleted():void
		{
			if (onCompleted != null)
			{
				this.onCompleted();
			}
		}
		
		public function OnNext(value:*):void
		{
			if (onNext != null)
			{
				onNext(value);
			}
		}
		
		public function OnError(error:*):void
		{
			if (onError != null)
			{
				onError(error);
			}
		}
	}

}