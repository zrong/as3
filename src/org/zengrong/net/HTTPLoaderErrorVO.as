package org.zengrong.net
{
import flash.events.ErrorEvent;

/**
 * HTTPLoader调用失败返回的VO
 * @author zrong (http://zengrong.net)
 * 创建日期：2012-12-4
 * 修改日期：2013-02-07
 */
public class HTTPLoaderErrorVO extends HTTPLoaderVO
{
	public function HTTPLoaderErrorVO()
	{
	}
	
	/**
	 * 错误的类型
	 */
	public var type:String;
	
	/**
	 * 错误消息
	 */
	public var message:String;
	
	/**
	 * 报错时候的error事件
	 */
	public var errorEvent:ErrorEvent;
}
}