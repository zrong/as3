////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-03-15
////////////////////////////////////////////////////////////////////////////////s
package org.zengrong.utils
{
import flash.utils.*;

/**
 * 处理增长和运动的时间
 * org.zengrong.display.MoveableSprite使用这个类和Vec2D来处理运动
 * 因为间隔时间是绝对的，如果帧率降低，那么每帧运动的距离会增大，这样的运动不会因为帧率降低导致运动变慢
 * @author zrong
 * */
public class TimerUpdate
{
    private var _lastTime:uint = 0;		//从程序启动到上一次调用update的时间，单位是毫秒
    private var _curTime:uint = 0;			//从程序启动到本次调用update后的时间，单位是毫秒
    private var _delayTime:Number = 0;		//两次操作间的时间间隔，单位是秒

	/**
	 * 返回最后一次调用update和上一次调用update间的时间间隔，单位是秒
	 * */
    public function get delayTime() : Number
    {
        return _delayTime;
    }
	
	/**
	 * 返回从游戏启动到最后一次调用update之间的时间流逝，单位是毫秒。
	 * */
	public function get elapsed() : uint
	{
		return _curTime;
	}
	
	/**
	 * 更新时间的流逝，更新elapsed和delayTime的值
	 * @see #delayTime
	 * @see #elapsed
	 * */
    public function update() : void
    {
        _curTime = getTimer();
        _delayTime = (_curTime - _lastTime) * 0.001;
        _lastTime = _curTime;
    }
}
}
