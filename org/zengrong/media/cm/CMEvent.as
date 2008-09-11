package org.zengrong.media.cm
{
	import flash.events.Event;
	import org.zengrong.media.cm.*;
	import flash.media.Camera;
	import flash.media.Microphone;

	public class CMEvent extends Event
	{
		public static const CAMERA_MUTED:String = "camMuted";			//摄像头禁用
		public static const CAMERA_UN_MUTED:String = "camUnMuted";		//摄像头启用
		public static const MICROPHONE_MUTED:String = "micMuted";			//摄像头禁用
		public static const MICROPHONE_UN_MUTED:String = "micUnMuted";		//摄像头启用
		public static const NO_CAMERA:String = "noCamera";	//没有摄像头
		public static const NO_MICROPHONE:String = "noMicrophone";	//没有麦克风
		public static const MULTI_CAMERA:String = "multiCamera";	//多个摄像头
		
		public var result:CMFormat;

		public function CMEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, result:CMFormat=null)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
			this.result = result;
		}
		
		/**
		 * 根据摄像头或者麦克风的启用状态返回不同的事件名称
		 */
		public static function toEvent($camOrMic:*):String
		{
			if($camOrMic is Camera)
			{
				if(($camOrMic as Camera).muted)
				{
					return CMEvent.CAMERA_MUTED;
				}
				else
				{
					return CMEvent.CAMERA_UN_MUTED;		
				}
			}
			else if($camOrMic is Microphone)
			{
				if(($camOrMic as Microphone).muted)
				{
					return CMEvent.MICROPHONE_MUTED;
				}
				else
				{
					return CMEvent.MICROPHONE_MUTED;
				}
			}
			else
			{
				return "";
			}
		}
		
	}
}