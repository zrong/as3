////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者: zrong(zrongzrong@gmail.com)
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
 * Modification: 2013-06-13 增加getBitmapDataMask方法和getBitmapDataWithMask方法
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
	 * 绘制Mask，返回Mask后的位图（黑白+渐变）
	 * @param	$bitmapData
	 * @return
	 */
	public static function getBitmapDataMask($bitmapData:BitmapData):BitmapData
	{
		var __bmd:BitmapData = new BitmapData($bitmapData.width, $bitmapData.height, false, 0xFF000000);
		var __sourceRect:Rectangle = __bmd.rect.clone();
		var __point:Point = new Point(0, 0);
		//为mask填充一个背景色
		__bmd.fillRect(__sourceRect, 0xFF000000);
		//分别填充红绿蓝通道，这样生成出的透明的部分才是白色
		__bmd.copyChannel($bitmapData, __sourceRect, __point, 8, 1);
		__bmd.copyChannel($bitmapData, __sourceRect, __point, 8, 2);
		__bmd.copyChannel($bitmapData, __sourceRect, __point, 8, 4);
		return __bmd;
	}
	
	/**
	 * 根据方向返回带有Mask的位图，位图内容和Mask位图并排
	 * @param	$bitmapData 要处理的原始图
	 * @param	$horizonal 横向还是纵向放置Mask
	 * @param	$transparent 原始图是否透明
	 * @param	$bgcolor 原始图背景色
	 * @return
	 */
	public static function getBitmapDataWithMask($bitmapData:BitmapData, $horizonal:Boolean, $transparent:Boolean, $bgcolor:uint):BitmapData
	{
		var __maskBmd:BitmapData = getBitmapDataMask($bitmapData);
		var __sourceRect:Rectangle = $bitmapData.rect.clone();
		var __point:Point = new Point(0,0);
		//新建一个带有Mask大小的位图
		var __saveBmd:BitmapData = null;
		if($horizonal)
		{
			__saveBmd = new BitmapData($bitmapData.width*2, $bitmapData.height, $transparent, $bgcolor);
			__point.x = $bitmapData.width;
		}
		else
		{
			__saveBmd = new BitmapData($bitmapData.width, $bitmapData.height*2, $transparent, $bgcolor);
			__point.y = $bitmapData.height;
		}
		__saveBmd.copyPixels($bitmapData, __sourceRect, new Point(0, 0), null, null, true);
		__saveBmd.copyPixels(__maskBmd, __sourceRect, __point, null, null, true);
		return __saveBmd;
	}
	
	/**
	 * 将位图左上角像素颜色视为空白区域的颜色，切除四周的空白区域
	 * @param $bmd 待处理的bitmapData。
	 */
	public static function trim($bmd:BitmapData):Object
	{
		//将左上角像素的颜色视为空白区域的颜色
		var __blankColor:uint = $bmd.getPixel32(0,0);
		return trimByColor($bmd, __blankColor);
	}
	
	/**
	 * 根据提供的空白颜色值，切除四周的空白颜色区域
	 * @param $bmd 待处理的bitmapData。
	 * @return 一个普通对象，形如：{rect:Rectangle,bitmapData:BitmapData}。
	 * 其中，rect为切除空白区域后的Rect（基于原始bitmapData的rect修改），bitmapData则是一个新的切除了空白区域的bitmapData对象
	 */
	public static function trimByColor($bmd:BitmapData, $blankColor:uint=0x00000000):Object
	{
		var __rect:Rectangle = $bmd.rect.clone();
		var __y:int = 0;
		var __x:int = 0;
		topOuter: for (__y = 0; __y < $bmd.height; __y++) 
		{
			for (__x = 0; __x < $bmd.width; __x++) 
			{
				if($blankColor != $bmd.getPixel32(__x,__y))
					break topOuter;
			}
			__rect.top++;
		}
		
		bottomOuter: for (__y = $bmd.height-1; __y >=__rect.top ; __y--) 
		{
			for (__x = 0; __x < $bmd.width; __x++) 
			{
				if($blankColor != $bmd.getPixel32(__x,__y))
					break bottomOuter;
			}
			__rect.bottom--;
		}
		
		leftOuter: for(__x=0;__x<$bmd.width;__x++)
		{
			for(__y=__rect.top;__y<__rect.bottom;__y++)
			{
				if($blankColor != $bmd.getPixel32(__x,__y))
					break leftOuter;
			}
			__rect.left++;
		}
		
		rightOuter: for(__x=$bmd.width-1;__x>=__rect.left;__x--)
		{
			for(__y=__rect.top;__y<__rect.bottom;__y++)
			{
				if($blankColor != $bmd.getPixel32(__x,__y))
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