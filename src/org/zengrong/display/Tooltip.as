////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  创建时间：2010-12-23
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display
{

import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * 显示一个有背景色的提示信息
 * @author zrong
 */
public class Tooltip extends Sprite
{
	/**
	 * @param $reference 使用Tooltip的对象
	 * @param $tip tip文字
	 * @param $width 宽度
	 * @param $height 高度
	 * @param $ignoreMouse 在reference的鼠标事件被禁用的时候，是否依然显示tooltip
	 * @param $bgColor tooltip背景色
	 * 
	 */	
	public function Tooltip($reference:InteractiveObject=null, $tip:String = '', $width:int=86, $height:int=66, $ignoreMouse:Boolean=false, $bgColor:uint=0xFFFF99)
	{
		_bgColor = $bgColor;
		_reference = $reference;
		_ignoreMouse = $ignoreMouse;
		_width = $width;
		_height = $height;
		init();
		if($tip)
			setTip($tip);
		if(_reference)
			addListener();
	}
	
	private var _bgColor:uint;
	private var _width:int;
	private var _height:int;
	private var _ignoreMouse:Boolean;	//在reference的鼠标事件被禁用的时候，是否依然显示tooltip
	
	private var _tf:TextField;
	private var _reference:InteractiveObject;	//被引用的显示对象，根据鼠标在该对象上的情况，显示或者隐藏tooltip
	
	/**
	 * 设置Tip文字
	 */	
	public function setTip($tip:String):void
	{
		_tf.htmlText = $tip;
	}
	
	/**
	 * 设置Tooltip的引用
	 * @param $reference
	 */	
	public function setReference($reference:InteractiveObject):void
	{
		if($reference == _reference)
			return;
		removeListener();
		_reference = $reference;
		addListener();
	}
	
	public function destory():void
	{
		removeListener();
		_reference = null;
	}
	
	private function init():void
	{
		this.graphics.clear();
//		this.graphics.lineStyle(1, 0x000000);
		this.graphics.beginFill(_bgColor);
		this.graphics.drawRoundRect(0,  0, _width, _height, 8, 8);
		this.graphics.endFill();
		addChildren();
	}
	
	private function addChildren():void
	{
		var __format:TextFormat = new TextFormat(null,12, 0x000000);
		__format.leading = 3;
		_tf = new TextField();
		_tf.selectable = false;
		_tf.defaultTextFormat = __format;
		_tf.width = _width-8;
		_tf.height = _height-8;
		_tf.multiline = true;
		_tf.wordWrap = true;
		_tf.x = 4;
		_tf.y = 4;
		this.addChild(_tf);
		this.visible = false;
		this.mouseChildren = false;
		this.mouseEnabled = false;
		this.tabEnabled = false;
	}
	
	private function handler_rollOver(evt:MouseEvent):void
	{
		this.visible = true;
		_reference.addEventListener(MouseEvent.ROLL_OUT, handler_rollOut);
	}
	
	private function handler_rollOut(evt:MouseEvent):void
	{
		this.visible = false;
		_reference.removeEventListener(MouseEvent.ROLL_OUT, handler_rollOut);
	}
	
	private function handler_enterFrame(evt:Event):void
	{
		if(_ignoreMouse)
		{
			var __rootMouse:Point = this.localToGlobal(new Point(this.mouseX, this.mouseY));
//			trace('测试鼠标位置：', __rootMouse, _reference.hitTestPoint(__rootMouse.x, __rootMouse.y));
			if(_reference.hitTestPoint(__rootMouse.x, __rootMouse.y, true))
				this.visible = true;
			else
				this.visible = false;
		}
	}
	
	private function addListener():void
	{
		this.x = _reference.x;
		this.y = _reference.y - _height;
		_reference.addEventListener(MouseEvent.ROLL_OVER, handler_rollOver);
		if(_ignoreMouse)
			_reference.addEventListener(Event.ENTER_FRAME, handler_enterFrame);
	}
	
	private function removeListener():void
	{
		_reference.removeEventListener(MouseEvent.ROLL_OVER, handler_rollOver);
		_reference.removeEventListener(MouseEvent.ROLL_OUT, handler_rollOut);
		_reference.removeEventListener(Event.ENTER_FRAME, handler_enterFrame);
	}
}
}