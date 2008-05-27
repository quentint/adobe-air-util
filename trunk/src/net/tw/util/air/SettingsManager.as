package net.tw.util.air {
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.describeType;
	
	import mx.utils.ObjectUtil;
	//
	public class SettingsManager {
		protected var path:File;
		protected var objects:Array;
		public var autoStoreOnExit:Boolean=true;
		//
		public function SettingsManager(filename:String="settings.ini", a:Array=null) {
			objects=[];
			path=File.applicationStorageDirectory.resolvePath(filename);
			if (a!=null) for each (var o:Object in a) manage(o);
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExit);
		}
		private function onExit(e:Event):void {
			if (autoStoreOnExit) store();
		}
		public function manage(o:Object, prop:String=null):void {
			objects.push({object:o, prop:prop});
		}
		public function store():void {
			var prefs:Object=new Object();
			for each (var object:Object in objects) {
				var o:Object=object.object;
				var prop:String=object.prop as String;
				if (prop==null) {
					var className:String = describeType(o).@name.toString();
					switch (className) {
						case 'mx.controls::HSlider':
						case 'mx.controls::VSlider':
						case 'mx.controls::NumericStepper':
							prop='value';
							break;
						case 'mx.controls::RadioButton':
						case 'mx.controls::CheckBox':
							prop='selected';
							break;
						case 'mx.controls::TextArea':
						case 'mx.controls::TextInput':
							prop='text';
							break;
						default:
							trace(className, 'not managed!');
					}
				}
				if (prop!=null) {
					var pair:Object=prefs[o.id] ? prefs[o.id] : {};
					pair[prop]=o[prop];
					prefs[o.id]=pair;
				}
			}
			//
			var s:FileStream=new FileStream();
			s.open(path, FileMode.WRITE);
			s.writeObject(prefs);
			s.close();
		}
		public function load():void {
			if (!path.exists) return; 
			var s:FileStream=new FileStream();
			s.open(path, FileMode.READ);
			var prefs:Object=s.readObject();
			//
			for each (var o:Object in objects) {
				var object:Object=o.object;
				if (prefs[object.id]) {
					var props:Object=prefs[object.id];
					for (var p:String in props) object[p]=props[p];
				}
			}
			s.close();
		}
	}
}