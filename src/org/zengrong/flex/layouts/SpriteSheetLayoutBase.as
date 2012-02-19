package org.zengrong.flex.layouts
{
import flash.geom.Rectangle;

import mx.core.ILayoutElement;

import org.zengrong.flex.layouts.SpriteSheetCellVO;
import org.zengrong.flex.primitives.SpriteSheetBitmapImage;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;
import spark.primitives.BitmapImage;

public class SpriteSheetLayoutBase extends LayoutBase
{
	public function SpriteSheetLayoutBase()
	{
		super();
	}
	
	protected var _cells:Array;
	
	public function get cells():Array
	{
		return _cells;
	}
	
	public function set cells($value:Array):void
	{
		_cells = $value;
	}
	
	override public function get useVirtualLayout():Boolean
	{
		return false;
	}
	
	/**
	 * 不支持虚拟化
	 */	
	override public function set useVirtualLayout(value:Boolean):void
	{
		
	}

}
}
