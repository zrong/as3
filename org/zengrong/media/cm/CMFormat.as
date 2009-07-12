package org.zengrong.media.cm
{
	import flash.media.Camera;
	import flash.media.Microphone;
	
	public class CMFormat
	{
		public var cam:Camera;	//返回的摄像头实例
		public var mic:Microphone;	//返回的麦克风实例
		public var names:Array;		//麦克风或者摄像头的名称数组
		public var manual:Boolean;	//是否是手动启用或禁用摄像头
		
		public function CMFormat($camOrMic:* = null, $camOrMicNames:Array = null, $isManual:Boolean = false)
		{
			if($camOrMic is Camera)
			{
				cam = $camOrMic;
				mic = null;
			}
			else if($camOrMic is Microphone)
			{
				mic = $camOrMic;	
				cam = null;
			}
			else
			{
				cam = null;
				mic = null;
			}
			names = $camOrMicNames;
			manual = $isManual;
		}
		
		public function toString():String
		{
			return '[org.zengrong.media.cm:CMFormat ' +
					'cam=' + cam +',' +
					'mic=' + mic + ',' + 
					'names=' + names + ',' +
					'manual=' + manual + ']';
		}
	}
}