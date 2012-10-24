package org.zengrong.flex.components
{
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.events.TouchInteractionEvent;

import org.zengrong.events.TouchAndGestureEvent;

import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.TouchScrollHelper;
import spark.core.IViewport;
import spark.effects.Fade;
import spark.effects.ThrowEffect;

use namespace mx_internal;

[DefaultProperty("viewport")]

/**
 * 简单滚动器，仅实现拖动功能。
 * @author zrong
 * 创建日期：2012-03-02
 * 修改日期：2012-6-14
 */

/**
 * 锁定滚动成功的时候发布此事件。
 * @eventType org.zengrong.assets.TouchAndGestureEvent.TOUCH_MOVE
 * @see lockVerticalScroll
 * @see lockHorizontalScroll
 */
[Event(name="touchMove",type="org.zengrong.events.TouchAndGestureEvent")]

/**
 * <h1>拖动超限的时候发布此事件。</h1>
 * <p>在收到此事件时，需要检测velX和velY的值。若为NaN，说明这个方向没有超域。</p>
 * <p>若大于0代表向下或向右超域，小于0代表向左或向上超域。</p>
 * @eventType org.zengrong.assets.TouchAndGestureEvent.BEYOND
 */
[Event(name="beyond",type="org.zengrong.events.TouchAndGestureEvent")]

public class SimpleScroller extends UIComponent implements IVisualElementContainer
{
	
	protected static const MAX_DRAG_RATE:Number = 30;
	
	protected static const ZERO_POINT:Point = new Point(0,0); 
	
	protected static const HORIZONTAL_SCROLL_POSITION:String = "horizontalScrollPosition";
	
	protected static const VERTICAL_SCROLL_POSITION:String = "verticalScrollPosition";

	
	public function SimpleScroller()
	{
		super();

		this.addEventListener(FlexEvent.UPDATE_COMPLETE, handler_scrollerupdateComplete);
		//初始化拖动手势
		initTouchScrollHelper();
		installTouchListeners();
	}
	
	
	protected var _minSlopInches:Number = 0.079365; // 20.0/252.0
	
	/**
	 * 若目前正在拖动，此值为true
	 */
	protected var _inTouchInteraction:Boolean=false;
	
	/**
	 *  @protected
	 * 用于跟踪在滚动发生的时候是否捕获下一个单击事件。通常我们收到后应该直接发布出去。
	 * 在滚动和抛出发生的时候，我们捕获mouseDown事件 
	 * 在mouseDown, touchInteractionStart,touchInteractionEnd的时候设置它的值
	 */
	protected var _captureNextMouseDown:Boolean = false;
	
	/**
	 * 在滚动发生的时候是否捕获下一个单击事件。通常我们收到后应该直接发布出去。
	 * 在mouseDown或者touchScrollStart的时候设置它的值 
	 */
	protected var _captureNextClick:Boolean = false;

	
	/**
	 * 在滚动开始之前保存横向滚动的值
	 */
	protected var _hspBeforeTouchScroll:Number;
	
	/**
	 * 在滚动开始前保存纵向滚动的值
	 */
	protected var _vspBeforeTouchScroll:Number;
	
	protected var _minVerticalScrollPosition:Number = 0;
	protected var _maxVerticalScrollPosition:Number = 0;
	protected var _minHorizontalScrollPosition:Number = 0;
	protected var _maxHorizontalScrollPosition:Number = 0;
	
	private var _viewport:IViewport;
	
	protected var _touchScrollHelper:TouchScrollHelper;
	
	protected var _pageScrollingEnabled:Boolean = true;
	
	protected var _barFadeEffect:Fade;
	
	protected var _horizontalBarOffset:int=0;

	/**
	 * 横向滚动条的位置偏移，仅针对y轴
	 */
	[Bindable]
	public function get horizontalBarOffset():int
	{
		return _horizontalBarOffset;
	}

	/**
	 * @private
	 */
	public function set horizontalBarOffset($value:int):void
	{
		_horizontalBarOffset = $value;
	}

	
	protected var _horizontalBar:DisplayObject;
	
	/**
	 * 生成横向滚动条形象的类
	 */
	[Bindable]
	public function get horizontalBar():DisplayObject
	{
		return _horizontalBar;
	}

	/**
	 * @private
	 */
	public function set horizontalBar($value:DisplayObject):void
	{
		if(_horizontalBar == $value) return;
		if(!_horizontalBar) removeTargetFromFadeEffect(_horizontalBar);
		_horizontalBar = $value;
		addTargetToFadeEffect(_horizontalBar);
	}
	
	protected var _verticalBarOffset:int = 0;

	/**
	 * 纵向滚动条的偏移值，仅针对x轴
	 */
	[Bindable]
	public function get verticalBarOffset():int
	{
		return _verticalBarOffset;
	}

	/**
	 * @private
	 */
	public function set verticalBarOffset($value:int):void
	{
		_verticalBarOffset = $value;
	}

	
	protected var _verticalBar:DisplayObject;

	/**
	 * 生成纵向滚动条形象的类
	 */
	[Bindable]
	public function get verticalBar():DisplayObject
	{
		return _verticalBar;
	}
	
	/**
	 * 生成纵向滚动条形象的类
	 */
	public function set verticalBar($value:DisplayObject):void
	{
		if(_verticalBar == $value) return;
		if(!_verticalBar) removeTargetFromFadeEffect(_verticalBar);
		_verticalBar = $value;
		addTargetToFadeEffect(_verticalBar);
	}
	
	/**
	 * 最大的纵向滚动值
	 */
	public function get maxVerticalScrollPosition():int
	{
		if(!viewport) return 0;
		return viewport.contentHeight - viewport.height;
	}
	
	/**
	 * 最大的横向滚动值
	 */
	public function get maxHorizontalScrollPosition():int
	{
		if(!viewport) return 0;
		return viewport.contentWidth - viewport.width;
	}
	
	protected var _lockVerticalScroll:Boolean = false;

	/**
	 * <h1>锁定垂直滚动</h1>
	 * <p>如果此值为true，则在滚动第一次发生的时候，若垂直滚动像素较小，就不会进行垂直滚动</p>
	 * <p>锁定成功的同时发布TouchAndGestureEvent.TOUCH_MOVE事件，此事件会提供velX（代表水平滚动像素）和velY（代表垂直滚动像素），</p>
	 * <p>负数为向左向上；正数为向右向下。该值的绝对值就是移动的绝对像素值。此时velX的绝对值一定较大。</p>
	 */
	[Bindable]
	public function get lockVerticalScroll():Boolean
	{
		return _lockVerticalScroll;
	}

	/**
	 * @private
	 */
	public function set lockVerticalScroll($value:Boolean):void
	{
		_lockVerticalScroll = $value;
	}
	
	protected var _lockHorizontalScroll:Boolean = false;

	/**
	 * <h1>锁定水平滚动</h1>
	 * <p>如果此值为true，则在滚动第一次发生的时候检测水平和垂直滚动值，若水平滚动像素较小，就不会进行水平滚动。</p>
	 * <p>锁定成功的同时发布TouchAndGestureEvent.TOUCH_MOVE事件，此事件会提供velX（代表水平滚动像素）和velY（代表垂直滚动像素）。</p>
	 * <p>负数为向左向上；正数为向右向下。该值的绝对值就是移动的绝对像素值。此时velY的绝对值一定较大。</p>
	 */
	[Bindable]
	public function get lockHorizontalScroll():Boolean
	{
		return _lockHorizontalScroll;
	}

	/**
	 * @private
	 */
	public function set lockHorizontalScroll($value:Boolean):void
	{
		_lockHorizontalScroll = $value;
	}
	
	private var _enableScroll:Boolean=true;

	/**
	 * 是否允许滚动。如果该值为false，不进行滚动
	 */
	public function get enableScroll():Boolean
	{
		if(!_enableHorizonalScroll && !_enableVerticalScroll) return false;
		return _enableScroll;
	}

	public function set enableScroll($value:Boolean):void
	{
		_enableScroll = $value;
	}
	
	private var _enableHorizonalScroll:Boolean=true;

	/**
	 * 是否允许横向滚动，如果该值为false，不进行横向滚动
	 */
	public function get enableHorizonalScroll():Boolean
	{
		return _enableHorizonalScroll;
	}

	/**
	 * @private
	 */
	public function set enableHorizonalScroll($value:Boolean):void
	{
		_enableHorizonalScroll = $value;
	}

	
	private var _enableVerticalScroll:Boolean=true;

	/**
	 * 是否允许纵向滚动，如果该值为false，不进行纵向滚动
	 */
	public function get enableVerticalScroll():Boolean
	{
		return _enableVerticalScroll;
	}

	/**
	 * @private
	 */
	public function set enableVerticalScroll($value:Boolean):void
	{
		_enableVerticalScroll = $value;
	}
	

	/**
	 * 当前是否超域
	 */
	protected var _isBeyond:Boolean = false;
	
	/**
	 * 当前是否处于纵向滚动锁定中
	 */
	protected var _isLockVerticonalScroll:Boolean = false;
	
	/**
	 * 当前是否处于横向滚动锁定中
	 */
	protected var _isLockHorizontalScroll:Boolean = false;
	
	/**
	 * 将滚动条指示器添加到Fade效果的目标中
	 */
	private function addTargetToFadeEffect($target:DisplayObject):void
	{
		if(!_barFadeEffect)
		{
			_barFadeEffect = new Fade();
			_barFadeEffect.addEventListener(EffectEvent.EFFECT_END, handler_fadeEnd);
			_barFadeEffect.duration = 200;
			_barFadeEffect.alphaTo = 0;
		}
		if(_barFadeEffect.targets.indexOf(_barFadeEffect) == -1)
			_barFadeEffect.targets.push($target);
	}
	
	/**
	 * 将滚动条指示器从Fade效果的目标中删除
	 */
	private function removeTargetFromFadeEffect($target:DisplayObject):void
	{
		if(_barFadeEffect)
		{
			var __index:int = _barFadeEffect.targets.indexOf($target);
			if(__index>=0) _barFadeEffect.targets.splice(__index, 1);
		}
	}
	
	/**
	 * 把Viewport的子显示对象移动到滚动条顶部
	 */
	public function moveChild2Top($child:DisplayObject):void
	{
		if(viewportUI && $child && viewportUI.contains($child))
		{
			var __rect:Rectangle = $child.getBounds(viewportUI);
			//trace('max:', maxVerticalScrollPosition, ',rect:', __rect.y);
			var __maxV:int = maxVerticalScrollPosition;
			if(__maxV>0 && __rect.y>__maxV)
			{
				__rect.y = __maxV;
			}
			viewport.verticalScrollPosition = __rect.y;
		}
	}
	
	public function move2Top():void
	{
		if(viewport) viewport.verticalScrollPosition= 0;
	}
	
	public function move2Bottom():void
	{
		if(canScrollVertically)
		{
			viewport.verticalScrollPosition = viewport.contentHeight-viewport.height;
		}
	}
	
	public function move2Left():void
	{
		if(viewport) viewport.horizontalScrollPosition = 0;
	}
	
	public function move2Right():void
	{
		if(canScrollHorizontally)
		{
			viewport.horizontalScrollPosition = maxHorizontalScrollPosition;
		}
	}
	
	protected var _backgroundColor:uint = 0xFFFFFF;

	/**
	 * 滚动区域的背景颜色
	 */
	[Bindable]
	public function get backgroundColor():uint
	{
		return _backgroundColor;
	}

	public function set backgroundColor($value:uint):void
	{
		_backgroundColor = $value;
		drawBG();
	}

	
	protected var _backgroundAlpha:Number = 0;

	/**
	 * 滚动区域的背景Alpha
	 */
	[Bindable]
	public function get backgroundAlpha():Number
	{
		return _backgroundAlpha;
	}

	/**
	 * @private
	 */
	public function set backgroundAlpha($value:Number):void
	{
		_backgroundAlpha = $value;
		drawBG();
	}


	/**
	 * 实现Scroller的背景，一般是透明的矩形，需要这个矩形来让Scroller响应鼠标事件
	 */
	protected function drawBG():void
	{
		this.graphics.clear();
		if(_width>0 && _height>0)
		{
			this.graphics.beginFill(backgroundColor, backgroundAlpha);
			this.graphics.drawRect(0,0,_width, _height);
			this.graphics.endFill();
			//trace('绘制......:', _width, _height);
		}
	}
	
	override public function set width($value:Number):void
	{
		super.width = $value;
		drawBG();
	}
	
	override public function set height($value:Number):void
	{
		super.height = $value;
		drawBG();
		//更新高度的同时更新viewport的高度
		if(viewport)
		{
			viewport.height = this.height;
		}
	}
	
	override protected function measure():void
	{
		super.measure();
//		trace('计算,显式宽度：', explicitWidth,',计算宽度：',measuredWidth, ',当前宽度：', _width);
//		trace('计算,显式高度：', explicitHeight,',计算高度：',measuredHeight, ',当前高度：', _height);
		drawBG();
//        measuredMinWidth = 0;
//        measuredMinHeight = 0;
//        measuredWidth = explicitWidth;
//        measuredHeight = explicitHeight;
	}

	public function get viewport():IViewport
	{
		return _viewport;
	}
	
	public function get viewportUI():GroupBase
	{
		return _viewport as GroupBase;
	}

	public function set viewport($value:IViewport):void
	{
		if(_viewport == $value) return;
		uninstallViewport();
		_viewport = $value;
		installViewport();
	}
	
	protected function get canScrollHorizontally():Boolean
	{
		if(!enableHorizonalScroll) return false;
		if(viewport)
		{
			return viewport.contentWidth > viewport.width;
		}
		return false;
	}
	
	protected function get canScrollVertically():Boolean
	{
		if(!enableVerticalScroll) return false;
		if(viewport)
		{
			return viewport.contentHeight > viewport.height;
		}
		return false;
	}
	
	/**
	 * 初始化滚动帮助类，这个类位于mx_internal包
	 */
	protected function initTouchScrollHelper():void
	{
		_touchScrollHelper = new TouchScrollHelper();
		_touchScrollHelper.target = this;
		
		//在被拖动的时候循环调用的方法
		_touchScrollHelper.dragFunction = performDrag;
		_touchScrollHelper.throwFunction = performThrow;
	}
	
	/**
	 * 开始侦听touch事件
	 */
	private function installTouchListeners():void
	{
		addEventListener(MouseEvent.MOUSE_DOWN, handler_mouseDown);
		addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_STARTING, handler_touchStarting);
		addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_START, handler_touchStart);
		addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_END, handler_touchEnd);
		
		//侦听鼠标的click和mouseDown事件、mouseUp事件
		//滚动正在进行的时候，阻塞mouseDown事件
		//滚动正在进行或者刚刚完成的时候，阻塞click事件
		addEventListener(MouseEvent.CLICK, touchScrolling_captureMouseHandler, true);
		addEventListener(MouseEvent.MOUSE_DOWN, touchScrolling_captureMouseHandler, true);
		addEventListener(MouseEvent.MOUSE_UP, touchScrolling_captureMouseHandler, true);
	}
	
	/**
	 * 取消侦听touch事件
	 */
	private function uninstallTouchListeners():void
	{
		removeEventListener(MouseEvent.MOUSE_DOWN, handler_mouseDown);
		removeEventListener(TouchInteractionEvent.TOUCH_INTERACTION_STARTING, handler_touchStarting);
		removeEventListener(TouchInteractionEvent.TOUCH_INTERACTION_START, handler_touchStart);
		removeEventListener(TouchInteractionEvent.TOUCH_INTERACTION_END, handler_touchEnd);
		
		removeEventListener(MouseEvent.CLICK, touchScrolling_captureMouseHandler, true);
		removeEventListener(MouseEvent.MOUSE_DOWN, touchScrolling_captureMouseHandler, true);
		removeEventListener(MouseEvent.MOUSE_UP, touchScrolling_captureMouseHandler, true);
	}
	
	/**
	 * 安装视口
	 */
	private function installViewport():void
	{
		if (viewport)
		{
			viewport.width = this.width;
			viewport.height = this.height;
			viewport.clipAndEnableScrolling = true;
			this.addChild(viewportUI);
			viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
			viewport.addEventListener("scaleYChanged", viewport_scaleChange);
			viewport.addEventListener("scaleXChanged", viewport_scaleChange);
			viewport.addEventListener(Event.RESIZE, viewport_resizeHandler);
		}
	}
	
	/**
	 * 卸载视口
	 */
	private function uninstallViewport():void
	{
		if (viewport)
		{
			viewport.clipAndEnableScrolling = false;
			viewport.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
			viewport.removeEventListener(Event.RESIZE, viewport_resizeHandler);
			viewport.removeEventListener("scaleXChanged", viewport_scaleChange);
			viewport.removeEventListener("scaleYChanged", viewport_scaleChange);
			if(this.contains(viewportUI)) this.removeChild(viewportUI);
			_viewport = null;
		}
	}
	
	/**
	 * 在Scroller的updateComplete事件发生的时候，更新视口的宽高
	 */
	protected function handler_scrollerupdateComplete($evt:FlexEvent):void
	{
		//trace('----------SGMapScroller.updateComplete:', this.width, this.height);
		if(viewport)
		{
			viewport.height = this.height;
			viewport.width = this.width;
		}
	}
	
	/**
	 * 在视口的尺寸变化的时候，加入对视口的update事件的侦听
	 */
	private function viewport_resizeHandler(event:Event):void
	{
//		trace('---viewport_resize:', viewport.width, viewport.height,
//			',contentHeight:', viewport.contentHeight, 
//			',verticalScrollPos:', viewport.verticalScrollPosition);
//		trace('---viewport_resize:', viewport.verticalScrollPosition);
		viewport.addEventListener(FlexEvent.UPDATE_COMPLETE, 
			handleSizeChangeOnUpdateComplete);
	}
	
	private function viewport_scaleChange($evt:Event):void
	{
//		trace('---viewport_scaleChange:',$evt.type, 
//			",viewport wh:", viewport.width, viewport.height,
//			',contentWH:', viewport.contentWidth, viewport.contentHeight, 
//			',VHScrollPos:', viewport.verticalScrollPosition, viewport.horizontalScrollPosition,
//			",viewport scrollRect:", viewportUI.scrollRect);
	}
	
	/**
	 * Viewport的尺寸发生改变的时候，限制ViewPort不会拖出范围
	 */
	private function handleSizeChangeOnUpdateComplete(event:FlexEvent):void
	{
		viewport.removeEventListener(FlexEvent.UPDATE_COMPLETE, 
			handleSizeChangeOnUpdateComplete);
		//限制滚动到内容边缘停止
		if( canScrollHorizontally && 
			viewport.horizontalScrollPosition+ viewport.width > viewport.contentWidth)
			viewport.horizontalScrollPosition = maxHorizontalScrollPosition;
		//在内容高度太小以至于不必发生滚动的时候不处理
		if(viewport.contentHeight > viewport.height &&
			viewport.verticalScrollPosition + viewport.height > viewport.contentHeight)
			viewport.verticalScrollPosition = maxVerticalScrollPosition;
//		trace('---viewport_sizeChangeOnUpdate:',
//			',width', viewport.width,
//			',height', viewport.height,
//			',contentWidth', viewport.contentWidth,
//			',contentHeight', viewport.contentHeight,
//			',horzonalScrollPos:', viewport.horizontalScrollPosition ,
//			',verticalScrollPos:', viewport.verticalScrollPosition);
	}
	
	/**
	 * 视口属性变化的事件
	 */
	private function viewport_propertyChangeHandler(event:PropertyChangeEvent):void
	{
//		trace('----viewport_propertyChangeHeight:',event.property, event.oldValue, event.newValue, viewport.contentWidth, viewport.contentHeight, viewport.width, viewport.height);
//		trace('scrollRect:', viewportUI.scrollRect);
//		trace('layout:', viewportUI.layout);
		switch(event.property) 
		{
			//如果内容的宽度和高度降低导致无法滚动，就将内容的滚动到0
			//如果内容的滚动值大于最大滚动值，就还原到最大滚动值
			case "contentWidth": 
				if(viewport.contentWidth<viewport.width) move2Left();
				else if(viewport.horizontalScrollPosition > maxHorizontalScrollPosition) move2Right();
				break;
			case "contentHeight":
				if(viewport.contentHeight<viewport.height) move2Top();
				else if(viewport.verticalScrollPosition > maxVerticalScrollPosition) move2Bottom();
				break;
		}
	}
	
	/**
	 * 在Scroller范围内按下鼠标的时候的事件
	 */
	protected function handler_mouseDown(event:MouseEvent):void
	{
		_captureNextClick = false;
		
		//开始观察滚动情况，helper将调用performDrag和paerformThrow
		//如果当前允许锁定滚动，就都传递true
		//因为只有传递true，在performDrag的时候，才会永远有x和y参数，否则，在不允许滚动的方向，根本就不会受到performDrag调用
		_touchScrollHelper.startScrollWatch(
			event, 
			lockVerticalScroll ? true : canScrollHorizontally,
			lockHorizontalScroll ? true : canScrollVertically,
			Math.round(_minSlopInches * Capabilities.screenDPI), 
			MAX_DRAG_RATE);
	}
	
	/**
	 * 在touch开始之前收到此事件
	 * 如果有其他对象在捕获touch事件，而我当前处于滚动状态，就不触发我的touch事件
	 */
	private function handler_touchStarting($evt:TouchInteractionEvent):void
	{
		/**
		 * 若发出touch事件的是我，什么也不做
		 * 若我没有开始滚动，什么也不做
		 * 
		 * 若我已经开始滚动，取消事件，这时不会再触发touchStart事件
		 */
		if ($evt.relatedObject != this && _inTouchInteraction)
		{
			$evt.preventDefault();
		}
	}
	
	/**
	 * touch开始时收到此事件
	 */
	private function handler_touchStart($evt:TouchInteractionEvent):void
	{
		//trace('拖动开始');
		//如果touch的不是我，就停止我的滚动侦测
		if ($evt.relatedObject != this)
		{
			_touchScrollHelper.stopScrollWatch();
		}
		//发起touch的是我，就开始滚动
		else
		{
			_captureNextClick = true;
			_captureNextMouseDown = true;
			//_preventThrows = false;
			
			_hspBeforeTouchScroll = viewport.horizontalScrollPosition;
			_vspBeforeTouchScroll = viewport.verticalScrollPosition;
			
			//trace('拖动开始时候保存位置：', _hspBeforeTouchScroll, _vspBeforeTouchScroll);
			
			// need to invaliadte the ScrollerLayout object so it'll update the
			// scrollbars in overlay mode
			//this.invalidateDisplayList();
			
			_inTouchInteraction = true;
			addScrollBar();
		}
	}
	
	/**
	 * 在touch结束的时候处理
	 */
	private function handler_touchEnd($evt:TouchInteractionEvent):void
	{
		//trace('拖动结束');
		//如果结束touch的是我，就将捕获开关值还原，等待下一次touch
		if ($evt.relatedObject == this)
		{
			_captureNextMouseDown = false;
			_inTouchInteraction = false;
			_captureNextClick = false;
			removeScrollBar();
			_touchScrollHelper.stopScrollWatch();
			_isLockHorizontalScroll = false;
			_isLockVerticonalScroll = false;
			_isBeyond = false;
		}
	}
	
	/**
	 * 在滚动发生的时候阻塞鼠标的MouseDown/Click/MouseUp事件
	 */
	protected function touchScrolling_captureMouseHandler($event:MouseEvent):void
	{
		switch($event.type)
		{
			case MouseEvent.CLICK:
			case MouseEvent.MOUSE_UP:
				//trace('是否侦测下一次点击：', _captureNextClick);
				if (!_captureNextClick) return;
				$event.stopImmediatePropagation();
				break;
		}
	}
	
	/**
	 * 在拖动的时候被helper调用
	 * @param dragX
	 * @param dragY
	 */	
	private function performDrag($dragX:Number, $dragY:Number):void
	{
		if(!enableScroll)
		{
			_touchScrollHelper.stopScrollWatch();
			_touchScrollHelper.endTouchScroll();
			return;
		}
		// dragX和dragY是全局坐标系中的增量值。
		//为了使用它们改变滚动条位置，我们必须转换他们到滚动条的坐标系。
		//下面进行转换
		//trace('原始的拖动距离:', $dragX, $dragY);
		var __localDragDeltas:Point = globalToLocal(new Point($dragX,$dragY)).subtract(globalToLocal(ZERO_POINT));
		$dragX = __localDragDeltas.x;
		$dragY = __localDragDeltas.y;
		//trace('全局后的拖动距离：', $dragX, $dragY);
		
		var __xMove:int = 0;
		var __yMove:int = 0;
		
		//trace('lockV:', _isLockVerticonalScroll, ',lockH:', _isLockHorizontalScroll);
		if (canScrollHorizontally && !_isLockHorizontalScroll)
			__xMove = $dragX;
		
		if (canScrollVertically && !_isLockVerticonalScroll)
			__yMove = $dragY;
		
		if(lockVerticalScroll &&
			!_isLockVerticonalScroll&&
			Math.abs($dragX)>Math.abs($dragY))
		{
			__yMove = 0;
			_isLockVerticonalScroll = true;
			trace('锁定V');
			this.dispatchEvent(new TouchAndGestureEvent(TouchAndGestureEvent.TOUCH_MOVE, $dragX, $dragY));
		}
		if(lockHorizontalScroll &&
			!_isLockHorizontalScroll &&
			 Math.abs($dragY)>Math.abs($dragX))
		{
			__xMove = 0;
			_isLockHorizontalScroll = true;
			trace('锁定H');
			this.dispatchEvent(new TouchAndGestureEvent(TouchAndGestureEvent.TOUCH_MOVE, $dragX, $dragY));
		}
		
		var __newHSP:Number = _hspBeforeTouchScroll - __xMove;
		var __newVSP:Number = _vspBeforeTouchScroll - __yMove;
		//trace('限制前的pos：', __newHSP, __newVSP, _hspBeforeTouchScroll, _vspBeforeTouchScroll);
		var __beyondEvt:TouchAndGestureEvent = new TouchAndGestureEvent(TouchAndGestureEvent.BEYOND);
		if(__newHSP<0)
		{
			__newHSP = 0;
			__beyondEvt.velX = -1;
		}
		else
		{
			//在可滚动区域大于可视区域的时候才处理滚动
			var __maxVHP:Number = maxHorizontalScrollPosition;
			if(__maxVHP<0) __maxVHP=0;
			if(__newHSP > __maxVHP)
			{
				__newHSP =__maxVHP;
				__beyondEvt.velX = 1;
			}
		}
		if(__newVSP<0)
		{
			__newVSP = 0;
			__beyondEvt.velY = -1;
		}
		else
		{
			var __maxVSP:Number = maxVerticalScrollPosition;
			if(__maxVSP<0) __maxVSP = 0;
			if(__newVSP > __maxVSP)
			{
				__newVSP = __maxVSP;
				__beyondEvt.velY = 1;
			}
		}
		//trace('限制后的pos：', __newHSP, __newVSP);
		checkBeyond(__beyondEvt);
		
		viewport.horizontalScrollPosition = __newHSP;
		viewport.verticalScrollPosition = __newVSP;
		updateScrollBarPos();
	}
	
	/**
	 * 检测是否超域，如果有一个方向超域，就发布事件
	 */
	protected function checkBeyond($evt:TouchAndGestureEvent):void
	{
		if(!_isBeyond && 
			(!isNaN($evt.velX) || !isNaN($evt.velY)) )
		{
			this.dispatchEvent($evt);
			_isBeyond = true;
		}
	}
	
	/**
	 * 在抛事件的时候被helper调用
	 * @param $velocityX
	 * @param $velocityY
	 */	
	protected function performThrow($velocityX:Number, $velocityY:Number):void
	{
		_touchScrollHelper.endTouchScroll();
	}
	
	/**
	 * 加入滚动指示条
	 */
	protected function addScrollBar():void
	{
		if(canScrollVertically && _verticalBar)
		{
			_verticalBar.x = viewport.width - _verticalBar.width + _verticalBarOffset;
			_verticalBar.alpha = 1;
//			trace('verticalBar.x:', _verticalBar.x);
			this.addChild(_verticalBar);
		}
		if(canScrollHorizontally && _horizontalBar)
		{
			_horizontalBar.y = viewport.height - _horizontalBar.height + _horizontalBarOffset;
			_horizontalBar.alpha = 1;
			//trace('horizontalBar.y:', _horizontalBar.y, viewport.height, this.height);
			this.addChild(_horizontalBar);
		}
	}
	
	/**
	 * 移除滚动指示条
	 */
	protected function removeScrollBar():void
	{
		//if(_verticalBar || _horizontalBar) _barFadeEffect.play();
		handler_fadeEnd(null);
	}
	
	private function handler_fadeEnd($evt:EffectEvent):void
	{
		if(_verticalBar && this.contains(_verticalBar)) this.removeChild(_verticalBar);
		if(_horizontalBar && this.contains(_horizontalBar)) this.removeChild(_horizontalBar);
	}
	
	/**
	 * 更新滚动指示条的位置
	 */
	protected function updateScrollBarPos():void
	{
		if(_verticalBar && viewport)
		{
			_verticalBar.y = viewport.verticalScrollPosition/(maxVerticalScrollPosition)*(viewport.height-_verticalBar.height+horizontalBarOffset);
		}
		if(_horizontalBar && viewport)
		{
			_horizontalBar.x = viewport.horizontalScrollPosition/(maxHorizontalScrollPosition)*(viewport.width-_horizontalBar.width+verticalBarOffset);
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Methods: IVisualElementContainer
	//
	//--------------------------------------------------------------------------
	
	public function get numElements():int
	{
		return viewport ? 1 : 0;
	}
	
	public function getElementAt(index:int):IVisualElement
	{
		if (viewport && index == 0)
			return viewport;
		else
			throw new RangeError(resourceManager.getString("components", "indexOutOfRange", [index]));
	}
	
	public function getElementIndex(element:IVisualElement):int
	{
		if (element != null && element == viewport)
			return 0;
		else
			throw ArgumentError(resourceManager.getString("components", "elementNotFoundInScroller", [element]));
	}
	
	public function addElement(element:IVisualElement):IVisualElement
	{
		throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
	}
	
	public function addElementAt(element:IVisualElement, index:int):IVisualElement
	{
		throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
	}
	
	public function removeElement(element:IVisualElement):IVisualElement
	{
		throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
	}
	
	public function removeElementAt(index:int):IVisualElement
	{
		throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
	}
	
	public function removeAllElements():void
	{
		throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
	}
	
	public function setElementIndex(element:IVisualElement, index:int):void
	{
		throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
	}
	
	public function swapElements(element1:IVisualElement, element2:IVisualElement):void
	{
		throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
	}

	public function swapElementsAt(index1:int, index2:int):void
	{
		throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
	}
}
}