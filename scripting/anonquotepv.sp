#pragma semicolon 1

#include <sourcemod>


public Plugin myinfo = 
{
	name = "Anon Chat",
	author = "evilscout",
	description = "Remove usernames from chat, by request of Gaylord.",
	version = "1.1"
};

enum struct PlayerInfo {
	float lastTime; /* Last time player used say or say_team */
	int tokenCount; /* Number of flood tokens player has */
}

PlayerInfo playerinfo[MAXPLAYERS+1];

ConVar sm_flood_time;									/* Handle to sm_flood_time convar */
float max_chat;
bool blocked;


public void OnPluginStart()
{	
	AddCommandListener(OnSay, "say");
	AddCommandListener(FloodCheck, "say");
	AddCommandListener(FloodResult, "say");
	AddCommandListener(OnSay, "say_team");
	AddCommandListener(FloodCheck, "say_team");
	AddCommandListener(FloodResult, "say_team");
	sm_flood_time = CreateConVar("sm_flood_time", "0.75", "Amount of time allowed between chat messages");
}
public void OnClientPutInServer(int client)
{
	playerinfo[client].lastTime = 0.0;
	playerinfo[client].tokenCount = 0;
}

public Action FloodCheck(client, const String:command[], argc)
{
	max_chat = sm_flood_time.FloatValue;
	if (max_chat <= 0.0)
	{
		blocked = false;
		return;
	}
	if (playerinfo[client].lastTime >= GetGameTime())
	{
		if (playerinfo[client].tokenCount >= 3)
		{
			blocked = true;
			return;
		}
	}
	
	blocked = false;
}

public Action FloodResult(client, const String:command[], argc)
{
	if (max_chat <= 0.0)
	{
		return;
	}
	
	float curTime = GetGameTime();
	float newTime = curTime + max_chat;
	
	if (playerinfo[client].lastTime >= curTime)
	{
		/* If the last message was blocked, update their time limit */
		if (blocked)
		{
			newTime += 3.0;
		}
		/* Add one flood token when player goes over chat time limit */
		else if (playerinfo[client].tokenCount < 3)
		{
			playerinfo[client].tokenCount++;
		}
	}
	else if (playerinfo[client].tokenCount > 0)
	{
		/* Remove one flood token when player chats within time limit (slow decay) */
		playerinfo[client].tokenCount--;
	}
	
	playerinfo[client].lastTime = newTime;
}

public Action OnSay(client, const String:command[], argc)
{
	if(!client || client > MaxClients || !IsClientInGame(client)) 
		return Plugin_Continue;
	
	if (blocked == true) {
		return Plugin_Handled;
	}
	
	decl String:text[128];
	GetCmdArgString(text, sizeof(text));
	StripQuotes(text);
	if (text[0] == '>') {
		decl String:message[256];
		Format(message, sizeof(message), "\x05%s\x01 : \x05%s", "Anonymous", text);
		
		PrintToChatAll(message);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}