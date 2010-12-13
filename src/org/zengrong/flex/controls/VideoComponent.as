package org.zengrong.flex.controls
{
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.core.UIComponent;
	
	import org.zengrong.media.NetConnectionInfoCode;

	[Event(name='close', type='flash.events.Event')]
	[Event(name='complete', type='flash.events.Event')]
	
	/**
	 * 与org.zengrong.display.VideoDisplay基本相同，只是用于Flex框架。 
	 */	
	[Bindable]
	public class VideoComponent extends UIComponent
	{
		public static const URISTREAM:String = 'uristream'
		public static const NETSTREAM:String = 'netstream';
		public static const CAMERA:String = 'camera';
		
		private var _video:Video;
		private var _type:String;
		private var _playing:Boolean = false;
		private var _streamName:String;
		private var _serverURI:String;
		private var _nc:NetConnection;
		private var _ns:NetStream;
		
		private var _videoWidth:Number;
		private var _videoHeight:Number;
		private var _maintainAspectRatio:Boolean;
		private var _muted:Boolean;
		
		public function VideoComponent($width:int=320, $height:int=240)
		{
			this.width = $width;
			this.height = $height;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get playing():Boolean
		{
			return _playing;
		}
		
		public function get videoWidth():Number
		{
			return _videoWidth;
		}
		
		public function set videoWidth($num:Number):void
		{
			_videoWidth = $num;
		}
		
		public function get videoHeight():Number
		{
			return _videoHeight;
		}
		
		public function set videoHeight($num:Number):void
		{
			_videoHeight = $num;
		}
		
		public function get muted():Boolean
		{
			return _muted;
		}
		
		public function set muted($muted:Boolean):void
		{
			_muted = $muted;
			setMuted();			
		}
		
		public function get maintainAspectRatio():Boolean
		{
			return _maintainAspectRatio;
		}
		
		public function set maintainAspectRatio($maintainAspectRatio:Boolean):void
		{
			_maintainAspectRatio = $maintainAspectRatio;
		}
		
		protected override function createChildren(): void 
		{
			super.createChildren();
			if(_video)
			{
				_video.width = this.width;
				_video.height = this.height;
			}
			else
			{
				_video = new Video(this.width, this.height);
			}
			this.addChild(_video);
			_video.visible = false;
//			trace('VideoDisplay.createChildren,width:',this.width,',height:', height);
		}
		
		public function attachNetStream($ns:NetStream):void
		{
			if(type != null) throw new Error('VideoDisplay已經被用於NetStream視訊！');
			_type = NETSTREAM;
			_playing = true;
			_video.clear();
			_video.attachNetStream($ns);
			_video.visible = true;
//			trace('VideoDisplay.attachNetStream,ns:', $ns);
		}
		
		public function attachCamera($cam:Camera):void
		{
			if(type != null) throw new Error('VideoDisplay已經被用於Camera視訊！');
			_type = CAMERA;
			_playing = true;
			_video.clear();
			_video.attachCamera($cam);
			_video.visible = true;
//			trace('VideoDisplay.attachCamera:_video.width:',_video.width,'$cam.width:',$cam.width);
		}
		
		public function attachURIStream($serverURI:String, $streamName:String, $param:*=null):void
		{
			var __streamNameArr:Array = $streamName.split('.');
			//如果当前类型为空，就初始化
			if(type == null || type == URISTREAM) 
			{
				_serverURI = $serverURI;
				//将streamName变成需要的形式
				_streamName = __streamNameArr[1] + ':' + __streamNameArr[0];
				initnc();
				_nc.connect(_serverURI, $param);
				_video.visible = true;
				_type = URISTREAM;	
			}	
			else
			{
				throw new Error('VideoDisplay已經被用於其它視訊！');		
			}
		}
		
		private function initnc():void
		{
			if(_nc == null)
			{
				_nc = new NetConnection();
				_nc.addEventListener(NetStatusEvent.NET_STATUS, ncStatus_Handler);
			}
			else
			{
				if(_nc.connected)
				{
					close();
				}
			}
		}
		
		private function ncStatus_Handler(evt:NetStatusEvent):void
		{
//			trace('VideoDisplay,nc statue:', evt.info.code);
			switch(evt.info.code)
			{
				case NetConnectionInfoCode.SUCCESS:
					if(_ns == null)
					{
						_ns = new NetStream(_nc);
						_ns.addEventListener(NetStatusEvent.NET_STATUS, nsStatus_Handler);
						_ns.client = new StreamClient(this);
						setMuted();
						trace('_ns.soundTransform.volume:', _ns.soundTransform.volume);
					}
					_ns.play(_streamName);
					_video.attachNetStream(_ns);
					trace('nc success， uri:', _nc.uri, ' streamName:', _streamName);
					break;
				case NetConnectionInfoCode.CLOSED:
					if(_ns != null)
					{
						_ns.close();
						_ns.removeEventListener(NetStatusEvent.NET_STATUS, nsStatus_Handler);
						_ns = null;
					}
					dispatchEvent(new Event(Event.CLOSE));
					break;
			}
		}
		
		private function setMuted():void
		{
			if(_ns == null) return;
			var __st:SoundTransform = _ns.soundTransform;
			__st.volume = muted ? 0 : 1;
			_ns.soundTransform = __st;
		}
		
		private function nsStatus_Handler(evt:NetStatusEvent):void
		{
//			trace('VideoDisplay,ns statue:', evt.info.code);
		}
		
		public function clear():void
		{
//			trace(Util.getTime(), "//**** VideoDisplay.clear 执行****//");
			if((type==NETSTREAM) || (type==URISTREAM))
			{
				_video.attachNetStream(null);
//				trace(Util.getTime(), "停止显示NetStream");
			}
			else if(type == CAMERA)
			{				
				_video.attachCamera(null);
//				trace(Util.getTime(), "停止显示Camera");
			}
			_playing = false;
			_video.clear();
			_video.visible = false;
//			trace(Util.getTime(), "清除显示内容");
			
		}
		
		public function close():void
		{
			clear();
			if(_type == URISTREAM)
			{
				if(_nc.connected) _nc.close();
			}
			_type = null;
		}
		
		protected override function updateDisplayList(unscaledWidth: Number, unscaledHeight:Number):void 
		{
/* 			var __width:Number = unscaledWidth;
			var __height:Number = unscaledHeight;
			if(maintainAspectRatio && isNaN(videoWidth) && isNaN(videoHeight))
			{
				if(__width > __height)
				{
					__width = 
				}				
			} */
			super.updateDisplayList(unscaledWidth, unscaledHeight);
//			trace(Util.getTime(), "VideoDisaplay中的updateDisplayList运行,type:", type, ",unscaledWidth:",unscaledWidth,",unscaledHeight:",unscaledHeight);
			_video.width = unscaledWidth;
			_video.height = unscaledHeight;
//			_video.clear();
//			trace(Util.getTime(), "_video.width,height:",_video.width,_video.height);
//			trace(Util.getTime(), "this.width,height:",this.width,this.height);
		}
	}
}

import flash.events.Event;

import org.zengrong.flex.controls.VideoComponent;

class StreamClient
{
	private var _videoDisplay:VideoComponent;
	
	public function StreamClient($video:org.zengrong.flex.controls.VideoComponent)
	{
		_videoDisplay = $video;
	} 

	public function onPlayStatus($obj:Object):void
	{
		trace('NetStream.onPlayStatus:', $obj.code);
		if($obj.code == 'NetStream.Play.Complete')
		{
			_videoDisplay.dispatchEvent(new Event(Event.COMPLETE));
		}
	}
	
	public function onMetaData($obj:Object):void
	{
		trace('NetStream.onMetaData(width,height):', $obj.width, $obj.height);
		_videoDisplay.videoWidth = $obj.width;
		_videoDisplay.videoHeight = $obj.height;
	}
}