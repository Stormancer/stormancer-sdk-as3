package Stormancer.Core
{
	
	/**
	 * ...
	 * @author Stormancer
	 */
	public interface IConnection
	{
		function get id():Number;
		function get connectionDate():Date;
		function get metadata():Object;
		function get account():String;
		function get application() : String;
		function get serializer():ISerializer;
		function set serializer(value:ISerializer):void;
		function get serializerChosen():Boolean;
		function set serializerChosen(value:Boolean):void 
		function get onDisconnection():Vector.<Function> 
		
		function close():void;
		/**
		 *
		 * @param	msgId
		 * @param	writer A method that writes data to a IDataOutput argument
		 */
		function sendSystem(msgId:Number, writer:Function):void;
		/**
		 *
		 * @param	sceneIndex
		 * @param	route
		 * @param	writer A method that writes data to a IDataOutput argument
		 */
		function sendToScene(sceneIndex:Number, route:Number, writer:Function):void;
		function setApplication(account:String, application:String):void;
	}
}