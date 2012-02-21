package org.zengrong.file
{
/**
 * 保存不同平台的换行符，的枚举
 * @author zrong
 * 创建日期：2012-02-21
 */
public class FileEnding
{
	/**
	 * 微软操作系统的换行符
	 */	
	public static const DOS:String = '\r\n';
	
	/**
	 * 苹果操作系统的换行符
	 */	
	public static const MAC:String = '\r';
	
	/**
	 * 类Unix系统的换行符
	 */	
	public static const UNIX:String = '\n';
}
}