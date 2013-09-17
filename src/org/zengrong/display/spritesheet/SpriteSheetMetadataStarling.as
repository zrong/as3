package org.zengrong.display.spritesheet
{
import flash.geom.Rectangle;

/**
 * SpriteSheetMetadata的Starling格式包装器
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

	override public function isLegalFormat($value:*):Boolean
	{
		var __xml:XML = $value;
		var __xmlRootName:String = __xml.localName();
		return __xmlRootName == "TextureAtlas";
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
		if(!isLegalFormat(__xml))
		{
			throw new TypeError('不支持的metadata格式:'+__xml.localName());
		}
		var i:int=0;
		type = SpriteSheetType.PNG_IMAGE;
		hasLabel = false;
		hasName = true;
		maskType = MaskType.NO_MASK;
		setup(true);
		var __frames:XMLList = __xml.SubTexture;
		var __totalFrame:int = __frames.length();
		var __frame:XML = null;
		if(hasName)
		{
			names = new Vector.<String>(__totalFrame);
			namesIndex = {};
		}
		var __frameRect:Rectangle = null;
		var __originalRect:Rectangle = null;
		for(i=0;i<__totalFrame;i++)
		{
			__frame = __frames[i];
			__frameRect = new Rectangle(
				int(__frame.@x.toString()), 
				int(__frame.@y.toString()), 
				int(__frame.@width.toString()), 
				int(__frame.@height.toString()) );
			if(__frame.hasOwnProperty("@frameX") && 
				__frame.hasOwnProperty("@frameY") &&
				__frame.hasOwnProperty("@frameWidth") &&
				__frame.hasOwnProperty("@frameHeight") )
			{
				__originalRect = new Rectangle(
					int(__frame.@frameX.toString()),
					int(__frame.@frameY.toString()),
					int(__frame.@frameWidth.toString()),
					int(__frame.@frameHeight.toString()) );
			}
			else
			{
				__originalRect = null;
			}
			//如果没有提供原始Frame的值，就交给writeFrame自动计算
			addFrameAt(i, __frameRect, __originalRect);
			if(hasName)
			{
				names[i] = __frame.@name.toString();
				namesIndex[names[i]] = i;
			}
		}
		return _metadata;
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