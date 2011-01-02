////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-12-22
//	说明：本组件参照Keith Peters的Minimalcomps组件写成，修改、使用或继承Minimalcal源码
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.controls
{

import flash.display.Bitmap;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

import org.zengrong.controls.supportClasses.DisplayObjectButtonBase;

/**
 * @eventType timerComplete
 */
[Event(name="timerComplete",type="flash.events.TimerEvent")]
/**
 * 用于游戏中的带有冷却功能的按钮，按下后必须经过一段冷却时间才能再次使用。
 * @author zrong
 */
public class CDImageButton extends ImageButton
{
	/**
	 * 用于指定线性动画的值 
	 */	
	public static const ANI_LINEAR : String = "linear";
	
	/**
	 * 用于指定放射状动画的值
	 */	
	public static const ANI_RADIAL : String = "radial"
		
	//计时器的步进
	private static const DELAY:int = 100;
	private static const MASK_ALPHA:Number = .6;
	private static const MASK_COLOR:uint = 0x000000;
	
	public function CDImageButton(parent:DisplayObjectContainer, upStateImage:Bitmap, coolDownTime:int=5000, aniType:String='radial', defaultHandler:Function=null, btnid:int=-1)
	{
		_cdt = coolDownTime;
		_aniType = aniType;
		_btnid = btnid;
		//CDImageButton只是用一张图片
		super(upStateImage, null, null, parent, 0, 0, defaultHandler);
		if(coolDownTime < DELAY)
			throw new RangeError('冷却时间不能小于'+DELAY+'毫秒！');
	}
	
	private var _btnid:int;		//按钮的id
	private var _cdt:int;			//冷却时间，单位是毫秒
	private var _repeatCount:int;	//动画绘制的总次数
	private var _radius:int;		//radial动画效果绘制半径
	private var _aniType:String;	//动画效果类型，值为ANI_LINEAR或ANI_RADIAL
	
	private var _commands:Vector.<int>;			//绘制radial类型的动画的命令数组
	private var _vectors:Vector.<Number>;		//绘制radial类型的的动画的坐标数组
	private var _tmp_commands:Vector.<int>;		//绘制过程中需要的临时命令数组
	private var _tmp_vectors:Vector.<Number>;	//绘制过程中需要的临时坐标数组
	
	private var _timer:Timer;
	private var _center:Point;
	
	private var _maskBody:Shape;	//用于覆盖在按钮上方显示半透明效果的Shape
	private var _ani:Shape;			//用于显示动画的Shape
	
	//----------------------------------
	//  getter/setter
	//----------------------------------
	
	public function get btnid():int
	{
		return _btnid;
	}
	
	public function set btnid($id:int):void
	{
		_btnid = $id
	}
	/**
	 * 当前的按钮是否处于CD动画过程中
	 */	
	public function get running():Boolean
	{
		return _timer.running;
	}
	
	/**
	 * 重新设置冷却时间
	 * @param $cdt 冷却时间，单位是秒
	 */	
	public function set coolDownTime($cdt:int):void
	{
		if($cdt < DELAY)
			throw new RangeError('冷却时间不能小于'+DELAY+'毫秒！');
		//停止目前的动画，清空蒙版效果
		_timer.reset();
		handler_timerComplete(new TimerEvent(TimerEvent.TIMER_COMPLETE));
		if($cdt == _cdt)
			return;
		//重新按照cd时间计算重复次数
		_cdt = $cdt;
		_repeatCount = getRepeatCount();
		_timer.repeatCount = _repeatCount;
		if(_aniType == ANI_RADIAL)
			initRadial();
	}
	
	/**
	 * 重新设置冷却动画类型
	 * @param $type 动画类型字符串，值为ANI_LINEAR或ANI_RADIAL
	 */	
	public function set aniType($type:String):void
	{
		//停止目前的动画，清空半透明效果
		_timer.reset();
		handler_timerComplete(new TimerEvent(TimerEvent.TIMER_COMPLETE));
		if($type == _aniType)
			return;
		_aniType = $type;
		if(_aniType == ANI_LINEAR)
		{
			_ani.x = _ani.y = 0;
		}
		else if(_aniType == ANI_RADIAL)
		{
			initRadial();
		}
	}
	
	/**
	 * 不支持selected
	 */	
	override public function get selected():Boolean
	{
		return false;
	}
	
	override public function set selected(value:Boolean):void
	{
	}
	
	/**
	 * 不支持toggle
	 */	
	override public function get toggle():Boolean
	{
		return false;
	}
	
	override public function set toggle(value:Boolean):void
	{
	}
	
	override public function set enabled(value:Boolean):void
	{
		_enabled = value;
		mouseEnabled = mouseChildren = _enabled;
		tabEnabled = value;
		//如果启用按钮，就隐藏并清空蒙版，否则就初始化蒙版。
		if(_enabled)
		{
			_maskBody.graphics.clear();
			_maskBody.visible = false;
			_ani.graphics.clear();
			_ani.visible = false;
		}
		else
			drawInitMask();
	}
	
	/**
	 * 获取动画计时器的重复次数。使用冷却时间与DELAY进行计算。 
	 */	
	public function getRepeatCount():int
	{
		return _cdt / DELAY;
	}
	
	//----------------------------------
	//  被外部调用的公有方法
	//----------------------------------
	/**
	 * 开始计算冷却时间，禁用按钮，并绘制冷却动画。
	 */	
	public function start():void
	{
		if(_timer.running)
			return;
		_timer.reset();
		_timer.start();
		enabled = false;
		if(_aniType == ANI_RADIAL)
		{
			//复制两个绘制数据数组
			_tmp_commands = _commands.concat();
			_tmp_vectors = _vectors.concat();
		}
	}
	
	/**
	 * 停止和重置冷却时间计时器
	 */	
	public function stop():void
	{
		_timer.reset();
	}
	
	//----------------------------------
	//  覆盖父类的方法
	//----------------------------------
	override protected function init():void
	{
		super.init();
		
		_repeatCount = getRepeatCount(); 
		
		_timer = new Timer(DELAY, _repeatCount);
		_timer.addEventListener(TimerEvent.TIMER, handler_timer);
		_timer.addEventListener(TimerEvent.TIMER_COMPLETE, handler_timerComplete);
		
		if(_aniType == ANI_RADIAL)
			initRadial();
	}
	
	override protected function addChildren():void
	{
		super.addChildren();
		_maskBody = new Shape();
		_maskBody.visible = false;
		this.addChild(_maskBody);
		_ani = new Shape();
		_ani.visible = false;
		this.addChild(_ani);
		_maskBody.mask = _ani;
	}
	
	override protected function onMouseGoUp(event:MouseEvent):void
	{
		super.onMouseGoUp(event);
		start();
	}
	
	//----------------------------------
	//  handler
	//----------------------------------
	/**
	 * 绘制冷却动画效果 
	 */	
	private function handler_timer(evt:TimerEvent):void
	{
		if(_aniType == ANI_LINEAR)
		{
			drawLinearMask(_timer.repeatCount - _timer.currentCount, _timer.repeatCount);
		}
		else
		{
			drawRadialMask(_tmp_commands, _tmp_vectors);
			//每次绘制后，从数组最后减去一个坐标点
			_tmp_commands.pop();
			_tmp_vectors.splice(_tmp_vectors.length-2, 2);
		}
	}
	
	/**
	 * 冷却时间过去，重新启用按钮
	 */	
	private function handler_timerComplete(evt:TimerEvent):void
	{
		enabled = true;
		this.dispatchEvent(evt);
	}
	
	//----------------------------------
	//  内部调用的私有方法
	//----------------------------------
	
	/**
	 * 初始化Radial类型的动画需要的变量
	 */	
	private function initRadial():void
	{
		_radius = this.width;
		
		_center = new Point(this.width/2, this.height/2) 
		_ani.x = _center.x;
		_ani.y = _center.y;
		
		//初始化给出第一个坐标点，由于已经将Shape移动到了父显示对象中心点，这里就不需要moveTo命令，直接从0,0开始画
		_commands = Vector.<int>([2]);
		_vectors = Vector.<Number>([0, _radius]);
		//根据计时器的次数计算绘制过程中需要的所有坐标
		for(var i:int=1; i<=_repeatCount; i++)
		{
			//var __radian:Number = (i/repeatCount*360)*Math.PI/180;
			var __radian:Number = i/_repeatCount*Math.PI*2;
			var __x:Number = Math.sin(__radian)*_radius;
			var __y:Number = Math.cos(__radian)*_radius;
			_commands.push(2);
			_vectors.push(__x, __y);
		}
	}
	
	/**
	 * 绘制线性动画的方法，使用两个参数来计算现在应该绘制到百分之几。
	 * @param $current	计数器的当前次数
	 * @param $total	计数器的总次数
	 */	
	private function drawLinearMask($current:int, $total:int):void
	{
		var __percent:Number = $current/$total;
		_ani.graphics.clear();
		_ani.graphics.beginFill(MASK_COLOR, MASK_ALPHA);
		_ani.graphics.drawRect(0, 0, width, height*__percent);
		_ani.graphics.endFill();
	}
	
	/**
	 * 绘制放射状动画的方法，使用
	 * @param $commands	绘制命令
	 * @param $vectors	绘制顶点
	 */	
	private function drawRadialMask($commands:Vector.<int>, $vectors:Vector.<Number>):void
	{
		_ani.graphics.clear();
		_ani.graphics.beginFill(MASK_COLOR, MASK_ALPHA);
		_ani.graphics.drawPath($commands, $vectors);
		_ani.graphics.endFill();
	}
	
	/**
	 * 绘制蒙版效果的初始化状态
	 */	
	private function drawInitMask():void
	{
		_maskBody.visible = true;
		_ani.visible = true;
		//绘制一个矩形作为放射动画的蒙版，因为要显示的部分就是一个矩形
		_maskBody.graphics.clear();
		_maskBody.graphics.beginFill(MASK_COLOR, MASK_ALPHA);
		_maskBody.graphics.drawRect(0, 0, this.width, this.height);
		_maskBody.graphics.endFill();
		if(_aniType == ANI_LINEAR)
		{
			drawLinearMask(_repeatCount, _repeatCount);
		}
		else
		{
			//绘制一个正圆，作为初始的效果
			_ani.graphics.clear();
			_ani.graphics.beginFill(MASK_COLOR);
			_ani.graphics.drawCircle(0, 0, _radius);
			_ani.graphics.endFill();
		}
	}
}
}