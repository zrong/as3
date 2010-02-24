package org.zengrong.media
{
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.NetStream;
	
	import mx.core.UIComponent;
	
	//
	[Bindable]
	public class VideoDisplay extends UIComponent
	{
		private var _video:Video;
		private var _type:int;
		private var _playing:Boolean = false;
		
		public static const NETSTREAM:int = 1;
		public static const CAMERA:int = 2;
		
		public function VideoDisplay($width:int=320, $height:int=240)
		{
			this.width = $width;
			this.height = $height;
		}
		
		public function get type():int
		{
			return _type;
		}
		
		public function get playing():Boolean
		{
			return _playing;
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
			_type = NETSTREAM;
			_playing = true;
			_video.clear();
			_video.attachNetStream($ns);
			_video.visible = true;
//			trace('VideoDisplay.attachNetStream,ns:', $ns);
		}
		
		public function attachCamera($cam:Camera):void
		{
			_type = CAMERA;
			_playing = true;
			_video.clear();
			_video.attachCamera($cam);
			_video.visible = true;
//			trace('VideoDisplay.attachCamera:_video.width:',_video.width,'$cam.width:',$cam.width);
		}			
		
		public function clear():void
		{
//			trace(Util.getTime(), "//**** VideoDisplay.clear 执行****//");
			if(type == NETSTREAM)
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
		
		protected override function updateDisplayList(unscaledWidth: Number, unscaledHeight:Number):void 
		{
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