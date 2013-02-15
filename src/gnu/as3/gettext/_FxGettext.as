/*
 * _FxGettext.as
 * This file is part of Actionscript GNU Gettext 
 *
 * Copyright (C) 2010 - Vincent Petithory
 *
 * Actionscript GNU Gettext is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * Actionscript GNU Gettext is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
package gnu.as3.gettext 
{

    import flash.events.Event;

    public class _FxGettext extends _Gettext 
    {
        
        public function _FxGettext(locale:_Locale)
        {
            super(locale);
        }
        
        /**
         * @inheritDoc
         */
        [Bindable("complete")]
        override public function gettext(string:String):String
        {
            return super.gettext(string);
        }
        
        /**
         * @copy #gettext()
         */
        [Bindable("complete")]
        public function _(string:String):String
        {
            return super.gettext(string);
        }
        
        /**
         * @inheritDoc
         */
        [Bindable("complete")]
        override public function dgettext(domain:String, string:String):String
        {
            return super.dgettext(domain,string);
        }
        
        /**
         * @copy #dgettext()
         */
        [Bindable("complete")]
        public function _d(domain:String, string:String):String
        {
            return super.dgettext(domain,string);
        }
        
    }
    
}
