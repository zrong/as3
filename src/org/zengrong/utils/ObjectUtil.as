////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-01-02
//  修改时间：2011-08-10
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.utils
{
import flash.utils.ByteArray;
import flash.utils.getQualifiedClassName;
import flash.utils.getQualifiedSuperclassName;

public class ObjectUtil
{
	/**
	 * 克隆一个普通对象
	 * @param value
	 */	
	public static function clone(value:Object):Object
	{
		var __buffer:ByteArray = new ByteArray();
		__buffer.writeObject(value);
		__buffer.position = 0;
		return __buffer.readObject();
	}
	
	/**
	 * 将Array或者Vector转换为字符串，仅支持一层。
	 * @param $arrOrVector Array或者Vector
	 */	
	public static function array2String($arrOrVector:*, $delim:String=','):String
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
		return __str += ']';;
	}
	
	/**
	 * 将仅包含Object的数组转换成文本
	 * @param $arr Array或者Vector
	 */
	public static function arrayObj2String($arrOrVector:*):String
	{
		if(!isArray($arrOrVector)) return null;
		var __str:String = '[';
		for each(var __item:Object in $arrOrVector)
		{
			__str += obj2String(__item) + ',';
		}
		delEndDelimiter(__str, ',');
		return __str+']';
	}
	
	/**
	 * 将标准的Object转换成字符串，仅支持一层。
	 */	
	public static function obj2String($obj:Object, $delim1:String=':', $delim2:String=','):String
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
	public static function delEndDelimiter($str:String, $del:String=','):String
	{
		//如果能搜索到定界符
		if($str.lastIndexOf($del) == $str.length-$del.length)
		{
			return $str.slice(0, $str.length - $del.length);
		}
		return $str;
	}
	
	/**
	 * 判断一个对象是否是Array或者Vector
	 */
	public static function isArray($obj:*):Boolean
	{
		return $obj is Array || $obj is Vector.<*>;
	}
	
	/**
	 * 判断一个对象是否是简单对象
	 */
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
