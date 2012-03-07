////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-23
//  最后修改：2012-03-06
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.assets
{
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

import org.zengrong.display.spritesheet.SpriteSheet;
import org.zengrong.net.SpriteSheetLoader;
import org.zengrong.net.VisualLoader;

/**
 * 负责载入和解析外部资源。这些资源按zrong的习惯一般位于assets文件夹。
 * @author zrong
 */

[Event(name="complete",type="org.zengrong.assets.AssetsEvent")]
[Event(name="info",type="org.zengrong.events.AssetsEvent")]
[Event(name="progress",type="org.zengrong.events.AssetsEvent")]

public class Assets extends EventDispatcher
{
	/**
	 * 设置Assets在载入外部资源的过程中的处理程序，第一个处理程序必须设定。
	 * @param $done 处理载入全部完毕的处理器，不需要参数
	 * @param $info 处理显示信息的处理器（载入过程中的任何错误和信息均通过这个处理器发送，参数为字符串）
	 * @param $progress 处理载入过程的处理器，参数为AssetsProgressVO
	 * 这个事件处理器，可以表示单个资源的载入流程，也可以表示整个列表的载入流程。
	 * 需要注意的是，代表列表的载入流程的事件，是从该资源开始载入的时候发出的。
	 * @see org.zengrong.assets.AssetsProgressVO
	 * */
	public function setListener($done:Function, $info:Function=null, $progress:Function=null):void
	{
		_fun_loadDone = $done;
		_fun_loadInfo = $info;
		_fun_loadProgress = $progress;
	}
	
	public function Assets()
	{
		init();
	}
	
	/**
	 * 内含的VisualLoader进行载入的时候需要的LoaderContext
	 */
	public var loaderContext:LoaderContext;
	
	protected var _fun_loadDone:Function;
	protected var _fun_loadInfo:Function;
	protected var _fun_loadProgress:Function;

	protected var _visualLoader:VisualLoader;		//载入可视文件的loader
	protected var _ssLoader:SpriteSheetLoader; 	//载入SpriteSheet

	protected var _urls:Array;			//保存所有需要载入的文件的路径
	protected var _loadingCount:int;		//所有需要载入的外部资源的总数量
	protected var _curFile:Object;		//保存正在载入的文件的相关信息
	protected var _assets:Object;		//保存解析后的资源信息
	
	//----------------------------------
	//  init
	//----------------------------------
	protected function init():void
	{
		_assets = {};
		_urls = [];
		_loadingCount = -1;

		_visualLoader = new VisualLoader();
		_visualLoader.addEventListener(Event.COMPLETE, handler_loaded);
		_visualLoader.addEventListener(IOErrorEvent.IO_ERROR, handler_ioError);
		_visualLoader.addEventListener(ProgressEvent.PROGRESS, handler_progress);

		_ssLoader = getSSLoader();
		_ssLoader.addEventListener(Event.COMPLETE, handler_loaded);
		_ssLoader.addEventListener(IOErrorEvent.IO_ERROR, handler_ioError);
		_ssLoader.addEventListener(ProgressEvent.PROGRESS, handler_progress);
	}

	/**
	 * 初始化SpriteSheepLoader的实例，子类可以通过重写这个类来提供新的SpriteSheetLoader
	 */
	protected function getSSLoader():SpriteSheetLoader
	{
		return new SpriteSheetLoader();
	}
	
	//----------------------------------
	//  getter/setter
	//----------------------------------
	/**
	 * 是否正在载入资源
	 */	
	public function get isLoading():Boolean
	{
		return (_urls && (_urls.length > 0)) ||
			_visualLoader.loading ||
			_ssLoader.loading;
	}
	
	//----------------------------------
	//  public
	//----------------------------------
	/**
	 * 开始载入外部资源
	 * 外部素材的配置文件是一个Object数组，每个Object有5个值：
	 * <ul>
	 * 	<li>url（必须）：待载入文件的URL</li>
	 * 	<li>ftype（必须）：待载入文件的类型，可用值见AssetsType。</li>
	 * 	<li>fname（可选）：待载入的文件的键名，如果不提供，则使用文件的主文件名。fname的命名规则与变量命名规则相同。fname相同的文件不会被重复载入。</li>
	 * 	<li>symbols（可选/必须）：ftype值为AssetsType.SWF时必须提供，否则不必提供。以字符串数组的方式提供所有需要的FLA库中的Symbol（CLASS）名称。</li>
	 * 	<li>mtype（可选/必须）：ftype值为AssetStype.SPRITE_SHEET时必须提供，否则不必提供。值为SpriteSheetMetadataType中的值。</li>
	 * 	<li>meta（可选）：ftype值为AssetsType.SPRITE_SHEET时可以提供，值为<a href="http://zengrong.net/sprite_sheet_editor">SpriteSheetEditor</a>生成的元数据内容。
	 * 	数据内容应该与mtype的值相匹配。如果不提供，就自动载入url同目录下的同名metadata文件，其扩展名就是mtype的值。</li>
	 * </ul>
	 * @param $urls 待载入的外部资源素材配置文件
	 * @see org.zengrong.display.assets.AssetsType
	 * @see org.zengrong.display.spritesheet.SpriteSheetType
	 * @see org.zengrong.display.net.SpriteSheetLoader
	 * @see org.zengrong.display.spritesheet.SpriteSheetMetadataType
	 * */
	public function load($urls:Array, $loaderContext:LoaderContext=null):void
	{
		loaderContext = $loaderContext;
		if(!_urls) throw new ReferenceError('请先初始化调用init方法初始化!');
		//如果正在载入，将要载入的数据压入数组，并更新数组总量
		if(isLoading)
		{
			_urls = _urls.concat($urls);
			//更新数组总量
			_loadingCount += $urls.length;
		}
		else
		{
			_urls = $urls;
			_loadingCount = _urls.length;
			loadAssets();
		}
	}
	
	public function destroy():void
	{
		if(_visualLoader)
		{
			_visualLoader.removeEventListener(Event.COMPLETE, handler_loaded);
			_visualLoader.removeEventListener(IOErrorEvent.IO_ERROR, handler_ioError);
			_visualLoader.removeEventListener(ProgressEvent.PROGRESS, handler_progress);
			_visualLoader = null;
		}
		if(_ssLoader)
		{
			_ssLoader.removeEventListener(Event.COMPLETE, handler_loaded);
			_ssLoader.removeEventListener(IOErrorEvent.IO_ERROR, handler_ioError);
			_ssLoader.removeEventListener(ProgressEvent.PROGRESS, handler_progress);
			_ssLoader = null;
		}
		//移除所有的资源
		for(var __key:String in _assets)
		{
			removeAssets(__key);
		}
		_fun_loadDone = null;
		_fun_loadInfo = null;
		_fun_loadProgress = null;
		_assets = null;
		_urls = null;
		_curFile = null;
		_loadingCount = -1;
	}
	
	/**
	 * 从载入的资源中获取Class。只有SWF资源才能获取到Class。
	 * @param $name 资源的名称。如果在载入的时候没有明确指定，就是资源swf的主文件名部分
	 * @param $symbol 类名，即FLA库中绑定的类的名称
	 * @return FLA库中对应的类定义，如果没有找到或者类型错误，返回null。
	 */	
	public function getClass($name:String, $symbol:String):Class
	{
		if(_assets[$name])
			return _assets[$name][$symbol] as Class;
		return  null;
	}
	
	/**
	 * 从载入的资源中获取BitmapData。只有图像资源才能获取到BitmapData。
	 * @param $mame 资源的名称。如果在载入的时候没有明确指定，就是图像文件的主文件名部分
	 * @return 该图像文件的bitmapData数据。如果没有找到或者类型错误，返回null。
	 */	
	public function getBitmapData($name:String):BitmapData
	{
		return _assets[$name] as BitmapData;
	}
	
	/**
	 * 从载入的资源中获取SpriteSheet。只有SpriteSheet类型的资源才能获取到BitmapData。
	 * @param $mame 资源的名称。如果在载入的时候没有明确指定，就是图像文件的主文件名部分
	 * @return SpriteSheet对象。如果没有找到或者类型错误，返回null。
	 */	
	public function getSpriteSheet($name:String):SpriteSheet
	{
		return _assets[$name] as SpriteSheet;
	}

	/**
	 * 从资源库中移除对应的资源
	 */
	public function removeAssets($name:String):void
	{
		if($name in _assets)
		{
			var __ass:* = _assets[$name];
			if(__ass is SpriteSheet)
				SpriteSheet(__ass).destroy();
			else if(__ass is BitmapData)
				BitmapData(__ass).dispose();
			delete _assets[$name];
		}
	}

	/**
	 * 返回所有资源的名称数组
	 */
	public function getAssetsNames():Array
	{
		var __names:Array = [];
		for(var __name:String in _assets)
		{
			__names.push(__name);
		}
		return __names;
	}
	//--------------------------------------------------------------------------
	//  handler
	//--------------------------------------------------------------------------
	
	protected function handler_ioError(evt:IOErrorEvent):void
	{
		info(evt.text);
		//碰到载入错误，继续载入
		loadAssets();
	}
	
	protected function handler_loaded(evt:Event):void
	{
		saveAssets();
		dispatchProgress(getProgressVO(_loadingCount-_urls.length, _loadingCount, true, true));
		loadAssets();
	}
	
	protected function handler_progress(evt:ProgressEvent):void
	{
		var __vo:AssetsProgressVO = getProgressVO(ProgressEvent(evt).bytesLoaded,ProgressEvent(evt).bytesTotal);
		dispatchProgress(__vo);
	}
	
	//----------------------------------
	//  内部方法
	//----------------------------------
	//发送载入进度的vo
	protected function dispatchProgress($vo:AssetsProgressVO):void
	{
		this.dispatchEvent(new AssetsEvent(AssetsEvent.PROGRESS, $vo));
		if(_fun_loadProgress is Function)
			_fun_loadProgress.call(null, $vo);
	}

	protected function getProgressVO($loaded:int, $total:int, $whole:Boolean=false, $done:Boolean=false):AssetsProgressVO
	{
		var __vo:AssetsProgressVO = new AssetsProgressVO(_curFile);
		__vo.loaded = $loaded;
		__vo.total = $total;
		__vo.whole = $whole;
		__vo.done = $done;
		return __vo;
	}
	
	/**
	 * 开始载入素材，载入前的一些判断在这里进行
	 */
	protected function loadAssets():void
	{
		if(_urls == null)
			throw new Error('找不到资源文件路径！');
		if(_urls.length > 0)
		{
			_curFile = _urls.shift();
			//如果没有提供fname，需要指定一个name
			if(!_curFile.fname)
			{
				//若没有提供fname，使用主文件名作为fname
				_curFile.fname = getFileName(_curFile.url).main;
			}
			//载入一个新的资源开始的时候，发送载入列表的百分比
			dispatchProgress(getProgressVO(_loadingCount-_urls.length, _loadingCount, true, false));
			//如果要载入的资源已经存在于保存的资源中了，就跳过这个资源的载入，载入下一个资源
			//因为在分析要载入的资源阶段，可能有些资源是重复的（例如某些技能可能共享效果资源文件）
			if(_assets[_curFile.fname])
			{
				//由于存在这个资源，代表载入成功了，这里发送载入资源完毕时候的百分比事件
				dispatchProgress(getProgressVO(_loadingCount-_urls.length, _loadingCount, true, true));
				loadAssets();
				return;
			}
			performLoad();
		}
		else
		{
			this.dispatchEvent(new AssetsEvent(AssetsEvent.COMPLETE));
			if(_fun_loadDone is Function) _fun_loadDone.call();
		}
	}

	/**
	 * 确定载入一个文件
	 * 载入每种类型的文件，使用独立的方法，方便子类覆盖
	 */
	protected function performLoad():void
	{
		if(_curFile.url is ByteArray)
			info('Assets开始执行载入ByteArray:'+_curFile.fname+',ftype:'+_curFile.ftype);
		else
			info('Assets开始执行载入:'+_curFile.url);
		//载入的外部资源是可视化资源
		if(	AssetsType.isVisual(_curFile.ftype) )
		{
			if(_curFile.ftype == AssetsType.SWF && !_curFile.symbols)
				throw new ReferenceError('对于SWF素材，必须提供symbols数组！');
			loadVisual();
		}
		//载入的资源是SpriteSheet类型
		else if(_curFile.ftype == AssetsType.SPRITE_SHEET)
		{
			loadSpriteSheet();
		}
		else
			throw new RangeError('要载入的资源类型不符合要求！类型：'+_curFile.ftype+',URL:'+_curFile.url);
	}

	/**
	 * 载入可视化文件对象
	 */
	protected function loadVisual():void
	{
		_visualLoader.load(_curFile.url, _curFile.ftype, loaderContext);
	}

	/**
	 * 载入spritesheet
	 */
	protected function loadSpriteSheet():void
	{
		_ssLoader.load(_curFile.url, _curFile.meta, _curFile.mtype, loaderContext);
	}
		
	/**
	 * 将从外部获取到的可视对象保存在对象中备用
	 * */
	protected function saveAssets():void
	{
		//如果载入的是swf，就获取symbol对象。将symbol的Class存在变量中
		if(_curFile.ftype == AssetsType.SWF)
		{
			
			var __swfSymbols:Object = new Object();
			for each(var __symbol:String in _curFile.symbols)
			{
				__swfSymbols[__symbol] = _visualLoader.getClass(__symbol);
			}
			_assets[_curFile.fname] = __swfSymbols; 
		}
		//普通图片，直接保存BitmapData
		else if(AssetsType.isPic(_curFile.ftype))
		{
			_assets[_curFile.fname] = _visualLoader.getBitmapData();
		}
		else if(_curFile.ftype == AssetsType.SPRITE_SHEET)
		{
			_assets[_curFile.fname] = _ssLoader.getSpriteSheet();
		}
		else
		{
			throw new Error('载入完成的文件类型不被支持！类型：'+_curFile.ftype,',URL:'+_curFile.url);
		}
	}
	
	//获取URL中的主文件名
	protected function getFileName($url:String):Object
	{
		//使用main和ext两个属性保存主文件名和扩展名
		var __mainAndExt:Object = {};
		var __slashIndex:int = $url.lastIndexOf('/');
		var __dotIndex:int = $url.lastIndexOf('.');
		if(__slashIndex > -1)
		{
			//如果能找到点，说明这个文件有扩展名，就去掉扩展名
			if(__dotIndex>-1)
			{
				__mainAndExt.main = $url.slice(__slashIndex+1, __dotIndex);
				__mainAndExt.ext = $url.slice(__dotIndex+1);
			}
			//找不到点，说明没有扩展名，直接使用主文件名
			else
			{
				__mainAndExt.main =  $url.slice(__slashIndex+1);
			}
		}
		else
		{
			//如果找不到斜杠，说明这个路径本来就只有一个文件名，直接从0开始算
			if(__dotIndex>-1)
			{
				__mainAndExt.main =  $url.slice(0, __dotIndex);
				__mainAndExt.ext =  $url.slice(__dotIndex+1);
			}
			else
				__mainAndExt.main =  $url;
		}
		return __mainAndExt;
	}
	
	protected function info($msg:String):void
	{
		var __evt:AssetsEvent = new AssetsEvent(AssetsEvent.INFO);
		__evt.info = $msg;
		this.dispatchEvent(__evt);
		if(_fun_loadInfo is Function)
			_fun_loadInfo.call(null, $msg);
	}
}
}
class Singlton{}
