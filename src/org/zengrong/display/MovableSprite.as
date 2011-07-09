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
		init();
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
	 * 当前向上
	 */		
	protected var _up:Boolean = false;

	/**
	 * 当前向下
	 */		
	protected var _down:Boolean = false;
	
	/**
	 * 保存对象每个周期移动的距离和方向，这个值的x和y会根据移动方向、角度的变动而更新。
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

	//----------------------------------------
	// init
	//----------------------------------------
	/**
	 * 初始化sprite
	 */
	protected function init():void
	{
		clearTarget();
	}

	//----------------------------------------
	// getter/setter
	//----------------------------------------
	/**
	 * 返回Spite的当前位置
	 */	
	public function get posV():Vec2D
	{
		return new Vec2D(x, y);
	}

	public function get left():Boolean
	{
		return	_left;
	}
	
	public function get right():Boolean
	{
		return	_right;
	}

	public function get up():Boolean
	{
		return	_up;
	}
	
	public function get down():Boolean
	{
		return _down;
	}

	public function set left($left:Boolean):void
	{
		_left = $left;
	}
	
	public function set right($right:Boolean):void
	{
		_right = $right;
	}

	public function set up($up:Boolean):void
	{
		_up = $up;
	}
	
	public function set down($down:Boolean):void
	{
		_down = $down;
	}

	/**
	 * 返回按照delay计算的，应该移动的距离
	 */
	public function getOffsetV($delay:Number):Vec2D
	{
        moveV.angle += angVel * $delay;
		//更新速度，如果acc为0，则vel是个恒定的值
        vel += acc * $delay;
		//最终的移动距离，根据moveV与速度计算
        return moveV.mulNum(vel*$delay);
	}

	//----------------------------------------
	// public
	//----------------------------------------
	/**
	 * 更新自己的位置
	 */		
    public function update($elapsed:Number, $delay:Number) : void
    {
        var __vec:Vec2D = getOffsetV($delay);
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
		//trace(this.name, 'moveTo,targetV:',targetV, ',moveV:', moveV, ',posV:',posV, ',__vec:' ,__vec, ',__radian:', __radian);
        moveV.radian = __radian;
		//trace(this.name, 'moveV:', moveV);
    }

	/**
	 * Sprite所在的位置是否包含坐标点
	 * 这个包含关系是根据radius计算的范围
	 * */
	public function contain($x:int, $y:int):Boolean
	{
		return posV.subNum($x, $y).len2 <= radius*radius;
	}

	/**
	 * 清空目标，让Sprit不再移动
	 */
	public function clearTarget():void
	{
		targetV = null;
		moveV = new Vec2D();
		clearFlags();
	}

	/**
	 * 清空上下左右的控制标记
	 */
	public function clearFlags():void
	{
		_up = false;
		_down = false;
		_left = false;
		_right = false;
	}

	public function destroy():void
	{
		clearFlags();
		targetV = null;
		moveV = null;
	}
	
}
}
