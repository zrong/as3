package org.zengrong.logging
{
import flash.utils.getQualifiedClassName;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.logging.LogEvent;
import mx.logging.LogEventLevel;
import mx.logging.targets.TraceTarget;
import mx.utils.ObjectUtil;
public class Logger
{
	private static var _log:ILogger;
	private static var _target:TraceTarget;
	
	public static const LC_NAME:String = '_debugLocalConnection';
	private static const LC_FUN_NAME:String = 'lcHandler';
	private static const CAT:String = 'net.zengrong.logging.Logger';
	
	public static var FILTERS:Array = [CAT];
	
	public static const TRACE:String = 'trace';
	public static const FIREBUG:String = 'firebug';
	
	public static var TYPE:String = TRACE; 
	
	//--------------------------------------------------------------------------
	//
	//  类属性
	//
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//  level
	//--------------------------------------------------------------------------
	
	public static function get level():int
	{
		return Logger.getTarget().level;
	}
	
	public static function set level($level:int):void
	{
		Logger.getTarget().level = $level;
	}
	
	//--------------------------------------------------------------------------
	//  fieldSeparator
	//--------------------------------------------------------------------------
	
	public static function get fieldSeparator():String
	{
		return Logger.getTarget().fieldSeparator;
	}
	
	public static function set fieldSeparator($sep:String):void
	{
		Logger.getTarget().fieldSeparator = $sep;
	}
	
	//--------------------------------------------------------------------------
	//  includeDate
	//--------------------------------------------------------------------------
	
	public static function get includeDate():Boolean
	{
		return Logger.getTarget().includeDate;
	}
	
	public static function set includeDate($value:Boolean):void
	{
		Logger.getTarget().includeDate = $value;
	}
	
	//--------------------------------------------------------------------------
	//  includeTime
	//--------------------------------------------------------------------------
	
	public static function get includeTime():Boolean
	{
		return Logger.getTarget().includeTime;
	}
	
	public static function set includeTime($value:Boolean):void
	{
		Logger.getTarget().includeTime = $value;
	}
	
	//--------------------------------------------------------------------------
	//  includeLevel
	//--------------------------------------------------------------------------
	
	public static function get includeLevel():Boolean
	{
		return Logger.getTarget().includeLevel;
	}
	
	public static function set includeLevel($value:Boolean):void
	{
		Logger.getTarget().includeLevel = $value;
	}
	
	//--------------------------------------------------------------------------
	//  includeCategory
	//--------------------------------------------------------------------------
	
	public static function get includeCategory():Boolean
	{
		return Logger.getTarget().includeCategory;
	}
	
	public static function set includeCategory($value:Boolean):void
	{
		Logger.getTarget().includeCategory = $value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  类方法（公开）
	//
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//  debug()
	//--------------------------------------------------------------------------
	public static function debug(...rest):void
	{
		switch(TYPE)
		{
			case TRACE:
				Logger.getLogger().debug.apply(null, rest);
				break;
			case FIREBUG:
				Firebug.debug.apply(null, rest);
				break;			
		}		
	}
	
	//--------------------------------------------------------------------------
	//  error()
	//--------------------------------------------------------------------------
	public static function error(...rest):void
	{
		switch(TYPE)
		{
			case TRACE:
				Logger.getLogger().error.apply(null, rest);
				break;
			case FIREBUG:
				Firebug.error.apply(null, rest);
				break;			
		}	
	}
	
	//--------------------------------------------------------------------------
	//  fatal()
	//--------------------------------------------------------------------------
	public static function fatal(...rest):void
	{
		switch(TYPE)
		{
			case TRACE:
				Logger.getLogger().fatal.apply(null, rest);
				break;
			case FIREBUG:
				Firebug.log.apply(null, rest);
				break;			
		}	
	}
	
	//--------------------------------------------------------------------------
	//  info()
	//--------------------------------------------------------------------------
	public static function info(...rest):void
	{
		switch(TYPE)
		{
			case TRACE:
				Logger.getLogger().info.apply(null, rest);
				break;
			case FIREBUG:
				Firebug.info.apply(null, rest);
				break;			
		}	
	}
	
	//--------------------------------------------------------------------------
	//  warn()
	//--------------------------------------------------------------------------
	public static function warn(...rest):void
	{
		switch(TYPE)
		{
			case TRACE:
				Logger.getLogger().warn.apply(null, rest);
				break;
			case FIREBUG:
				Firebug.warn.apply(null, rest);
				break;			
		}	
	}
	
	
	//--------------------------------------------------------------------------
	//  getLevelString()
	//--------------------------------------------------------------------------
	
	public static function getLevelString ($level:int):String
	{
		return LogEvent.getLevelString($level);
	}
	
	//--------------------------------------------------------------------------
	//
	//  类方法（私有）
	//
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//  getLogger()
	//--------------------------------------------------------------------------
	private static function getLogger():ILogger
	{
		if(Logger._log == null)
		{
			Logger.getTarget();
			Logger._log = Log.getLogger(CAT);
		}
		return Logger._log;
	}
	
	//--------------------------------------------------------------------------
	//  getTarget()
	//--------------------------------------------------------------------------
	
	private static function getTarget():TraceTarget
	{
		if(Logger._target == null)
		{
			_target = new TraceTarget();
			_target.filters = FILTERS;
			_target.level = LogEventLevel.DEBUG;
			Log.addTarget(_target);
		}
		return Logger._target;
	}
	
	private static function getTargetParam($obj:*):String
	{
		var _msg:String = '';
		_msg += '[' + getQualifiedClassName($obj) + ']';
		//如果是简单的数据类型，直接使用toString
		if(ObjectUtil.isSimple($obj))
		{
			_msg += $obj.toString();
		}
		else
		{
			_msg += ObjectUtil.toString($obj);
		}
		return _msg;
		//Logger.trace2(_msg);
	}
		
	//--------------------------------------------------------------------------
	//
	//  构造函数
	//
	//--------------------------------------------------------------------------
	
	public function Logger()
	{
		throw(new Error('不能通过new创建实例！'));
		return;
	}
	
}

}