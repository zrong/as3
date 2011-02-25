////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-01-02
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.utils
{
import flash.utils.ByteArray;

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
	 * 将对象转换成字符串形式
	 * @param $obj 要转换的对象
	 * @param $delim1 键值之间的定界符
	 * @param $delim2 每对值之间的定界符
	 * @param $pref 显示的前缀
	 * @return 结果字符串
	 */	
	public static function toString($obj:*, $delim1:String=':', $delim2:String=', ', $pref:String=''):String
	{
		var __str:String = '{';
		for(var __key:String in $obj)
		{
			if(	$obj[__key] is String ||
				$obj[__key] is Boolean ||
				$obj[__key] is int ||
				$obj[__key] is Number)
			{
				__str += __key + $delim1 + $obj[__key] + $delim2;
			}
			else
			{
				__str += toString($obj[__key], $delim1, $delim2);
			}
		}
		return delEndDelimiter(__str, $delim2) + '}';
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
}
}