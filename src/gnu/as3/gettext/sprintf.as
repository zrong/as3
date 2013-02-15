/*
 * sprintf.as
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
    
    /**
     * Formats the specified string, using the specified values.
     * 
     * @param str The string to format.
     * @param values A collection of values to insert. 
     * It can be an Array, Vector, Dictionary, Object, or any object that 
     * matches the keys of the string.
     * @return The formatted string.
     */
    public function sprintf(string:String, values:* = undefined):String
    {
        regexpValues = values;
        var stringOut:String = string.replace(tokenPattern, repFunc);
        regexpValues = null;
        return stringOut;
    }
    
}

/**
 * Defines the pattern that token-based functions 
 * use to manipulate strings.
 */
internal const tokenPattern:RegExp = /{[\d|\w]+}/g;

/**
 * @private
 */
internal var regexpValues:*;

/**
 * @private
 */
internal const repFunc:Function = function():String 
{
    var token:String = arguments[0];
    return String(regexpValues[token.substring(1,token.length-1)]);
}
