package org.zengrong.flex.primitives
{
import org.zengrong.flex.layouts.SpriteSheetCell;

import spark.primitives.BitmapImage;

public class SpriteSheetBitmapImage extends BitmapImage
{
	public function SpriteSheetBitmapImage()
	{
		super();
	}
	
	private var _cell:SpriteSheetCell;

	public function get cell():SpriteSheetCell
	{
		return _cell;
	}

	public function set cell($value:SpriteSheetCell):void
	{
		_cell = $value;
	}
}
}