package org.zengrong.rpc
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;

	public class Remoting extends NetConnection
	{
		public static const CONNECT_ERROR:String = 'connectError';
		protected var gateway:String;
		protected var service:String;
		
		public function Remoting($gateway:String, $service:String)
		{
			super();
			gateway = $gateway;
			service = $service;
			this.addEventListener(NetStatusEvent.NET_STATUS, _netStatusHandler);
			this.addEventListener(IOErrorEvent.IO_ERROR, _connError);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _connError);
			this.connect(gateway);
			trace('remoting connect',$gateway, $service);
		}
		
		private function _netStatusHandler(evt:NetStatusEvent):void
		{
			trace('remoting状态：', evt.info.code);
			switch(evt.info.code) {
				case "NetConnection.Connect.Failed":
					dispatchEvent(new Event(CONNECT_ERROR));
					break;
			}
		}
		
		private function _connError(evt:*):void
		{
			dispatchEvent(new Event(CONNECT_ERROR));
		}
		
		override public function call($methodName:String, $responder:Responder, ...$arguments):void {
			var __operationPath:String = service + "." + $methodName;
			var __callArgs:Array = [__operationPath, $responder];
			for (var i:uint = 0; i < $arguments.length; i++) {
		        __callArgs.push($arguments[i]);
		    }
			super.call.apply(null, __callArgs);
		}
		
		override public function toString():String
		{
			return "org.zengrong.rpc.Remoting {" + 
					' gateway:' + gateway + 
					', service:' + service +'}';
		}
		
	}
}