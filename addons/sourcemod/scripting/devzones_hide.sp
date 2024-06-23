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
	version = "2.0",
	url = "http://www.zeuszombie.com/"
};

public void OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_team", Event_PlayerTeam);
}

public void OnClientDisconnect(int client)
{
	hide[client] = false;
}

public Action Event_PlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	team[client] = GetEventInt(event, "team");
	return Plugin_Continue;
}

public Action PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (hide[client])
		NoHide(client);

	CreateTimer(4.0, OnPostPlayerSpawn, client);
	return Plugin_Continue;
}

public Action OnPostPlayerSpawn(Handle timer, any client)
{
	if (IsClientInGame(client) && hide[client])
		NoHide(client);
	return Plugin_Continue;
}

public void Zone_OnClientEntry(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;

	if(StrContains(zone, "hide", false) != 0)
		return;

	PrintHintText(client, "You entered in a hide teammates zone to improve the vision");
	CPrintToChat(client," {darkred}[HIDE TEAMMATES]{lime}You entered in a hide teammates zone to improve the vision");

	if(!hide[client])
		YesHide(client);
}

public void Zone_OnClientLeave(int client, const char[] zone)
{
	if (client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if (StrContains(zone, "hide", false) != 0)
		return;

	PrintHintText(client, "You left the hide teammates zone");
	CPrintToChat(client," {darkred}[HIDE TEAMMATES]{lime}You left the hide teammates zone");
	
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
