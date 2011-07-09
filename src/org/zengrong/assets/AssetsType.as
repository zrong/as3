////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-23
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.assets
{
/**
 * 指定所有外部资源的类型
 * @author zrong
 */
public class AssetsType
{
	/**
	 * 指示载入的类型为mp3文件
	 */	
	public static const MP3:String = 'mp3';
	
	/**
	 * 指示载入的类型为spriteSheet图片的常量。
	 * */
	public static const SPRITE_SHEET:String = 'ss';
	
	/**
	 * 指示在如类型为swf动画的常量。
	 * */
	public static const SWF:String = 'swf';
	
	/**
	 * 指示载入的类型为png图片的常量。
	 * */
	public static const PNG:String = 'png';
	
	/**
	 * 指示载入类型为jpeg图片的常量。
	 * */
	public static const JPG:String = 'jpg';
	
	/**
	 * 指示载入类型为gif静态图片的常量。
	 * */
	public static const GIF:String = 'gif';
	
	/**
	 * 指示载入类型为gif动画的常量。
	 * */
	public static const GIF_ANI:String = 'gifAnimation';
	
	
	public static function isPic($type:String):Boolean
	{
		return $type == AssetsType.PNG || 
				$type == AssetsType.JPG || 
				$type == AssetsType.GIF;
	}
	
	public static function isAni($type:String):Boolean
	{
		return $type == AssetsType.SWF || $type == AssetsType.GIF_ANI;
	}
	
	public static function isVisual($type:String):Boolean
	{
		return isPic($type) || isAni($type);
	}
}
}
