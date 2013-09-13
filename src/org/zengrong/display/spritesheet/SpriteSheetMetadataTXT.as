package org.zengrong.display.spritesheet
{
import flash.geom.Rectangle;

/**
 * SpriteSheetMetadata的TXT格式包装器，用于SSE生成的TXT格式
 * @author zrong (http://zengrong.net)
 * 创建日期：2013-4-6
 */
public class SpriteSheetMetadataTXT extends SpriteSheetMetadataStringWraper
{
	public function SpriteSheetMetadataTXT($meta:ISpriteSheetMetadata)
	{
		super($meta);
	}
	
	/**
	 * 从TXT文件解析Metadata数据，TXT必须由Sprite Sheet Editor生成的TXT格式Metadata解析而来。
	 * @TODO 2013-04-07 等待实现
	 * 
	 * @param $value 由Sprite Sheet Editor生成的TXT文件
	 */	
	override public function parse($value:*):ISpriteSheetMetadata
	{
		return null;
	}
	
	/**
	 * @inheritDoc
	 */
	override public function objectify($isSimple:Boolean=false, $includeName:Boolean=true, ...$args):*
	{
		var __str:String = getTextLine('frames',null);
		var __name:String = null;
		for(var i:int=0;i<totalFrame;i++)
		{
			__name = getFrameName($includeName, i);
			__str += getRectTxt(frameRects[i], originalFrameRects[i], __name);
		}
		//如果需要附加信息，要在帧信息前面加上frames字样
		if(!$isSimple)
			__str += getAddTXT($includeName);
		return __str;
	}
	
	/**
	 * 返回Frame的Rect的纯文本格式
	 */	
	public function getRectTxt($sizeRect:Rectangle, $originRect:Rectangle, $name:String = null):String
	{
		var __str:String = $name?($name+'='):'';
		return __str + 
			$sizeRect.x+','+
			$sizeRect.y+','+
			$sizeRect.width+','+
			$sizeRect.height+',' +
			$originRect.x+','+
			$originRect.y+','+
			$originRect.width+','+
			$originRect.height+
			lineEnding;
	}
	
	/**
	 * 获取TXT格式的附加信息
	 */	
	public function getAddTXT($includeName:Boolean):String
	{
		var __str:String = '';
		__str += getTextLine('sheepType', type);
		__str += getTextLine('hasLabel',hasLabel);
		__str += getTextLine('maskType',maskType);
		__str += getTextLine('hasName',$includeName);
		__str += getTextLine('totalFrame',totalFrame);
		if(hasLabel)
		{
			__str += getTextLine('labels',null);
			__str += getTextLine('count', labels.length);
			for(var __key:String in labelsFrame)
			{
				__str += getTextLine(__key, labelsFrame[__key].toString());
			}
		}
		return __str;
	}
	
	/**
	 * 返回键名+等号+键值+换行符格式的字符串。若不提供键值，则不加入等号
	 * @param $key	键名
	 * @param $value	键值
	 */	
	private function getTextLine($key:String, $value:*=null):String
	{
		var __str:String = $key;
		if($value != null)
			__str += '=' + $value.toString();
		return __str + lineEnding;
	}
	
}
}