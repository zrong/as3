////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong(zrongzrong@gmail.com)
//  创建时间：2012-1-14
////////////////////////////////////////////////////////////////////////////////

package org.zengrong.utils
{
import flash.system.Capabilities;
/**
 * 检测Flash Player的平台
 * @param $platform 平台代码，值为WIN/MAC/LNX/AND或空字符串（代表不比较平台）
 */
public function checkPlatform($platform:String):Boolean
{
	var __ver:String = Capabilities.version;
	var __split:Array = __ver.split(' ');
	return __split[0] == $platform;
}
}
