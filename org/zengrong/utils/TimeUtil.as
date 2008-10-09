package org.zengrong.utils
{
	public class TimeUtil
	{
		/**
		 * 获取当前的时间，并格式化后作为字符串返回
		 */
		 static public function getTime():String
		 {
		 	var curTime:String = "";
			var my_date:Date = new Date();
			//
			var curHour:int = my_date.getHours();
			var curMinutes:int = my_date.getMinutes();
			var curSeconds:int = my_date.getSeconds();
			//
			var curHourString:String = curHour.toString();
			var curMinutesString:String = curMinutes.toString();
			var curSecondsString:String = curSeconds.toString();
			//
			curHourString = curHour<10 ? ("0" + curHourString) : curHourString;			
			curMinutesString = curMinutes<10 ? ("0" + curMinutesString) : curMinutesString;			
			curSecondsString = curSeconds<10 ? ("0" + curSecondsString) : curSecondsString;
			curTime = curHourString +":"+curMinutesString+":"+curSecondsString+" ";
			return curTime;
		}

	}
}