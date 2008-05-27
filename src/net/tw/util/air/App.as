package net.tw.util.air {
	import flash.desktop.NativeApplication;
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
	}
}