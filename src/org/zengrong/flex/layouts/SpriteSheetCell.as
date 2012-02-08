package org.zengrong.flex.layouts
{
import mx.core.IMXMLObject;
import mx.core.mx_internal;
import mx.graphics.BitmapFillMode;

use namespace mx_internal;

public class SpriteSheetCell implements IMXMLObject
{
	public function SpriteSheetCell()
	{
	}
	
	private var _x:Number;
	
	private var _y:Number;
	
	private var _fillMode:String;
	
	/**
	 * 指定SpriteSheet中的图像名称，若设置了name属性，则会清空index属性
	 */	
	private var _name:String;
	
	/**
	 * 指定SpriteSheet中的图像索引号，0基。若设置了index属性，则会清空name属性
	 */	
	private var _index:int = -1;
	
	private var _width:Number;
	
	private var _height:Number;
	
	/**
	 * 行索引，仅在实现九宫格布局的时候需要
	 */	
	public var rowIndex:int = -1;
	
	public function get width():Number
	{
		return _width;
	}
	
	public function set width($value:Number):void
	{
		if (_width == $value)
			return;
		_width = $value;
	}
	
	public function get height():Number
	{
		return _height;
	}
	
	public function set height($value:Number):void
	{
		if (_height == $value)
			return;
		_height = $value;
	}
	
	[Inspectable(category="General", enumeration="repeatX,repeatY,repeatXY", defaultValue="repeatX")]
	
	public function get fillMode():String
	{
		return _fillMode;
	}

	public function set fillMode($value:String):void
	{
		_fillMode = $value;
	}

	public function get y():Number
	{
		return _y;
	}

	public function set y($value:Number):void
	{
		_y = $value;
	}

	public function get x():Number
	{
		return _x;
	}

	public function set x($value:Number):void
	{
		_x = $value;
	}
	
	public function get name():String
	{
		return _name;
	}
	
	public function set name($value:String):void
	{
		if(!$value) throw new ArgumentError('name的值不能为空！');
		_name = $value;
		//若存在index属性，则清空name属性
		if(_index>-1) _index = -1;
	}

	public function initialized($document:Object, $id:String):void
	{
		//trace('SpriteSheetCell.initialized:', $document, $id);
	}

	public function get index():int
	{
		return _index;
	}

	public function set index($value:int):void
	{
		if($value<=-1) throw ArgumentError("index的值必须大于-1！当前值:"+$value);
		_index = $value;
		//如果存在name属性，就重置index
		if(_name) _name = null;
	}

}
}
