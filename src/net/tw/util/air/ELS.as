package net.tw.util.air {
	import flash.data.EncryptedLocalStore;
	import flash.utils.ByteArray;
	//
	public class ELS {
		public static function getItem(name:String):* {
			if (!hasItem(name)) return null;
			return EncryptedLocalStore.getItem(name).readObject();
		}
		public static function hasItem(name:String):Boolean {
			return EncryptedLocalStore.getItem(name)!=null;
		}
		public static function setItem(name:String, data:*, stronglyBound:Boolean=false):void {
			var ba:ByteArray=new ByteArray();
			ba.writeObject(data);
			EncryptedLocalStore.setItem(name, ba, stronglyBound);
		}
		public static function removeItem(name:String):void {
			EncryptedLocalStore.removeItem(name);
		}
		public static function reset():void {
			EncryptedLocalStore.reset();
		}
	}
}