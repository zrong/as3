////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2010-11-19
//  更新时间：2011-09-06
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.net
{
import org.zengrong.assets.AssetsType;

import flash.display.*;
import flash.events.*;
import flash.net.*;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;

[Event(name="complete",type="flash.events.Event")]
[Event(name="ioError",type="flash.events.IOErrorEvent")]
[Event(name="progress",type="flash.events.ProgressEvent")]

/**
 * 此类用于载入外部可视化资源，并转换成可以AS支持的资源的功能。
 * */
public class VisualLoader extends EventDispatcher implements ILoader
{
    public function VisualLoader()
    {
		_loading = false;
    }

	protected var _loader:Loader;
	
	/**
	 * 当前载入的可视对象的类型 
	 */	
	protected var _type:String;
	
	protected var _url:String;
	
	protected var _loading:Boolean;
	
	//----------------------------------
	//  init
	//----------------------------------
	/**
	 * 初始化载入可视对象的Loader
	 */	
	protected function initLoader():void
	{
		if (_loader == null)
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handler_loaded);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handler_ioError);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, handler_progress);
		}
	}
	
	//----------------------------------
	//  getter/setter
	//----------------------------------
	/**
	 * 返回当前载入的文件类型
	 * */
	public function get type():String
	{
		return _type;
	}
	
	public function get url():String
	{
		return _url;
	}
	
	/**
	 * 返回当前是否正在载入
	 */	
	public function get loading():Boolean
	{
		return _loading;
	}
	
	/**
	 * 返回载入的AS3SWF库中的类，例如MovieClip、Sprite、Bitmap、Sound、Font等。只要Flash软件支持的类型，这里都可以获取到。
	 * @throw Error 如果载入的文件不是SWF，则抛出异常。判断文件类型通过AssetsType.SWF属性。
	 * @see org.zengrong.assets.ActorType#SWF
	 * @see #_type
	 */	
	public function getClass($className:String):Class
	{
		if (_loader == null)
			return null;
		if(_type == AssetsType.SWF)
			return _loader.contentLoaderInfo.applicationDomain.getDefinition($className) as Class;
		else
			throw new Error('载入的可视对象不是SWF类型，不能返回Class');
	}
	
	/**
	 * 返回载入的图像的BitmapData
	 * @throw Error 如果载入的文件不是图像，则抛出异常。判断文件类型通过ActorType.isPic()方法。
	 * @see org.zengrong.assets.ActorType#isPic()
	 * @see #_type
	 */	
	public function getBitmapData():BitmapData
	{
		if (_loader == null)
			return null;
		if(AssetsType.isPic(_type))
		{
			return Bitmap(_loader.content).bitmapData;
		}
		else
			throw new Error('载入的可视对象不是图像类型，不能返回bitmapData');
	}
	
	//----------------------------------
	//  handler
	//----------------------------------

    protected function handler_loaded(evt:Event):void
    {
//		trace('载入资源完成：', _loader.contentLoaderInfo.url)
		//如果载入的是可视资源，就发布载入成功消息
		_loading = false;
        dispatchEvent(evt);
    }

	protected function handler_progress(evt:ProgressEvent):void
    {
        dispatchEvent(evt);
    }
	
	protected function handler_ioError(evt:IOErrorEvent):void
	{
		_loading = false;
		dispatchEvent(evt);
	}
	
	//----------------------------------
	//  public
	//----------------------------------
	
	/**
	 * 载入字节数组，字节数组必须是swf、png或者jpg类型。
	 * @param $bytes 要载入的字节数组
	 * @param $type 要载入的字节数组的类型
	 * */
	public function loadBytes($bytes:ByteArray, $type:String):void
	{
		if(_loading)
			return;
		_loading = true;
		_type = $type;
		initLoader();
		_loader.loadBytes($bytes);
	}

	/**
	 * 从外部URL载入可视对象，可视对象必须是swf、png或者jpg类型。
	 * @param $bytes 要载入的资源文件路径
	 * @param $type 要载入的资源类型
	 * */
    public function load($url:String, $type:String, $loaderContext:LoaderContext=null) : void
    {
		if(_loading)
			return;
		_loading = true;
		_url = $url;
		_type = $type;
		initLoader();
		if(!$loaderContext)
			$loaderContext = new LoaderContext(true, new ApplicationDomain(ApplicationDomain.currentDomain), SecurityDomain.currentDomain);
        _loader.load(new URLRequest($url),  $loaderContext);
    }
	
	public function destroy():void
	{
		if(_loader)
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, handler_loaded);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, handler_ioError);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, handler_progress);
			_loader = null;
		}
	}
}
}
