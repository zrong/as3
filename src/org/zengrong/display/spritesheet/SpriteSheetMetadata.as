////////////////////////////////////////////////////////////////////////////////
//  zengrong.org
//  创建者:	zrong
//  创建时间：2011-04-11
//	修改时间：2012-02-02
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.spritesheet
{
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

import org.zengrong.utils.ObjectUtil;

/**
 * 处理SpriteSheet的元数据
 * @author zrong
 */
public class SpriteSheetMetadata
{
	public function SpriteSheetMetadata()
	{
		setup(true);
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
	 * @param $force 是否强制初始化。值为true则不判断原来是否存在该变量，强行覆盖
	 */	
	protected function setup($force:Boolean=false):void
	{
		var __frameRects:Vector.<Rectangle> = new Vector.<Rectangle>;
		var __originalFrameRects:Vector.<Rectangle> = new Vector.<Rectangle>;
		if($force)
		{
			frameRects = __frameRects;
			originalFrameRects = __originalFrameRects;
		}
		else if(!frameRects)
		{
			frameRects = __frameRects;
			originalFrameRects = __originalFrameRects;
		}
	}
	
	/**
	 * 增加一个Label
	 * @param $labelName 要增加的Label的名称
	 * @param $labelFrame 要增加的Label的帧索引
	 * 
	 * @throw TypeError 提供的Label名称或者帧索引为空的时候抛出错误
	 */	
	public function addLabel($labelName:String, $labelFrame:Array):void
	{
		if(!$labelName) throw new TypeError('增加的Label不能为空！');
		if(!$labelFrame || $labelFrame.length==0) throw new TypeError('必须为增加的Label('+$labelName+')定义帧序列！');
		hasLabel = true;
		if(!labels) labels = new Vector.<String>;
		if(!labelsFrame) labelsFrame = {};
		labels[labels.length] = $labelName;
		labelsFrame[$labelName] = $labelFrame;
	}
	
	/**
	 * 设置Label的属性
	 * @param $hasLabel	是否使用了Label
	 * @param $labels	Label的对象，每个键名为label名称，每个键值是数组，保存帧的索引号，格式为:[1,2,3]
	 * 
	 */	
	public function setLabels($hasLabel:Boolean, $labels:Object=null):void
	{
		trace('SpriteSheetMetadata.setLabels:', $hasLabel, $labels);
		//必须传递可用的$items才算是使用了Label，否则都算没有Label
		if($hasLabel && $labels)
		{
			hasLabel = true;
			labels = new Vector.<String>;
			labelsFrame = ObjectUtil.clone($labels);
			for(var __labelName:String in $labels) 
			{
				labels[labels.length] = __labelName;
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
	public function addFrame($sizeRect:Rectangle, $originalRect:Rectangle=null, $name:String=null):void
	{
//		if(frameRects.length>=frameCount)
//			return;
		setup();
		writeFrame(frameRects.length, $sizeRect, $originalRect, $name);
	}
	
	public function addFrameAt($index:int, $sizeRect:Rectangle, $originalRect:Rectangle=null, $name:String=null):void
	{
		setup();
		writeFrame($index, $sizeRect, $originalRect, $name);
	}
	
	public function removeFrameAt($index:int):void
	{
		frameRects.splice($index,1);
		originalFrameRects.splice($index,1);
		if(names && namesIndex)
		{
			var __delName:String = names.splice($index, 1)[0] as String;
			//删除被删除的帧的名称
			delete namesIndex[__delName];
			for(var __name:String in namesIndex)
			{
				//將所有帧编号大于被删除帧的帧编号减一
				if(namesIndex[__name] > $index) namesIndex[__name]--;
			}
		}
	}
	
	private function writeFrame($index:int, $sizeRect:Rectangle, $originalRect:Rectangle=null, $name:String=null):void
	{
		if(!$originalRect) $originalRect = new Rectangle(0, 0, $sizeRect.width, $sizeRect.height);
		frameRects[$index] = $sizeRect;
		originalFrameRects[$index] = $originalRect;
		trace('增加帧：', $index, $name);
		if($name && names && namesIndex)
		{
			names[$index] = $name;
			namesIndex[$name] = $index;
		}
	}
	
	//----------------------------------------
	// decode
	//----------------------------------------
	
	/**
	 * 从XML文件解析Metadata数据，XML文件必须由Sprite Sheet Editor生成。
	 * @param $xml 由Sprite Sheet Editor生成的XML文件，或者自行生成且符合Sprite Sheet Editor格式的XML文件。
	 */	
	public function decodeFromXML($xml:XML):void
	{
		var i:int=0;
		type = $xml.sheetType.toString();
		hasLabel = $xml.hasLabel.toString() == 'true';
		hasName = $xml.hasName.toString() == 'true';
		maskType = int($xml.maskType.toString());
		var __totalFrame:int = int($xml.totalFrame.toString());
		setup(true);
		var __frames:XMLList = $xml.frames.children();
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
	}
	
	/**
	 * 从普通Object文件解析Metadata数据，Object必须由Sprite Sheet Editor生成的JSON格式Metadata解析而来。
	 */	
	public function decodeFromObject($obj:Object):void
	{
		var i:int=0;
		type = $obj.sheetType.toString();
		hasLabel = $obj.hasLabel;
		hasName = $obj.hasName;
		maskType = int($obj.maskType);
		var __totalFrame:int = $obj.totalFrame;
		setup(true);
		var __frames:Array = $obj.frames;
		var __frame:Object = null;
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
			__frameRect = new Rectangle(__frame.x, __frame.y, __frame.w, __frame.h);
			__originalRect = new Rectangle(__frame.ox, __frame.oy, __frame.ow,__frame.oh);
			//如果没有提供原始Frame的值，就交给writeFrame自动计算
			if(__originalRect.x == 0 && __originalRect.y == 0 && __originalRect.width == 0 && __originalRect.height == 0)
				__originalRect = null;
			writeFrame(i, __frameRect, __originalRect);
			if(hasName)
			{
				names[i] = __frame.name;
				namesIndex[names[i]] = i;
			}
		}
		if(hasLabel)
		{
			var __count:int = $obj.labels.count;
			labels = new Vector.<String>;
			labelsFrame = {};
			for each (var __labelName:String in $obj.labels) 
			{
				//count是一个特殊的属性，保存label的数量
				if(__labelName!='count') continue;
				labels[labels.length] = __labelName;
				labelsFrame[__labelName] = $obj.labels[__labelName];
			}
		}
	}
	
	/**
	 * 从字节数组解析普通Object文件解析Metadata数据，ByteArray是从SS格式中提取的
	 * @param $ba 从SS格式中提取的Metadata数据
	 */	
	public function decodeFromByteArray($ba:ByteArray):void
	{
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
			var __addObj:Object = getAddObject($includeName);
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
			var __addXMLList:XMLList = getAddXML($includeName).children();
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
	public function toXMLString($isSimple:Boolean=false, $includeName:Boolean=true, $lineEnding:String='\n'):String
	{
		return getTextLine('<?xml version="1.0" encoding="UTF-8"?>',null, $lineEnding) + toXML($isSimple,$includeName).toXMLString();
	}
	
	/**
	 * 返回TXT格式的Metadata
	 * @param $isSimple 是否简单数据
	 */	
	public function toTXT($isSimple:Boolean=false, $includeName:Boolean=true, $lineEnding:String="\n"):String
	{
		var __str:String = getTextLine('frames',null,$lineEnding);
		var __name:String = null;
		for(var i:int=0;i<totalFrame;i++)
		{
			__name = getFrameName($includeName, i);
			__str += getRectTxt(frameRects[i], originalFrameRects[i], __name, $lineEnding);
		}
		//如果需要附加信息，要在帧信息前面加上frames字样
		if(!$isSimple)
			__str += getAddTXT($includeName, $lineEnding);
		return __str;
	}
	
	/**
	 * 获取Object格式的附加信息
	 */	
	public function getAddObject($includeName:Boolean):Object
	{
		var __jsonObj:Object =	{};
		//写入sheet的类型
		__jsonObj.sheetType = type;
		__jsonObj.hasLabel = hasLabel;
		__jsonObj.maskType = maskType;
		__jsonObj.hasName = $includeName;
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
	public function getAddXML($includeName:Boolean):XML
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
	 * 获取TXT格式的附加信息
	 */	
	public function getAddTXT($includeName:Boolean, $lineEnding:String="\n"):String
	{
		var __str:String = '';
		__str += getTextLine('sheepType', type, $lineEnding);
		__str += getTextLine('hasLabel',hasLabel, $lineEnding);
		__str += getTextLine('maskType',maskType, $lineEnding);
		__str += getTextLine('hasName',$includeName, $lineEnding);
		__str += getTextLine('totalFrame',totalFrame, $lineEnding);
		if(hasLabel)
		{
			__str += getTextLine('labels',null, $lineEnding);
			__str += getTextLine('count', labels.length, $lineEnding);
			for(var __key:String in labelsFrame)
			{
				__str += getTextLine(__key, labelsFrame[__key].toString(), $lineEnding);
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
	public function getRectTxt($sizeRect:Rectangle, $originRect:Rectangle, $name:String = null, $lineEnding:String="\n"):String
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
			$lineEnding;
	}
	
	/**
	 * 返回键名+等号+键值+换行符格式的字符串。若不提供键值，则不加入等号
	 * @param $key	键名
	 * @param $value	键值
	 */	
	private function getTextLine($key:String, $value:*=null, $lineEnding:String="\n"):String
	{
		var __str:String = $key;
		if($value != null)
			__str += '=' + $value.toString();
		return __str + $lineEnding;
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
