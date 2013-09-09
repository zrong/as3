package org.zengrong.display.spritesheet
{
import flash.geom.Rectangle;

/**
 * SpriteSheetMetadata的XML格式包装器
 * @author zrong (http://zengrong.net)
 * 创建日期：2013-4-6
 */
public class SpriteSheetMetadataStarling extends SpriteSheetMetadataStringWraper
{
	public function SpriteSheetMetadataStarling($meta:ISpriteSheetMetadata)
	{
		super($meta);
	}
	
	/**
	 * XML格式的换行符
	 * 将XML文本化的方法，是调用XML.toXMLString转换XML字符串，而XML.toXMLString默认使用\n作为换行符。所以这里使用自定义换行符意义不大，反而可能会造成换行符混乱。
	 */
	override public function get lineEnding():String
	{
		return super.lineEnding;
	}
	
	private var _header:String = '<?xml version="1.0" encoding="UTF-8"?>\n';

	/**
	 * 设置XML的Header内容
	 */
	public function get header():String
	{
		return _header;
	}

	public function set header($value:String):void
	{
		_header = $value;
	}


	/**
	 * 从Starling 的XML文件解析Metadata数据
	 * TODO 等待实现
	 * 
	 * @param $xml Starling格式的SpriteSheet XML文件
	 */	
	override public function parse($value:*):ISpriteSheetMetadata
	{
		var __xml:XML = $value;
		return null;
	}
	
	/**
	 * @inheritDoc
	 * Starling格式必须要包含名称，因此$includeName无论传递什么，都会认为是true。
	 */
	override public function objectify($isSimple:Boolean=false, $includeName:Boolean=true, ...$args):*
	{
		var __xml:XML = toXML($isSimple, true);
		if($args.length > 0 && ($args[0] is String))
		{
			__xml.@imagePath = String($args[0]);
		}
		return header + __xml.toXMLString();
	}
	
	private function toXML($isSimple:Boolean, $includeName:Boolean):XML
	{
		var __xml:XML = <TextureAtlas />;
		var i:int=0;
		var __name:String = null;
		for(i=0;i<totalFrame;i++)  
		{
			__name = getFrameName($includeName, i);
			__xml.appendChild( getRectXML(frameRects[i], originalFrameRects[i], __name) );
		}
		return __xml;
	}
	
	/**
	 * 返回Frame的Rect的XML格式
	 */	
	private function getRectXML($sizeRect:Rectangle, $originRect:Rectangle, $name:String=null):XML
	{
		var __xml:XML = <SubTexture />;
		if($name) __xml.@name = $name;
		__xml.@x = $sizeRect.x;
		__xml.@y = $sizeRect.y;
		__xml.@width = $sizeRect.width;
		__xml.@height = $sizeRect.height;
		__xml.@frameX = $originRect.x;
		__xml.@frameY = $originRect.y;
		__xml.@frameWeight = $originRect.width;
		__xml.@frameHeight = $originRect.height;
		return __xml;
	}
}
}