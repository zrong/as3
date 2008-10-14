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

	import flash.net.NetConnection;
	import flash.net.Responder;
	
	/**
	 * @author Danny Patterson
	 * @version 1.0.0 2006-07-03
	 */	
	public class Operation {
		
		private var connection:NetConnection;
		private var operationPath:String;
		private var responder:Responder;
		private var args:Array;
		
		
		public function Operation(connection:NetConnection, operationPath:String, responder:Responder, args:Array) {
			this.connection = connection;
			this.operationPath = operationPath;
			this.responder = responder;
			this.args = args;
		}
		
		
		public function execute():void {
			var callArgs:Array = new Array(operationPath, responder);
			connection.call.apply(null, callArgs.concat(args));
			trace("execute执行");
			trace("callArgs.concat(args)：", callArgs.concat(args));
		}
		
	}
	
}