package org.zengrong.display
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.utils.getTimer;

import org.zengrong.events.TouchAndGestureEvent;


/**
 * @eventType org.zengrong.events.TouchAndGestureEvent.GESTURE_THROW
 */
[Event(name="gestureThrow", type="org.zengrong.events.TouchAndGestureEvent")]

/**
 * 帮助计算鼠标手势，因为FlashPlayer自带的GenstureEvent在使用上不够灵活，无法满足变态的前端需求
 * @author zrong
 * 创建日期：2012-04-21
 */
public class GestureHelper extends EventDispatcher
{
	public function GestureHelper($target:DisplayObject)
	{
		super();
		_target = $target;
	}
	
	public static const DIRECTION_VERTICAL:String = 'vertical';
	
	public static const DIRECTION_HORIZONTAL:String = 'horizontal';
	
	public static const DIRECTION_ANY:String = 'any';
	
	/**
	 * 移动误差值
	 * 当按下位置超过了移动误差值，才开始计算速度
	 * 这是为了允许玩家在按钮上按下并停留一段时间，然后再做手势
	 */
	public var moveRange:uint = 0;
	
	/**
	 * 大于这个速率，就认为是手势
	 * 单位是像素/秒
	 */
	public var velocity:uint = 1000;
	
	private var _target:DisplayObject;
	
	/**
	 * 保存开始移动时候的时间，用这个时间来判断在用户结束按钮响应的时候，是否应该停止检测鼠标手势
	 */
	private var _startTime:uint;
	
	/**
	 * 如果检测手势的条件满足，这个值为true
	 */
	private var _isGesture:Boolean;
	
	/**
	 * 保存开始移动的时候的鼠标位置，这个位置用于检测鼠标手势的起点
	 */
	private var _startMouseY:int = 0;
	
	private var _startMouseX:int = 0;
	
	/**
	 * 检测方向，默认为全向检测
	 */	
	public var direction:String = 'any';
	
	/**
	 * 开始检测移动主菜单的手势
	 */
	public function startCheck():void
	{
		//开始检测前，先停止检测
		stopCheck();
		trace('准备检测手势');
		_startMouseX = _target.mouseX;
		_startMouseY = _target.mouseY;
		_startTime = getTimer();
		_isGesture = false;
		addMouseUp();
		//检测玩家开始做手势的时间
		addEnterFrame();
	}
	
	/**
	 * 停止检测移动主菜单的手势
	 */
	public function stopCheck():void
	{
		trace('停止检测手势');
		removeMouseUp();
		removeEnterFrame();
		_isGesture = false;
	}
	
	public function checking():void
	{
		trace('checking.....:', _isGesture);
		if(_isGesture)
		{
			//移动的时间
			var __moveTime:Number = (getTimer()-_startTime)/1000;
			//纵向每秒速度
			var __velocityY:Number = (_target.mouseY-_startMouseY)/__moveTime;
			//横向每秒速度
			var __velocityX:Number = (_target.mouseX-_startMouseX)/__moveTime;
			trace('纵向移动时间：', __moveTime, ',速率：', __velocityY);
			var __evt:TouchAndGestureEvent = new TouchAndGestureEvent(TouchAndGestureEvent.GESTURE_THROW);
			//如果移动速率超过设定值，就认为手势发生
			if(direction == DIRECTION_ANY)
			{
				if(Math.abs(__velocityX) > velocity) __evt.velX = __velocityX;
				if(Math.abs(__velocityY) > velocity) __evt.velY = __velocityY;
			}
			else if(direction == DIRECTION_HORIZONTAL)
			{
				if(Math.abs(__velocityX) > velocity) __evt.velX = __velocityX;
				else return;
			}
			else
			{
				if(Math.abs(__velocityY) > velocity) __evt.velY = __velocityY;
			}
			//如果横向和纵向的变化都没有设置，就不处理
			if(isNaN(__evt.velX) && isNaN(__evt.velY)) return;
			this.dispatchEvent(__evt);
		}
	}
	
	private function handler_enterFrame($evt:Event):void
	{
		//trace(_target.mouseY-_startMouseY);
		//当按下位置超过了移动误差值，才开始计算速度
		//这是为了允许玩家在按钮上按下并停留一段时间，然后再做手势
		var __move:int = _target.mouseY-_startMouseY;
		if(direction == DIRECTION_HORIZONTAL)
			__move = _target.mouseX-_startMouseX;
		if(Math.abs(__move) > moveRange)
		{
			trace('移动的距离：', __move);
			trace('检测到手势开始,是否在检测鼠标松开：', _target.stage.hasEventListener(MouseEvent.MOUSE_UP));
			//取消侦测玩家开始做手势的时间
			removeEnterFrame();
			addMouseUp();
			//更新开始做手势的时间
			_startTime = getTimer();
			_isGesture = true;
		}
	}
	
	private function handler_tapLeave($evt:MouseEvent):void
	{
		trace('鼠标松开');
		checking();
		stopCheck();
	}
	
	private function addMouseUp():void
	{
		trace('开始检测手势松开');
		if(_target.stage) _target.stage.addEventListener(MouseEvent.MOUSE_UP, handler_tapLeave);
	}
	
	private function removeMouseUp():void
	{
		trace('取消检测手势松开');
		if(_target.stage) _target.stage.removeEventListener(MouseEvent.MOUSE_UP, handler_tapLeave);
	}
	
	private function addEnterFrame():void
	{
		_target.addEventListener(Event.ENTER_FRAME, handler_enterFrame);
	}
	
	private function removeEnterFrame():void
	{
		_target.removeEventListener(Event.ENTER_FRAME, handler_enterFrame);
	}
	
	public function destroy():void
	{
		stopCheck();
		_target = null;
	}
	
}
}