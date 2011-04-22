////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-11
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.spritesheet
{
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

import org.zengrong.utils.Vec2D;

/**
 * 基于位图引擎的Sprite，并加入运动功能
 * @author zrong
 */
public class BMPMovableSprite extends BMPSprite
{
	public function BMPMovableSprite($bmds:Vector.<BitmapData>=null)
	{
		moveV = new Vec2D();
		super($bmds);
	}
	
	/**
	 * 半径，主要用于计算碰撞
	 */	
	public var radius:int = 0;
	
	/**
	 * 平移速度
	 */		
	public var vel:Number = 0;
	
	/**
	 * 平移加速度
	 */		
	public var acc:Number = 0;
	
	/**
	 * 旋转速度
	 */		
	public var angVel:Number = 0;
	
	/**
	 * 旋转加速度
	 */		
	public var angAcc:Number = 0;
	
	/**
	 * 保存每个周期移动的距离和方向，这个值的x和y会根据移动方向、角度的变动而更新。
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
	
	//----------------------------------
	//  getter/setter
	//----------------------------------
	/**
	 * 返回Spite的当前位置
	 */	
	public function get posV():Vec2D
	{
		return new Vec2D(x, y);
	}
	
	//----------------------------------
	//  公开方法
	//----------------------------------
	/**
	 * 更新自己的位置
	 */		
	override public function update($stage:BitmapData, $delay:Number=-1):void
	{
		moveV.angle += angVel * $delay;
		//更新速度，如果acc为0，则vel是个恒定的值
		vel += acc * $delay;
		//最终的移动距离，根据moveV与速度计算
		var __vec:Vec2D = moveV.mulNum(vel*$delay);
		this.x += __vec.x;
		this.y += __vec.y;
		super.update($stage, $delay);
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
}
}