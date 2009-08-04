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
	public class HTMLOverlay2 extends EventDispatcher {
		protected var ph:Sprite;
		protected var phnw:NativeWindow;
		protected var sbv:Boolean;
		//
		protected var p:HTMLLoader;
		protected var pw:NativeWindow;
		//
		protected var lastPlacingEvent:Event;
		protected var needsPlacing:Boolean=true;
		protected var needsHiding:Boolean=false;
		protected var explicitWidth:Number;
		protected var explicitHeight:Number;
		//
		public function HTMLOverlay2(placeHolder:Sprite, scrollBarsVisible:Boolean=true, explicitWidth:Number=0, explicitHeight:Number=0) {
			ph=placeHolder;
			sbv=scrollBarsVisible;
			this.explicitWidth = explicitWidth;
			this.explicitHeight = explicitHeight;
			//
			if (ph.stage) setupListeners();
			else ph.addEventListener(Event.ADDED_TO_STAGE, setupListeners);
		}
		protected function setupListeners(e:Event=null):void {
			if (e) ph.removeEventListener(Event.ADDED_TO_STAGE, setupListeners);
			//
			phnw=ph.stage.nativeWindow;
			//
			var nwio:NativeWindowInitOptions=new NativeWindowInitOptions();
			nwio.minimizable = true;
			nwio.systemChrome=NativeWindowSystemChrome.NONE;
			nwio.type=NativeWindowType.LIGHTWEIGHT;
			p=HTMLLoader.createRootWindow(true, nwio, sbv, new Rectangle(placeholderAbsoluteLeft, placeholderAbsoluteTop, width, height));
			if( explicitHeight != 0 ) { p.height; }
			if( explicitWidth != 0 ) { p.width; }
			pw=p.stage.nativeWindow;
			subscribeCloseSyncEvents(pw, phnw);
			syncWith(ph);
			//
			dispatchEvent(new Event(Event.COMPLETE));
		}
		private function subscribeCloseSyncEvents(pw:NativeWindow, phnw:NativeWindow):void
		{
			phnw.addEventListener(Event.CLOSING, beforeClose);
			pw.addEventListener(Event.CLOSING, beforeClose);
		}
		private function subscribeVisualSyncEvents(pw:NativeWindow, phnw:NativeWindow, ph:Sprite):void
		{
			phnw.addEventListener(NativeWindowBoundsEvent.MOVE, updatePositionAndSizeAfterParentIsPositioned);
			phnw.addEventListener(NativeWindowBoundsEvent.RESIZE, updatePositionAndSizeAfterParentIsPositioned);
			ph.addEventListener(ResizeEvent.RESIZE, updatePositionAndSize);
			ph.addEventListener(Event.REMOVED, removeVisualSyncEventsAndHide);
			phnw.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, onDSChange);
			pw.addEventListener(Event.DEACTIVATE, keepWindowOnTop );
			phnw.addEventListener(Event.DEACTIVATE, keepWindowOnTop );
			pw.addEventListener(Event.ACTIVATE, keepWindowOnTop );
			phnw.addEventListener(Event.ACTIVATE, keepWindowOnTop );
		}
		private function removeVisualSyncEventsAndHide(e:Event=null, hideWithDelay:Boolean=true) : void
		{
			phnw.removeEventListener(NativeWindowBoundsEvent.MOVE, updatePositionAndSizeAfterParentIsPositioned);
			phnw.removeEventListener(NativeWindowBoundsEvent.RESIZE, updatePositionAndSizeAfterParentIsPositioned);
			ph.removeEventListener(ResizeEvent.RESIZE, updatePositionAndSize);
			ph.removeEventListener(Event.REMOVED, removeVisualSyncEventsAndHide);
			phnw.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, onDSChange);
			pw.removeEventListener(Event.DEACTIVATE, keepWindowOnTop );
			phnw.removeEventListener(Event.DEACTIVATE, keepWindowOnTop );
			pw.removeEventListener(Event.ACTIVATE, keepWindowOnTop );
			phnw.removeEventListener(Event.ACTIVATE, keepWindowOnTop );
			var hide:Function = function():void{ pw.visible = false; };
			if( hideWithDelay == true ) {
				setTimeout( hide, 10 );
			} else {
				hide();
			}
		}
		protected function keepWindowOnTop(e:Event):void {
			var applicationIsActive:Boolean = pw.active || phnw.active;
			pw.alwaysInFront = applicationIsActive;
			if( !applicationIsActive ){
				pw.orderInFrontOf(phnw);
			}			
		}
		protected function beforeClose(e:Event):void {
			removeVisualSyncEventsAndHide(e, false);
			e.preventDefault();
			pw.close();
			phnw.close();
		}
		protected function onDSChange(e:NativeWindowDisplayStateEvent):void {
			if (e.afterDisplayState==NativeWindowDisplayState.MINIMIZED) pw.visible=false;
			else pw.visible = true;
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
		public function get width() : Number {
			if (explicitWidth != 0) { 
				return explicitWidth;
			} else { 
				return ph.width; 
			}
		}
		public function get height() : Number {
			if (explicitHeight != 0) {
				return explicitHeight; 
			} else {
				return ph.height; 
			}
		}
		protected function getPlaceholderGlobalPoint():Point {
			return ph.localToGlobal(new Point(0, 0));
		}
		private function updatePositionAndSizeAfterParentIsPositioned(e:Event=null):void
		{
			setTimeout(function():void{ updatePositionAndSize(e) }, 10);
		}
		public function updatePositionAndSize(e:Event=null):void {
			refreshOverlayPosition();
			refreshOverlaySize();
		}
		public function refreshOverlayPosition():void {
			pw.x=placeholderAbsoluteLeft;
			pw.y=placeholderAbsoluteTop;
		}
		public function refreshOverlaySize():void {
			pw.width=width;
			pw.height=height;
		}
		public function syncWith(ph:Sprite):void{
			this.ph = ph;
			subscribeVisualSyncEvents(pw,phnw, ph);
			//
			pw.activate();
			updatePositionAndSizeAfterParentIsPositioned();
		}
		public function stopSync():void{
			removeVisualSyncEventsAndHide();
		}
		//
		public function get htmlLoader():HTMLLoader {
			return p;
		}
		public function get nativeWindow():NativeWindow {
			return pw;
		}
	}
}