package Stormancer.Util 
{
	import com.codecatalyst.promise.Promise;
	import flash.utils.ByteArray;
	import mx.utils.Base64Decoder;
	/**
	 * ...
	 * @author Stormancer
	 */
	public final class Helpers 
	{
		public static function base64ToByteArray(data:String) :ByteArray
		{		
			var decoder :Base64Decoder = new Base64Decoder();
			decoder.decode(data);
			return decoder.toByteArray();
		}
		
		public static function stringFormat(str:String, ...args):String
		{
			var argsArray :Array= args as Array;
			
			for (var i:int = 0; i < args.length; i++) 
			{
				var regexp :RegExp = new RegExp("\\{" + i +"\\}", "g");
				str = str.replace(regexp, args[i]);
			}
			
			return str;
		}
		
		public static function mapKeys(map :*):Vector.<String>{
			var result : Vector.<String>= new Vector.<String>();
			for (var key :String in map)
			{
				result.push(key);
			}
			return result;
		}
		
		public static function promiseIf(condition : Boolean, action : Function, context : * = null) : Promise{
			if (condition)
			{
				return action.call(context);
			}
			else 
			{
				return Promise.when(null);
			}
		}
		
		public function Helpers() 
		{
			
		}
		
	}

}