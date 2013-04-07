package org.zengrong.display.spritesheet
{
import flash.geom.Rectangle;

import org.zengrong.utils.ObjectUtil;

/**
 * SpriteSheetMetadata的JSON格式包装器
 * @author zrong (http://zengrong.net)
 * 创建日期：2013-4-6
 */
public class SpriteSheetMetadataJSON extends SpriteSheetMetadataWrapper
{
	public function SpriteSheetMetadataJSON($meta:ISpriteSheetMetadata)
	{
		super($meta);
	}
	
	/**
	 * 从普通Object文件解析Metadata数据，Object必须由Sprite Sheet Editor生成的JSON格式Metadata解析而来。
	 * 
	 * @param $value 由Sprite Sheet Editor生成的JSON文件解析成的Object
	 * 
	 * @inheritDoc
	 */	
	override public function parse($value:*):ISpriteSheetMetadata
	{
		var __obj:Object = $value;
		var i:int=0;
		type = __obj.sheetType.toString();
		hasLabel = __obj.hasLabel;
		hasName = __obj.hasName;
		maskType = int(__obj.maskType);
		var __totalFrame:int = __obj.totalFrame;
		setup(true);
		var __frames:Array = __obj.frames;
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
			addFrameAt(i, __frameRect, __originalRect);
			if(hasName)
			{
				names[i] = __frame.name;
				namesIndex[names[i]] = i;
			}
		}
		if(hasLabel)
		{
			var __count:int = __obj.labels.count;
			labels = new Vector.<String>;
			labelsFrame = {};
			for each (var __labelName:String in __obj.labels) 
			{
				//count是一个特殊的属性，保存label的数量
				if(__labelName!='count') continue;
				labels[labels.length] = __labelName;
				labelsFrame[__labelName] = __obj.labels[__labelName];
			}
		}
		return _metadata;
	}
	
	/**
	 * @inheritDoc
	 */
	override public function objectify($isSimple:Boolean=false, $includeName:Boolean=true):*
	{
		return JSON.stringify(toObject($isSimple, $includeName));
	}
	
	/**
	 * 返回一个标准的Object对象
	 * 
	 * @param $isSimple 是否简单数据
	 */	
	private function toObject($isSimple:Boolean=false, $includeName:Boolean=true):Object
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
	 * 获取Object格式的附加信息
	 */	
	private function getAddObject($includeName:Boolean):Object
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
	 * 返回Frame的Rect的Json格式
	 */	
	private function getRectObject($sizeRect:Rectangle, $originRect:Rectangle, $name:String=null):Object
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

	
}
}