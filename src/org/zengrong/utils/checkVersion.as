////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong(zrongzrong@gmail.com)
//  创建时间：2012-1-14
////////////////////////////////////////////////////////////////////////////////

package org.zengrong.utils
{
import flash.system.Capabilities;
/**
 * 检测Flash Player的版本号
 * @param $major 主版本号，必须提供
 * @param $minor 次版本号，可选
 * @param $build 生成版本号，可选
 * @param $internal 内部生成版本号，可选
 * @return 若提供的版本号比当前版本号大，则返回1；若相等，则返回0；否则返回-1
 * @author zrong
 */
public function checkVersion($major:int, $minor:int=-1, $build:int=-1, $internal:int=-1):int
{
	var __ver:String = Capabilities.version;
	var __split:Array = __ver.split(' ');
	var __vList:Array = String(__split[1]).split(',');
	//trace('ver:', __ver);
	//trace('__vList:', __vList);
	if($major > int(__vList[0])) return 1;
	else if($major < int(__vList[0])) return -1;
	else
	{
		if($minor>-1)
		{
			if($minor > int(__vList[1])) return 1;
			else if($minor < int(__vList[1])) return -1;
			else
			{
				if($build > -1)
				{
					if($build > int(__vList[2])) return 1;
					else if($build < int(__vList[2])) return -1;
					else
					{
						if($internal > -1)
						{
							if($internal > int(__vList[3])) return 1;
							else if($internal < int(__vList[3])) return -1;
							else return 0;
						}
						return 0;
					}
				}
				return 0;
			}
		}
		return 0;
	}
}
}
