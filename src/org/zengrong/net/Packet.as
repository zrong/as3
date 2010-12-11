////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-11-24
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.net
{
import flash.utils.ByteArray;

/**
 * Socket发来的数据如果过长，会拆包；如果两个操作比较近，也有可能两个数据包合成一个发送。这个类处理处理数据包的合并和分拆的相关操作。
 * */
public class Packet
{
	public static const BOF:String = '\\x00';	//看似5个字符，其实\\是\的转义符，这个字符串只有4个字符
	public static const EOF:String = '\\xFF';
	
	public function Packet()
	{
		_msg = '';
		_packetLength = 0;
		_messages = [];
	}

	private var _messageByte:ByteArray;
	private var _msg:String;
	private var _packetLength:int;
	private var _messages:Array;
	
	
	public function get packetLength():int
	{
		return _packetLength;
	}
	
	/**
	 * 返回消息是否完整。
	 */	
	public function get isIntact():Boolean
	{
		return _messageByte == null;
	}
	
	public function get message():String
	{
		return _msg;
	}
	
	/**
	 * 对数据包进行解析，并返回解析到的数据。
	 * @param $data 从服务器传来的ByteArray数据包。
	 * @return 如果数据包完整，返回的数组元素为1。<br />
	 * 如果数据包是合成数据包，返回的元素数量与合成的数据包相同。但不包含不完整的部分<br />
	 * 如果数据包不完整，会返回空数组。
	 */		
	public function getMessage($data:ByteArray):Array
	{
		_messages = [];
		$data.position = 0;
		_msg = $data.readUTFBytes($data.bytesAvailable);
		_packetLength = $data.length;
		//如果发来的消息是开头
		if(isBOF(_msg))
		{
			//如果发来的消息是合成消息
			if(hasEOF(_msg))
			{
				while(_msg.indexOf(EOF) != -1)
				{
					//字符串的切割点，是第一次找到EOF的索引加上EOF的长度。因为索引是以EOF的第一个字符的位置为准的
					var __cutPoint:int = _msg.indexOf(EOF) + EOF.length;
					_messages.push(_msg.slice(0, __cutPoint));
					_msg = _msg.slice(__cutPoint);
				}
				/*
				如果_msg不为空，说明合成的信息中的最后一条被拆包了，这时就需要把剩下的信息写入_messageByte暂存等待下一条信息进行组合
				这里有可能有问题，因为拆包的时候可能拆的不是一个整个的字符串，而读取的时候是最为字符串读取的
				这就会导致写入的信息不完整，和下次传过来的信息拼起来就可能出错。这里暂时不处理
				*/
				if(_msg.length > 0)
				{
					_messageByte = new ByteArray();
					_messageByte.writeUTFBytes(_msg);
				}
			}
			//如果发来的信息是完整的一条，就清空_messageByte
			else if(isEOF(_msg))
			{
				_messageByte = null;
				_messages.push(_msg);
			}
			//没有结束，保存数据，返回未完成
			else
			{
				_messageByte = new ByteArray();
				$data.position = 0;
				$data.readBytes(_messageByte);
			}
		}
		//没有消息开头，说明消息被拆包了
		else
		{
			//将发来的字节写入_messageByte末尾
			$data.position = 0;
			$data.readBytes(_messageByte, _messageByte.length);
			_messageByte.position = 0;
			//重新解析拼好的messageByte
			_messages = getMessage(_messageByte);
		}
		return _messages.concat();
	}
	
	//确定消息中间部分是否包含开头字符，开头字符是第一个字符则不算。
	private function hasBOF($msg:String):Boolean
	{
		var __bofIndex:int = $msg.indexOf(BOF);
		return __bofIndex > 0;
	}
	
	//确定消息中间部分是否包含结尾字符，结尾字符是最后一个则不算。
	private function hasEOF($msg:String):Boolean
	{
		var __eofIndex:int = $msg.indexOf(EOF);
		if(__eofIndex == -1)
			return false;
		/*
		如果EOF本来就在最后，也返回false
		这时indexOf找到的位置就是$msg的长度减去EOF的长度
		*/
		if(__eofIndex == ($msg.length - EOF.length))
			return false;
		return true;
	}
	
	//确定消息是否从开头字符开始
	private function isBOF($msg:String):Boolean
	{
		return $msg.slice(0, BOF.length) == BOF;
	}
	
	//确定消息是否以结尾字符串结束
	private function isEOF($msg:String):Boolean
	{
		return $msg.slice($msg.length-EOF.length, $msg.length) == EOF;
	}
	
	//返回消息中的code部分
	public static function getCode($msg:String):String
	{
		return $msg.slice(4, 8);
	}
	
	//返回消息主体
	public static function getBody($msg:String):String
	{
		return $msg.slice(8, $msg.length-4);
	}
}
}