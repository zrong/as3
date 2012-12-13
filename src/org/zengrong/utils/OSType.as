package org.zengrong.utils
{
import flash.system.Capabilities;
/**
 * 定义程序所在的平台类型的枚举<br>
 * 提供比较平台类型字符串的功能
 * @author zrong
 * 创建日期：2012-08-31
 */
public class OSType
{
	public static const LINUX_CODE:int = 1;
	
	public static const IOS_CODE:int = 2;
	
	public static const WINDOWS_CODE:int = 4;
	
	/**
	 * 未知平台
	 */
	public static const UNKNOWN:String = "unknown";
	
	/**
	 * iOS平台，包括iPhone、iPod、iPad
	 */
	public static const IOS:String = "iPhone OS";
	
	/**
	 * Mac平台
	 */
	public static const MAC:String = "Mac OS";
	
	/**
	 * Linxu平台，包括Android。目前也只有Android了
	 */
	public static const LINUX:String = "Linux";
	
	/**
	 * Windows平台
	 */
	public static const WINDOWS:String = "Windows";
	
	/**
	 * iPhone
	 */
	public static const IPHONE:String = "iPhone";
	
	/**
	 * iPad
	 */
	public static const IPAD:String = "iPad";
	
	/**
	 * iPod 和 iPod Touch
	 */
	public static const IPOD:String = "iPod";
	
	public static const IPHONE_1G:String = "iPhone1,1";	// first gen is 1,1
	public static const IPHONE_3G:String = "iPhone1";	// second gen is 1,2
	public static const IPHONE_3GS:String = "iPhone2";	// third gen is 2,1
	public static const IPHONE_4:String = "iPhone3";		// normal:3,1 verizon:3,3
	public static const IPHONE_4S:String = "iPhone4";	// 4S is 4,1
	public static const IPHONE_5PLUS:String = "iPhone";
	public static const TOUCH_1G:String = "iPod1,1";
	public static const TOUCH_2G:String = "iPod2,1";
	public static const TOUCH_3G:String = "iPod3,1";
	public static const TOUCH_4G:String = "iPod4,1";
	public static const TOUCH_5PLUS:String = "iPod";
	public static const IPAD_1:String = "iPad1";		// iPad1 is 1,1
	public static const IPAD_2:String = "iPad2";		// wifi:2,1 gsm:2,2 cdma:2,3
	public static const IPAD_3:String = "iPad3";		// wifi:3,1
	public static const IPAD_4PLUS:String = "iPad";
	
	public static const IOS_DEVICES:Array = 
		[
			IPHONE_1G, IPHONE_3G, IPHONE_3GS,
			IPHONE_4, IPHONE_4S, IPHONE_5PLUS, IPAD_1, IPAD_2, IPAD_3, IPAD_4PLUS,
			TOUCH_1G, TOUCH_2G, TOUCH_3G, TOUCH_4G, TOUCH_5PLUS
		];
	
	/**
	 * 判断传来的值是否是Windows设备的兼容值，如果传来的值为空，就获取当前设备的值
	 */
	public static function isWindows($deviceType:String=null):Boolean
	{
		if(!$deviceType) $deviceType = getDevice();
		return $deviceType == WINDOWS;
	}
	
	/**
	 * 判断传来的值是否是Linux/Android设备的兼容值，如果传来的值为空，就获取当前设备的值
	 */
	public static function isLinux($deviceType:String=null):Boolean
	{
		if(!$deviceType) $deviceType = getDevice();
		return $deviceType == LINUX;
	}
	
	/**
	 * 判断传来的值是否是Mac OS设备的兼容值，如果传来的值为空，就获取当前设备的值
	 */
	public static function isMac($deviceType:String=null):Boolean
	{
		if(!$deviceType) $deviceType = getDevice();
		return $deviceType == MAC;
	}
	
	/**
	 * 判断传来的值是否是iOS设备的兼容值，如果传来的值为空，就获取当前设备的值
	 */
	public static function isIOS($deviceType:String=null):Boolean
	{
		if(!$deviceType) $deviceType = getDevice();
		return IOS_DEVICES.indexOf($deviceType) != -1;
	}
	
	/**
	 * 返回代表设备平台的字符串，所有可用字符串保存在OSType类中
	 * <p>iPhone设备的报告形式如下：<br>
	 * iPhone OS 5.1.1 iPhone3,1</p>
	 * <p>Windows设备的报告形式如下：<br>
	 * Windows 7</p>
	 * <p>Android设备的报告形式如下：<br>
	 * Linux 2.6.35-7-g8b67f97</p>
	 * @return 设备的名称，可以在OSType中找到常量进行比对。不能识别的设备将报告unknown
	 * @see org.zengrong.utils.OSType
	 */
	public static function getDevice():String
	{
		var __info:Array = Capabilities.os.split(" ");
		if(__info[0] == OSType.WINDOWS) return OSType.WINDOWS;
		if(__info[0] == OSType.LINUX) return OSType.LINUX;
		var __appleStyle:String = __info[0] + " " + __info[1];
		if (__appleStyle == OSType.MAC)  return OSType.MAC;
		if(__appleStyle == OSType.IOS)
		{
			for each (var $device:String in OSType.IOS_DEVICES)
			{	
				if (__info[3].indexOf($device) != -1)
				{
					return $device;
				}
			}
		}
		return OSType.UNKNOWN;
	}
}
}