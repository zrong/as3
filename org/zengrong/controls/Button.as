package org.zengrong.controls
{
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.text.TextField;

	public class Button extends Sprite
	{
		private var _buttonString:String;
		private var _txt:TextField;
		private var _bgColor:uint;
		private var _txtColor:uint;
		private var _w:Number;
		private var _h:Number;
		
		public function Button($txt:String, $w:Number=100, $h:Number=30, $bgColor:uint=0xffffff, $txtColor:uint=0x000000)
		{
			super();			
			buildButton($w, $h, $bgColor);
			buildText($txt, $txtColor);
		}
		
		public function buildButton($w:Number, $h:Number, $color:uint):void
		{
			_bgColor = $color;
			_w = $w;
			_h = $h;
			this.graphics.clear();
			this.graphics.beginFill($color);
			this.graphics.lineStyle(1, 0x000000, 1, true, LineScaleMode.NONE);
			this.graphics.drawRect(0, 0, $w, $h);
		}
		
		public function buildText($txt:String, $color:uint=0x000000):void
		{
			if(_txt)
			{
				if(this.contains(_txt)) this.removeChild(_txt);
			}
			_txtColor = $color;
			_buttonString = $txt;
			_txt = new TextField();
			_txt.selectable = false;
			_txt.text = $txt;
			_txt.textColor = $color;
			_txt.width = _w;
			_txt.height = _h;
			resizeText();
			this.addChild(_txt);
		}
		
		private function resizeText():void
		{
			_txt.x = (this.width - _txt.textWidth)/2-2;
			_txt.y = (this.height - _txt.textHeight)/2-2;
//			trace(this.width, this.height, _txt.textWidth, _txt.textHeight, _txt.width, _txt.height, _txt.x, _txt.y);
		}
		
	}
}