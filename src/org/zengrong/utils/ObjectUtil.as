////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-01-02
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.utils
{
import flash.utils.ByteArray;
import flash.utils.getQualifiedClassName;
import flash.utils.getQualifiedSuperclassName;

public class ObjectUtil
{
	/**
	 * 复制一个对象
	 * @param value
	 */	
	public static function copy(value:Object):Object
	{
		var buffer:ByteArray = new ByteArray();
		buffer.writeObject(value);
		buffer.position = 0;
		var result:Object = buffer.readObject();
		return result;
	}
	
	/**
	 * 将Array或者Vector转换为字符串，仅支持一层。
	 * @param $arrOrVector Array或者Vector
	 * @throw RangeError 如果参数不是Array或者Vector，会抛出异常
	 */	
	public static function ArrayToString($arrOrVector:*, $delim:String=','):String
	{
		if(!isArray($arrOrVector))
		{
			if(!$arrOrVector)
				return 'null';
			return $arrOrVector.toString();			
		}
		var __length:int =$arrOrVector.length;
		var __str:String = ($arrOrVector is Vector.<*>) ? 'Vector[' : 'Array[';
		for(var i:int=0; i<__length;i++)
		{
			__str += $arrOrVector[i].toString() + $delim;
		}
		delEndDelimiter(__str, $delim);
		__str += ']';
		return __str;
	}
	
	/**
	 * 将标准的Object转换成字符串，仅支持一层。
	 */	
	public static function ObjToString($obj:Object, $delim1:String=':', $delim2:String=','):String
	{
		var __str:String = '{';
		for(var __key:String in $obj)
		{
			__str += __key + $delim1 + $obj[__key].toString() + $delim2;
		}
		delEndDelimiter(__str, $delim2);
		return __str + '}';
	}
	
	/**
	 * 将对象转换成字符串形式
	 * @param $obj 要转换的对象
	 * @param $delim1 键值之间的定界符
	 * @param $delim2 每对值之间的定界符
	 * @param $pref 显示的前缀
	 * @return 结果字符串
	 */	
	public static function toString($obj:*, $delim1:String=':', $delim2:String=', ', $pref:String=''):String
	{
		if(!$obj)
			return 'null';
		if(isSimple($obj))
			return $obj.toString();
		var __str:String = isArray($obj) ? '[' :'{';
		var __data:* = null;
		for(var __key:String in $obj)
		{
			__data = $obj[__key];
			if(isSimple(__data))
			{
				__str += __key + $delim1 + __data.toString() + $delim2;
			}
			else if(isArray(__data))
			{
				__str += __key + $delim1 + toString(__data, $delim1, $delim2);
			}
			else if(__data is XML || __data is XMLList)
			{
				__str += __key + $delim1 + __data.toXMLString();
			}
			else
			{
				__str += __key + $delim1 + toString(__data, $delim1, $delim2);
			}
		}
		return delEndDelimiter(__str, $delim2) + (isArray($obj) ? ']' :'}');
	}
	
	/**
	 * 删除末尾的定界符
	 */	
	public static function delEndDelimiter($str:String, $del:String=', '):String
	{
		//如果能搜索到定界符
		if($str.lastIndexOf($del) == $str.length-$del.length)
		{
			return $str.slice(0, $str.length - $del.length);
		}
		return $str;
	}
	
	public static function isArray($obj:*):Boolean
	{
		return $obj is Array || $obj is Vector.<*>;
	}
	
	public static function isSimple($obj:*):Boolean
	{
		return $obj is String ||
				$obj is Boolean ||
				$obj is int ||
				$obj is Number ||
				$obj is uint;
	}
}
}
