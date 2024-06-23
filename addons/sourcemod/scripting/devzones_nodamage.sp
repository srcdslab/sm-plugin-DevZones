#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <devzones>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "SM DEV Zones - NoDamage",
	author = "Franc1sco franug",
	description = "",
	version = "3.1",
	url = "http://steamcommunity.com/id/franug"
};

public void OnPluginStart()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
			OnClientPutInServer(i);
	}
}

public void OnClientPutInServer(int client)
{
   SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(!IsValidClient(victim) || !IsValidClient(attacker))
		return Plugin_Continue;

	if(!Zone_IsClientInZone(victim, "nodamage", false) && !Zone_IsClientInZone(attacker, "nodamage", false))
		return Plugin_Continue;

	PrintHintText(attacker, "You cant hurt players in that zone!");
	return Plugin_Handled;
}

public bool IsValidClient(int client)
{
    if (!( 1 <= client <= MaxClients ) || !IsClientInGame(client))
        return false; 
    return true; 
}
