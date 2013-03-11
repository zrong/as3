////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong(zrongzrong@gmail.com)
//  创建时间：2012-04-17
//  修改时间：2012-12-04
//  修改时间：2013-02-07 加入HTTPLoaderDoneVO和HTTPLoaderErrorVO支持
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.net
{
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLVariables;

import org.zengrong.utils.MathUtil;

/**
 * 不管返回调用是否失败，都不断请求的HTTP类，适用于大批量同时的请求，返回没有顺序
 * @author zrong
 */
public class HTTPLoaderAsync
{
	public function HTTPLoaderAsync($done:Function, $error:Function)
	{
		init();
		_fun_loadDone = $done;
		_fun_loadError = $error;
	}
	
	private var _loaderID:uint = 0;
	
	private var _loaderList:Object;
	
	/**
	 * 载入成功后的回调函数
	 * */
	protected var _fun_loadDone:Function;
	
	/**
	 * 载入错误时的回调函数
	 * */
	protected var _fun_loadError:Function;
	
	protected var _method:String = 'GET';
	
	protected var _dataFormat:String = 'text';
	
	public var debug:Boolean;
	
	private function init():void
	{
		
	}
	
	/**
	 * 处理一次HTTP请求
	 * @param $url 请求地址
	 * @param $requestVar 请求参数，参数自动转换成键值对的方式
	 * @param $random 是否添加随机数防止缓存
	 */
	public function load($url:String , $requestVar:Object=null, $random:Boolean=true):void
	{
		if(!$url) throw new ArgumentError('必须提供URL参数!');
		var __request:URLRequest = new URLRequest($url);
		__request.method = _method;
		if($requestVar)
		{
			var __var:URLVariables = new URLVariables();
			if($random) __var["r"+MathUtil.getRandom(9999)] = MathUtil.getRandom(9999999);
			for(var __key:String in $requestVar)
			{
				__var[__key] = $requestVar[__key];
			}
			__request.data = __var; 
		}
		var __loader:MyLoader = createLoader();
		//在Loader中保存提交的数据，以便返回给调用者
		__loader.returnData = __request.data;
		//在Loader中保存提交的URL地址
		__loader.url = $url;
		__loader.dataFormat = _dataFormat;
		__loader.load(__request);
		if(debug)
		{
			var __tracetxt:String  = "";
			if(__request.data)
			{
				__tracetxt = "?"+__request.data.toString();
			}
			trace($url + __tracetxt);
		}
	}
	
	/**
	 * 指定使用何种方法提交数据到服务器
	 * @see flash.net.URLRequestMethod
	 */
	public function get method():String
	{
		return _method;
	}
	
	public function set method($method:String):void
	{
		_method = $method;
	}
	
	/**
	 * 控制如何接收下载数据
	 * @see flash.net.URLLoaderDataFormat
	 */
	public function get dataFormat():String
	{
		return _dataFormat;
	}
	
	public function set dataFormat($format:String):void
	{
		_dataFormat = $format;
	}
	
	protected function createLoader():MyLoader
	{
		var __loader:MyLoader = new MyLoader('myLoader'+_loaderID++);
		__loader.dataFormat = _dataFormat;
		__loader.addEventListener(IOErrorEvent.IO_ERROR, handler_error);
		__loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handler_error);
		__loader.addEventListener(Event.COMPLETE, handler_complete);
		return __loader;
	}
	
	protected function destroyLoader($loader:MyLoader):void
	{
		if($loader)
		{
			$loader.removeEventListener(IOErrorEvent.IO_ERROR, handler_error);
			$loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handler_error);
			$loader.removeEventListener(Event.COMPLETE, handler_complete);
			$loader.returnData = null;
			$loader.url = null;
			$loader.name = null;
		}
	}
	
	protected function handler_error($evt:ErrorEvent):void
	{
		var __loader:MyLoader = $evt.currentTarget as MyLoader;
		var __error:HTTPLoaderErrorVO = new HTTPLoaderErrorVO();
		__error.type = $evt.type;
		__error.errorEvent = $evt;
		__error.message = $evt.toString();
		__error.url = __loader.url;
		__error.returnData = __loader.returnData;
		_fun_loadError.call(null, __error);
		destroyLoader(__loader);
	}
	
	protected function handler_complete($evt:Event):void
	{
		var __loader:MyLoader = $evt.currentTarget as MyLoader;
		var __done:HTTPLoaderDoneVO = new HTTPLoaderDoneVO();
		__done.returnData = __loader.returnData;
		__done.resultData = __loader.data;
		__done.url = __loader.url;
		_fun_loadDone.call(null, __done);
		destroyLoader(__loader);
	}
}
}
import flash.net.URLLoader;
import flash.net.URLRequest;

class MyLoader extends URLLoader
{
	public function MyLoader($name:String)
	{
		super(null);
		name = $name;
	}
	
	public var name:String;
	public var returnData:Object;
	public var url:String;
}