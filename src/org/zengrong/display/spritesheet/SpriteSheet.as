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
	 * 保存所有BMD的数组
	 */
	private var _allBmds:Vector.<BitmapData>;

	/**
	 * 因为bitmapData实际上是一整块Sheet，这个方法能够将整块Sheet解析成需要的数据
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 帧数量为0的时候抛出异常
	 */
	public function parseSheet():void
	{
		checkData();
		checkRange();
		_allBmds = createAll();
	}
	
	/**
	 * 根据allBMDs中的bitmapdata列表，绘制整块的Sheet
	 * @throw TypeError 没有提供被绘制的bitmapData，或缺少metadata数据
	 * @throw RangeError metadata与spritesheet中的帧数量不匹配
	 */
	public function drawSheet($bmd:BitmapData=null):void
	{
		//没有_allBMDs，不绘制
		if(!_allBmds) return;
		if(!$bmd && !bitmapData) throw new TypeError('没有可供绘制的bitmapdata！');
		if(!metadata) throw new TypeError('必须提供metadata才能开始绘制!');
		if(!metadata.frameRects || !metadata.originalFrameRects) 
			throw new TypeError('metadata中没有帧数据！');
		if(metadata.totalFrame != _allBmds.length) 
			throw new RangeError('metadata与spritesheet中的帧数量不匹配。meta:'+metadata.totalFrame+',sheet:'+_allBmds.length);
		//如果提供了bitmapdata，就使用提供的覆盖当前保存的
		if($bmd) bitmapData = $bmd;
		var __frameBMD:BitmapData = null;
		//var __frameDrawPoint:Point = new Point();
		for (var i:int = 0; i < _allBmds.length; i++) 
		{
			__frameBMD = _allBmds[i];
			bitmapData.lock();
//			//从metadata中获取该图像对应的Frame的rect，转换成Point
//			__frameDrawPoint.x = metadata.frameSizeRect[i].x
//			__frameDrawPoint.y = metadata.frameSizeRect[i].y;
			bitmapData.copyPixels(__frameBMD, __frameBMD.rect, metadata.frameRects[i].topLeft, null, null, true);
			bitmapData.unlock();
		}
	}
	
	/**
	 * 销毁所有对象
	 */
	public function destroy():void
	{
		//销毁数组中的图像
		while(_allBmds && _allBmds.length>0)
		{
			_allBmds.pop().dispose();
		}
		dispose();
		if(metadata)
			metadata.destroy();
		bitmapData = null;
		metadata = null;
	}
	
	public function clone():SpriteSheet
	{
		var __ss:SpriteSheet = new SpriteSheet();
		var __bmds:Vector.<BitmapData> = cloneFrames();
		if(__bmds)
			__ss.setFrames(__bmds);
		if(bitmapData)
			__ss.bitmapData = bitmapData.clone();
		if(metadata)
			__ss.metadata = metadata.clone();
		return __ss;
	}
	
	public function cloneFrames():Vector.<BitmapData>
	{
		if(_allBmds)
		{
			var __bmds:Vector.<BitmapData> = new Vector.<BitmapData>;
			for (var i:int = 0; i < _allBmds.length; i++) 
			{
				__bmds[i] = _allBmds[i].clone();
			}
			return __bmds;
		}
		return null;
	}

	/**
	 * 仅销毁bitmapDataSheet。在parseSheet之后，就可以执行这个方法释放内存。
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
	 */	
	public function addFrame($bmd:BitmapData, $sizeRect:Rectangle=null, $originalRect:Rectangle=null):void
	{
		if(!_allBmds) _allBmds = new Vector.<BitmapData>;
		var __index:int = _allBmds.length;
		_allBmds[__index] = $bmd;
		if($sizeRect && metadata)
			metadata.addFrame($sizeRect, $originalRect);
	}
	
	/**
	 * 向SpriteSheet的对应索引中加入一帧
	 */
	public function addFrameAt($index:int, $bmd:BitmapData, $sizeRect:Rectangle=null, $originalRect:Rectangle=null):void
	{
		if(!_allBmds) _allBmds = new Vector.<BitmapData>;
		_allBmds[$index] = $bmd;
		if($sizeRect && metadata)
			metadata.addFrameAt($index, $sizeRect, $originalRect);
	}
	
	/**
	 * 清空原有的帧（如果存在），并保存传递的帧列表
	 * @param $bmds 待设置的帧列表
	 * @param $sizeRects 与帧列表对应的帧sizeRect列表
	 * @param $originalRects 与帧列表对应的帧trimRect列表
	 */
	public function setFrames($bmds:Vector.<BitmapData>, $sizeRects:Vector.<Rectangle>=null, $originalRects:Vector.<Rectangle>=null):void
	{
		while(_allBmds && _allBmds.length>0)
			_allBmds.pop().dispose();
		_allBmds = $bmds;
		if($sizeRects && metadata)
		{
			metadata.frameRects = new Vector.<Rectangle>;
			metadata.originalFrameRects = new Vector.<Rectangle>;
			for (var i:int = 0; i < $sizeRects.length; i++) 
			{
				if($originalRects)
					metadata.addFrameAt(i, $sizeRects[i], $originalRects[i]);
				else
					metadata.addFrameAt(i, $sizeRects[i]);
			}
		}
	}
	
	/**
	 * 返回对应Label名的所有BitmapData列表
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 帧数量为0的时候抛出异常
	 */	
	public function getLabel($label:String):Vector.<BitmapData>
	{
		if(!_allBmds) parseSheet();
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
		if(!_allBmds) parseSheet();
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
		if(!_allBmds) parseSheet();
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
		if(!_allBmds) parseSheet();
		return _allBmds[$index];
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
		if(!_allBmds) parseSheet();
		if(!metadata.hasName || !metadata.names)
			throw new ReferenceError('这个SpriteSheet不包含name。');
		return _allBmds[metadata.namesIndex[$name]];
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
		var __origin:Rectangle = metadata.originalFrameRects[$index];
		var __rect:Rectangle = metadata.frameRects[$index];
		var __bmd:BitmapData = new BitmapData(__origin.width, __origin.height, true, 0x00000000);
		__bmd.copyPixels(bitmapData, __rect, new Point(0-__origin.x, 0-__origin.y), null, null, true);
		return __bmd;
	}
	private function checkData():void
	{
		if(!metadata || !bitmapData)
			throw new ReferenceError('位图和(或)元数据没有设置！');
	}
	
	private function checkRange():void
	{
		if(metadata.totalFrame<=0 || metadata.frameRects.length<=0)
			throw new RangeError('SpriteSheet中的帧数必须大于0！');
	}
	
}
}
