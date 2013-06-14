package org.zengrong.display.spritesheet
{
import flash.geom.Rectangle;

/**
 * SpriteSheet元数据接口，实现SpriteSheetMetadata的所有方法
 * @author zrong (http://zengrong.net)
 * 创建日期：2013-4-5
 */
public interface ISpriteSheetMetadata
{
	
	/**
	 * Sheet的类型，见SpriteSheetType
	 */	
	function get type():String;
	
	/**
	 * @private
	 */
	function set type($value:String):void;
	
	/**
	 * 是否包含Label，Label信息用于分段动画 
	 */	
	function get hasLabel():Boolean;
	
	/**
	 * @private
	 */
	function set hasLabel($value:Boolean):void;
	
	/**
	 * 是否包含名称信息，即对每一帧都使用了名称
	 */	
	function get hasName():Boolean;
	
	/**
	 * @private
	 */
	function set hasName($value:Boolean):void;
	
	/**
	 * mask的类型，详见org.zengrong.display.spritesheet.MaskType。mask信息只能存在于JPG文件中
	 */	
	function get maskType():int;
	
	/**
	 * @private
	 */
	function set maskType($value:int):void;
	
	/**
	 * Sheet的所有Label名称
	 */	
	function get labels():Vector.<String>;
	
	/**
	 * @private
	 */
	function set labels($value:Vector.<String>):void;
	
	/**
	 * 每个Label的的帧范围，键名是Label，键值是一个数组，第一个元素为开始帧（0基），第二个元素为该Label总帧数
	 */	
	function get labelsFrame():Object;
	
	/**
	 * @private
	 */
	function set labelsFrame($value:Object):void;
	
	/**
	 * 如果使用名称来指定每一帧，则这里保存所有名字的数组
	 */	
	function get names():Vector.<String>;
	
	/**
	 * @private
	 */
	function set names($value:Vector.<String>):void;
	
	/**
	 * 如果使用名称来指定每一帧，则这里保存每个名称与帧的对应关系
	 */	
	function get namesIndex():Object;
	
	/**
	 * @private
	 */
	function set namesIndex($value:Object):void;
	
	/**
	 * 每帧在整个大的Sheet中的位置和尺寸
	 * 这并非是最终在大的Sheet中体现出来的位置和尺寸。而是是未修剪之前的尺寸。也就是最终要在程序中使用的尺寸。
	 * 因为如果执行了修剪，那么在大的Sheet中只会保存有效像素（空白的边缘被修建掉了）。
	 * 而在还原到程序中的时候，还是必须使用原来的Rect大小的（因为要考虑到动作的外延范围）。
	 * 这个Vector中保存的始终都是在程序使用时候的Rect。
	 */	
	function get frameRects():Vector.<Rectangle>;
	
	/**
	 * @private
	 */
	function set frameRects($value:Vector.<Rectangle>):void;
	
	/**
	 * 每帧原始的Rect，基于frameRect保存修剪信息
	 * 例如，对frameRect进行了修剪操作，修剪的上下左右的值均为10像素。修剪后的frameRect为(0,0,50,50)
	 * 那么originalFrameRect则为(-10,-10,70,70)
	 * 如果frameRect没有经过修剪，则这个rect的w和h值与frameRect中的对应元素相等，但x和y为0
	 */
	function get originalFrameRects():Vector.<Rectangle>;
	
	/**
	 * @private
	 */
	function set originalFrameRects($value:Vector.<Rectangle>):void;
	
	/**
	 * Sheet的帧数
	 */	
	function get totalFrame():int;
	
	/**
	 * 返回自身的副本（深复制）
	 */
	function clone():ISpriteSheetMetadata;
	
	/**
	 * 根据设置的属性初始化一些值
	 * 
	 * @param $force 是否强制初始化。值为true则不判断原来是否存在该变量，强行覆盖
	 */	
	function setup($force:Boolean=false):void;
	
	/**
	 * 销毁整个对象
	 */	
	function destroy():void;
	
	/**
	 * 将传递的数据解析成元数据对象，保存在自身当中，同时返回
	 */
	function parse($value:*):ISpriteSheetMetadata;
	
	/**
	 * 将自身数据对象化
	 * 
	 * @param $isSimple 是否简单数据
	 * @param $includeName 是否包含name
	 * @param ...$args 其他参数
	 * @return 返回的可能是任何类型的数据
	 */
	function objectify($isSimple:Boolean=false, $includeName:Boolean=true, ...$args):*;
	
	/**
	 * 增加一个Label
	 * @param $labelName 要增加的Label的名称
	 * @param $labelFrame 要增加的Label的帧索引
	 */	
	function addLabel($labelName:String, $labelFrame:Array):void;
	
	/**
	 * 设置Label的属性
	 * 
	 * @param $hasLabel	是否使用了Label
	 * @param $labels	Label的对象，每个键名为label名称，每个键值是数组，保存帧的索引号，格式为:[1,2,3]
	 */	
	function setLabels($hasLabel:Boolean, $labels:Object=null):void;
	
	/**
	 * 从外部向数组中添加帧的尺寸，一般在循环中执行
	 */	
	function addFrame($sizeRect:Rectangle, $originalRect:Rectangle=null, $name:String=null):void;
	
	/**
	 * 从外部向数组中添加帧的尺寸，指定帧索引
	 */
	function addFrameAt($index:int, $sizeRect:Rectangle, $originalRect:Rectangle=null, $name:String=null):void;
	
	/**
	 * 从指定的索引移除帧
	 */
	function removeFrameAt($index:int):void;
	
	/**
	 * 返回帧索引对应的帧名称。如果选择了不保存名称，或者没有名称，或者该帧没有对应名称，就返回null
	 * 
	 * @param $includeName 是否包含名称
	 * @param $index 帧索引
	 */	
	 function getFrameName($includeName:Boolean, $index:int):String;
	 
	 /**
	  * 直接调用objectify方法，传递的参数均为true
	  * @return
	  */
	 function toString():String;
}
}