////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-01
//	修改时间：2012-05-02
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.utils
{
import flash.media.Sound;
import flash.net.SharedObject;
import flash.utils.Dictionary;

import mx.core.Singleton;

/**
 * 提供SO的快速读写功能
 * @author zrong
 */
public class SOUtil
{
	public static var list:Dictionary = new Dictionary();
	
	/**
	 * 获取一个SOUtil的实例。如果该名称SOUtil存在，直接返回，否则就创建一个SO
	 * @param $name 要获取的so的名称
	 */
	public static function getSOUtil($name:String):SOUtil
	{
		if(list[$name]) return list[$name] as SOUtil;
		var __soutil:SOUtil = new SOUtil($name, new Singleton);
		list[$name] = __soutil;
		return __soutil;
	}
	
	public function SOUtil($name:String, $sig:Singleton)
	{
		if(!$sig) throw new TypeError('请使用SOUtil.getSOUtil获得实例。');
		name = $name;
		_so = createSO();
	}
	
	public var name:String;
	private var _so:SharedObject;
	
	private function createSO():SharedObject
	{
		return SharedObject.getLocal(name);
	}
	
	/**
	 * 保存数据，如果不提供$name参数，则自动建立name
	 * @param $data 要保存的数据
	 * @param $name 数据的键名
	 */
	public function save($data:Object, $name:String=''):void
	{
		var __name:String;
		if($name)
		{
			__name = $name;
			_so.data[__name] = $data;
		}
		else
		{
			__name = 'auto_save_' + list().length;
			_so.data[__name] = $data;
		}
		flush();
	}
	
	public function flush($miniDiskSpace:int=0):String
	{
		var __flush:String = _so.flush($miniDiskSpace);
		trace('保存so：', __flush);
		return __flush;
	}
	
	/**
	 * 获取$name键名的值
	 * @param $name
	 */	
	public function get($name:String):*
	{
		return _so.data[$name];
	}
	
	/**
	 * 删除$name键
	 * @param $name
	 * 
	 */	
	public function del($name:String):void
	{
		delete _so.data[$name];
	}
	
	/**
	 * 清除so
	 */	
	public function clear():void
	{
		_so.clear();
	}
	
	/**
	 * 获取so中保存的所有键值对的数组
	 */	
	public function list():Array
	{
		var __list:Array = [];
		for(var __name:String in _so.data)
		{
			__list.push({name:__name, value:_so.data[__name]});
		}
		return __list;
	}
}
}
class Singleton{};