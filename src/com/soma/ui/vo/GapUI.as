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
 
package com.soma.ui.vo {
	
	/**
	 * Value Object class containing the necessary properties (horizontal and vertical) used to set a gap between the DisplayObject children of the HBoxUI, VBoxUI and TileUI layouts classes (childrenGap property).
	 * 
	 * @example
	 * <listing version="3.0">
	 * var tile:TileUI = new TileUI(stage, 400, 300);
	 * tile.childrenGap = new GapUI(10, 10);
	 * </listing>
	 * 
	 * @see com.soma.ui.layouts.HBoxUI
	 * @see com.soma.ui.layouts.VBoxUI
	 * @see com.soma.ui.layouts.TileUI
	 * 
	 */
	
	public class GapUI {

		//------------------------------------
		// private, protected properties
		//------------------------------------
		
		

		//------------------------------------
		// public properties
		//------------------------------------
		
		/** Value number that will be used to set a gap between DisplayObject children horizontally */
		public var horizontal:Number;
		/** Value number that will be used to set a gap between DisplayObject children vertically */
		public var vertical:Number;
		
		//------------------------------------
		// constructor
		//------------------------------------
		
		/**
		 * Create an instance of the GapUI class
		 * @param horizontal A Number		 * @param vertical A Number
		 */
		public function GapUI(horizontal:Number = 0, vertical:Number = 0) {
			this.horizontal = horizontal;
			this.vertical = vertical;
		}
		
		//
		// PRIVATE, PROTECTED
		//________________________________________________________________________________________________
		
		
		
		// PUBLIC
		//________________________________________________________________________________________________
		
		/**
		 * Pretty-prints the GapUI instance and its properties into a String
		 * @return A String
		 */
		public function toString():String {
			return "[GapUI] "
				 + "horizontal: " + horizontal
				 + ", vertical: " + vertical;
		}
		
	}
}