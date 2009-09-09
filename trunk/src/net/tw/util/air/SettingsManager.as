package net.tw.util.air {
	import flash.data.EncryptedLocalStore;
	import flash.desktop.NativeApplication;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	//
	public class SettingsManager extends EventDispatcher {
		protected var itemName:String;
		protected var objects:Array;
		protected var vars:Array;
		public var autoStoreOnExit:Boolean=true;
		//
		public function SettingsManager(name:String="settings", a:Array=null) {
			itemName=name;
			objects=[];
			vars=[];
			if (a!=null) for each (var o:Object in a) manage(o);
			restoreVars();
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExit);
		}
		protected function restoreVars():void {
			var prefs:Object=getPrefs();
			for (var a:String in prefs) {
				if (!objects.some(function(element:*, index:int, arr:Array):Boolean {return element.target.id==a})) {
					storeVar(a, prefs[a]);
				}
			}
		}
		private function onExit(e:Event):void {
			dispatchEvent(new Event("store"));
			if (autoStoreOnExit) store();
		}
		public function manage(o:Object, prop:String=null):void {
			if (prop=='toolTip') trace('manage', o, prop);
			objects.push({target:o, prop:prop});
			// On gère un conflit éventuel...
			for (var i:uint=0; i<vars.length; i++) {
				if (vars[i].id==o.id) vars.splice(i, 1);
			}
		}
		public function storeVar(uniqueIdentifer:String, val:*):void {
			trace('storeVar', uniqueIdentifer, val);
			vars.push({id:uniqueIdentifer, v:val});
		}
		public function hasVar(uniqueIdentifier:String):Boolean {
			var prefs:Object=getPrefs();
			return prefs[uniqueIdentifier]!=null;
		}
		public function removeVar(uniqueIdentifer:String):void {
			for (var i:uint=0; i<vars.length; i++) {
				var o:Object=vars[i];
				if (o.id==uniqueIdentifer) {
					vars.splice(i, 1);
					return;
				}
			}
		}
		protected function getPrefs():Object {
			var bytes:ByteArray=EncryptedLocalStore.getItem(itemName);
			return bytes==null ? {} : bytes.readObject();
		}
		public function retrieveVar(uniqueIdentifier:String):* {
			var prefs:Object=getPrefs();
			return prefs[uniqueIdentifier] ? prefs[uniqueIdentifier] : null;
		}
		public function store():void {
			EncryptedLocalStore.removeItem(itemName);
			var prefs:Object=new Object();
			for each (var o:Object in objects) {
				var tg:Object=o.target;
				//trace(tg);
				var prop:String=o.prop as String;
				if (prop==null) {
					var className:String = describeType(tg).@name.toString();
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
						case 'mx.controls::ComboBox':
							prop='selectedIndex';
							break;
						default:
							trace(className, 'not managed!');
					}
				}
				if (prop!=null) {
					if (prop=='toolTip') trace('store', tg, prop, tg[prop]);
					var pair:Object=prefs[tg.id] ? prefs[tg.id] : {};
					pair[prop]=tg[prop];
					prefs[tg.id]=pair;
				}
			}
			for each (o in vars) {
				prefs[o.id]=o.v;
				trace('var', o.id);
				for each(var s:String in o.v) {
					trace(' - ', s, o.v[s]);
				}
			}
			var bytes:ByteArray=new ByteArray();
			bytes.writeObject(prefs);
			EncryptedLocalStore.setItem(itemName, bytes);
		}
		public function load():void {
			var prefs:Object=getPrefs();
			//
			for each (var o:Object in objects) {
				var object:Object=o.target;
				if (prefs[object.id]) {
					var props:Object=prefs[object.id];
					for (var p:String in props) {
						object[p]=props[p];
						if (p=='toolTip') trace('load', object, p, props[p]);
					}
				}
			}
		}
	}
}