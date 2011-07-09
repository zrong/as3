package org.zengrong.display.character
{
import flash.display.*;

import org.zengrong.utils.Vec2D;

/**
 * 可以移动的角色，在Character的基础上加入移动功能，包括：
 * 检测角色是否超过边缘
 *
 */
public class MovableChar extends Character
{
    public function MovableChar($bmds:Vector.<BitmapData>=null)
    {
		super($bmds);
    }
	
	/**
	 * 半径，主要用于计算碰撞
	 */	
	public var radius:int = 10;
	
	/**
	* 运动速度
	*/		
	public var vel:Number = 0;

	/**
	 * 保存运动速度
	 */
	public var speed:int;
	
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
	 * 角色是否在左边缘
	 */
	public var atLeftEdge:Boolean;

	/**
	 * 角色是否在右边缘
	 */
	public var atRightEdge:Boolean;

	/**
	 * 角色是否在上边缘
	 */
	public var atUpEdge:Boolean;

	/**
	 * 角色是否在下边缘
	 */
	public var atDownEdge:Boolean;

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
	

	//----------------------------------------
	// init
	//----------------------------------------
	/**
	 * 初始化sprite
	 */
	override protected function init():void
	{
		super.init();
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
		//使用整数，避免在计算的时候出现无限小值的情况
		return new Vec2D(int(this.x), int(this.y));
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
		if(_left)
			this.flip = true;
	}
	
	public function set right($right:Boolean):void
	{
		_right = $right;
		if(_right)
			this.flip = false;
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
	 * 角色是否在边缘
	 */
	public function get atEdge():Boolean
	{
		return this.atLeftEdge || this.atRightEdge || this.atUpEdge || this.atDownEdge;
	}

	/**
	 * 返回按照delay计算的，应该移动的距离
	 * 重写的时候去掉计算加速度和角加速度的计算，尽量减少误差。因为角色目前不需要旋转和加速
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
    override public function update($elapsed:Number, $delay:Number) : void
    {
		updateMyMoveState($elapsed, $delay);
		super.update($elapsed, $delay);
    }

	/**
	 * 设定移动的目标位置点，更新moveV以确定运动方向和距离
	 * @param $x 要移动到的位置的x坐标
	 * @param $y 要移动到的位置的y坐标
	 */		
    public function moveTo($x:int, $y:int) : void
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
	public function hitTestByRadius($x:int, $y:int):Boolean
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

	override public function destroy():void
	{
		super.destroy();
		clearFlags();
		targetV = null;
		moveV = null;
	}

	/**
	 * 是否已经到达了目标点
	 * @return 包含x,y两个布尔值的Object，x为true代表x方向到达了目标点，y为true代表y方向到达了目标点。
	 */
	public function getArrived($offset:int=0):Object
	{
		var __arrive:Object = {x:false, y:false};
		//在玩家跑过目标点的时候停住
		if(this.left)
		{
			if( this.x <= this.targetV.x + $offset)
				__arrive.x = true;
		}
		else if(this.right)
		{
			if(this.x >= this.targetV.x - $offset)
				__arrive.x = true;
		}
		if(this.up )
		{
			if(this.y <= this.targetV.y + $offset)
				__arrive.y = true;
		}
		else if(this.down)
		{
			if(this.y >= this.targetV.y - $offset)
				__arrive.y = true;
		}
		//TODO 2011-07-04 zrong 处理无限小值的问题
		//上面的代码有问题。如果一个角色仅仅向左边运动，那么up和down值为false，因此判断y坐标是否到达的逻辑永远都不会执行
		//这可能会导致角色永远都无法到达目的地。但这种情况有个特性，就是由于目的坐标与其实坐标非常近，moveV的值会非常小。
		//因此在这里增加一层判断。在moveV非常小的时候，判断为已经到达目的地
		//这种判断方式，其实是不科学的。后面有时间再修正
		if(moveV.x<.01 && moveV.x>-.01)
			__arrive.x = true;
		if(moveV.y<.01 && moveV.y>-.01)
			__arrive.y = true;
		return __arrive;
	}

	/**
	 * 更新玩家是否碰撞到屏幕边缘的情况
	 */
	public function updateEdge():void
	{
		if(osdLimit==null) return;
		if(this.up && this.y <= osdLimit.y)
			atUpEdge = true;
		else if( this.down && this.y >= osdLimit.bottom)
			atDownEdge = true;
		else if( this.left && this.x <= osdLimit.x)
			atLeftEdge = true;
		else if(this.right && this.x >= osdLimit.right)
			atRightEdge = true;
		else
		{
			atUpEdge = false;
			atDownEdge = false;
			atLeftEdge = false;
			atRightEdge = false;
		}
		//trace('updateEdge,atLeftEdge:', atLeftEdge, ',atRightEdge:', atRightEdge, ',atUpEdge:', atUpEdge, ',atDownEdge:', atDownEdge, ',角色位置：', this.wx, this.wy, osdLimit.toString());
	}

	public function runTo($x:int, $y:int):void
	{
		trace('MovableChar('+this.name+').runTo:', $x, $y);
		clearTarget();
		//判断点击的地点在当前player的哪个方向
		var __dx:int = $x - int(this.x);
		var __dy:int = $y - int(this.y);
		//对点击点的x和y舍去小数部分，如果舍去部分与目标点相等，那么直接使用当前位置
		if(__dx > 0)
		{
			this.left = false;
			this.right = true;
		}
		else if(__dx < 0)
		{
			this.left = true;
			this.right = false;
		}
		else
		{
			this.left = false;
			this.right = false;
		}
		if(__dy > 0)
		{
			this.up = false;
			this.down = true;
		}
		else if(__dy < 0)
		{
			this.up = true;
			this.down = false;
		}
		else
		{
			this.up = false;
			this.down = false;
		}
		//如果不能确定方向，说明目标点与站立点重合，这种情况不跑动
		if(!this.up && !this.down && !this.left && !this.right)
		{
			trace('MovableChar('+this.name+').runTo，不能确定方向，不跑动。');
			clearTarget();
			return;
		}
		moveTo($x, $y);
		run();
		//trace(this.name,'runTo,玩家方向,left:', this.left, ',right:', this.right, ',up:', this.up, ',down:', this.down);
	}

	public function run():void
	{
		vel = speed;
	}

	public function stand():void
	{
		vel = 0;
	}

	//----------------------------------------
	// 非公有
	//----------------------------------------
	//更新自己的移动
	protected function updateMyMoveState($elapsed:Number,$delay:Number):void
	{
		var __vec:Vec2D = this.getOffsetV($delay);
		//trace(this.name, 'Character.update开始更新xy,targetV:', targetV, ',moveV:', moveV, ',__vec:', __vec, '$delay:', $delay, ',vel:', vel);
		this.x += __vec.x;
		this.y += __vec.y;
	}
}
}
