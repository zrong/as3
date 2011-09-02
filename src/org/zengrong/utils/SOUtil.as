////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-01
//	修改时间：2011-09-02
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.utils
{
import flash.net.SharedObject;
/**
 * 读写SO的静态类
 * @author zrong
 */
public class SOUtil
{
	public static var name:String;
	private static var _so:SharedObject;
	
	private static function get so():SharedObject
	{
		if(_so == null)
		{
			if(!name)
				name = 'org.zengrong.util.so';
			_so = SharedObject.getLocal(name);
		}
		return _so;
	}
	
	/**
	 * 保存数据，如果不提供$name参数，则自动建立name
	 * @param $data 要保存的数据
	 * @param $name 数据的键名
	 */
	public static function save($data:Object, $name:String=''):void
	{
		var __name:String;
		if($name)
		{
			__name = $name;
			so.data[__name] = $data;
			trace('保存so：', so.flush());
		}
		else
		{
			__name = 'auto_save_' + list().length;
			so.data[__name] = $data;
		}
	}
	
	/**
	 * 获取$name键名的值
	 * @param $name
	 */	
	public static function get($name:String):Object
	{
		return so.data[$name];
	}
	
	/**
	 * 删除$name键
	 * @param $name
	 * 
	 */	
	public static function del($name:String):void
	{
		delete so.data[$name];
	}
	
	/**
	 * 清除so
	 */	
	public static function clear():void
	{
		so.clear();
	}
	
	/**
	 * 获取so中保存的所有键值对的数组
	 */	
	public static function list():Array
	{
		var __list:Array = [];
		for(var __name:String in so.data)
		{
			__list.push({name:__name, value:so.data[__name]});
		}
		return __list;
	}
}
}