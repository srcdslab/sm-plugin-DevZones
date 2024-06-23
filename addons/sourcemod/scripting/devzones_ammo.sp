#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <devzones>

#pragma semicolon 1
#pragma newdecls required

bool infiniteammo[MAXPLAYERS+1];

int activeOffset = -1;
int clip1Offset = -1;
int clip2Offset = -1;
int secAmmoTypeOffset = -1;
int priAmmoTypeOffset = -1;

public Plugin myinfo =
{
	name = "SM DEV Zones - Infinite Ammo",
	author = "Franc1sco franug",
	description = "",
	version = "2.0",
	url = "http://steamcommunity.com/id/franug"
};

public void OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("weapon_fire", EventWeaponFire);
	
	activeOffset = FindSendPropInfo("CAI_BaseNPC", "m_hActiveWeapon");
	
	clip1Offset = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
	clip2Offset = FindSendPropInfo("CBaseCombatWeapon", "m_iClip2");
	
	priAmmoTypeOffset = FindSendPropInfo("CBaseCombatWeapon", "m_iPrimaryAmmoCount");
	secAmmoTypeOffset = FindSendPropInfo("CBaseCombatWeapon", "m_iSecondaryAmmoCount");
}

public Action PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	infiniteammo[client] = false;
	CreateTimer(4.0, OnPostPlayerSpawn, GetClientUserId(client));
	return Plugin_Continue;
}

public Action OnPostPlayerSpawn(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client != 0 && IsClientInGame(client))
		infiniteammo[client] = false;
	return Plugin_Continue;
}

public void Zone_OnClientEntry(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
			
	if(StrContains(zone, "ammo", false) != 0) return;
	PrintHintText(client, "UNLIMITED AMMO ZONE");
	infiniteammo[client] = true;
}

public void Zone_OnClientLeave(int client, const char[] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;
		
	if(StrContains(zone, "ammo", false) != 0) return;
	
	infiniteammo[client] = false;
}

public Action EventWeaponFire(Handle event, const char[] name, bool dontBroadcast)
{
    // Get all required event info.
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (infiniteammo[client])
		Client_ResetAmmo(client);
	return Plugin_Continue;
}

public void Client_ResetAmmo(int client)
{
	int zomg = GetEntDataEnt2(client, activeOffset);
	if (clip1Offset != -1 && zomg != -1)
		SetEntData(zomg, clip1Offset, GetEntData(zomg, clip1Offset, 4)+1, 4, true);
	if (clip2Offset != -1 && zomg != -1)
		SetEntData(zomg, clip2Offset, GetEntData(zomg, clip2Offset, 4)+1, 4, true);
	if (priAmmoTypeOffset != -1 && zomg != -1)
		SetEntData(zomg, priAmmoTypeOffset, GetEntData(zomg, priAmmoTypeOffset, 4)+1, 4, true);
	if (secAmmoTypeOffset != -1 && zomg != -1)
		SetEntData(zomg, secAmmoTypeOffset, GetEntData(zomg, secAmmoTypeOffset, 4)+1, 4, true);		
}
