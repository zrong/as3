package org.zengrong.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.display.Loader;
	import flash.events.Event;
	
	public class ImageDecoder
	{
		private var _loader:Loader = new Loader();
		public var loading:Boolean;
		
		/**
		 * 将载入的ByteArray转换成BitmapData。
		 * @param $byte	图片文件的ByteArray
		 * @param $callBack 图片文件载入完毕后的回调函数。
		 */
		public function ImageDecoder($byte:ByteArray, $callBack:Function) {
			loading = true;
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
				function(e:Event){
					loading = false;
					var __bitmapData:BitmapData = Bitmap(e.target.content).bitmapData;
					$callBack.call(null, __bitmapData);
				});
			_loader.loadBytes($byte);
		}
	}
}