////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：日期
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.media.cm
{
import flash.media.Camera;
import flash.media.Microphone;

/**
 * 包含
 * @author zrong
 */
public class CMVO
{
	public function CMVO($camOrMic:* = null, $camOrMicNames:Array = null, $isManual:Boolean = false)
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
	
	/**
	 * 摄像头实例
	 */	
	public var cam:Camera;
	/**
	 * 麦克风实例
	 */	
	public var mic:Microphone;
	/**
	 * 麦克风或者摄像头的名称数组
	 */	
	public var names:Array;
	/**
	 * 是否是手动启用或禁用摄像头
	 */	
	public var manual:Boolean;	
	
	public function toString():String
	{
		return 'org.zengrong.media.cm:CMVO {' +
				'cam=' + cam +',' +
				'mic=' + mic + ',' + 
				'names=' + names + ',' +
				'manual=' + manual + '}';
	}
}
}