////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-11
//  修改时间：2012-10-15
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.spritesheet
{
/**
 * 定义SpriteSheet的类型
 * <p>
 * SpriteSheet的类型与SpriteSheetMetadata的类型并不一样。<br>
 * 前者指明SpriteSheet是否是嵌入metadata，以及使用什么图像格式。<br>
 * 要了解使用何种元数据还要参考SpriteSheetMetadata。<br>
 * 例如，SSE默认格式的SpriteSheet文件的类型，sheetType是PNG_IMAGE；而metadataType是一般是SpriteSheetMetadataType.SSE_XML。<br>
 * 再如，cocos2d格式的SpriteSheet文件类型，sheetType是PNG_IMAGE；而metadataType是SpriteSheetMetadataType.COCOS2D
 * </p>
 * @author zrong
 */
public class SpriteSheetType
{
	/**
	 * 正常的png文件，没有加入过任何内容，metaData数据需要另行提供
	 */	
	public static const PNG_IMAGE:String = 'SSPI';
	
	/**
	 * 正常的jpg文件，没有加入过任何内容，metaData数据需要另行提供
	 */	
	public static const JPG_IMAGE:String = 'SSJI';
	
	/**
	 * 正常的JPEG-XR文件，metaData数据需要另行提供
	 */
	public static const JPG_XR_IMAGE:String = "SSXI";
	
	/**
	 * 在文件头中加入了元数据的PNG文件
	 */	
	public static const PNG_BINARY:String = 'SSPB';
	
	/**
	 * 在文件头中加入了元数据的JPG文件
	 */	
	public static const JPG_BINARY:String = 'SSJB';
	
	/**
	 * 在文件头中加入了元数据的JPEG-XR文件
	 */
	public static const JPG_XR_BINARY:String = "SSXB";
}
}
