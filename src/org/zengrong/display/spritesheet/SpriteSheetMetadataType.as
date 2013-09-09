////////////////////////////////////////////////////////////////////////////////
// zengrong.net
// 创建者:	zrong
// 创建时间：2011-08-24
// 修改时间：2013-09-02 将扩展名类型移动到AssetsType中，这里只保留逻辑类型
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.spritesheet
{
import org.zengrong.assets.AssetsType;
/**
 * 定义SpriteSheetMetadata的文件类型
 */
public class SpriteSheetMetadataType
{
	/**
	 * SpriteSheetEditor存储的二进制格式
	 */
	public static const BINARY:String = 'binary';
	
	/**
	 * SpriteSheetEditor的原生格式，存储为XML
	 */
	public static const SSE_XML:String = "ssexml";
	
	/**
	 * SpriteSheetEditor的原生格式，存储为JSON
	 */
	public static const SSE_JSON:String = "ssejson";
	
	/**
	 * SpriteSheetEditor的原生格式，存储为TXT
	 */
	public static const SSE_TXT:String = "ssetxt";
	
	/**
	 * Starling格式
	 */
	public static const STARLING:String = "starling";
	
	/**
	 * Cocos2d格式
	 */
	public static const COCOS2D:String = "cocos2d";
	
	/**
	 * 检查$type是不是SSE格式
	 */
	public static function isSSEType($type:String):Boolean
	{
		return $type == SSE_XML || 
			$type == SSE_JSON ||
			$type == SSE_TXT;
	}
	
	public static function getTypeExt($typeName:String):String
	{
		switch($typeName)
		{
			case SSE_XML:
				return AssetsType.XML;
				break;
			case SSE_JSON:
				return AssetsType.JSON;
				break;
			case SSE_TXT:
				return AssetsType.TXT;
				break;
			case STARLING:
				return AssetsType.XML;
				break;
			case COCOS2D:
				return AssetsType.PLIST;
				break;
		}
		return null;
	}
}
}
