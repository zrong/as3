////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者: zrong(zrongzrong@gmail.com)
//  创建时间：2015-04-05
////////////////////////////////////////////////////////////////////////////////

package org.zengrong.air.utils
{
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

public class FileUtil
{
    static public function writeTextFile(file:File, txt:String):void
    {
        var stream:FileStream = new FileStream();
        stream.open(file, FileMode.WRITE);
        stream.writeUTFBytes(txt);
        stream.close();
    }

    static public function readTextFile(file:File):String
    {
        return readFile(file).toString();
    }

    static public function readFile(file:File):ByteArray
    {
        var stream:FileStream = new FileStream();
        stream.open(file, FileMode.READ);
        var ba:ByteArray = new ByteArray();
        stream.readBytes(ba);
        stream.close();
        return ba;
    }

    //返回一个文件的主文件名
    static public function getFileName(file:File):String
    {
        return file.nativePath.split(File.separator).pop().split('.')[0];
    }
}
}