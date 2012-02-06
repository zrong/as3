package org.zengrong.flex.layouts
{
/**
 * SpriteSheetBitmapFillMode 类定义了调整SpriteSheet中的图像块大小模式的一个枚举，这些模式确定 SpriteSheetGroup 如何填充由布局系统指定的 SpriteSheetBitmapImage 图像块。
 * @author zrong
 * @see org.zengrong.flex.layouts.SpriteSheetCell
 * @see org.zengrong.flex.components.SpriteSheetGoup
 * 创建时间：2012-02-06
 */
public class SpriteSheetBitmapFillMode
{
	/**
	 * 在x方向重复位图
	 */	
	public static const REPEAT_X:String = 'repeatX';
	
	/**
	 * 在y方向重复位图
	 */	
	public static const REPEAT_Y:String = 'repeatY';
	
	/**
	 * 同时在x方向和y方向重复位图 
	 */	
	public static const REPEAT_XY:String = 'repeatXY';
}
}