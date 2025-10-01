state("BabySteps")
{
	float x : "GameAssembly.dll", 0x4E38470, 0xB8, 0x28;
	float y : "GameAssembly.dll", 0x4E38470, 0xB8, 0x2c;
    float z : "GameAssembly.dll", 0x4E38470, 0xB8, 0x30;
    bool isStartCutScenePlaying : "GameAssembly.dll", 0x4E38530, 0xB8, 0x0, 0x3F8;
    bool isCutScenePlaying : "GameAssembly.dll", 0x4E38530, 0xB8, 0x0, 0x315;
    float timePlayedCurSave : "GameAssembly.dll", 0x4E38378, 0xB8, 0x0, 0x40;
}

startup
{
    print("Startup");
}
 
start
{
    current.inEndSplit = false;
    if (current.isStartCutScenePlaying && !old.isStartCutScenePlaying)
    {
        print("Start");
        return true;
    }
}

reset {
    if (old.timePlayedCurSave > 1 && current.timePlayedCurSave == 0f)
        {
            return true;
        }
}
 
split
{
    bool inEndArea = current.x > 200 && current.x < 300 &&
                          current.z > 2800 && current.z < 2900 &&
                          current.y > 900 && current.y < 1000;
    if (!current.inEndSplit && inEndArea && current.isCutScenePlaying && current.timePlayedCurSave > 0f) {
        current.inEndSplit = true;
        return true;
    } 
}
