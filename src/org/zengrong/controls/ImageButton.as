////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-12-14
//	说明：本组件参照Keith Peters的Minimalcomps组件写成，修改、使用或继承Minimalcal源码
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.controls
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.PixelSnapping;
import flash.events.MouseEvent;
import flash.filters.ColorMatrixFilter;
import flash.filters.DropShadowFilter;

import org.zengrong.controls.supportClasses.DisplayObjectButtonBase;
import org.zengrong.controls.supportClasses.Style;
import org.zengrong.utils.ColorMatrix;

/**
 * 支持up、over、down三态，同时支持toggle和seleted的图像按钮。
 * @author zrong
 */
public class ImageButton extends DisplayObjectButtonBase
{
	/**
	 * 构造函数 
	 * @param upStateImage 按钮up状态的位图
	 * @param overState 按钮over状态的位图
	 * @param downState 按钮down状态的位图
	 * @param parent ImageButton的父显示对象
	 * @param xpos x坐标
	 * @param ypos y坐标
	 * @param defaultHandler 按钮的默认处理程序，响应click事件
	 */	
	public function ImageButton(upStateImage:Bitmap, overStateImage:Bitmap=null, downStateImage:Bitmap=null, parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, defaultHandler:Function=null)
	{
		updateStateImage(upStateImage, overStateImage, downStateImage);
		super(parent, xpos, ypos, defaultHandler);
	}
	
	protected var _upBmd:BitmapData;
	protected var _overBmd:BitmapData;
	protected var _downBmd:BitmapData;
	
	protected var _overState:Bitmap;
	protected var _downState:Bitmap;
	
	/**
	 * 重新设置按钮中的图片
	 * @param upStateImage 		up状态的图片
	 * @param overStateImage	over状态的图片
	 * @param downStateImage	down状态的图片
	 */	
	public function setState(upStateImage:Bitmap, overStateImage:Bitmap=null, downStateImage:Bitmap=null):void
	{
		while(numChildren > 0)
			removeChildAt(0);
		_upBmd = null;
		_overBmd = null;
		_downBmd = null;
		_upState = null;
		_overState = null;
		_downState = null;
		updateStateImage(upStateImage, overStateImage, downStateImage);
		addChildren();
	}
	
	override protected function addChildren():void
	{
		//如果没有提供over和down状态的图片，就启用阴影效果
		_shaow = (_overBmd == null) && (_downBmd == null);
		_upState = new Bitmap(_upBmd, PixelSnapping.AUTO, true);
		_upState.width = this.width;
		_upState.height = this.height;
		super.addChildren();
		
		_overState = createState(_overBmd);
		addChild(_overState);
		
		_downState = createState(_downBmd);
		addChild(_downState);
	}
	
	//----------------------------------
	//  事件处理器
	//----------------------------------
	/**
	 * 覆盖父类的mouseOver事件
	 */
	override protected function onMouseOver(event:MouseEvent):void
	{
		super.onMouseOver(event);
		_upState.visible = false;
		_downState.visible = false;
		_overState.visible = true;
	}
	
	/**
	 * 覆盖父类的mouseOut事件
	 */
	override protected function onMouseOut(event:MouseEvent):void
	{
		super.onMouseOut(event);
		if(!_down)
		{
			_upState.visible = true;
			_downState.visible = false;
			_overState.visible = false;
		}
	}
	
	/**
	 * 覆盖父类的onMouseGoDown事件
	 */
	override protected function onMouseGoDown(event:MouseEvent):void
	{
		super.onMouseGoDown(event);
		_upState.visible = false;
		_overState.visible = false;
		_downState.visible = true;
	}
	
	/**
	 * 覆盖父类的onMouseGoUp事件
	 */
	override protected function onMouseGoUp(event:MouseEvent):void
	{
		super.onMouseGoUp(event);
		_upState.visible = !_selected;
		_overState.visible = false;
		_downState.visible = _selected;
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
	}
	
	override public function set selected(value:Boolean):void
	{
		super.selected = value;
		_upState.visible = !_selected;
		_overState.visible = false;
		_downState.visible = _selected;
	}
	
	/**
	 * 获取当前状态的对应Bitmap
	 */	
	private function get curState():Bitmap
	{
		if(_over)
			return _overState;
		if(_down)
			return _downState;
		return Bitmap(_upState);
	}
	
	/**
	 * 更新按钮中的状态图片
	 * @param upStateImage		up状态的图片
	 * @param overStateImage	over状态的图片
	 * @param downStateImage	down状态的图片
	 */	
	private function updateStateImage(upStateImage:Bitmap, overStateImage:Bitmap=null, downStateImage:Bitmap=null):void
	{
		setSize(upStateImage.width, upStateImage.height); 
		//trace('imagebutton:', this.width, this.height);
		_upBmd = upStateImage.bitmapData;
		if(overStateImage)
			_overBmd = overStateImage.bitmapData;
		if(downStateImage)
			_downBmd = downStateImage.bitmapData;
	}
	
	private function createState($bmd:BitmapData):Bitmap
	{
		var __bmpState:Bitmap = null;
		if($bmd)
			__bmpState = new Bitmap($bmd, PixelSnapping.AUTO, true);
		else
			__bmpState = new Bitmap(_upBmd, PixelSnapping.AUTO, true);
		__bmpState.width = this.width;
		__bmpState.height = this.height;
		__bmpState.visible = false;
		return __bmpState;
	}
}
}