/**
 * VERSION: 1
 * DATE: 2013-8-3
 * AS3
 * CLK/陈泽丹
 **/
package org.zengrong.utils
{
	import flash.utils.Dictionary;

	public class LuaTable2Dictionary
	{
		/**
		 * 哥已经很少写以下这么麻烦的算法了。记得最早写这种用堆框模拟递归进行处理的东西，还是刚学编程那会，用它写了一个四则运算的计算器算法。
		 * 										－－　陈泽丹
		 * 											2013-8-15
		 */		
		
		
		private var m_operator_stack:Vector.<String> = null;
		private var m_item_stack:Vector.<Object> = null;
		private var m_table_text:String = "";
		private var m_table_pos:int = 0;
		public function GetTable( _table_text:String ):Object
		{
			var replace_pattern:RegExp = /nil/gi; 
			var table_text:String = _table_text.replace(replace_pattern,"\"NULL\"");
			m_operator_stack = new Vector.<String>();
			m_item_stack = new Vector.<Object>();
			m_table_text = "[\"ROOT\"] = " + table_text + ",";
			//m_table_text = "[\"ROOT\"] = { [\"582\"] = 8547, [5] = 46, [\"TEST\"] = {[45] = 89, }, },";
			m_table_pos = 0;
			var ret:Object =  GetDictionary();
			Tidy(ret.ROOT);
			return ret.ROOT;
		}
		
		private function GetDictionary():Object
		{
			//目前不支持带转义字符的解析
			var ret:Object = new Object();
			var len:int = m_table_text.length;
			var item_val:Object = new Object();
			var item:Object = new Object();
			var s:String = "0";
			var e:String = "9";
			for(; m_table_pos<len; ++m_table_pos)
			{
				var char_temp:String = m_table_text.substr(m_table_pos,1);
				if( " " == char_temp )
					continue;
				
				if( "}" == char_temp )
				{
					if( "{" == m_operator_stack.pop() )
					{
						return ret;
					}
					else
					{
						trace("数据异常");
					}
				}
				
				//项处理
				if( "[" == char_temp )
				{
					m_operator_stack.push(char_temp);
					continue;
				}
				else if( "]" == char_temp )
				{
					if( "[" == m_operator_stack.pop() )
					{
						m_item_stack.push(item_val);
						continue;
					}
				}
					
				//合成处理
				else if( "=" == char_temp )
				{
					m_operator_stack.push(char_temp);
					continue;
				}
				else if( "," == char_temp )
				{
					if( "=" == m_operator_stack.pop() )
					{
						item = m_item_stack.pop();
						if( item is Number )
						{
							if( null == ret["ARRAY"] )
								ret["ARRAY"] = new Array();
							ret["ARRAY"][item] = item_val;
						}
						else
						{
							ret[item] = item_val;
						}
						continue;
					}
				}
				
				//值处理
				if( "\"" == char_temp )
				{
					item_val = GetString();
					continue;
				}
				else if( "{" == char_temp )
				{
					m_operator_stack.push(char_temp);
					++m_table_pos;
					item_val = GetDictionary();
					continue;
				}
				else if( char_temp.charCodeAt() >= s.charCodeAt()  && char_temp.charCodeAt() <= e.charCodeAt() )
				{
					item_val = GetNumber();
					continue;
				}
			}
			return ret;
		}
		
		private function GetNumber():Number
		{
			var temp:String = "";
			var len:int = m_table_text.length;
			for(; m_table_pos<len; ++m_table_pos)
			{
				var char_temp:String = m_table_text.substr(m_table_pos,1);
				var s:String = "0";
				var e:String = "9";
				if( char_temp.charCodeAt() >= s.charCodeAt()  && char_temp.charCodeAt() <= e.charCodeAt() )
				{
					temp = temp + char_temp;
				}
				else if( " " != char_temp)
				{
					break;
				}
			}
			m_table_pos = m_table_pos - 1;
			var num:Number = Number(temp);
			return num;
		}
		
		private function GetString():String
		{
			var sub_buf:String = m_table_text.substr(m_table_pos+1);
			var pos:int = sub_buf.search("\"");
			var temp:String = sub_buf.substr(0, pos);
			m_table_pos = m_table_pos + 1 + pos;
			return temp;
		}
		
		private function Tidy( _obj:Object ):void
		{
			for( var ID:Object in _obj )
			{
				if( "NULL" == _obj[ID] )
				{
					delete _obj[ID];
				}
				else if( _obj[ID] is Object )
				{
					Tidy( _obj[ID] );
				}
			}
		}
	}
}
