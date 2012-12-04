package org.zengrong.net
{
/**
 * HTTPLoader调用失败返回的VO
 * @author zrong (http://zengrong.net)
 * 创建日期：2012-12-4
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
}
}