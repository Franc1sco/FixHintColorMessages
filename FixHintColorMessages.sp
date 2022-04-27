UserMsg g_TextMsg, g_HintText, g_KeyHintText;

public Plugin myinfo =
{
	name = "Fix Hint Color Messages",
	description = "Fix for PrintHintText and PrintCenterText colors msgs in csgo",
	author = "Phoenix (˙·٠●Феникс●٠·˙)",
	version = "1.3.0 Franc1sco franug github version",
	url = "https://github.com/Franc1sco/FixHintColorMessages"
};

public void OnPluginStart()
{
	g_TextMsg = GetUserMessageId("TextMsg");
	g_KeyHintText = GetUserMessageId("KeyHintText");
	g_HintText = GetUserMessageId("HintText");
	
	HookUserMessage(g_KeyHintText, HintTextHook, true)
	HookUserMessage(g_HintText, HintTextHook, true);
}

Action HintTextHook(UserMsg msg_id, Protobuf msg, const int[] players, int playersNum, bool reliable, bool init)
{
	char szBuf[2048];
	
	if(msg_id == g_KeyHintText)
	{
		msg.ReadString("hints", szBuf, sizeof szBuf, 0);
	}
	else
	{
		msg.ReadString("text", szBuf, sizeof szBuf);
	}
	
	if(StrContains(szBuf, "</") != -1)
	{
		DataPack hPack = new DataPack();
		
		hPack.WriteCell(playersNum);
		
		for(int i = 0; i < playersNum; i++)
		{
			hPack.WriteCell(players[i]);
		}
		
		hPack.WriteString(szBuf);
		
		hPack.Reset();
		
		RequestFrame(HintTextFix, hPack);
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

void HintTextFix(DataPack hPack)
{
	int iCountNew = 0, iCountOld = hPack.ReadCell();
	
	int iPlayers[MAXPLAYERS+1];
	
	for(int i = 0, iPlayer; i < iCountOld; i++)
	{
		iPlayer = hPack.ReadCell();
		
		if(IsClientInGame(iPlayer))
		{
			iPlayers[iCountNew++] = iPlayer;
		}
	}
	
	if(iCountNew != 0)
	{
		char szBuf[2048];
		
		hPack.ReadString(szBuf, sizeof szBuf);
		
		Protobuf hMessage = view_as<Protobuf>(StartMessageEx(g_TextMsg, iPlayers, iCountNew, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS));
		
		if(hMessage)
		{
			hMessage.SetInt("msg_dst", 4);
			hMessage.AddString("params", "#SFUI_ContractKillStart");
			
			Format(szBuf, sizeof szBuf, "</font>%s<script>", szBuf);
			hMessage.AddString("params", szBuf);
			
			hMessage.AddString("params", NULL_STRING);
			hMessage.AddString("params", NULL_STRING);
			hMessage.AddString("params", NULL_STRING);
			
			EndMessage();
		}
	}
	
	hPack.Close();
}
