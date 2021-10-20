package bhvr.constatnts
{
   import bhvr.controller.StateController;
   
   public class GameConfig
   {
      
      //The name of the game displayed in the UI (at least I think so)
      public static const GAME_NAME:String = "Pong";
      
      //Not sure where this is stored yet
      public static const GAME_HIGH_SCORE_KEY:String = "HSPong";
      
      //Whether the game should utilize the player's cursor or not
      public static const USING_CURSOR:Boolean = false;
    /*
      //The asset swf with all the content in it. Need to research how this is referenced
      public static const GAME_ASSETS_PATH:String = "AtomicCommandAssets.swf";
      
      public static const GAME_XML_PATH:String = "xml/AtomicCommandConfig.xml";
      
      public static const STARTING_STATE:int = StateController.TITLE;
    */
      
      public function GameConfig()
      {
         super();
      }
   }
}
