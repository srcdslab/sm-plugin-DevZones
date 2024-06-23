#include <sourcemod>
#include <sdktools>
#include <devzones>

#pragma semicolon 1
#pragma newdecls required

// configuration
#define ZONE_PREFIX "noentry"
//End

float zone_pos[MAXPLAYERS+1][3];
Handle g_hClientTimers[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};

public Plugin myinfo =
{
	name = "SM DEV Zones - NoEntry",
	author = "Franc1sco franug",
	description = "",
	version = "2.0",
	url = "http://steamcommunity.com/id/franug"
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
		
	if(StrContains(zone, ZONE_PREFIX, false) == 0)
	{
		Zone_GetZonePosition(zone, false, zone_pos[client]);
		g_hClientTimers[client] = CreateTimer(0.1, Timer_Repeat, client, TIMER_REPEAT);
		PrintHintText(client, "You can't enter here!");
	}
}

public void Zone_OnClientLeave(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if(StrContains(zone, ZONE_PREFIX, false) == 0)
	{
		if (g_hClientTimers[client] != INVALID_HANDLE)
			KillTimer(g_hClientTimers[client]);
		g_hClientTimers[client] = INVALID_HANDLE;
	}
}

public Action Timer_Repeat(Handle timer, any client)
{
	if(!IsClientInGame(client) || !IsPlayerAlive(client))
	{
		if (g_hClientTimers[client] != INVALID_HANDLE)
			KillTimer(g_hClientTimers[client]);
		g_hClientTimers[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	float clientloc[3];
	GetClientAbsOrigin(client, clientloc);
	
	KnockbackSetVelocity(client, zone_pos[client], clientloc, 300.0);
	return Plugin_Continue;
}

stock void KnockbackSetVelocity(int client, const float startpoint[3], const float endpoint[3], float magnitude)
{
    // Create vector from the given starting and ending points.
    float vector[3];
    MakeVectorFromPoints(startpoint, endpoint, vector);
    
    // Normalize the vector (equal magnitude at varying distances).
    NormalizeVector(vector, vector);
    
    // Apply the magnitude by scaling the vector (multiplying each of its components).
    ScaleVector(vector, magnitude);

    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vector);
}
