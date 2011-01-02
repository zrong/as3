////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-01-02
//	说明：本组件参照Keith Peters的Minimalcomps组件写成，修改、使用或继承Minimalcal源码
////////////////////////////////////////////////////////////////////////////////
 
package org.zengrong.controls.supportClasses
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import org.zengrong.controls.Component;	

/**
 * 所有使用显示对象用作按钮的状态的按钮类的基类。ImageButton、ClassButton是它的子类
 * @author zrong
 */
public class DisplayObjectButtonBase extends Component
{
	protected var _over:Boolean = false;
	protected var _down:Boolean = false;
	protected var _selected:Boolean = false;
	protected var _toggle:Boolean = false;
	
	/**
	 * 是否在禁用按钮的时候使用去色效果
	 */
	protected var _colorless:Boolean = false;
	
	/**
	 * 是否使用阴影效果。阴影效果使用不同深度的阴影自动为按钮添加三态
	 */	
	protected var _shaow:Boolean = true;
	
	protected var _upState:DisplayObject;
	
	/**
	 * 构造函数。
	 * @param 按钮的父显示对象
	 * @param xpos x坐标
	 * @param ypos y坐标
 	 * @param defaultHandler 默认的事件处理器，侦听click事件
	 */
	public function DisplayObjectButtonBase(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0, defaultHandler:Function = null)
	{
		super(parent, xpos, ypos);
		if(defaultHandler != null)
		{
			addEventListener(MouseEvent.CLICK, defaultHandler);
		}
	}
	
	/**
	 * 初始化按钮
	 */
	override protected function init():void
	{
		super.init();
		buttonMode = true;
		useHandCursor = true;
	}
	
	/**
	 * 创建和添加子显示对象
	 */
	override protected function addChildren():void
	{
		this.addChild(_upState);
		if(_shaow)
			this.filters = [getShadow(1)];
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseGoDown);
		addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
	}
	
	override protected function getShadow(dist:Number, knockout:Boolean=false):DropShadowFilter
	{
		return new DropShadowFilter(dist, 45, 0x000000, 1, 2, 2);
	}
	
	//----------------------------------
	//  事件处理器
	//----------------------------------
	
	/**
	 * mouseover事件处理器
	 */
	protected function onMouseOver(event:MouseEvent):void
	{
		_over = true;
		if(_toggle && _selected)
			return;
		if(_shaow)
			this.filters = [getShadow(2)];
		addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
	}
	
	/**
	 * mouseOut事件处理器
	 */
	protected function onMouseOut(event:MouseEvent):void
	{
		_over = false;
		if(!_down)
		{
			if(_shaow)
				this.filters = [getShadow(1)];
		}
		removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
	}
	
	/**
	 * mouseOut事件处理器
	 */
	protected function onMouseGoDown(event:MouseEvent):void
	{
		_down = true;
		if(_shaow)
			this.filters = [getShadow(3)];
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
	}
	
	/**
	 * mouseUp事件处理器
	 */
	protected function onMouseGoUp(event:MouseEvent):void
	{
		if(_toggle  && _over)
		{
			_selected = !_selected;
		}
		_down = _selected;
		if(_shaow)
			this.filters = [_selected ? getShadow(3) : getShadow(1)];
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
	}
	
	//----------------------------------
	//  getter/setter
	//----------------------------------
	
	public function set colorless(value:Boolean):void
	{
		_colorless = value;
	}
	
	public function set shaow(value:Boolean):void
	{
		_shaow = value;
		if(!_shaow)
			this.filters = [];
	}
	
	public function set selected(value:Boolean):void
	{
		if(!_toggle)
		{
			value = false;
		}
		
		_selected = value;
		_down = _selected;
		if(_shaow)
			this.filters = [_selected ? getShadow(3) : getShadow(1)];
	}
	
	public function get selected():Boolean
	{
		return _selected;
	}
	
	public function set toggle(value:Boolean):void
	{
		_toggle = value;
	}
	public function get toggle():Boolean
	{
		return _toggle;
	}
	
	override public function set enabled(value:Boolean):void
	{
		super.enabled = value;
		if(_colorless)
		{
			if(_shaow)
				this.filters = value ? [getShadow(1)] : [Style.COLORLESS_FILTER, getShadow(1)];
			else
				this.filters = value ? [] : [Style.COLORLESS_FILTER];
		}
				
	}
}
}