////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-12-17
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display
{
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 用于将一行宽度相同的连续位图按照提供的宽度和高度切成不同大小的块。
 * 例如：有一个逐渐变大的图片序列，将它拼在一张图片中，可以使用BMPDiverseSlice来切割。
 * @author zrong
 */
public class BMPDiverseSlicer extends BMPSlicer
{
	/**
	 * @param $bmd 要切割的BitmapData
	 * @param $widthArray 切片的宽度数组
	 * @param $heightArray 切片的高度数组
	 * @param $transparent 切片是否透明
	 * @param $direction 是横向切割还是纵向切割
	 * @param $length 切片的数量
	 */	
	public function BMPDiverseSlicer($bmd:BitmapData=null, $widthArray:Array=null, $heightArray:Array=null, $transparent:Boolean=true, $direction:String='horizontal', $length:int=-1)
	{
		_bmd = $bmd;
		_widths = $widthArray;
		_heights = $heightArray;
		_transparent = $transparent;
		_direction = $direction;
		_length = $length;
		if(_bmd && _widths && _height)
			slice();
	}
	
	private var _widths:Array;
	private var _heights:Array;
	
	public function set widths($widths:Array):void
	{
		_widths = $widths;
	}
	
	public function set heights($heights:Array):void
	{
		_heights = $heights;
	}
	
	/**
	 * @inheritDoc 
	 */	
	override public function slice():void
	{
		checkReference();
		//如果提供的切片个数大于_widths数组提供的元素个数，就以_widths的元素个数为准
		if(_length <= 0 || _length > _widths.length)
			_length = _widths.length;
		//根据长度建立一个固定长度的数组
		_bmdList = new Vector.<BitmapData>(_length, true);
		var __pt:Point = new Point(0, 0);
		var __x:Vector.<int> = new Vector.<int>(_length, true);
		var __y:Vector.<int> = new Vector.<int>(_length, true);
		//按照元素的个数，计算每个位图元素在整个位图中的坐标
		for(var j:int=0; j<_length; j++)
		{
			var __xValue:int = 0;
			var __yValue:int = 0;
			//第一个位图的坐标为0,0
			if(j > 0)
			{
				//后面的位图的坐标为前面的位图的高度或者宽度相加
				for(var k:int=0; k<j; k++)
				{
					__xValue += _widths[k];
					__yValue += _heights[k];
				}
			}
			__x[j] = __xValue;
			__y[j] = __yValue;
		}
		//新建一个BitmapData
		for(var i:int=0; i<_length; i++)
		{
			var __width:int = _widths[i];
			var __height:int = _heights[i];
			var __rect:Rectangle = new Rectangle(0, 0, __width,__height);
			var __newBmd:BitmapData = new BitmapData(__width, __height, _transparent);
			if(_direction == HORIZONTAL)
				__rect.x= __x[i];
			else
				__rect.y = __y[i];
			__newBmd.copyPixels(_bmd, __rect, __pt);
			_bmdList[i] = __newBmd;
		}
	}
	
	private function checkReference():void
	{
		if(!_bmd)
			throw new ReferenceError(BMPSlicer.ERROR_MSG_BITMAPDATA);
		if(_widths == null)
			throw new ReferenceError(BMPSlicer.ERROR_MSG_WIDTH);
		else
			if(_widths.length == 0)
				throw new ReferenceError(BMPSlicer.ERROR_MSG_WIDTH);
		if(_heights == null)
			throw new ReferenceError(BMPSlicer.ERROR_MSG_HEIGHT);
		else
			if(_heights.length == 0)
				throw new ReferenceError(BMPSlicer.ERROR_MSG_HEIGHT);
		if(_widths.length != _heights.length)
			throw new ReferenceError('提供的宽度和长度数组的元素个数必须相等！');
	}
}
}