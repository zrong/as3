////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-04-27
//  修改时间：2011-09-01
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.assets
{
/**
 * Assets载入过程中，调用Progress回调函数的参数的ValueObject
 * @author zrong
 */
public class AssetsProgressVO
{
	public function AssetsProgressVO($curFile:Object=null)
	{
		if($curFile)
		{
			name = $curFile.fname;
			url = $curFile.url;
			type = $curFile.ftype;
			if($curFile.loaded!=undefined)
				loaded = $curFile.loaded;
			if($curFile.total!=undefined)
				total = $curFile.total;
			if($curFile.whole!=undefined)
				whole = $curFile.whole;
		}
	}
	
	/**
	 * 若值为true，代表载入列表的进度；否则就是当前文件的载入进度
	 */	
	public var whole:Boolean;

	/**
	 * 若值为true，代表这次载入完成；否则代表载入没有完成
	 * 这个值与whole联用，主要针对载入列表的进度。当whole为true的时候才有意义。当whole为false的时候，这个值始终为false
	 * 在载入列表进度时间发生时，whole总是为true。对于列表中一个资源的载入，在开始载入和载入成功的时候会各发送一次progress事件。
	 * 开始载入的时候，done值为false；载入成功的时候，done值为true。
	 */
	public var done:Boolean;
	
	/**
	 * 载入的总量
	 */	
	public var total:int;
	
	/**
	 * 当前载入量
	 */	
	public var loaded:int;
	
	/**
	 * 正在载入的资源的名称
	 */	
	public var name:String;
	
	/**
	 * 正在载入的资源的url
	 */	
	public var url:String;
	
	/**
	 * 正在载入的资源的type
	 */	
	public var type:String;
	
	public function toString():String
	{
		return 'org.zengrong.assets::AssetsProgressVO{'+
				'name:'+name+
				',url:'+url+
				',type:'+type+
				',loaded:'+loaded+
				',total:'+total+
				',whole:'+whole + 
				',done:'+done+ '}';
	}
}
}
