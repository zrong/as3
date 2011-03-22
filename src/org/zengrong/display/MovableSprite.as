////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-03-15
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display
{
import flash.display.*;

import org.zengrong.utils.Vec2D;

/**
 * 一个可以移动的Sprite
 * @author zrong
 */
public class MovableSprite extends Sprite
{
    public function MovableSprite()
    {
        moveV = new Vec2D();
    }
	
	/**
	 * 半径，主要用于计算碰撞
	 */	
	public var radius:int = 0;
	
	/**
	* 速度
	*/		
	public var vel:Number = 0;
	
	/**
	 * 加速度
	 */		
	public var acc:Number = 0;
	
	/**
	 * 转向速度
	 */		
	public var angVel:Number = 0;
	
	/**
	 * 转向加速度
	 */		
	public var angAcc:Number = 0;
	
	/**
	 * 当前向右
	 */		
	protected var _right:Boolean = false;
	
	/**
	 * 当前向左
	 */		
	protected var _left:Boolean = false;
	
	/**
	 * 当前向前
	 */		
	protected var _forward:Boolean = false;
	
	/**
	 * 保存Avatar每个周期移动的距离和方向，这个值的x和y会根据移动方向、角度的变动而更新。
	 * 例如，垂直向下的运动，则moveV的x值应为0或无限接近与0，y则是一个大于0的数。
	 */		
	public var moveV:Vec2D;
	
	/**
	 * 保存要移动到的点位置
	 */	
	public var targetV:Vec2D;
	
	/**
	 * 运动摩擦力
	 */		
	public var friction:Number = 1;

	/**
	 * 返回Spite的当前位置
	 */	
	public function get posV():Vec2D
	{
		return new Vec2D(x, y);
	}

	/**
	 * 更新自己的位置
	 */		
    public function update($delay:Number) : void
    {
        moveV.angle += angVel * $delay;
		//更新速度，如果acc为0，则vel是个恒定的值
        vel += acc * $delay;
		//最终的移动距离，根据moveV与速度计算
        var __vec:Vec2D = moveV.mulNum(vel*$delay);
        this.x += __vec.x;
        this.y += __vec.y;
    }

	/**
	 * 设定移动的目标位置点，更新moveV以确定运动方向和距离
	 * @param $x 要移动到的位置的x坐标
	 * @param $y 要移动到的位置的y坐标
	 */		
    public function moveTo($x:Number, $y:Number) : void
    {
		targetV = new Vec2D($x, $y);
        var __vec:Vec2D = targetV.subVec(posV);
		var __radian:Number = __vec.radian;
        moveV.radian = __radian;
    }

	public function clearFlags() : void
	{
		_forward = false;
		_left = false;
		_right = false;
	}
	
	public function forward() : void
	{
		_forward = true;
	}
	
	public function left() : void
	{
		_left = true;
	}
	
	public function right() : void
	{
		_right = true;
	}
}
}
