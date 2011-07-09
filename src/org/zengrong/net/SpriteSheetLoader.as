////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2011-07-09
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.net
{
import org.zengrong.assets.AssetsType;
import org.zengrong.display.spritesheet.MaskType;
import org.zengrong.display.spritesheet.SpriteSheet;
import org.zengrong.display.spritesheet.SpriteSheetMetadata;
import org.zengrong.display.spritesheet.SpriteSheetType;

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
import flash.utils.ByteArray;

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
	public function SpriteSheetLoader()
	{
		initLoader();
	}
	
	protected var _url:String;
	protected var _loading:Boolean;
	protected var _loader:Loader;
	protected var _urlLoader:URLLoader;
	protected var _metadata:SpriteSheetMetadata;
	
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
		if(_metadata.maskType == MaskType.NO_MASK)
			return new SpriteSheet(__bmd, _metadata);
		var __merge:BitmapData = null;
		var __rect:Rectangle = new Rectangle();
		var __point:Point = new Point();
		//复制Alpha通道
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
	 * 开始载入SpriteSheet
	 * 如果载入的是SS格式的SpriteSheet，则直接使用嵌入的元数据，不使用metadata参数提供的元数据。
	 * 如果载入的是普通的图像文件，则使用metadata参数提供的元数据。
	 * 如果载入的是普通的图像文件，但没有提供metadata参数，则自动载入同目录下同文件名的XML文件作为元数据。若无此文件，则抛出异常。（使用XML的原因是因为JSON需要增加解析包，会增加最终文件的大小。而XML原生支持）
	 * @param $url	SpriteSheet文件路径
	 * @param $type	是普通pic文件，则为true；是ss文件，则为false
	 * @param $metaData	SpriteSheet的Metadata信息，由SpriteSheetPacker生成的XML格式。
	 * @see org.zengrong.display.spritesheet.SpriteSheetMetadata
	 */	
	public function load($url:String, $type:Boolean=false, $metadata:XML=null):void
	{
		if(_loading)
			return;
		_loading = true;
		_url = $url;
		_metadata = new SpriteSheetMetadata();
		//trace('ss load:', _url, $type);
		if($type)
		{
			//对于标准的图像文件，需要获取metadata信息，如果有，就开始载入图像文件
			if($metadata)
			{
				_metadata.decodeFormXML($metadata);
				_loader.load(new URLRequest(_url));
			}
			//如果没有metadata信息，就使用同目录下的同名json文件为metadata，载入它。
			//metadata载入成功后，才载入实际的图像
			else
			{
				_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
				_urlLoader.load(new URLRequest(getMetadataXMLUrl(_url)));
			}
		}
		//对于SS文件，直接载入二进制数据
		else
		{
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.load(new URLRequest(_url));
		}
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
		//trace('spriteSheetLoader.handler_urlLoaded:', evt.currentTarget, _urlLoader.dataFormat);
		//如果载入的是Metadata，就保存XML格式的Metadata，然后再载入实际的图像
		if(_urlLoader.dataFormat == URLLoaderDataFormat.TEXT)
		{
			_metadata.decodeFormXML(new XML(_urlLoader.data));
			_loader.load(new URLRequest(_url), new LoaderContext(true));
		}
		//如果载入的是二进制数据，就将其分离成元数据和图像信息，使用loader再次载入实际的图像字节数组
		else
		{
		}
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
	//  private
	//----------------------------------
	//根据载入的图片的地址，获取同名的xml metadata文件
	private function getMetadataXMLUrl($url:String):String
	{
		var __dotIndex:int = $url.lastIndexOf('.');
		if(__dotIndex == -1)
			return $url + '.xml';
		return $url.slice(0, __dotIndex) + '.xml';
	}
	
	private function isLoadMetadata($loader:*):Boolean
	{
		return $loader == _urlLoader && _urlLoader.dataFormat == URLLoaderDataFormat.TEXT;
	}
}
}
