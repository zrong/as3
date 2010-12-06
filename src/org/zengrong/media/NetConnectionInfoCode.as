////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-12-06
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.media
{
/**
 * 保存NetConnection连接时返回的字符串，这样在比对连接状态的时候就不用输入这些字符串了。
 * @author zrong
 */
public class NetConnectionInfoCode
{
	//常用的NC连接错误信息
	public static const SUCCESS:String = "NetConnection.Connect.Success";
	public static const FAILED:String = "NetConnection.Connect.Failed";
	public static const REJECTED:String = "NetConnection.Connect.Rejected";
	public static const CLOSED:String = "NetConnection.Connect.Closed";
	public static const APP_SHUTDOWN:String = "NetConnection.Connect.AppShutdown";
	
	public static const CALL_SUCCESS:String = "NetConnection.Call.Success";
	public static const CALL_FAILED:String = "NetConnection.Call.Failed";
	public static const ADMIN_FAILED:String = "NetConnection.Admin.CommandFailed";
	public static const CALL_BAD:String = "NetConnection.Call.BadValue";	
}
}