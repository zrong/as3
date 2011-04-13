////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-11
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.spritesheet
{
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 保存SpriteSheet的BitmapData以及相关的信息，提供将BitmapData转换成序列的方法
 * @author zrong
 */
dynamic public class SpriteSheet
{
	public function SpriteSheet($bmd:BitmapData=null, $meta:SpriteSheetMetadata=null)
	{
		bitmapData = $bmd;
		metaData = $meta;
	}
	
	/**
	 * 整个Sheet的位图数据
	 */	
	public var bitmapData:BitmapData;
	
	/**
	 * Sheet的元数据
	 */	
	public var metaData:SpriteSheetMetadata;
	
	/**
	 * 使用copyPixels写入图像的索引，每调用一次copyPixels，该索引增加1
	 */	
	public var copyPixelIndex:int = 0;
	
	public function destroy():void
	{
		if(bitmapData)
			bitmapData.dispose();
		if(metaData)
			metaData.destroy();
		copyPixelIndex = 0;
	}
	
	public function addFrame($bmd:BitmapData):void
	{
		if(!bitmapData || !metaData)
			throw new ReferenceError('位图和(或)元数据没有设置！');
		if(copyPixelIndex>=metaData.frameCount)
			return;
		
		bitmapData.lock();
		//从metaData中获取该图像对应的Frame的rect，转换成Point
		var __point:Point =  new Point(metaData.frameSizeRect[copyPixelIndex].x, metaData.frameSizeRect[copyPixelIndex].y);
		bitmapData.copyPixels($bmd, $bmd.rect, __point, null, null, true);
		bitmapData.unlock();
		copyPixelIndex ++;
	}
	
	/**
	 * 返回对应Label名的所有BitmapData列表
	 */	
	public function getLabels($label:String):Vector.<BitmapData>
	{
		if(metaData && bitmapData)
		{
			var __label:Array = metaData.labelsFrame[$label];
			if(__label)
			{
				return metaData.isEqualSize ? getEqualBMD(__label[0], __label[1]) : getUnequalBMD(__label[0], __label[1]);
			}
			return null;
		}
		return null;
	}
	
	/**
	 * 返回解析后的所有的BitmapList列表
	 */	
	public function getList():Vector.<BitmapData>
	{
		if(metaData && bitmapData)
		{
			return metaData.isEqualSize ? getEqualBMD(0, metaData.frameCount) : getUnequalBMD(0, metaData.frameCount);
		}
		return null;
	}
	
	/**
	 * 获取大小相等的BitmapData列表
	 * @param $start 开始帧（0基）
	 * @param $total 总帧数
	 */	
	private function getEqualBMD($start:int, $total:int):Vector.<BitmapData>
	{
		var __list:Vector.<BitmapData> = new Vector.<BitmapData>($total, true);
		var __bmd:BitmapData = new BitmapData(metaData.frameSize[1], metaData.frameSize[2], true, 0x00000000);
		var __rect:Rectangle = new Rectangle(0, 0, metaData.frameSize[1], metaData.frameSize[2]);
		var __point:Point = new Point(0, 0);
		for(var i:int=0;i<$total;i++)
		{
			__rect.x = (i+$start)%metaData.frameSize[0] * metaData.frameSize[1];
			__rect.y = int((i+$start)/metaData.frameSize[0]) * metaData.frameSize[2];
			__bmd.copyPixels(bitmapData, __rect, __point, null, null, true);
			__list[i] = __bmd;
		}
		return __list;
	}
	
	/**
	 * 获取大小不相等的BitmapData列表
	 * @param $start 开始帧（0基）
	 * @param $total 总帧数
	 */	
	private function getUnequalBMD($start:int, $total:int):Vector.<BitmapData>
	{
		var __list:Vector.<BitmapData> = new Vector.<BitmapData>($total, true);
		var __bmd:BitmapData = null;
		var __rect:Rectangle = null;
		var __point:Point = new Point(0, 0);
		for(var i:int=0;i<$total;i++)
		{
			__rect = metaData.frameSizeRect[$start];
			__bmd = new BitmapData(__rect.width, __rect.height, true, 0x00000000);
			__bmd.copyPixels(bitmapData, __rect, __point, null, null, true);
			__list[i] = __bmd;
		}
		return __list;
	}
	
}
}