#include <sourcemod>
#include <sdktools>
#include <devzones>

#pragma semicolon 1
#pragma newdecls required

#define	HIDEHUD_ALL 1<<2

public Plugin myinfo =
{
	name = "SM DEV Zones - No HUD",
	author = "Franc1sco franug",
	description = "",
	version = "2.0",
	url = "http://steamcommunity.com/id/franug"
};

public void Zone_OnClientEntry(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;

	if(StrContains(zone, "nohud", false) != 0) return;

	SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDEHUD_ALL);
}

public void Zone_OnClientLeave(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if(StrContains(zone, "nohud", false) != 0) return;
	
	SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") & ~HIDEHUD_ALL);
}
