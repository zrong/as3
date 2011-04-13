////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-11
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.spritesheet
{
/**
 * 定义SpriteSheet的类型
 * @author zrong
 */
public class SpriteSheetType
{
	/**
	 * 正常的png文件，没有加入过任何内容，metaData数据需要另行提供
	 */	
	public static const PNG:String = 'SSP';
	
	/**
	 * 正常的jpg文件，没有加入过任何内容，metaData数据需要另行提供
	 */	
	public static const JPG:String = 'SSJ';
	
	/**
	 * 在文件头中加入了元数据的PNG文件
	 */	
	public static const META_PNG:String = 'MSSP';
	
	/**
	 * 在文件头中加入了元数据的JPG文件
	 */	
	public static const META_JPG:String = 'MSSJ';
	
}
}