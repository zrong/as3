package org.zengrong.flex.controls
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;

	public class Loader extends UIComponent
	{
		private var _loader:flash.display.Loader;
		private var _url:String;
		
		public function Loader($width:Number=0, $height:Number=0)
		{
			super();
			if($width != 0) this.width = $width; 
			if($height != 0) this.height = $height;
			buildLoader();	
		}
		
		public function get contentWidth():Number
		{
			return _loader.contentLoaderInfo.content.width;
		}
		
		public function get contentHeight():Number
		{
			return _loader.contentLoaderInfo.content.height;
		}
		
		private function buildLoader():void
		{
			_loader = new flash.display.Loader();
			_loader.contentLoaderInfo.addEventListener(Event.INIT, loader_initHandler);
			_loader.addEventListener('quit', quit_handler);
			
			addEventListener(FlexEvent.ADD, add_handler);
			addEventListener(FlexEvent.REMOVE, remove_handler);
//			trace('buildLoader:', this.width, this.height);
			
		}
		
		private function add_handler(evt:FlexEvent):void
		{
			trace('Loader added');
		}
		
		private function remove_handler(evt:FlexEvent):void
		{
			trace('Loader removed');
		}		
		
		protected override function createChildren(): void 
		{
			super.createChildren();						
			addChild(_loader);	
		}
		
		private function loader_initHandler(evt:Event):void
		{
			//不能直接设置Loader的大小，否则会导致载入的内容不能显示。应该在Loader载入成功后设置其内容的大小。
			var __li:LoaderInfo = evt.currentTarget as LoaderInfo;
			var __loader:DisplayObject = __li.content as DisplayObject; 			
			trace('loaderContent:', contentWidth, contentHeight, __li.actionScriptVersion);
			
			if(this.width!=0) __loader.width = this.width;
			if(this.height!=0) __loader.height = this.height;
		}
		
		private function quit_handler(evt:Event):void
		{
			_loader.unload();
			trace('收到魔法表情发来的推出信息');
		}
		
		public function load($url:String):void
		{
	 		_url = $url;
			_loader.load(new URLRequest(_url)); 
		}
		
  		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
//			_loader.width = unscaledWidth;
//			_loader.height = unscaledHeight;
			trace('_loader.contentLoaderInfo:', _loader.contentLoaderInfo);
		}  
		
	}
}