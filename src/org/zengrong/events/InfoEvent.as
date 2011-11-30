package org.zengrong.events
{
	import flash.events.Event;

	public class InfoEvent extends Event
	{
		/**
		 * 通用的完成事件
		 */
		public static const COMPLETE:String = 'complete';
		
		/**
		 * 通用的信息事件
		 */
		public static const INFO:String = 'info';
		
		/**
		 * 通用的处理事件
		 */
		public static const PROGRESS:String = 'progress';
		
		public var info:*;
		
		public function InfoEvent($type:String, $info:*=null, $bubbles:Boolean=false, $cancelable:Boolean=false)
		{
			//TODO: implement function
			super($type, $bubbles, $cancelable);
			info = $info;
		}
		
		override public function clone():Event
		{
			return new InfoEvent(type, info, bubbles, cancelable);
		}		
	}
}