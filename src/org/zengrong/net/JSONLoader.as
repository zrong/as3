////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-11-24
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.net
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	//--------------------------------------------------------------------------
	//
	//  载入多个JSON配置文件
	//
	//--------------------------------------------------------------------------
	public class JSONLoader
	{
		//--------------------------------------------------------------------------
		//
		//  类变量
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 按照载入的顺序保存载入的配置文件解析成的JSON对象
		 * */
		public static var config:Array;
		private static var _loader:URLLoader;
		
		/**
		 * 载入成功后的回调函数
		 * */
		private static var _fun_loadDone:Function;
		
		/**
		 * 载入错误时的回调函数
		 * */
		private static var _fun_loadError:Function;
		
		/**
		 * 保存要载入的JSON配置文件的url
		 * */
		private static var _jsonUrls:Array;
		
		//--------------------------------------------------------------------------
		//
		//  类方法
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 设定回调函数
		 * @param $done 载入全部完成的回调函数
		 * @param $error 载入出现错误的回调函数，这个函数必须接受一个类型为flash.events.ErrorEvent的参数
		 */		
		public static function setListener($done:Function, $error:Function):void
		{
			_fun_loadDone = $done;
			_fun_loadError = $error;
		}
		
		/**
		 * 
		 * @param urls 要载入的JSON配置文件的URL，不限制参数数目
		 * 
		 */		
		public static function load(...urls):void
		{
			if(!(_fun_loadDone is Function) || !(_fun_loadError is Function))
				throw new Error('必须先调用setListener设定回调函数！');
			if(urls.length == 0)
				throw new Error('必须提供至少1个URL参数！');
			config = [];
			_jsonUrls = urls.concat();
			if(_loader == null)
			{
				_loader = new URLLoader();
				_loader.dataFormat = URLLoaderDataFormat.TEXT;
				_loader.addEventListener(IOErrorEvent.IO_ERROR, _fun_loadError);
				_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _fun_loadError);
				_loader.addEventListener(Event.COMPLETE, handler_complete);
			}
			loadJson();
		}
		
		/**
		 * 载入一个JSON配置文件
		 * */
		private static function loadJson():void
		{
			if(_jsonUrls.length > 0)
			{
				_loader.load(new URLRequest(_jsonUrls.shift()));
			}
			else
			{
				_fun_loadDone.call(null, config);
				_loader.removeEventListener(IOErrorEvent.IO_ERROR, _fun_loadError);
				_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _fun_loadError);
				_loader.removeEventListener(Event.COMPLETE, handler_complete);
			}
		}
		
		private static function handler_complete(evt:Event):void
		{
			config.push(JSON.decode(_loader.data));
			loadJson();
		}
	}
}