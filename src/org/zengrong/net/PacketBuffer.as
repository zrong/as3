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
	 * 4个校验码
	 */
	public static var MASK1:uint = 0x59;
	public static var MASK2:uint = 0x7a;
	public static var MASK3:uint = 0x7a;
	public static var MASK4:uint = 0x59;

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
	 * 消息体长度使用32位整数保存，占用4字节
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
		//写入前置校验码
		__bytes.writeByte(getRandom(RANDOM_BASE) & PacketBuffer.MASK1);
		__bytes.writeByte(getRandom(RANDOM_BASE) & PacketBuffer.MASK2);
		//trace(__mask1, __mask2);
		//写入信息主体的长度
		var __bodyLen:int = $bytes ? $bytes.length : 0;
		//写入信息的整体长度，整体长度为非主体长度+主体长度
		__bytes.writeInt(METHOD_CODE_LEN + __bodyLen);
		//写入方法代码
		__bytes.writeShort($methodCode);
		//写入信息主体
		if($bytes) __bytes.writeBytes($bytes);
		//写入后置校验码
		__bytes.writeByte(getRandom(RANDOM_BASE) & MASK3);
		__bytes.writeByte(getRandom(RANDOM_BASE) & MASK4);
		
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
		_buf.position = 0;  
		var __flag1:uint;
		var __flag2:uint;
		trace('开始解析，整个缓冲区大小:', _buf.length);
		//读取整个缓冲区
		while (_buf.bytesAvailable >= __preMaskAndBody_len)  
		{
			//读取第一个校验码
			__flag1 = uint(_buf.readByte());
			trace('__flag1:', __flag1);
			//判断第一个校验码是否匹配，不匹配就继续读取
			if ((__flag1 & MASK1) != __flag1) continue;
			//读取第二个校验码
			__flag2 = uint(_buf.readByte());
			trace('__flag2:', __flag2);
			//判断第二个校验码是否匹配，不匹配就继续读
			if ((__flag2 & MASK2) != __flag2) continue;
			trace('前置校验码读取正确,pos:', __pos);
			//读取信息主体的长度
			var __bodyLen:int=_buf.readInt();
			//暂存信息主体开头所在位置的指针
			__pos = _buf.position;
			trace('信息主体长度:', __bodyLen, ',pos:', __pos, '_buf.bytesAvailable:', _buf.bytesAvailable, '_buf.length:', _buf.length);
			//如果没有将数据包的所有数据接受完全（即当前可用的长度小于当前位置＋消息主体长度＋尾部校验码长度）则等待下一次处理
			if (_buf.length < __pos + __bodyLen + SUF_MASK_LEN) break;
			//数据包长度足够，就读取尾部校验码
			_buf.position = __pos + __bodyLen;
			__flag1 = _buf.readByte();
			__flag2 = _buf.readByte();
			trace('_buf.pos:', _buf.position);
			//如果后置校验码正确则提取消息体加入队列
			if ((__flag1 & MASK3) == __flag1 && (__flag2 & MASK4) == __flag2)
			{
				trace('校验码正确');
				//长度在允许的范围内就析取数据包
				if (__bodyLen <= MAX_SIZE)
				{
					//将缓冲区的读取位置设置到信息主体开头
					_buf.position =__pos;
					//建立一个Object，将数据包的method和body放在其中
					var __msg:Object = {};
					//读取信息主体中的方法名称，使用16位整数保存
					__msg.method = _buf.readShort();
					//读取信息主体中的数据，读取的长度从主体信息长度中减去方法名占用的长度
					var __msgBody:ByteArray = getBaseBA();
					_buf.readBytes(__msgBody, 0, __bodyLen - METHOD_CODE_LEN);  
					__msgBody.position = 0;
					__msg.body = __msgBody;
					//放入数组
					__msgs.push(__msg); 
					//将指针位置移动到后置校验码的后方
					_buf.position += SUF_MASK_LEN;
				}
			}
			//如果后置校验码不正确，就还原缓冲区的指针到信息主体长度记录之前
			else _buf.position= __pos;
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
