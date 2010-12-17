////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-12-14
//	说明：本组件参照Keith Peters的Minimalcomps组件写成，修改、直接使用或继承Minimalcal源码
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.controls
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.PixelSnapping;
import flash.events.MouseEvent;

/**
 * 支持up、over、down三态，同时支持toggle和seleted的图像按钮。
 * @author zrong
 */
public class ImageButton extends Component
{
	/**
	 * 构造函数 
	 * @param parent ImageButton的父显示对象
	 * @param xpos x坐标
	 * @param ypos y坐标
	 * @param upStateImage 按钮up状态的位图
	 * @param overState 按钮over状态的位图
	 * @param downState 按钮down状态的位图
	 * @param defaultHandler 按钮的默认处理程序，响应click事件
	 */	
	public function ImageButton(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, upStateImage:Bitmap=null, overStateImage:Bitmap=null, downStateImage:Bitmap=null, defaultHandler:Function=null)
	{
		updateStateImage(upStateImage, overStateImage, downStateImage);
		super(parent, xpos, ypos);
		if(defaultHandler is Function)
			addEventListener(MouseEvent.CLICK, defaultHandler);
	}
	
	protected var _upBmd:BitmapData;
	protected var _overBmd:BitmapData;
	protected var _downBmd:BitmapData;
	
	protected var _upBmp:Bitmap;
	protected var _overBmp:Bitmap;
	protected var _downBmp:Bitmap;
	
	protected var _over:Boolean = false;
	protected var _down:Boolean = false;
	protected var _selected:Boolean = false;
	protected var _toggle:Boolean = false;
	
	public function set selected(value:Boolean):void
	{
		if(!_toggle)
		{
			value = false;
		}
		
		_selected = value;
		_down = _selected;
		_upBmp.visible = !_selected;
		_overBmp.visible = false;
		_downBmp.visible = _selected;
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
	
	override protected function init():void
	{
		if(_upBmd)
		{
			super.init();
			buttonMode = true;
			useHandCursor = true;
			setSize(_upBmd.width, _upBmd.height);
		}
	}
	
	public function setState(upStateImage:Bitmap, overStateImage:Bitmap=null, downStateImage:Bitmap=null):void
	{
		while(numChildren > 0)
			removeChild(getChildAt(0));
		updateStateImage(upStateImage, overStateImage, downStateImage);
		addChildren();
	}
	
	override public function draw():void
	{
		super.draw();
	}
	
	override protected function addChildren():void
	{
		//如果没有设定over和down状态，就是用up状态代替
		_upBmp = new Bitmap(_upBmd, PixelSnapping.AUTO, true);
		addChild(_upBmp);
		
		if(_overBmd)
			_overBmp = new Bitmap(_overBmd, PixelSnapping.AUTO, true);
		else
			_overBmp = new Bitmap(_upBmd, PixelSnapping.AUTO, true);
		_overBmp.visible = false;
		addChild(_overBmp);
		
		if(_downBmd)
			_downBmp = new Bitmap(_downBmd, PixelSnapping.AUTO, true);
		else
			_downBmp = new Bitmap(_upBmd, PixelSnapping.AUTO, true);
		_downBmp.visible = false;
		addChild(_downBmp);
		
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseGoDown);
		addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
	}
	
	/**
	 * Internal mouseOver handler.
	 * @param event The MouseEvent passed by the system.
	 */
	protected function onMouseOver(event:MouseEvent):void
	{
		_over = true;
		if(_toggle && _selected)
			return;
		addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		_upBmp.visible = false;
		_downBmp.visible = false;
		_overBmp.visible = true;
	}
	
	/**
	 * Internal mouseOut handler.
	 * @param event The MouseEvent passed by the system.
	 */
	protected function onMouseOut(event:MouseEvent):void
	{
		_over = false;
		if(!_down)
		{
			_upBmp.visible = true;
			_downBmp.visible = false;
			_overBmp.visible = false;
		}
		removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
	}
	
	/**
	 * Internal mouseOut handler.
	 * @param event The MouseEvent passed by the system.
	 */
	protected function onMouseGoDown(event:MouseEvent):void
	{
		_down = true;
		_upBmp.visible = false;
		_overBmp.visible = false;
		_downBmp.visible = true;
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
	}
	
	/**
	 * Internal mouseUp handler.
	 * @param event The MouseEvent passed by the system.
	 */
	protected function onMouseGoUp(event:MouseEvent):void
	{
		if(_toggle  && _over)
		{
			_selected = !_selected;
		}
		_down = _selected;
		_upBmp.visible = !_selected;
		_overBmp.visible = false;
		_downBmp.visible = _selected;
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
	}
	
	private function updateStateImage(upStateImage:Bitmap, overStateImage:Bitmap=null, downStateImage:Bitmap=null):void
	{
		if(upStateImage)
			_upBmd = upStateImage.bitmapData;
		if(overStateImage)
			_overBmd = overStateImage.bitmapData;
		if(downStateImage)
			_downBmd = downStateImage.bitmapData;
	}
}
}