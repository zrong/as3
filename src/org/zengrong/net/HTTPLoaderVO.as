package org.zengrong.net
{
/**
 * HTTPLoader返回的数据的基类
 * @author zrong (http://zengrong.net)
 * 创建日期：2012-12-4
 * 修改日期：2013-02-07
 */
public class HTTPLoaderVO
{
	public function HTTPLoaderVO()
	{
	}
	
	/**
	 * 提交的地址
	 */
	public var url:String;
	
	/**
	 * 提交的时候要求返回的数据<br>
	 * 一般可以把提交的参数放在这个对象中，这样在提交出错的时候，可以使用这些数据重复提交。
	 */
	public var returnData:Object;
	
}
}