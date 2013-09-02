////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-08-24
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display.spritesheet
{
/**
 * 定义SpriteSheetMetadata的文件类型
 */
public class SpriteSheetMetadataType
{
	public static const XML:String = 'xml';
	public static const JSON:String = 'json';
	public static const BINARY:String = 'binary';
	public static const TXT:String = 'txt';
	public static const PLIST:String = 'plist';
	
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
	
	public static function getTypeExt($typeName:String):String
	{
		switch($typeName)
		{
			case SSE_XML:
				return XML;
				break;
			case SSE_JSON:
				return JSON;
				break;
			case SSE_TXT:
				return TXT;
				break;
			case STARLING:
				return XML;
				break;
			case COCOS2D:
				return PLIST;
				break;
		}
		return null;
	}
}
}
