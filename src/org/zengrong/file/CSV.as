/**
 *   This file is a part of csvlib, written by Marco Müller / http://short-bmc.com
 *   zrong(zengrong.net) 进行大幅修改，加入大量新的方法和功能
 *
 *   The csvlib is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU General Public License for more details.
 *	 
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>
 */
package org.zengrong.file
{
import flash.utils.Dictionary;
import org.zengrong.utils.StringUtil;
/**
 * @author Marco Müller / http://shorty-bmc.com
 * @author zrong(zengrong.net) 2012-06-28 修改
 * @author zrong(zengrong.net) 2013-01-06 修改
 * @see http://rfc.net/rfc4180.html RFC4180
 * @see http://csvlib.googlecode.com csvlib
 */
public class CSV
{
	public static const FORMATED_TYPE_OBJECT_ARRAY:String = 'Array';
	public static const FORMATED_TYPE_DICTIONARY:String = 'Dictionary';
	
	/**
	 * 设置转换ValueObject的函数名称
	 */
	public static var FACTORY_NAME:Array = ['toVO', 'toValueObject'];
	
	/**
	 * 将字符串作为CSV进行解析 
	 * @param $str
	 * @return 返回一个解析好的CSV对象
	 */		
	public static function parse($str:String):CSV
	{
		var __csv:CSV = new CSV($str);
		return __csv;
	}
	
	/**
	 * @param $str 要解析的CSV数据
	 */
	public function CSV($str:String=null)
	{
		_fieldSeperator = ',';
		_fieldEnclosureToken = '"';
		_recordsetDelimiter	= FileEnding.UNIX;
		
		_embededHeader = true;
		_headerOverwrite = false;
		if($str) decode($str);
	}
	
	
	/**
	 * 是使用toObjectArray还是使用toDictionary来解析数据
	 */
	private var _formatedType:String;
	
	private var _formatedData:Object;
	
	
	private var _sortField:*;
	private var _sortSequence:String;
	
	public function get formatedType():String
	{
		return _formatedType;
	}
	
	public function set formatedType($value:String):void
	{
		_formatedType = $value;
	}
	
	/**
	 * 保存使用toObjectArray或者toDictionary解析之后的数据格式
	 */
	public function get formatedData():Object
	{
		if(!_formatedType) return null;
		return _formatedData;
	}
	
	public function set formatedData($value:Object):void
	{
		_formatedData = $value;
	}
	
	private var _fieldSeperator:String;
	
	/**
	 * 列分隔符
	 */
	public function get fieldSeperator() : String
	{
		return _fieldSeperator;
	}
	
	public function set fieldSeperator( $value : String ) : void
	{
		_fieldSeperator = $value;
	}
	
	private var _fieldEnclosureToken:String;
	public function get fieldEnclosureToken() : String
	{
		return _fieldEnclosureToken;
	}
	
	public function set fieldEnclosureToken( $value : String ) : void
	{
		_fieldEnclosureToken = $value;
	}
		
	private var _recordsetDelimiter:String;
	/**
	 * 行分隔符，默认是Unix换行符
	 */
	public function get recordsetDelimiter() : String
	{
		return _recordsetDelimiter;
	}	
	
	public function set recordsetDelimiter( $value : String ) : void
	{
		_recordsetDelimiter = $value;
	}
	
	private var _embededHeader:Boolean;
	/**
	 * CSV数据中是否包含Header域，默认值为true
	 */
	public function get embededHeader() : Boolean
	{
		return _embededHeader;
	}
	
	public function set embededHeader( $value : Boolean ) : void
	{
		_embededHeader = $value;
	}
	
	private var _headerOverwrite:Boolean;
	/**
	 * 是否允许覆盖CSV的header域
	 */
	public function get headerOverwrite()  : Boolean 
	{
		return _headerOverwrite;
	}

	public function set headerOverwrite( $value : Boolean ) : void
	{
		_headerOverwrite = $value;
	}
	
	private var _header:Array;
	/**
	 * CSV的头数组
	 */
	public function get header() : Array 
	{
		return _header;
	}	
	
	public function set header( $value : Array ) : void
	{
		if( (!embededHeader && !headerHasValues) ||
			(!embededHeader && headerHasValues && headerOverwrite) || 
			 headerOverwrite )
			   _header = $value;
	}
	
	private var _data:Array;
	/**
	 * 获取CSV的数据
	 */
	public function get data():Array
	{
		return _data;
	}	
	
	public function set data($value:Array):void
	{
		_data = $value;
	}

	public function get headerHasValues () : Boolean
	{
		return _header && _header.length>0;
	}
	
	public function get dataHasValues () : Boolean
	{
		return data && data.length>0;
	}
	
	private var _csvString:String;
	
	/**
	 * 保存原始的CSV字符串 
	 */		
	public function get csvString():String
	{
		return _csvString;
	}
	
	public function set csvString($value:String):void
	{
		_csvString = $value;
	}

	
	// -> Public methods
	
	/**
	 * 在CSV中获取一条记录
	 */
	public function getRecordSet( index : int ) : Array
	{
		if ( dataHasValues )
			 return data[ index ];
		else
			return null;
	}
	
	/**
	 * 在CSV中增加一条记录
	 */
	public function addRecordSet( recordset : Array, index : * = null ) : void
	{
		if ( !dataHasValues )
			  data = new Array();
		if ( !index && index != 0 )
			  data.push( recordset );
		else
			  data.splice(index, 0, recordset);
	}
	
	/**
	 * 根据指定的范围删除记录
	 */
	public function deleteRecordSet ( startIndex : int, endIndex : int = 1 ) : Boolean
	{
		if ( dataHasValues && startIndex < data.length && endIndex > 0 )
			 return data.splice( startIndex, endIndex )
		else
			 return false;
	}
	
	public function search ( needle : *, removeDuplicates : Boolean = true ) : Array
	{
		var result : Array = new Array()
		for each ( var i : Array in data ){
			if ( needle is Array ){
				 for each ( var j : String in needle )
					 if ( i.indexOf( String( j ) ) >= 0 )
						  result.push( i )}
			else
				if ( i.indexOf( String( needle ) ) >= 0 ){
				 	 result.push( i )}}
		if ( removeDuplicates && result.length > 2 )
			 var k : int = result.length -1;
			 while ( k-- ){
				 var l : int = result.length;
				 while ( --l > k )
					if ( result[ k ] == result[ l ] )
						 result.splice( l, 1 )}
		return result
	}
	
	public function sort( fieldNameOrIndex : * = 0, sequence : String = 'ASC' ) : void
	{
		_sortSequence = sequence;
		if ( headerHasValues && header.indexOf( fieldNameOrIndex ) >=0 )
			 _sortField = header.indexOf( fieldNameOrIndex );
		else
			 _sortField = fieldNameOrIndex;
		if ( dataHasValues )
			 _data.sort ( sort2DArray );
	}
	
	/**
	 * 解析传递的CSV字符串
	 * @param $str 要解析的CSV字符串
	 */
	public function decode($str:String) : void
	{
		_csvString = $str;
		var __count  : int = 0;
		var __result : Array = new Array ();
		var __csvData:Array = _csvString.split( recordsetDelimiter );
		for(  var i : int = 0; i < __csvData.length; i++ )
		{
			if( !Boolean( __count % 2 ) )
				 __result.push( __csvData[ i ] );
			else
				 __result[ __result.length - 1 ] += __csvData[ i ];
			__count += StringUtil.count( __csvData[ i ] , fieldEnclosureToken );
		}
		__result = __result.filter( isNotEmptyRecord )
		__result.forEach( fieldDetection );
		if ( ( embededHeader && headerOverwrite ) || 
			( embededHeader && headerHasValues ) )
			   __result.shift();
		else if ( embededHeader )
			   _header = __result.shift();
		_data = __result;
	}
	
	/**
	 * 将本地保存的数组转换成CSV字符串
	 */
	public function encode () : void
	{
		_csvString = '';
		if ( headerHasValues && header.length > 0 )
		{
			 embededHeader = true;
			 data.unshift( header );
		}
		if ( dataHasValues )
		{
			 for each ( var recordset : Array in data )
				_csvString += recordset.join( fieldSeperator ) + recordsetDelimiter;
		}
	}
	
	// -> private methods
	
	/**
	 * 检测域
	 */
	private function fieldDetection( element : *, index : int, arr : Array ) : void
	{	
		var count  : uint  = 0;
		var result : Array = new Array ();
		var tmp    : Array = element.split( fieldSeperator );
		for( var i : uint = 0; i < tmp.length; i++ )
		{
			if( !Boolean( count % 2 ) )
				 result.push( StringUtil.trimList( tmp[ i ] ) );
			else
				 result[ result.length - 1 ] += fieldSeperator + tmp[ i ];
			count += StringUtil.count( tmp[ i ] , fieldEnclosureToken );
		}
		arr[ index ] = result
	}
	
	private function sort2DArray( a : Array, b : Array ) : Number
	{
		var n : int = 0
		var r : int = _sortSequence == 'ASC' ? -1 : 1;
		if ( String( a[ _sortField ] ) < String( b[ _sortField ]) )
			n = r
		else if ( String( a[ _sortField ] ) > String( b[ _sortField ] ) )
			n = -r
		else
			n = 0
		return n;
	}
	
	private function isNotEmptyRecord( element : *, index : int, arr : Array ) : Boolean
	{
		return Boolean( StringUtil.trimList( element ) );
	}
	
	/**
	 * 将CSV转换成对象列表
	 * @param $save 是否将解析后的结果保存在formatedData变量中
	 * @param $voClass 提供一个VOClass，此方法会将保存在数组中的类型转换为voClass类型。<br>
	 * 该类若提供了一个工厂静态方法，则会使用这个方法来进行VO转换。工厂方法的名称在FACTORY_NAME中定义
	 */		
	public function toObjectArray($save:Boolean=false, $voClass:Class=null):Array
	{
		var __objarray:Array = [];
		var __unit:*= null;
		for(var i:uint=0;i<data.length;i++)
		{
			if($voClass is Class)
			{
				__unit = toVO($voClass, header, data[i]);
			}
			else
			{
				__unit = {};
				writeObject(__unit, header, data[i]);
			}
			__objarray[i] = __unit;
		}
		if($save)
		{
			_formatedType = FORMATED_TYPE_OBJECT_ARRAY;
			formatedData = __objarray;
		}
		else
		{
			_formatedData = null;
			formatedData = null;
		}
		return __objarray;
	}
	
	/**
	 * 将列表导出成字典格式
	 * @param $id 提供字典的id使用哪个key
	 * @param $save 是否将解析后的结果保存在formatedData变量中
	 * @param $voClass 提供一个VOClass，此方法会将保存在数组中的类型转换为voClass类型。<br>
	 * 该类若提供了一个工厂静态方法，则会使用这个方法来进行VO转换。工厂方法的名称在FACTORY_NAME中定义
	 */
	public function toDictionary($id:String=null, $save:Boolean=false, $voClass:Class=null):Dictionary
	{
		var __dict:Dictionary = new Dictionary(false);
		var __unit:* = null;
		var __idIndex:int = -1;
		for(var k:uint=0;k<header.length;k++)
		{
			//如果提供了id，并且在CSV的header中确实有这个id，就使用这个id作为这个字典的索引
			if($id && $id == header[k])
			{
				__idIndex = k;
				break;
			}
		}
		for(var i:uint=0;i<data.length;i++)
		{
			if($voClass is Class)
			{
				__unit = toVO($voClass, header, data[i]);
			}
			else
			{
				__unit = {};
				writeObject(__unit, header, data[i]);
			}
			//若有id，使用id作为键名，否则使用数字作为键名
			if(__idIndex>-1) __dict[data[i][__idIndex]] = __unit;
			else __dict[i] = __unit;
		}
		if($save)
		{
			_formatedType = FORMATED_TYPE_DICTIONARY;
			formatedData = __dict;
		}
		else
		{
			_formatedData = null;
			formatedData = null;
		}
		return __dict;
	}
	
	/**
	 * 根据提供的类建立该类的值对象
	 */
	public function toVO($voClass:Class, $header:Array, $value:Array):*
	{
		var __factoryIndex:int = -1;
		for (var i:int = 0; i < FACTORY_NAME.length; i++) 
		{
			if($voClass.hasOwnProperty(FACTORY_NAME[i]))
			{
				__factoryIndex = i;
				break;
			}
		}
		var __vo:* = null;
		//如果找不到工厂方法，下面的循环会根据属性来设置值
		if(__factoryIndex < 0)
		{
			__vo = new $voClass;
			writeObject(__vo, header, $value);
			return __vo;
		}
		//如果找到了工厂方法，先将CSV转成Object
		__vo = {};
		writeObject(__vo, header, $value);
		//使用工厂方法返回
		return ($voClass[FACTORY_NAME[__factoryIndex]] as Function).call(null, __vo);
	}
	
	/**
	 * 提供header和值数组，将它们转换成键值对写入object中
	 */
	private function writeObject($obj:Object, $header:Array, $value:Array):void
	{
		for (var j:int = 0; j < $header.length; j++) 
		{
			$obj[$header[j]] = $value[j];
		}
	}
	
	/**
	 * 显示CSV的结构
	 */
	public function toString() : String
	{
		var  __result : String = 'data:Array -> [\r'
		for ( var i : int = 0; i < data.length; i++ )
		{
			__result += '\t[' + i + ']:Array -> [\r'
			for (var j : uint = 0; j < data[i].length; j++ ) __result += '\t\t[' + j + ']:String -> ' + data[ i ][ j ] + '\r'
			__result += ( '\t]\r' )
		}
		__result += ']\r'
		return __result;
	}
}
}