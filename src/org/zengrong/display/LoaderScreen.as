////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong
//  创建时间：2011-10-16
//  更新时间：2011-10-16
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.display
{
import flash.display.Sprite;
import flash.display.Loader;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.system.LoaderContext;
import flash.system.ApplicationDomain;
import flash.net.URLRequest;
/**
 * 一个完整的载入swf，用于为纯as3项目提供载入功能
 */
[SWF(width=900,height=400,backgroundColor=0xDF358A,frameRate=12)]
public class LoaderScreen extends Sprite
{
	public function LoaderScreen()
	{
		init();
	}

	private var _loader:Loader;
	private var _tf:TextField;
	private var _bar:Shape;

	private function init():void
	{
		this.stage.scaleMode = StageScaleMode.NO_SCALE;
		this.stage.align = StageAlign.TOP_LEFT;
		this.stage.showDefaultContextMenu = false;
		this.stage.addEventListener(Event.RESIZE, handler_resize);
		//加一个textField显示进度
		_tf = this.addChild(new TextField()) as TextField;
		with(_tf)
		{
			selectable = false;
			defaultTextFormat = new TextFormat(null,13,0xFFFFFF,null,null,null,null,null,"center");
			mouseEnabled = false;
			height = 25;
			text = "载入中...";
		}
		_bar = this.addChild(new Shape()) as Shape;
		center();

		_loader = new Loader();
		_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, handler_progress);
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handler_complete);
		//从外部参数中传入要载入的文件
		var __main:String = this.loaderInfo.parameters.main;
		if(!__main) throw new TypeError('必须提供要载入的文件！请设置URL变量中的main变量。');
		_loader.load(new URLRequest(__main), new LoaderContext(true, ApplicationDomain.currentDomain));
	}

	//显示进度
	private function handler_progress($evt:ProgressEvent):void
	{
		var __per:int = $evt.bytesLoaded/$evt.bytesTotal*100;
		_tf.text = __per.toString() +"% 载入中...";
		_bar.graphics.clear();
		_bar.graphics.beginFill(0xFFFFFF);
		_bar.graphics.drawRect(0,0,__per,15);
		_bar.graphics.endFill();
	}

	private function handler_complete($evt:Event):void
	{
		this.addChild(_loader.content);
		_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, handler_progress);
		_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, handler_complete);
		this.removeChild(_bar);
		this.removeChild(_tf);
	}

	private function handler_resize($evt:Event):void
	{
		trace('resize:', this.stage.stageWidth, this.stage.stageHeight);
		center();
	}

	private function center():void
	{
		if(_tf)
		{
			_tf.x = (stage.stageWidth-100)/2;
			_tf.y = stage.stageHeight*.5+10;
		}
		if(_bar)
		{
			_bar.x = (stage.stageWidth-100)/2;
			_bar.y = stage.stageHeight*.5-20;
		}
	}
}
}
