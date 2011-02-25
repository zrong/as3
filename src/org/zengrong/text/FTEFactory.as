////////////////////////////////////////////////////////////////////////////////
//  youxi.com
//  创建者:	zrong
//  创建时间：2011-02-25
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.text
{
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.TextBaseline;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;

/**
 * 关于FTE的一些创建工厂，因为直接用FTE要建很多对象，很麻烦。
 * @author zrong
 */
public class FTEFactory
{
	/**
	 * 创建一个单行的TextLine
	 * @param $str 文本内容
	 * @param $width 文本宽度
	 * @return 单行的TextLine
	 */	
	public static function createSingleTextLine($str:String, $width:Number, $color:uint=0x000000, $size:int=12, $font:FontDescription=null):TextLine
	{
		if(!$font)
			$font = new FontDescription('Microsoft YaHei', 'bold');
		var __ef:ElementFormat = new ElementFormat($font);
		__ef.color = $color;
		__ef.fontSize = $size;
		var __tb:TextBlock = new TextBlock(new TextElement($str, __ef));
		return __tb.createTextLine(null, $width);
	}
}
}