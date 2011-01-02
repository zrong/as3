////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-01-02
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.utils
{
import flash.utils.ByteArray;

public class ObjectUtil
{
	/**
	 * 复制一个对象
	 * @param value
	 */	
	public static function copy(value:Object):Object
	{
		var buffer:ByteArray = new ByteArray();
		buffer.writeObject(value);
		buffer.position = 0;
		var result:Object = buffer.readObject();
		return result;
	}
}
}