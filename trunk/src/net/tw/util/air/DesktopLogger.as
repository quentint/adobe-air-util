package net.tw.util.air {
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	public class DesktopLogger {
		public function DesktopLogger() {}
		public static function log(... rest:Array):void {
			var f:File=File.desktopDirectory.resolvePath('desktop-logger.txt');
			var s:FileStream=new FileStream();
			s.open(f, FileMode.APPEND);
			var str:String=new Date().toLocaleString()+' - '+App.getName()+' '+App.getVersion()+' - '+Capabilities.playerType+' '+(Capabilities.isDebugger ? 'debugger' : 'not debugger')+': ';
			for (var i:uint=0; i<rest.length; i++) {
				str+=Object(rest[i]).toString();
				if (i<rest.length-1) str+=', ';
			}
			trace(str);
			str+='\n';
			s.writeUTFBytes(str);
			s.close();
		}
	}
}