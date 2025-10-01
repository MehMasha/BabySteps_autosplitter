state("BabySteps")
{
    float x : "GameAssembly.dll", 0x3ED3CE8, 0xB8, 0x28;
    float y : "GameAssembly.dll", 0x3ED3CE8, 0xB8, 0x2c;
    float z : "GameAssembly.dll", 0x3ED3CE8, 0xB8, 0x30;
    bool isStartCutScenePlaying : "GameAssembly.dll", 0x3EB5890, 0xB8, 0x0, 0x390;
    bool isCutScenePlaying : "GameAssembly.dll", 0x3EB5890, 0xB8, 0x0, 0x30D;
    float timePlayedCurSave : "GameAssembly.dll", 0x3E6B448, 0xB8, 0x0, 0x40;
}

startup
{
    print("Startup");
}

start
{
    current.CupBasketSplit = false;
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
    bool inCupBasketArea = current.x > 246 && current.x < 260 &&
                          current.z > 363 && current.z < 375 &&
                          current.y > 200 && current.y < 204;
    if (!current.CupBasketSplit && inCupBasketArea && current.isCutScenePlaying) {
        current.CupBasketSplit = true;
        return true;
    }   
}
