package Stormancer.Infrastructure 
{
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class SceneEndpoint 
	{
		public var tokenData : ConnectionData;
		public var token: String;
		
		public function SceneEndpoint( token:String, tokenData:ConnectionData) 
		{
			this.token = token;
			this.tokenData = tokenData;
		}			
	}
}