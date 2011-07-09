////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	董伟
//	修改者：zrong
//  修改时间：2011-06-10
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.net
{  
import flash.utils.ByteArray;
import flash.utils.Endian;

/**
 * Socket发来的数据如果过长，会拆包；如果两个操作比较近，也有可能两个数据包合成一个发送。这个类处理处理数据包的合并和分拆的相关操作。
 * 与com.youxi.net.Packet的区别，在于Packet类将数据流作为字符串处理
 * */
public class PacketBuffer
{  
	public static const MASK1:uint = 0x59;
	public static const MASK2:uint = 0x7a;
	public static const MAXSIZE:int=2100000000;
	
	/**
	 * 前面的掩码加上内容总长度占用的字节数
	 * 6的组成：2+4
	 * 2=前面两个校验码长度
	 * 4=消息包长度数据的长度，使用int写入，占用4字节
	 */	
	public static const MASK_AND_LEN:int = 6;
	
	/**
	 * 随机数的基准值
	 */	
	public static const RANDOM_BASE:int = 10000;
	/**
	 * 除去body的长度。
	 *
	 * 6的组成：2+2+2 见getSendBytes 
	 * 2=前面两个校验码长度，2=methodCode，2=后面两个校验码长度
	 *
	 * 2011-06-13修改，长度理解错误，应为：
	 * 6的组成:2+4
	 * 2=methodCode，methodCode使用short写入，占用2字节
	 * 4=消息包长度数据的长度，使用int写入，占用4字节
	 * 校验码不占用字节
	 */	
	public static const NO_BODY_LEN:int = 6;

	/**
	 * 返回一个低位的字节数组
	 */	
	public static function getBaseBA():ByteArray
	{
		var __bytes:ByteArray = new ByteArray();
		__bytes.endian = Endian.LITTLE_ENDIAN;
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
		__bytes.writeInt(PacketBuffer.NO_BODY_LEN + __bodyLen);
		//写入方法代码
		__bytes.writeShort($methodCode);
		//写入信息主体
		if($bytes)
			__bytes.writeBytes($bytes);
		//写入校验码
		__bytes.writeByte(getRandom(RANDOM_BASE) & PacketBuffer.MASK2);
		__bytes.writeByte(getRandom(RANDOM_BASE) & PacketBuffer.MASK1);
		
		return __bytes;
	}
	
	//临时保存服务器发来的消息，如果这次消息被拆包了，就保存拆包的前一部分，一直到包完整
	private var _buf:ByteArray;

	public function PacketBuffer()  
	{  
		_buf = getBaseBA();
	}  

	/**
	 * 获取数据包
	 * @$ba socket服务器发来的未经拆包的数据
	 * @return 返回一个经过拆包的数组。<br />
	 * 这个数组的length一般是1，如果两个包一起发过来，则值可能是2。因此需要用循环来处理这个结果。
	 */
	public function getPackets($ba:ByteArray):Array  
	{  			
		var __msgs:Array = [];  
		var __pos:uint = 0;  

		_buf.position = _buf.length;  
		_buf.writeBytes($ba);

		_buf.position = 0;  
		
		while (_buf.bytesAvailable >= MASK_AND_LEN)  
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
			//如果没有将数据包的所有数据接受完全则等待下一次处理
			if (_buf.length < __pos + __bodyLen + 2)
				break;
			_buf.position=__pos + __bodyLen;

			//如果结束码校验正常则提取消息体加入队列
			__flag1 = _buf.readByte();
			__flag2 = _buf.readByte();
			if ((__flag1 & MASK2) == __flag1 && (__flag2 & MASK1) == __flag2)
			{
				//长度在允许的范围内就析取数据包
				if (__bodyLen <= MAXSIZE)
				{
					//跳过前面的信息长度值（32位整数，占4字节）
					_buf.position =__pos + 4;
					//建立一个Object，将数据包的method和body放在其中
					var __msg:Object = {};
					//写入方法类型
					__msg.method = _buf.readShort();
					var __msgBody:ByteArray = getBaseBA();
					
					_buf.readBytes(__msgBody, 0, __bodyLen - NO_BODY_LEN);   //len为body的长度，将body的数据放入msgBody  
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
		if (_buf.bytesAvailable <= 0)
			clear();
		else
		{
			var __tmp:ByteArray = getBaseBA();

			_buf.position = __pos - MASK_AND_LEN;
			_buf.readBytes(__tmp,0,_buf.bytesAvailable);

			clear();
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
