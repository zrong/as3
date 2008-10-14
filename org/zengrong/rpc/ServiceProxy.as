//*******************************************************************************
//	Copyright (c) 2006 Patterson Consulting, Inc
//	All rights reserved.
//
// 	Redistribution and use in source and binary forms, with or without
// 	modification, are permitted provided that the following conditions are met:
//
// 		* Redistributions of source code must retain all references to Patterson
// 		  Consulting, Danny Patterson, com.dannypatterson and dannypatterson.com.
//		* Redistributions of source code must retain the above copyright
//		  notice, this list of conditions and the following disclaimer.
//		* Redistributions in binary form must reproduce the above copyright
//		  notice, this list of conditions and the following disclaimer in the
//		  documentation and/or other materials provided with the distribution.
//		* Neither the name of the Patterson Consulting nor the names of its
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
// 	THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND ANY
// 	EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// 	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// 	DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
// 	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// 	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// 	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// 	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// 	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// 	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//*******************************************************************************


package org.zengrong.rpc {
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	[Event(name="RESULT", type="remoting.service.ResultEvent")]
	[Event(name="FAULT", type="remoting.service.FaultEvent")]
	[Event(name="CONNECTION_ERROR", type="remoting.service.FaultEvent")]
	
	/**
	 * @author Danny Patterson
	 * @version 1.0.0 2006-07-03
	 */	
	public dynamic class ServiceProxy extends Proxy implements IEventDispatcher {
		
		protected var connection:NetConnection;
		protected var gateway:String;
		private var eventDispatcher:EventDispatcher;
		private var service:String;
		private var useOperationPooling:Boolean;
		
		
		public function ServiceProxy(gateway:String, service:String, useOperationPooling:Boolean = true) {
			this.gateway = gateway;
			this.service = service;
			this.useOperationPooling = useOperationPooling;
			eventDispatcher = new EventDispatcher();
			connection = new NetConnection();
			connection.client = this;
			connection.addEventListener(NetStatusEvent.NET_STATUS, onConnectionStatus);
			connection.addEventListener(IOErrorEvent.IO_ERROR, onConnectionError);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR , onConnectionError);
			connection.objectEncoding = ObjectEncoding.AMF0;
			connection.connect(gateway);
		}
		
		private function onConnectionError(event:ErrorEvent):void {
			dispatchEvent(new FaultEvent(FaultEvent.CONNECTION_ERROR, true, true, {text:"Connection Error: " + event.text}));
		}
		
		private function onConnectionStatus(event:NetStatusEvent):void {
			switch(event.info.code) {
				case "NetConnection.Connect.Failed":
					dispatchEvent(new FaultEvent(FaultEvent.CONNECTION_ERROR, true, true, {text:"Connection Error: " + event.info.code}));
					break;
			}
		}
		
		private function onFault(fault:Object):void {
			dispatchEvent(new FaultEvent(FaultEvent.FAULT, true, true, fault));
			//fault的结构参见remoting.Remoting
			//trace(fault);
		}
		
		private function onResult(result:Object):void {
			dispatchEvent(new ResultEvent(ResultEvent.RESULT, true, true, result));
			//result会有一个result属性,result属性的结构参见remoting.remotingResultFormat.*
		}
		
		public function AppendToGatewayUrl(value:Object):void {
			gateway += value.toString();
		}
		
		/**
		 * @param methodName (String)
		 * @param arguments (Array)
		 */
		public function call(methodName:String, arguments:Array):void {
			var responder:Responder = new Responder(onResult, onFault);
			var operationPath:String = service + "." + methodName.toString();
			trace("Remoting.call 执行");
			trace("operationPath:", operationPath);
			trace("arguments:", arguments.toString());
			trace("arguments.toString.length:", arguments.toString().length);
			trace("arguments.length:", arguments.length);
			var operation:Operation = new Operation(connection, operationPath, responder, arguments);
			if(useOperationPooling) {
				OperationPool.getInstance().addOperation(operation);
			}else {
				operation.execute();
			}
		}
		
		flash_proxy override function callProperty(methodName:*, ...args):* {
			try {
				call(methodName, args);
			}catch(error:Error) {}
			return null;
		}
		
  		flash_proxy override function hasProperty(name:*):Boolean {
			return false;
		}
		
		flash_proxy override function getProperty(name:*):* {
			return null;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, weakRef:Boolean = false):void {
			eventDispatcher.addEventListener(type, listener, useCapture, priority, weakRef);
		}
		
		public function dispatchEvent(event:Event):Boolean {
			return eventDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean {
			return eventDispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean {
			return eventDispatcher.willTrigger(type);
		}
		
		public function toString():String{
			return "remoting.service.ServiceProxy";
		}
	}
}
