package org.zengrong.utils
{
import flash.geom.Point;

/**
 * 2维向量常用功能实现
 * @author zrong
 * Modification: 2013-09-24
 */
public class Vec2D
{
    public var x:Number = 0;
    public var y:Number = 0;

    public function Vec2D($x:Number = 0, $y:Number = 0)
    {
        this.x = $x;
        this.y = $y;
    }

	//----------------------------------
	//  getter/setter
	//----------------------------------
	/**
	 * 使用勾股定理计算向量长度
	 * x、y在这里代表直角三角形的两条直角边。
	 * @return 自身的x、y代表的直角三角形的斜边的长度。
	 */	
	public function get len() : Number
	{
		return Math.sqrt(this.x * this.x + this.y * this.y);
	}
	
	/**
	 * 使用勾股定理计算不开方的向量长度。
	 * @see len()
	 */
	public function get len2() : Number
	{
		return this.x * this.x + this.y * this.y;
	}
	
	/**
	 * 得到一个新的归一化向量，该向量的长度为1。使用这个归一化向量可以更方便地计算速度、角度和坐标。
	 * <ol>
	 * <li>例如，可以计算出与自己代表的直角三角形的同比直角三角形的斜边上的任意一个坐标点。</li>
	 * <li>再例如，使用Vec2D.mulN(n)，可以得到根据斜边n的长度计算出来x、y坐标点。</li>
	 * </ol>
	 * @return 归一化之后的新向量。
	 */	
	public function get normalized() : Vec2D
	{
		var __len:Number = this.len;
		var __vec:Vec2D = new Vec2D(0, 0);
		__vec.x = this.x / __len;
		__vec.y = this.y / __len;
		return __vec;
	}
	
	/**
	 * 根据自己的坐标值返回一个point对象。
	 */	
	public function get point() : Point
	{
		return new Point(this.x, this.y);
	}
	
	/**
	 * 根据提供的point的坐标设置自己的向量值。
	 */	
	public function set point($point:Point) : void
	{
		this.x = $point.x;
		this.y = $point.y;
	}
	
	/**
	 * 获取自己与坐标0,0点的角度值。
	 */	
	public function get angle() : Number
	{
		return radian * 180 / Math.PI;
	}
	
	/**
	 * 根据自己与0,0点的角度值设置自己的向量值。
	 */	
	public function set angle($angle:Number) : void
	{
		var __radian:Number = $angle * Math.PI / 180;
		radian = __radian;
	}
	
	/**
	 * 获取自己与坐标0,0点的弧度，并保证弧度为正值。
	 */	
	public function get radian():Number
	{
		var __radian:Number = Math.atan2(this.y, this.x); 
		if(__radian < 0)
			__radian += Math.PI*2;
		return __radian;
	}
	
	/**
	 * 根据与0,0点的弧度值设置自己的向量值。
	 */	
	public function set radian($radian:Number):void
	{
		this.x = Math.cos($radian);
		this.y = Math.sin($radian);
	}
	
	/**
	 * 复制当前的值到一个新的vec2D对象。
	 */	
	public function get vec() : Vec2D
	{
		return new Vec2D(this.x, this.y);
	}
	
	/**
	 * 根据提供的vec2D的值设置自己的向量值。
	 */	
	public function set vec($vec:Vec2D) : void
	{
		this.x = $vec.x;
		this.y = $vec.y;
	}
	
	/**
	 * 返回右法线向量，一般用右法线代表标准法线。
	 */	
	public function get rightNormals() : Vec2D
	{
		return new Vec2D(-this.y, this.x);
	}
	
	/**
	 * 返回左法线向量。
	 */
	public function get leftNormals():Vec2D
	{
		return new Vec2D( this.y, -this.x);
	}
	
	/**
	 * 获取一个反向向量。
	 */	
	public function get reverse() : Vec2D
	{
		return new Vec2D(-this.x, -this.y);
	}
	
	public function getAngle($vec:Vec2D) : Number
	{
		var __num:Number = this.nDot($vec);
		return Math.acos(__num) * 180 / Math.PI;
	}
	
	//----------------------------------
	//  公有方法
	//----------------------------------
	/**
	 * 当前向量是否位于参数向量的左边，版本1，通过计算垂直点乘
	 * @param $vec 要比较位置的向量
	 */
	public function isLeft($vec:Vec2D) : Boolean
	{
		return this.cross($vec) >= 0;
	}
	
	/**
	 * 当前向量是否位于参数向量的左边，版本2，仅比较x值
	 */
	public function isLeft2($vec:Vec2D):Boolean
	{
		return x < $vec.x;
	}
	
	/**
	 * 当前向量是否与参数向量平行
	 */
	public function isParallel($vec:Vec2D):Boolean
	{
		var __thisVec:Vec2D = this.normalized;
		var __otherVec:Vec2D = $vec.normalized;
		return 	(__thisVec.x == __otherVec.x && __thisVec.y == __otherVec.y) ||
				(__thisVec.x == -__otherVec.x && __thisVec.y == -__otherVec.y);
	}
	
	/**
	 * cross 是垂直点乘的别名
	 * @see #prepDot()
	 */
    public function cross($vec:Vec2D) : Number
    {
		return prepDot($vec);
    }

	/**
	 * 获取与参数向量的点乘( dot product ）<br>
	 * 值如果是正数，那么2个向量的方向是相同的（夹角小于90度）。<br>
	 * 值如果是负数，那么2个向量的方向是相反的（夹角大于90度）。 
	 * @param $vec 被点乘的向量
	 * @return 点乘后的值
	 */
    public function dot($vec:Vec2D) : Number
    {
        return this.x * $vec.x + this.y * $vec.y;
    }
	
	/**
	 * 获取归一化的点乘（normalized dot product）。<br>
	 * 先将两个向量归一化，然后再点乘。
	 * @see #dot()
	 * @return 点乘后的值
	 */
	public function nDot($vec:Vec2D) : Number
	{
		var __thisVec:Vec2D = this.normalized;
		var __otherVec:Vec2D = $vec.normalized;
		return __thisVec.x * __otherVec.x + __thisVec.y * __otherVec.y;
	}

	/**
	 * 垂直点乘（prep dot product）
	 * 垂直点乘就是使用向量的右法线与参数向量进行点乘
	 * @param	$vec 被点乘的向量
	 * @see #dot()
	 * @return 点乘后的值
	 */
	public function prepDot($vec:Vec2D):Number
	{
		//return -this.y * $vec.x + this.x * $vec.y;
		return this.x * $vec.y - this.y * $vec.x;
	}
	
	/**
	 * 获取向量相对于参数向量的投影
	 */
	public function project($vec:Vec2D) : Vec2D
	{
		var __dot1:Number = this.dot($vec);
		var __dot2:Number = $vec.dot($vec);
		var __num:Number = __dot1 / __dot2;
		return $vec.mulNum(__num);
	}
	
	/**
	 * 根据向量1的起点、终点坐标、向量2的起点坐标，计算出向量1与向量2（当前向量）的交点坐标。<br>
	 * 向量1根据$v1p0与$v1p1计算，向量2已知，向量2的起点坐标已知，计算得到向量1与向量2的交点坐标。
	 * @param	$v1p0 向量1的起点坐标
	 * @param	$v1p1 向量1的终点坐标
	 * @param	$v2p0 向量2的起点坐标
	 * @see https://docs.google.com/drawings/d/1rXSO0ocKfu8fKeFaLSFZ1YFyBGMjm0wcv9NtjO3D6kM/pub?w=486&h=350
	 * @return 代表交点坐标的向量
	 */
	public function intersectionPoint($v1p0:Vec2D, $v1p1:Vec2D, $v2p0:Vec2D):Vec2D
	{
		//得到向量1
		var __vec1:Vec2D = $v1p1.subVec($v1p0);
		//得到向量3（向量1起点指向向量2起点的向量）
		var __vec3:Vec2D = $v2p0.subVec($v1p0);
		//计算交点参数
		var __intersection:Number = intersect(__vec1, __vec3);
		//根据交点参数计算坐标
		return new Vec2D($v1p0.x+__vec1.x*__intersection, $v1p0.y+__vec1.y*__intersection);
	}
	
	/**
	 * 计算两个向量的交点参数。<br>
	 * 假设要计算向量1和向量2是否相交。$vec1代表向量1，当前向量为向量2(vec2)。$vec3代表从$vec1的起点到向量2起点的向量。那么：<br>
	 * <ol>
	 * <li>当两个垂直点乘的比例正好为1，那么交点就正好在向量2(vec2)的终点上；</li>
	 * <li>当为0-1之间的值时，那么交点就在向量1($vec1)上；</li>
	 * <li>当为负数交点就在向量2(vec2)的起点之前；</li>
	 * <li>当为大于1的数，交点就在向量2(vec2)的终点之后。</li>
	 * </ol>
	 * @see https://docs.google.com/drawings/d/1rXSO0ocKfu8fKeFaLSFZ1YFyBGMjm0wcv9NtjO3D6kM/pub?w=486&h=350
	 * @param	$vec1 第1个向量
	 * @param	$vec3 $vec1的起点到当前向量(vec2)的起点的向量
	 * @return 一个交叉点的参数值
	 */
	public function intersect($vec1:Vec2D, $vec3:Vec2D):Number
	{
		return $vec1.prepDot(this) / $vec3.prepDot(this);
	}
	
	/**
	 * 将自身归一化，修改自身。
	 * @see normalized
	 */	
	public function normalize() : void
	{
		this.vec = this.normalized;
	}
	
	public function toString() : String
	{
		return 'Vec2D:('+this.x.toString() + " " + this.y.toString()+')';
	}
	
	//----------------------------------
	//  向量与数字的四则运算，修改自身
	//----------------------------------
	/**
	 * 向量加法，修改自身
	 */	
	public function addN($x:Number, $y:Number=NaN) : void
	{
		if(isNaN($y))
			$y = $x;
		this.x = this.x + $x;
		this.y = this.y + $y;
	}
	
	/**
	 * 向量减法，修改自身
	 */	
	public function subN($x:Number, $y:Number=NaN) : void
	{
		if(isNaN($y))
			$y = $x;
		this.x = this.x - $x;
		this.y = this.y - $y;
	}
	
	/**
	 * 向量乘法，修改自身
	 */	
    public function mulN($x:Number, $y:Number=NaN) : void
    {
		if(isNaN($y))
			$y = $x;
        this.x = this.x * $x;
        this.y = this.y * $y;
    }
	
	/**
	 * 向量除法，修改自身
	 */	
	public function divN($x:Number, $y:Number=NaN) : void
	{
		if(isNaN($y))
			$y = $x;
		this.x = this.x / $x;
		this.y = this.y / $y;
	}
	
	//----------------------------------
	//  向量与数字四则运算，不修改自身，返回一个新的Vec2D
	//----------------------------------
	/**
	 * 向量加法，并返回一个新的Vec2D
	 * @param $num 要增加的数字 
	 */	
	public function addNum($x:Number, $y:Number=NaN) : Vec2D
	{
		if(isNaN($y))
			$y = $x;
		return new Vec2D(this.x + $x, this.y + $y);
	}
	
	/**
	 * 向量减法，返回一个新的Vec2D
	 * @param $num 要减去的数字
	 */		
	public function subNum($x:Number, $y:Number=NaN) : Vec2D
	{
		if(isNaN($y))
			$y = $x;
		return new Vec2D(this.x - $x, this.y - $y);
	}
	
	/**
	 * 向量乘法，返回一个新的Vec2D
	 */	
	public function mulNum($x:Number, $y:Number=NaN) : Vec2D
	{

		if(isNaN($y))
			$y = $x;
		return new Vec2D(this.x * $x, this.y * $y);
	}
	
	/**
	 * 向量除法，返回一个新的Vec2D
	 */	
	public function divNum($x:Number, $y:Number=NaN) : Vec2D
	{
		if(isNaN($y))
			$y = $x;
		return new Vec2D(this.x / $x, this.y / $y);
	}
	
	//----------------------------------
	//  向量与向量的四则运算，修改自身
	//----------------------------------
	/**
	 * 向量与向量加法，修改自身
	 * @param $vec 要增加的Vec2D
	 */	
    public function addV($vec:Vec2D) : void
    {
        this.x = this.x + $vec.x;
        this.y = this.y + $vec.y;
    }

	/**
	 * 向量与向量减法，修改自身
	 * @param $vec 要减去的Vec2D
	 */	
    public function subV($vec:Vec2D) : void
    {
        this.x = this.x - $vec.x;
        this.y = this.y - $vec.y;
    }
	
	/**
	 * 向量与向量乘法，修改自身
	 * @param $num 要相乘Vec2D
	 */	
	public function mulV($vec:Vec2D) : void
	{
		this.x = this.x * $vec.x;
		this.y = this.y * $vec.y;
	}
	
	/**
	 * 向量与向量除法，修改自身
	 * @param $num 要作为除数的Vec2D
	 */	
	public function divV($vec:Vec2D) : void
	{
		this.x = this.x / $vec.x;
		this.y = this.y / $vec.y;
	}
	
	//----------------------------------
	//  向量与向量的的四则运算，返回新的向量
	//----------------------------------

	/**
	 * 向量与向量加法，返回新的向量
	 * @param $vec 要增加的Vec2D
	 */	
	public function addVec($vec:Vec2D) : Vec2D
	{
		return new Vec2D(this.x + $vec.x, this.y + $vec.y);
	}
	
	/**
	 * 向量与向量减法，返回新的向量
	 * @param $vec 要减去的Vec2D
	 */	
	public function subVec($vec:Vec2D) : Vec2D
	{
		return new Vec2D(this.x - $vec.x, this.y - $vec.y);
	}
	
	/**
	 * 向量与向量乘法，返回新的向量
	 * @param $num 要相乘Vec2D
	 */	
	public function mulVec($vec:Vec2D) : Vec2D
	{
		return new Vec2D(this.x * $vec.x, this.y * $vec.y);
	}
	
	/**
	 * 向量与向量除法，返回新的向量
	 * @param $num 要作为除数的Vec2D
	 */	
	public function divVec($vec:Vec2D) : Vec2D
	{
		return new Vec2D(this.x / $vec.x, this.y / $vec.y);
	}
}
}
