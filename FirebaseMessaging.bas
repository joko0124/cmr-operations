B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=10
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	
#End Region

Sub Process_Globals
	Private fm As FirebaseMessaging
	Public MyIcon As Bitmap
	
	Public const grpNotifyID As Int = 101
	Public const sumNotifyID As Int = 100
	Public const groupID As String = "test_group"
	Public const groupName As String = "Test Group"
	Public const grpChnId As String = "chnTest"
	Public const grpChnName As String = Application.LabelName
	Public const sumChnId As String = "chnSummary"
	Public const sumChnName As String = "Summary Channel"
	Public curNotifyID As Int = grpNotifyID
  
	Public remNotifyID As Int = 0

End Sub

Sub Service_Create
	fm.Initialize("fm")
End Sub

Public Sub SubscribeToTopics
	fm.SubscribeToTopic("general") 'you can subscribe to more topics
End Sub

Sub Service_Start (StartingIntent As Intent)
	If StartingIntent.IsInitialized Then fm.HandleIntent(StartingIntent)
	Sleep(0)
	Service.StopAutomaticForeground 'remove if not using B4A v8+.
End Sub

Sub fm_MessageArrived (Message As RemoteMessage)
	Log("Message arrived")
	Log($"Message data: ${Message.GetData}"$)
'	Dim n As Notification
'	n.Initialize2(n.IMPORTANCE_HIGH)
'	n.Icon = "icon"
'	n.Light = True
'	n.Vibrate = True
'	n.SetInfo(Message.GetData.Get("title"), Message.GetData.Get("body"), Main)
'	n.Notify(1)
'	grpNotifyID = Message.GetData.Get("group_notify_id")
	
	MyIcon = LoadBitmapResize(File.DirAssets, "icon.png",24dip, 24dip, True)
	
	Dim n2 As NB6
	n2.Initialize(grpChnId, grpChnName, "DEFAULT",True).SmallIcon(MyIcon)
	n2.SetDefaults(True, True, True)
	n2.NotificationChannelGroup(groupID, groupName)
	
	n2.GroupSet(groupID)
	n2.GroupSummary(False)
	n2.CustomLight(Colors.ARGB(255,255,0,0),10,10)
	
	n2.Build(Message.GetData.Get("title"),Message.GetData.Get("body"),"tag",Main).Notify(curNotifyID)
	curNotifyID = curNotifyID + 1
	
	Dim nSum As NB6
	nSum.Initialize(sumChnId, sumChnName, "LOW",True).AutoCancel(True).SmallIcon(MyIcon)
	'we don't need any notification sound/vibration
	nSum.SetDefaults(False, False, False)
	'create notification channel group
	nSum.NotificationChannelGroup(groupID, groupName)
  
	nSum.GroupSet(groupID)
	nSum.GroupSummary(True)
  
	Dim contentText As String = "Summary Notification"
	Dim contentTitle As String = "Group " & grpChnName
	nSum.Build(contentTitle, contentText, "Tag", Main).Notify(sumNotifyID)
	nSum.BadgeIconType("LARGE").Number(sumNotifyID)
	Log($"Token: "$ & fm.Token)
End Sub

Sub fm_TokenRefresh (Token As String)
	Log("TokenRefresh: " & Token)
End Sub
Sub Service_Destroy

End Sub
