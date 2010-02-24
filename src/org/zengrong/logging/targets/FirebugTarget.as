package org.zengrong.logging.targets
{

import mx.core.mx_internal;
import mx.logging.ILogger;
import mx.logging.LogEvent;
import mx.logging.LogEventLevel;
import mx.logging.targets.LineFormattedTarget;

import org.zengrong.logging.Firebug;

use namespace mx_internal;

/**
 *  Provides a logger target that outputs to a <code>LocalConnection</code>,
 *  connected to the MiniDebug application.
 */
public class FirebugTarget extends LineFormattedTarget
{

    public function FirebugTarget()
    {
        super();
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------



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
							  
    	firebug(event.level, level + date + category, event.message);
    }
    
    private function firebug($level:int, $info:String, $msg:*):void
    {
    	switch($level)
    	{
    		case LogEventLevel.DEBUG:
    			Firebug.debug($info, $msg);
    			break;
    		case LogEventLevel.INFO:
    			Firebug.info($info, $msg);
    			break;
    	}
    	
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
    
}

}
