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

package com.soma.ui {
	import com.soma.ui.events.EventUI;
	import com.soma.ui.vo.PropertiesUI;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Dispatched from a ElementUI instance, before making a calculation to a DisplayObject (cancelable), the event flow is: WILL_CALCULATE > WILL_UPDATE > UPDATED
	 * @eventType com.soma.ui.events.EventUI.WILL_CALCULATE
	 */
	[Event(name="willCalculate", type="com.soma.ui.events.EventUI")]
	 
	/**
	 * Dispatched from a ElementUI instance, after a calculation and before making a change to a DisplayObject (cancelable), the event flow is: WILL_CALCULATE > WILL_UPDATE > UPDATED
	 * @eventType com.soma.ui.events.EventUI.WILL_UPDATE
	 */
	[Event(name="willUpdated", type="com.soma.ui.events.EventUI")]
	 
	/**
	 * Dispatched from a ElementUI instance, after a DisplayObject has been updated, the event flow is: WILL_CALCULATE > WILL_UPDATE > UPDATED
	 * @eventType com.soma.ui.events.EventUI.UPDATED
	 */
	[Event(name="updated", type="com.soma.ui.events.EventUI")]
	 
	/**
	 * The ElementUI class represents a DisplayObject.
	 * You can use the following properties to handle the position and size of the DisplayObject registered:
	 * x, y, left, right, top, bottom, horizontalCenter, verticalCenter, ratio, alignX, alignY
	 * 
	 * @example
	 * <listing version="3.0">
	 * var baseUI:BaseUI = new BaseUI(stage);
	 * var element:ElementUI = baseUI.add(mySprite);
	 * element.addEventListener(EventUI.WILL_CALCULATE, willCalculateHandler);
	 * element.addEventListener(EventUI.WILL_UPDATE, willUpdateHandler);
	 * element.addEventListener(EventUI.UPDATED, updatedHandler);
	 * element.right = 10;
	 * element.bottom = 10;
	 * element.refresh();
	 * addChild(mySprite);
	 * 
	 * private function willCalculateHandler(event:EventUI):void {
	 * 	   //event.preventDefault(); // stop the process before the calculation
	 *     trace(event.element); // trace the ElementUI instance
	 *     trace(event.element.object); // trace the DisplayObject instance
	 *     trace(event.element.baseUI); // trace the BaseUI instance
	 * }
	 * 
	 * private function willUpdateHandler(event:EventUI):void {
	 * 	   //event.preventDefault(); // stop the process before new properties are applied to the DisplayObject
	 * 	   trace(event.element); // trace the ElementUI instance
	 * 	   trace(event.element.object); // trace the DisplayObject instance
	 * 	   trace(event.element.baseUI); // trace the BaseUI instance
	 * 	   trace(event.properties); // trace the properties that will be applied to the DisplayObject
	 * }
	 * 
	 * private function updatedHandler(event:EventUI):void {
	 * 	   trace(event.element); // trace the ElementUI instance
	 * 	   trace(event.element.object); // trace the DisplayObject instance
	 * 	   trace(event.element.baseUI); // trace the BaseUI instance
	 * 	   trace(event.properties); // trace the properties that have been applied to the DisplayObject
	 * }
	 * </listing>
	 * 
	 * @see com.soma.ui.BaseUI	 * @see com.soma.ui.events.EventUI
	 * @see com.soma.ui.vo.PropertiesUI
	 * 
	 */
	 
	public class ElementUI extends EventDispatcher {

		//------------------------------------
		// private, protected properties
		//------------------------------------
		
		/** @private */
		protected var _baseUI:BaseUI;
		/** @private */
		protected var _object:DisplayObject;
		/** @private */
		protected var _reference:DisplayObjectContainer;		/** @private */
		protected var _rect:Rectangle;
		/** @private */
		protected var _ratio:String;
		
		/** @private */
		protected var _referenceX:Number;
		/** @private */
		protected var _referenceY:Number;
		/** @private */
		protected var _referenceWidth:Number = NaN;
		/** @private */
		protected var _referenceHeight:Number = NaN;
		/** @private */
		protected var _scaleXNeg:Boolean;		/** @private */
		protected var _scaleYNeg:Boolean;
		
		/** @private */
		protected var _top:Number = NaN;
		/** @private */
		protected var _bottom:Number = NaN;
		/** @private */
		protected var _left:Number = NaN;
		/** @private */
		protected var _right:Number = NaN;
		/** @private */
		protected var _horizontalCenter:Number = NaN;		/** @private */
		protected var _verticalCenter:Number = NaN;
		
		/** @private */
		protected var _alignX:String;		/** @private */
		protected var _alignY:String;
		
		/** @private */
		protected var _enable:Boolean = true;
		/** @private */
		protected var _rounded:Boolean = false;
		
		/** @private */
		protected var _properties:PropertiesUI;
		
		/** @private */
		protected var _mask:Shape;
		
		//------------------------------------
		// public properties
		//------------------------------------
		
		/** static constant for the horizontal alignment (property alignX) in mode ratio_in or ratio_out (ElementUI.ALIGN_LEFT) */
		public static const ALIGN_LEFT:String = "left";
		/** static constant for the horizontal alignment (property alignX) in mode ratio_in or ratio_out (ElementUI.ALIGN_RIGHT) */
		public static const ALIGN_RIGHT:String = "right";
		/** static constant for the horizontal and vertical alignment (property alignX and alignY) in mode ratio_in or ratio_out (ElementUI.ALIGN_CENTER) */
		public static const ALIGN_CENTER:String = "center";
		/** static constant for the vertical alignment (property alignY) in mode ratio_in or ratio_out (ElementUI.ALIGN_TOP) */
		public static const ALIGN_TOP:String = "top";
		/** static constant for the vertical alignment (property alignY) in mode ratio_in or ratio_out (ElementUI.ALIGN_BOTTOM) */
		public static const ALIGN_BOTTOM:String = "bottom";
		
		/** static constant for the mode ratio_in (ElementUI.RATIO_IN) */
		public static const RATIO_IN:String = "ratio_in";
		/** static constant for the mode ratio_out (ElementUI.RATIO_OUT) */
		public static const RATIO_OUT:String = "ratio_out";
		/** static constant that can be used to reset the ratio mode (any value can be used, as long as it is different than "ratio_in" and "ratio_out") */
		public static const RATIO_NONE:String = "ratio_none";
		
		//------------------------------------
		// constructor
		//------------------------------------
		
		/**
		 * The constructor shouldn't be used directly. You can get an ElementUI instance using the add method of the BaseUI instance.
		 * @param baseUI instance of the BaseUI that creates the ElementUI instance
		 * @param obj instance of the DisplayObject that will be handled by the ElementUI instance		 * @param reference DisplayObjectContainer instance used to calculate the size and position of the DisplayObject instance
		 * @see com.soma.ui.BaseUI#add()
		 */
		public function ElementUI(baseUI:BaseUI, obj:DisplayObject, reference:DisplayObjectContainer) {
			_baseUI = baseUI;
			_object = obj;
			_reference = reference;
			initialize();
		}
		
		//
		// PRIVATE, PROTECTED
		//________________________________________________________________________________________________
		
		/** @private */
		protected function initialize():void {
			_alignX = ALIGN_CENTER;			_alignY = ALIGN_CENTER;
		}

		/** @private */
		protected function refreshElement():void {
			if (!_enable) return;
			var eventBeforeCalculation:EventUI = new EventUI(EventUI.WILL_CALCULATE, _object, this);
			dispatchEvent(eventBeforeCalculation);
			if (eventBeforeCalculation.isDefaultPrevented()) return;
			_properties = new PropertiesUI();
			updateReferenceValues();
			_scaleXNeg = (_object.scaleX < 0);
			_scaleYNeg = (_object.scaleY < 0);
			// calcultate
			if (_ratio != null) processRatio();
			else processProperties();
			if (isNaN(_properties.x)) _properties.x = _object.x;			if (isNaN(_properties.y)) _properties.y = _object.y;			if (isNaN(_properties.width)) _properties.width = _object.width;			if (isNaN(_properties.height)) _properties.height = _object.height;
			// adjust object position with reference
			var point:Point = getRelocatedPoint(new Point(_properties.x, _properties.y));
			if (point != null) {
				_properties.x = point.x;
				_properties.y = point.y;
			}
			// round
			if (_rounded) {
				_properties.x = Math.round(_properties.x);
				_properties.y = Math.round(_properties.y);
				_properties.width = Math.round(_properties.width);
				_properties.height = Math.round(_properties.height);
			}
			var event:EventUI = new EventUI(EventUI.WILL_UPDATE, _object, this, _properties);
			dispatchEvent(event);
			if (!event.isDefaultPrevented()) {
				setProperties(event.properties);
				dispatchEvent(new EventUI(EventUI.UPDATED, _object, this, _properties));
			}
		}
		
		/** @private */
		protected function updateReferenceValues():void {
			_referenceX = (_reference is Stage) ? 0 : _reference.x;
			_referenceY = (_reference is Stage) ? 0 : _reference.y;
			_referenceWidth = (_reference is Stage) ? Stage(_reference).stageWidth : _reference.width;
			_referenceHeight = (_reference is Stage) ? Stage(_reference).stageHeight : _reference.height;
		}
		
		/** @private */
		protected function processRatio():void {
			// values
			var leftValue:Number = (isNaN(_left)) ? 0 : _left;
			var rightValue:Number = (isNaN(_right)) ? 0 : _right;
			var topValue:Number = (isNaN(_top)) ? 0 : _top;
			var bottomValue:Number = (isNaN(_bottom)) ? 0 : _bottom;
			var hcValue:Number = (isNaN(_horizontalCenter)) ? 0 : _horizontalCenter;
			var vcValue:Number = (isNaN(_verticalCenter)) ? 0 : _verticalCenter;
			// ratio
			var ratioValue:Number = getRatioValue();
			// screen
			var screenWidth:Number = _referenceWidth - leftValue - rightValue;
			var screenHeight:Number = _referenceHeight - topValue - bottomValue;
			// rect
			if (_ratio == RATIO_IN) {
				if (screenWidth / ratioValue > screenHeight) {
					_properties.width = screenHeight * ratioValue;
					_properties.height = screenHeight;
				}
				else {
					_properties.width = screenWidth;
					_properties.height = screenWidth / ratioValue;
				}
				// rect size
				setRatioRectSize();
				// align X
				if (_alignX == ALIGN_LEFT) {
					_properties.x = leftValue + hcValue;
				}
				else if (_alignX == ALIGN_CENTER) {
					_properties.x = ((_referenceWidth - _properties.width) >> 1) + ((leftValue - rightValue) >> 1) + hcValue - rightValue;
				}
				else if (_alignX == ALIGN_RIGHT) {
					_properties.x = _referenceWidth - _properties.width - rightValue + hcValue;
				}
				// align Y
				if (_alignY == ALIGN_TOP) {
					_properties.y = topValue + vcValue;
				}
				else if (_alignY == ALIGN_CENTER) {
					_properties.y = ((_referenceHeight - _properties.height) >> 1) + ((topValue - bottomValue) >> 1) + vcValue - bottomValue;
				}
				else if (_alignY == ALIGN_BOTTOM) {
					_properties.y = _referenceHeight - _properties.height - bottomValue + vcValue;
				}
				// rect pos
				setRatioRectPos();
			}
			else if (_ratio == RATIO_OUT) {
				if (screenWidth / ratioValue < screenHeight) {
					_properties.width = screenHeight * ratioValue;
					_properties.height = screenHeight;
				}
				else {
					_properties.width = screenWidth;
					_properties.height = screenWidth / ratioValue;
				}
				// rect size
				setRatioRectSize();
				// align X
				if (_alignX == ALIGN_LEFT) {
					_properties.x = leftValue + hcValue;
				}
				else if (_alignX == ALIGN_CENTER) {
					_properties.x = 0 - ((_properties.width - _referenceWidth) >> 1) + ((leftValue - rightValue) >> 1) + hcValue;
				}
				else if (_alignX == ALIGN_RIGHT) {
					_properties.x = _referenceWidth - _properties.width - rightValue + hcValue;
				}
				// align Y
				if (_alignY == ALIGN_TOP) {
					_properties.y = topValue + vcValue;
				}
				else if (_alignY == ALIGN_CENTER) {
					_properties.y = 0 - ((_properties.height - _referenceHeight) >> 1) + ((topValue - bottomValue) >> 1) + vcValue;
				}
				else if (_alignY == ALIGN_BOTTOM) {
					_properties.y = _referenceHeight - _properties.height - bottomValue + vcValue;
				}
				// rect pos
				setRatioRectPos();
			}
		}

		/** @private */
		protected function processProperties():void {
			// center
			if (!isNaN(_horizontalCenter)) {
				setHorizontalCenter();
			}
			if (!isNaN(_verticalCenter)) {
				setVerticalCenter();
			}
			// top and left
			if (!isNaN(_left) && isNaN(_horizontalCenter)) {
				_properties.x = _left;
				if (_rect != null && isNaN(_right)) _properties.x -= _rect.x;
			}
			if (!isNaN(_top) && isNaN(_verticalCenter)) {
				_properties.y = _top;
				if (_rect != null && isNaN(_bottom)) _properties.y -= _rect.y;
			}
			// right and width
			if (!isNaN(_right) && isNaN(_horizontalCenter)) {
				if (!isNaN(_left)) {
					// left and right are set
					_properties.width = getObjectWidth();
					// adjust pos
					if (_rect != null) {
						var percentX:Number = _rect.x / (_object.width / _object.scaleX);
						var percentWidth:Number = (_object.width / _object.scaleX) / _rect.width;
						_properties.x -= percentX * ((_referenceWidth - _left - _right) * percentWidth);
					}
				}
				else {
					_properties.x = _referenceWidth - _right - getObjectWidth();
					if (_rect != null) _properties.x -= _rect.x;
				}
			}
			// bottom and height
			if (!isNaN(_bottom) && isNaN(_verticalCenter)) {
				if (!isNaN(_top)) {
					// top and bottom are set
					_properties.height = getObjectHeight();
					// adjust pos
					if (_rect != null) {
						var percentY:Number = _rect.y / (_object.height / _object.scaleY);
						var percentHeight:Number = (_object.height / _object.scaleY) / _rect.height;
						_properties.y -= percentY * ((_referenceHeight - _top - _bottom) * percentHeight);
					}
				}
				else {
					_properties.y = _referenceHeight - _bottom - getObjectHeight();
					if (_rect != null) _properties.y -= _rect.y;
				}
			}
		}
		
		/** @private */
		protected function setProperties(properties:PropertiesUI):void {
			if (!isNaN(properties.x)) _object.x = properties.x;
			if (!isNaN(properties.y)) _object.y = properties.y;
			if (!isNaN(properties.width)) _object.width = properties.width;
			if (!isNaN(properties.height)) _object.height = properties.height;
			setNegativeScale();
			setRatioOutMask();
		}
		
		/** @private */
		protected function getRelocatedPoint(point:Point):Point {
			if (_object.parent == null) return null;
			var referencePoint:Point = _reference.localToGlobal(point);
			return _object.parent.globalToLocal(referencePoint);
		}
		
		/** @private */
		protected function setRatioRectSize():void {
			if ( _rect != null) {
				var percentWidth:Number = getInitialWidth() / _rect.width;
				var percentHeight:Number = getInitialHeight() / _rect.height;
				_properties.width *= percentWidth;
				_properties.height *= percentHeight;
			}
		}

		/** @private */
		protected function setRatioRectPos():void {
			if ( _rect != null) {
				var percentX:Number = _rect.x / getInitialWidth();
				var percentY:Number = _rect.y / getInitialHeight();
				_properties.x -= (percentX * _properties.width);
				_properties.y -= (percentY * _properties.height);
			}
		}

		/** @private */
		protected function getObjectWidth():Number {
			if (!isNaN(_left) && !isNaN(_right)) {
				if (_rect != null) {
					var percentWidth:Number = Math.abs(_object.width / _object.scaleX) / _rect.width;
					return (_referenceWidth - _left - _right) * percentWidth;
				}
				else return _referenceWidth - _left - _right;
			}
			if (_rect != null) return _rect.width;
			else return _object.width;
			return 0;
		}
		
		/** @private */
		protected function getObjectHeight():Number {
			if (!isNaN(_top) && !isNaN(_bottom)) {
				if (_rect != null) {
					var percentHeight:Number = Math.abs(_object.height / _object.scaleY) / _rect.height;
					return (_referenceHeight - _top - _bottom) * percentHeight;
				}
				else return _referenceHeight - _top - _bottom;
			}
			if (_rect != null) return _rect.height;
			else return _object.height;
			return 0;
		}
		
		/** @private */
		protected function setHorizontalCenter():void {
			if (_rect != null) _properties.x = ((_referenceWidth - _rect.width) >> 1) + (_horizontalCenter) - (_rect.x);
			else _properties.x = (_referenceWidth >> 1) - (_object.width >> 1) + (_horizontalCenter);
		}

		/** @private */
		protected function setVerticalCenter():void {
			if (_rect != null) _properties.y = ((_referenceHeight  - _rect.height) >> 1) + (_verticalCenter) - (_rect.y);
			else _properties.y = ((_referenceHeight - _object.height) >> 1) + (_verticalCenter);
		}
		
		/** @private */
		protected function setNegativeScale():void {
			// re-assign scale value if it was negative
			if (_scaleXNeg && _object.scaleX > 0) _object.scaleX *= -1;
			if (_scaleYNeg && _object.scaleY > 0) _object.scaleY *= -1;
		}
		
		/** @private */
		protected function setRatioOutMask():void {
			if (_ratio != RATIO_OUT) return;
			if (_reference is Stage && isNaN(_left) && isNaN(_right) && isNaN(_top) && isNaN(_bottom)) return;
			if (_mask == null) {
				createMask();
			}
			else {
				drawMask();
			}
		}
		
		/** @private */
		protected function createMask():void {
			if (_object.parent == null) return;
			_mask = new Shape();
			_object.mask = _mask;
			_object.parent.addChild(_mask);
			drawMask();
		}
		
		/** @private */
		protected function destroyMask():void {
			if (_object.parent != null && _mask != null) _object.parent.removeChild(_mask);
			_object.mask = null;
			_mask = null;
		}
		
		/** @private */
		protected function drawMask():void {
			if (_mask == null) return;
			var leftValue:Number = (isNaN(_left)) ? 0 : _left;
			var rightValue:Number = (isNaN(_right)) ? 0 : _right;
			var topValue:Number = (isNaN(_top)) ? 0 : _top;
			var bottomValue:Number = (isNaN(_bottom)) ? 0 : _bottom;
			var screenWidth:Number = _referenceWidth - leftValue - rightValue;
			var screenHeight:Number = _referenceHeight - topValue - bottomValue;
			var point:Point = getRelocatedPoint(new Point(leftValue, topValue));
			var screenPoint1:Point = new Point(point.x, point.y);
			var screenPoint2:Point = new Point(point.x + screenWidth, point.y + screenHeight);
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x0000FF, 0.3);
			_mask.graphics.drawRect(screenPoint1.x, screenPoint1.y, screenPoint2.x-screenPoint1.x, screenPoint2.y-screenPoint1.y);
			_mask.graphics.endFill();
		}
		
		// PUBLIC
		//________________________________________________________________________________________________
		
		/**
		 * Pretty-prints the ElementUI instance and its properties into a String
		 * @return A String
		 */
		override public function toString():String {
			return "[ElementUI] "
				 + "top: " + _top				 + ", left: " + _left				 + ", right: " + _right				 + ", bottom: " + _bottom				 + ", horizontalCenter: " + _horizontalCenter
				 + ", verticalCenter: " + _verticalCenter;
		}
		
		/**
		 * Calculate and update the position and size of the DisplayObject
		 */
		public function refresh(e:Event = null):void {
			refreshElement();
		}
		
		/**
		 * Destroys the ElementUI instance so it can be garbage collected. Automatically called when you remove an object from the BaseUI instance.
		 * @see com.soma.ui.BaseUI.remove()
		 * @see com.soma.ui.BaseUI.removeAll()
		 */
		public function dispose() : void {
			// dispose objects, graphics and events listeners
			try {
				destroyMask();
				_baseUI = null;
				_object = null;
				_reference = null;
				_rect = null;
				_properties = null;
			} catch(e:Error) {
				trace("Error in", this, "(dispose method):", e.message);
			}
		}
		
		/**
		 * Re-set all the ElementUI instance properties to initial values (NaN for numbers, and center for alignment)
		 */
		public function reset():void {
			_top = NaN;
			_bottom = NaN;
			_left = NaN;
			_right = NaN;
			_verticalCenter = NaN;			_horizontalCenter = NaN;
			_rect = null;
			_alignX = ALIGN_CENTER;			_alignY = ALIGN_CENTER;
		}

		/**
		 * Return the real width of the DisplayObject instance (not the one on screen)
		 * @return An absolute number
		 */
		public function getInitialWidth():Number {
			return Math.abs(_object.width / _object.scaleX);
		}
		
		/**
		 * Return the real height of the DisplayObject instance (not the one on screen)
		 * @return An absolute number
		 */
		public function getInitialHeight():Number {
			return Math.abs(_object.height / _object.scaleY);
		}
		
		/**
		 * Return the ratio value between the width and height of the DisplayObject instance 
		 * @return An absolute number
		 */
		public function getRatioValue():Number {
			return getInitialWidth() / getInitialHeight();
		}
		
		/**
		 * Distance from the top of the reference to the top of the DisplayObject instance (Y axis)
		 * @return A Number
		 */
		public function get top():Number {
			return _top;
		}
		
		public function set top(value:Number):void {
			_top = value;
		}

		/**
		 * Distance from the bottom of the reference to the bottom of the DisplayObject instance (Y axis)
		 * @return A Number
		 */
		public function get bottom():Number {
			return _bottom;
		}
		
		public function set bottom(value:*):void {
			_bottom = value;
		}
		
		/**
		 * Distance from the left of the reference to the left of the DisplayObject instance (X axis)
		 * @return A Number
		 */
		public function get left():Number {
			return _left;
		}
		
		public function set left(value:Number):void {
			_left = Number(value);
		}
		
		/**
		 * Distance from the right of the reference to the right of the DisplayObject instance (X axis)
		 * @return A Number
		 */
		public function get right():Number {
			return _right;
		}
		
		public function set right(value:Number):void {
			_right = value;
		}
		
		/**
		 * Distance from the middle of the reference to the middle of the DisplayObject instance (X axis)
		 * @return A Number
		 */
		public function get horizontalCenter():Number {
			return _horizontalCenter;
		}
		
		public function set horizontalCenter(value:Number):void {
			_horizontalCenter = value;
		}
		
		/**
		 * Distance from the middle of the reference to the middle of the DisplayObject instance (Y axis)
		 * @return A Number
		 */
		public function get verticalCenter():Number {
			return _verticalCenter;
		}
		
		public function set verticalCenter(value:Number):void {
			_verticalCenter = value;
		}
		
		/**
		 * Get the DisplayObject instance handled by the ElementUI instance
		 * @return A DisplayObject instance
		 */
		public function get object():DisplayObject {
			return _object;
		}
		
		/**
		 * Get the BaseUI instance that has created the ElementUI instance
		 * @return A BaseUI instance
		 */
		public function get baseUI():BaseUI {
			return _baseUI;
		}
		
		/**
		 * Reference used to calculate the position and size of the DisplayObject instance
		 */
		public function get reference():DisplayObjectContainer {
			return _reference;
		}
		
		public function set reference(object:DisplayObjectContainer) : void {
			_reference = object;
		}
		
		/**
		 * Rectangle that can be used to specify or force the boundaries of the DisplayObject
		 * @default null
		 */
		public function get rect():Rectangle {
			return _rect;
		}
		
		public function set rect(rect:Rectangle) : void {
			_rect = rect;
		}
		
		/**
		 * The ratio is a mode used to make the DisplayObject instance fits an area and never get deformed (such as backgrounds for example). 
		 * The type of ratio of the ElementUI can be ElementUI.RATIO_IN or ElementUI.RATIO_OUT, any other value will set the ratio to null (default).
		 * In the mode ElementUI.RATIO_IN, all the DisplayObject instance will be visible (related to the reference).		 * In the mode ElementUI.RATIO_OUT, all the surface of the reference will be covered by the DisplayObject instance.
		 * The following properties can not be set or are not used when a ratio has been specified: x, y, width, height.
		 * The following properties can be used to "offset" the DisplayObject instance: horizontalCenter and verticalCenter.
		 * @default null
		 */
		public function get ratio():String {
			return _ratio;
		}
		
		public function set ratio(value:String):void {
			if (value == RATIO_IN || value == RATIO_OUT) _ratio = value;
			else {
				_ratio = null;
				if (_mask != null) destroyMask();
			}
		}
		
		/**
		 * Horizontal alignment used when the property ratio is set to ElementUI.RATIO_IN or ElementUI.RATIO_OUT, the value cn be ElementUI.ALIGN_LEFT, ElementUI.ALIGN_RIGHT, ElementUI.ALIGN_CENTER (X axis)
		 */
		public function get alignX():String {
			return _alignX;
		}
		
		public function set alignX(value:String):void {
			if (value != ALIGN_LEFT && value != ALIGN_CENTER && value != ALIGN_RIGHT) {
				throw new Error("Error in " + this + " " + _object + " (" + _object.name + "): the alignX property must be ALIGN_LEFT, ALIGN_CENTER or ALIGN_RIGHT");
			}
			_alignX = value;
		}
		
		/**
		 * Vertical alignment used when the property ratio is set to ElementUI.RATIO_IN or ElementUI.RATIO_OUT, the value can be ElementUI.ALIGN_CENTER, ElementUI.ALIGN_TOP, ElementUI.ALIGN_BOTTOM (Y axis) 
		 */
		public function get alignY():String {
			return _alignY;
		}
		
		public function set alignY(value:String):void {
			if (value != ALIGN_TOP && value != ALIGN_CENTER && value != ALIGN_BOTTOM) {
				throw new Error("Error in " + this + " " + _object + " (" + _object.name + "): the alignY property must be ALIGN_TOP, ALIGN_CENTER or ALIGN_BOTTOM");
			}
			_alignY = value;
		}
		
		/**
		 * Indicates wether or not the ElementUI instance will calculate and update the position and size of the DisplayObject instance
		 * @default true
		 */
		public function get enable():Boolean {
			return _enable;
		}
		
		public function set enable(value:Boolean):void {
			_enable = value;
		}
		
		/**
		 * Indicates wether or not the position and size numbers of the DisplayObject instance are rounded to the nearest integer
		 * @default false
		 */
		public function get rounded():Boolean {
			return _rounded;
		}
		
		public function set rounded(value:Boolean):void {
			_rounded = value;
		}
	}
}

