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
	public static function Arr2String($arrOrVector:*, $delim:String=','):String
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
		return __str + ']';
	}
	
	/**
	 * 将标准的Object转换成字符串，仅支持一层。
	 */	
	public static function toString($obj:Object, $delim1:String=':', $delim2:String=','):String
	{
		var __str:String = '{';
		for(var __key:String in $obj)
		{
			__str += __key + $delim1 + $obj[__key] + $delim2;
		}
		delEndDelimiter(__str, $delim2);
		return __str + '}';
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
