#include <NCIncs/nc_rpg> // for config loader :) for simple use
#include <csgo_colors>
#define PREFIX "{GREEN}[Bonus]{DEFAULT}"

public  Plugin myinfo = {
    name = "NNBonus",
    author = ".KarmA",
    description = "Give bonus for nickname",
    version = "r0.9",
    url = "https://steamcommunity.com/id/i_t_s_Karma/"
}

Handle hTimerNotice;
float fIntervalNotice;
char cPrefix[64];
int iGiveCredits, iBonusInterval;
#include <NNBonus/NNB_DB>

public void OnPluginStart(){
    LoadSettings();
    Database.Connect(DBCallback, "default");
    RegConsoleCmd("sm_bonus", fClbBonus, "use a bonus");
    hTimerNotice = CreateTimer(fIntervalNotice, fTimerNotice, _, TIMER_REPEAT);
}
public bool correctPlayer(int client){
    if(client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client))
        return true;
    return false;
}
public Action fClbBonus(int client, int args){
    if(!correctPlayer(client)) return;
    GiveBonus(client);
}
stock void GiveBonus(int client){
    char sClientAuth[64], szQuery[256];
    if(!CheckPlayerPrefix(client)){
        CGOPrintToChat(client, "%s %t", PREFIX, "BONUS_NO_PREFIX", cPrefix);
        CGOPrintToChat(client, "%s %t", PREFIX, "BONUS_NOTICE_MESSAGE", cPrefix, iGiveCredits);
        return;
    }
    if(!bDBInitialized){
        SetFailState("DB Is not initialized!");
        return;
    }
    GetClientAuthId(client, AuthId_Steam2, sClientAuth, sizeof(sClientAuth));
    FormatEx(szQuery, sizeof(szQuery), "SELECT `lastuse` FROM `nn_bonus` WHERE `steamid` = '%s';", sClientAuth);

    hDatabase.Query(PlayerGiveBonusSQL, szQuery, client);    
}
public bool CheckPlayerPrefix(client){
    char szPlayerName[32];
    if(!GetClientName(client, szPlayerName, sizeof(szPlayerName))) return false;
    if(StrContains(szPlayerName, cPrefix) > -1) return true;
    return false;
}


stock void LoadSettings(){
    NCRPG_Configs rConfig = NCRPG_Configs(CONFIG_CORE);
    fIntervalNotice = rConfig.GetFloat("NNBonus", "NoticeInterval", 20.0);
    rConfig.GetString("NNBonus", "Prefix", cPrefix, sizeof(cPrefix), "[TEST]");
    iGiveCredits = rConfig.GetInt("NNBonus", "Credit", 100);
    iBonusInterval = rConfig.GetInt("NNBonus", "BonusInterval", 86400); 
    LoadTranslations("NNBonus.phrases");    

    rConfig.SaveConfigFile(CONFIG_CORE);
}
public Action fTimerNotice(Handle timer, Handle hndl){
    CGOPrintToChatAll("%s %t", PREFIX, "BONUS_NOTICE_MESSAGE", cPrefix, iGiveCredits);
}