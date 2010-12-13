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
		public static const PLAY_INSUF_BW:String = "NetStream.Play.InsufficientBW";
		
		//下面3个play相关的code来源于NetStream的client的onPlayStatus处理器
		public static const PLAY_COMPLETE:String = 'NetStream.Play.Complete';			//流的播放已经结束
		public static const PLAY_SWITCH:String = 'NetStream.Play.Switch';				//流的订阅者正在从播放列表中的一个流切换到另一个流
		public static const PLAY_TRANSITION:String = 'NetStream.Play.TransitionComplete';		//应用流比特率切换之后，订户将切换到新的流
		
		public static const BUFFER_EMPTY:String = "NetStream.Buffer.Empty";
		public static const BUFFER_FULL:String = "NetStream.Buffer.Full";
		public static const FAILED:String = "NetStream.Failed";
	}
}