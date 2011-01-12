////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2010-12-30
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.net
{

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

import org.zengrong.utils.ObjectUtil;

/**
 * 与服务器通信，可以传递多重资料和载入多个文件
 * */
public class HTTPLoader
{
	public static var METHOD:String = 'GET';
	
	public function HTTPLoader($done:Function, $error:Function)
	{
		init();
		_fun_loadDone = $done;
		_fun_loadError = $error;
	}
	
	/**
	 * 载入成功后的回调函数
	 * */
	protected var _fun_loadDone:Function;
	
	/**
	 * 载入错误时的回调函数
	 * */
	protected var _fun_loadError:Function;
	
	private var _loading:Boolean;			//是否正在载入。这个变量保证同一时间只能有一次或者一组载入。
	private var _multi:Boolean;			//是否是多文件载入
	
	private var _loader:URLLoader;
	private var _submitVar:Object;			//每次提交都需要的
	private var _returnVar:Object;			//每次提交的时候需要原样返回的参数。这些参数在服务器返回的时候会原样提供
	private var _curSubmitVar:URLVariables;//保存当次提交的变量
	private var _curReturnVar:Object;		//保存当次提交需要返回的参数。
	private var _curUrl:String;			//保存当次提交的URL
	
	private var _urls:Array;				//多文件载入保存每次载入的路径
	private var _submitVars:Array;			//如果是多文件载入，这个变量保存每次提交的时候需要返回的参数。所有的多重载入提供的参数都将统一视为需要返回的参数
	private var _results:Array;			//保存多文件载入时候返回的值
	
	/**
	 * <p>通过这个方法加入的参数，不仅会传给服务端，同时也会在返回的时候提供。</p>
	 * <p>如果使用的是多重载入，那么使用此方法添加的参数，在每次提交和返回的时候都会提供。</p>
	 * @param $key
	 * @param $value
	 */	
	public function addReturnVar($key:String, $value:*):void
	{
		if(!_returnVar)
			_returnVar = {};
		_returnVar[$key] = $value;
		addVariable($key, $value);
	}
	/**
	 * <p>添加要传递给服务器的信息</p>
	 * <p>如果使用的是多重载入，那么使用此方法添加的参数，在每次提交的时候都会提供。</p>
	 * @param $key
	 * @param $value
	 */	
	public function addVariable($key:String, $value:*):void
	{
		if(!_submitVar)
			_submitVar = {};
		_submitVar[$key] = $value;
	}
	
	/**
	 * 开始载入。
	 * @param $url 要载入的地址。地址可以是String或者包含字符串的Array。如果是String，将其作为载入URL对待；如果是Array，将其作为包含需要批量载入的URL对待。
	 * @param args 载入时要传递的参数。参数可以是Object或者Array。如果$url是Array，则这里也必须提供与$url元素相同的Array，Array的每个元素应该是Object。载入的时候，将传递Object中包含的键和值。
	 */	
	public function load($url:* , $requestVar:*=null):void
	{
		if(_loading)
			return;
		if(!$url)
			return;
		//如果提供的是地址字符串，就视为单载入
		if($url is String)
		{
			_multi = false;
			perform($url, $requestVar);
		}
		//否则视为多重载入
		else if($url is Array)
		{
			_multi = true;
			_results = [];
			//保存提供的数组参数
			_urls = $url as Array;
			_submitVars = $requestVar as Array;
			//如果提供了参数，就将参数传入
			if(_submitVars)
			{
				perform(_urls.shift(), _submitVars.shift());
			}
			else
			{
				perform(_urls.shift());
			}
		}
		//否则就不执行
		else
		{
			return;
		}
		addEvent();
		_loading = true;
	}
	
	protected function perform($url:String, $var:Object=null):void
	{
		_curUrl = $url;
		//如果提供了每次提交参数，就将参数中的值全部加入要提交的变量中
		if(_submitVar)
		{
			if(!_curSubmitVar)
				_curSubmitVar = new URLVariables();
			for(var __key:String in _submitVar)
			{
				_curSubmitVar[__key] = _submitVar[__key];
			}
		}
		//如果本次提交提供了参数，就将参数中的所有值加入到本次要提交的变量中
		if($var)
		{
			if(!_curSubmitVar)
				_curSubmitVar = new URLVariables();
			for(var __key2:String in $var)
			{
				_curSubmitVar[__key2] = $var[__key2];
			}
			//如果是多重载入，就将本次提交的所有变量值都作为要返回的变量进行保存
			if(_multi)
				_curReturnVar = $var;
		}
		var __request:URLRequest = new URLRequest(_curUrl);
		__request.method = METHOD;
		if(_curSubmitVar)
			__request.data = _curSubmitVar; 
		_loader.load(__request);
	}
	
	protected function addEvent():void
	{
		_loader.addEventListener(IOErrorEvent.IO_ERROR, handler_error);
		_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handler_error);
		_loader.addEventListener(Event.COMPLETE, handler_complete);
	}
	
	protected function removeEvent():void
	{
		_loader.removeEventListener(IOErrorEvent.IO_ERROR, handler_error);
		_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handler_error);
		_loader.removeEventListener(Event.COMPLETE, handler_complete);
	}
	
	protected function handler_error(evt:ErrorEvent):void
	{
		//如果载入错误，就立即将错误返回
		var __result:Object = {};
		__result.returnData = createReturnData();
		__result.message = '载入【'+_curUrl+'】失败，错误信息：'+evt.toString();
		_fun_loadError.call(null, __result);
		//对于多重载入，即使载入错误，依然要继续载入。但检测的时候，不将返回输入加入数组中。也就是说最终返回的结果数组，将不包含这次载入错误的数据。
		if(_multi)
			checkLoadDone(false);
	}
	
	protected function handler_complete(evt:Event):void
	{
		//如果是多重载入，就是用数组保存
		if(_multi)
		{
			checkLoadDone();
		}
		//如果是单次载入，就直接返回result的值
		else
		{
			var __result:Object = {};
			__result.returnData = createReturnData();
			__result.resultData = _loader.data;
			
			_fun_loadDone.call(null, __result);
			clearVar();
		}
	}
	
	private function init():void
	{
		_loader = new URLLoader();
		_loader.dataFormat = URLLoaderDataFormat.TEXT;
		_loading = false;
		_multi = false;
	}
	
	//创建返回的时候加入的参数
	private function createReturnData():Object
	{
		var __returnData:Object = null;
		//如果提供了返回变量，就将返回变量作为参数加入到返回值中
		if(_returnVar)
			__returnData = ObjectUtil.copy(_returnVar);
		//如果提供了每次返回的变量（实际上就是load的时候提供的所有变量），就将这些变量加入到返回值的returnData中
		if(_curReturnVar)
		{
			if(!__returnData)
				__returnData = {};
			for(var __key:String in _curReturnVar)
				__returnData[__key] = _curReturnVar[__key];
		}
		return __returnData;
	}
	
	/**
	 * 检测多重载入是否全部完成。
	 * @param $addReturn 值为true，则将返回的结果加入数组；否则不加入数组。
	 */	
	private function checkLoadDone($addResult:Boolean=true):void
	{
		if($addResult)
		{
			//__result是一次提交返回的值
			var __result:Object = {};
			__result.returnData = createReturnData();
			//真实的返回值
			__result.resultData = _loader.data;
			//将返回的值加入数组
			_results.push(__result);
		}
		//如果载入没有完毕，就继续载入
		if(_urls.length>0)
		{
			_curReturnVar = null;
			_curSubmitVar = null;
			//再次调用载入
			perform(_urls.shift(), _submitVars ? _submitVars.shift() : null);
		}
		//如果载入完毕就调用函数，传递结果数组
		else
		{
			_fun_loadDone.call(null, _results);
			clearVar();
		}
	}
	
	private function clearVar():void
	{
		_curReturnVar = null;
		_curSubmitVar = null;
		_returnVar = null;
		_submitVar = null;
		_loading = false;
		_results = null;
		removeEvent();
	}
}
}