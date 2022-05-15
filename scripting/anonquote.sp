#pragma semicolon 1

#include <sourcemod>


public Plugin myinfo = 
{
	name = "Anon Chat",
	author = "evilscout",
	description = "Remove usernames from chat, by request of Gaylord.",
	version = "1.2"
};

enum struct PlayerInfo {
	float lastTime; /* Last time player used say or say_team */
	int tokenCount; /* Number of flood tokens player has */
	bool blocked; /* Has a players message been blocked */
}

PlayerInfo playerinfo[MAXPLAYERS+1];

ConVar sm_flood_time;									/* Handle to sm_flood_time convar */
ConVar sm_anon_names;									/* Handle to sm_anon_names convar */
float max_chat;
int anon_names;

public void OnPluginStart()
{	
	AddCommandListener(OnSay, "say");
	AddCommandListener(FloodCheck, "say");
	AddCommandListener(FloodResult, "say");
	AddCommandListener(OnSay, "say_team");
	AddCommandListener(FloodCheck, "say_team");
	AddCommandListener(FloodResult, "say_team");
	sm_flood_time = CreateConVar("sm_flood_time", "0.75", "Amount of time allowed between chat messages");
	sm_anon_names = CreateConVar("sm_anon_names", "1", ("Anonymous Chat" ... " : 0 - Names will only be anonymous when using greentext 1 - Names will always be anonymous"), _, true, 0.0, true, 1.0); 
	AutoExecConfig(true, "anonquote");
}
public void OnClientPutInServer(int client)
{
	playerinfo[client].lastTime = 0.0;
	playerinfo[client].tokenCount = 0;
	playerinfo[client].blocked = false;
}

public Action FloodCheck(client, const String:command[], argc)
{
	max_chat = sm_flood_time.FloatValue;
	if (max_chat <= 0.0)
	{
		playerinfo[client].blocked = false;
		return;
	}
	if (playerinfo[client].lastTime >= GetGameTime())
	{
		if (playerinfo[client].tokenCount >= 3)
		{
			playerinfo[client].blocked = true;
			return;
		}
	}
	
	playerinfo[client].blocked = false;
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
		if (playerinfo[client].blocked)
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
	anon_names = sm_anon_names.IntValue;
	
	if(!client || client > MaxClients || !IsClientInGame(client)) 
		return Plugin_Continue;
	
	if (playerinfo[client].blocked == true) {
		PrintToChat(client, "[SM] You are flooding the server!");
		return Plugin_Handled;
	}
	
	decl String:text[128];
	GetCmdArgString(text, sizeof(text));
	StripQuotes(text);
	if (anon_names == 1) {
		decl String:message[256];
		Format(message, sizeof(message), "\x05%s\x01 : \x05%s", "Anonymous", text);
		
		PrintToChatAll(message);
		return Plugin_Handled;
	}
	else if (text[0] == '>') {
		decl String:message[256];
		Format(message, sizeof(message), "\x05%s\x01 : \x05%s", "Anonymous", text);
		
		PrintToChatAll(message);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}