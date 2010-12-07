/**
 * 提示声音类
 * 提供一组声音的载入，并提供播放这些声音的方法
 */
package org.zengrong.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	
	import org.zengrong.events.InfoEvent;

	public class SoundLoader extends EventDispatcher
	{
		private var _inSound:Sound;
		private var _outSound:Sound;
		private var _warningSound:Sound;
		
		private var _soundList:Array = [];
		
		
		private static var INSTANCE:SoundLoader;
		private static var URL_LIST:Array;
		//
		public static const IN_SOUND:String = "in";
		public static const OUT_SOUND:String = "out";
		public static const WARNING_SOUND:String = "warning";
		
		public static const LOAD_ONCE_START:String = "loadOnceStart";
		public static const LOAD_ALL_COMPLETE:String = "loadSoundAllComplete";
		
		private var _loadedNum:uint = 0;	//已经载入的声音的个数		
		
		public function SoundLoader($sig:SingletonEnforcer)
		{
			while(URL_LIST.length>0)
			{
				var __sound:Sound = new Sound();
				__sound.addEventListener(Event.COMPLETE, _loadComplete);
				__sound.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
				__sound.addEventListener(ProgressEvent.PROGRESS, _progressHandler);
				_soundList.push([__sound, URL_LIST.shift()]);
			}
		}
		
		public static function getInstance($url:Array):SoundLoader
		{
			if(INSTANCE == null) {
				if($url.length==0) throw Error('必須提供音效文件地址！');
				URL_LIST = $url;
				INSTANCE = new SoundLoader(new SingletonEnforcer());
			}
			return INSTANCE;
		}
		
		public function load():void
		{
			if(_loadedNum >= _soundList.length)
			{
				this.dispatchEvent(new Event(LOAD_ALL_COMPLETE));
				return;
			}
			var __aSound:Array = _soundList[_loadedNum] as Array; 
			Sound(__aSound[0]).load(new URLRequest(__aSound[1]));
			//发出开始载入一个声音的事件
			this.dispatchEvent(new Event(LOAD_ONCE_START));
		}
		
		public function play($url:String):void
		{
			if(_soundList.length==0) return;
			for(var i:int=0; i<_soundList.length; i++)
			{
				if(String(_soundList[i][1]) == $url)
				{
					Sound(_soundList[i][0]).play();
				}
			}
		}
		
		//返回当前正在载入的声音的索引号
		public function get soundIndex():int
		{
			return _loadedNum;
		}
		
		private function _loadComplete(evt:Event):void
		{
			trace("载入完成第", _loadedNum, "个音频");
			this.dispatchEvent(evt);
//			Sound(_soundList[_loadedNum][0]).play();
			_loadedNum ++;
			//如果数组中还有声音没有载入，就继续载入
			if(_loadedNum < _soundList.length){
				load();		
			}
			//否则，就发布载入完毕的事件
			else
			{
				this.dispatchEvent(new Event(LOAD_ALL_COMPLETE));
				trace("所有音频载入完毕");
			}
		}
		
		private function _progressHandler(evt:ProgressEvent):void
		{
			this.dispatchEvent(evt);
		}
		
		private function _ioErrorHandler(evt:IOErrorEvent):void
		{
			this.dispatchEvent(evt);
		}
	}
}

class SingletonEnforcer {}