////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-12-07
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;


/**
 * 用位图拼成文字形式用于显示 
 * @author zrong
 */
public class BMPText extends Sprite
{
	/**
	 * 设置所有能显示的字符范围，以及提供代替字符显示用的BitmapData数据。 
	 * @param $allText 所有能显示的字符串
	 * @param $width 字符图片的宽度
	 * @param $height 字符图片的高度
	 * @param $transparent 字符图片是否支持透明
	 * @param $bmds 字符图片数据，可以为一个或多个。<br />
	 * 每个参数都必须是BitmapData类型。<br />
	 * 如果提供的字符图片数据小于$allText的字符数量，则仅使用第一个BitmapData进行切割。<br />
	 * 否则按照提供的参数的数据与$allText字符串中的字符进行对应。
	 */	
	public function BMPText($allText:String='', $width:int=-1, $height:int=-1, $transparent:Boolean=false, $direction:String='horizontal', ...$bmds:Array)
	{
		if($allText && $width>0 && $height>0 && $bmds.length>0)
		{
			var __args:Array = [$allText, $width, $height, $transparent, $direction];
			setBMPAndText.apply(this, __args.concat($bmds));
		}
	}
	
	private var _text:String;		//当前正在显示的字符
	private var _allText:String;	//支持显示的所有字符
	private var _gap:int = 0;		//文字间距
	private var _allTextLength:int;	//支持显示的所有字符的数量
	private var _bmpWidth:int;		//一个文字位图的宽度
	private var _bmpHeight:int;		//一个文字位图的高度
	private var _transparent:Boolean;	//是否透明
	private var _direction:String;		//切割方向
	private var _slice:BMPSlicer;	//用来对长的位图进行切片
	private var _bmdList:Vector.<BitmapData>;	//支持显示的所有字符对应的BitmapData列表
	private var _textIndex:Object;			//保存每个文字的索引
	
	//--------------------------------------------------------------------------
	//
	//  公有方法
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  getter方法
	//----------------------------------
	/**
	 * 获取当前正在显示的字符串。 
	 */	
	public function get text():String
	{
		return _text;
	}
	
	/**
	 * 获取允许显示的所有字符串。 
	 */	
	public function get allText():String
	{
		return _allText;
	}
	
	public function get gap():int
	{
		return _gap;
	}
	
	//----------------------------------
	//  setter方法
	//----------------------------------
	/**
	 * 设置文本位图之间的间隔。 
	 * @param $gap 文本位图之间的间隔。
	 */	
	public function set gap($gap:int):void
	{
		_gap = $gap;
		var __child:int = numChildren;
		for(var i:int=0; i<__child; i++)
		{
			var __dis:DisplayObject = getChildAt(i);
			__dis.x = i * _bmpWidth;
			if(i > 0)
				__dis.x += i*_gap;
		}
	}
	
	/**
	 * 设置显示的文本。
	 * @param $text 要显示的文本。
	 * @throw RangeError 如果参数中的文本中有字符不在允许字符的范围内，就会抛出此异常。
	 */	
	public function set text($text:String):void
	{
		while(numChildren>0)
			removeChildAt(0);
		if(!_allText || !_bmdList)
			return;
		_text = $text;
		var __length:int = _text.length;
		for(var i:int=0; i<__length; i++)
		{
			var __curTxt:String = _text.charAt(i);
			if(_allText.indexOf(__curTxt) == -1)
				throw new RangeError('字符"'+__curTxt+'"不在允许的字符范围内。');
			var __bmp:Bitmap = getTextBMP(__curTxt);
			__bmp.x = i * _bmpWidth;
			//如果不是第一个图片，就加上分隔宽度
			if(i > 0)
				__bmp.x += i*_gap;
			addChild(__bmp);
		}
	}
	
	/**
	 * @copy BMPText#BMPText()
	 */	
	public function setBMPAndText($allText:String, $width:int, $height:int, $transparent:Boolean, $direction:String, ...$bmds:Array):void
	{
		if($allText.length <= 0)
			return;
		if($bmds == null || $bmds.length == 0)
			return;
		_allText = $allText;
		_allTextLength = _allText.length;
		_bmpWidth = $width;
		_bmpHeight = $height;
		_transparent = $transparent;
		_direction = $direction;
		
		_textIndex = {};
		//如果提供的BitmapData的数量小于文本数量，就用第一个BitmapData进行分割
		if($bmds.length < _allTextLength)
		{
			var __bmd1:BitmapData = BitmapData($bmds[0]);
			if(__bmd1.width < _allTextLength*_bmpWidth)
				throw new RangeError('提供的BitmapData的宽度不够切割成'+_allTextLength+'块！');
			_slice = new BMPSlicer(__bmd1, _bmpWidth, _bmpHeight, $transparent, $direction, _allTextLength);
			_bmdList = _slice.slicedBitmapDataList;
			for(var i:int=0; i<_allTextLength; i++)
			{
				//保存对应每个文字的图片的索引
				_textIndex[_allText.charAt(i)] = i;
			}
		}
		//否则就认为每个参数都是一个与文本对应的BitmapData
		else
		{
			_bmdList = new Vector.<Bitmap>(_allTextLength, true);
			for(var j:int=0; j<_allTextLength; j++)
			{
				_bmdList[j] = BitmapData($bmds[j]);
				//保存对应每个文字的图片的索引
				_textIndex[_allText.charAt(j)] = j;
			}
		}
	}
	
	/**
	 * 使用当前的数据复制一个BMPText
	 */	
	public function duplicate():BMPText
	{
		var __bmpt:BMPText = new BMPText();
		var __param:Array = [_allText, _bmpWidth, _bmpHeight, _transparent, _direction];
		__bmpt.setBMPAndText.apply(__bmpt, __param.concat(_bmdList));
		__bmpt.gap = _gap;
		__bmpt.text = _text;
		return __bmpt;
	}
	
	private function getTextBMP($txt:String):Bitmap
	{
		var __index:int = _textIndex[$txt];
		return new Bitmap(_bmdList[__index]);
	}
}
}