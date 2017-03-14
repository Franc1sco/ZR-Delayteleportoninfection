/*  ZR Delay teleport on infection
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <zombiereloaded>

#define DATA "1.0"

public Plugin:myinfo = 
{
	name = "ZR Delay teleport on infection",
	author = "Franc1sco franug",
	description = "",
	version = DATA,
	url = "http://steamcommunity.com/id/franug"
};

bool firsti;
Handle timers;

float position[MAXPLAYERS + 1][3];
Handle cvar_time;

public OnPluginStart()
{
	HookEvent("round_start", start);
	HookEvent("player_spawn", Event_PlayerSpawn);
	
	cvar_time = CreateConVar("sm_delayteleportoninfection_time", "5.0", "Time for teleport zombies to spawn after first infection.");
	
	CreateConVar("zr_delayteleportoninfection", DATA, "", FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	GetClientAbsOrigin(client, position[client]);
}

public Action:start(Handle:event, const String:name[], bool:dontBroadcast)
{
	firsti = false;
	if (timers != INVALID_HANDLE)KillTimer(timers);
	timers = INVALID_HANDLE;
}

public ZR_OnClientInfected(client, attacker, bool:motherInfect, bool:respawnOverride, bool:respawn)
{
	if (!firsti)Telepo();
}

Telepo()
{
	firsti = true;
	
	if (timers != INVALID_HANDLE)KillTimer(timers);
	timers = CreateTimer(GetConVarFloat(cvar_time), DoTele);
	
}

public Action DoTele(Handle timer)
{
	for(new i=1;i<=MaxClients;i++)
	{
    	if(IsClientInGame(i) && IsPlayerAlive(i) && ZR_IsClientZombie(i))
    	{
        	TeleportEntity(i, position[i], NULL_VECTOR, NULL_VECTOR);
    	}
	} 
	timers = INVALID_HANDLE;
}
