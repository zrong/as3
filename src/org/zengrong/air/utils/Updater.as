package org.zengrong.air.utils
{
	import air.update.ApplicationUpdater;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusFileUpdateErrorEvent;
	import air.update.events.StatusFileUpdateEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import flash.events.ErrorEvent;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	import mx.controls.ProgressBar;
	import mx.controls.ProgressBarMode;

	public class Updater extends ApplicationUpdater
	{
		private var _pb:ProgressBar;
		private var _fun:Function;
		
		public function Updater($configFile:String, $progressBar:ProgressBar, $fun:Function)
		{
			super();
			_pb = $progressBar;
			_fun = $fun;
			this.configurationFile =  new File('app:/'+$configFile);
			addEventListener(UpdateEvent.INITIALIZED, updateInitHandler);
			addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, statusUpdateErrorHandler);
			addEventListener(StatusUpdateEvent.UPDATE_STATUS, updateStatusHandler);
			addEventListener(UpdateEvent.DOWNLOAD_START, downloadStartHandler);
			addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, downloadCompleteHandler);
			addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, downloadErrorHandler);
			addEventListener(StatusFileUpdateErrorEvent.FILE_UPDATE_ERROR, statusFileUpdateErrorHandler);
			addEventListener(StatusFileUpdateEvent.FILE_UPDATE_STATUS, statusFileUpdateHandler);
			addEventListener(ErrorEvent.ERROR, errorHandler);
		}
		
		private function updateInitHandler(evt:UpdateEvent):void
			{
				trace(evt.toString());
				checkNow();
			}
			
			private function statusUpdateErrorHandler(evt:StatusUpdateErrorEvent):void
			{
				Alert.show('獲取更新信息出錯，原因：'+evt.text+'。仍使用舊版本！');
				startup();
			}
			
			private function downloadErrorHandler(evt:DownloadErrorEvent):void
			{
				Alert.show('下載更新程序出錯，原因：'+evt.text+'('+evt.errorID+')。仍使用舊版本！');
				revertPB();
				startup();
			}
			
			private function errorHandler(evt:ErrorEvent):void
			{
				Alert.show('分析更新信息出錯，原因：'+evt.text+'。仍使用舊版本！');
				startup();
			}
			
			private function statusFileUpdateErrorHandler(evt:StatusFileUpdateErrorEvent):void
			{
				Alert.show('更新程序出錯，原因：'+evt.text+'。仍使用舊版本！');
			}
			
			private function updateStatusHandler(evt:StatusUpdateEvent):void
			{
				trace(evt.toString());
				if(!evt.available)
				{
					startup();
				}
			}
			
			private function downloadStartHandler(evt:UpdateEvent):void
			{
				trace(evt.toString());
				_pb.indeterminate = false;
				_pb.mode = ProgressBarMode.EVENT;
				_pb.source = this;
				_pb.label = '下載更新%3%%';
			}
			
			private function downloadCompleteHandler(evt:UpdateEvent):void
			{
				trace(evt.toString());
				revertPB();
			}		
			private function statusFileUpdateHandler(evt:StatusFileUpdateEvent):void
			{
				trace(evt.toString());
			}
			
			private function revertPB():void
			{
				_pb.indeterminate = true;
				_pb.label = '載入中，請稍候……';
				_pb.source = null;
			}
			
			private function startup():void
			{
				_fun.apply();
			}
	}
}