#include <sourcemod>
#include <sdktools>
#include <devzones>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

// configuration
#define ZONE_PREFIX "noblock"
//End

bool noblock[MAXPLAYERS+1] = { false, ... };

public Plugin myinfo =
{
	name = "SM DEV Zones - NoBlock",
	author = "Franc1sco franug",
	description = "",
	version = "2.0",
	url = "http://www.cola-team.es"
};

public void OnPluginStart()
{
	HookEvent("player_spawn", EventPlayerSpawn);
}

public void EventPlayerSpawn(Handle event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	noblock[client] = false;
}

public void Zone_OnClientEntry(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;

	if(StrContains(zone, ZONE_PREFIX, false) == 0)
	{
		noblock[client] = true;
	}
}

public void Zone_OnClientLeave(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;

	if(StrContains(zone, ZONE_PREFIX, false) == 0)
	{
		noblock[client] = false;
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_ShouldCollide, ShouldCollide);
}

public bool ShouldCollide(int entity, int collisiongroup, int contentsmask, bool result)
{
	if (contentsmask == 33636363)
	{
		if (noblock[entity])
		{
			result = false;
			return false;
		}
	}
	
	return true;
}
