package org.zengrong.flex.components
{
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.system.Capabilities;

import mx.core.mx_internal;
import mx.events.EffectEvent;

import org.zengrong.events.TouchAndGestureEvent;

import spark.effects.ThrowEffect;

use namespace mx_internal;
/**
 * 在SimpleScroller的基础上实现抛的功能
 * @author zrong
 * 创建日期：2012-6-14
 */
public class Scroller extends SimpleScroller
{
	public function Scroller()
	{
		super();
	}
	
	protected var _throwReachedMaximumScrollPosition:Boolean;
	
	protected var _throwFinalVSP:Number;
	
	protected var _throwFinalHSP:Number;
	
	/**
	 * 实现抛效果的Effect，这是一个内置的Effect
	 */
	protected var _throwEffect:ThrowEffect;
	
	protected var _preventThrows:Boolean = false;
	
	
	/**
	 * 减速效果，如果需要更快的减速，可以使用0.990
	 */
	protected var _throwEffectDecelFactor:Number = 0.998;
	
	
	/**
	 * 优先停止
	 */
	protected var _stoppedPreemptively:Boolean = false;
	
	/**
	 * 是否禁止抛动作
	 */
	[Bindable]
	public function get preventThrows():Boolean
	{
		return _preventThrows;
	}
	
	/**
	 * @private
	 */
	public function set preventThrows($value:Boolean):void
	{
		_preventThrows = $value;
	}

	
	/**
	 * 在Scroller范围内按下鼠标的时候的事件
	 */
	override protected function handler_mouseDown(event:MouseEvent):void
	{
		//如果追踪动画正在播放，需要在开始新的交互之前停止它
		stopThrowEffectOnMouseDown();
		super.handler_mouseDown(event);
	}
	
	override protected function touchScrolling_captureMouseHandler($event:MouseEvent):void
	{
		if($event.type == MouseEvent.MOUSE_DOWN)
		{
		// If we get a mouse down when the throw animation is within a few
		// pixels of its final destination, we'll go ahead and stop the 
		// touch interaction and allow the event propogation to continue
		// so other handlers can see it.  Otherwise, we'll capture the 
		// down event and start watching for the next scroll.
		
		//如果在抛效果到达目标点前发生了鼠标按下事件
		//我们需要停止touch响应，并允许事件继续传播
		//否则，我们捕获MouseDown事件并开始观察下一次滚动
		
		// 5 pixels at 252dpi worked fairly well for this heuristic.
		const THRESHOLD_INCHES:Number = 0.01984; // 5/252 
		
		var __captureThreshold:Number = Math.round(THRESHOLD_INCHES * Capabilities.screenDPI);
		
		//需要转换增量到本地系统
		__captureThreshold = globalToLocal(new Point(__captureThreshold,0)).subtract(globalToLocal(ZERO_POINT)).x;
		
		if (_captureNextMouseDown &&  
			(Math.abs(viewport.verticalScrollPosition - _throwFinalVSP) > __captureThreshold || 
				Math.abs(viewport.horizontalScrollPosition - _throwFinalHSP) > __captureThreshold))
		{
			//捕获mouseDown事件
			stopThrowEffectOnMouseDown();
			
			// Watch for a scroll to begin.  The helper object will call our
			// performDrag and performThrow callbacks as appropriate.
			_touchScrollHelper.startScrollWatch(
				$event,
				canScrollHorizontally,
				canScrollVertically,
				Math.round(_minSlopInches * Capabilities.screenDPI), 
				MAX_DRAG_RATE);
			$event.stopImmediatePropagation();
		}
		else
		{
			//停止当前的抛事件并允许down事件继续进行标准传播
			if (_throwEffect && _throwEffect.isPlaying)
			{
				_throwEffect.stop();
				snapContentScrollPosition();
			}
		}
		}
		else super.touchScrolling_captureMouseHandler($event);
	}
	
	
	/**
	 * 做抛效果执行期间，鼠标按下。这时需要停止抛效果
	 */
	private function stopThrowEffectOnMouseDown():void
	{
		if (_throwEffect && _throwEffect.isPlaying)
		{
			//停止抛效果。不用移动到目标值，我们希望在鼠标按下的地方停止
			_stoppedPreemptively = true;
			_throwEffect.stop();
			
			// Snap the scroll position to the content in case the empty space beyond the edge was visible
			// due to bounce/pull.
			snapContentScrollPosition();
			
			//更新当前的滚动值，用于下一次滚动
			_hspBeforeTouchScroll = viewport.horizontalScrollPosition;
			_vspBeforeTouchScroll = viewport.verticalScrollPosition;
		}
	}
	
	/**
	 * 在抛事件的时候被helper调用
	 * @param $velocityX
	 * @param $velocityY
	 */	
	override protected function performThrow($velocityX:Number, $velocityY:Number):void
	{
		//如果明确的阻止抛动作，或者处于画面之外，或者锁定了某个方向，停止抛动作
		if (_preventThrows || 
			!stage || 
			(lockHorizontalScroll && _isLockHorizontalScroll) ||
			(lockVerticalScroll && _isLockVerticonalScroll))
		{
			_touchScrollHelper.endTouchScroll();
			return;
		}
		//trace('performThrow:', $velocityX, $velocityY);
		_stoppedPreemptively = false;
		
		//我们先放大速率,然后在调用了globalToLocal之后再缩小它。
		//这么做的原因是运行时提供给我们的值在0.05附近，这个速率非常小，我们不应该丢失它的精度。
		//这个转换是为了保护速率值的精度
		var __throwVelocity:Point = new Point($velocityX, $velocityY);
		__throwVelocity.x *= 100000;
		__throwVelocity.y *= 100000;
		
		//因为我们减去了两个坐标系之间的不同所以本质上是在缩放系数。
		__throwVelocity = 
			this.globalToLocal(__throwVelocity).subtract(this.globalToLocal(ZERO_POINT));
		
		__throwVelocity.x /= 100000;
		__throwVelocity.y /= 100000;
		
		if (setUpThrowEffect(__throwVelocity.x, __throwVelocity.y))
			_throwEffect.play();
	}
	
	/**
	 *  设置抛动画的效果
	 */
	private function setUpThrowEffect($velocityX:Number, $velocityY:Number):Boolean
	{
		if (!_throwEffect)
		{
			_throwEffect = new ThrowEffect();
			//_throwEffect.target = viewport;
			_throwEffect.addEventListener(EffectEvent.EFFECT_END, throwEffect_effectEndHandler);
			_throwEffect.addEventListener(EffectEvent.EFFECT_UPDATE, throwEffect_effectupdateHandler);
		}
		_throwEffect.target = viewport;
		
		var __minHSP:Number = _minHorizontalScrollPosition;
		var __minVSP:Number = _minVerticalScrollPosition;
		//		var __maxHSP:Number = _maxHorizontalScrollPosition;
		//		var __maxVSP:Number = _maxVerticalScrollPosition;
		var __maxHSP:Number = maxHorizontalScrollPosition;
		var __maxVSP:Number = maxVerticalScrollPosition;
		
		_throwEffect.propertyNameX = canScrollHorizontally ? HORIZONTAL_SCROLL_POSITION : null;
		_throwEffect.propertyNameY = canScrollVertically ? VERTICAL_SCROLL_POSITION : null;
		_throwEffect.startingVelocityX = $velocityX;
		_throwEffect.startingVelocityY = $velocityY;
		_throwEffect.startingPositionX = viewport.horizontalScrollPosition;
		_throwEffect.startingPositionY = viewport.verticalScrollPosition;
		_throwEffect.minPositionX = __minHSP;
		_throwEffect.minPositionY = __minVSP;
		_throwEffect.maxPositionX = __maxHSP;
		_throwEffect.maxPositionY = __maxVSP;
		_throwEffect.decelerationFactor = _throwEffectDecelFactor;
		
		// In snapping mode, we need to ensure that the final throw position is snapped appropriately.
		_throwEffect.finalPositionFilterFunction = null; 
		
		//trace(__minHSP, __minVSP, __maxHSP, __maxVSP);
		
		_throwReachedMaximumScrollPosition = false;
		if (_throwEffect.setup())
		{
			_throwFinalHSP = _throwEffect.finalPosition.x;
			if (canScrollHorizontally && _throwFinalHSP == maxHorizontalScrollPosition)
				_throwReachedMaximumScrollPosition = true;
			_throwFinalVSP = _throwEffect.finalPosition.y;
			if (canScrollVertically && _throwFinalVSP == maxVerticalScrollPosition)
				_throwReachedMaximumScrollPosition = true;
			//准备超域事件
			var __beyondEvt:TouchAndGestureEvent = new TouchAndGestureEvent(TouchAndGestureEvent.BEYOND);
			//如果抛目标大于最大拖动范围，就认为是超域
			if(_throwFinalHSP == 0)
			{
				__beyondEvt.velX = -1;
			}
			else if(_throwFinalHSP >= maxHorizontalScrollPosition)
			{
				__beyondEvt.velX = 1;
			}
			if(_throwFinalVSP == 0)
			{
				__beyondEvt.velY = -1;
			}
			else if(_throwFinalVSP >= maxVerticalScrollPosition)
			{
				__beyondEvt.velY = 1;
			}
			checkBeyond(__beyondEvt);
			//trace('throw:', _throwFinalHSP, _throwFinalVSP, maxHorizontalScrollPosition, maxVerticalScrollPosition);
		}
		else
		{
			_touchScrollHelper.endTouchScroll();
			return false;
		}
		return true;
	}
	
	private function throwEffect_effectupdateHandler($evt:EffectEvent):void
	{
		//trace('effect_updateHandler');
		updateScrollBarPos();
	}
	
	private function throwEffect_effectEndHandler(event:EffectEvent):void
	{
		//如果由于按下鼠标停止了抛效果，就不再处理touch
		//拖动效果仍然有作用，用户依然可以拖动滚动（不是抛）
		//如果结束了touch，那么拖动效果就会失效
		if (_stoppedPreemptively) return;
		
		_touchScrollHelper.endTouchScroll();
	}
	
	
	/**
	 *  @private
	 *  Snap the scroll positions to valid values.
	 */
	private function snapContentScrollPosition(snapHorizontal:Boolean = true, snapVertical:Boolean = true):void
	{
		// Note that we only snap the scroll position if content is present.  This allows existing scroll position
		// values to be retained before content is added or when it is removed/readded.
		//		if (snapHorizontal && viewport.contentWidth != 0)
		//		{
		//			viewport.horizontalScrollPosition = getSnappedPosition( 
		//				Math.min(Math.max(_minHorizontalScrollPosition, viewport.horizontalScrollPosition), _maxHorizontalScrollPosition),
		//				HORIZONTAL_SCROLL_POSITION);
		//		}
		//		
		//		if (snapVertical && viewport.contentHeight != 0)
		//		{
		//			viewport.verticalScrollPosition = getSnappedPosition( 
		//				Math.min(Math.max(_minVerticalScrollPosition, viewport.verticalScrollPosition), _maxVerticalScrollPosition),
		//				VERTICAL_SCROLL_POSITION);
		//		}
	}
}
}