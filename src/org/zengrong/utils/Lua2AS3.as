package org.zengrong.utils
{
/**
 * Lua解析工具
 * @author leente
 */        
public class Lua2AS3
{
	/**
	 * 替换指定位置字符 
	 * @param rep        替换的字符
	 * @param str        目标字符串
	 * @param index 目标字符下标
	 * @return                 处理完的字符串
	 * 
	 */                
	public static function replaceAt(rep:String, str:String, index:uint):String
	{
			var begin:String = str.substring(0, index);
			var end:String = str.substring(index + 1, str.length);
			return begin + rep + end;
	}
	
	/**
	 * 在指定位置插入字符串 
	 * @param str                插入的字符串
	 * @param target        目标字符串
	 * @param index                目标字符串的下标
	 * @return                         处理完的字符串
	 * 
	 */                
	public static function insertAt(str:String, target:String, index:uint):String
	{
			var begin:String = target.substring(0, index + 1);
			var end:String = target.substring(index + 1, target.length);
			return begin + str + end;
	}

	public function Lua2AS3()
	{
	}
	
	public static function tabelToObject(script:String):Object
	{        
		return JSON.parse(tabelToJson(script));
	}
	
	public static function tabelToJson(script:String):String
	{
		var json:String = "";
		script = script.replace(/\s|\t|\r|\n/g, "");
		script = script.replace(/\[|\]/g, "\"");
		script = script.replace(/=/g, ":");
		json = "{" + makeJson(script) + "}";
		return json;
	}
	
	
	protected static function makeJson(script:String):String
	{
		var arrayTypes:Vector.<Boolean> = new Vector.<Boolean>();
		
		var char:String = "";
		
		var nextChar:String = "";
		var prevChar:String = "";
		
		for (var i:int = 0; i < script.length; i++)
		{
			char = script.charAt(i);
			if (char == "\"")
					continue;
			switch (char)
			{
				case "{":
					var str:String = script.substring(i + 1, script.length);
					nextChar = script.charAt(i + 1);
					if (nextChar == "{")
					{
						arrayTypes.push(true);
						script = Lua2AS3.replaceAt("[", script, i);
					}
					else
					{
						var index1:int = str.indexOf(":");
						var index2:int = str.indexOf(",");
						
						if (index1 > index2 || index1 == -1)
						{
							arrayTypes.push(true);
							script = Lua2AS3.replaceAt("[", script, i);
						}
						else
							arrayTypes.push(false);
					}
					break;
				case "}":
					if (arrayTypes.pop())
					{
						script = Lua2AS3.replaceAt("]", script, i);
					}
					nextChar = script.charAt(i + 1);
					if (nextChar != "," && nextChar != "}" && nextChar != "")
					{
						script = Lua2AS3.insertAt(",", script, i);
					}
					break;
				case ":":
					nextChar = script.charAt(i + 1);
					var reg:RegExp = /[a-z]|[A-Z]|[0-9]|_/;
					if (reg.test(nextChar))
						script = Lua2AS3.insertAt("\"", script, i);
					break;
					break;
				default:
					if (i > 0)
					{
						nextChar = script.charAt(i + 1);
						prevChar = script.charAt(i - 1);
					}
					if (i == 0 && char != "{")
						script = "\"" + script;
					
					if ((prevChar == "{" || prevChar == "[" || prevChar == ",")
							&& char != "\"")
					{
						script = Lua2AS3.insertAt("\"", script, i - 1);
					}
					else if ((nextChar == "}" || nextChar == "]" || nextChar == "," || nextChar == ":") 
							&& char != "\"")
					{
						script = Lua2AS3.insertAt("\"", script, i);
					}
					break;
			}
		}
		return script;
	}
}
}
