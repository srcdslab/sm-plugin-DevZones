#include <sourcemod>
#include <sdktools>
#include <devzones>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "SM DEV Zones - Teleport",
	author = "Franc1sco franug",
	description = "",
	version = "2.0",
	url = "http://www.clanuea.com/"
};

public void Zone_OnClientEntry(int client, const char[] zone)
{
	if (client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client)) 
		return;

	if (StrContains(zone, "teleport", false) == 0)
	{
		char targetzone[64];
		float Position[3];
		strcopy(targetzone, 64, zone);
		ReplaceString(targetzone, 64, "teleport", "target", false);
		if (Zone_GetZonePosition(targetzone, false, Position))
			TeleportEntity(client, Position, NULL_VECTOR, NULL_VECTOR);
	}
}
