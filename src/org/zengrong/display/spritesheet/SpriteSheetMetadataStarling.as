package org.zengrong.display.spritesheet
{
import flash.geom.Rectangle;

/**
 * SpriteSheetMetadat的XML格式包装器
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
	 */
	override public function objectify($isSimple:Boolean=false, $includeName:Boolean=true):*
	{
		return header + toXML($isSimple,$includeName).toXMLString();
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
		if(!$isSimple)
		{
			var __addXMLList:XMLList = getAddXML($includeName).children();
			for(i = 0;i<__addXMLList.length();i++)
			{
				__xml.appendChild(__addXMLList[i]);
			}
		}
		return __xml;
	}
	
	/**
	 * 获取XML格式的附加信息
	 */	
	private function getAddXML($includeName:Boolean):XML
	{
		var __xml:XML = <metadata />;
		__xml.sheetType = type;
		__xml.hasLabel = hasLabel;
		__xml.maskType = maskType;
		__xml.hasName = $includeName;
		__xml.totalFrame =totalFrame;
		if(hasLabel)
		{
			var __labelXML:XML = <labels />;
			__labelXML.@count = labels.length;
			for(var __key:String in labelsFrame)
			{
				__labelXML[__key] = labelsFrame[__key].toString();
			}
			__xml.appendChild(__labelXML);
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
		__xml.x = $sizeRect.x;
		__xml.y = $sizeRect.y;
		__xml.width = $sizeRect.width;
		__xml.height = $sizeRect.height;
		__xml.frameX = $originRect.x;
		__xml.frameY = $originRect.y;
		__xml.frameWeight = $originRect.width;
		__xml.frameHeight = $originRect.height;
		return __xml;
	}
}
}