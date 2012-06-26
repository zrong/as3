////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2010-12-30
//	此类中的部分方法来自于Flex框架的mx.utils.StringUtil，具体到方法中将有详细标注
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.utils
{
/**
 * StringUtil 实用程序类是一个全静态类。不用创建 StringUtil 的实例；只是调用如 StringUtil.substitute() 之类的方法。
 * @author Adobe.com
 * @author zrong
 * 
 */
public class StringUtil
{
	/**
	 * 返回易读的大小格式
	 * @param $size 字节数
	 * @param $decimals 每个级别的保留小数。[0,1,2]代表KB不保留小数，MB保留1位小数，GB保留2位小数。如果不提供参数，默认使用[1,2,2]。如果提供的数组数量不够，则后面的级别使用0。
	 */
	public static function getHumenSize($size:uint, $decimals:Array=null):String
	{
		//保存易读的大小格式
		var __humanSize:String;
		var __float:Number;
		if(!$decimals || $decimals.length==0) $decimals = [1,2,2];
		//小于1K就使用字节做单位
		if($size<ByteSize.KB)
		{
			__humanSize = $size.toString() + 'Byte';
		}
			//小于1M使用KB作单位
		else if($size<ByteSize.MB)
		{
			//保留一位小数
			__humanSize = float2String($size/ByteSize.KB, $decimals[0]) + 'KB';
		}
		//小于1G使用MB作单位
		else if($size <ByteSize.GB)
		{
			//保留两位小数
			__humanSize = float2String($size/ByteSize.MB, int($decimals[1])) + 'MB';
		}
		//否则使用GB做单位
		else
		{
			//保留两位小数
			__humanSize = float2String($size/ByteSize.GB, int($decimals[2])) + 'MB';
		}
		return __humanSize;
	}
	
	/**
	 * 把一个数字输出成浮点形式的字符串
	 * @param $num 要处理的数字
	 * @param $decimals 小数的位数
	 */
	public static function float2String($num:Number, $dedimals:uint=1):String
	{
		var __float:String = $num.toString();
		var __floatArr:Array = __float.split('.');
		if(__floatArr.length>1)
		{
			if($dedimals>0)
			{
				var __decimal:String = __floatArr[1];
				if(__decimal.length>$dedimals)
				{
					__decimal = __decimal.slice(0, $dedimals);
				}
				else
				{
					while(__decimal.length<$dedimals)
						__decimal += '0';
				}
				return __floatArr[0] + '.' + __decimal;
			}
			else
			{
				return __floatArr[0].toString();
			}
		}
		if($dedimals>0)
		{
			__float += '.';
			for(var i:int=0; i<$dedimals;i++)
			{
				__float += '0';
			}
		}
		return __float;
	}

	/**
	 * 使用$value数组中的键值替换指定字符串内的“{key}”标记。key的值来自于$key数组
	 * @param $str 要在其中进行替换的字符串。该字符串可包含 {key} 形式的特殊标记，其中key的值与$key数组中的元素相同，它将被$value中相同索引的元素替换。
	 * @param $key 要替换的键名数组
	 * @param $value 被替换的值的数组，值的索引与键名的索引要一一对应
	 * @return 完成替换的新字符串
	 */		
	public static function substituteFromKey($str:String, $key:Array, $value:Array):String
	{
		if($str == null)
			return '';
		var __str:String = $str;
		for(var i:int=0; i<$key.length; i++)
		{
			__str = __str.replace(new RegExp("\\{"+$key[i]+"\\}", "g"), $value[i]);
		}
		return __str;
	}
	
	/**
	 * 测试一个字符串是否为真
	 */		
	public static function isTrue($str:String):Boolean
	{
		return trim($str).toLocaleLowerCase() === 'true';
	}
	
	/**
	 * 检测一个字符串是否是[a,b]的形式，仅支持一维数组 
	 */		
	public static function isArray($str:String):Boolean
	{
		var _reg:RegExp = /^\[[^\[\]]*\]$/g;
		return _reg.test($str);
	}
	
	/**
	 * 使用传入的各个参数替换指定的字符串内的“{n}”标记。n从0开始
	 * @param str  要在其中进行替换的字符串。该字符串可包含 {n} 形式的特殊标记，其中 n 为从零开始的索引，它将被该索引处的其他参数（如果指定）替换。
	 * @param rest 可在 str 参数中的每个 {n} 位置被替换的其他参数，其中 n 是一个对指定值数组的整数索引值（从 0 开始）。如果第一个参数是一个数组，则该数组将用作参数列表。
	 * @author Adobe.com
	 */		
	public static function substitute(str:String, ... rest):String
	{
		if (str == null) return '';
		
		// Replace all of the parameters in the msg string.
		var len:uint = rest.length;
		var args:Array;
		if (len == 1 && rest[0] is Array)
		{
			args = rest[0] as Array;
			len = args.length;
		}
		else
		{
			args = rest;
		}
		
		for (var i:int = 0; i < len; i++)
		{
			str = str.replace(new RegExp("\\{"+i+"\\}", "g"), args[i]);
		}
		
		return str;
	}
	
	/**
	 *  删除指定字符串的开头和末尾的所有空格字符。
	 *  @param str 要去掉其空格字符的字符串。
	 *  @return 删除了其开头和末尾空格字符的更新字符串。
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 * 	@author Adobe.com
	 */
	public static function trim(str:String):String
	{
		if (str == null) return '';
		
		var startIndex:int = 0;
		while (isWhitespace(str.charAt(startIndex)))
			++startIndex;
		
		var endIndex:int = str.length - 1;
		while (isWhitespace(str.charAt(endIndex)))
			--endIndex;
		
		if (endIndex >= startIndex)
			return str.slice(startIndex, endIndex + 1);
		else
			return "";
	}
	
	/**
	 *  删除数组中每个元素的开头和末尾的所有空格字符，此处数组作为字符串存储。
	 *  @param value 要去掉其空格字符的字符串。
	 *  @param separator 分隔字符串中的每个数组元素的字符串。
	 *  @return 删除了每个元素的开头和末尾空格字符的更新字符串。
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 * 	@author Adobe.com
	 */
	public static function trimArrayElements(value:String, delimiter:String):String
	{
		if (value != "" && value != null)
		{
			var items:Array = value.split(delimiter);
			
			var len:int = items.length;
			for (var i:int = 0; i < len; i++)
			{
				items[i] = StringUtil.trim(items[i]);
			}
			
			if (len > 0)
			{
				value = items.join(delimiter);
			}
		}
		
		return value;
	}
	
	/**
	 *  如果指定的字符串是单个空格、制表符、回车符、换行符或换页符，则返回 true。
	 *  @param str 查询的字符串。
	 *  @return 如果指定的字符串是单个空格、制表符、回车符、换行符或换页符，则为<code>true</code>。
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 * 	@author Adobe.com
	 */
	public static function isWhitespace(character:String):Boolean
	{
		switch (character)
		{
			case " ":
			case "\t":
			case "\r":
			case "\n":
			case "\f":
				return true;
				
			default:
				return false;
		}
	}
	
	/**
	 *  从字符串中删除“不允许的”字符。“限制字符串”（如 <code>"A-Z0-9"</code>）用于指定允许的字符。此方法使用的是与 TextField 的 <code>restrict</code> 属性相同的逻辑。Removes "unallowed" characters from a string.
	 *  @param str 输入字符串。
	 *  @param restrict 限制字符串。
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 *  @author Adobe.com
	 */
	public static function restrict(str:String, restrict:String):String
	{
		// A null 'restrict' string means all characters are allowed.
		if (restrict == null)
			return str;
		
		// An empty 'restrict' string means no characters are allowed.
		if (restrict == "")
			return "";
		
		// Otherwise, we need to test each character in 'str'
		// to determine whether the 'restrict' string allows it.
		var charCodes:Array = [];
		
		var n:int = str.length;
		for (var i:int = 0; i < n; i++)
		{
			var charCode:uint = str.charCodeAt(i);
			if (testCharacter(charCode, restrict))
				charCodes.push(charCode);
		}
		
		return String.fromCharCode.apply(null, charCodes);
	}
	
	/**
	 *  @private
	 *  Helper method used by restrict() to test each character
	 *  in the input string against the restriction string.
	 *  The logic in this method implements the same algorithm
	 *  as in TextField's 'restrict' property (which is quirky,
	 *  such as how it handles a '-' at the beginning of the
	 *  restriction string).
	 */
	private static function testCharacter(charCode:uint, restrict:String):Boolean
	{
		var allowIt:Boolean = false;
		
		var inBackSlash:Boolean = false;
		var inRange:Boolean = false;
		var setFlag:Boolean = true;
		var lastCode:uint = 0;
		
		var n:int = restrict.length;
		var code:uint;
		
		if (n > 0)
		{
			code = restrict.charCodeAt(0);
			if (code == 94) // caret
				allowIt = true;
		}
		
		for (var i:int = 0; i < n; i++)
		{
			code = restrict.charCodeAt(i)
			
			var acceptCode:Boolean = false;
			if (!inBackSlash)
			{
				if (code == 45) // hyphen
					inRange = true;
				else if (code == 94) // caret
					setFlag = !setFlag;
				else if (code == 92) // backslash
					inBackSlash = true;
				else
					acceptCode = true;
			}
			else
			{
				acceptCode = true;
				inBackSlash = false;
			}
			
			if (acceptCode)
			{
				if (inRange)
				{
					if (lastCode <= charCode && charCode <= code)
						allowIt = setFlag;
					inRange = false;
					lastCode = 0;
				}
				else
				{
					if (charCode == code)
						allowIt = setFlag;
					lastCode = code;
				}
			}
		}
		
		return allowIt;
	}
	
	public static var NEWLINE_TOKENS : Array = new Array (
		'\n',
		'\r'
	);
	
	public static var WHITESPACE_TOKENS : Array = new Array (
		' ',
		'\t'
	);
	
	public static function count ( haystack : String, needle : String, offset : Number = 0, length : Number = 0 ) : Number
	{
		if ( length === 0 )
			length = haystack.length
		var result : Number = 0;
		haystack = haystack.slice( offset, length );
		while ( haystack.length > 0 && haystack.indexOf( needle ) != -1 )
		{
			haystack = haystack.slice( ( haystack.indexOf( needle ) + needle.length ) );
			result++;
		}
		return result;
	}
	
	
	public static function trimList ( str : String, charList : Array = null ) : String
	{
		var list : Array;
		if ( charList )
			list = charList;
		else
			list = WHITESPACE_TOKENS.concat( NEWLINE_TOKENS );
		str = trimLeft( str, list );
		str = trimRight( str, list );
		return str;
	}
	
	public static function trimLeft ( str : String, charList : Array = null ) : String
	{
		var list:Array;
		if ( charList )
			list = charList;
		else
			list = WHITESPACE_TOKENS.concat( NEWLINE_TOKENS );
		
		while ( list.toString().indexOf ( str.substr ( 0, 1 ) ) > -1 && str.length > 0 )
			str = str.substr ( 1 );
		return str;
	}
	
	public static function trimRight ( str:String, charList : Array = null ) : String
	{
		var list : Array;
		if ( charList )
			list = charList;
		else
			list = WHITESPACE_TOKENS.concat( NEWLINE_TOKENS );
		
		while ( list.toString().indexOf ( str.substr ( str.length - 1 ) ) > -1 && str.length > 0)
			str = str.substr ( 0, str.length - 1 );
		return str;
	}
}
}