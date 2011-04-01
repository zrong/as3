////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-01
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
				name = 'zrong';
			_so = SharedObject.getLocal(name);
		}
		return _so;
	}
	
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
		}
		
	}
	
	public static function get($name:String):Object
	{
		return so.data[$name]
	}
	
	public static function del($name:String):void
	{
		delete so.data[$name];
	}
	
	public static function clear():void
	{
		so.clear();
	}
	
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