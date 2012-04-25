////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2012-03-06
//  最后修改：2012-03-06
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.assets
{
import flash.events.Event;

import org.zengrong.assets.AssetsProgressVO;

/**
 * 用于Assets类在载入过程中发出的事件
 * @author zrong
 * @see org.zengrong.assets.Assets
 */
public class AssetsEvent extends Event
{
	/**
	 * 资源载入完成事件
	 * @eventType complete
	 */
	public static const COMPLETE:String = 'complete';
	
	/**
	 * 碰到载入错误等需要发送信息
	 * @eventType info
	 */
	public static const INFO:String = 'info';
	
	/**
	 * 处理事件
	 * @eventType progress
	 */
	public static const PROGRESS:String = 'progress';
	
	public function AssetsEvent($type:String, $vo:AssetsProgressVO=null, $bubbles:Boolean=false, $cancelable:Boolean=false)
	{
		super($type, $bubbles, $cancelable);
		vo = $vo;
	}
	
	public var vo:AssetsProgressVO;
	
	public var info:String;
	
	override public function clone():Event
	{
		return new AssetsEvent(type, vo, bubbles, cancelable);
	}
}
}