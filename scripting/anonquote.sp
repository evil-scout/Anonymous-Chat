#pragma semicolon 1

#include <sourcemod>


public Plugin myinfo = 
{
	name = "Anon Chat",
	author = "evilscout",
	description = "Remove usernames from chat, by request of Gaylord.",
	version = "1.0"
};

public void OnPluginStart()
{	
	AddCommandListener(OnSay, "say");
	AddCommandListener(OnSay, "say_team");
}

public Action OnSay(client, const String:command[], argc)
{
	if(!client || client > MaxClients || !IsClientInGame(client)) 
		return Plugin_Continue;

	decl String:text[128];
	
	GetCmdArgString(text, sizeof(text));
	StripQuotes(text);
	decl String:message[256];
	
	if (text[0] == '>')
		Format(message, sizeof(message), "\x05%s\x01 : \x05%s", "Anonymous", text);
	else 
		Format(message, sizeof(message), "\x05%s\x01 : %s", "Anonymous", text);
		
	PrintToChatAll(message);

	return Plugin_Handled;
}