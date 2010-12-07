package org.zengrong.logging.targets
{

import flash.events.StatusEvent;
import flash.net.LocalConnection;

import mx.core.mx_internal;
import mx.logging.ILogger;
import mx.logging.LogEvent;
import mx.logging.LogEventLevel;
import mx.logging.targets.LineFormattedTarget;

import org.zengrong.utils.TimeUtil;

use namespace mx_internal;

/**
 *  Provides a logger target that outputs to a <code>LocalConnection</code>,
 *  connected to the MiniDebug application.
 */
public class LCDebugTarget extends LineFormattedTarget
{

    public function LCDebugTarget(connection:String = "_debugLocalConnection",
									method:String = "lcHandler")
    {
        super();

        _lc = new LocalConnection();
        _lc.addEventListener(StatusEvent.STATUS, statusHandler);
        _connection = connection;
        _method = method;
        this.level = LogEventLevel.DEBUG;
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var _lc:LocalConnection;
    
    /**
     *  @private
     *  The name of the method that we should call on the remote connection.
     */
    private var _method:String;

    /**
     *  @private
     *  The name of the connection that we should send to.
     */
    private var _connection:String;

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
    override public function logEvent(event:LogEvent):void
    {
    	var date:String = ""
    	if (includeDate || includeTime)
    	{
    		var d:Date = new Date();
    		if (includeDate)
    		{
    			date = d.getFullYear().toString() + "-" +
					   Number(d.getMonth() + 1).toString() + "-" +
					   d.getDate().toString() + fieldSeparator;
    		}	
    		if (includeTime)
    		{
    			date += padTime(d.getHours()) + ":" +
					    padTime(d.getMinutes()) + ":" +
					    padTime(d.getSeconds()) + "." +
					    padTime(d.getMilliseconds(), true) + fieldSeparator;
    		}
    	}
    	
        var level:String = "";
        if (includeLevel)
        {
        	level = "[" + LogEvent.getLevelString(event.level) +
				    "]" + fieldSeparator;
        }

 		var category:String = includeCategory ?
							  ILogger(event.target).category + fieldSeparator :
							  "";
							  
    	_lc.send(_connection, _method, event.level, level + date + category + event.message);
    }
    
    private function padTime(num:Number, millis:Boolean=false):String
    {
        if (millis)
        {
            if (num < 10)
                return "00" + num.toString();
            else if (num < 100)
                return "0" + num.toString();
            else 
                return num.toString();
        }
        else
        {
            return num > 9 ? num.toString() : "0" + num.toString();
        }
    }
    
    private static function statusHandler(evt:StatusEvent):void {
		switch (evt.level) {
			case "status":
				trace(TimeUtil.getFormatedTime(), "Debug message send succeeded");
				break;
			case "error":
				trace(TimeUtil.getFormatedTime(), "Debug message send failed");
				break;
		}
	}
}

}
