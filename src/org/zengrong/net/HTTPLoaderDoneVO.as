package org.zengrong.net
{
/**
 * HTTPLoader调用成功返回的VO
 * @author zrong (http://zengrong.net)
 * 创建日期：2012-12-4
 */
public class HTTPLoaderDoneVO extends HTTPLoaderVO
{
	public function HTTPLoaderDoneVO()
	{
	}
	
	/**
	 * 调用成功后HTTP服务器返回的数据
	 */
	public var resultData:Object;
}
}