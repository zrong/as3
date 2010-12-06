////////////////////////////////////////////////////////////////////////////////
//
//  zengrong.net
//  创建者:	zrong
//  最后更新时间：2010-12-06
//
////////////////////////////////////////////////////////////////////////////////
package org.zengrong.media
{
	/**
	 * 保存NetStream连接时返回的字符串，这样在比对连接状态的时候就不用输入这些字符串了。
	 * @author zrong
	 */
	public class NetStreamInfoCode
	{
		//常用的NS连接错误信息
		public static const PUB_START:String = "NetStream.Publish.Start";
		public static const UNPUB_SUCCESS:String = "NetStream.Unpublish.Success";
		public static const PUB_BADNAME:String = "NetStream.Publish.BadName";
		public static const PLAY_START:String = "NetStream.Play.Start";
		public static const PLAY_STOP:String = "NetStream.Play.Stop";
		public static const PLAY_PUB_NOTIFY:String =  "NetStream.Play.PublishNotify";
		public static const PLAY_UNPUB_NOTIFY:String = "NetStream.Play.UnpublishNotify";
		public static const BUFFER_EMPTY:String = "NetStream.Buffer.Empty";
		public static const BUFFER_FULL:String = "NetStream.Buffer.Full";
		public static const PLAY_INSUF_BW:String = "NetStream.Play.InsufficientBW";
		public static const FAILED:String = "NetStream.Failed";
	}
}