////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  修改:zrong
//	说明：本组件参照Keith Peters的Minimalcomps组件写成，修改、使用或继承Minimalcal源码
//	修改列表：
//		2011-01-02 加入静态的COLORLESS_FILTER变量
//
////////////////////////////////////////////////////////////////////////////////
 /**
 * Style.as
 * Keith Peters
 * version 0.9.7
 * 
 * A collection of style variables used by the components.
 * If you want to customize the colors of your components, change these values BEFORE instantiating any components.
 * 
 * Copyright (c) 2010 Keith Peters
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 
package org.zengrong.controls.supportClasses
{
import flash.filters.ColorMatrixFilter;

import org.zengrong.utils.ColorMatrix;

	public class Style
	{
		public static var BACKGROUND:uint = 0xCCCCCC;
		public static var BUTTON_FACE:uint = 0xFFFFFF;
		public static var INPUT_TEXT:uint = 0x333333;
		public static var LABEL_TEXT:uint = 0x666666;
		public static var DROPSHADOW:uint = 0x000000;
		public static var PANEL:uint = 0xF3F3F3;
		public static var PROGRESS_BAR:uint = 0xFFFFFF;
		public static var COLORLESS_FILTER:ColorMatrixFilter = new ColorMatrixFilter(ColorMatrix.COLORLESS);
		
		public static var embedFonts:Boolean = false;
		public static var fontName:String = "simsun";
		public static var fontSize:Number = 12;
	}
}