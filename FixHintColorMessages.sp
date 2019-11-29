UserMsg g_TextMsg, g_HintText;

public Plugin myinfo =
{
	name = "Fix Hint Color Messages",
	description = "Исправляет форматирование для PrintHintText и PrintCenterText",
	author = "Phoenix (˙·٠●Феникс●٠·˙) and Franc1sco Franug",
	version = "1.0.1",
	url = "zizt.ru hlmod.ru"
};

public void OnPluginStart()
{
	g_TextMsg = GetUserMessageId("TextMsg");
	g_HintText = GetUserMessageId("HintText");
	
	HookUserMessage(g_TextMsg, TextMsgHintTextHook, true);
	HookUserMessage(g_HintText, TextMsgHintTextHook, true);
}

Action TextMsgHintTextHook(UserMsg msg_id, Protobuf msg, const int[] players, int playersNum, bool reliable, bool init)
{
	static char sBuf[8192];
	
	if(msg_id == g_HintText)
	{
		msg.ReadString("text", sBuf, sizeof sBuf);
	}
	else if(msg.ReadInt("msg_dst") == 4)
	{
		msg.ReadString("params", sBuf, sizeof sBuf, 0);
	}
	else
	{
		return Plugin_Continue;
	}
		
	if(StrContains(sBuf, "<font") != -1 || StrContains(sBuf, "<span") != -1) // only hook msg with colored tags
	{
		DataPack hPack = new DataPack();
		
		hPack.WriteCell(playersNum);
		
		for(int i = 0; i < playersNum; i++)
		{
			hPack.WriteCell(players[i]);
		}
		
		hPack.WriteString(sBuf);
		
		hPack.Reset();
		
		RequestFrame(TextMsgFix, hPack);
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

void TextMsgFix(DataPack hPack)
{
	int iCount = hPack.ReadCell();
	
	static int iPlayers[MAXPLAYERS+1];
	
	for(int i = 0; i < iCount; i++)
	{
		iPlayers[i] = hPack.ReadCell();
	}
	
	static char sBuf[8192];
	
	hPack.ReadString(sBuf, sizeof sBuf);
	
	delete hPack;
	
	Protobuf hMessage = view_as<Protobuf>(StartMessageEx(g_TextMsg, iPlayers, iCount, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS));
	
	if(hMessage)
	{
		hMessage.SetInt("msg_dst", 4);
		hMessage.AddString("params", "#SFUI_ContractKillStart");
		
		Format(sBuf, sizeof sBuf, "</font>%s\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", sBuf);
		hMessage.AddString("params", sBuf);
		
		hMessage.AddString("params", NULL_STRING);
		hMessage.AddString("params", NULL_STRING);
		hMessage.AddString("params", NULL_STRING);
		hMessage.AddString("params", NULL_STRING);
		
		EndMessage();
	}
}