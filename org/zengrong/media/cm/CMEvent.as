package org.zengrong.media.cm
{
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Microphone;

	public class CMEvent extends Event
	{
		public static const CAMERA_MUTED:String = "camMuted";			//摄像头禁用
		public static const CAMERA_UN_MUTED:String = "camUnMuted";		//摄像头启用
		public static const MICROPHONE_MUTED:String = "micMuted";			//麦克风禁用
		public static const MICROPHONE_UN_MUTED:String = "micUnMuted";		//麦克风启用
		public static const NO_CAMERA:String = "noCamera";	//没有摄像头
		public static const NO_MICROPHONE:String = "noMicrophone";	//没有麦克风
		public static const MULTI_CAMERA:String = "multiCamera";	//多个摄像头
		
		public static const CAMERA_AVAILABLE:String = "cameraAvailable";	//摄像头可用，这个事件只会在第一次检测摄像头的时候发生一次
		public static const MICROPHONE_AVAILABLE:String = "microphoneAvailable";	//麦克风可用，，这个事件只会在第一次检测麦克风的时候发生一次
		
		public static const ACTIVITY_START:String = 'activityStart'; //在摄像头开始会话时调度
		public static const ACTIVITY_STOP:String = 'activityStop'; 	//在摄像头结束会话时调度
		
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
		
		override public function toString():String
		{
			return 'org.zengrong.media.cm:CMEvent {' +
					'type=' + type + ',' +
					'result=' + result + '}';
					
		}
		
	}
}