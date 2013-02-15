/*
 * MOFile.as
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
    
    import flash.utils.Dictionary;
    
    /**
     * The <code>MOFile</code> class holds the data inside a binary MO file.
     * Usually, you won't have to manipulate directly 
     * a <code>MOFile</code> instance, as accessing 
     * the translated strings is done automatically.
     * 
     * <p>The most important property is the <code>strings</code> property. 
     * It is a <code>Dictionary</code> instance holding the original strings 
     * and the translations of the MO file. Original strings are the keys 
     * of this Dictionary, and translated strings are the values. 
     * Almost all the other properties are metadata found in the MO file.</p>
     * 
     */
    public class MOFile 
    {
        
        /**
         * The file format revision of this MO file.
         */
        public var fileFormatRevision:uint;
        
        /**
         * The dictionary of the string and translated strings in 
         * this MO file.
         * 
         * <p>The original strings are the keys ;
         * the translated strings are the values.</p>
         */
        public var strings:Dictionary;
        
        /**
         * The number of translations in this MO file.
         */
        public var numStrings:uint;
        
        /**
         * The project id and version in which this MO file is used.
         */
        public var projectIdVersion:String;
        
        /**
         * Where to report bugs of msgid strings
         */
        public var reportMsgidBugsTo:String;
        
        /**
         * The creation date of the PO template file
         * that was used to create this MO file.
         */
        public var potCreationDate:Date;
        
        /**
         * The creation date of the PO file  
         * that was used to create this MO file.
         */
        public var poRevisionDate:Date;
        
        /**
         * The last translator who has worked 
         * on the translations of this MO file.
         */
        public var lastTranslator:String;
        
        /**
         * The language team behind the translations of this MO file.
         */
        public var languageTeam:String;
        
        /**
         * The mime version of this MO file, such as <code>1.0</code>
         */
        public var mimeVersion:String;
        
        /**
         * The content type of this MO file, such as 
         * <code>text/plain; charset=UTF-8</code>
         */
        public var contentType:String;
        
        /**
         * The content mime type of this MO file, 
         * such as <code>text/plain</code>.
         */
        public function get contentMimeType():String
        {
            return contentType.substring(0,contentType.indexOf(";"));
        }
        
        /**
         * The charset of the content of this MO file, 
         * such as <code>UTF-8</code>.
         */
        public function get contentCharset():String
        {
            return contentType.substr(contentType.indexOf("=")+1);
        }
        
        /**
         * Value is usually <code>8bit</code>.
         */
        public var contentTransferEncoding:String;
        
        /**
         * The raw plural forms as specified in the MO file, 
         * such as <code>nplurals=2; plural=n>1</code>.
         */
        public var pluralForms:String;
        
        /**
         * The plural expression used in the MO file, to determine if a string 
         * is a plural form. The expression is usually <code>n>1</code>.
         */
        public function get plural():int
        {
            return parseInt(
                    pluralForms.substring(
                        pluralForms.lastIndexOf(">")+1, 
                        pluralForms.lastIndexOf(";")
                    )
                );
        }
        
        /**
         * The locale of this catalog.
         */
        public var locale:String;
        
        /**
         * The plural value used in the MO file, to determine if a string 
         * is a plural form. The value is usually <code>2</code>.
         */
        public function get nPlural():int
        {
            return parseInt(
                    pluralForms.substring(
                        pluralForms.indexOf("=")+1, 
                        pluralForms.indexOf(";")
                    )
                );
        }
        
        /**
         * Constructor.
         */
        public function MOFile()
        {
            super();
        }
        
        
        
    }
    
}
