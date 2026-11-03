#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <devzones>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required

bool hide[MAXPLAYERS+1];
int team[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "SM DEV Zones - Hide",
	author = "Franc1sco franug",
	description = "",
	version = "2.1.2",
	url = "http://www.zeuszombie.com/"
};

public void OnPluginStart()
{
	LoadTranslations("devzones_hide.phrases");

	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_team", Event_PlayerTeam);
}

public void OnClientDisconnect(int client)
{
	hide[client] = false;
}

public Action Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	team[client] = event.GetInt("team");
	return Plugin_Continue;
}

public Action PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (hide[client])
		NoHide(client);

	CreateTimer(4.0, OnPostPlayerSpawn, GetClientUserId(client));
	return Plugin_Continue;
}

public Action OnPostPlayerSpawn(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client != 0 && IsClientInGame(client) && hide[client])
		NoHide(client);
	return Plugin_Continue;
}

public void Zone_OnClientEntry(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;

	if(StrContains(zone, "hide", false) != 0)
		return;

	PrintHintText(client, "%t", "Hide Zone Entered");
	CPrintToChat(client," {darkred}[HIDE TEAMMATES]{lime}%t", "Hide Zone Entered");

	if(!hide[client])
		YesHide(client);
}

public void Zone_OnClientLeave(int client, const char[] zone)
{
	if (client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if (StrContains(zone, "hide", false) != 0)
		return;

	PrintHintText(client, "%t", "Hide Zone Left");
	CPrintToChat(client," {darkred}[HIDE TEAMMATES]{lime}%t", "Hide Zone Left");
	
	if (hide[client])
		NoHide(client);
}

public Action Hook_SetTransmit(int entity, int client) 
{ 
    if (entity != client && team[client] == team[entity]) 
        return Plugin_Handled;
    return Plugin_Continue;
}

stock void NoHide(int client)
{
	SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit); 
	hide[client] = false;
}

stock void YesHide(int client)
{
	SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit); 
	hide[client] = true;
}
