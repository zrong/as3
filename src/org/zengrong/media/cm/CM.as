/**
 * 检测摄像头和麦克风
 */
package org.zengrong.media.cm
{
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.utils.setTimeout;
	
	public class CM implements IEventDispatcher
	{
		private var eventDispatcher:EventDispatcher;
		private static var CHECKER:CM = null;
		private var cam:Camera;
		private var mic:Microphone;
		
		public function CM()
		{
//			trace("建立CM的实例");
			eventDispatcher = new EventDispatcher();
		}		
		
		/**
		* 返回一个CM实例
		*/
		public static function getInstance():CM
		{
			if(CHECKER == null)
			{
				CHECKER = new CM();
			}
			return CHECKER;
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
		
		//移去侦听器
		public function reset():void
		{
			trace('CM重新设置');
			if(cam != null) cam.removeEventListener(StatusEvent.STATUS, camStatusHandler);
			if(cam != null) cam.removeEventListener(ActivityEvent.ACTIVITY, activityHandler);
			if(mic != null) mic.removeEventListener(StatusEvent.STATUS, micStatusHandler);
			cam = null;
			mic = null;
		}
		
		
		/**
		 * 检测摄像头数量，不需要参数
		 * 如果摄像头数量大于1
		 **/
		public function checkCam():Camera
		{
			trace('执行了checkCam！摄像头数量：'+ camAmount);
			if(camAmount <= 0){
				this.dispatchEvent(new CMEvent(CMEvent.NO_CAMERA));	//发布摄像头检测消息
			}else{
				cam = Camera.getCamera();
				cam.addEventListener(StatusEvent.STATUS, camStatusHandler);
				cam.addEventListener(ActivityEvent.ACTIVITY, activityHandler);
				//延迟100毫秒再发布事件，这样外部就能先获得return的值，然后再收到事件。避免在获得cam之前收到cam可以事件，导致依赖cam的代码失败
				setTimeout(checkCamStatus, 100, false);
//				checkCamStatus(false);
				//如果有多个摄像头并且当前的摄像头被禁用，就发出“多个摄像头”事件
				if(cam.muted && (camAmount > 1))
				{
					var i:CMFormat = new CMFormat(cam, camNames);
					this.dispatchEvent(new CMEvent(CMEvent.MULTI_CAMERA, false, true, i));
				}
			}
			return cam;
		}
		
		private function activityHandler(evt:ActivityEvent):void
		{
			var __cam:Camera = evt.currentTarget as Camera;
//			trace('//=================org.zengrong.media.cm.CM');
//			trace('activityHandler发生,activating:',evt.activating);
//			trace('camera name:',__cam.name);
//			trace('camera width:',__cam.width);
//			trace('camera height:',__cam.height);
//			trace('=============================//');
			var i:CMFormat = new CMFormat(__cam, camNames);
			var __event:CMEvent = 	evt.activating ? 
									new CMEvent(CMEvent.ACTIVITY_START, false, true, i) :
									new CMEvent(CMEvent.ACTIVITY_STOP, false, true, i);
			this.dispatchEvent(__event);

		}
		
		private function camStatusHandler(evt:StatusEvent):void
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
			trace("摄像头是否禁用："+cam.muted);
			trace("待发布的事件："+CMEvent.toEvent(cam));
			trace('=============================//');
			var i:CMFormat = new CMFormat(cam, camNames, $isManual);
			var e:CMEvent = new CMEvent(CMEvent.toEvent(cam), false, true, i);
			this.dispatchEvent(e); 
		}
		
		/**
		 * 检测麦克风数量，不需要参数
		 * 如果麦克风数量大于1，则显示一个列表进行选择。如果
		 **/
		public function checkMic():Microphone
		{
			if(micAmount <= 0){
				this.dispatchEvent(new CMEvent(CMEvent.NO_MICROPHONE));	//发布摄像头检测消息
			}else{
				mic = Microphone.getMicrophone();
				mic.addEventListener(StatusEvent.STATUS, micStatusHandler);
				checkMicStatus();
			}
			return mic;
		}
		
		private function micStatusHandler(evt:StatusEvent):void
		{
			checkMicStatus();
		}
		
		/**
		 * 检查麦克风的当前状态并发布，没有参数
		 **/
		private function checkMicStatus():void
		{
			var i:CMFormat = new CMFormat(mic, micNames);
			var e:CMEvent = new CMEvent(CMEvent.toEvent(mic),false, true, i);
			this.dispatchEvent(e);	
		}
		
		//============================================================================下面的代码实现CM类的事件功能
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, weakRef:Boolean = false):void 
		{
			eventDispatcher.addEventListener(type, listener, useCapture, priority, weakRef);
		}	
			
		public function dispatchEvent(event:Event):Boolean 
		{
			return eventDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean 
		{
			return eventDispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
		{
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean 
		{
			return eventDispatcher.willTrigger(type);
		}
		//============================================================================实现事件功能的代码完毕
		
	}
}