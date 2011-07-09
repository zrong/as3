////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-11
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.spritesheet
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 基于位图引擎的Sprite
 * @author zrong
 */
public class BMPSprite
{
	public function BMPSprite($bmds:Vector.<BitmapData>=null, $hasFlip:Boolean=false, $autoCenterOffset:Boolean=false)
	{
		_hasFlip = $hasFlip;
		_bmds = $bmds;
		isAutoCenterOffset = $autoCenterOffset;
		init();
	}
	
	/**
	 * 当前处于显示状态中的BitmapData 
	 */	
	public var bitmapData:BitmapData;
	
	/**
	 * 图像列表
	 */
	protected var _bmds:Vector.<BitmapData>;

	/**
	 * 翻转的图像列表
	 */
	protected var _flipBmds:Vector.<BitmapData>;

	/**
	 * Sprite的名称
	 */	
	public var name:String;
	
	public var x:int = 0;
	
	public var y:int= 0;
	
	/**
	 * 是否重复播放，如果为真，那么当播放到最后一帧的时候，会跳转到第一帧。否则就会停止在最后帧
	 */	
	public var isRepeat:Boolean = false;

	/**
	 * 是否自动计算中心点offset，如果不自动计算，就始终以左上角为中心点
	 */
	public var isAutoCenterOffset:Boolean = false;

	/**
	 * 自动计算中心点的x系数，即如何计算中心点的x偏移，默认是位图的宽度的-0.5倍
	 */
	public var xOffsetFactor:Number = -0.5;
	
	/**
	 * 自动计算中心点的x系数，即如何计算中心点的x偏移，默认是位图的高度的-0.5倍
	 */
	public var yOffsetFactor:Number = -0.5;

	/**
	 * 当前播放到第几帧（0基）
	 */	
	protected var _curFrame:int = 0;
	
	/**
	 * 对应当前对象的坐标点
	 */
	protected var _point:Point;

	/**
	 * 对应当前对象的中心点
	 */
	protected var _centerOffset:Point;

	/**
	 * 当前Sprite是否包含翻转
	 */
	protected var _hasFlip:Boolean;

	/**
	 * 当前是否是翻转状态
	 */
	protected var _flip:Boolean;

	//----------------------------------------
	// init
	//----------------------------------------

	public function init():void
	{
		_point = new Point(x, y);
		_centerOffset = new Point(0,0);
		if(_bmds) 
		{
			bitmapData = getFrame( 0 );
			//如果包含翻转，则根据现有的像素计算翻转像素
			if(_hasFlip)
				reFlip();
		}
		else
		{
			_bmds = new Vector.<BitmapData>;
			if(_hasFlip)
				_flipBmds = new Vector.<BitmapData>;
		}
	}

	//----------------------------------
	//  getter/setter
	//----------------------------------
	public function get rect():Rectangle
	{
		return bitmapData.rect;
	}

	/**
	 * 获取当前对象的定位点
	 */
	public function get point():Point
	{
		_point.x = x;
		_point.y = y;
		//若自动计算偏移，则加上偏移值
		if( isAutoCenterOffset )
		{
			_point.x = int(_point.x + _centerOffset.x);
			_point.y = int(_point.y + _centerOffset.y);
		}
		return _point;
	}

	public function get centerOffset():Point
	{
		return _centerOffset;
	}	

	/**
	 * 设置中心点的偏移位置，对象的位置使用x和y的位置加上便宜位置。
	 * @param $xOffset x偏移，如果值为NaN，则使用当前位图的宽度的-0.5倍
	 * @param $yOffset y偏移，如果值为NaN，则使用当前位图的高度的-0.5倍
	 */
	public function setCenterOffset( $xOffset:Number=NaN, $yOffset:Number=NaN ):void
	{
		if( isNaN( $xOffset) )
			$xOffset = bitmapData.width*xOffsetFactor;
		if( isNaN( $yOffset ) )
			$yOffset = bitmapData.height*yOffsetFactor;
		_centerOffset.x = int($xOffset);
		_centerOffset.y = int($yOffset);
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

	/**
	 * 当前的Sprite是否包含翻转的像素列表
	 */
	public function get hasFlip():Boolean
	{
		return _hasFlip; 
	}

	/**
	 * 获取Sprite的反转状态
	 */
	public function get flip():Boolean
	{
		return _flip;
	}

	/**
	 * 设置sprite的翻转状态，如果当前没有设置过翻转，就从原始状态中绘制翻转。
	 */
	public function set flip($flip:Boolean):void
	{
		if(!hasFlip)
			throw new RangeError('不支持Flip！');
		_flip = $flip;
		//flip后，更新中点位置。由于这时bitmapData可能不是最新的，而现在也不应该更新bitmapData，否则会导致显示错误
		//因此这里直接计算最新的bitmapData的长宽偏移值
		var __bmd:BitmapData = getFrame( 0 );
		setCenterOffset( __bmd.width*xOffsetFactor, __bmd.height*yOffsetFactor );
	}

	/**
	 * 获取帧的位图
	 */
	public function getFrame( $index:int ):BitmapData
	{
		return (_flip ? _flipBmds : _bmds)[$index];
	}

	
	//----------------------------------
	//  公开方法
	//----------------------------------
	/**
	 * 向对象中增加一帧
	 */
	public function addFrame($bmd:BitmapData):void 
	{
		if(!_bmds) _bmds = new Vector.<BitmapData>;
		_curFrame = _bmds.length;
		_bmds[_bmds.length] = $bmd;
		if(hasFlip)
			_flipBmds[_bmds.length] = getFlipBMD($bmd);
		bitmapData = getFrame(_curFrame);
		//更新中心偏移值
		setCenterOffset(  );
	}
	
	/**
	 * 移除所有帧
	 */
	public function removeAllFrame():void
	{
		while(_bmds && _bmds.length>0)
			_bmds.pop().dispose();
	}

	public function reFlip():void
	{
		if(_bmds && _bmds.length>0)
		{
			//如果翻转像素已经存在，就销毁它
			if(_flipBmds)
			{
				while(_flipBmds.length > 0)
					_flipBmds.pop().dispose();
			}
			_flipBmds = new Vector.<BitmapData>;
			var __flipBmd:BitmapData = null;
			var __matrix:Matrix = null;
			//执行翻转
			for(var i:int=0;i<_bmds.length;i++)
			{
				_flipBmds[i] = getFlipBMD(_bmds[i]);
			}
		}
		else
		{
			throw new ReferenceError('没有图像资料，无法进行翻转！');
		}
	}

	public function destroy():void
	{
		if(bitmapData)
			bitmapData.dispose();
		bitmapData = null;
		name = null;
		x = y = 0;
		isRepeat = false;
		_hasFlip = false;
		_flip = false;
		_curFrame = 0;
		_point = null;
		var __bmd:BitmapData = null;
		if(_bmds && _bmds.length>0)
		{
			for each(__bmd in _bmds)
			{
				__bmd.dispose();
			}
		}
		_bmds = null;
		if(_flipBmds && _flipBmds.length>0)
		{
			for each(__bmd in _flipBmds)
			{
				__bmd.dispose();
			}
		}
		_flipBmds = null;
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
		bitmapData = getFrame(_curFrame);
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
		bitmapData = getFrame(_curFrame);
		return bitmapData; 
	}

	private function getFlipBMD($bmd:BitmapData):BitmapData
	{
		var __matrix:Matrix = new Matrix(-1,0,0,1, $bmd.width, 0);
		var __flipBmd:BitmapData = new BitmapData($bmd.width, $bmd.height, $bmd.transparent, 0x00000000);
		__flipBmd.draw($bmd, __matrix, null, null, null, true);
		return __flipBmd;
	}
}
}
