package org.zengrong.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
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
														function(evt:Event):void{
															loading = false;
															$callBack.call(null, Bitmap(evt.target.content));
														});
			_loader.loadBytes($byte);
		}
		
		//将可视的UIComponent组件转换为ByteArray数组，我就是在UIComponent那里放了一个图片 
		public static function BitmapDataToByteArray(target:DisplayObject):ByteArray
		{ 
			var imageWidth:uint = target.width; 
			var imageHeight:uint = target.height; 
			var srcBmp:BitmapData = new BitmapData( imageWidth, imageHeight ); 
			//将组件读取为BitmapData对象，bitmagData的数据源 
			srcBmp.draw( target ); 
			//getPixels方法用于读取指定像素区域生成一个ByteArray，Rectangle是一个区域框，就是起始坐标 
			var pixels:ByteArray = srcBmp.getPixels( new Rectangle(0,0,imageWidth,imageHeight) ); 
			//下面俩行将数据源的高和宽一起存储到数组中,为翻转的时候提供高度和宽度 
			pixels.writeShort(imageHeight); 
			pixels.writeShort(imageWidth); 
			return pixels; 
		} 
		
		//次方法的参数必须是像上面的ByteArray形式一样的,即需要对象的大小; 
		//此方法返回的Bitmap可以直接赋值给Image的source属性 
		public static function ByteArrayToBitmap(byArr:ByteArray):Bitmap
		{ 
			if(byArr==null){ 
				return null; 
			} 
			//读取出存入时图片的高和宽,因为是最后存入的数据,所以需要到尾部读取 
			var bmd:ByteArray= byArr; 
			bmd.position=bmd.length-2; 
			var imageWidth:int = bmd.readShort(); 
			bmd.position=bmd.length-4; 
			var imageHeight:int= bmd.readShort(); 
			var copyBmp:BitmapData = new BitmapData( imageWidth, imageHeight, true ); 
			//利用setPixel方法给图片中的每一个像素赋值,做逆操作 
			//ByteArray数组从零开始存储一直到最后都是图片数据,因为读入时的高和宽都是一样的,所以当循环结束是正好读完 
			bmd.position = 0; 
			for( var i:uint=0; i<imageHeight ; i++ ) 
			{ 
				for( var j:uint=0; j<imageWidth; j++ ) 
				{ 
					copyBmp.setPixel( j, i, bmd.readUnsignedInt() ); 
				} 
			} 
			var bmp:Bitmap = new Bitmap( copyBmp ); 
			return bmp; 
		}
		
	}
}