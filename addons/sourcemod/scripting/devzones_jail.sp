#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <devzones>

#pragma semicolon 1
#pragma newdecls required

bool nodamage[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "SM DEV Zones - Jail Damage",
	author = "Franc1sco franug",
	description = "",
	version = "2.0",
	url = "http://www.cola-team.es"
};

public void OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
}

public Action PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	nodamage[client] = false;
	CreateTimer(4.0, SpawnTimer, GetClientUserId(client));
	return Plugin_Continue;
}

public Action SpawnTimer(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client))
		return Plugin_Continue;

	nodamage[client] = false;
	return Plugin_Continue;
}

public void Zone_OnClientEntry(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;

	if(StrContains(zone, "jail", false) != 0)
		return;

	nodamage[client] = true;
}

public void Zone_OnClientLeave(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;

	if(StrContains(zone, "jail", false) != 0)
		return;

	nodamage[client] = false;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(!IsValidClient(attacker) || !IsValidClient(client)) return Plugin_Continue;

	if(nodamage[attacker] && nodamage[client])
	{
		return Plugin_Continue;
	}
	else if(!nodamage[attacker] && !nodamage[client])
	{
		return Plugin_Continue;
	}

	PrintHintText(attacker, "You cant hurt players in this zone!");
	return Plugin_Handled;
}

public bool IsValidClient(int client)
{
    if (!( 1 <= client <= MaxClients ) || !IsClientInGame(client))
        return false; 
    return true; 
}
