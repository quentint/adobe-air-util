package net.tw.util.air {
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import mx.core.Window;
	import flash.geom.Point;

	//
	public class App {
		public function App() {}
		public static function getDescriptor():XML {
			return NativeApplication.nativeApplication.applicationDescriptor;
		}
		public static function getNamespace():Namespace {
			return getDescriptor().namespace();
		}
		public static function getName():String {
			var ns:Namespace=getNamespace();
			return getDescriptor().ns::name;
		}
		public static function getVersion():String {
			var ns:Namespace=getNamespace();
			return getDescriptor().ns::version;
		}
		public static function getCopyright():String {
			var ns:Namespace=getNamespace();
			return getDescriptor().ns::copyright;
		}
		public static function runningOnMac():Boolean {
			return Capabilities.os.indexOf("Mac")==0;
		}
		public static function runningOnLinux():Boolean {
			return Capabilities.os.indexOf("Linux")==0;
		}
		public static function fixLoadURL(fileURL:String):String {
			return ((App.runningOnLinux() || App.runningOnMac()) && fileURL.substr(0, 7)!='file://') ? 'file://'+fileURL : fileURL;
		}
		public static function getAppSchemeURL(f:File):String {
			var absAppDir:File=new File(File.applicationDirectory.nativePath);
			return File.applicationDirectory.resolvePath(absAppDir.getRelativePath(f)).url;
		}
		//
		public static function centerWindow(w:*, offset:Point=null):void {
			if (!(w is NativeWindow) && !(w is Window)) {
				throw(new ArgumentError());
				return;
			}
			var o:*=w is NativeWindow ? w : w.nativeWindow;
			o.x=(Screen.mainScreen.bounds.width-o.width)/2+(offset ? offset.x : 0);
			o.y=(Screen.mainScreen.bounds.height-o.height)/2+(offset ? offset.y : 0);
		}
		public static function preventClose(w:NativeWindow, activateOnHide:NativeWindow=null):void {
			w.addEventListener(Event.CLOSING, function(e:Event):void {
				e.preventDefault();
				w.visible=false;
				if (activateOnHide) activateOnHide.activate();
			});
		}
	}
}