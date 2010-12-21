package org.zengrong.controls
{
import flash.display.Bitmap;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.BevelFilter;
import flash.filters.ColorMatrixFilter;
import flash.utils.Timer;

import org.zengrong.utils.ColorMatrix;

/**
 * 用于游戏中的带有冷却功能的按钮，按下后必须经过一段冷却时间才能再次使用。
 * @author zrong
 */
public class CDImageButton extends ImageButton
{
	//计时器的步进
	private static const DELAY:int = 200;
	
	public function CDImageButton(parent:DisplayObjectContainer, upStateImage:Bitmap, coolDownTime:int=5, defaultHandler:Function=null)
	{
		_cdt = coolDownTime;
		super(parent, 0, 0, upStateImage, null, null, defaultHandler);
		init();
	}
	
	private var _timer:Timer;
	private var _cdt:int;	//冷却时间，单位是秒
	private var _delay:int;
	private var _mask:Shape;
	
	//----------------------------------
	//  getter/setter
	//----------------------------------
	/**
	 * 重新设置冷却时间
	 * @param $cdt 冷却时间，单位是秒
	 */	
	public function set coolDownTime($cdt:int):void
	{
		_cdt = $cdt;
		_timer.reset();
		_timer.repeatCount = repeatCount;
	}
	
	/**
	 * 获取动画计时器的重复次数。使用冷却时间与DELAY进行计算。 
	 */	
	public function get repeatCount():int
	{
		return _cdt * (1000/DELAY);
	}
	
	/**
	 * CDImageButton按钮不使用去色效果 
	 */	
	override public function get useColorless():Boolean
	{
		return false;
	}
	
	//----------------------------------
	//  被外部调用的公有方法
	//----------------------------------
	/**
	 * 开始计算冷却时间，禁用按钮，并绘制冷却动画。
	 */	
	public function start():void
	{
		if(_timer.running)
			return;
		_timer.reset();
		enabled = false;
		drawRectMask(_timer.repeatCount, _timer.repeatCount);
		_timer.start();
	}
	
	/**
	 * 停止和重置冷却时间计时器
	 */	
	public function stop():void
	{
		_timer.reset();
	}
	
	//----------------------------------
	//  覆盖父类的方法
	//----------------------------------
	override protected function init():void
	{
		super.init();
		_timer = new Timer(DELAY, repeatCount);
		_timer.addEventListener(TimerEvent.TIMER, handler_timer);
		_timer.addEventListener(TimerEvent.TIMER_COMPLETE, handler_timerComplete);
	}
	
	override protected function addChildren():void
	{
		super.addChildren();
		_mask = new Shape();
		addChild(_mask);
	}
	
	override protected function onMouseGoUp(event:MouseEvent):void
	{
		super.onMouseGoUp(event);
		start();
	}
	
	//----------------------------------
	//  handler
	//----------------------------------
	/**
	 * 绘制冷却动画效果 
	 */	
	private function handler_timer(evt:TimerEvent):void
	{
		drawRectMask(_timer.repeatCount - _timer.currentCount, _timer.repeatCount);
	}
	
	/**
	 * 冷却时间过去，重新启用按钮
	 */	
	private function handler_timerComplete(evt:TimerEvent):void
	{
		enabled = true;
	}
	
	//----------------------------------
	//  内部调用的私有方法
	//----------------------------------
	private function drawRectMask($current:int, $total:int):void
	{
		var __percent:Number = $current/$total;
		_mask.graphics.clear();
		_mask.graphics.beginFill(0x000000, .5);
		_mask.graphics.drawRect(0, 0, width, height*__percent);
		_mask.graphics.endFill();
	}
}
}