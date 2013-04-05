////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  更新时间：2011-09-07
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.net
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.system.LoaderContext;

import org.zengrong.assets.AssetsType;
import org.zengrong.display.spritesheet.MaskType;
import org.zengrong.display.spritesheet.SpriteSheet;
import org.zengrong.display.spritesheet.SpriteSheetMetadata;
import org.zengrong.display.spritesheet.SpriteSheetMetadataType;
import org.zengrong.display.spritesheet.SpriteSheetType;

[Event(name="complete",type="flash.events.Event")]
[Event(name="ioError",type="flash.events.IOErrorEvent")]
[Event(name="progress",type="flash.events.ProgressEvent")]
/**
 * 此类用于载入SpriteSheet资源，并转换成SpriteSheet格式。
 * SpriteSheet资源的格式类型见SpriteSheetType
 * @see org.zengrong.display.spritesheet.SpriteSheetType
 * */
public class SpriteSheetLoader extends EventDispatcher implements ILoader
{
	/**
	 * @param $decodeJSON 提供将JSON字符串解析成Object对象的方法
	 */	
	public function SpriteSheetLoader($decodeJSON:Function=null)
	{
		_decodeJSON = $decodeJSON;
		initLoader();
	}
	
	/**
	 * JSON解析方法比较复杂，因此从外部提供。避免增加类库大小。而且从Flash Player 11开始，已经内置JSON解析。这样处理方便过渡。
	 */
	protected var _decodeJSON:Function;
	protected var _url:String;
	protected var _metaType:String;
	protected var _loading:Boolean;
	protected var _loader:Loader;
	protected var _urlLoader:URLLoader;
	protected var _metadata:SpriteSheetMetadata;
	protected var _loaderContext:LoaderContext;
	
	//----------------------------------
	//  init
	//----------------------------------
	/**
	 * 初始化载入可视对象的Loader
	 */	
	protected function initLoader():void
	{
		_loading = false;
		_loader = new Loader();
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handler_visualLoaded);
		_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handler_ioError);
		_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, handler_progress);
		
		_urlLoader = new URLLoader();
		_urlLoader.addEventListener(Event.COMPLETE, handler_urlLoaded);
		_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handler_ioError);
		_urlLoader.addEventListener(ProgressEvent.PROGRESS, handler_progress);
	}
	
	//----------------------------------
	//  getter/setter
	//----------------------------------
	public function get type():String
	{
		return AssetsType.SPRITE_SHEET;
	}
	
	public function get url():String
	{
		return _url;
	}
	
	public function get loading():Boolean
	{
		return _loading;
	}
	
	/**
	 * 获取解析好的bitmapData数据
	 */	
	public function getSpriteSheet():SpriteSheet
	{
		var __bmd:BitmapData = Bitmap(_loader.content).bitmapData;
		if(!_metadata)
			return new SpriteSheet(__bmd);
		if(_metadata.maskType == MaskType.NO_MASK)
			return new SpriteSheet(__bmd, _metadata);
		var __merge:BitmapData = null;
		var __rect:Rectangle = new Rectangle();
		var __point:Point = new Point();
		//合并Alpha通道
		if(_metadata.maskType == MaskType.HOR_MASK)
		{
			__rect.width = __bmd.width*.5;
			__rect.height = __bmd.height;
			__merge = new BitmapData(__rect.width, __rect.height, true, 0x00000000);
			__merge.copyPixels(__bmd, __rect, __point, null, null, true);
			__rect.x = __rect.width;
			__merge.copyChannel(__bmd, __rect, __point, 1, 8);
		}
		else
		{
			__rect.width = __bmd.width;
			__rect.height = __bmd.height*.5;
			__merge = new BitmapData(__rect.width, __rect.height, true, 0x00000000);
			__merge.copyPixels(__bmd, __rect, __point, null, null, true);
			__rect.y = __rect.height;
			__merge.copyChannel(__bmd, __rect, __point, 1, 8);
		}
		return new SpriteSheet(__merge, _metadata);
	}
	//----------------------------------
	//  public
	//----------------------------------
	/**
	 * 开始载入SpriteSheet，使用metadata参数提供的元数据，元数据类型默认为XML格式
	 * 如果没有提供metadata参数，则自动载入同目录下同文件名的XML文件作为元数据。
	 * 若无此文件，则抛出异常。（使用XML的原因是因为JSON需要增加解析包，会增加最终文件的大小。而XML原生支持）
	 * @param $url	SpriteSheet文件路径
	 * @param $metaData	SpriteSheet的Metadata信息，由Sprite Sheet Editor生成，默认是XML格式，可支持XML和JSON（以标准Object方式提供）
	 * @see org.zengrong.display.spritesheet.SpriteSheetMetadata
	 */	
	public function load($url:String, $metadata:*=null, $metaType:String='xml', $loaderContext:LoaderContext=null):void
	{
		if(_loading)return;
		if($metaType == SpriteSheetMetadataType.JSON && !(_decodeJSON is Function))
			throw new TypeError('Metadata为JSON格式的时候，必须提供解析JSON用的方法！');
		//如果没有提供LoaderContext，就建立一个，并允许检测Policy文件
		_loaderContext = $loaderContext;
		if(!_loaderContext) _loaderContext = new LoaderContext(true);
		_loading = true;
		_url = $url;
		_metaType = $metaType;
		decodeMetadata($metadata);
	}
	
	public function destroy():void
	{
		if(_loader)
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, handler_visualLoaded);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, handler_ioError);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, handler_progress);
			_loader = null;
		}
		if(_urlLoader)
		{
			_urlLoader.removeEventListener(Event.COMPLETE, handler_urlLoaded);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, handler_ioError);
			_urlLoader.removeEventListener(ProgressEvent.PROGRESS, handler_progress);
			_urlLoader = null;
		}
		_metadata = null;
		_url = null;
		_loading = false;
		_metaType = null;
	}
	
	//----------------------------------
	//  handler
	//----------------------------------
	protected function handler_visualLoaded(evt:Event):void
	{
		//trace('spriteSheetLoader.handler_visualLoaded:', evt.currentTarget);
		_loading = false;
		dispatchEvent(evt);
	}
	
	protected function handler_urlLoaded(evt:Event):void
	{
		if(_metaType == SpriteSheetMetadataType.JSON)
		{
			if(_decodeJSON is Function)
			{
				_metadata = createSpriteSheetMetadata();
				_metadata.decodeFromObject(_decodeJSON.call(null, _urlLoader.data));
			}
		}
		else
		{
			_metadata = createSpriteSheetMetadata();
			_metadata.decodeFromXML(new XML(_urlLoader.data));
		}
		//载入图像文件
		_loader.load(new URLRequest(_url), _loaderContext);
	}
	
	protected function handler_progress(evt:ProgressEvent):void
	{
		//trace('spriteSheetLoader.handler_progress:', evt.bytesLoaded, evt.bytesTotal);
		dispatchEvent(evt);
	}
	
	protected function handler_ioError(evt:IOErrorEvent):void
	{
		//trace('spriteSheetLoader.handler_ioError载入io错误！');
		_loading = false;
		if( isLoadMetadata(evt.currentTarget) )
			evt.text = '无法载入元数据文件！' + evt.text;
		dispatchEvent(evt);
	}
	
	//----------------------------------
	//  内部方法
	//----------------------------------
	
	/**
	 * 这个方法实现了XML格式和JSON格式metadta的自动载入。
	 * 若要支持其他格式（例如ByteArray格式或TXT格式），可覆盖此方法
	 */
	protected function decodeMetadata($metadata:*):void
	{
		//trace('ss load:', _url, $type);
		//对于标准的图像文件，需要获取metadata信息，如果有，就开始载入图像文件
		if($metadata)
		{
			_metadata = createSpriteSheetMetadata();
			if(_metaType == SpriteSheetMetadataType.XML)
				_metadata.decodeFromXML($metadata);
			else if(_metaType == SpriteSheetMetadataType.JSON)
				_metadata.decodeFromObject($metadata);
			else throw TypeError('不支持的metadata格式:'+_metaType);
			//如果提供了Metadata，就开始载入图像文件
			_loader.load(new URLRequest(_url),  _loaderContext);
		}
		//如果没有metadata信息，就载入同目录下的同名文件为metadata，扩展名取决于metaType的值
		//metadata载入成功后，才载入实际的图像
		else
		{
			//不支持除XML和JSON格式之外的外部Metadata文件
			if(_metaType != SpriteSheetMetadataType.JSON && _metaType != SpriteSheetMetadataType.XML)
				throw TypeError('不支持的metadata格式:'+_metaType);
			_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			_urlLoader.load(new URLRequest(getMetadataUrl(_url, _metaType)));
		}
	}
	
	/**
	 * 根据载入的图片的地址，获取同名的metadata文件
	 */
	protected function getMetadataUrl($url:String, $type:String):String
	{
		var __dotIndex:int = $url.lastIndexOf('.');
		if(__dotIndex == -1)
			return $url + '.'+$type;
		return $url.slice(0, __dotIndex) + '.'+$type;
	}
	
	/**
	 * 判断当前的载入是否与Metadata相关的
	 */
	protected function isLoadMetadata($loader:*):Boolean
	{
		return $loader == _urlLoader && _urlLoader.dataFormat == URLLoaderDataFormat.TEXT;
	}
	
	/**
	 * 创建一个SpriteSheetMetadata对象，子类可以覆盖这个方法，以实现扩展的SpriteSheetMetadata
	 */
	protected function createSpriteSheetMetadata():SpriteSheetMetadata
	{
		return new SpriteSheetMetadata();
	}
}
}
