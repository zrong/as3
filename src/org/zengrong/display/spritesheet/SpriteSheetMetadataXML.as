package org.zengrong.display.spritesheet
{
import flash.geom.Rectangle;

/**
 * SpriteSheetMetadat的XML格式包装器
 * @author zrong (http://zengrong.net)
 * 创建日期：2013-4-6
 */
public class SpriteSheetMetadataXML extends SpriteSheetMetadataStringWraper
{
	public function SpriteSheetMetadataXML($meta:ISpriteSheetMetadata)
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
	 * 从XML文件解析Metadata数据，XML文件必须由Sprite Sheet Editor生成。
	 * 
	 * @param $xml 由Sprite Sheet Editor生成的XML文件，或者自行生成且符合Sprite Sheet Editor格式的XML文件。
	 */	
	override public function parse($value:*):ISpriteSheetMetadata
	{
		var __xml:XML = $value;
		var __xmlRootName:String = __xml.name();
		if(__xmlRootName != "metadata")
		{
			throw new TypeError('不支持的metadata格式:'+__xmlRootName);
		}
		var i:int=0;
		type = __xml.sheetType.toString();
		hasLabel = __xml.hasLabel.toString() == 'true';
		hasName = __xml.hasName.toString() == 'true';
		maskType = int(__xml.maskType.toString());
		var __totalFrame:int = int(__xml.totalFrame.toString());
		setup(true);
		var __frames:XMLList = __xml.frames.children();
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
			__frameRect = new Rectangle(int(__frame.x.toString()), int(__frame.y.toString()), int(__frame.w.toString()), int(__frame.h.toString()));
			__originalRect = new Rectangle(int(__frame.ox.toString()), int(__frame.oy.toString()), int(__frame.ow.toString()), int(__frame.oh.toString()));
			//如果没有提供原始Frame的值，就交给writeFrame自动计算
			if(__originalRect.x == 0 && __originalRect.y == 0 && __originalRect.width == 0 && __originalRect.height == 0)
				__originalRect = null;
			addFrameAt(i, __frameRect, __originalRect);
			if(hasName)
			{
				names[i] = __frame.@name.toString();
				namesIndex[names[i]] = i;
			}
		}
		if(hasLabel)
		{
			var __count:int = __xml.labels.@count;
			var __labelsXML:XMLList = __xml.labels.children();
			labels = new Vector.<String>(__count);
			labelsFrame = {};
			for(i=0; i<__count; i++)
			{
				labels[i] = XML(__labelsXML[i]).localName().toString();
				var __labelFrame:Array = __labelsXML[i].toString().split(',');
				//转换字符串为数字
				for(var j:int=0;j<__labelFrame.length;j++)
				{
					__labelFrame[j] = int(__labelFrame[j]);
					//处理第一帧小于0的情况
					if(j==0 && __labelFrame[j]<0) __labelFrame[0] = 0;
				}
				labelsFrame[labels[i]] = __labelFrame;
			}
		}
		return _metadata;
	}
	
	/**
	 * @inheritDoc
	 */
	override public function objectify($isSimple:Boolean=false, $includeName:Boolean=true, ...$args):*
	{
		return _header + toXML($isSimple,$includeName).toXMLString();
	}
	
	private function toXML($isSimple:Boolean, $includeName:Boolean):XML
	{
		var __xml:XML = <metadata />;
		var __frames:XML = <frames />;
		var i:int=0;
		var __name:String = null;
		for(i=0;i<totalFrame;i++)  
		{
			__name = getFrameName($includeName, i);
			__frames.appendChild( getRectXML(frameRects[i], originalFrameRects[i], __name) );
		}
		__xml.appendChild(__frames);
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
		var __xml:XML = <frame />;
		if($name) __xml.@name = $name;
		__xml.x = $sizeRect.x;
		__xml.y = $sizeRect.y;
		__xml.w = $sizeRect.width;
		__xml.h = $sizeRect.height;
		__xml.ox = $originRect.x;
		__xml.oy = $originRect.y;
		__xml.ow = $originRect.width;
		__xml.oh = $originRect.height;
		return __xml;
	}
}
}