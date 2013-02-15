/*
 * parseMOBytes.as
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

    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;
    
    import flash.errors.EOFError;    
    
    /**
     * Parses the bytes representing a MO file.
     * 
     * @param bytes The bytes of the MO file
     * @return A MOFile instance containing the informations of the original
     * .mo file.
     * 
     * @throws GettextError if the bytes does not represent a valid MO file.
     * @throws TypeError if the specified ByteArray is null.
     * 
     */
    public function parseMOBytes(bytes:ByteArray):MOFile 
    {
        if (bytes == null)
            throw new TypeError("The <bytes> parameter must not be null");
            
        var originalPosition:uint = bytes.position;
        var originalEndian:String = bytes.endian;
        var magicNumber:uint = bytes.readUnsignedInt();
        if (magicNumber == 0xde120495)
            bytes.endian = Endian.LITTLE_ENDIAN;
        else if (magicNumber == 0x950412de)
            bytes.endian = Endian.BIG_ENDIAN;
        else
            throw new GettextError("The magic number is invalid.");
        
        var fileFormatRevision:uint = bytes.readUnsignedInt();
        if (fileFormatRevision > 0)
            throw new GettextError(
                "Unknown or unsupported MO file format revision."
            );
        
        var n:uint = bytes.readUnsignedInt();
        if (n <= 0)
            throw new GettextError("The MO file has no translations.");
        
        var o:uint = bytes.readUnsignedInt();
        var t:uint = bytes.readUnsignedInt();
        var s:uint = bytes.readUnsignedInt();
        var h:uint = bytes.readUnsignedInt();
        
        // Loop through string and translations location informations 
        // and retrieve string and translations infos
        const LOOP_INCREMENT:int = 8;//4+4
        const NUM_LOOPS:int = n;//(n-1+1)
        var dictionary:Dictionary = new Dictionary(false);
        var i:int = -1;
        var bytesIndent:uint;
        var strlen:uint;
        var stroffset:uint;
        var trStrlen:uint;
        var trStroffset:uint;
        
        while (++i<NUM_LOOPS)
        {
            try 
            {
                bytesIndent = i*LOOP_INCREMENT;
                bytes.position = o+bytesIndent;
                strlen = bytes.readUnsignedInt();
                stroffset = bytes.readUnsignedInt();
                bytes.position = t+bytesIndent;
                trStrlen = bytes.readUnsignedInt();
                trStroffset = bytes.readUnsignedInt();
            
                // get string
                bytes.position = stroffset;
                var str:String = bytes.readUTFBytes(strlen);
                bytes.position = trStroffset;
                dictionary[str] = bytes.readUTFBytes(trStrlen);
            } catch (e:EOFError)
            {
                throw new GettextError("The MO file is invalid or corrupted.");
            }
        }
        
        // The informations are assumed to be 
        // in the first string to be translated.
        // The original string is empty
        // We should be careful to check the evolution of it.
        bytes.position = t;
        var infolen:uint = bytes.readUnsignedInt();
        var infooffset:uint = bytes.readUnsignedInt();
        
        bytes.position = infooffset;
        var infos:String = bytes.readUTFBytes(infolen);
        var elements:Array = infos.split(String.fromCharCode(0x0A));
        
        // Create and fill the MOFile instance
        var mo:MOFile = new MOFile();
        mo.fileFormatRevision = fileFormatRevision;
        mo.strings = dictionary;
        mo.numStrings = n;
        mo.projectIdVersion = elements[0].substr(elements[0].indexOf(":")+2);
        mo.reportMsgidBugsTo = elements[1].substr(elements[1].indexOf(":")+2);
        
        // YYYY-MM-DD HH::MM(+|-HHMM)
        
        var rawPotCreationDate:String = elements[2].substr(elements[2].indexOf(":")+2);
        
        mo.potCreationDate = new Date(
            Date.parse(
                rawPotCreationDate.replace(DATE_PATTERN,DATE_PATTERN_REPL)
            )
        );
        
        var rawPoRevisionDate:String = elements[3].substr(elements[3].indexOf(":")+2);
        mo.poRevisionDate = new Date();
        mo.poRevisionDate = new Date(
            Date.parse(
                rawPoRevisionDate.replace(DATE_PATTERN,DATE_PATTERN_REPL)
            )
        );
        
        mo.lastTranslator = elements[4].substr(elements[4].indexOf(":")+2);
        mo.languageTeam = elements[5].substr(elements[5].indexOf(":")+2);
        mo.mimeVersion = elements[6].substr(elements[6].indexOf(":")+2);
        mo.contentType = elements[7].substr(elements[7].indexOf(":")+2);
        mo.contentTransferEncoding = elements[8].substr(elements[8].indexOf(":")+2);
        mo.pluralForms = elements[9].substr(elements[9].indexOf(":")+2);
        
        // Put the byte array in its original state.
        bytes.position = originalPosition;
        bytes.endian = originalEndian;
        return mo;
    }
    
}

internal const DATE_PATTERN:RegExp = /(\d+)-(\d+)-(\d+) (\d+):(\d+)(\+|-\d+)/g;
internal const DATE_PATTERN_REPL:String = "$1/$2/$3 $4:$5 GMT$6";

