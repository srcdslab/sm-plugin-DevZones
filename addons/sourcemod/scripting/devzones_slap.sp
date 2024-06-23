#include <sourcemod>
#include <sdktools>
#include <devzones>

#pragma semicolon 1
#pragma newdecls required

#define ZONE_PREFIX_CT "SlapCT"
#define ZONE_PREFIX_TT "SlapTT"
#define ZONE_PREFIX_ANY "SlapANY"
#define REPEAT_VALUE 0.1

Handle g_hClientTimers[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};

public Plugin myinfo =
{
	name = "SM DEV Zones - Slap",
	author = "Franc1sco franug",
	description = "",
	version = "2.1",
	url = "http://www.clanuea.com/"
};

public void OnClientDisconnect(int client)
{
	if (g_hClientTimers[client] != INVALID_HANDLE)
		KillTimer(g_hClientTimers[client]);
	g_hClientTimers[client] = INVALID_HANDLE;
}

public void Zone_OnClientEntry(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if((StrContains(zone, ZONE_PREFIX_CT, false) == 0 && GetClientTeam(client) == 3) || (StrContains(zone, ZONE_PREFIX_TT, false) == 0 && GetClientTeam(client) == 2) || StrContains(zone, ZONE_PREFIX_ANY, false) == 0)
	{
		g_hClientTimers[client] = CreateTimer(REPEAT_VALUE, Timer_Repeat, client, TIMER_REPEAT);
	}
}

public void Zone_OnClientLeave(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if((StrContains(zone, ZONE_PREFIX_CT, false) == 0 && GetClientTeam(client) == 3) || (StrContains(zone, ZONE_PREFIX_TT, false) == 0 && GetClientTeam(client) == 2) || StrContains(zone, ZONE_PREFIX_ANY, false) == 0)
	{
		if (g_hClientTimers[client] != INVALID_HANDLE)
			KillTimer(g_hClientTimers[client]);
		g_hClientTimers[client] = INVALID_HANDLE;
	}
}

public Action Timer_Repeat(Handle timer, any client)
{
	if(!IsPlayerAlive(client))
	{
		if (g_hClientTimers[client] != INVALID_HANDLE)
			KillTimer(g_hClientTimers[client]);
		g_hClientTimers[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	SlapPlayer(client, 0, false);
	return Plugin_Continue;
}
