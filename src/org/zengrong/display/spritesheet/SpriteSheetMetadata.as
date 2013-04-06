////////////////////////////////////////////////////////////////////////////////
//  zengrong.org
//  创建者:	zrong
//  创建时间：2011-04-11
//	修改时间：2012-02-02
//	修改时间：2013-04-06 实现 ISpriteSheetMetadata接口
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.spritesheet
{
import flash.geom.Rectangle;
import flash.utils.ByteArray;

import org.zengrong.utils.ObjectUtil;

/**
 * 处理SpriteSheet的元数据
 * @author zrong
 */
public class SpriteSheetMetadata implements ISpriteSheetMetadata
{
	public function SpriteSheetMetadata()
	{
		setup(true);
	}
	
	private var _type:String;

	/**
	 * @inheritDoc
	 */
	public function get type():String
	{
		return _type;
	}

	public function set type($value:String):void
	{
		_type = $value;
	}

	private var _hasLabel:Boolean;

	/**
	 * @inheritDoc
	 */
	public function get hasLabel():Boolean
	{
		return _hasLabel;
	}

	/**
	 * @private
	 */
	public function set hasLabel($value:Boolean):void
	{
		_hasLabel = $value;
	}

	private var _hasName:Boolean;

	/**
	 * @inheritDoc
	 */
	public function get hasName():Boolean
	{
		return _hasName;
	}

	/**
	 * @private
	 */
	public function set hasName($value:Boolean):void
	{
		_hasName = $value;
	}

	private  var _maskType:int;

	/**
	 * @inheritDoc
	 */
	public function get maskType():int
	{
		return _maskType;
	}

	/**
	 * @private
	 */
	public function set maskType($value:int):void
	{
		_maskType = $value;
	}

	
	private var _labels:Vector.<String>;

	/**
	 * @inhericDoc
	 */
	public function get labels():Vector.<String>
	{
		return _labels;
	}

	/**
	 * @private
	 */
	public function set labels($value:Vector.<String>):void
	{
		_labels = $value;
	}

	
	private var _labelsFrame:Object;

	/**
	 * @inheritDoc
	 */
	public function get labelsFrame():Object
	{
		return _labelsFrame;
	}

	/**
	 * @private
	 */
	public function set labelsFrame($value:Object):void
	{
		_labelsFrame = $value;
	}

	private var _names:Vector.<String>;

	/**
	 * @inheritDoc
	 */
	public function get names():Vector.<String>
	{
		return _names;
	}

	/**
	 * @private
	 */
	public function set names($value:Vector.<String>):void
	{
		_names = $value;
	}

	
	private var _namesIndex:Object;

	/**
	 * @inheritDoc
	 */
	public function get namesIndex():Object
	{
		return _namesIndex;
	}

	/**
	 * @private
	 */
	public function set namesIndex($value:Object):void
	{
		_namesIndex = $value;
	}

	
	private var _frameRects:Vector.<Rectangle>;

	/**
	 * @inheritDoc
	 */
	public function get frameRects():Vector.<Rectangle>
	{
		return _frameRects;
	}

	/**
	 * @private
	 */
	public function set frameRects($value:Vector.<Rectangle>):void
	{
		_frameRects = $value;
	}

	
	private var _originalFrameRects:Vector.<Rectangle>;

	/**
	 * @inheritDoc
	 */
	public function get originalFrameRects():Vector.<Rectangle>
	{
		return _originalFrameRects;
	}

	/**
	 * @private
	 */
	public function set originalFrameRects($value:Vector.<Rectangle>):void
	{
		_originalFrameRects = $value;
	}

	
	//----------------------------------------
	// getter/setter
	//----------------------------------------
	
	/**
	 * @inheritDoc
	 */	
	public function get totalFrame():int
	{
		return frameRects ? frameRects.length : 0;
	}
	
	//----------------------------------
	//  public
	//----------------------------------
	/**
	 * @inheritDoc
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
	 * @inheritDoc
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
	 * @inheritDoc
	 */	
	public function setup($force:Boolean=false):void
	{
		if($force || !frameRects)
		{
			frameRects = new Vector.<Rectangle>;
			originalFrameRects = new Vector.<Rectangle>;
		}
	}
	
	/**
	 * @throw TypeError 提供的Label名称或者帧索引为空的时候抛出错误
	 * 
	 * @inheritDoc
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
	 * @inheritDoc
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
	 * @inheritDoc
	 */	
	public function addFrame($sizeRect:Rectangle, $originalRect:Rectangle=null, $name:String=null):void
	{
//		if(frameRects.length>=frameCount)
//			return;
		setup();
		writeFrame(frameRects.length, $sizeRect, $originalRect, $name);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addFrameAt($index:int, $sizeRect:Rectangle, $originalRect:Rectangle=null, $name:String=null):void
	{
		setup();
		writeFrame($index, $sizeRect, $originalRect, $name);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeFrameAt($index:int):void
	{
		frameRects.splice($index,1);
		originalFrameRects.splice($index,1);
		//如果存在label，也要从label中移除这个帧
		if(hasLabel && labelsFrame)
		{
			var __framesIndices:Array;
			//从Label中删除帧编号
			for each(__framesIndices in labelsFrame)
			{
				var __frameIndexInLabel:int = __framesIndices.indexOf($index);
				if(__frameIndexInLabel != -1)
				{
					__framesIndices.splice(__frameIndexInLabel, 1);
					break;
				}
			}
			//将label中所有大于被删除帧编号的帧编号减1
			for each(__framesIndices in labelsFrame)
			{
				for (var i:int = 0; i < __framesIndices.length; i++) 
				{
					if(__framesIndices[i] > $index) __framesIndices[i]--;
				}
			}
		}
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
	
	protected function writeFrame($index:int, $sizeRect:Rectangle, $originalRect:Rectangle=null, $name:String=null):void
	{
		if(!$originalRect) $originalRect = new Rectangle(0, 0, $sizeRect.width, $sizeRect.height);
		frameRects.splice($index, 0, $sizeRect);
		originalFrameRects.splice($index, 0, $originalRect);
		//trace('增加帧：', $index, $name);
		if($name && names && namesIndex)
		{
			names.splice($index, 0, $name);
			namesIndex[$name] = $index;
		}
	}
	
	/**
	 * @inheritDoc
	 */	
	public function getFrameName($includeName:Boolean, $index:int):String
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
	
	//----------------------------------------
	// decode
	//----------------------------------------
	
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
