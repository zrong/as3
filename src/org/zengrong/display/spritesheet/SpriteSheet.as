////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-11
//  更新时间：2011-09-07
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
	 * @param $force 是否强行解析。如果该值为true，则不会理会_allBmds是否设置过，都会执行解析
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 帧数量为0的时候抛出异常
	 */
	public function parseSheet($force:Boolean=false):void
	{
		//不存在allBmds，或者要求强行解析的情况下执行解析
		if(!_allBmds || $force)
		{
			checkData();
			checkRange();
			_allBmds = createAll();
		}
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
		//帧位图块，将这个块在循环中绘制到大图上
		var __frameBMD:BitmapData = null;
		//如何在帧位图块中取需要绘制的范围
		var __drawRect:Rectangle = new Rectangle();
		for (var i:int = 0; i < _allBmds.length; i++) 
		{
			__frameBMD = _allBmds[i];
			bitmapData.lock();
			//计算修剪帧尺寸与原始帧尺寸的偏移，绘制在大图上的像素并不包含剪切过的空白像素
			//当然，如果帧没有被执行过“修剪空白操作”，那么originalFrame的x和y应该为0，w和h应该与frame相同
			__drawRect.x = 0-metadata.originalFrameRects[i].x;
			__drawRect.y = 0-metadata.originalFrameRects[i].y;
			__drawRect.width = metadata.frameRects[i].width;
			__drawRect.height = metadata.frameRects[i].height;
			bitmapData.copyPixels(__frameBMD, __drawRect, metadata.frameRects[i].topLeft, null, null, true);
			//trace('SpriteSheet.drawSheet:', __frameBMD.rect, __drawRect, metadata.originalFrameRects[i]);
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
	public function addFrame($bmd:BitmapData, $sizeRect:Rectangle=null, $originalRect:Rectangle=null, $name:String=null):void
	{
		if(!_allBmds) _allBmds = new Vector.<BitmapData>;
		_allBmds[_allBmds.length] = $bmd;
		if($sizeRect && metadata)
			metadata.addFrame($sizeRect, $originalRect,$name);
	}
	
	/**
	 * 向SpriteSheet的对应索引中加入一帧
	 */
	public function addFrameAt($index:int, $bmd:BitmapData, $sizeRect:Rectangle=null, $originalRect:Rectangle=null,$name:String=null):void
	{
		if(!_allBmds) _allBmds = new Vector.<BitmapData>;
		_allBmds.splice($index, 0, $bmd);
		if($sizeRect && metadata)
			metadata.addFrameAt($index, $sizeRect, $originalRect, $name);
	}
	
	public function removeFrameAt($index:int):void
	{
		if(_allBmds) _allBmds.splice($index,1);
		if(metadata) metadata.removeFrameAt($index);
	}
	
	/**
	 * 清空原有的帧（如果存在），并保存传递的帧列表
	 * @param $bmds 待设置的帧列表
	 * @param $sizeRects 与帧列表对应的帧sizeRect列表
	 * @param $originalRects 与帧列表对应的帧trimRect列表
	 */
	public function setFrames($bmds:Vector.<BitmapData>, $sizeRects:Vector.<Rectangle>=null, $originalRects:Vector.<Rectangle>=null, $names:Vector.<String>=null):void
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
				var __name:String = $names?$names[i]:null;
				if($originalRects)
					metadata.addFrameAt(i, $sizeRects[i], $originalRects[i], __name);
				else
					metadata.addFrameAt(i, $sizeRects[i], null, __name);
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
		if(__labelRange) return getListFromIndices(__labelRange);
		return null;
	}
	
	/**
	 * 返回解析后的所有的BitmapData列表
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 帧数量为0的时候抛出异常
	 */	
	public function getAll():Vector.<BitmapData>
	{
		//checkData();
		checkRange();
		if(!_allBmds) parseSheet();
		return getListFromRange(0, metadata.totalFrame);
	}
	
	/**
	 * 获取范围内的BitmapData列表
	 * @param $start 开始帧（0基）
	 * @param $total 总帧数
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 可用帧数量为0的时候抛出异常
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
	 * 根据提供的索引列表获取BitmapData列表
	 * @param $indices 需要的帧的索引
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 可用帧数量为0的时候抛出异常
	 */
	public function getListFromIndices($indices:Array):Vector.<BitmapData>
	{
		if(!_allBmds) parseSheet();
		if(!$indices) return null;
		if($indices.length==0) return null;
		var __list:Vector.<BitmapData> = new Vector.<BitmapData>($indices.length, true);
		for(var i:int=0;i<$indices.length;i++)
			__list[i] = getBMDByIndex($indices[i]);
		return __list;
	}
	
	/**
	 * 返回对应索引的BitmapData的修剪版本。如果位图没有被修剪过，直接返回该位图。
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 帧数量为0的时候抛出异常
	 */	
	public function getTrimBMDByIndex($index:int):BitmapData
	{
		if(!_allBmds) parseSheet();
		var __frame:Rectangle = metadata.frameRects[$index];
		var __origin:Rectangle = metadata.originalFrameRects[$index];
		//如果帧没有被修剪过，直接返回原始的位图
		if(__frame.width == __origin.width && 
			__frame.height == __origin.height &&
			__origin.x == 0 && __origin.y == 0)
			return _allBmds[$index];
		var __frameBmd:BitmapData = new BitmapData(__frame.width, __frame.height, true, 0x00000000);
		var __drawRect:Rectangle = new Rectangle(0-__origin.x, 0-__origin.y, __frame.width, __frame.height);
		__frameBmd.copyPixels(_allBmds[$index], __drawRect, new Point(0,0), null, null, true);
		return __frameBmd;
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
		if(metadata.namesIndex[$name] === undefined)
			throw new ReferenceError('寻找的name【'+$name+'】不在SpriteSheet的索引表中');
		return _allBmds[metadata.namesIndex[$name]];
	}

	/**
	 * 创建所有BitmapData列表
	 * @throw ReferenceError 位图和元数据没有设置时抛出异常
	 * @throw RangeError 帧数量为0的时候抛出异常
	 */	
	public function createAll($origin:Boolean=true):Vector.<BitmapData>
	{
		checkData();
		checkRange();
		var __list:Vector.<BitmapData> = new Vector.<BitmapData>(metadata.totalFrame);
		for(var i:int=0;i<metadata.totalFrame;i++)
			__list[i] = createBMDByIndex(i, $origin);
		return __list;
	}
	
	/**
	 * 创建对应索引的BitmapData
	 */	
	public function createBMDByIndex($index:int, $origin:Boolean=true):BitmapData
	{
		var __origin:Rectangle = metadata.originalFrameRects[$index];
		var __rect:Rectangle = metadata.frameRects[$index];
		var __bmd:BitmapData = null;
		if($origin)
		{
			__bmd = new BitmapData(__origin.width, __origin.height, true, 0x00000000);
			__bmd.copyPixels(bitmapData, __rect, new Point(0-__origin.x, 0-__origin.y), null, null, true);
		}
		else
		{
			__bmd = new BitmapData(__rect.width, __rect.height, true, 0x00000000);
			__bmd.copyPixels(bitmapData, __rect, new Point(0, 0), null, null, true);
		}
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
