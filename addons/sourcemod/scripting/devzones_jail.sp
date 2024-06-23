#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <devzones>

new bool:nodamage[MAXPLAYERS+1];

public Plugin:myinfo =
{
	name = "SM DEV Zones - Jail Damage",
	author = "Franc1sco franug",
	description = "",
	version = "2.0",
	url = "http://www.cola-team.es"
};

public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	nodamage[client] = false;
	CreateTimer(4.0, SpawnTimer, GetClientUserId(client));
}

public Action:SpawnTimer(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client))
		return;
		
	nodamage[client] = false;
	
}

public Zone_OnClientEntry(client, String:zone[])
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if(StrContains(zone, "jail", false) != 0) return;
	
	nodamage[client] = true;
}

public Zone_OnClientLeave(client, String:zone[])
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if(StrContains(zone, "jail", false) != 0) return;
	
	nodamage[client] = false;
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
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

public IsValidClient( client ) 
{ 
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}