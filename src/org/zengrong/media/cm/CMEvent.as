////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2011-02-27
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.media.cm
{
import flash.events.Event;
import flash.media.Camera;
import flash.media.Microphone;

/**
 * 检测摄像头和麦克风的事件
 * @author zrong
 */
public class CMEvent extends Event
{
	/**
	 * 摄像头禁用
	 */	
	public static const CAMERA_MUTED:String = "cameraMuted";
	
	/**
	 * 摄像头启用
	 */	
	public static const CAMERA_UN_MUTED:String = "cameraUnMuted";
	
	/**
	 * 多个摄像头
	 */	
	public static const MULTI_CAMERA:String = "multiCamera";	
	
	/**
	 * 麦克风禁用
	 */	
	public static const MICROPHONE_MUTED:String = "microphoneMuted";
	
	/**
	 * 麦克风启用
	 */	
	public static const MICROPHONE_UN_MUTED:String = "microphoneUnMuted";
	
	/**
	 * 没有摄像头
	 */	
	public static const NO_CAMERA:String = "noCamera";
	
	/**
	 * 没有麦克风
	 */	
	public static const NO_MICROPHONE:String = "noMicrophone";
	
	/**
	 * 摄像头可用，这个事件只会在第一次检测摄像头的时候发生一次
	 */	
	public static const CAMERA_AVAILABLE:String = "cameraAvailable";
	
	/**
	 * 麦克风可用，这个事件只会在第一次检测麦克风的时候发生一次
	 */	
	public static const MICROPHONE_AVAILABLE:String = "microphoneAvailable";
	
	/**
	 * 在摄像头中的图像开始运动时调度
	 */	
	public static const ACTIVITY_START:String = 'activityStart';
	
	/**
	 *在摄像头中的图像结束运动时调度 
	 */	
	public static const ACTIVITY_STOP:String = 'activityStop'; 
	
	public function CMEvent($type:String, $result:CMVO=null, $bubbles:Boolean=false, $cancelable:Boolean=true)
	{
		super($type, $bubbles, $cancelable);
		result = $result;
	}
	
	public var result:CMVO;
	
	override public function clone():Event
	{
		return new CMEvent(type, result, bubbles, cancelable);
	}	
	
	override public function toString():String
	{
		return 'org.zengrong.media.cm:CMEvent {' +
				'type=' + type + ',' +
				'result=' + result + '}';
	}
}
}