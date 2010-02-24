package org.zengrong.utils
{
	import flash.display.Sprite;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.CloseEvent;
	
	public class Dialog
	{
		public static function alert($info:String, $title:String=''):void
		{
			Alert.show($info, $title, 4, Application.application as Sprite);
		}
		
		/**
		* 弹出confirm确认对话框，根据用户的交互返回是否确认布尔值
		* @param $s	要显示的信息
		* @param $closeFun 关闭确认对话框时调用的函数
		*/
		public static function confirm($s:String, $closeFun:Function):void
		{
			var __fun:Function = function(evt:CloseEvent):void
			{
				$closeFun(evt.detail == Alert.YES);
			}
			Alert.show($s, '', Alert.YES|Alert.NO, Application.application as Sprite, __fun);
		}
	}
}