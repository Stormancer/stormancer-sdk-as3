package Stormancer.Plugins 
{
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class PluginBuildContext 
	{
		private var _sceneCreated : Vector.<Function> = new Vector.<Function>();
		private var _clientCreated : Vector.<Function> = new Vector.<Function>();
		private var _sceneConnected : Vector.<Function> = new Vector.<Function>();
		private var _sceneDisconnected : Vector.<Function> = new Vector.<Function>();
		private var _packetReceived : Vector.<Function> = new Vector.<Function>();
		public function PluginBuildContext() 
		{
			
		}
		
		public function get packetReceived():Vector.<Function> 
		{
			return _packetReceived;
		}
		
		public function get sceneDisconnected():Vector.<Function> 
		{
			return _sceneDisconnected;
		}
		
		public function get sceneCreated():Vector.<Function> 
		{
			return _sceneCreated;
		}
		
		public function get clientCreated():Vector.<Function> 
		{
			return _clientCreated;
		}
		
		public function get sceneConnected():Vector.<Function> 
		{
			return _sceneConnected;
		}
		
	}

}