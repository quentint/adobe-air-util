package net.tw.util.air {
   import flash.desktop.NativeApplication;
   import flash.desktop.Updater;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.net.URLRequest;
   import flash.net.URLStream;
   import flash.utils.ByteArray;
   
   import mx.controls.Alert;
   import mx.rpc.events.ResultEvent;
   import mx.rpc.http.HTTPService;
   //
   // Original source: http://flexair.mykii.eu/2007/12/17/air-beta-3-update/
   //
   public class UpdateManager extends EventDispatcher {
		private var _constantApplicationName:String;
		public var versionURL:String;
		private var version:XML;
		public var remoteVersion:String;
		public var remoteMessage:String;
		private var urlStream:URLStream;
		private var fileData:ByteArray;
		[Bindable] private var _currentVersion:String;
		[Bindable] private var appVersion:String;
		/*
		constructor
		*/
		public function UpdateManager(vURL:String, localAppName:String='temp-updater.air'):void {
			urlStream=new URLStream();
			fileData=new ByteArray();
			versionURL = vURL;
			_constantApplicationName=localAppName;
		}
		public function checkNewVersion():void {
			loadApplicationFile();
		}
		/*
		load the application.xml file
		*/
		protected function loadApplicationFile():void{
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			var  appId:String = appXml.ns::id[0];
			appVersion = appXml.ns::version[0];
			var appName:String = appXml.ns::filename[0];
			loadRemoteFile();
		}
		/*
		load a remote xml file to check for new version
		*/
		private function loadRemoteFile():void{
			var http:HTTPService = new HTTPService();
			http.url = versionURL;
			http.useProxy=false;
			http.method = "GET";
			http.resultFormat="xml";
			http.send();
			http.addEventListener(ResultEvent.RESULT, testVersion2);
		}
		/*
		check to see if an update exists and either
		force the update or give the user the option
		*/
		private function testVersion2(event:ResultEvent):void{
			version = XML(event.result);
			remoteVersion=version.@version;
			remoteMessage=version.@message;
			if((appVersion != remoteVersion) && version.@forceUpdate == true){
				getUpdate();
			} else if(appVersion != remoteVersion) {
				dispatchEvent(new Event("newVersion"));
			} else {
				//trace("There are no new updates available");
				dispatchEvent(new Event("noVersion"));
			}
		}
		/*
		download the new AIR installer file
		*/
		public function getUpdate():void{
			var urlReq:URLRequest=new URLRequest(version.@downloadLocation);
			urlStream.addEventListener(Event.COMPLETE, loaded);
			urlStream.load(urlReq);
		}
		/*
		read the new AIR file
		*/
		private function loaded(event:Event):void {
			urlStream.readBytes(fileData, 0, urlStream.bytesAvailable);
			writeAirFile();
		}
		/*
		write the new AIR installer to disk
		*/
		private function writeAirFile():void {
			var file:File = File.applicationStorageDirectory.resolvePath(_constantApplicationName);
			var fileStream:FileStream = new FileStream();
			fileStream.addEventListener(Event.CLOSE, fileClosed);
			fileStream.openAsync(file, FileMode.WRITE);
			fileStream.writeBytes(fileData, 0, fileData.length);
			fileStream.close();
		 }
		 /* close the FileStream and use the
		 Updater class to update the application
		 */
		private function fileClosed(event:Event):void {
			var updater:Updater = new Updater();
			var airFile:File = File.applicationStorageDirectory.resolvePath(_constantApplicationName);
			try {
				updater.update(airFile, version.@version);
			} catch (e:IllegalOperationError) {
				Alert.show("Cannot update from within ADL!", "IllegalOperationError");
			}
		}
	}
}