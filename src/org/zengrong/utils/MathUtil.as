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
		if($max === $min)
			return $max;
		return $min + Math.round(Math.random()*($max-$min));
	}
	
	/**
	 * 获取2的幂
	 * 算法从这儿偷的：http://en.wikipedia.org/wiki/Power_of_two#Algorithm_to_find_the_next-highest_power_of_two
	 */
	public static function nextPowerOf2($k:int):int
	{
		$k--;
		for (var i:int = 1; i < 32 * 8; i <<= 1)
			$k = $k | $k >> i;
		return $k + 1;
	}
}
}