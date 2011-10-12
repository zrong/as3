package org.zengrong.ui
{
/**
 * 所有UI组件的基类
 */
public class UI extends Sprite
{
	public function UI()
	{
	}

	private var _width:Number;
	private var _height:Number;
	private var _enabled:Boolean;

	protected function init():void
	{
	}

	protected function addChildren():void
	{
	}

	protected function draw():void
	{
	}

	override public function get width():Number
	{
		return _width;
	}

	override public function set width($w:Number):void
	{
		_width = $w;
		draw();
	}
	override public function get height():Number
	{
		return _height;
	}

	override public function set height($h:Number):void
	{
		_height = $h;
		draw();
	}

	public function set enabled($en:Boolean):void
	{
		_enabled = $en;
		mouseEnabled = mouseChildren = _enabled;
		tabEnabled = $en;
		alpha = _enabled ? 1.0 : 0.5;
	}

	public function get enabled():Boolean
	{
		return _enabled;
	}

	public function setSize($width:int, $height:int): void 
	{
		width = $width;
		height = $height;
	}

	public function move($x:int, $y:int):void
	{
		x = $x;
		y = $y;
	}

	public function destroy():void
	{
	}
	
}
}
