package org.zengrong.logging
{
	public class FirebugLogger
	{
		public function FirebugLogger()
		{
		}
		
		public function log(...parameters):void
		{
			Firebug.log.apply(null, parameters);
		}
		
		public function debug(...parameters):void
		{
			Firebug.debug.apply(null, parameters);
		}
		
		public function error(...parameters):void
		{
			Firebug.error.apply(null, parameters);
		}
		
		public function fatal(...parameters):void
		{
			Firebug.fatal.apply(null, parameters);
		}
		
		public function info(...parameters):void
		{
			Firebug.info.apply(null, parameters);
		}
		
		public function warn(...parameters):void
		{
			Firebug.info.apply(null, parameters);
		}
	}
}