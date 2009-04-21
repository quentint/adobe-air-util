package net.tw.util.air {
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.html.*;
	import flash.utils.*;
	
	import mx.core.*;
	import mx.events.ResizeEvent;
	//
	public class HTMLOverlay extends EventDispatcher {
		protected var ph:DisplayObject;
		protected var phnw:NativeWindow;
		protected var sbv:Boolean;
		protected var t:Timer;
		//
		protected var p:HTMLLoader;
		protected var pw:NativeWindow;
		//
		protected var lastPlacingEvent:Event;
		public var needsPlacing:Boolean=true;
		protected var needsHiding:Boolean=false;
		//
		public function HTMLOverlay(placeHolder:UIComponent, scrollBarsVisible:Boolean=true) {
			ph=placeHolder;
			sbv=scrollBarsVisible;
			//
			if (ph.stage) setupListeners();
			else ph.addEventListener(Event.ADDED_TO_STAGE, setupListeners);
		}
		protected function setupListeners(e:Event=null):void {
			ph.removeEventListener(Event.ADDED_TO_STAGE, setupListeners);
			//
			phnw=ph.stage.nativeWindow;
			phnw.addEventListener(NativeWindowBoundsEvent.MOVE, updateOverlay);
			phnw.addEventListener(NativeWindowBoundsEvent.RESIZE, updateOverlay);
			ph.addEventListener(ResizeEvent.RESIZE, updateOverlay);
			phnw.addEventListener(Event.ACTIVATE, updateOverlay);
			phnw.addEventListener(Event.DEACTIVATE, hideOverlay);
			phnw.addEventListener(Event.CLOSING, beforeClose);
			phnw.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, onDSChange);
			//
			var nwio:NativeWindowInitOptions=new NativeWindowInitOptions();
			nwio.systemChrome=NativeWindowSystemChrome.NONE;
			nwio.type=NativeWindowType.LIGHTWEIGHT;
			p=HTMLLoader.createRootWindow(true, nwio, sbv, new Rectangle(placeholderAbsoluteLeft, placeholderAbsoluteTop, ph.width, ph.height));
			pw=p.stage.nativeWindow;
			pw.alwaysInFront=true;
			pw.addEventListener(Event.ACTIVATE, showOverlay);
			pw.addEventListener(Event.CLOSING, function (e:Event):void {e.preventDefault()});
			//
			updateOverlayIfNeeded();
			t=new Timer(15);
			t.addEventListener(TimerEvent.TIMER, updateOverlayIfNeeded);
			t.start();
			//
			dispatchEvent(new Event(Event.COMPLETE));
		}
		protected function beforeClose(e:Event):void {
			e.preventDefault();
			pw.close();
			phnw.close();
		}
		protected function onDSChange(e:NativeWindowDisplayStateEvent):void {
			if (e.afterDisplayState==NativeWindowDisplayState.MINIMIZED) pw.visible=false;
			else showOverlay();
		}
		public function get nativeWindowLeftMargin():Number {
			return (phnw.width-ph.stage.stageWidth)/2;
		}
		public function get nativeWindowTopMargin():Number {
			return phnw.height-ph.stage.stageHeight-nativeWindowLeftMargin;
		}
		public function get placeholderAbsoluteLeft():Number {
			var pt:Point=getPlaceholderGlobalPoint();
			return phnw.x+pt.x+nativeWindowLeftMargin;
		}
		public function get placeholderAbsoluteTop():Number {
			var pt:Point=getPlaceholderGlobalPoint();
			return phnw.y+pt.y+nativeWindowTopMargin;
		}
		protected function getPlaceholderGlobalPoint():Point {
			return ph.localToGlobal(new Point(0, 0));
		}
		public function updateOverlay(e:Event=null):void {
			lastPlacingEvent=e;
			needsPlacing=true;
		}
		public function updateOverlayIfNeeded(e:Event=null):void {
			if (!needsPlacing) return;
			refreshOverlayPosition();
			refreshOverlaySize();
			if (lastPlacingEvent && lastPlacingEvent.type==Event.ACTIVATE && !pw.visible) showOverlay();
			needsPlacing=false;
		}
		public function refreshOverlayPosition():void {
			pw.x=placeholderAbsoluteLeft;
			pw.y=placeholderAbsoluteTop;
		}
		public function refreshOverlaySize():void {
			pw.width=ph.width;
			pw.height=ph.height;
		}
		//
		public function hideOverlay(e:Event=null):void {
			needsHiding=true;
			setTimeout(hideOverlayIfNeeded, 10);
		}
		public function hideOverlayIfNeeded():void {
			if (needsHiding) try {if (pw.visible) pw.visible=false;} catch (er:Error) {}
		}
		public function showOverlay(e:Event=null):void {
			needsHiding=false;
			try {if (!pw.visible) pw.visible=true;} catch (er:Error) {}
		}
		//
		public function get htmlLoader():HTMLLoader {
			return p;
		}
		public function get nativeWindow():NativeWindow {
			return pw;
		}
		public function get timer():Timer {
			return t;
		}
	}
}