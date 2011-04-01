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
		
	
	/**
	 * CD效果蒙版的透明度
	 */		
	public static var MASK_ALPHA:Number = .2;
	
	/**
	 * CD效果蒙版的颜色
	 */	
	public static var MASK_COLOR:uint = 0x000000;
	
	/**
	 * 禁用效果蒙版的颜色
	 */	
	public static var ENABLED_MASK_COLOR:uint = 0x000000;
	
	/**
	 * 禁用效果蒙版的透明度
	 */	
	public static var ENABLED_MASK_ALPHA:Number = .3;
		
	//计时器的步进
	private static const DELAY:int = 100;
	
	/**
	 * 构造函数
	 * @param parent			父显示对象，若提供则将按钮直接加入其中，不提供可传递null
	 * @param upStateImage		按钮up状态的Bitmap
	 * @param coolDownTime		按钮的冷却时间，单位毫秒
	 * @param aniType			按钮冷却效果动画，值为linear或radial，默认为radial
	 * @param defaultHandler	按钮的事件处理器
	 * @param clickStart 		是否在按钮上单击鼠标的时候，自动开始CD
	 * @param btnid				按钮的id
	 */	
	public function CDImageButton(parent:DisplayObjectContainer, upStateImage:Bitmap, coolDownTime:int=5000, aniType:String='radial', defaultHandler:Function=null, clickStart:Boolean=true, btnid:int=-1)
	{
		_cdt = coolDownTime;
		_aniType = aniType;
		_btnid = btnid;
		_clickStart = clickStart;
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
	private var _clickStart:Boolean;	//是否在按钮上单击鼠标的时候，自动开始CD
	
	private var _commands:Vector.<int>;		//绘制radial类型的动画的命令数组
	private var _vectors:Vector.<Number>;		//绘制radial类型的的动画的坐标数组
	private var _tmp_commands:Vector.<int>;	//绘制过程中需要的临时命令数组
	private var _tmp_vectors:Vector.<Number>;	//绘制过程中需要的临时坐标数组
	
	private var _timer:Timer;
	private var _center:Point;
	
	private var _cdMask:Shape;		//用于覆盖在按钮上方显示半透明CD效果的Shape
	private var _cdAni:Shape;		//用于显示CD动画的Shape
	private var _enabledMask:Shape;	//用于显示禁用和启用效果的Shape
	
	//----------------------------------
	//  初始化的方法
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
		this.addEventListener(MouseEvent.CLICK, onMouseClick);
	}
	
	override protected function addChildren():void
	{
		super.addChildren();
		_cdMask = new Shape();
		_cdMask.visible = false;
		this.addChild(_cdMask);
		_cdAni = new Shape();
		_cdAni.visible = false;
		this.addChild(_cdAni);
		_cdMask.mask = _cdAni;
		//启用禁用效果的shape，这个初始化一次就可以了
		_enabledMask = new Shape();
		_enabledMask.graphics.beginFill(ENABLED_MASK_COLOR, ENABLED_MASK_ALPHA);
		_enabledMask.graphics.drawRect(0, 0, this.width, this.height);
		_enabledMask.graphics.endFill();
		_enabledMask.visible = false;
		this.addChild(_enabledMask);
	}
	
	//----------------------------------
	//  getter/setter
	//----------------------------------
	
	public function get btnid():int
	{
		return _btnid;
	}
	
	public function set btnid($id:int):void
	{
		_btnid = $id;
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
			_cdAni.x = _cdAni.y = 0;
		}
		else if(_aniType == ANI_RADIAL)
		{
			initRadial();
		}
	}
	
	/**
	 * 设置按钮是否在单击的时候自动启动CD动画效果
	 * @param $isClick
	 */	
	public function set clickStart($isClick:Boolean):void
	{
		_clickStart = $isClick;
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
		//如果启用按钮，就隐藏并清空蒙版，否则就初始化蒙版。
		if(value)
		{
			_enabledMask.visible = false;
			//CD运行过程中，仅取消蒙版显示，但不处理启用按钮的操作
			if(running)
				return;
		}
		else
		{
			_enabledMask.visible = true;
		}
		trace(btnid, '启用：', value);
		setInteract(value);
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
		if(running)
			return;
		_timer.reset();
		_timer.start();
		setInteract(false);
		drawCDMask();
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
		clear();
	}
	
	public function clear():void
	{
		trace('clear调用');
		_cdMask.graphics.clear();
		_cdMask.visible = false;
		_cdAni.graphics.clear();
		_cdAni.visible = false;
		//检测禁用蒙版是否显示，如果没有显示就说明在CD过程中，没有设置过enable = false，就可以启用按钮的交互
		if(!_enabledMask.visible)
			setInteract(true);
	}
	
	override public function destroy():void
	{
		super.destroy();
		_timer.removeEventListener(TimerEvent.TIMER, handler_timer);
		_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, handler_timerComplete);
		_timer.reset();
		_timer = null;
		
		_btnid = -1;
		_cdt = -1;
		_repeatCount = -1;
		_radius = -1;
		_aniType = null;
		_clickStart = false;
		
		_commands = null;
		_vectors = null;
		_tmp_commands = null;
		_tmp_vectors = null;
		
		_center = null;
		
		_cdMask = null;
		_cdAni = null;
		_enabledMask = null;
	}
	
	//----------------------------------
	//  handler
	//----------------------------------
	
	protected function onMouseClick(event:MouseEvent):void
	{
		if(_clickStart)
			start();
		else
			enabled = false;
	}
	
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
		//清空CD效果蒙版
		clear();
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
		_cdAni.x = _center.x;
		_cdAni.y = _center.y;
		
		//初始化给出第一个坐标点，由于已经将Shape移动到了父显示对象中心点，这里就不需要moveTo命令，直接从0,0开始画
		//设定lineTo命令
		_commands = Vector.<int>([2]);
		//设定第一个点，12点位置的顶端坐标就是0,radius*-1
		_vectors = Vector.<Number>([0, _radius*-1]);
		//根据计时器的次数计算绘制过程中需要的所有坐标
		for(var i:int=1; i<=_repeatCount; i++)
		{
			//根据循环的次数将一个圆周分成等份，然后计算等份的坐标，下面这个计算会从圆周的6点钟开始绘制CD效果
			//var __radian:Number = i/_repeatCount*(Math.PI*2);
			//下面的计算从12点开始绘制CD效果
			var __radian:Number = (i/_repeatCount)*(Math.PI*2)+Math.PI;
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
		_cdAni.graphics.clear();
		_cdAni.graphics.beginFill(MASK_COLOR, MASK_ALPHA);
		_cdAni.graphics.drawRect(0, 0, width, height*__percent);
		_cdAni.graphics.endFill();
	}
	
	/**
	 * 绘制放射状动画的方法，使用
	 * @param $commands	绘制命令
	 * @param $vectors	绘制顶点
	 */	
	private function drawRadialMask($commands:Vector.<int>, $vectors:Vector.<Number>):void
	{
		_cdAni.graphics.clear();
		_cdAni.graphics.beginFill(MASK_COLOR, MASK_ALPHA);
		_cdAni.graphics.drawPath($commands, $vectors);
		_cdAni.graphics.endFill();
	}
	
	/**
	 * 绘制CD蒙版效果的初始化状态
	 */	
	private function drawCDMask():void
	{
		_cdMask.visible = true;
		_cdAni.visible = true;
		//绘制一个矩形作为放射动画的蒙版，因为要显示的部分就是一个矩形
		_cdMask.graphics.clear();
		_cdMask.graphics.beginFill(MASK_COLOR, MASK_ALPHA);
		_cdMask.graphics.drawRect(0, 0, this.width, this.height);
		_cdMask.graphics.endFill();
		if(_aniType == ANI_LINEAR)
		{
			drawLinearMask(_repeatCount, _repeatCount);
		}
		else
		{
			//绘制一个正圆，作为初始的效果
			_cdAni.graphics.clear();
			_cdAni.graphics.beginFill(MASK_COLOR);
			_cdAni.graphics.drawCircle(0, 0, _radius);
			_cdAni.graphics.endFill();
		}
	}
	
	/**
	 * 设置实际的按钮交互可用性。set enabled要修改按钮的禁用可用的外观，同时还要调用本方法。 
	 * @param $enabled 按钮是否可用
	 */	
	private function setInteract($enabled:Boolean):void
	{
		_enabled = $enabled;
		this.mouseEnabled = this.mouseChildren = this.tabEnabled = _enabled;
	}
}
}