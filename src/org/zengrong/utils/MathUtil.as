////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-12-07
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.utils
{
public class MathUtil
{
	/**
	 * 获取一个范围内的随机整数 
	 * @param $max 随机数的最大值
	 * @param $min 随机数的最小值
	 */	
	public static function getRandom($max:int, $min:int=0):int
	{
		return $min + Math.round(Math.random()*($max-$min));
	}
}
}