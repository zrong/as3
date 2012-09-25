////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong(zrongzrong@gmail.com)
//  创建时间：2012-6-14
//  最后修改：2012-6-14
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.events
{
import flash.events.Event;

/**
 * 实现手势事件
 * @author zrong
 */
public class TouchAndGestureEvent extends Event
{
	/**
	 * 手势事件，实现“抛”动作的侦测
	 * @eventType gestureThrow
	 */
	public static const GESTURE_THROW:String = 'gestureThrow';
	
	/**
	 * 开始检测手势，当按下的时候发送此事件
	 * @eventType gestureCheckStarting
	 */	
	public static const GESTURE_CHECK_STARTING:String = 'gestureCheckStarting';
	
	/**
	 * 开始检测手势，当超过了移动误差值之后发送此事件。此事件一定在GESTURE_STARTING_CHECK之后发送
	 * @eventType gestureCheckStart
	 */	
	public static const GESTURE_CHECK_START:String = "gestureCheckStart";
	
	/**
	 * 停止检测手势
	 * @eventType gestureCheckStop
	 */
	public static const GESTURE_CHECK_STOP:String = 'gestureCheckStop';
	
	/**
	 * 放开触摸的时候发送此事件
	 * @eventType touchLeave
	 */
	public static const TOUCH_LEAVE:String = "touchLeave";
	
	/**
	 * 触摸并移动
	 * @eventType touchMove
	 */
	public static const TOUCH_MOVE:String = 'touchMove';
	
	/**
	 * 移动超限
	 * @eventType beyond
	 */
	public static const BEYOND:String = 'beyond';
	
	public function TouchAndGestureEvent($type:String, $velX:Number=NaN, $velY:Number=NaN, $bubbles:Boolean=false, $cancelable:Boolean=false)
	{
		super($type, $bubbles, $cancelable);
		velX = $velX;
		velY = $velY;
	}
	
	/**
	 * 负数代表向左移动，正数为向右
	 */
	public var velX:Number;
	
	/**
	 * 负数代表向上移动，正数代表向下
	 */
	public var velY:Number;
	
	
	override public function clone():Event
	{
		return new TouchAndGestureEvent(type, velX, velY, bubbles, cancelable);
	}		
	
	override public function toString():String
	{
		return 'org.zengrong.events.GestureEvent:{' +
			'type:'+type+
			',bubble:'+bubbles+
			',cancelable:'+cancelable+
			',velX:'+velX+
			',velY:'+velY +'}';
	}
}
}