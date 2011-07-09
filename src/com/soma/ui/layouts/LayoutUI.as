/**
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 * 
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied.
 * See the License for the specific language governing rights and
 * limitations under the License.
 * 
 * The Original Code is BaseUI.
 * 
 * The Initial Developer of the Original Code is Romuald Quantin.
 * romu@soundstep.com (www.soundstep.com).
 * 
 * Portions created by
 * 
 * Initial Developer are Copyright (C) 2008-2010 Soundstep. All Rights Reserved.
 * All Rights Reserved.
 * 
 * BaseUI version: 4.0
 * Actionscript version: 3.0
 * Copyright: Mozilla Public License 1.1 (MPL 1.1) - http://www.opensource.org/licenses/mozilla1.1.php
 * 
 * You can use BaseUI in any flash site, except to include/distribute it in another framework, application, template, component or structure that is meant to build, scaffold or generate source files.
 * 
 */
 
 package com.soma.ui.layouts {
	import com.soma.ui.BaseUI;
	import com.soma.ui.ElementUI;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;


	/**
	 * The LayoutUI class is a base for other layout classes (such as CanvasUI, HBoxUI, VBoxUI, TileUI), but can be used as a basic container.
	 * A LayoutUI instance is a DisplayObjectContainer, as it extends MovieClip, and add ElementUI properties (top, right, ratio, etc).
	 * The LayoutUI class does not implements any ElementUI properties on its children, it is the difference with the CanvasUI class.
	 * The difference between the MovieClip class and the LayoutUI class, beside having ElementUI properties accessible,
	 * is that it ensures the instance always have the width and height values (related to its scale) that you have set,
	 * even if some children are outside the boundaries.
	 * 
	 * For example, for a LayoutUI instance with a width of 100, that has a children with a width that changes all the time (with a motion) from 100 to 300,
	 * The width value returned by the class will always be 100, while a normal DisplayObject class would return values between 100 and 300. 
	 * 
	 * @example
	 * <listing version="3.0">
	 * var layout:LayoutUI = new LayoutUI(stage, 400, 300);
	 * layout.backgroundColor = 0xFF0000;
	 * layout.backgroundAlpha = 0.2;
	 * layout.ratio = ElementUI.RATIO_IN;
	 * layout.refresh();
	 * addChild(layout);
	 * </listing>
	 * 
	 * @see com.soma.ui.ElementUI
	 * @see com.soma.ui.layouts.CanvasUI
	 * @see com.soma.ui.layouts.HBoxUI
	 * @see com.soma.ui.layouts.VBoxUI
	 * @see com.soma.ui.layouts.TileUI
	 * 
	 */
	
	public class LayoutUI extends Sprite {

		//------------------------------------
		// private, protected properties
		//------------------------------------
		
		/** @private */
		protected var _ui:BaseUI;
		/** @private */
		protected var _reference:DisplayObjectContainer;
		/** @private */
		protected var _element:ElementUI;
		
		/** @private */
		protected var _layouts:Array;
		
		/** @private */
		protected var _width:Number;
		/** @private */
		protected var _height:Number;
		
		/** @private */
		protected var _backgroundColor:uint = 0;
		/** @private */
		protected var _backgroundAlpha:Number = 0;
		
		/** @private */
		protected var _hideOutsideContent:Boolean = false;
		
		/** @private */
		protected var _enable:Boolean = true;

		//------------------------------------
		// public properties
		//------------------------------------
		
		//------------------------------------
		// constructor
		//------------------------------------
		
		/**
		 * Create a LayoutUI instance
		 * @param reference DisplayObjectContainer instance used to calculate the size and position of the layout instance
		 * @param width width of the layout (not disturbed by children)
		 * @param height height of the layout (not disturbed by children)
		 * @see #getRealWidth()
		 * @see #getRealHeight()
		 */
		public function LayoutUI(reference:DisplayObjectContainer, width:Number = 100, height:Number = 100) {
			_reference = reference;
			_width = width;
			_height = height;
			initialize();
		}
		
		//
		// PRIVATE, PROTECTED
		//________________________________________________________________________________________________
		
		/** @private */
		protected function initialize():void {
			_ui = new BaseUI(_reference);
			_element = _ui.add(this);
			_element.reference = _reference;
			_layouts = []; 
			draw();
		}
		
		/** @private */
		protected function draw():void {
			graphics.clear();
			graphics.beginFill(_backgroundColor, _backgroundAlpha);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			updateScrollRect();
		}
		
		/** @private */
		protected function updateScrollRect():void {
			if (_hideOutsideContent) scrollRect = new Rectangle(0, 0, _width, _height);
			else scrollRect = null;
		}
		
		/** @private */
		protected function refreshLayouts():void {
			if (_layouts == null) return;
			var i:Number = 0;
			var l:Number = _layouts.length;
			for (i; i<l; ++i) {
				LayoutUI(_layouts[i]).refresh();
			}
		}
		
		/** @private */
		protected function removeLayout(layout:LayoutUI):void {
			var i:Number = 0;
			var l:Number = _layouts.length;
			for (i; i<l; ++i) {
				if (layout == _layouts[i]) _layouts.splice(i, 1);
			}
		}
		
		// PUBLIC
		//________________________________________________________________________________________________
		
		/**
		 * Destroys the instance so it can be garbage collected. Automatically called when you remove an object from the BaseUI instance.
		 * @see com.soma.ui.BaseUI.remove()
		 * @see com.soma.ui.BaseUI.removeAll()
		 */
		public function dispose():void {
			// dispose objects, graphics and events listeners
			try {
				if (_ui != null) {
					_ui.dispose();
					_ui = null;
				}
				_reference = null;
				_element = null;
				// dispose layout
				if (_layouts != null) {
					while (_layouts.length > 0) {
						var layout:LayoutUI = _layouts[0];
						layout.dispose();
						super.removeChildAt(0);
						layout = null;
						_layouts.splice(0, 1);
					}
				}
				_layouts = null;
				// dispose children
				while (numChildren > 0) {
					var child:DisplayObject = getChildAt(0);
					if (child != null) {
						if (child.hasOwnProperty("dispose")) child['dispose']();
						super.removeChildAt(0);
						child = null;
					}
				}
			} catch(e:Error) {
				trace("Error in", this, name, "(dispose method):", e.message);
			}
		}
		
		/** @private */
		override public function addChild(child:DisplayObject):DisplayObject {
			if (child is LayoutUI) _layouts.push(child);
			return super.addChild(child);
		}
		
		/** @private */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			if (child is LayoutUI) _layouts.push(child);
			return super.addChildAt(child, index);
		}
		
		/** @private */
		override public function removeChild(child:DisplayObject):DisplayObject {
			if (child is LayoutUI && _layouts.length > 0) removeLayout(LayoutUI(child));
			return super.removeChild(child);
		}
		
		/** @private */
		override public function removeChildAt(index:int):DisplayObject {
			var child:DisplayObject = getChildAt(index);
			if (child is LayoutUI && _layouts.length > 0) removeLayout(LayoutUI(child));
			return super.removeChildAt(index);
		}
		
		/**
		 * Background color of the layout instance
		 * @default 0x000000;
		 */
		public function get backgroundColor():uint {
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:uint):void {
			_backgroundColor = value;
			draw();
		}
		
		/**
		 * Transparency of the layout instance background (alpha)
		 * @default 0;
		 */
		public function get backgroundAlpha():Number {
			return _backgroundAlpha;
		}
		
		public function set backgroundAlpha(value:Number):void {
			_backgroundAlpha = value;
			draw();
		}
		
		/**
		 * ElementUI class internally used, it manages the directly accessible layout properties such as top, bottom, ratio, etc. The EventUI listeners must be added to it.
		 */
		public function get element():ElementUI {
			return _element;
		}
		
		/**
		 * Hide the area of the DisplayObject children that are outside the boundaries (width and height)
		 * @default false;
		 */
		public function get hideOutsideContent():Boolean {
			return _hideOutsideContent;
		}
		
		public function set hideOutsideContent(value:Boolean):void {
			_hideOutsideContent = value;
			updateScrollRect();
		}
		
		// BaseUI methods
		
		/**
		 * Calculate and update the position and size of the layout
		 * @see com.soma.ui.ElementUI#refresh()
		 */
		public function refresh():void {
			if (_ui != null) _ui.refresh();
			refreshLayouts();
		}
		
		/**
		 * Re-set all the ElementUI instance properties of the layout to initial values (NaN for numbers, and center for alignment)
		 * @see com.soma.ui.ElementUI#reset()
		 */
		public function reset():void {
			_element.reset();
		}
		
		/**
		 * Distance from the top of the reference to the top of the layout instance (Y axis)
		 * @return A Number
		 * @see com.soma.ui.ElementUI#top
		 */
		public function get top():Number {
			return _element.top;
		}

		public function set top(value:Number):void {
			_element.top = value;
		}
		
		/**
		 * Distance from the bottom of the reference to the bottom of the layout instance (Y axis)
		 * @return A Number
		 * @see com.soma.ui.ElementUI#bottom
		 */
		public function get bottom():Number {
			return _element.bottom;
		}
		
		public function set bottom(value:Number):void {
			_element.bottom = value;
		}
		
		/**
		 * Distance from the left of the reference to the left of the layout instance (X axis)
		 * @return A Number
		 * @see com.soma.ui.ElementUI#left
		 */
		public function get left():Number {
			return _element.left;
		}
		
		public function set left(value:Number):void {
			_element.left = value;
		}
		
		/**
		 * Distance from the right of the reference to the right of the layout instance (X axis)
		 * @return A Number
		 * @see com.soma.ui.ElementUI#right
		 */
		public function get right():Number {
			return _element.right;
		}
		
		public function set right(value:Number):void {
			_element.right = value;
		}
		
		/**
		 * Distance from the middle of the reference to the middle of the layout instance (X axis)
		 * @return A Number
		 * @see com.soma.ui.ElementUI#horizontalCenter
		 */
		public function get horizontalCenter():Number {
			return _element.horizontalCenter;
		}
		
		public function set horizontalCenter(value:Number):void {
			_element.horizontalCenter = value;
		}
		
		/**
		 * Distance from the middle of the reference to the middle of the layout instance (Y axis)
		 * @return A Number
		 * @see com.soma.ui.ElementUI#verticalCenter
		 */
		public function get verticalCenter():Number {
			return _element.verticalCenter;
		}
		
		public function set verticalCenter(value:Number):void {
			_element.verticalCenter = value;
		}
		
		/**
		 * Reference used to calculate the position and size of the layout instance
		 * @see com.soma.ui.ElementUI#verticalCenter
		 */
		public function get reference():DisplayObjectContainer {
			return _reference;
		}
		
		public function set reference(object:DisplayObjectContainer) : void {
			_reference = object;
			_element.reference = _reference;
		}
		
		/**
		 * The ratio is a mode used to make the layout instance fits an area and never get deformed (such as backgrounds for example). 
		 * The type of ratio of the ElementUI can be ElementUI.RATIO_IN or ElementUI.RATIO_OUT, any other value will set the ratio to null (default).
		 * In the mode ElementUI.RATIO_IN, all the layout instance will be visible (related to the reference).
		 * In the mode ElementUI.RATIO_OUT, all the surface of the reference will be covered by the layout instance.
		 * The following properties can not be set or are not used when a ratio has been specified: x, y, width, height.
		 * The following properties can be used to "offset" the layout instance: horizontalCenter and verticalCenter.
		 * @default null
		 * @see com.soma.ui.ElementUI#ratio
		 */
		public function get ratio():String {
			return _element.ratio;
		}
		
		public function set ratio(value:String):void {
			_element.ratio = value;
		}
		
		/**
		 * Horizontal alignment used when the property ratio is set to ElementUI.RATIO_IN or ElementUI.RATIO_OUT, the value cn be ElementUI.ALIGN_LEFT, ElementUI.ALIGN_RIGHT, ElementUI.ALIGN_CENTER (X axis)
		 * @see com.soma.ui.ElementUI#alignX
		 */
		public function get alignX():String {
			return _element.alignX;
		}
		
		public function set alignX(value:String):void {
			_element.alignX = value;
		}
		
		/**
		 * Vertical alignment used when the property ratio is set to ElementUI.RATIO_IN or ElementUI.RATIO_OUT, the value can be ElementUI.ALIGN_CENTER, ElementUI.ALIGN_TOP, ElementUI.ALIGN_BOTTOM (Y axis)
		 * @see com.soma.ui.ElementUI#alignY 
		 */
		public function get alignY():String {
			return _element.alignY;
		}
		
		public function set alignY(value:String):void {
			_element.alignY = value;
		}
		
		/**
		 * Get the real width of the layout
		 * @return A Number
		 */
		public function getRealWidth():Number {
			return super.width;
		}
		
		/**
		 * Get the real height of the layout
		 * @return A Number
		 */
		public function getRealHeight():Number {
			return super.height;
		}
		
		/**
		 * Indicates wether or not the ElementUI instance will calculate and update the position and size of the layout instance
		 * @default true
		 * @see com.soma.ui.ElementUI#enable
		 */
		public function get enable():Boolean {
			return _element.enable;
		}
		
		public function set enable(value:Boolean):void {
			_element.enable = value;
		}
		
		/**
		 * Indicates wether or not the position and size numbers of the layout instance are rounded to the nearest integer
		 * @default false
		 * @see com.soma.ui.ElementUI#enable
		 */
		public function get rounded():Boolean {
			return _element.rounded;
		}
		
		public function set rounded(value:Boolean):void {
			_element.rounded = value;
		}
		
		// DisplayObjectContainer methods
		
		/** @private */
		override public function set width(value:Number):void {
			_width = value;
			if (_width < 0) _width = 0;
			draw();
		}

		/** @private */
		override public function get width():Number {
			return _width;
		}

		/** @private */
		override public function set height(value:Number):void {
			_height = value;
			if (_height < 0) _height = 0;
			draw();
		}
		
		/** @private */
		override public function get height():Number {
			return _height;
		}
		
	}
}

