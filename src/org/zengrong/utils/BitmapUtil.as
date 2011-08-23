////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong(zrongzrong@gmail.com)
//  创建时间：2011-8-15
////////////////////////////////////////////////////////////////////////////////

package org.zengrong.utils
{
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 提供位图相关的计算工具
 * @author zrong
 * 
 */
public class BitmapUtil
{
	/**
	 * 将一个ARGB分割成包含a,r,g,b值的普通对象
	 */
	public static function splitARGB($argb:uint):Object
	{
		return {	a:$argb >> 24 & 0xFF,
			r:$argb >> 16 & 0xFF,
			g:$argb >> 8 & 0xFF,
			b:$argb & 0xFF	};
	}
	
	/**
	 * 将位图左上角像素颜色视为空白区域的颜色，切除四周的空白区域
	 * @param $bmd 待处理的bitmapData。
	 * @return 一个普通对象，形如：{rect:Rectangle,bitmapData:BitmapData}。
	 * 其中，rect为切除空白区域后的Rect（基于原始bitmapData的rect修改），bitmapData则是一个新的切除了空白区域的bitmapData对象
	 */
	public static function trim($bmd:BitmapData):Object
	{
		var __rect:Rectangle = $bmd.rect.clone();
		var __y:int = 0;
		var __x:int = 0;
		//将左上角像素的颜色视为空白区域的颜色
		var __blankColor:uint = $bmd.getPixel32(0,0);
		topOuter: for (__y = 0; __y < $bmd.height; __y++) 
		{
			for (__x = 0; __x < $bmd.width; __x++) 
			{
				if(__blankColor != $bmd.getPixel32(__x,__y))
					break topOuter;
			}
			__rect.top++;
		}
		
		bottomOuter: for (__y = $bmd.height-1; __y >=__rect.top ; __y--) 
		{
			for (__x = 0; __x < $bmd.width; __x++) 
			{
				if(__blankColor != $bmd.getPixel32(__x,__y))
					break bottomOuter;
			}
			__rect.bottom--;
		}
		
		leftOuter: for(__x=0;__x<$bmd.width;__x++)
		{
			for(__y=__rect.top;__y<__rect.bottom;__y++)
			{
				if(__blankColor != $bmd.getPixel32(__x,__y))
					break leftOuter;
			}
			__rect.left++;
		}
		
		rightOuter: for(__x=$bmd.width-1;__x>=__rect.left;__x--)
		{
			for(__y=__rect.top;__y<__rect.bottom;__y++)
			{
				if(__blankColor != $bmd.getPixel32(__x,__y))
					break rightOuter;
			}
			__rect.right--;
		}
		if(__rect.width<=0||__rect.height<=0)
		{
			trace('空位图原样返回');
			return {rect:$bmd.rect.clone(), bitmapData:$bmd.clone()};
			//return null;
		}
		var __bmd:BitmapData = new BitmapData(__rect.width, __rect.height, $bmd.transparent, 0x00000000);
		__bmd.copyPixels($bmd, __rect, new Point(0,0), null, null, true);
		return {rect:__rect, bitmapData:__bmd};
	}
}
}