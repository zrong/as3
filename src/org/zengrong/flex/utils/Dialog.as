package org.zengrong.flex.utils
{
	import flash.display.Sprite;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	
	public class Dialog
	{
		public static function alert($info:String, $title:String='', $parent:Sprite=null):void
		{
			var __parent:Sprite = $parent ? $parent : FlexGlobals.topLevelApplication as Sprite;
			Alert.show($info, $title, 4, __parent);
		}
		
		/**
		* 弹出confirm确认对话框，根据用户的交互返回是否确认布尔值
		* @param $s	要显示的信息
		* @param $closeFun 关闭确认对话框时调用的函数
		*/
		public static function confirm($s:String, $closeFun:Function, $title:String='', $parent:Sprite=null):void
		{
			var __fun:Function = function(evt:CloseEvent):void
			{
				$closeFun(evt.detail == Alert.YES);
			}
			var __parent:Sprite = $parent ? $parent : FlexGlobals.topLevelApplication as Sprite;
			Alert.show($s, $title, Alert.YES|Alert.NO, __parent, __fun);
		}
	}
}