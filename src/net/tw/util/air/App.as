package net.tw.util.air {
	import flash.desktop.NativeApplication;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.system.Capabilities;
	//
	import mx.core.IWindow;
	import mx.core.Window;
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
		//
		public static function centerWindow(w:IWindow):void {
			w.nativeWindow.x=(Screen.mainScreen.bounds.width-w.nativeWindow.width)/2;
			w.nativeWindow.y=(Screen.mainScreen.bounds.height-w.nativeWindow.height)/2;
		}
		public static function preventClose(w:Window, activateOnHide:IWindow=null):void {
			w.nativeWindow.addEventListener(Event.CLOSING, function(e:Event):void {
				e.preventDefault();
				w.visible=false;
				if (activateOnHide) activateOnHide.nativeWindow.activate();
			});
		}
	}
}