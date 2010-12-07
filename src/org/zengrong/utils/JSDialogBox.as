////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-11-24
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.utils
{
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	
	/**
	 * 使用JS的alert、confirm、close来与用户浏览器交互
	 * @author zrong
	 */	
	public class JSDialogBox
	{
		private static const ERROR_TXT:String = '必须在浏览器环境下才能调用。';
		/**
		 * 弹出一个JS的Alert对话框 
		 * @param $info 要显示的消息
		 */		
		public static function alert($info:String):void
		{
			if(ExternalInterface.available)
			{
				ExternalInterface.call('alert', $info);
			}
			else
			{
				throw new Error(ERROR_TXT);
			}
		}
		
		/**
		 * 关闭一个浏览器窗口 
		 */		
		public static function close():void
		{
			if(ExternalInterface.available)
			{
				ExternalInterface.call('window.close');
			}
			else
			{
				throw new Error(ERROR_TXT);
			}
		}
		
		/**
		* 弹出JavaScript confirm确认对话框，根据用户的交互返回是否确认布尔值
		* @param $info 要显示的信息
		* @param $closeFun 关闭确认对话框时调用的函数，该函数必须包含1个Boolean参数，如果用户选择确认，则这个参数为true
		*/
		public static function confirm($info:String, $closeFun:Function):void
		{
			if(ExternalInterface.available)
			{
				$closeFun(ExternalInterface.call('confirm', $info));
			}
			else
			{
				throw new Error(ERROR_TXT);
			}
		}
	}
}