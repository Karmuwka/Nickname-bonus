Database hDatabase;
bool bDBInitialized = false;

stock int Abs(int x){
    if(x < 0) return -x;
    return x;
}

public void PlayerGiveBonusSQL(Database hDatabase, DBResultSet results, const char[] sError, any client){
    if(!correctPlayer(client)) return;
    char sClientAuth[64], szQuery[256], sClientName[32];
    GetClientName(client, sClientName, sizeof(sClientName));
    GetClientAuthId(client, AuthId_Steam2, sClientAuth, sizeof(sClientAuth));

    if(results.FetchRow()){
        int lasttime = results.FetchInt(0);
        int left = GetTime() - lasttime;

        if(left < iBonusInterval){
            CGOPrintToChat(client, "%s %t", PREFIX, "BONUS_COOLDOWN", Abs((left - iBonusInterval) / 3600)); 
            return;
        }

        FormatEx(szQuery, sizeof(szQuery), "UPDATE `nn_bonus` SET `lastuse` = '%i' WHERE `steamid` = '%s'", GetTime(), sClientAuth);
        hDatabase.Query(UpdateLasttimeSQL, szQuery, client);
        
    }else{
        int lastuse = GetTime();
        FormatEx(szQuery, sizeof(szQuery), "INSERT INTO `nn_bonus` (steamid, name, lastuse) VALUES ('%s', '%s', '%i')", sClientAuth, sClientName, lastuse);
        hDatabase.Query(UpdateLasttimeSQL, szQuery, client);
    }
}
public void UpdateLasttimeSQL(Database hDB, DBResultSet hRes, const char[] sError, any client){
    char sClientName[32];
    GetClientName(client, sClientName, sizeof(sClientName));
    if(sError[0]){
        LogMessage("Fail to update last time for player: %s", sError);
        return;
    }
    NCRPG_GiveCredits(client, iGiveCredits);
    CGOPrintToChat(client, "%s %t", PREFIX, "BONUS_GIVE_SUCCESS"); 
    CGOPrintToChatAll("%s %t", PREFIX, "BONUS_GIVEN", sClientName, iGiveCredits);        
}
public void DBCallback(Database hDB, const char[] szError, any data){
    if(hDB == null || szError[0]){
        SetFailState("Database fail: %s", szError);
        return;
    }
    hDatabase = hDB;
    CreateTables();
}
public void CreateTables(){
    hDatabase.SetCharset("utf8");
    hDatabase.Query(DB_CreateTables_CB, "CREATE TABLE IF NOT EXISTS `nn_bonus`(`steamid` VARCHAR(32) NOT NULL,`name`    VARCHAR(32) NOT NULL,`lastuse` INT(32) NOT NULL);");
}
public void DB_CreateTables_CB(Database hDB, DBResultSet results, const char[] sError, any iUserID){
    if(sError[0]){
        SetFailState("SQL CreateTable Fail: %s", sError);
        return;
    }
    bDBInitialized = true;
}