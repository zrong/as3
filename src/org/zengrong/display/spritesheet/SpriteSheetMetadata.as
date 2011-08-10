////////////////////////////////////////////////////////////////////////////////
//  youxi.com
//  创建者:	zrong
//  创建时间：2011-04-11
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.spritesheet
{
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
	public function SpriteSheetMetadata($totalFrame:int=-1)
	{
		if($totalFrame > 0)	setup($totalFrame);
	}
	
	/**
	 * Sheet的类型，见SpriteSheetType
	 */	
	public var type:String;
	
	/**
	 * 帧的大小是否相等
	 */	
	public var isEqualSize:Boolean;
	
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
	 * Sheet的帧数
	 */	
	public var totalFrame:int=-1;
	
	/**
	 * 每个帧的Rect
	 */	
	public var frameSizeRect:Vector.<Rectangle>;
	
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
		__meta.isEqualSize = isEqualSize;
		__meta.hasLabel = hasLabel;
		__meta.hasName = hasName;
		__meta.maskType = maskType;
		__meta.totalFrame = totalFrame;
		if(frameSizeRect)
		{
			__meta.frameSizeRect = new Vector.<Rectangle>;
			for (var i:int = 0; i < frameSizeRect.length; i++) 
			{
				__meta.frameSizeRect[i] = frameSizeRect[i].clone();
			}
		}
		if(labels)
			__meta.labels = labels.concat();
		if(labelsFrame)
		{
			__meta.labelsFrame = {};
			for(var __label:String in labelsFrame) 
			{
				__meta.labelsFrame[__label] = (labelsFrame[__label] as Array).concat();
			}
		}
		if(names)
			__meta.names = names.concat();
		if(namesIndex)
		{
			__meta.namesIndex = {};
			for(var __name:String in namesIndex) 
			{
				__meta.namesIndex[__name] = namesIndex[__name];
			}
		}
		return __meta;
	}
	/**
	 * 销毁整个对象
	 */	
	public function destroy():void
	{
		type = null;
		isEqualSize = false;
		hasLabel = false;
		maskType = 0;
		hasName = false;
		totalFrame = -1;
		frameSizeRect = null;
		labels = null;
		labelsFrame = null;
		names = null;
		namesIndex = null;
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
		isEqualSize = $ba.readBoolean();
		hasLabel = $ba.readBoolean();
		hasName = $ba.readBoolean();
		maskType = $ba.readByte();
		totalFrame = $ba.readShort();
		setup(totalFrame, isEqualSize);
		for(i=0;i<totalFrame;i++)
		{
			writeFrame(new Rectangle($ba.readShort(), $ba.readShort(), $ba.readShort(), $ba.readShort())); 
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
			names = new Vector.<String>(totalFrame, true);
			namesIndex = {};
			for(i=0;i<totalFrame;i++)
			{
				names[i] = $ba.readUTF();
				namesIndex[names[i]] = $ba.readShort();
			}
		}
	}
	
	/**
	 * 从XML文件解析Metadata数据，XML文件必须由SpriteSheetPacker生成。
	 * @param $xml 由SpriteSheetPacker生成的XML文件，或者自行生成且符合SpriteSheetPacker格式的XML文件。
	 */	
	public function decodeFormXML($xml:XML):void
	{
		var i:int=0;
		type = $xml.sheetType.toString();
		isEqualSize = $xml.isEqualSize.toString() == 'true';
		hasLabel = $xml.hasLabel.toString() == 'true';
		hasName = $xml.hasName.toString() == 'true';
		maskType = int($xml.maskType.toString());
		totalFrame = int($xml.totalFrame.toString());
		setup(totalFrame, isEqualSize);
		var __frames:XMLList = $xml.frames.children();
		var __frame:XML = null;
		for(i=0;i<totalFrame;i++)
		{
			__frame = __frames[i];
			writeFrame(new Rectangle(int(__frame.x.toString()), int(__frame.y.toString()), int(__frame.w.toString()), int(__frame.h.toString()))); 
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
		if(hasName)
		{
			var __namesXML:XMLList = $xml.names.children();
			names = new Vector.<String>(totalFrame, true);
			namesIndex = {};
			for(i=0;i<totalFrame;i++)
			{
				names[i] = __namesXML[i].localName();
				namesIndex[names[i]] = int(__namesXML[i].toString());
			}
		}
	}
	
	/**
	 * 根据设置的属性初始化一些值
	 */	
	public function setup($totalFrame:int=-1, $isEqual:Boolean=false):void
	{
		if($totalFrame == -1)
			throw new RangeError('帧数量还未设定！');
		isEqualSize = $isEqual;
		totalFrame = $totalFrame;
		frameSizeRect = new Vector.<Rectangle>();
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
	public function addFrameSize($rect:Rectangle):void
	{
//		if(frameSizeRect.length>=frameCount)
//			return;
		if(totalFrame == -1 || !frameSizeRect)
			throw new RangeError('请先执行setup设置！');
		writeFrame($rect);
	}
	
	private function writeFrame($rect:Rectangle):void
	{
		frameSizeRect[frameSizeRect.length] = $rect;
	}
	
	public function toString():String
	{
		return 'org.zengrong.display.spritesheet::SpriteSheetMetadata{'+
				'type:'+type+
				',hasLabel:'+hasLabel+
				',isEqualSize:'+isEqualSize+
				',hasName:'+hasName+
				',totalFrame:'+totalFrame+
				',maskType:'+maskType+
				',labels:'+ObjectUtil.array2String(labels)+
				',labelsFrame:'+ObjectUtil.obj2String(labelsFrame)+
				',frameSizeRect:'+ObjectUtil.array2String(frameSizeRect)+
				',names:'+ObjectUtil.array2String(names)+
				',namesIndex:'+ObjectUtil.obj2String(namesIndex)+
				'}';
	}
}
}
