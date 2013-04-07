package org.zengrong.display.spritesheet
{
/**
 * 输出格式为纯文本的包装器，需要实现lineEnding
 * @author zrong (http://zengrong.net)
 * 创建日期：2013-4-7
 */
public class SpriteSheetMetadataStringWraper extends SpriteSheetMetadataWrapper
{
	public function SpriteSheetMetadataStringWraper($meta:ISpriteSheetMetadata)
	{
		super($meta);
	}
	
	private var _lineEnding:String = "\n";
	
	/**
	 * 文本换行符
	 * 
	 * @defaults \n
	 */
	public function get lineEnding():String
	{
		return _lineEnding;
	}
	
	/**
	 * @private
	 */
	public function set lineEnding($value:String):void
	{
		_lineEnding = $value;
	}
}
}