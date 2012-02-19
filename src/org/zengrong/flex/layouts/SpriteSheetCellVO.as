package org.zengrong.flex.layouts
{
import org.zengrong.flex.primitives.SpriteSheetBitmapImage;
/**
 * 暂存在SpriteSheetLayout布局过程中的临时ValueObject
 * @author zrong
 * 创建日期：2012-02-06
 */
public class SpriteSheetCellVO
{
	
	public function SpriteSheetCellVO()
	{
	}
	
	public var bmp:SpriteSheetBitmapImage;
	public var originalW:Number;
	public var originalH:Number;
	public var measureW:Number;
	public var measureH:Number;
	public var measureX:int;
	public var measureY:int;
	
	/**
	 * 显示的指定X
	 */	
	public var explicitX:Number;
	
	/**
	 * 显示的指定Y 
	 */	
	public var explicitY:Number;
	
	public var fillMode:String;
	
	public var rowIndex:int = -1;
}
}