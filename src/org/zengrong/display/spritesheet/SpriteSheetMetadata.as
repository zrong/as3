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

/**
 * 处理SpriteSheet的元数据
 * @author zrong
 */
public class SpriteSheetMetadata
{
	public function SpriteSheetMetadata($meta:ByteArray=null)
	{
		if($meta)
		{
			byteArray = $meta;
			decode();
		}
	}
	
	public var byteArray:ByteArray;
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
	public var isLabel:Boolean;
	
	/**
	 * mask的类型，详见org.zengrong.display.spritesheet.MaskType。mask信息只能存在于JPG文件中
	 */	
	public var maskType:int;
	
	/**
	 * Sheet的帧数
	 */	
	public var frameCount:int=-1;
	
	/**
	 * 每个帧的大小，若equalSize为真，则包含3个整型元素代表每行数量、宽、高；否则包含frameCount数量的x,y,w,h
	 */	
	public var frameSize:Vector.<int>;
	
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
	 * 根据当前设置的Sheet大小和Frame大小，判断每行最多可以放几个Frame。只有当isEqualSize为true的时候，值才大于0
	 */	
	public function get column():int
	{
		if(frameCount == -1 || !frameSize || !frameSizeRect)
			throw new RangeError('请先执行setup设置！');
		return isEqualSize ? frameSize[0] : -1;
	}
	/**
	 * 销毁整个对象
	 */	
	public function destroy():void
	{
		byteArray = null;
		type = null;
		isEqualSize = false;
		isLabel = false;
		maskType = 0;
		frameCount = -1;
		frameSize = null;
		frameSizeRect = null;
		labels = null;
		labelsFrame = null;
	}
	
	/**
	 * 解析MetaData
	 */	
	public function decode():void
	{
		if(byteArray)
		{
			byteArray.position = 0;
			type = byteArray.readUTF();
			isEqualSize = byteArray.readBoolean();
			isLabel = byteArray.readBoolean();
			maskType = byteArray.readByte();
			frameCount = byteArray.readShort();
			setup();
			if(isEqualSize)
				decodeEqualFrame();
			else
				decodeUnequalFrame();
			if(isLabel)
				parseLabels();
		}
	}
	
	/**
	 * 根据设置的属性初始化一些值
	 */	
	public function setup($frameCount:int=-1, $isEqual:Boolean=false):void
	{
		//如果使用Label，总帧数根据每个Label的帧数之和计算
		if(isLabel)
		{
			frameCount = 0;
			for each(var __labelFrame:Array in labelsFrame)
			{
				frameCount += __labelFrame[1];
			}
		}
		else
		{
			frameCount = $frameCount;
		}
		isEqualSize = $isEqual;
		if(frameCount == -1)
			throw new RangeError('帧数量还未设定！');
		frameSize = isEqualSize ? new Vector.<int>(3, true) : new Vector.<int>(frameCount*4, true);
		frameSizeRect = new Vector.<Rectangle>(frameCount, true);
	}
	
	/**
	 * 设置Label的属性
	 * @param $isLabel	是否使用了Label
	 * @param $items	Label的数组
	 * 
	 */	
	public function setLabels($isLabel:Boolean, $items:Array=null):void
	{
		//必须传递可用的$items才算是使用了Label，否则都算没有Label
		if($isLabel && $items && $items.length>0)
		{
			isLabel = true;
			labels = new Vector.<String>($items.length, true);
			labelsFrame = {};
			for(var i:int=0; i<$items.length; i++)
			{
				labels[i] = $items[i].label;
				labelsFrame[labels[i]] = [$items[i].first, $items[i].total];
			}
		}
		else
		{
			isLabel = false;
			labels = null;
			labelsFrame = null;
		}
	}
	/**
	 * 从外部向数组中添加不相等的帧，一般在循环中执行
	 */	
	public function addUnequalFrameSize($rect:Rectangle):void
	{
		if(frameSizeRect.length>=frameCount)
			return;
		if(frameCount == -1 || !frameSize || !frameSizeRect)
			throw new RangeError('请先执行setup设置！');
		writeUnequalFrame($rect);
	}
	
	/**
	 * 从外部向数组中添加大小相等的帧，仅执行一次
	 * @param $column	有几列
	 * @param $w		帧宽度
	 * @param $h		帧高度
	 * 
	 */	
	public function addEqualFrameSize($column:int, $w:int, $h:int):void
	{
		if(frameCount == -1 || !frameSize || !frameSizeRect)
			throw new RangeError('请先执行setup设置！');
		frameSize[0] = $column;
		frameSize[1] = $w;
		frameSize[2] = $h;
		writeEqualFrame();
	}
	
	/**
	 * 将大小相等的帧的尺寸写入数组，第1项为一行中有几帧，第2项为帧宽度，第3项为帧高度 
	 * @return 
	 */	
	private function decodeEqualFrame():void
	{
		for(var i:int=0;i<3;i++)
		{
			frameSize[i] = byteArray.readShort();
		}
		writeEqualFrame();
	}
	
	private function writeEqualFrame():void
	{
		var __rect:Rectangle = null;
		var __x:int=0;
		var __y:int=0;
		for(var i:int=0;i<frameCount;i++)
		{
			__x = frameSize[1] * (i%frameSize[0]);
			__y = frameSize[2] * int(i/frameSize[0]);
			frameSizeRect[i] = new Rectangle(__x, __y, frameSize[1], frameSize[2]);
		}
	}
	
	private function decodeUnequalFrame():void
	{
		var __rect:Rectangle = null;
		for(var i:int=0;i<frameCount;i++)
		{
			writeUnequalFrame(new Rectangle(byteArray.readShort(), byteArray.readShort(), byteArray.readShort(), byteArray.readShort())); 
		}
	}
	
	private function writeUnequalFrame($rect:Rectangle):void
	{
		frameSizeRect[frameSizeRect.length] = $rect;
		frameSize[frameSize.length] = $rect.x;
		frameSize[frameSize.length] = $rect.y;
		frameSize[frameSize.length] = $rect.width;
		frameSize[frameSize.length] = $rect.height;
	}
	
	private function parseLabels():void
	{
		var __count:int = byteArray.readShort();
		labels = new Vector.<String>(__count, true);
		labelsFrame = {};
		for(var i:int=0; i<__count; i++)
		{
			labels[i] = byteArray.readUTF();
			labelsFrame[labels[i]] = [byteArray.readShort(), byteArray.readShort()];
		}
	}
}
}