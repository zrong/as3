////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-11
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.bmp
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
	public function BMPMovableSprite($bmds:Vector.<BitmapData>=null, $hasFlip:Boolean=false, $autoCenterOffset:Boolean=false)
	{
		super($bmds, $hasFlip, $autoCenterOffset);
	}
	
	/**
	 * 是否在可视界面中横向移动
	 * 控制x坐标是否变化。若该值为true，则x与rx一起变化。否则就只有rx变化。
	 * 若该值一直为true，则rx与x的值是完全相同的
	 */
	public var isOSDMoveX:Boolean = true; 

	/**
	 * 是否在可视界面中移动
	 * 控制y坐标是否变化。若该值为true，则y与ry一起变化。否则就只有ry变化。
	 * 若该值一直为true，则ry与y的值是完全相同的
	 */
	public var isOSDMoveY:Boolean = true; 

	/**
	 * realX，sprite在地图中的x坐标，在可以卷动的地图中，这个值一直是变化的。
	 * x在地图卷动的时候，可能是不变的。
	 */
	public var rx:int = 0;

	/**
	 * realY，sprite在地图中的y坐标，在可以卷动的地图中，这个值一直是变化的。
	 * y在地图卷动的时候，可能是不变的。
	 */
	public var ry:int = 0;

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
		var __x:int = this.x;
		var __y:int = this.y;
		//若自动计算偏移，则加上偏移值
	//	if( isAutoCenterOffset )
	//	{
	//		__x = int(__x + _centerOffset.x);
	//		__y = int(__y + _centerOffset.y);
	//	}
		return new Vec2D(__x, __y);
	}

	/**
	 * 返回Sprite在地图中的真实位置
	 */
	public function get realPosV():Vec2D
	{
		var __x:int = this.rx;
		var __y:int = this.ry;
		//若自动计算偏移，则加上偏移值
	//	if( isAutoCenterOffset )
	//	{
	//		__x = int(__x + _centerOffset.x);
	//		__y = int(__y + _centerOffset.y);
	//	}
		return new Vec2D(__x, __y);
	}

	//----------------------------------------
	// init
	//----------------------------------------
	
	override public function init():void
	{
		super.init();
		moveV = new Vec2D();
	}
	//----------------------------------
	//  公开方法
	//----------------------------------
	
	/**
	 * Sprite所在的位置是否包含坐标点
	 * 这个包含关系是根据radius计算的范围
	 * */
	public function contain($x:int, $y:int):Boolean
	{
		return posV.subNum($x, $y).len2 <= radius*radius;
	}

	/**
	 * sprite在地图上的位置是否包含坐标点
	 */
	public function realContain($x:int, $y:int):Boolean
	{
		return realPosV.subNum($x, $y).len2 <= radius*radius;
	}
	/**
	 * 更新自己的位置
	 */		
	override public function update($stage:BitmapData, $delay:Number=0):void
	{
		moveV.angle += angVel * $delay;
		//更新速度，如果acc为0，则vel是个恒定的值
		vel += acc * $delay;
		//最终的移动距离，根据moveV与速度计算
		var __vec:Vec2D = moveV.mulNum(vel*$delay);
		//rx和ry是始终变化的
		rx += int(__vec.x);
		ry += int(__vec.y);
		//x和y的值则在可视界面中移动的时候才会变化
		if(isOSDMoveX)
			this.x += int(__vec.x);
		if(isOSDMoveY)
			this.y += int(__vec.y);
		super.update($stage, $delay);
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
		moveV.radian = __radian;
	}

	/**
	 * 与moveTo的区别在于，这里设定的目标位置点是基于地图的绝对坐标
	 */
	public function moveToReal($x:int, $y:int):void
	{
		targetV = new Vec2D($x, $y);
		var __vec:Vec2D = targetV.subVec(realPosV);
		var __radian:Number = __vec.radian;
		moveV.radian = __radian;
	}

}
}
