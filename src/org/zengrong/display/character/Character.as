////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2011-08-03
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.character
{
import com.youxi.text.FTEFactory;

import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.text.engine.TextLine;

/**
 * 所有的角色形象的基类，提供以下功能：
 * 帧动画功能以及帧频控制
 * 超出屏幕范围自动隐藏
 * 翻转功能
 * 显示title
 * 居中功能
 * 自动Z索引
 */
public class Character extends Sprite 
{

	public function Character($bmds:Vector.<BitmapData>=null)
	{
		this.mouseChildren = false;
		this.mouseEnabled = false;
		_bmds = $bmds;
		init();
	}

	//----------------------------------------
	// public变量
	//----------------------------------------
	/**
	 * 角色的z轴值，因为z已经被Sprite使用，因此采用wz
	 */
	public var wz:int;

	/**
	 * 角色的形象，是主文件名字符串
	 */
	public var img:String;

	/**
	 * 角色的类型
	 */
	public var type:String;

	/**
	 * 单击角色的时候要执行的动作，可能是任何类型
	 */
	public var fun:Object;

	/**
	 * 是否自动计算z的值。如果为false，就使用固定的z值
	 */
	public var isAutoZ:Boolean;

	/**
	 * 是否在超过屏幕范围的时候自动隐藏
	 */
	public var isAutoHide:Boolean = true;

	/**
	 * 屏幕范围
	 */
	public var osdLimit:Rectangle;

	/**
	 * 是否重复播放，如果为真，那么当播放到最后一帧的时候，会跳转到第一帧。否则就会停止在最后帧
	 */	
	public var isRepeat:Boolean = false;

	//----------------------------------------
	// protected变量
	//----------------------------------------
	
	/**
	 * 是否已经初始化
	 */
	protected var _init:Boolean = false;

	/**
	 * 图像列表
	 */
	protected var _bmds:Vector.<BitmapData>;

	/**
	 * 用以显示图像的位图
	 */
	protected var _bmp:Bitmap;

	/**
	 * 用以显示玩家名称
	 */
	protected var _titleTL:TextLine;

	/**
	 * 用来保存玩家的名称
	 */
	protected var _title:String;

	/**
	 * 当前是否是翻转状态
	 */
	protected var _flip:Boolean;

	/**
	 * 用户翻转之后计算xy的偏移
	 */
	protected var _flipMatrix:Matrix;

	/**
	 * 当前是否为帧停止状态，值为true的时候不更新帧动画
	 */
	protected var _stop:Boolean;

	/**
	 * 当前播放到第几帧（0基）
	 */	
	protected var _curFrame:int = 0;

	/**
	 * 播放的帧率，根据这个值计算多长时间应该切换一次帧
	 */
	private var _frameRate:int = 8;

	/**
	 * 根据frameRate计算换帧的时间间隔，单位秒。默认frameRate是8，因此这个值默认是1/8
	 */
	protected var _delay:Number = .125;

	/**
	 * 记录上一次切换帧的时间，根据时间间隔计算这次更新是否应该换帧，单位秒
	 */
	protected var _lastChangeFrame:Number = 0;

	//----------------------------------------
	// init
	//----------------------------------------

	protected function init():void
	{
		_init = true;
		_flipMatrix = new Matrix(-1,0,0,1);
		_bmp = new Bitmap();
		this.addChild(_bmp);
		if(_bmds) 
		{
			goto(0);
		}
		else
		{
			_bmds = new Vector.<BitmapData>;
		}
	}

	public function destroy():void
	{
		_init = false;
		this.removeChild(_bmp);
		_bmp = null;
		_bmds = null;
		_lastChangeFrame = 0;
		_curFrame = 0;
		wz = 0;
		frameRate = 10;
		isAutoZ = false;
		osdLimit = null;
		type = null;
	}

	//----------------------------------
	//  getter/setter
	//----------------------------------

	public function get isInit():Boolean
	{
		return _init;
	}

	/**
	 * 当前是否正在播放帧动画
	 */
	public function get isPlaying():Boolean
	{
		return !_stop;
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
		if(_flip == $flip)
			return;
		_flip = $flip;
		_bmp.scaleX = _flip ? -1 : 1;
		_bmp.x = _flip ? (.5 * _bmp.width) : (-.5*_bmp.width);
		//trace(this.name ,_title, '设置翻转, _flip:', _flip, ',bmp.x:', _bmp.x, ',bmp.w:', _bmp.width);
		moveTitle();
	}

	public function get frameRate():int
	{
		return _frameRate;
	}

	public function set frameRate($rate:int):void
	{
		_frameRate = $rate;
		_delay = 1/_frameRate;
	}

	public function get currentFrame():int
	{
		return _curFrame;
	}
	
	public function get totalFrames():int
	{
		return _bmds.length;
	}

	public function get title():String
	{
		return _title;
	}

	public function set title($title:String):void
	{
		_title = $title;
		if(_titleTL && this.contains(_titleTL))
		{
			this.removeChild(_titleTL);
			_titleTL = null;
		}
		_titleTL = FTEFactory.createSingleTextLine(_title, 1000);
		if(_titleTL)
		{
			moveTitle();
			this.addChild(_titleTL);
		}
	}

	/**
	 * 获取帧的位图
	 */
	public function getFrame($index:int):BitmapData
	{
		return _bmds[$index];
	}

	//----------------------------------
	//  公开方法
	//----------------------------------
	public function update($elapsed:Number, $delay:Number):void
	{
		if(!isInit) return;
		updateFrame($elapsed);
		hideOnOverEdge();
		//自动计算z值，z值其实是y值
		if(isAutoZ)
			this.wz = this.y;
	}

	public function updateFrame($elapsed:Number):void
	{
		//如果过去的时间大于帧间隔，且当前处于播放状态，就切换帧
		if(($elapsed - _lastChangeFrame >= _delay) && !_stop && _bmds)
		{
			//trace('Character.update:', $elapsed, _lastChangeFrame);
			next();
			_lastChangeFrame = $elapsed;
		}
	}

	/**
	 * 设置对象中的所有帧
	 */
	public function setFrames($bmds:Vector.<BitmapData>):void
	{
		_bmds = $bmds;
		goto(0);
	}

	/**
	 * 向对象中增加一帧
	 */
	public function addFrame($bmd:BitmapData):void 
	{
		_curFrame = _bmds.length;
		_bmds[_bmds.length] = $bmd;
		_bmp.bitmapData = getFrame(_bmds.length-1);
	}
	
	/**
	 * 移除所有帧
	 */
	public function removeAllFrame():void
	{
		//_bmds为固定的，说明是从SpriteSheet生成的，这样的_bmds不能销毁，因为其他的角色还需要它
		//固定的就直接新建一个空bmds替换
		if(_bmds.fixed)
		{
			_bmds = new Vector.<BitmapData>;
		}
		else
		{
			while(_bmds.length>0)
				_bmds.pop().dispose();
		}
	}

	/**
	 * 向后移动一帧，并返回新帧
	 * @return 
	 */	
	public function next():BitmapData
	{
		//图像列表不存在或者只有1帧图像，就不必更新帧
		//if(!_bmds || _bmds.length<=1) return;
		if(++_curFrame >= _bmds.length)
		{
			_curFrame = isRepeat ? 0 : _bmds.length - 1;
		}
		_bmp.bitmapData = getFrame(_curFrame);
		return _bmp.bitmapData; 
	}
	
	/**
	 * 跳转到指定的帧，并返回该帧
	 * @param $frame 帧编号，0基
	 */	
	public function goto($frame:int):BitmapData
	{
		if($frame >= _bmds.length)
			_curFrame = isRepeat ? 0 : _bmds.length - 1;
		else
			_curFrame = $frame;
		_bmp.bitmapData = getFrame(_curFrame);
		center();
		return _bmp.bitmapData; 
	}

	/**
	 * 开始播放帧动画
	 */
	public function play():void
	{
		_stop = false;
	}

	/**
	 * 停止播放帧动画，形象将停止在当前帧
	 */
	public function stop():void
	{
		_stop = true;
	}

	/**
	 * 确定角色的中心点位置，默认的位置为底边中点
	 */
	public function center($offsetX:int=0, $offsetY:int=0):void
	{
		_bmp.x = _flip ? (.5*_bmp.width+$offsetX) : (-.5*_bmp.width+$offsetX);
		_bmp.y = _bmp.height*-1+$offsetY;
		//trace('Character.', this.name, _title, ' center:', _bmp.x, _bmp.y, ' width:', _bmp.width, ' bmdWidth:', _bmp.bitmapData.width);
		this.graphics.clear();
		this.graphics.beginFill(0xFF0000);
		this.graphics.drawCircle(0,0,3);
		this.graphics.endFill();
		moveTitle();
	}

	/**
	 * 根据bmp的位置确定title的位置
	 */
	public function moveTitle():void
	{
		if(_titleTL)
		{
			//trace('Character.moveTitle:',_titleTL.width, _titleTL.textBlock.content.text );
			_titleTL.x = (_flip ? -1*_bmp.x : _bmp.x) + (_bmp.width-_titleTL.width)*.5;
			_titleTL.y = _bmp.y-10;
		}
	}

	/**
	 * 测试坐标是否在角色的有效像素范围内
	 */
	public function hitTest($x:int, $y:int):Boolean
	{
		//获取真实的左上角全局坐标
		var __rx:int = this.x+_bmp.x;
		var __ry:int = this.y+_bmp.y;
		//将检测坐标转换成本地坐标
		var __lp:Point = new Point($x - __rx, $y - __ry);
		//翻转状态需要变换坐标，无法使用下面“注释1”的方法计算坐标，因为角色的形象被翻转了，如果采用注释1的方法，计算出的坐标对应的点其实是该位置翻转后的像素
		//TODO 2011-07-19 可以使用display.transform.matrix计算flip，这样在center和flip的时候，就可以不计算bmp宽度的一半
		if(_flip) __lp = _flipMatrix.transformPoint(__lp);
		if(__lp.x>0 && __lp.x<_bmp.width && __lp.y>0 && __lp.y<_bmp.height)
		{	
			var __argb:uint = _bmp.bitmapData.getPixel32(__lp.x, __lp.y);
			return (__argb>>24&0xFF) > 0;
		}
		return false;
		//注释1，旧的错误方法
		//var __rx:int = this.x+_bmp.scaleX*_bmp.x;
		//var __ry:int = this.y+_bmp.y;
		//var __lx:int = $x - __rx;
		//var __ly:int = $y - __ry;
		//this.graphics.clear();
		//this.graphics.lineStyle(0,0xFF0000);
		//this.graphics.drawRect(_bmp.x * _bmp.scaleX, _bmp.y, _bmp.width, _bmp.height);
		//this.graphics.lineStyle(0,0x0000FF);
		//this.graphics.drawCircle(__lx+_bmp.x, __ly+_bmp.y, 5);
		//if(__lx>0 && __lx<_bmp.width && __ly>0 && __ly<_bmp.height)
		//{	
		//	var __rgba:uint = _bmp.bitmapData.getPixel32(__lx, __ly);
		//	return (__rgba>>24&0xFF) > 0;
		//}
	}

	//----------------------------------
	//  公开方法
	//----------------------------------
	/**
	 * 计算角色的世界x位置，如果超出屏幕范围就隐藏自己
	 */
	protected function hideOnOverEdge():void
	{
		//trace('计算超限,wx:', this.wx, 'limit:',osdLimit);
		if(isAutoHide && osdLimit)
			this.visible = !(this.x+this.width*.5 < osdLimit.x || this.x-this.width*.5 > osdLimit.right);
	}

}
}
