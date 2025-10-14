state("BabySteps") {}

startup
{
    vars.Log = (Action<object>)(output => print("[BabySteps] " + output));
    // asl-help by just-ero https://github.com/just-ero/asl-help
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    // uhara by ru-mii https://github.com/ru-mii/uhara
    Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
    vars.Helper.GameName = "BabySteps";
    vars.Uhara.EnableDebug();


    // by Nepo from Outer Wilds Autosplitter
    vars.createSetting = (Action<string, string, string, bool>)((name, description, tooltip, enabled) => {
        try {
            settings.Add(name, enabled, description);
            settings.SetToolTip(name, tooltip);
        } catch (Exception e) {
            if (e.Message.StartsWith("Parent")) {/////We can remove one of the ifs and so on
                print(e.Message);
            } else if (e.Message.StartsWith("Setting")) {//Setting 'XXXX' was already added 
                //print(e.Message);
            } else {
                print("Setting " + name + " already exists\nMessage = " + e.Message);
            }
        }
    });

    settings.CurrentDefaultParent = null;
    vars.createSetting("GeneralSplits", "Splits", "Choose where you want the game to split", true);
    settings.CurrentDefaultParent = "GeneralSplits";
        vars.createSetting("PoisonSwampCampfire", "Swamp Split, Campfire after Poison Swamp", "", false);
        vars.createSetting("DonkeyFarmCampfire", "Donkey Farm Split, Campfire after Donkey Farm", "First time you see Ethan", false);
        vars.createSetting("PoisonForestCampfire", "Forest Split, Campfire after Forest", "After small brick wall", false);
        vars.createSetting("PoisonSlopesCampfire", "Slopes Split, Beach Campfire after slopes", "", false);
        vars.createSetting("PoisonDesertCampfire", "Desert Split, Campfire inside fortress", "", false);
        vars.createSetting("PoisonCastleCampfire", "Fortress Split, Campfire after apartment tour in fortress", "", false);
        vars.createSetting("PoisonHillsCampfire", "Hills Split, Marshmallow in mines Campfire", "", false);
        vars.createSetting("ManbreakerStart", "Mines without Manbreaker Split, Start of Manbreaker Cutscene", "", false);
        vars.createSetting("PoisonMinesCampfire", "Mines Split, Campfire after Manbreaker", "", false);
        vars.createSetting("MooseHut", "Moose Hut Split", "", true);
        vars.createSetting("EndCredits", "Started credits Split", "", false);


    vars.inCutsceneCheck = (Func<Dictionary<string, float>, Dictionary<string, float>, bool>)((camp, player) => {
        float mod_x = ((player["X"] % 512) + 512) % 512;
        return Math.Abs(mod_x % 512) > camp["X"] - 50 && Math.Abs(mod_x % 512) < camp["X"] + 20 &&
                        player["Y"] > camp["Y"] - 20 && player["Y"] < camp["Y"] + 50 &&
                        player["Z"] > camp["Z"] - 20 && player["Z"] < camp["Z"] + 20;
        return true;
    });


    vars.splits = new Dictionary<string, bool>
    {
        { "PoisonSwampCampfire", false },
        { "DonkeyFarmCampfire", false },
        { "PoisonForestCampfire", false },
        { "PoisonSlopesCampfire", false },
        { "PoisonDesertCampfire", false },
        { "PoisonCastleCampfire", false },
        { "PoisonHillsCampfire", false },
        { "ManbreakerStart", false },
        { "PoisonMinesCampfire", false },
        { "MooseHut", false },
        { "EndCredits", false }
    };
}

init
{
    var Instance = vars.Uhara.CreateTool("Unity", "IL2CPP", "Instance");


    var Pos = Instance.Get("CoreGameLogic::PlayerMovement", "pos");
    vars.Helper["X"] = vars.Helper.Make<float>(Pos.Base, 0x28);
    vars.Helper["Y"] = vars.Helper.Make<float>(Pos.Base, 0x2c);
    vars.Helper["Z"] = vars.Helper.Make<float>(Pos.Base, 0x30);


    var CampfireDatas = Instance.Get("CoreGameLogic::Menu", "campfireDatas");
    vars.numberOfCampfires = 10;
    const int ELEMENT_SIZE = 0x08;
    const int BASE_ARRAY_OFFSET = 0x20;
    const int X_OFFSET = 0x10;
    const int Y_OFFSET = 0x14;
    const int Z_OFFSET = 0x18;

    for (int i = 0; i < vars.numberOfCampfires; i++) {
        int currentElementOffset = BASE_ARRAY_OFFSET + (i * ELEMENT_SIZE);
        vars.Helper[string.Format("camp{0}_x", i)] = vars.Helper.Make<float>(CampfireDatas.Base, 0x20, currentElementOffset, X_OFFSET);
        vars.Helper[string.Format("camp{0}_y", i)] = vars.Helper.Make<float>(CampfireDatas.Base, 0x20, currentElementOffset, Y_OFFSET);
        vars.Helper[string.Format("camp{0}_z", i)] = vars.Helper.Make<float>(CampfireDatas.Base, 0x20, currentElementOffset, Z_OFFSET);
    }



    var StartCutscenePlaying = Instance.Get("CoreGameLogic::Menu", "playingIntro");
    vars.Helper["StartCutscenePlaying"] = vars.Helper.Make<bool>(StartCutscenePlaying.Base, StartCutscenePlaying.Offsets);


    var CutscenePlaying = Instance.Get("CoreGameLogic::Menu", "inCutscene");
    vars.Helper["CutscenePlaying"] = vars.Helper.Make<bool>(CutscenePlaying.Base, CutscenePlaying.Offsets);


    var NonInteractiveCutscenePlaying = Instance.Get("CoreGameLogic::Menu", "inNonInteractiveCutscene");
    vars.Helper["NonInteractiveCutscenePlaying"] = vars.Helper.Make<bool>(NonInteractiveCutscenePlaying.Base, NonInteractiveCutscenePlaying.Offsets);


    var Paused = Instance.Get("CoreGameLogic::Menu", "paused");
    vars.Helper["Paused"] = vars.Helper.Make<bool>(Paused.Base, Paused.Offsets);


    var TimePlayedCurSave = Instance.Get("CoreGameLogic::SaveGod", "theSave", "timePlayed");
    vars.Helper["TimePlayedCurSave"] = vars.Helper.Make<float>(TimePlayedCurSave.Base, TimePlayedCurSave.Offsets);


    var EndCreditsPlaying = Instance.Get("CoreGameLogic::EndCredits", "started");
    vars.Helper["EndCreditsPlaying"] = vars.Helper.Make<bool>(EndCreditsPlaying.Base, EndCreditsPlaying.Offsets);

    vars.Campfires = new Dictionary<string, Dictionary<string, float>> {};
    
    vars.Cutscenes = new Dictionary<string, Dictionary<string, float>> {};
    Dictionary<string, float> ManbreakerStart = new Dictionary<string, float>();
    ManbreakerStart.Add("X", 324);
    ManbreakerStart.Add("Y", 687);
    ManbreakerStart.Add("Z", 1934);
    vars.Cutscenes.Add("ManbreakerStart", ManbreakerStart);

}

start
{

    if(vars.Campfires.Count == 0){
        var currentAsDictionary = (IDictionary<string, object>)current;

        for (int i = 0; i < vars.numberOfCampfires; i++) {

            Dictionary<string, float> Campfire = new Dictionary<string, float>();
            Campfire.Add("X", (float)currentAsDictionary[string.Format("camp{0}_x", i)]);
            Campfire.Add("Y", (float)currentAsDictionary[string.Format("camp{0}_y", i)]);
            Campfire.Add("Z", (float)currentAsDictionary[string.Format("camp{0}_z", i)]);
            vars.Campfires.Add(string.Format("Camp{0}", i), Campfire);
            
        }    
    }

    current.inEndSplit = false;
    if (current.StartCutscenePlaying && !old.StartCutscenePlaying)
    {
        print("Start");
        return true;
    }
}


isLoading
{
    if (current.Paused && !current.StartCutscenePlaying) {
        return true;
    }
    return false;
}


update
{
    vars.Helper.Update();
    vars.Helper.MapPointers();


    if(timer.CurrentPhase == TimerPhase.Ended && old.TimePlayedCurSave > 0.1 && current.TimePlayedCurSave == 0f) {
        vars.tm = new TimerModel { CurrentState = timer };
        vars.tm.Reset();
    }	

    return true;
}

reset {
    if (old.TimePlayedCurSave > 1 && current.TimePlayedCurSave == 0f)
        {
            return true;
        }
}

onReset {
    vars.splits["PoisonSwampCampfire"] = false;
    vars.splits["DonkeyFarmCampfire"] = false;
    vars.splits["PoisonForestCampfire"] = false;
    vars.splits["PoisonSlopesCampfire"] = false;
    vars.splits["PoisonDesertCampfire"] = false;
    vars.splits["PoisonCastleCampfire"] = false;
    vars.splits["PoisonHillsCampfire"] = false;
    vars.splits["ManbreakerStart"] = false;
    vars.splits["PoisonMinesCampfire"] = false;
    vars.splits["MooseHut"] = false;
    vars.splits["EndCredits"] = false;
}



split
{


    Dictionary<string, float> player = new Dictionary<string, float>();
    player.Add("X", (float)current.X);
    player.Add("Y", (float)current.Y);
    player.Add("Z", (float)current.Z);


    if (settings["PoisonSwampCampfire"] && !vars.splits["PoisonSwampCampfire"] &&
    current.CutscenePlaying && current.NonInteractiveCutscenePlaying && current.TimePlayedCurSave > 0f &&
    vars.inCutsceneCheck(vars.Campfires["Camp1"], player)) {
        vars.splits["PoisonSwampCampfire"] = true;
        return true;
    }
    else if (settings["DonkeyFarmCampfire"] && !vars.splits["DonkeyFarmCampfire"] &&
    current.CutscenePlaying && current.NonInteractiveCutscenePlaying && current.TimePlayedCurSave > 0f &&
    vars.inCutsceneCheck(vars.Campfires["Camp2"], player)) {
        vars.splits["DonkeyFarmCampfire"] = true;
        return true;
    }
    else if (settings["PoisonForestCampfire"] && !vars.splits["PoisonForestCampfire"] &&
    current.CutscenePlaying && current.NonInteractiveCutscenePlaying && current.TimePlayedCurSave > 0f &&
    vars.inCutsceneCheck(vars.Campfires["Camp3"], player)) {
        vars.splits["PoisonForestCampfire"] = true;
        return true;
    }
    else if (settings["PoisonSlopesCampfire"] && !vars.splits["PoisonSlopesCampfire"] &&
    current.CutscenePlaying && current.NonInteractiveCutscenePlaying && current.TimePlayedCurSave > 0f &&
    vars.inCutsceneCheck(vars.Campfires["Camp4"], player)) {
        vars.splits["PoisonSlopesCampfire"] = true;
        return true;
    }
    else if (settings["PoisonDesertCampfire"] && !vars.splits["PoisonDesertCampfire"] &&
    current.CutscenePlaying && current.NonInteractiveCutscenePlaying && current.TimePlayedCurSave > 0f &&
    vars.inCutsceneCheck(vars.Campfires["Camp5"], player)) {
        vars.splits["PoisonDesertCampfire"] = true;
        return true;
    }
    else if (settings["PoisonCastleCampfire"] && !vars.splits["PoisonCastleCampfire"] &&
    current.CutscenePlaying && current.NonInteractiveCutscenePlaying && current.TimePlayedCurSave > 0f &&
    vars.inCutsceneCheck(vars.Campfires["Camp6"], player)) {
        vars.splits["PoisonCastleCampfire"] = true;
        return true;
    }
    else if (settings["PoisonHillsCampfire"] && !vars.splits["PoisonHillsCampfire"] &&
    current.CutscenePlaying && current.NonInteractiveCutscenePlaying && current.TimePlayedCurSave > 0f &&
    vars.inCutsceneCheck(vars.Campfires["Camp7"], player)) {
        vars.splits["PoisonHillsCampfire"] = true;
        return true;
    }
    else if (settings["ManbreakerStart"] && !vars.splits["ManbreakerStart"] &&
    current.CutscenePlaying && current.NonInteractiveCutscenePlaying && current.TimePlayedCurSave > 0f &&
    vars.inCutsceneCheck(vars.Cutscenes["ManbreakerStart"], player)) {
        vars.splits["ManbreakerStart"] = true;
        return true;
    }
    else if (settings["PoisonMinesCampfire"] && !vars.splits["PoisonMinesCampfire"] &&
    current.CutscenePlaying && current.NonInteractiveCutscenePlaying && current.TimePlayedCurSave > 0f &&
    vars.inCutsceneCheck(vars.Campfires["Camp8"], player)) {
        vars.splits["PoisonMinesCampfire"] = true;
        return true;
    }
    else if (settings["MooseHut"] && !vars.splits["MooseHut"] &&
    current.CutscenePlaying && current.NonInteractiveCutscenePlaying && current.TimePlayedCurSave > 0f &&
    vars.inCutsceneCheck(vars.Campfires["Camp9"], player)) {
        vars.splits["MooseHut"] = true;
        return true;
    }
    else if (settings["EndCredits"] && !vars.splits["EndCredits"] &&
    current.EndCreditsPlaying && current.TimePlayedCurSave > 0f) {
        vars.splits["EndCredits"] = true;
        return true;
    }

}