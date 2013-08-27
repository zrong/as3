////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-11
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.bmp
{
import flash.display.BitmapData;
/**
 * 带有Label支持的BMPMovableSprite
 * @author zrong
 */
public class BMPMovieClip extends BMPMovableSprite
{
	/**
	 * 针对翻转的图片的label名称后缀
	 */
	public static const LABEL_FLIP_POSTFIX:String = '_flip';
	public static const NO_LABEL:String = 'no_label';

	/**
	 * @param $hasFlip 是否包含翻转图像
	 */
	public function BMPMovieClip($hasFlip:Boolean=false, $autoCenterOffset:Boolean=false)
	{
		super(null, $hasFlip, $autoCenterOffset);
	}
	
	private var _label:String;

	//以label为键名保存bmd列表
	private var _labelsList:Object;

	//----------------------------------------
	// init
	//----------------------------------------
	
	override public function init():void
	{
		super.init();
		_labelsList = {};
	}

	//----------------------------------------		
	// getter/setter
	//----------------------------------------
	
	
	public function get label():String
	{
		return _label;
	}

	/**
	 * 根据label的值更新图像列表
	 * @throw RangeError 如果提供的label不存在，抛出此异常
	 */
	public function set label($label:String):void
	{
		//根据label更新图像列表
		if($label in _labelsList)
		{
			_label = $label;
			_bmds = getListByLabel($label);
			//同时更新翻转的图像列表
			if(hasFlip)
			{
				var __flipLabel:String = _label + LABEL_FLIP_POSTFIX;
				if(__flipLabel in _labelsList)
				{
					_flipBmds = getListByLabel(__flipLabel);
				}
				else
				{
					throw new RangeError('没有名为'+$label+'的label！');
				}
			}
			//设置label后，更新中点位置。由于这时bitmapData可能不是最新的，而现在也不应该更新bitmapData，否则会导致显示错误
			//因此这里直接计算最新的bitmapData的长宽偏移值
			var __bmd:BitmapData = getFrame( 0 );
			setCenterOffset( __bmd.width*xOffsetFactor, __bmd.height*yOffsetFactor );
		}
		else
			throw new RangeError('没有名为'+$label+'的label！');
	}	

	public function getListByLabel($label:String):Vector.<BitmapData>
	{
		return _labelsList[$label];
	}

	//----------------------------------------		
	// public
	//----------------------------------------
	
	public function addLabel($label:String, $bmds:Vector.<BitmapData>):void
	{
		_bmds = $bmds;
		_labelsList[$label] = _bmds;
		trace('addLabel,hasFlip:', hasFlip);
		//如果需要翻转，就根据当前的图像计算翻转，在label名称后加上后缀，再存入label列表
		if(hasFlip)
		{
			_flipBmds = null;
			reFlip();
			_labelsList[$label + LABEL_FLIP_POSTFIX] = _flipBmds;
			trace('fipBmds:', _flipBmds.length);
			_flipBmds = null;
		}
		_bmds = null;
	}

	public function removeLabel($label:String):void
	{
		delete _labelsList[$label];
		delete _labelsList[$label + LABEL_FLIP_POSTFIX];
	}
}
}
