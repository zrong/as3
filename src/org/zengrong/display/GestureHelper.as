package org.zengrong.display
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.utils.getTimer;

import org.zengrong.events.TouchAndGestureEvent;

/**
 * @eventType org.zengrong.events.TouchAndGestureEvent.TOUCH_MOVE
 */
[Event(name="touchMove", type="org.zengrong.events.TouchAndGestureEvent")]

/**
 * @eventType org.zengrong.events.TouchAndGestureEvent.GESTURE_THROW
 */
[Event(name="gestureThrow", type="org.zengrong.events.TouchAndGestureEvent")]

/**
 * 与GESTURE_CHECK_STOP的区别在于，前者每次执行stopCheck的时候都会发出。
 * 而这个事件仅在离开触摸的时候才会发出。
 * 也就是说TOUCH_LEAVE发出的机会比GESTURE_CHECK_STOP要少
 * @eventType org.zengrong.events.TouchAndGestureEvent.TOUCH_LEAVE
 */
[Event(name="touchLeave", type="org.zengrong.events.TouchAndGestureEvent")]

/**
 * @eventType org.zengrong.events.TouchAndGestureEvent.GESTURE_CHECK_STOP
 */
[Event(name="gestureCheckStop", type="org.zengrong.events.TouchAndGestureEvent")]

/**
 * @eventType org.zengrong.events.TouchAndGestureEvent.GESTURE_CHECK_STARTING
 */
[Event(name="gestureCheckStarting", type="org.zengrong.events.TouchAndGestureEvent")]

/**
 * @eventType org.zengrong.events.TouchAndGestureEvent.GESTURE_CHECK_START
 */
[Event(name="gestureCheckStart", type="org.zengrong.events.TouchAndGestureEvent")]

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
		initEventHandler();
	}
	
	public static const DIRECTION_VERTICAL:String = 'vertical';
	
	public static const DIRECTION_HORIZONTAL:String = 'horizontal';
	
	public static const DIRECTION_ANY:String = 'any';
	
	private var _handlerList:Object;
	
	/**
	 * 检测方向，默认为全向检测
	 */	
	public var direction:String = 'any';
	
	/**
	 * 移动误差值
	 * 当按下位置超过了移动误差值，才开始计算速度
	 * 这是为了允许玩家在按钮上按下并停留一段时间，然后再做手势
	 */
	public var moveRange:int = 0;
	
	/**
	 * 大于这个速率，就认为是手势
	 * 单位是像素/秒
	 */
	public var velocity:int = 1000;
	
	private var _target:DisplayObject;
	
	/**
	 * 保存开始移动时候的时间，用这个时间来判断在用户结束按钮响应的时候，是否应该停止检测鼠标手势
	 */
	private var _startTime:int;
	
	/**
	 * 如果检测手势的条件满足，这个值为true
	 */
	private var _isGesture:Boolean;
	
	/**
	 * 记录开始移动的时候的舞台鼠标坐标
	 */
	private var _startStageMouseX:int = 0;
	private var _startStageMouseY:int = 0;

	private var _startMouseY:int = 0;
	
	/**
	 * 保存开始移动的时候的鼠标位置，这个位置用于检测鼠标手势的起点
	 */
	public function get startMouseY():int
	{
		return _startMouseY;
	}

	
	private var _startMouseX:int = 0;

	public function get startMouseX():int
	{
		return _startMouseX;
	}

	public function get targetMouseX():int
	{
		return _target.mouseX;
	}
	
	public function get targetMouseY():int
	{
		return _target.mouseY;
	}
	
	public function get stageMouseX():int
	{
		return _target.stage.mouseX;
	}
	
	public function get stageMouseY():int
	{
		return _target.stage.mouseY;
	}
	
	private function initEventHandler():void
	{
		_handlerList = {};
		_handlerList[Event.ENTER_FRAME] = handler_enterFrame;
		_handlerList[MouseEvent.MOUSE_UP] = handler_tapLeave;
		_handlerList[MouseEvent.MOUSE_MOVE] = handler_tapMove;
	}
	
	private function addEvent($type:String):void
	{
		//trace('addEvent:', $type);
		var __handler:Function = _handlerList[$type] as Function;
		if(__handler is Function)
		{
			if(_target.stage && ($type == MouseEvent.MOUSE_UP || $type == MouseEvent.MOUSE_MOVE))
			{
				//trace('开始检测手势松开');
				_target.stage.addEventListener($type, __handler);
			}
			else
				_target.addEventListener($type, __handler);
		}
	}
	
	private function removeEvent($type:String):void
	{
		//trace('removeEvent:', $type);
		var __handler:Function = _handlerList[$type] as Function;
		if(__handler is Function)
		{
			if(_target.stage && ($type == MouseEvent.MOUSE_UP || $type == MouseEvent.MOUSE_MOVE))
			{
				//trace('取消检测手势松开');
				_target.stage.removeEventListener($type, __handler);
			}
			else
				_target.removeEventListener($type, __handler);
		}
	}
	/**
	 * 开始检测移动主菜单的手势
	 */
	public function startCheck():void
	{
		//开始检测前，先停止检测
		stopCheck();
		//trace('准备检测手势');
		_startMouseX = targetMouseX;
		_startMouseY = targetMouseY;
		
		_startStageMouseX = stageMouseX;
		_startStageMouseY = stageMouseY;
		
		_startTime = getTimer();
		_isGesture = false;
		addEvent(MouseEvent.MOUSE_UP);
		addEvent(MouseEvent.MOUSE_MOVE);
		//检测玩家开始做手势的时间
		addEvent(Event.ENTER_FRAME);
		this.dispatchEvent(new TouchAndGestureEvent(TouchAndGestureEvent.GESTURE_CHECK_STARTING, _startMouseX, _startMouseY));
	}
	
	/**
	 * 停止检测移动主菜单的手势
	 */
	public function stopCheck():void
	{
		//trace('停止检测手势');
		removeEvent(MouseEvent.MOUSE_UP);
		removeEvent(MouseEvent.MOUSE_MOVE);
		removeEvent(Event.ENTER_FRAME);
		//如果当前执行过startCheck才需要发送checkStop事件
		if(_isGesture)
			this.dispatchEvent(new TouchAndGestureEvent(TouchAndGestureEvent.GESTURE_CHECK_STOP, _target.mouseX, _target.mouseY));
		_isGesture = false;
	}
	
	public function checking():void
	{
		//trace('checking.....:', _isGesture);
		if(_isGesture)
		{
			//移动的时间
			var __moveTime:Number = (getTimer()-_startTime)/1000;
			//纵向每秒速度
			var __velocityY:Number = (stageMouseY-_startStageMouseY)/__moveTime;
			//横向每秒速度
			var __velocityX:Number = (stageMouseX-_startStageMouseX)/__moveTime;
			//trace('纵向移动时间：', __moveTime, ',速率：', __velocityY);
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
		var __move:int = 0;
		//横向手势计算X值
		if(direction == DIRECTION_HORIZONTAL)
			__move = stageMouseX-_startStageMouseX;
		//纵向手势计算Y值
		else if(direction == DIRECTION_VERTICAL)
			__move = stageMouseY-_startStageMouseY;
		//任意方向，就计算横向和纵向较大的那一个值
		else
		{
			__move = Math.max(Math.abs(stageMouseX-_startStageMouseX), Math.abs(stageMouseY-_startStageMouseY));
		}
		//trace("------------------move:", __move);
		if(Math.abs(__move) > moveRange)
		{
//			trace('移动的距离：', __move);
//			trace('检测到手势开始,是否在检测鼠标松开：', _target.stage.hasEventListener(MouseEvent.MOUSE_UP));
			//取消侦测玩家开始做手势的时间
			removeEvent(Event.ENTER_FRAME);
			addEvent(MouseEvent.MOUSE_UP);
			//更新开始做手势的时间
			_startTime = getTimer();
			_isGesture = true;
			//发布开始做手势的时间
			this.dispatchEvent(new TouchAndGestureEvent(TouchAndGestureEvent.GESTURE_CHECK_START, targetMouseX, targetMouseY));
		}
	}
	
	private function handler_tapLeave($evt:MouseEvent):void
	{
		//trace('鼠标松开');
		checking();
		stopCheck();
		this.dispatchEvent(new TouchAndGestureEvent(TouchAndGestureEvent.TOUCH_LEAVE, targetMouseX, targetMouseY));
	}
	
	/**
	 * 触摸移动的时候发送
	 */
	private function handler_tapMove($evt:MouseEvent):void
	{
		this.dispatchEvent(new TouchAndGestureEvent(TouchAndGestureEvent.TOUCH_MOVE, targetMouseX, targetMouseY));
	}
	
	public function destroy():void
	{
		stopCheck();
		_target = null;
	}
}
}