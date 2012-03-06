////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：忘了
//  最后修改：2012-03-06
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.events
{
	import flash.events.Event;

	public class InfoEvent extends Event
	{
		public var info:*;
		
		public function InfoEvent($type:String, $info:*=null, $bubbles:Boolean=false, $cancelable:Boolean=false)
		{
			super($type, $bubbles, $cancelable);
			info = $info;
		}
		
		override public function clone():Event
		{
			return new InfoEvent(type, info, bubbles, cancelable);
		}		
	}
}