////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-12-07
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.utils
{
import flash.utils.getQualifiedClassName;
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

	/**
	 * 二分查找，性能与Array和Vector原生的indexOf类似
	 * http://www.nczonline.net/blog/tag/computer-science/
	 * Copyright 2009 Nicholas C. Zakas. All rights reserved.  
	 * MIT-Licensed, see source file
	 * @param $items 被搜索的列表，必须是Array或者Vector
	 * @param $value 被搜索的值，可以是任意类型，只要能使用==比较
	 */
	public static function binarySearch($items:*, $value:*):int
	{
		var __className:String = getQualifiedClassName($items);
		if(__className.search(/^(__AS3__.vec::Vector\.<\w+>)|(Array)$/))
			throw TypeError("要使用二分查找，必须提供Array或者Vector！");
		var __time:int=0;
		var __startIndex:int = 0;
		var __stopIndex:int = $items.length - 1;
		var __middle:int = int((__stopIndex + __startIndex)*.5);
		while($items[__middle] != $value && __startIndex < __stopIndex)
		{
			//调整查找范围
			if ($value < $items[__middle])
				__stopIndex = __middle - 1;
			else if ($value > $items[__middle])
				__startIndex = __middle + 1;
			//重新计算中项索引
			__middle = int((__stopIndex + __startIndex)*.5);
			__time++;
		}
		trace('次数：', __time);
		//确保返回正确的值
		return ($items[__middle] != $value) ? -1 : __middle;
	}
}
}
