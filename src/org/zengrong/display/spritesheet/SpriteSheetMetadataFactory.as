package org.zengrong.display.spritesheet
{
/**
 * 创建SpriteSheetMetadata的工厂
 */
public class SpriteSheetMetadataFactory
{
	/**
	 * 根据SpriteSheetMetadata类型，创建一个ISpriteSheetMetadata
	 * @param $type Metadata的类型
	 * @see SpriteSheetMetadataType
	 * @throws TypeError $type为不支持的类型的时候，会抛出异常
	 */
	public static function create($type:String):ISpriteSheetMetadata
	{
		var __metadata:SpriteSheetMetadata = new SpriteSheetMetadata();
		if($type == SpriteSheetMetadataType.SSE_JSON)
			return new SpriteSheetMetadataJSON(__metadata);
		else if($type == SpriteSheetMetadataType.SSE_XML)
			return new SpriteSheetMetadataXML(__metadata);
		else if($type == SpriteSheetMetadataType.STARLING)
			return new SpriteSheetMetadataStarling(__metadata);
		else if($type == SpriteSheetMetadataType.COCOS2D)
			return new SpriteSheetMetadataCocos2d(__metadata);
		throw TypeError('不支持的metadata格式:'+$type);
		return null;
	}
}
}