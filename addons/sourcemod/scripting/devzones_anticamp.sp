#include <sourcemod>
#include <sdktools>
#include <devzones>

#pragma semicolon 1
#pragma newdecls required

Handle g_hClientTimers[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};
Handle cvar_time = INVALID_HANDLE;

public Plugin myinfo =
{
	name = "SM DEV Zones - AntiCamp",
	author = "Franc1sco franug",
	description = "",
	version = "2.0",
	url = "http://www.clanuea.com/"
};

public void OnPluginStart()
{
	cvar_time = CreateConVar("sm_devzones_anticamptime", "10", "Time in seconds before players must leave the zone or die");
}

public void OnClientPutInServer(int client)
{
	if (g_hClientTimers[client] != INVALID_HANDLE)
		KillTimer(g_hClientTimers[client]);
	g_hClientTimers[client] = INVALID_HANDLE;
}

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
		
	if((StrContains(zone, "AntiCampCT", false) == 0 && GetClientTeam(client) == 3) || (StrContains(zone, "AntiCampTT", false) == 0 && GetClientTeam(client) == 2))
	{
		int seconds = GetConVarInt(cvar_time);
		g_hClientTimers[client] = CreateTimer(seconds * 1.0, Timer_End, client);
		PrintHintText(client, "You has entered in a AntiCamp Zone for your team\nYou have %i seconds for leave this zone or you will die", seconds);
	}
}

public void Zone_OnClientLeave(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if((StrContains(zone, "AntiCampCT", false) == 0 && GetClientTeam(client) == 3) || (StrContains(zone, "AntiCampTT", false) == 0 && GetClientTeam(client) == 2))
	{
		if (g_hClientTimers[client] != INVALID_HANDLE)
			KillTimer(g_hClientTimers[client]);
		g_hClientTimers[client] = INVALID_HANDLE;
	}
}

public Action Timer_End(Handle timer, any client)
{
	if(IsPlayerAlive(client))
	{
		ForcePlayerSuicide(client);
		PrintToChatAll("%N have beeen killed for camp in a anticamp zone",client);
	}
	g_hClientTimers[client] = INVALID_HANDLE;
	return Plugin_Continue;
}
