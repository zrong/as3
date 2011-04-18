////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-11
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.spritesheet
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

import org.zengrong.utils.Vec2D;

/**
 * 基于位图引擎的Sprite
 * @author zrong
 */
public class BMPSprite
{
	public function BMPSprite($bmds:Vector.<BitmapData>=null)
	{
		_point = new Point(0, 0);
		if($bmds)
			_bmds = $bmds;
		else
			_bmds = new Vector.<BitmapData>;
	}
	
	/**
	 * 当前处于显示状态中的BitmapData 
	 */	
	public var bitmapData:BitmapData;
	
	/**
	 * Sprite的名称
	 */	
	public var name:String;
	
	public var x:Number = 0;
	
	public var y:Number = 0;
	
	/**
	 * 是否重复播放，如果为真，那么当播放到最后一帧的时候，会跳转到第一帧。否则就会停止在最后帧
	 */	
	public var isRepeat:Boolean = false;
	
	/**
	 * 当前播放到第几帧（0基）
	 */	
	protected var _curFrame:int = 0;
	
	protected var _point:Point;
	
	protected var _bmds:Vector.<BitmapData>;
	
	//----------------------------------
	//  getter/setter
	//----------------------------------
	public function get rect():Rectangle
	{
		return bitmapData.rect;
	}
	
	public function get point():Point
	{
		_point.x = x;
		_point.y = y;
		return _point;
	}
	
	public function get width():int
	{
		return bitmapData.width;
	}
	
	public function get height():int
	{
		return bitmapData.height;
	}
	
	public function get currentFrame():int
	{
		return _curFrame;
	}
	
	public function get totalFrames():int
	{
		return _bmds.length;
	}
	
	//----------------------------------
	//  公开方法
	//----------------------------------
	public function destroy():void
	{
		if(bitmapData)
			bitmapData.dispose();
		name = null;
		x = y = 0;
		isRepeat = false;
		_curFrame = 0;
		_point = new Point(0,0);
		for(var i:int=_bmds.length-1; i>=0; i--)
			_bmds[i].dispose();
		_bmds = new Vector.<BitmapData>;
	}
	
	public function addFrame($bmd:BitmapData):void
	{
		_curFrame = _bmds.length;
		_bmds[_bmds.length] = $bmd;
		bitmapData = $bmd;
	}
	/**
	 * 更新自己的位置
	 */		
	public function update($stage:BitmapData, $delay:Number=0) : void
	{
		$stage.copyPixels(bitmapData, rect, point, null, null, true);	
	}
	
	/**
	 * 向后移动一帧，并返回新帧
	 * @return 
	 */	
	public function next():BitmapData
	{
		if(++_curFrame >= _bmds.length)
		{
			_curFrame = isRepeat ? 0 : _bmds.length - 1;
		}
		bitmapData = _bmds[_curFrame];
		return bitmapData;
	}
	
	/**
	 * 跳转到指定的帧，并返回该帧
	 * @param $frame 帧编号，0基
	 */	
	public function goto($frame:int):BitmapData
	{
		if($frame >= _bmds.length)
			_curFrame = isRepeat ? 0 : _bmds.length - -1;
		else
			_curFrame = $frame;
		bitmapData = _bmds[_curFrame];
		return bitmapData; 
	}
}
}