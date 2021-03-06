package bhvr.controller
{
   import Holotapes.Common.views.PauseButton;
   import Shared.AS3.COMPANIONAPP.CompanionAppMode;
   import Shared.BGSExternalInterface;
   import bhvr.constatnts.GameConfig;
   import bhvr.constatnts.GameInputs;
   import bhvr.data.CursorType;
   import bhvr.data.SoundList;
   import bhvr.debug.Log;
   import bhvr.events.EventWithParams;
   import bhvr.manager.InputManager;
   import bhvr.manager.SoundManager;
   import bhvr.states.ConfirmQuitState;
   import bhvr.states.GameState;
   import bhvr.states.PauseState;
   import bhvr.views.CustomCursor;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import scaleform.clik.controls.UILoader;
   import scaleform.clik.core.CLIK;
   import scaleform.gfx.Extensions;
   
   public class GameController
   {
       
      
      public var BGSCodeObj:Object;
      
      private var _platformInfo:Object;
      
      private var _stage:Stage;
      
      private var _visualContent:MovieClip;
      
      private var _assets:MovieClip;
      
      private var _assetLoader:UILoader;
      
      private var _pauseButton:PauseButton;
      
      private var _inputMgr:InputManager;
      
      private var _cursor:CustomCursor;
      
      private var _stateController:StateController;
      
      private var _isPaused:Boolean = false;
      
      private var _isConfirmingQuit:Boolean = false;
      
      private var _isTutorialShown:Boolean = false;
      
      public function GameController(mainStage:Stage)
      {
         super();
         this._platformInfo = new Object();
         this._stage = mainStage;
         Extensions.enabled = true;
         Extensions.noInvisibleAdvance = true;
         CLIK.disableNullFocusMoves = true;
         CLIK.disableDynamicTextFieldFocus = true;
         if(CompanionAppMode.isOn)
         {
            this.loadGameAssets();
         }
         else
         {
            this._stage.addEventListener(Event.ENTER_FRAME,this.onDelayedAssetLoading);
         }
      }
      
      public function get inputMgr() : InputManager
      {
         return this._inputMgr;
      }
      
      public function get stateController() : StateController
      {
         return this._stateController;
      }
      
      private function initialize() : void
      {
         if(GameConfig.USING_CURSOR && !CompanionAppMode.isOn)
         {
            this._cursor = new CustomCursor(this._stage,this._assets,CursorType.CURSOR_BRACKETS);
            this._assets.cursorContainerMc.addChild(this._cursor);
         }
         this._inputMgr = new InputManager(this._stage);
         this._inputMgr.addEventListener(GameInputs.PAUSE,this.onPause,false,0,true);
         if(this._platformInfo.platform != null)
         {
            this._inputMgr.SetPlatform(this._platformInfo.platform,this._platformInfo.psnButtonSwap);
         }
         if(CompanionAppMode.isOn)
         {
            this._pauseButton = new PauseButton(this._assets.pauseBtnMc);
            this._pauseButton.addEventListener(PauseButton.CLICKED,this.onPauseBtnClicked,false,0,true);
         }
         else
         {
            this._assets.pauseBtnMc.visible = false;
         }
         this._stateController = new StateController(this._assets,this._cursor);
         this._stateController.addEventListener(PauseState.READY_TO_RESUME,this.onResume,false,0,true);
         this._stateController.addEventListener(ConfirmQuitState.CANCEL,this.onQuitCancelled,false,0,true);
         this._stateController.addEventListener(ConfirmQuitState.QUIT,this.onQuitConfirmed,false,0,true);
         this._stateController.addEventListener(GameState.TUTORIAL_REQUESTED,this.onTutorialRequested,false,0,true);
         this._stateController.BGSCodeObj = this.BGSCodeObj;
         this._stateController.initialize();
         SoundManager.instance.BGSCodeObj = this.BGSCodeObj;
         SoundManager.instance.registerSound(SoundList.BOMBER_LOOP_SOUND);
         SoundManager.instance.registerSound(SoundList.TITLE_SCREEN_SOUND);
         SoundManager.instance.registerSound(SoundList.ROUND_START_SOUND);
         SoundManager.instance.registerSound(SoundList.EXTRA_LANDMARK_BONUS_SOUND);
         SoundManager.instance.registerSound(SoundList.GAME_OVER_SOUND);
         SoundManager.instance.registerSound(!!CompanionAppMode.isOn ? SoundList.LANDMARK_DESTRUCTION_SOUND_MOBILE_1 : SoundList.LANDMARK_DESTRUCTION_SOUND_1);
         SoundManager.instance.registerSound(!!CompanionAppMode.isOn ? SoundList.LANDMARK_DESTRUCTION_SOUND_MOBILE_2 : SoundList.LANDMARK_DESTRUCTION_SOUND_2);
         SoundManager.instance.registerSound(!!CompanionAppMode.isOn ? SoundList.LANDMARK_DESTRUCTION_SOUND_MOBILE_3 : SoundList.LANDMARK_DESTRUCTION_SOUND_3);
         SoundManager.instance.registerSound(!!CompanionAppMode.isOn ? SoundList.LANDMARK_DESTRUCTION_SOUND_MOBILE_4 : SoundList.LANDMARK_DESTRUCTION_SOUND_4);
         SoundManager.instance.registerSound(!!CompanionAppMode.isOn ? SoundList.LANDMARK_DESTRUCTION_SOUND_MOBILE_5 : SoundList.LANDMARK_DESTRUCTION_SOUND_5);
         SoundManager.instance.registerSound(!!CompanionAppMode.isOn ? SoundList.LANDMARK_DESTRUCTION_SOUND_MOBILE_6 : SoundList.LANDMARK_DESTRUCTION_SOUND_6);
         SoundManager.instance.registerSound(!!CompanionAppMode.isOn ? SoundList.LANDMARK_DESTRUCTION_SOUND_MOBILE_7 : SoundList.LANDMARK_DESTRUCTION_SOUND_7);
         SoundManager.instance.registerSound(!!CompanionAppMode.isOn ? SoundList.LANDMARK_DESTRUCTION_SOUND_MOBILE_8 : SoundList.LANDMARK_DESTRUCTION_SOUND_8);
         SoundManager.instance.registerSound(SoundList.CANON_DESTRUCTION_SOUND);
      }
      
      private function onDelayedAssetLoading(e:Event) : void
      {
         this._stage.removeEventListener(Event.ENTER_FRAME,this.onDelayedAssetLoading);
         this.loadGameAssets();
      }
      
      private function loadGameAssets() : void
      {
         this._assetLoader = new UILoader();
         this._assetLoader.addEventListener(Event.COMPLETE,this.onAssetsLoaded,false,0,true);
         this._assetLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadingError,false,0,true);
         this._assetLoader.source = GameConfig.GAME_ASSETS_PATH;
      }
      
      private function onAssetsLoaded(e:Event) : void
      {
         this._visualContent = this._assetLoader.content as MovieClip;
         this._assets = this._visualContent.getChildByName("mainMc") as MovieClip;
         this._stage.addChild(this._visualContent);
         this.initialize();
      }
      
      private function onLoadingError(e:IOErrorEvent) : void
      {
         Log.error("Can\'t load Game assets because " + this._assetLoader.source + " doesn\'t exist!");
      }
      
      private function onPauseBtnClicked(e:Event) : void
      {
         this.ConfirmQuit();
      }
      
      private function onPause(e:EventWithParams) : void
      {
         this.Pause(!this._isPaused);
      }
      
      private function onResume(e:EventWithParams) : void
      {
         this._inputMgr.Pause(false);
         SoundManager.instance.Pause(false);
      }
      
      private function onQuitCancelled(e:EventWithParams) : void
      {
         this._isConfirmingQuit = false;
      }
      
      private function onQuitConfirmed(e:EventWithParams) : void
      {
         BGSExternalInterface.call(this.BGSCodeObj,"closeHolotape");
      }
      
      private function onTutorialRequested(e:EventWithParams) : void
      {
         BGSExternalInterface.call(null,"showTutorialOverlay",e.params.id);
      }
      
      public function dispose() : void
      {
         this._platformInfo = null;
         this._visualContent = null;
         this._assetLoader = null;
         this._stateController.dispose();
         this._stateController = null;
         if(GameConfig.USING_CURSOR)
         {
            this._assets.cursorContainerMc.removeChild(this._cursor);
            this._cursor.dispose();
            this._cursor = null;
         }
         this._inputMgr.dispose();
         this._inputMgr = null;
         SoundManager.instance.dispose();
         this.BGSCodeObj = null;
      }
      
      public function SetPlatform(auiPlatform:uint, abPSNButtonSwap:Boolean) : void
      {
         this._platformInfo.platform = auiPlatform;
         this._platformInfo.psnButtonSwap = abPSNButtonSwap;
         if(this._inputMgr)
         {
            this._inputMgr.SetPlatform(auiPlatform,abPSNButtonSwap);
         }
      }
      
      public function Pause(paused:Boolean) : void
      {
         if(!this._isTutorialShown && !this._isConfirmingQuit && this._isPaused != paused)
         {
            this._stateController.Pause(paused);
            if(paused)
            {
               this._inputMgr.Pause(paused);
               SoundManager.instance.Pause(paused);
            }
            this._isPaused = paused;
         }
      }
      
      public function ConfirmQuit() : void
      {
         if(!this._isTutorialShown && !this._isConfirmingQuit)
         {
            this._stateController.ConfirmQuit();
            this._inputMgr.Pause(true);
            SoundManager.instance.Pause(true);
            this._isConfirmingQuit = true;
         }
      }
   }
}
