////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2011-02-27
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.media.cm
{
import flash.events.ActivityEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.media.Camera;
import flash.media.Microphone;
import flash.media.SoundCodec;
import flash.system.Capabilities;
import flash.utils.getDefinitionByName;
import flash.utils.setTimeout;

import mx.core.Singleton;

import org.zengrong.utils.checkVersion;

/**
 * 检测摄像头和麦克风
 */
[Event(name="cameraMuted",type="org.zengrong.media.cm.CMEvent")]
[Event(name="cameraUnMuted",type="org.zengrong.media.cm.CMEvent")]
[Event(name="noCamera",type="org.zengrong.media.cm.CMEvent")]
[Event(name="multiCamera",type="org.zengrong.media.cm.CMEvent")]
[Event(name="activityStart",type="org.zengrong.media.cm.CMEvent")]
[Event(name="activityStop",type="org.zengrong.media.cm.CMEvent")]

public class CM extends EventDispatcher
{
	public function CM($sig:Singleton)
	{
		trace("建立CM的实例");
	}		
	
	/**
	* 返回一个CM实例
	*/
	public static function getInstance():CM
	{
		if(_cm == null)
		{
			_cm = new CM(new Singleton());
		}
		return _cm;
	}
	
	private static var _cm:CM;
	private var _cam:Camera;
	private var _mic:Microphone;
	
	public function get cam():Camera
	{
		return _cam;
	}
	
	public function get mic():Microphone
	{
		return _mic;
	}
	
	/**
	*	返回摄像头数量
	*/
	public function get camAmount():uint
	{
		return camNames.length;
	}
	
	public function get camNames():Array
	{
		return Camera.names;
	}
	
	/**
	 *返回麦克风数量
	 */
	public function get micAmount():uint
	{
		return micNames.length;
	}
	
	public function get micNames():Array
	{
		return Microphone.names;
	}

	/**
	 *  系统是否支持高级麦克风
	 */
	public function get supportEnhancedMicrophone():Boolean
	{
		var __ver:int = checkVersion(10,3);
		return __ver <= 0;
	}

	/**
	 * 重置摄像头的大小
	 */
	public function setMode($w:int, $h:int, $fps:int, $favorArea:Boolean=true):void
	{
		if(_cam)
		{
			trace('CM.setMode:', $w, $h, $fps);
			trace('CM.setMode,cam:', _cam.width, _cam.height, _cam.fps);
			if(_cam.width != $w || _cam.height != $h || _cam.fps != $fps)
			{
				_cam.setMode($w, $h, $fps, $favorArea);
			}
		}
	}

	public function setQuality($bw:int, $quality:int):void
	{
		if(_cam)
		{
			if(_cam.quality != $quality || _cam.bandwidth != $bw)
				_cam.setQuality($bw, $quality);
		}
	}

	/**
	 * 为Microphone设定默认设置
	 * @param $isEnhancedMic 是否是增强麦克风
	 */
	public function setMicDefalutSetting($isEnhancedMic:Boolean=false):void
	{
		if(_mic)
		{
			_mic.codec = SoundCodec.SPEEX;
			_mic.setSilenceLevel(0);
			_mic.enableVAD = true;
			_mic.rate = 16;
			//使用高质量的音频
			_mic.encodeQuality = 9;
			if($isEnhancedMic && supportEnhancedMicrophone)
			{
				//由于需要判断Flash Player版本，不能引用类名，采用反射
				var __OptionClass:Class = getDefinitionByName("flash.media.MicrophoneEnhancedOptions") as Class;
				var __ModeClass:Class = getDefinitionByName("flash.media.MicrophoneEnhancedMode") as Class;
				var __options:* = new __OptionClass();
				__options.mode = __ModeClass.FULL_DUPLEX;
				_mic["enhancedOptions"] = __options;
				//_mic.setLoopBack(true);
			}
		}
	}

	/**
	 * 重置 
	 */	
	public function reset():void
	{
		trace('CM重新设置');
		if(_cam != null)
		{
			_cam.removeEventListener(StatusEvent.STATUS, handler_camStatus);
			_cam.removeEventListener(ActivityEvent.ACTIVITY, handler_activity);
		}
		if(_mic != null)
			_mic.removeEventListener(StatusEvent.STATUS, handler_micStatus);
		_cam = null;
		_mic = null;
	}
	
	
	/**
	 * 检测摄像头数量，不需要参数
	 * 如果摄像头数量大于1
	 **/
	public function checkCam():Camera
	{
		trace('执行了checkCam！摄像头数量：'+ camAmount);
		if(camAmount <= 0)
		{
			this.dispatchEvent(new CMEvent(CMEvent.NO_CAMERA));	//发布摄像头检测消息
		}
		else
		{
			_cam = Camera.getCamera();
			_cam.addEventListener(StatusEvent.STATUS, handler_camStatus);
			_cam.addEventListener(ActivityEvent.ACTIVITY, handler_activity);
			//延迟100毫秒再发布事件，这样外部就能先获得return的值，然后再收到事件。避免在获得cam之前收到cam可以事件，导致依赖cam的代码失败
			setTimeout(checkCamStatus, 100, false);
			//如果有多个摄像头并且当前的摄像头被禁用，就发出“多个摄像头”事件
			if(_cam.muted && (camAmount > 1))
				this.dispatchEvent(new CMEvent(CMEvent.MULTI_CAMERA, new CMVO(_cam, camNames)));
		}
		return _cam;
	}
	
	private function handler_activity(evt:ActivityEvent):void
	{
		var __cam:Camera = evt.currentTarget as Camera;
/*		trace('//=================org.zengrong.media.cm.CM');
		trace('activityHandler发生,activating:',evt.activating);
		trace('camera name:',__cam.name);
		trace('camera width:',__cam.width);
		trace('camera height:',__cam.height);
		trace('=============================//');*/
		var __vo:CMVO = new CMVO(__cam, camNames);
		var __event:CMEvent = 	evt.activating ? 
								new CMEvent(CMEvent.ACTIVITY_START, __vo) :
								new CMEvent(CMEvent.ACTIVITY_STOP, __vo);
		this.dispatchEvent(__event);
	}
	
	private function handler_camStatus(evt:StatusEvent):void
	{
		checkCamStatus(true);
	}
	
	/**
	 * 检查摄像头的当前状态并发布
	 * @param isManual		是否是手动禁用摄像头
	 **/
	private function checkCamStatus($isManual:Boolean):void
	{
		trace('//=================org.zengrong.media.cm.CM');
		trace("执行了checkCamStatus！ manual:"+$isManual);
		trace("摄像头是否禁用："+_cam.muted);
		trace("待发布的事件："+getEventType(_cam));
		trace('=============================//');
		var __vo:CMVO = new CMVO(_cam, camNames, $isManual);
		this.dispatchEvent(new CMEvent(getEventType(_cam), __vo)); 
	}
	
	/**
	 * 检测麦克风数量，不需要参数
	 **/
	public function checkMic():Microphone
	{
		if(micAmount <= 0)
		{
			this.dispatchEvent(new CMEvent(CMEvent.NO_MICROPHONE));	//发布摄像头检测消息
		}
		else
		{
			//若当前Flash Player支持增强麦克风，就使用增强麦克风
			if(supportEnhancedMicrophone)
			{
				//即使是Flash Player版本足夠，也可能出現“1066，不支持的函數”這個錯誤
				//所以這裡還是要捕獲錯誤并不處理，使用普通麥克風
				try
				{
					_mic = Microphone.getEnhancedMicrophone();
					//如果能获得增强麦克风，就使用它
					if(_mic) setMicDefalutSetting(true);
				}
				catch($err:Error) { }
			}
			//如果无法获得增强麦克风，就使用普通麦克风
			if(!_mic)
			{
				_mic = Microphone.getMicrophone();
				_mic.setUseEchoSuppression(true);
				setMicDefalutSetting();
			}
			_mic.addEventListener(StatusEvent.STATUS, handler_micStatus);
			checkMicStatus();
		}
		return _mic;
	}
	
	private function handler_micStatus(evt:StatusEvent):void
	{
		checkMicStatus();
	}
	
	/**
	 * 检查麦克风的当前状态并发布，没有参数
	 **/
	private function checkMicStatus():void
	{
		var __evt:CMEvent = new CMEvent(getEventType(_mic), new CMVO(_mic, micNames));
		this.dispatchEvent(__evt);	
	}
	
	/**
	 * 根据摄像头或者麦克风的启用状态返回不同的事件名称
	 */
	private function getEventType($camOrMic:*):String
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
		throw new RangeError('必须提供Camera或者Microphone类型！');
	}

}
}
class Singleton{}
