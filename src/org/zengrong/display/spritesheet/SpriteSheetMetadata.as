////////////////////////////////////////////////////////////////////////////////
//  youxi.com
//  创建者:	zrong
//  创建时间：2011-04-11
//	修改时间：2011-08-11
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.spritesheet
{
import flash.filesystem.File;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.flash_proxy;

import org.zengrong.utils.ObjectUtil;

/**
 * 处理SpriteSheet的元数据
 * @author zrong
 */
public class SpriteSheetMetadata
{
	public function SpriteSheetMetadata()
	{
		setup();
	}
	
	/**
	 * Sheet的类型，见SpriteSheetType
	 */	
	public var type:String;
	
	/**
	 * 是否包含Label，Label信息用于分段动画 
	 */	
	public var hasLabel:Boolean;
	
	/**
	 * 是否包含名称信息，即对每一帧都使用了名称
	 */	
	public var hasName:Boolean;
	
	/**
	 * mask的类型，详见org.zengrong.display.spritesheet.MaskType。mask信息只能存在于JPG文件中
	 */	
	public var maskType:int;
	
	/**
	 * Sheet的所有Label名称
	 */	
	public var labels:Vector.<String>;
	
	/**
	 * 每个Label的的帧范围，键名是Label，键值是一个数组，第一个元素为开始帧（0基），第二个元素为该Label总帧数
	 */	
	public var labelsFrame:Object;
	
	/**
	 * 如果使用名称来指定每一帧，则这里保存所有名字的数组
	 */	
	public var names:Vector.<String>;
	
	/**
	 * 如果使用名称来指定每一帧，则这里保存每个名称与帧的对应关系
	 */	
	public var namesIndex:Object;
	
	/**
	 * 每帧在整个大的Sheet中的位置和尺寸
	 * 这并非是最终在大的Sheet中体现出来的位置和尺寸。而是是未修剪之前的尺寸。也就是最终要在程序中使用的尺寸。
	 * 因为如果执行了修剪，那么在大的Sheet中只会保存有效像素（空白的边缘被修建掉了）。
	 * 而在还原到程序中的时候，还是必须使用原来的Rect大小的（因为要考虑到动作的外延范围）。
	 * 这个Vector中保存的始终都是在程序使用时候的Rect。
	 */	
	public var frameRects:Vector.<Rectangle>;
	
	/**
	 * 每帧原始的Rect，基于frameRect保存修剪信息
	 * 例如，对frameRect进行了修剪操作，修剪的上下左右的值均为10像素。修剪后的frameRect为(0,0,50,50)
	 * 那么originalFrameRect则为(-10,-10,70,70)
	 * 如果frameRect没有经过修剪，则这个rect的w和h值与frameRect中的对应元素相等，但x和y为0
	 */
	public var originalFrameRects:Vector.<Rectangle>;
	
	//----------------------------------------
	// getter/setter
	//----------------------------------------
	
	/**
	 * Sheet的帧数
	 */	
	public function get totalFrame():int
	{
		return frameRects ? frameRects.length : 0;
	}
	
	//----------------------------------
	//  public
	//----------------------------------
	/**
	 * 返回自身的副本（深复制）
	 */
	public function clone():SpriteSheetMetadata
	{
		var __meta:SpriteSheetMetadata = new SpriteSheetMetadata();
		__meta.type = type;
		__meta.hasLabel = hasLabel;
		__meta.hasName = hasName;
		__meta.maskType = maskType;
		if(frameRects)
		{
			__meta.frameRects = new Vector.<Rectangle>;
			for (var i:int = 0; i < frameRects.length; i++) 
			{
				__meta.frameRects[i] = frameRects[i].clone();
				__meta.originalFrameRects[i] = originalFrameRects[i].clone();
			}
		}
		if(labels)
			__meta.labels = labels.concat();
		if(labelsFrame)
			__meta.labelsFrame = ObjectUtil.clone(labelsFrame);
		if(names)
			__meta.names = names.concat();
		if(namesIndex)
			__meta.namesIndex = ObjectUtil.clone(namesIndex);
		return __meta;
	}
	/**
	 * 销毁整个对象
	 */	
	public function destroy():void
	{
		type = null;
		hasLabel = false;
		maskType = 0;
		hasName = false;
		labels = null;
		labelsFrame = null;
		names = null;
		namesIndex = null;
		frameRects = null;
	}
	
	/**
	 * 根据设置的属性初始化一些值
	 */	
	public function setup():void
	{
		frameRects = new Vector.<Rectangle>;
		originalFrameRects = new Vector.<Rectangle>;
	}
	
	/**
	 * 设置Label的属性
	 * @param $hasLabel	是否使用了Label
	 * @param $items	Label的对象数组，每个对象格式为:{label,first,total}，其中first是1基的
	 * 
	 */	
	public function setLabels($hasLabel:Boolean, $items:Array=null):void
	{
		trace('SpriteSheetMetadata.setLabels:', $hasLabel, $items);
		//必须传递可用的$items才算是使用了Label，否则都算没有Label
		if($hasLabel && $items && $items.length>0)
		{
			hasLabel = true;
			labels = new Vector.<String>($items.length, true);
			labelsFrame = {};
			for(var i:int=0; i<$items.length; i++)
			{
				labels[i] = $items[i].label;
				//起始帧是1基的，要转换成0基，因此要-1
				var __first:int = $items[i].first - 1;
				if(__first<0) __first = 0;
				labelsFrame[labels[i]] = [__first, $items[i].total];
			}
		}
		else
		{
			hasLabel = false;
			labels = null;
			labelsFrame = null;
		}
	}
	/**
	 * 从外部向数组中添加帧的尺寸，一般在循环中执行
	 */	
	public function addFrame($sizeRect:Rectangle, $originalRect:Rectangle=null):void
	{
//		if(frameRects.length>=frameCount)
//			return;
		if(!frameRects)	setup();
		writeFrame(frameRects.length, $sizeRect, $originalRect);
	}
	
	public function addFrameAt($index:int, $sizeRect:Rectangle, $originalRect:Rectangle=null):void
	{
		if(!frameRects)	setup();
		writeFrame($index, $sizeRect, $originalRect);
	}
	
	private function writeFrame($index:int, $sizeRect:Rectangle, $originalRect:Rectangle=null):void
	{
		if(!$originalRect) $originalRect = new Rectangle(0-$sizeRect.x, 0-$sizeRect.y, $sizeRect.width, $sizeRect.height);
		frameRects[$index] = $sizeRect;
		originalFrameRects[$index] = $originalRect;
	}
	
	//----------------------------------------
	// decode
	//----------------------------------------
	
	/**
	 * 从XML文件解析Metadata数据，XML文件必须由SpriteSheetPacker生成。
	 * @param $xml 由SpriteSheetPacker生成的XML文件，或者自行生成且符合SpriteSheetPacker格式的XML文件。
	 */	
	public function decodeFormXML($xml:XML):void
	{
		var i:int=0;
		type = $xml.sheetType.toString();
		hasLabel = $xml.hasLabel.toString() == 'true';
		hasName = $xml.hasName.toString() == 'true';
		maskType = int($xml.maskType.toString());
		var __totalFrame:int = int($xml.totalFrame.toString());
		setup();
		var __frames:XMLList = $xml.frames.children();
		var __frame:XML = null;
		if(hasName)
		{
			names = new Vector.<String>(__totalFrame, true);
			namesIndex = {};
		}
		var __frameRect:Rectangle = null;
		var __originalRect:Rectangle = null;
		for(i=0;i<__totalFrame;i++)
		{
			__frame = __frames[i];
			__frameRect = new Rectangle(int(__frame.x.toString()), int(__frame.y.toString()), int(__frame.w.toString()), int(__frame.h.toString()))
			__originalRect = new Rectangle(int(__frame.ox.toString()), int(__frame.oy.toString()), int(__frame.ow.toString()), int(__frame.oh.toString()))
			writeFrame(i, __frameRect, __originalRect);
			if(hasName)
			{
				names[i] = __frame.@name.toString();
				namesIndex[names[i]] = i;
			}
		}
		if(hasLabel)
		{
			var __count:int = $xml.labels.@count;
			var __labelsXML:XMLList = $xml.labels.children();
			labels = new Vector.<String>(__count, true);
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
	}
	
	/**
	 * 从ByteArray解析MetaData
	 * @param $ba 从SS格式中提取的Metadata数据
	 */	
	public function decodeFromByteArray($ba:ByteArray):void
	{
		var i:int=0;
		$ba.position = 0;
		type = $ba.readUTF();
		hasLabel = $ba.readBoolean();
		hasName = $ba.readBoolean();
		maskType = $ba.readByte();
		var __totalFrame:int = $ba.readShort();
		setup();
		for(i=0;i<__totalFrame;i++)
		{
			writeFrame(i, new Rectangle($ba.readShort(), $ba.readShort(), $ba.readShort(), $ba.readShort())); 
		}
		if(hasLabel)
		{
			var __count:int = $ba.readShort();
			labels = new Vector.<String>(__count, true);
			labelsFrame = {};
			var __first:int = 0;
			var __total:int = 0;
			for(i=0; i<__count; i++)
			{
				labels[i] = $ba.readUTF();
				__first = $ba.readShort();
				__total = $ba.readShort();
				if(__first<0) __first = 0;
				labelsFrame[labels[i]] = [__first, __total];
			}
		}
		if(hasName)
		{
			names = new Vector.<String>(__totalFrame, true);
			namesIndex = {};
			for(i=0;i<__totalFrame;i++)
			{
				names[i] = $ba.readUTF();
				namesIndex[names[i]] = $ba.readShort();
			}
		}
	}
	
	//----------------------------------------
	// encode
	//----------------------------------------
	/**
	 * 返回一个标准的Object对象
	 * @param $isSimple 是否简单数据
	 */	
	public function toObject($isSimple:Boolean=false, $includeName:Boolean=true):Object
	{
		var __jsonObj:Object = {frames:[]};
		var __name:String = null;
		for(var i:int=0;i<totalFrame;i++)
		{
			__name = getFrameName($includeName, i);
			__jsonObj.frames[i] = getRectObject(frameRects[i], originalFrameRects[i], __name);
		}
		//加入附加信息
		if(!$isSimple)
		{
			var __addObj:Object = getAddObject();
			for(var __addKey:String in __addObj)
				__jsonObj[__addKey] = __addObj[__addKey];
		}
		return __jsonObj;
	}
	
	/**
	 * 返回XML格式的Metadata
	 * @param $isSimple 是否简单数据
	 */	
	public function toXML($isSimple:Boolean=false, $includeName:Boolean=true):XML
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
			var __addXMLList:XMLList = getAddXML().children();
			for(i = 0;i<__addXMLList.length();i++)
			{
				__xml.appendChild(__addXMLList[i]);
			}
		}
		return __xml;
	}
	
	/**
	 * 返回Metadata的XML格式字符串，并加上XML头
	 * @param $isSimple 是否简单数据
	 */	
	public function toXMLString($isSimple:Boolean=false, $includeName:Boolean=true):String
	{
		return getTextLine('<?xml version="1.0" encoding="UTF-8"?>') + toXML($isSimple,$includeName).toXMLString();
	}
	
	/**
	 * 返回TXT格式的Metadata
	 * @param $isSimple 是否简单数据
	 */	
	public function toTXT($isSimple:Boolean=false, $includeName:Boolean=true):String
	{
		var __str:String = getTextLine('frames');
		var __name:String = null;
		for(var i:int=0;i<totalFrame;i++)
		{
			__name = getFrameName($includeName, i);
			__str += getRectTxt(frameRects[i], originalFrameRects[i], __name);
		}
		//如果需要附加信息，要在帧信息前面加上frames字样
		if(!$isSimple)
			__str += getAddTXT();
		return __str;
	}
	
	/**
	 * 获取Object格式的附加信息
	 */	
	public function getAddObject():Object
	{
		var __jsonObj:Object =	{};
		//写入sheet的类型
		__jsonObj.sheetType = type;
		__jsonObj.hasLabel = hasLabel;
		__jsonObj.maskType = maskType;
		__jsonObj.hasName = hasName;
		__jsonObj.totalFrame = totalFrame;
		if(hasLabel)
		{
			__jsonObj.labels = ObjectUtil.clone(labelsFrame);
			__jsonObj.labels.count = labels.length;
		}
		return __jsonObj;
	}
	
	/**
	 * 获取XML格式的附加信息
	 */	
	public function getAddXML():XML
	{
		var __xml:XML = <metadata />;
		__xml.sheetType = type;
		__xml.hasLabel = hasLabel;
		__xml.maskType = maskType;
		__xml.hasName = hasName;
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
	 * 获取TXT格式的附加信息
	 */	
	public function getAddTXT():String
	{
		var __str:String = '';
		__str += getTextLine('sheepType', type);
		__str += getTextLine('hasLabel',hasLabel);
		__str += getTextLine('maskType',maskType);
		__str += getTextLine('hasName',hasName);
		__str += getTextLine('totalFrame',totalFrame);
		if(hasLabel)
		{
			__str += getTextLine('labels');
			__str += getTextLine('count', labels.length);
			for(var __key:String in labelsFrame)
			{
				__str += getTextLine(__key, labelsFrame[__key].toString());
			}
		}
		return __str;
	}
	
	/**
	 * 返回Frame的Rect的Json格式
	 */	
	public static function getRectObject($sizeRect:Rectangle, $originRect:Rectangle, $name:String=null):Object
	{
		var __obj:Object = {
			x:$sizeRect.x, 
			y:$sizeRect.y, 
			w:$sizeRect.width, 
			h:$sizeRect.height,
			ox:$originRect.x,
			oy:$originRect.y,
			ow:$originRect.width,
			oh:$originRect.height
		};
		if($name) __obj.name = $name;
		return __obj;
	}
	
	/**
	 * 返回Frame的Rect的XML格式
	 */	
	public function getRectXML($sizeRect:Rectangle, $originRect:Rectangle, $name:String=null):XML
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
			File.lineEnding;
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
		return __str + File.lineEnding;
	}
	
	/**
	 * 返回帧索引对应的帧名称。如果选择了不保存名称，或者没有名称，或者该帧没有对应名称，就返回null
	 * @param $includeName 是否包含名称
	 * @param $index 帧索引
	 */	
	private function getFrameName($includeName:Boolean, $index:int):String
	{
		if(hasName && $includeName)
		{
			//对保存的name的索引进行比较，如果索引正确，就将name写入当前帧中
			for(var __frameName:String in namesIndex)
			{
				if(namesIndex[__frameName] == $index) return __frameName;
			}
		}
		return null;
	}
	
	public function toString():String
	{
		return 'org.zengrong.display.spritesheet::SpriteSheetMetadata{'+
				'type:'+type+
				',hasLabel:'+hasLabel+
				',hasName:'+hasName+
				',totalFrame:'+totalFrame+
				',maskType:'+maskType+
				',labels:'+ObjectUtil.array2String(labels)+
				',labelsFrame:'+ObjectUtil.obj2String(labelsFrame)+
				',frameRects:'+ObjectUtil.array2String(frameRects)+
				',names:'+ObjectUtil.array2String(names)+
				',namesIndex:'+ObjectUtil.obj2String(namesIndex)+
				'}';
	}
}
}
