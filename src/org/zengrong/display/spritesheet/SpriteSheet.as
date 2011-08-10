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
public class SpriteSheet
{
	public function SpriteSheet($bmd:BitmapData=null, $meta:SpriteSheetMetadata=null)
	{
		bitmapData = $bmd;
		metadata = $meta;
		if(bitmapData && metadata)
			parseBMD();
	}
	
	/**
	 * 整个Sheet的位图数据
	 */	
	public var bitmapData:BitmapData;
	
	/**
	 * Sheet的元数据
	 */	
	public var metadata:SpriteSheetMetadata;
	
	/**
	 * 使用copyPixels写入图像的索引，每调用一次copyPixels，该索引增加1
	 */	
	public var copyPixelIndex:int = 0;

	/**
	 * 保存所有BMD的数组
	 */
	private var _allBMDs:Vector.<BitmapData>;

	/**
	 * 因为bitmapData实际上是一整块Sheet，这个方法能够将整块Sheet解析成需要的数据
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 帧数量为0的时候抛出异常
	 */
	public function parseBMD():void
	{
		checkData();
		checkRange();
		_allBMDs = createAll();
	}
	
	/**
	 * 销毁所有对象
	 */
	public function destroy():void
	{
		//销毁数组中的图像
		while(_allBMDs && _allBMDs.length>0)
		{
			_allBMDs.pop().dispose();
		}
		dispose();
		if(metadata)
			metadata.destroy();
		bitmapData = null;
		metadata = null;
		copyPixelIndex = 0;
	}
	
	public function clone():SpriteSheet
	{
		var __ss:SpriteSheet = new SpriteSheet();
		__ss.copyPixelIndex = copyPixelIndex;
		if(_allBMDs)
		{
			var __bmds:Vector.<BitmapData> = new Vector.<BitmapData>;
			for (var i:int = 0; i < _allBMDs.length; i++) 
			{
				__bmds[i] = _allBMDs[i].clone();
			}
			__ss.setFrames(__bmds);
		}
		if(bitmapData)
			__ss.bitmapData = bitmapData;
		if(metadata)
			__ss.metadata = metadata;
		return __ss;
	}

	/**
	 * 仅销毁bitmapDataSheet。在parseBMD之后，就可以执行这个方法释放内存。
	 */
	public function dispose():void
	{
		if(bitmapData)
		{
			bitmapData.dispose();
			bitmapData = null;
		}
	}
	
	/**
	 * 向SpriteSheet中加入一帧
	 * @param $bmd 加入的帧的BitmapData
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 */	
	public function addFrame($bmd:BitmapData):void
	{
		checkData();
		if(copyPixelIndex>=metadata.totalFrame)
			return;
		bitmapData.lock();
		//从metadata中获取该图像对应的Frame的rect，转换成Point
		var __point:Point =  new Point(metadata.frameSizeRect[copyPixelIndex].x, metadata.frameSizeRect[copyPixelIndex].y);
		bitmapData.copyPixels($bmd, $bmd.rect, __point, null, null, true);
		bitmapData.unlock();
		copyPixelIndex ++;
	}
	
	public function setFrames($bmds:Vector.<BitmapData>):void
	{
		while(_allBMDs && _allBMDs.length>0)
			_allBMDs.pop().dispose();
		_allBMDs = $bmds;
	}
	
	/**
	 * 返回对应Label名的所有BitmapData列表
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 帧数量为0的时候抛出异常
	 */	
	public function getLabel($label:String):Vector.<BitmapData>
	{
		if(!_allBMDs)
			parseBMD();
		if(!metadata.hasLabel || metadata.labels.length==0 || !metadata.labelsFrame)
			throw new ReferenceError('这个SpriteSheet不包含label。');
		var __labelRange:Array = metadata.labelsFrame[$label];
		if(__labelRange)
			return getListFromRange(__labelRange[0], __labelRange[1]);
		return null;
	}
	
	/**
	 * 返回解析后的所有的BitmapData列表
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 帧数量为0的时候抛出异常
	 */	
	public function getAll():Vector.<BitmapData>
	{
		checkData();
		checkRange();
		if(!_allBMDs)
			parseBMD();
		return getListFromRange(0, metadata.totalFrame);
	}
	
	/**
	 * 获取范围内的BitmapData列表
	 * @param $start 开始帧（0基）
	 * @param $total 总帧数
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 帧数量为0的时候抛出异常
	 */	
	public function getListFromRange($start:int, $total:int):Vector.<BitmapData>
	{
		if(!_allBMDs)
			parseBMD();
		var __list:Vector.<BitmapData> = new Vector.<BitmapData>($total, true);
		for(var i:int=0;i<$total;i++)
			__list[i] = getBMDByIndex(i+$start);
		return __list;
	}
	
	/**
	 * 返回对应索引的BitmapData
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 帧数量为0的时候抛出异常
	 */	
	public function getBMDByIndex($index:int):BitmapData
	{
		if(!_allBMDs)
			parseBMD();
		return _allBMDs[$index];
	}
	
	/**
	 * 根据位图资源的名称返回BitmapData
	 * @param $name 需要的位图资源的名称
	 * @throw ReferenceError 位图和元数据没有设置时抛出
	 * @throw ReferenceError SpriteSheet中不包含名称的时候抛出
	 * @throw RangeError 帧数量为0的时候抛出异常
	 */	
	public function getBMDByName($name:String):BitmapData
	{
		if(!_allBMDs)
			parseBMD();
		if(!metadata.hasName || !metadata.names)
			throw new ReferenceError('这个SpriteSheet不包含name。');
		return _allBMDs[metadata.namesIndex[$name]];
	}

	/**
	 * 创建所有BitmapData列表
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 帧数量为0的时候抛出异常
	 */	
	private function createAll():Vector.<BitmapData>
	{
		checkData();
		checkRange();
		var __list:Vector.<BitmapData> = new Vector.<BitmapData>(metadata.totalFrame);
		for(var i:int=0;i<metadata.totalFrame;i++)
			__list[i] = createBMDByIndex(i);
		return __list;
	}
	
	/**
	 * 创建对应索引的BitmapData
	 */	
	public function createBMDByIndex($index:int):BitmapData
	{
		const __POINT:Point = new Point();
		var __rect:Rectangle = metadata.frameSizeRect[$index];
		var __bmd:BitmapData = new BitmapData(__rect.width, __rect.height, true, 0x00000000);
		__bmd.copyPixels(bitmapData, __rect, __POINT, null, null, true);
		return __bmd;
	}
	private function checkData():void
	{
		if(!metadata || !bitmapData)
			throw new ReferenceError('位图和(或)元数据没有设置！');
	}
	
	private function checkRange():void
	{
		if(metadata.totalFrame<=0 || metadata.frameSizeRect.length<=0)
			throw new RangeError('SpriteSheet中的帧数必须大于0！');
	}
	
}
}
