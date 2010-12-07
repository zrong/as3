////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-12-07
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 用于将一行宽度相同的连续位图按照固定的宽度和高度切成单独的块。
 * 例如：要使用0-9的数字图片，一个个载入比较浪费，可以将0-9拼在一张长条形的图片中，然后使用BMPSlicer来切割。
 * @author zrong
 * 
 */
public class BMPSlicer
{
	/**
	 * @param $bmd 要切割的BitmapData
	 * @param $width 切片的宽度
	 * @param $height 切片的高度
	 * @param $transparent 切片是否透明
	 * @param $length 切片的数量
	 */	
	public function BMPSlicer($bmd:BitmapData=null, $width:int=-1, $height:int=-1, $transparent:Boolean=true, $length:int=-1)
	{
		_bmd = $bmd;
		_width = $width;
		_height = $height;
		_transparent = $transparent;
		_length = $length;
		if(_bmd && (_width>0) && (_height>0))
			slice();
	}
	
	//--------------------------------------------------------------------------
	//
	//  实例变量
	//
	//--------------------------------------------------------------------------	
	private var _bmd:BitmapData;
	private var _width:int;
	private var _height:int;
	private var _length:int;
	private var _transparent:Boolean;
	
	//--------------------------------------------------------------------------
	//
	//  getter方法
	//
	//--------------------------------------------------------------------------	
	/**
	 * 保存切割好的BitmapData 
	 */	
	private var _bmdList:Vector.<BitmapData>;
	
	/**
	 * 返回切割好的BitmapData
	 * @throw ReferenceError 如果没有执行过slice方法，就会抛出此异常。
	 * @see #slice()
	 */	
	public function get slicedBitmapDataList():Vector.<BitmapData>
	{
		if(!_bmdList)
			throw new ReferenceError('切片列表还没有定义！请先执行BMPSlicer.slice方法。');
		return _bmdList;
	}
	
	/**
	 * 根据索引返回要被切成片的BitmapData 
	 * @param $index 切片在切片列表中的索引，从0开始
	 */	
	public function getSlice($index:int):BitmapData
	{
		return _bmdList[$index];
	}

	/**
	 * 根据索引返回被切成片的位图数据，并包装成Bitmap显示对象 
	 * @param $index 切片在切片列表中的索引，从0开始
	 */	
	public function getSlicedBMP($index:int):Bitmap
	{
		return new Bitmap(getSlice($index));
	}
	
	//--------------------------------------------------------------------------
	//
	//  setter方法
	//
	//--------------------------------------------------------------------------
	
	public function set bitmapData($bmd:BitmapData):void
	{
		_bmd = $bmd;
	}
	
	public function set width($width:int):void
	{
		_width = $width;
	}
	
	public function set height($height:int):void
	{
		_height = $height;
	}
	
	public function set transparent($transparent:Boolean):void
	{
		_transparent = $transparent;
	}
	
	public function set length($length:int):void
	{
		_length = $length;
	}
	
	//--------------------------------------------------------------------------
	//
	//  方法
	//
	//--------------------------------------------------------------------------
	/**
	 * 执行切片动作 
	 * @throw ReferenceError 如果必要的属性没有定义，就会抛出异常。
	 */	
	public function slice():void
	{
		if(!_bmd)
			throw new ReferenceError('请先提供要切割的BitmapData。');
		if(_width < 0)
			throw new ReferenceError('请先定义切片的宽度。');
		if(_height < 0)
			throw new ReferenceError('请先定义切片的高度。');
		//如果没有传递$length值，就根据位图的宽度计算
		if(_length < 0)
			_length = int(_bmd.width / _width);
		//根据长度建立一个固定长度的数组
		_bmdList = new Vector.<BitmapData>(_length, true);
		var __rect:Rectangle = new Rectangle(0, 0, _width, _height);
		var __pt:Point = new Point(0, 0);
		//新建一个BitmapData
		for(var i:int=0; i<_length; i++)
		{
			var __newBmd:BitmapData = new BitmapData(_width, _height, _transparent);
			__rect.x= i * _width;
			__newBmd.copyPixels(_bmd, __rect, __pt);
			_bmdList[i] = __newBmd;
		}
	}
}
}