package org.zengrong.utils
{
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	
	//
	
	public class JS
	{
		public static function alert($info:String, $title:String=''):void
		{
			if(ExternalInterface.available)
			{
				try
				{
					ExternalInterface.call('alert', $info);
				}
				catch(err:Error)
				{
					trace(err);
					Alert.show(err.toString(), '調用容器失敗');
				}
			}
			else
			{
				Alert.show($info, $title, 4, FlexGlobals.topLevelApplication as Sprite);
			}
		}
		
		public static function close($error:String='窗口關閉'):void
		{
			if(ExternalInterface.available)
			{
				try
				{
					ExternalInterface.call('window.close');
				}
				catch(err:Error)
				{
					trace(err);
					Alert.show(err.toString(), '調用容器失敗');
				}
			}
			else
			{
				Alert.show($error);
			}
		}
		
		/**
		* 弹出JavaScript confirm确认对话框，根据用户的交互返回是否确认布尔值
		* @param $s	要显示的信息
		* @param $closeFun 关闭确认对话框时调用的函数
		*/
		public static function confirm($s:String, $closeFun:Function, $title:String=''):void
		{
			var __fun:Function = function(evt:CloseEvent):void
			{
				$closeFun(evt.detail == Alert.YES);
			}
			if(ExternalInterface.available)
			{
				try
				{
					$closeFun(ExternalInterface.call('confirm', $s));
				}
				catch(err:Error)
				{
					trace(err);
					Alert.show(err.toString(), '調用容器失敗');
				}
			}
			else
			{
				Alert.show($s, $title, Alert.YES|Alert.NO, FlexGlobals.topLevelApplication as Sprite, __fun);
			}	
		}
	}
}