////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	董伟
//	修改者：zrong
//  创建时间：2011-06-10
//  修改时间：2012-02-07
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.net
{  
import flash.utils.ByteArray;
import flash.utils.Endian;

/**
 * Socket发来的数据如果过长，会拆包；如果两个操作比较近，也有可能两个数据包合成一个发送。这个类处理处理数据包的合并和分拆的相关操作。
 * 与org.zengrong.net.PacketString的区别，在于Packet类将数据流作为字符串处理
 * */
public class PacketBuffer
{  
	/**
	 * 两个校验码
	 */
	public static var MASK1:uint = 0x59;
	public static var MASK2:uint = 0x7a;

	/**
	 * 随机数的基准值
	 */	
	public static var RANDOM_BASE:int = 10000;

	/**
	 * 数据包的最大长度
	 */
	public static const MAX_SIZE:int=2100000000;

	/**
	 * 前面的校验码长度
	 */
	public static var SUF_MASK_LEN:int = 2;

	/**
	 * 后面的校验码长度
	 */
	public static var PRE_MASK_LEN:int = 2;

	/**
	 * 消息体长度使用32位正数保存，占用4字节
	 */
	public static var BODY_LEN:int = 4;
	
	/**
	 * 命令代码的长度使用16位整数保存，占用2字节
	 */	
	public static var METHOD_CODE_LEN:int = 2;

	public static var endian:String = Endian.LITTLE_ENDIAN;

	/**
	 * 返回一个低位的字节数组
	 */	
	public static function getBaseBA():ByteArray
	{
		var __bytes:ByteArray = new ByteArray();
		__bytes.endian = endian;
		return __bytes;
	}

	public static function getRandom($max:int):int
	{
		return int(Math.random()*$max);
	}

	/**
	 * 返回最终要发送的数据，在要发送的数据中加入首位验证码和时间戳
	 * @param $methodCode 发送的方法代码
	 * @param $bytes 要发送的数据body
	 */	
	public static function getSendBA($methodCode:int, $bytes:ByteArray=null):ByteArray
	{
		var __bytes:ByteArray = PacketBuffer.getBaseBA();
		//写入校验码
		var __mask1:* = getRandom(RANDOM_BASE) & PacketBuffer.MASK1;
		var __mask2:* = getRandom(RANDOM_BASE) & PacketBuffer.MASK2;
		__bytes.writeByte(__mask1);
		__bytes.writeByte(__mask2);
		//trace(__mask1, __mask2);
		//写入信息主体的长度
		var __bodyLen:int = $bytes ? $bytes.length : 0;
		//写入信息的整体长度，整体长度为非主体长度+主体长度
		__bytes.writeInt(METHOD_CODE_LEN + __bodyLen);
		//写入方法代码
		__bytes.writeShort($methodCode);
		//写入信息主体
		if($bytes)
			__bytes.writeBytes($bytes);
		//写入校验码
		__bytes.writeByte(getRandom(RANDOM_BASE) & MASK2);
		__bytes.writeByte(getRandom(RANDOM_BASE) & MASK1);
		
		return __bytes;
	}
	
	public function PacketBuffer()  
	{  
		_buf = getBaseBA();
	}  

	//临时保存服务器发来的消息，如果这次消息被拆包了，就保存拆包的前一部分，一直到包完整
	private var _buf:ByteArray;

	/**
	 * 获取数据包
	 * @$ba socket服务器发来的未经拆包的数据
	 * @return 返回一个经过拆包的数组。<br />
	 * 这个数组的length一般是1，如果两个包一起发过来，则值可能是2。因此需要用循环来处理这个结果。
	 */
	public function getPackets($ba:ByteArray):Array  
	{  			
		//最终取得的信息列表
		var __msgs:Array = [];  

		//当前处理到的指针位置
		var __pos:uint = 0;  

		//保存前置校验码占用的字节长度＋信息主题占用的长度
		var __preMaskAndBody_len:int = PRE_MASK_LEN + BODY_LEN;

		//将传来的数据写入缓冲区的末尾
		_buf.position = _buf.length;  
		_buf.writeBytes($ba);

		//读取缓冲区
		_buf.position = 0;  
		while (_buf.bytesAvailable >= __preMaskAndBody_len)  
		{
			var __flag1:uint = uint(_buf.readByte());
			//trace('__flag1:', __flag1);
			if ((__flag1 & MASK1) != __flag1) 
				continue;
			var __flag2:uint = uint(_buf.readByte());
			//trace('__flag2:', __flag2);
			if ((__flag2 & MASK2) != __flag2) 
				continue;
			
			//trace('执行到flag之后');
			__pos = _buf.position;
			var __bodyLen:int=_buf.readInt();
			trace('__bodyLen:', __bodyLen, ',__pos:', __pos, '_buf.length:', _buf.length);
			//如果没有将数据包的所有数据接受完全（即当前可用的长度小于当前位置＋消息长度＋尾部校验码长度）则等待下一次处理
			if (_buf.length < __pos + __bodyLen + SUF_MASK_LEN) break;
			//设置位置，读取尾部校验码
			_buf.position=__pos + __bodyLen;
			__flag1 = _buf.readByte();
			__flag2 = _buf.readByte();
			//如果结束码校验正常则提取消息体加入队列
			if ((__flag1 & MASK2) == __flag1 && (__flag2 & MASK1) == __flag2)
			{
				//长度在允许的范围内就析取数据包
				if (__bodyLen <= MAX_SIZE)
				{
					//跳过前面的信息长度值（32位整数，占4字节）
					_buf.position =__pos + BODY_LEN;
					//建立一个Object，将数据包的method和body放在其中
					var __msg:Object = {};
					//写入方法类型
					__msg.method = _buf.readShort();
					var __msgBody:ByteArray = getBaseBA();
					
					_buf.readBytes(__msgBody, 0, __bodyLen - METHOD_CODE_LEN);   //len为body的长度，将body的数据放入msgBody  
					__msgBody.position = 0;
					__msg.body = __msgBody;
					__msgs.push(__msg);  //放入数组
					_buf.position += 2;
				}
			}
			else
			{
				_buf.position=__pos;// + msgLen;
			}
		}
		__pos = _buf.position;
		//如果缓冲区数据全部处理完则清空缓冲区
		if (_buf.bytesAvailable <= 0) clear();
		else
		{
			//如果缓冲区没有处理完
			//将剩余的数据读入一个临时数组
			var __tmp:ByteArray = getBaseBA();
			_buf.position = __pos - __preMaskAndBody_len;
			_buf.readBytes(__tmp, 0, _buf.bytesAvailable);
			//清空缓冲区
			clear();
			//将临时数组中保存的数据写入新的空白缓冲区
			_buf.writeBytes(__tmp,0,__tmp.length);
		}
		return __msgs; 
	} 

	/**
	 * 清空缓冲区，让缓冲区可以用于新的处理
	 */	
	public function clear():void  
	{  
		_buf = getBaseBA();  
	}  
}  
}
