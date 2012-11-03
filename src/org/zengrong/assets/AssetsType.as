////////////////////////////////////////////////////////////////////////////////
//  youxi.com
//  创建者:	zrong
//  创建时间：2011-04-23
//  修改时间：2011-10-14
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.assets
{
/**
 * 指定所有外部资源的类型
 * @author zrong
 */
public class AssetsType
{
	//========================================
	// 指示各种资源文件的扩展名或者类型值
	//========================================
	/**
	 * 指示所有的SpriteSheetConvert转换的类型
	 */
	public static const SPRITE_SHEET_FILE:String = "ssf";
	
	/**
	 * 指示载入的类型为通用文件包的常量。专用格式。
	 */
	public static const FILE_PACK:String = "fip";
	
	/**
	 * 指示载入的类型为纯文本包的常量。专用格式。
	 * @see org.zengrong.HeadVO
	 */
	public static const TXT_PACK:String = 'txp';

	/**
	 * 指示载入的类型为spriteSheet包的常量。专用格式。
	 * @see org.zengrong.HeadVO
	 */
	public static const SPRITE_SHEET_PACK:String = 'ssp';

	/**
	 * 指示载入的类型为图像文件包的常量。专用格式。
	 * @see org.zengrong.HeadVO
	 */
	public static const IMAGE_PACK:String = 'imp';

	/**
	 * 指示载入的类型为spriteSheet图片的常量。专用格式。
	 * @see org.zengrong.HeadVO
	 * */
	public static const SPRITE_SHEET:String = 'ss';
	
	/**
	 * 指示载入的类型为mp3文件
	 */	
	public static const MP3:String = 'mp3';

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
	 * 指示载入类型为JPEG-XR图片的常量
	 */
	public static const JPEG_XR:String = 'wdp';
	
	/**
	 * 指示载入类型为gif静态图片的常量。
	 * */
	public static const GIF:String = 'gif';
	
	/**
	 * 指示载入类型为gif动画的常量。
	 * */
	public static const GIF_ANI:String = 'gifAnimation';
	
	/**
	 * 根据文件类型判断文件是否是图像文件
	 */
	public static function isPic($type:String):Boolean
	{
		return $type == AssetsType.PNG || 
				$type == AssetsType.JPG || 
				$type == AssetsType.JPEG_XR || 
				$type == AssetsType.GIF;
	}
	
	/**
	 * 根据文件类型判断文件是否是动画文件
	 */
	public static function isAni($type:String):Boolean
	{
		return $type == AssetsType.SWF || $type == AssetsType.GIF_ANI;
	}
	
	/**
	 * 根据文件类型判断文件是否是可视化的文件 
	 */
	public static function isVisual($type:String):Boolean
	{
		return isPic($type) || isAni($type);
	}

	/**
	 * 根据文件类型判断文件是否是包文件
	 */
	public static function isPack($type:String):Boolean
	{
		return 	$type == TXT_PACK ||
				$type == IMAGE_PACK ||
				$type == FILE_PACK ||
				$type == SPRITE_SHEET_PACK;
	}
}
}
