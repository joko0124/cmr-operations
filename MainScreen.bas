B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.9
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: True
	#IncludeTitle: False
#End Region
#Extends: android.support.v7.app.AppCompatActivity
#If Java

public boolean _onCreateOptionsMenu(android.view.Menu menu) {
	if (processBA.subExists("activity_createmenu")) {
		processBA.raiseEvent2(null, true, "activity_createmenu", false, new de.amberhome.objects.appcompat.ACMenuWrapper(menu));
		return true;
	}
	else
		return false;
}
#End If

#Region Variable Declarations
Sub Process_Globals
	Private xui As XUI
	'Badge
	Private NotifBMP As Bitmap
End Sub

Sub Globals
	Dim ActionBarButton As ACActionBar
	Private ToolBar As ACToolBarDark
	Private xmlIcon As XmlLayoutBuilder
	Private MatDialogBuilder As MaterialDialogBuilder
	Private CD As ColorDrawable
	Private vibration As B4Avibrate
	Private vibratePattern() As Long
	Private snack As DSSnackbar
	Private csAns As CSBuilder

	Private Drawer As B4XDrawer
	Private lvMenus As ListView
	Private pnlMenuHeader As Panel
	Private lblUserBranch As Label
	Private lblUserFullName As Label

	Private img1 As ImageView
	Private img2 As ImageView
	Private img3 As ImageView
	Private img4 As ImageView
	Private img5 As ImageView
	Private img6 As ImageView
	Private pnlJO As Panel
	Private pnlNonOp As Panel
	Private pnlProd As Panel
	Private pnlRepair As Panel
	Private pnlStatus As Panel
	Private pnlCPM As Panel
	Private pnlGPM As Panel
	
	Private SelectedWBEntry As Int
	Private lblTranDate As Label

	Dim theDate As Long
	
	Dim dblInitRdg, dblLastRdg As Double

	Private lblEmpName As B4XView
	Private lblBranchName As B4XView
	Private lblReadingPeriod As B4XView
	
	Private DtDialog As DateDialogs
	Private MyToast As BCToast
	
	Private pnlPumpSelection As Panel
	Private clvPumpList As CustomListView
	Private lblPumpLoc As B4XView
	Private lblPumpCode As B4XView
	
	Type PumpAssigned (PumpID As Int, PumpCode As String, PumpLoc As String)

	Private btnSelect As ACButton
	Private btnCancel As ACButton

	Private lblAvatar As Label
	Private pnlUserStyle As Panel
	Private lblMenuAvatar As Label
	Private JOWithType As Int

	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")
	Private iJOUnreadCount As Int
	
	Private badger1 As Badger
	Private NotifTimer As Timer
	Private KVS As KeyValueStore
End Sub
#End Region

#Region Activity Functions
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Drawer.Initialize(Me,"MainMenu",Activity, 82%x)
	Drawer.CenterPanel.LoadLayout("mainscreen")

	GlobalVar.CSTitle.Initialize.Size(15).Bold.Append(Application.LabelName).PopAll
	GlobalVar.CSSubTitle.Initialize.Size(12).Append(Application.VersionName).PopAll
	
	ToolBar.InitMenuListener
	ToolBar.Title = GlobalVar.CSTitle
	ToolBar.SubTitle = GlobalVar.CSSubTitle
	
	Dim jo As JavaObject
	Dim xl As XmlLayoutBuilder
	jo = ToolBar
	jo.RunMethod("setPopupTheme", Array(xl.GetResourceId("style", "ToolbarMenu")))
	jo.RunMethod("setContentInsetStartWithNavigation", Array(1dip))
	jo.RunMethod("setTitleMarginStart", Array(0dip))
	
	ActionBarButton.Initialize

	ActionBarButton.ShowUpIndicator = True
	ActionBarButton.UpIndicatorBitmap = LoadBitmapSample(File.DirAssets, "hamburger.png", 80dip, 80dip)

	NotifBMP = LoadBitmap(File.DirAssets,"notifBMP.png")
	
	If FirstTime Then
		If GlobalVar.UserPosID = 5 Then 'Pump Operator
			CreateMainMenu(1, 1, 1, 0, 0, 0, 0, 1)		
		Else If GlobalVar.UserPosID = 6 Then 'Plumber
			CreateMainMenu(0, 0, 0, 1, 0, 0, 0, 1)
		Else
			CreateMainMenu(0, 0, 0, 0, 0, 0, 1, 1)			
		End If

		GlobalVar.TranDate = DateTime.Date(DateTime.Now)
		ShowWelcomeDialog
		GlobalVar.RepMainID = 0
		GlobalVar.RepMainDesc = ""
		lblAvatar.Text = GlobalVar.UserAvatar
'		lblMenuAvatar.Text = GlobalVar.UserAvatar
		lblEmpName.Text = GlobalVar.EmpName
		lblBranchName.Text = GlobalVar.UserPos & " | " &  GlobalVar.BranchName
		lblReadingPeriod.Text = $"PERIOD COVERED: "$ & GlobalVar.RdgFrom & " - " & GlobalVar.RdgTo
		GlobalVar.PumpDrainPipeType = ""
		GlobalVar.PumpDrainPipeSize = ""
		JOWithType = 0
		KVS.Initialize(File.DirInternal, "operations.dat")
	End If
	badger1.Initialize
	csAns.Initialize.Color(Colors.White).Bold.Append($"YES"$).PopAll
	Drawer.LeftPanel.LoadLayout("MainMenu")
	
	MyToast.Initialize(Activity)
	
	CD.Initialize2(GlobalVar.RedColor, 20, 0, Colors.Transparent)
	btnCancel.Background = CD
	btnCancel.Text = $"CANCEL"$
	NotifTimer.Initialize("Timer1", 2000)

	If GlobalVar.UserPosID = 6 Then
		NotifTimer.Enabled = True
	Else
		NotifTimer.Enabled = False
	End If
End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	If KeyCode = 4 Then
		Drawer.LeftOpen = False
		vibration.vibrateOnce(1000)
		snack.Initialize("LogOFF", Activity, $"Sure to Log Off now?"$, snack.DURATION_SHORT)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		snack.SetAction(csAns)
		snack.Show
		Return True
	Else
		Return False
	End If
End Sub

Sub Activity_Resume
	If GlobalVar.UserPosID = 5 Then 'Pump Operator
		CreateMainMenu(1, 1, 1, 0, 0, 0, 0, 1)
		GlobalVar.PumpDrainPipeType = ""
		GlobalVar.PumpDrainPipeSize = ""
	Else If GlobalVar.UserPosID = 6 Then 'Plumber
		CreateMainMenu(0, 0, 0, 1, 0, 0, 0, 1)
'		pnlProd.Enabled = False
'		pnlProd.Color = Colors.LightGray
		GlobalVar.PumpDrainPipeType = ""
		GlobalVar.PumpDrainPipeSize = ""		
	Else
		CreateMainMenu(0, 0, 0, 0, 0, 0, 1, 1)
	End If
'	SetDashboardIcons
	lblAvatar.Text = GlobalVar.UserAvatar
	lblEmpName.Text = GlobalVar.EmpName
	lblBranchName.Text = GlobalVar.UserPos & " | " &  GlobalVar.BranchName
	lblReadingPeriod.Text = $"PERIOD COVERED: "$ & GlobalVar.RdgFrom & " - " & GlobalVar.RdgTo

	DateTime.DateFormat = "yyyy-MM-dd"
'	theDate = DateTime.DateParse(GlobalVar.TranDate)
'	GlobalVar.TranDate = DateTime.Date(theDate)
	lblTranDate.Text =$"TRANSACTION DATE: "$ & GlobalVar.TranDate
	
	GlobalVar.RepMainID = 0
	GlobalVar.RepMainDesc = ""
	JOWithType = 0
	If GlobalVar.UserPosID = 6 Then
		NotifTimer.Enabled = True
	Else
		NotifTimer.Enabled = False
	End If
	If KVS.IsInitialized = False Then
		KVS.Initialize(File.DirInternal, "operations.dat")
	End If
'	If NotifyCountJO = True Then
'		UpdateBadge("Notif",AddBadgeToIcon(NotifBMP, iJOUnreadCount))
'	End If
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	NotifTimer.Enabled = False
	If UserClosed Then ExitApplication
End Sub

Sub Activity_CreateMenu(Menu As ACMenu)
	Dim iItem As ACMenuItem
	Menu.Clear
	If GlobalVar.UserPosID = 5 Then 'Pump Operator
		Menu.Add2(1, 1, "Transaction Date",xmlIcon.GetDrawable("ic_date_range_white_24dp")).ShowAsAction = iItem.SHOW_AS_ACTION_IF_ROOM
		Menu.Add2(2, 2, "Pump Selection",xmlIcon.GetDrawable("sharp_house_white_24dp")).ShowAsAction = iItem.SHOW_AS_ACTION_ALWAYS
	Else If GlobalVar.UserPosID = 6 Then 'Plumber
		Menu.Add2(1, 1, "Transaction Date",xmlIcon.GetDrawable("ic_date_range_white_24dp")).ShowAsAction = iItem.SHOW_AS_ACTION_IF_ROOM
		Menu.Add2(3, 3, "Notif",xmlIcon.GetDrawable("baseline_notifications_white_24dp")).ShowAsAction = iItem.SHOW_AS_ACTION_ALWAYS
		Menu.Add2(4, 4, "Logout",xmlIcon.GetDrawable("baseline_logout_white_24")).ShowAsAction = iItem.SHOW_AS_ACTION_ALWAYS
	Else 'Other Position
	End If
End Sub

Sub Activity_PermissionResult (Permission As String, Result As Boolean)
	Log (Permission)
End Sub
#End Region

#Region ToolBar Options
Sub ToolBar_NavigationItemClick
'	If MatDrawer.IsInitialized Then
'		MatDrawer.OpenDrawer
'	End If
	Drawer.LeftOpen = Not(Drawer.LeftOpen)
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)
	Select Case Item.Id
		Case 1 'Transaction Date
			Dim lDate As Long
			Dim sDate As String
			
			lDate = DateTime.DateParse(GlobalVar.TranDate)
			DtDialog.Initialize(Activity, lDate)
			DateTime.DateFormat = "yyyy-MM-dd"
			theDate = DtDialog.Show($"Select New Transaction Date"$)
			
			If theDate = DialogResponse.POSITIVE Then
				sDate = DtDialog.DateSelected
'				lDate = DateTime.DateParse(sDate)
				RemoveTranDate
				GlobalVar.TranDate = DateTime.Date(sDate)
				snack.Initialize("",Activity,$"Selected Transaction Date is "$ & GlobalVar.TranDate, snack.DURATION_SHORT)
				MyFunctions.SetSnackBarBackground(snack,GlobalVar.GreenColor)
				MyFunctions.SetSnackBarTextColor(snack, Colors.White)
				snack.Show
				SaveTranDate
			Else
				snack.Initialize("",Activity,$"Setting Transaction Date Cancelled"$, snack.DURATION_LONG)
				MyFunctions.SetSnackBarBackground(snack,Colors.White)
				MyFunctions.SetSnackBarTextColor(snack, GlobalVar.RedColor)
				snack.Show
			End If
			lblTranDate.Text =$"TRANSACTION DATE: "$ & GlobalVar.TranDate
		Case 2 'Pump Selection
			pnlPumpSelection.Visible = True
		Case 3
			StartActivity(actJONotification)
		Case 4
			vibration.vibrateOnce(1000)
			snack.Initialize("LogOFF", Activity, $"Sure to Log Off now?"$, snack.DURATION_SHORT)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			snack.SetAction(csAns)
			snack.Show			
	End Select
End Sub
#End Region

#Region MainMenu
Private Sub CreateMainMenu(iMod1 As Int, iMod2 As Int, iMod3 As Int, iMod4 As Int, iMod5 As Int, iMod6 As Int, iMod7 As Int, iMod8 As Int)
	Dim civ As CircularImageView
	Dim imgBack As BitmapDrawable
	Dim CDPressed,CDNormal As ColorDrawable
	Dim SLD As StateListDrawable
	Dim csMenu1, csMenu2, csMenu3, csMenu4, csMenu5, csMenu6, csMenu7, csMenu8 As CSBuilder
	Dim sIcon1, sIcon2, sIcon3, sIcon4, sIcon5, sIcon6, sIcon7, sIcon8 As Object
	
	Dim fMainMenu, fSecMenu As Typeface
		
	'User Icon
'	imgBack.Initialize( LoadBitmap(File.DirAssets,"profile3.jpg"))

	If pnlMenuHeader.IsInitialized = False Then pnlMenuHeader.Initialize("")
	LogColor(GlobalVar.UserAvatar, Colors.Cyan)

'	If civ.IsInitialized = False Then civ.Initialize("")

'	civ.BorderWidth = 2dip
'	civ.BorderColor = GlobalVar.PriColor
'	civ.Color = Colors.Transparent
'	civ.SetDrawable ( imgBack )
'	pnlMenuHeader.AddView(civ,20,2%y,100,100)
	
	'Menu State colors
	CDNormal.Initialize(Colors.White,0) 'Normal Color
	CDPressed.Initialize(0xFFD3D3D3,0)  'Pressed Color

	SLD.Initialize
	SLD.AddState(SLD.State_Pressed, CDNormal)
	SLD.AddState(-SLD.State_Pressed, CDPressed)
	
	If lblMenuAvatar.IsInitialized = False Then lblMenuAvatar.Initialize("")
	If lblUserFullName.IsInitialized = False Then lblUserFullName.Initialize("")
	If lblUserBranch.IsInitialized = False Then lblUserBranch.Initialize("")
	If lvMenus.IsInitialized = False Then lvMenus.Initialize("lvMenus")
	
	Dim LVO As JavaObject = lvMenus
	LVO.RunMethod("setSelector",Array As Object(SLD))
	lvMenus.FastScrollEnabled=True
	
	'Header Panel
	lblMenuAvatar.Text = GlobalVar.UserAvatar
	lblUserFullName.Text = GlobalVar.SF.Upper(GlobalVar.EmpName)
	lblUserBranch.Text = GlobalVar.BranchName
	
	fMainMenu = Typeface.LoadFromAssets("Roboto-Bold.ttf")
	fSecMenu = Typeface.LoadFromAssets("roboto-regular.ttf")

	'Menu Colors
	If iMod1 = 1 Then
		csMenu1.Initialize.Color(GlobalVar.BlueColor).Append($"Pump Production"$).PopAll
		sIcon1 = MyFunctions.FontBit(Chr(0xF043),17,GlobalVar.BlueColor, True)
	Else
		csMenu1.Initialize.Color(Colors.LightGray).Append($"Pump Production"$).PopAll
		sIcon1 = MyFunctions.FontBit(Chr(0xF043),17,Colors.LightGray, True)
	End If
	
	If iMod2 = 1 Then
		csMenu2.Initialize.Color(GlobalVar.BlueColor).Append($"Repair and Maintenance"$).PopAll
		sIcon2 = MyFunctions.FontBit(Chr(0xF0AD),17,GlobalVar.BlueColor, True)
	Else
		csMenu2.Initialize.Color(Colors.LightGray).Append($"Repair and Maintenance"$).PopAll
		sIcon2 = MyFunctions.FontBit(Chr(0xF0AD),17,Colors.LightGray, True)
	End If
	
	If iMod3 = 1 Then
		csMenu3.Initialize.Color(GlobalVar.BlueColor).Append($"Pump Non-operational"$).PopAll
		sIcon3 = MyFunctions.FontBit(Chr(0xE0C4),17,GlobalVar.BlueColor, False)
	Else
		csMenu3.Initialize.Color(Colors.LightGray).Append($"Pump Non-operational"$).PopAll
		sIcon3 = MyFunctions.FontBit(Chr(0xE0C4),17,Colors.LightGray, False)
	End If
	
	If iMod4 = 1 Then
		csMenu4.Initialize.Color(GlobalVar.BlueColor).Append($"Job Orders"$).PopAll
		sIcon4 = MyFunctions.FontBit(Chr(0xF022),17,GlobalVar.BlueColor, True)
	Else
		csMenu4.Initialize.Color(Colors.LightGray).Append($"Job Orders"$).PopAll
		sIcon4 = MyFunctions.FontBit(Chr(0xF022),17,Colors.LightGray, True)
	End If
	
	If iMod5 = 1 Then
		csMenu5.Initialize.Color(GlobalVar.BlueColor).Append($"Water Balance Entry"$).PopAll
		sIcon5 = MyFunctions.FontBit(Chr(0xF201),17,GlobalVar.BlueColor, True)
	Else
		csMenu5.Initialize.Color(Colors.LightGray).Append($"Water Balance Entry"$).PopAll
		sIcon5 = MyFunctions.FontBit(Chr(0xF201),17,Colors.LightGray, True)
	End If
	
	If iMod6 = 1 Then
		csMenu6.Initialize.Color(GlobalVar.BlueColor).Append($"Data Syncing"$).PopAll
		sIcon6 = MyFunctions.FontBit(Chr(0xE8D5),17,GlobalVar.BlueColor,False)
	Else
		csMenu6.Initialize.Color(Colors.LightGray).Append($"Data Syncing"$).PopAll
		sIcon6 = MyFunctions.FontBit(Chr(0xE8D5),17,Colors.LightGray,False)
	End If

	If iMod7 = 1 Then
		csMenu7.Initialize.Color(GlobalVar.BlueColor).Append($"Reading Settings"$).PopAll
		sIcon7 = MyFunctions.FontBit(Chr(0xF073),17,GlobalVar.BlueColor, True)
	Else
		csMenu7.Initialize.Color(Colors.LightGray).Append($"Reading Settings"$).PopAll
		sIcon7 = MyFunctions.FontBit(Chr(0xF073),17,Colors.LightGray, True)
	End If

	If iMod8 = 1 Then
		csMenu8.Initialize.Color(GlobalVar.BlueColor).Append($"User Settings"$).PopAll
		sIcon8 = MyFunctions.FontBit(Chr(0xE851),17,GlobalVar.BlueColor,False)
	Else
		csMenu8.Initialize.Color(Colors.LightGray).Append($"User Settings"$).PopAll
		sIcon8 = MyFunctions.FontBit(Chr(0xE851),17,Colors.LightGray,False)
	End If
	lvMenus.Clear
	
	'Add Menu to list
	lvMenus.AddTwoLinesAndBitmap2(csMenu1, $"Input Time On/Off, Flow Meter and PSI Reading"$, sIcon1, 1)
	lvMenus.AddTwoLinesAndBitmap2(csMenu2, $"Allow to Add Repair & Maintenance Entry"$, sIcon2, 2)
	lvMenus.AddTwoLinesAndBitmap2(csMenu3, $"Specify Date, Time & Reason for Pump non operational"$, sIcon3, 3)
	lvMenus.AddTwoLinesAndBitmap2(csMenu4, $"Allow to post JO findings"$, sIcon4, 4)
	lvMenus.AddTwoLinesAndBitmap2(csMenu5, $"Allow to Input Water Balance Entries"$, sIcon5, 5)
	lvMenus.AddTwoLinesAndBitmap2(csMenu6, $"Download/Upload Data from/to Database Server"$, sIcon6, 6)
	lvMenus.AddTwoLinesAndBitmap2(csMenu7, $"Allow to Set Current Reading Date"$, sIcon7, 7)
	lvMenus.AddTwoLinesAndBitmap2(csMenu8, $"Change User Name and/or User Password"$, sIcon8, 8)
	lvMenus.AddTwoLinesAndBitmap2($"Log Out "$ & GlobalVar.SF.Upper(GlobalVar.UserName),$"Log-out Session"$,MyFunctions.FontBit(Chr(0xF08B),17,GlobalVar.BlueColor,True), 9)
	lvMenus.AddTwoLinesAndBitmap2($"Close App"$,$"Close Pump Operation App"$,MyFunctions.FontBit(Chr(0xF2D4),17,GlobalVar.BlueColor,True), 10)

	lvMenus.TwoLinesAndBitmap.Label.TextColor = GlobalVar.BlueColor
	lvMenus.TwoLinesAndBitmap.Label.TextSize = 13
	lvMenus.TwoLinesAndBitmap.SecondLabel.TextSize = 8
	lvMenus.TwoLinesAndBitmap.SecondLabel.TextColor = 0xFF808080
	lvMenus.TwoLinesAndBitmap.SecondLabel.Typeface =fSecMenu
	lvMenus.TwoLinesAndBitmap.Label.Typeface = fMainMenu
	lvMenus.TwoLinesAndBitmap.ItemHeight = 50dip
End Sub

Sub lvMenus_ItemClick (Position As Int, Value As Object)
	LogColor(Value, Colors.Red)
	Select Case Value
		Case 1
'			If GlobalVar.Mod1 = 1 Then
'				If DBaseFunctions.IsThereBookAssignments(GlobalVar.BranchID, GlobalVar.BillYear, GlobalVar.BillMonth, GlobalVar.UserID) = False Then
'					snack.Initialize("",Activity,$"No Assigned book(s) for this Reader!"$,snack.DURATION_LONG)
'					myfunctions.SetSnackBarBackground(snack,Colors.Red)
'					myfunctions.SetSnackBarTextColor(snack,Colors.White)
'					snack.Show
'					Return
'				End If
'				StartActivity(ReadingBooks)
'			Else
'				Return
'			End If
		
		Case 2
'			If GlobalVar.Mod2 = 1 Then
'				StartActivity(CustomerList)
'				ProgressDialogShow2($"Loading Customer's Billing Data..."$, True)
'			Else
'				Return
'			End If
		
		Case 3
'			If GlobalVar.Mod3 = 1 Then
'				StartActivity(CMRVR)
'			Else
'				Return
'			End If

		Case 4
'			If GlobalVar.Mod4 = 1 Then
'				StartActivity(ReadingSettings)
'			Else
'				Return
'			End If
		
		Case 5
'			If GlobalVar.Mod5 = 1 Then
'				StartActivity(DataSyncing)
'			Else
'				Return
'			End If
		
		Case 6
'			If GlobalVar.Mod6 = 1 Then
'				StartActivity(UserAccountSettings)
'			Else
'				Return
'			End If
		
		Case 7
'			vibration.vibrateOnce(1000)
'			snack.Initialize("LogOFF", Activity, $"Sure to Log Off now?"$, snack.DURATION_SHORT)
'			myfunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'			myfunctions.SetSnackBarTextColor(snack, Colors.White)
'			snack.SetAction(csAns)
'			snack.Show
		
		Case 8
'			vibration.vibrateOnce(1000)
'			snack.Initialize("CloseButton", Activity, $"Close "$ & Application.LabelName & $"?"$,snack.DURATION_LONG)
'			snack.SetAction(csAns)
'			myfunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'			myfunctions.SetSnackBarTextColor(snack, Colors.White)
'			snack.Show

		Case 9
			vibration.vibrateOnce(1000)
			snack.Initialize("LogOFF", Activity, $"Sure to Log Off now?"$, snack.DURATION_SHORT)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			snack.SetAction(csAns)
			snack.Show
		
		Case 10
			vibration.vibrateOnce(1000)
			snack.Initialize("CloseButton", Activity, $"Close "$ & Application.LabelName & $"?"$,snack.DURATION_LONG)
			snack.SetAction(csAns)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			snack.Show
	End Select
	
	Dim CDBack As ColorDrawable
	CDBack.Initialize(Colors.Transparent,0)
	lvMenus.Background = CDBack
	Drawer.LeftOpen = False
End Sub

Private Sub LogOFF_Click()
	ClearUserData
	Activity.Finish
	StartActivity(Main)
End Sub

Private Sub CloseButton_Click()
	ExitApplication
End Sub

#End Region

#Region Badge Notifications

Sub AddBadgeToIcon(bmp As Bitmap, Number As Int) As Bitmap
	Dim cvs As Canvas
	Dim mbmp As Bitmap
	mbmp.InitializeMutable(32dip, 32dip)
	cvs.Initialize2(mbmp)
	Dim target As Rect
	target.Initialize(0, 0, mbmp.Width, mbmp.Height)
	cvs.DrawBitmap(bmp, Null, target)

	If Number > 0 Then
		cvs.DrawCircle(mbmp.Width - 8dip, 8dip, 8dip, GlobalVar.RedColor, True, 0)
		cvs.DrawText(Min(Number, 100), mbmp.Width - 8dip, 10dip, Typeface.DEFAULT_BOLD, 10, Colors.White, "CENTER")
	End If
	Return mbmp
End Sub

Sub UpdateBadge(MenuTitle As String, Icon As Bitmap)
	Dim m As ACMenuItem = GetMenuItem(MenuTitle)
	If m.IsInitialized = False Then
	End If
	m.Icon = BitmapToBitmapDrawable(Icon)
End Sub

Sub BitmapToBitmapDrawable (bitmap As Bitmap) As BitmapDrawable
	Dim bd As BitmapDrawable
	bd.Initialize(bitmap)
	Return bd
End Sub

Sub GetMenuItem(Title As String) As ACMenuItem
	For i = 0 To ToolBar.Menu.Size - 1
		Dim m As ACMenuItem = ToolBar.Menu.GetItem(i)
		If m.Title = Title Then
			Return m
		End If
	Next
	Return Null
End Sub

#End Region

#Region Welcome
Private Sub ShowWelcomeDialog()
	Dim theDate As Long
	Dim sTranDate As String

	theDate = DateTime.DateParse(DateTime.Date(DateTime.Now))
	DateTime.DateFormat = "MMM. dd, yyyy"
	sTranDate = DateTime.Date(theDate)

	Dim Alert As AX_CustomAlertDialog

	Alert.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(Alert.STYLE_DIALOGUE) _
			.SetCancelable(False) _
			.SetTitle($"W E L C O M E"$) _
			.SetMessage($"Welcome to BWSI's Operations App!"$ & CRLF & CRLF & $"Current Date is "$ &  sTranDate) _
			.SetPositiveText("OK") _
			.SetPositiveColor(GlobalVar.PosColor) _
			.SetPositiveTypeface(FontBold) _
			.SetNegativeText("SET DATE") _
			.SetNegativeColor(GlobalVar.NegColor) _
			.SetNegativeTypeface(Font) _
			.SetTitleTypeface(Font) _
			.SetMessageTypeface(Font) _
			.SetOnPositiveClicked("ShowDate") _	'listeners
			.SetOnNegativeClicked("ShowDate") _
			.SetOnViewBinder("FontSizeBinder") 'listeners
			
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

Private Sub ShowDate_OnNegativeClicked (View As View, Dialog As Object)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
	
	Dim lDate As Long
	Dim sDate As String
			
	DtDialog.Initialize(Activity, DateTime.Now)
	DateTime.DateFormat = "yyyy-MM-dd"
	theDate = DtDialog.Show($"Select New Transaction Date"$)
			
	If theDate = DialogResponse.POSITIVE Then
		sDate = DtDialog.DateSelected
'		lDate = DateTime.DateParse(sDate)
		GlobalVar.TranDate = DateTime.Date(sDate)
	Else
		theDate = DateTime.DateParse(DateTime.Date(DateTime.Now))
		DateTime.DateFormat = "yyyy-MM-dd"
		GlobalVar.TranDate = DateTime.Date(theDate)
	End If
	SaveTranDate
	lblTranDate.Text =$"TRANSACTION DATE: "$ & GlobalVar.TranDate
	snack.Initialize("",Activity,$"Selected Transaction Date is "$ & GlobalVar.TranDate, snack.DURATION_SHORT)
	MyFunctions.SetSnackBarBackground(snack,GlobalVar.GreenColor)
	MyFunctions.SetSnackBarTextColor(snack, Colors.White)
	snack.Show

End Sub

Private Sub ShowDate_OnPositiveClicked (View As View, Dialog As Object)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
	theDate = DateTime.DateParse(DateTime.Date(DateTime.Now))
	DateTime.DateFormat = "yyyy-MM-dd"
	GlobalVar.TranDate = DateTime.Date(theDate)
	lblTranDate.Text =$"TRANSACTION DATE: "$ & GlobalVar.TranDate

	If GlobalVar.UserPosID = 5 Then
		If DBaseFunctions.HasAssignment(GlobalVar.UserID) = True Then
			pnlPumpSelection.Visible = True
			ShowAssignedPump(GlobalVar.UserID)
		Else
			pnlPumpSelection.Visible = False
			MyToast.DefaultTextColor = Colors.White
			MyToast.pnl.Color = GlobalVar.RedColor
			MyFunctions.MyToastMsg(MyToast, $"You don't have any Pump Assignment!"$)
		End If
	End If
	SaveUserData

End Sub

Private Sub FontSizeBinder_OnBindView (View As View, ViewType As Int)
	Dim alert As AX_CustomAlertDialog
	alert.Initialize
	If ViewType = alert.VIEW_TITLE Then ' Title
		Dim lbl As Label = View
'		lbl.TextSize = 30
'		lbl.SetTextColorAnimated(2000,Colors.Magenta)
		
		
		Dim CS As CSBuilder
'		CS.Initialize.Typeface(Font).Append(lbl.Text & " ").Pop
'		CS.Typeface(Typeface.MATERIALICONS).Size(36).Color(Colors.Red).Append(Chr(0xE190))

		CS.Initialize.Typeface(Typeface.DEFAULT_BOLD).Typeface(Typeface.MATERIALICONS).Size(26).Color(GlobalVar.PriColor).Append(Chr(0xE88E) & "  ")
		CS.Typeface(Font).Size(22).Append(lbl.Text).Pop

		lbl.Text = CS.PopAll
	End If
	If ViewType = alert.VIEW_MESSAGE Then
		Dim lbl As Label = View
		lbl.TextSize = 17
		lbl.TextColor = Colors.Gray
	End If
End Sub

'Private Sub ShowDate_ButtonPressed(mDialog As MaterialDialog, sAction As String)
'	Select Case sAction
'		Case mDialog.ACTION_POSITIVE
'	
'			theDate = DateTime.DateParse(DateTime.Date(DateTime.Now))
'			DateTime.DateFormat = "MM/dd/yyyy"
'			GlobalVar.TranDate = DateTime.Date(theDate)
'			lblTranDate.Text =$"TRANSACTION DATE: "$ & GlobalVar.TranDate
'
'			If GlobalVar.UserPosID = 5 Then
'				If DBaseFunctions.HasAssignment(GlobalVar.UserID) = True Then
'					pnlPumpSelection.Visible = True
'					ShowAssignedPump(GlobalVar.UserID)
'				Else
'					pnlPumpSelection.Visible = False
'					MyToast.DefaultTextColor = Colors.White
'					MyToast.pnl.Color = GlobalVar.RedColor
'					MyFunctions.MyToastMsg(MyToast, $"You don't have any Pump Assignment!"$)
'				End If
'			End If
'		Case mDialog.ACTION_NEGATIVE
'		Case mDialog.ACTION_NEUTRAL
'			Dim lDate As Long
'			Dim sDate As String
'			
'			DtDialog.Initialize(Activity, DateTime.Now)
'			DateTime.DateFormat = "MM/dd/yyyy"
'			theDate = DtDialog.Show($"Select New Transaction Date"$)
'			
'			If theDate = DialogResponse.POSITIVE Then
'				sDate = DateTime.GetMonth(DtDialog.DateSelected) & "/" & DateTime.GetDayOfMonth(DtDialog.DateSelected) & "/" & DateTime.GetYear(DtDialog.DateSelected)
'				lDate = DateTime.DateParse(sDate)
'				GlobalVar.TranDate = DateTime.Date(lDate)
'			Else
'				theDate = DateTime.DateParse(DateTime.Date(DateTime.Now))
'				DateTime.DateFormat = "MM/dd/yyyy"
'				GlobalVar.TranDate = DateTime.Date(theDate)
'			End If
'			lblTranDate.Text =$"TRANSACTION DATE: "$ & GlobalVar.TranDate
'			snack.Initialize("",Activity,$"Selected Transaction Date is "$ & GlobalVar.TranDate, snack.DURATION_SHORT)
'			MyFunctions.SetSnackBarBackground(snack,GlobalVar.GreenColor)
'			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'			snack.Show
'	End Select
'End Sub
#End Region

#Region Repairs and Maintenance
Sub pnlRepair_Click
	If GlobalVar.UserPosID = 6 Then
		ShowRMJO
	Else
		vibration.vibrateOnce(1000)
		MyToast.DefaultTextColor = GlobalVar.RedColor
		MyToast.pnl.Color = Colors.White
		MyToast.Show($"You are Login as Pump Operator!"$ & CRLF & $"Login your Plumber Account first..."$)
	End If
End Sub

Private Sub ShowRMJO
	Dim rsJOCat As Cursor
	Dim csTitle As CSBuilder
	Dim JOReason As String
	Dim JOReasonList() As String
	Dim pCount As Int
	
	Try
		Starter.strCriteria = "SELECT * FROM constant_jo_reasons " & _
						  "WHERE cat_code = '" & "RM" & "' " & _
						  "ORDER BY id ASC"
							  
		LogColor(Starter.strCriteria, Colors.Blue)
		
		rsJOCat =  Starter.DBCon.ExecQuery (Starter.strCriteria)
		If rsJOCat.RowCount > 0 Then
			pCount = rsJOCat.RowCount
			Dim JOReasonList(pCount) As String
			
			For i = 0 To rsJOCat.RowCount - 1
				rsJOCat.Position = i
				JOReason = rsJOCat.GetString("reason_desc")
				JOReasonList(i) = JOReason
			Next
		Else
			snack.Initialize("", Activity, "No JO Reason found!",snack.DURATION_SHORT)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			snack.Show
			Return
		End If
	Catch
		snack.Initialize("", Activity, LastException,snack.DURATION_SHORT)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		snack.Show
		Return
	End Try


	csTitle.Initialize.Color(GlobalVar.PriColor).Bold.Size(16).Append($"SELECT Repair and Maintenance Category "$).PopAll
	MatDialogBuilder.Initialize("RMJO")
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Items(JOReasonList)
	MatDialogBuilder.PositiveText($"SELECT"$).PositiveColor(GlobalVar.PosColor)
	MatDialogBuilder.NegativeText($"CANCEL"$).NegativeColor(GlobalVar.NegColor)
	MatDialogBuilder.Cancelable(False)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.itemsCallbackSingleChoice(0)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.Show
End Sub

Private Sub RMJO_OnDismiss (Dialog As MaterialDialog)
	Log("Dialog dismissed")
End Sub

Private Sub RMJO_SingleChoiceItemSelected (Dialog As MaterialDialog, Position As Int, Text As String)
	GlobalVar.SelectedJOReason = Text
End Sub
	
Private Sub RMJO_ButtonPressed (mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			LogColor(GlobalVar.SelectedJOReason, Colors.Red)
			
			Select Case GlobalVar.SelectedJOReason
				Case "Drain from Mainline"
				Case "Pump Drain"
				Case "Inter-Connection"
				Case "Replace Gate Valve"
				Case "Hydrotest"
				Case "Leak Repair"
				Case "Busted Mainline"
				Case "Busted Pipe"
				Case "Replace Chlorinator Diagphram"
				Case "Replace Chlorinator"
				Case "Replace Chlorinator Hose"
			End Select
			LogColor(GlobalVar.SelectedJOReason, Colors.Yellow)

		Case mDialog.ACTION_NEGATIVE
	End Select
End Sub

'Private Sub ShowPumpAreas ()
'	Dim rsAreas As Cursor
'	Dim csTitle As CSBuilder
'	Dim Areas As String
'	Dim AreaList() As String
'	Dim pCount As Int
'	
'	Try
'		Starter.strCriteria = "SELECT * FROM PumpAreas " & _
'						  "ORDER BY PumpAreas.ID ASC"
'							  
'		LogColor(Starter.strCriteria, Colors.Blue)
'		
'		rsAreas =  Starter.DBCon.ExecQuery (Starter.strCriteria)
'		If rsAreas.RowCount > 0 Then
'			pCount = rsAreas.RowCount
'			Dim AreaList(pCount) As String
'			
'			For i = 0 To rsAreas.RowCount - 1
'				rsAreas.Position = i
'				Areas = rsAreas.GetString("PumpArea")
'				AreaList(i) = Areas
'			Next
'		Else
'			snack.Initialize("", Activity, "No Pump Area found!",snack.DURATION_SHORT)
'			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'			snack.Show
'			Return
'		End If
'	Catch
'		snack.Initialize("", Activity, LastException,snack.DURATION_SHORT)
'		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'		snack.Show
'		Return
'	End Try
'	
'	csTitle.Initialize.Color(GlobalVar.PriColor).Bold.Size(16).Append($"SELECT AREA OF CONCERN"$).PopAll
'	MatDialogBuilder.Initialize("RepMain")
'	MatDialogBuilder.Title(csTitle)
'	MatDialogBuilder.Items(AreaList)
'	MatDialogBuilder.PositiveText($"SELECT"$).PositiveColor(GlobalVar.PosColor)
'	MatDialogBuilder.NegativeText($"CANCEL"$).NegativeColor(GlobalVar.NegColor)
'	MatDialogBuilder.Cancelable(False)
'	MatDialogBuilder.CanceledOnTouchOutside(False)
'	MatDialogBuilder.itemsCallbackSingleChoice(0)
'	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
'	MatDialogBuilder.Show
'End Sub
'
'Private Sub RepMain_OnDismiss (Dialog As MaterialDialog)
'	Log("Dialog dismissed")
'End Sub
'
'Private Sub RepMain_SingleChoiceItemSelected (Dialog As MaterialDialog, Position As Int, Text As String)
'	GlobalVar.RepMainDesc = Text
'End Sub
'	
'Private Sub RepMain_ButtonPressed (mDialog As MaterialDialog, sAction As String)
'	Select Case sAction
'		Case mDialog.ACTION_POSITIVE
'			GlobalVar.RepMainID = DBaseFunctions.GetIDByCode("ID", "PumpAreas", "PumpArea", GlobalVar.RepMainDesc)
'			LogColor(GlobalVar.RepMainDesc & " - " & GlobalVar.RepMainID, Colors.Red)
'			Select Case GlobalVar.RepMainID
'				Case 1 'Pump and Motors
'					StartActivity(actRepMain)
'				Case 2 'Control Panel
'				Case 3 'Panel Board
'				Case 4 'VFD
'				Case 5 'Meter Set Assembly
'				Case 6 'Flow Meter
'				Case 7 'Pressure Gauge
'				Case 8 'Electricals
'				Case 9 'Chlorinator
'				Case 10 'GenSet
'				Case 11 'Service Vehicle
'				Case 12 'Bridge Interconnection
'				Case 13 'Others
'			End Select
'		Case mDialog.ACTION_NEGATIVE
'	End Select
'End Sub

#End Region

#Region Production
Sub pnlProd_Click
'	ShowPumpList(GlobalVar.UserID)
	If GlobalVar.UserPosID = 5 Then
		StartActivity(actNewProduction)
	Else
		vibration.vibrateOnce(1000)
		MyToast.DefaultTextColor = GlobalVar.RedColor
		MyToast.pnl.Color = Colors.White
		MyToast.Show($"You are Login as Plumber!"$ & CRLF & $"Login your Pump Operator Account first..."$)
	End If
End Sub

Private Sub ShowPumpList (iUserID As Double)
	Dim rsPumps As Cursor
	Dim csTitle As CSBuilder
	Dim Pumps As String
	Dim PumpList() As String
	Dim pCount As Int
	
	Try
		Starter.strCriteria = "SELECT Assignment.StationID, PumpStation.PumpHouseCode " & _
							  "FROM tblAssignedStation AS Assignment " & _
							  "INNER JOIN tblPumpStation AS PumpStation ON Assignment.StationID = PumpStation.StationID " & _
							  "WHERE Assignment.OpID = " & iUserID & " " & _
							  "ORDER BY PumpStation.StationID ASC		"
							  
		LogColor(Starter.strCriteria, Colors.Blue)
		
		rsPumps =  Starter.DBCon.ExecQuery (Starter.strCriteria)
		If rsPumps.RowCount > 0 Then
			pCount = rsPumps.RowCount
			Dim PumpList(pCount) As String
			
			For i = 0 To rsPumps.RowCount - 1
				rsPumps.Position = i
				Pumps = rsPumps.GetString("PumpHouseCode")
				PumpList(i) = Pumps
			Next
		Else
			snack.Initialize("", Activity, "No Assigned Pump(s) found!",snack.DURATION_SHORT)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			snack.Show
			Return
		End If
	Catch
		snack.Initialize("", Activity, LastException,snack.DURATION_SHORT)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		snack.Show
		Return
	End Try
	
	csTitle.Initialize.Color(GlobalVar.PriColor).Bold.Size(16).Append($"SELECT A PUMP"$).PopAll
	MatDialogBuilder.Initialize("SelectedPump")
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Items(PumpList)
	MatDialogBuilder.PositiveText($"SELECT"$).PositiveColor(GlobalVar.PosColor)
	MatDialogBuilder.NegativeText($"CANCEL"$).NegativeColor(GlobalVar.NegColor)
	MatDialogBuilder.Cancelable(False)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.itemsCallbackSingleChoice(0)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.Show
End Sub

Private Sub SelectedPump_OnDismiss (Dialog As MaterialDialog)
	Log("Dialog dismissed")
End Sub

Private Sub SelectedPump_SingleChoiceItemSelected (Dialog As MaterialDialog, Position As Int, Text As String)
	snack.Initialize("", Activity, $"Pump Selected : "$ & Text,snack.DURATION_SHORT)
	MyFunctions.SetSnackBarBackground(snack, GlobalVar.PriColor)
	MyFunctions.SetSnackBarTextColor(snack, Colors.White)
	snack.Show
	GlobalVar.PumpHouseCode = Text
'	MyFunctions.MyToastMsg(MyToast, $"Selected Pump: "$ & GlobalVar.PumpHouseCode, GlobalVar.GreenColor, Colors.White)
	GlobalVar.PumpHouseID = DBaseFunctions.GetPumpHouseID(GlobalVar.PumpHouseCode)
End Sub

Private Sub SelectedPump_ButtonPressed (mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			LogColor(GlobalVar.PumpHouseID, Colors.Blue)
			StartActivity(actProduction)
		Case mDialog.ACTION_NEGATIVE
			Return
	End Select
End Sub
#End Region

Sub pnlNonOp_Click
	If GlobalVar.UserPosID = 5 Then
		StartActivity(actNonOperational)
	Else
		vibration.vibrateOnce(1000)
		MyToast.DefaultTextColor = GlobalVar.RedColor
		MyToast.pnl.Color = Colors.White
		MyToast.Show($"You are Login as Plumber!"$ & CRLF & $"Login your Pump Operator Account first..."$)
	End If
End Sub

#Region JOs
Sub pnlJO_Click
	If GlobalVar.UserPosID = 6 Then
'		ShowJOCat
		StartActivity(actJOSummary)
	Else
		vibration.vibrateOnce(1000)
		MyToast.DefaultTextColor = GlobalVar.RedColor
		MyToast.pnl.Color = Colors.White
		MyToast.Show($"You are Login as Pump Operator!"$ & CRLF & $"Login your Plumber Account first..."$)
	End If
End Sub

Private Sub ShowJOCat
	Dim rsJOCat As Cursor
	Dim csTitle As CSBuilder
	Dim JODesc As String
	Dim JODescList() As String
	Dim pCount As Int
	
	Try
		Starter.strCriteria = "SELECT * FROM constant_jo_categories WHERE jo_code <> '" & "RM" & "' " & _
						  "AND jo_code <> '" & "CAC" & "' " & _
						  "ORDER BY id ASC"
							  
		LogColor(Starter.strCriteria, Colors.Blue)
		
		rsJOCat =  Starter.DBCon.ExecQuery (Starter.strCriteria)
		If rsJOCat.RowCount > 0 Then
			pCount = rsJOCat.RowCount
			Dim JODescList(pCount) As String
			
			For i = 0 To rsJOCat.RowCount - 1
				rsJOCat.Position = i
				JODesc = rsJOCat.GetString("jo_desc")
				JODescList(i) = JODesc
			Next
		Else
			snack.Initialize("", Activity, "No List of Job Order found!",snack.DURATION_SHORT)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			snack.Show
			Return
		End If
	Catch
		snack.Initialize("", Activity, LastException,snack.DURATION_SHORT)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		snack.Show
		Return
	End Try


	csTitle.Initialize.Color(GlobalVar.PriColor).Bold.Size(16).Append($"SELECT J.O. Category "$).PopAll
	MatDialogBuilder.Initialize("JOCat")
	MatDialogBuilder.Title(csTitle)
'	MatDialogBuilder.Items(Array As String($"Service Application Survey"$, $"New Connection"$, $"Metering Concerns"$, $"Change Meter"$, $"Disconnection - Delinquent Account"$, $"Disconnection - Customer Request"$, $"Reconnection"$, $"Service Level"$, $"Illegal Connection"$, $"Others"$))
	MatDialogBuilder.Items(JODescList)
	MatDialogBuilder.PositiveText($"SELECT"$).PositiveColor(GlobalVar.PosColor)
	MatDialogBuilder.NegativeText($"CANCEL"$).NegativeColor(GlobalVar.NegColor)
	MatDialogBuilder.Cancelable(False)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.itemsCallbackSingleChoice(0)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.Show
End Sub

Private Sub JOCat_OnDismiss (Dialog As MaterialDialog)
	Log("Dialog dismissed")
End Sub

Private Sub JOCat_SingleChoiceItemSelected (Dialog As MaterialDialog, Position As Int, Text As String)
	GlobalVar.SelectedJOCat = Position
	GlobalVar.SelectedJOCatCode = Text
	LogColor($"JO Category: "$ & Position & CRLF & $"JO Cat Code: "$ & Text, Colors.Magenta)
End Sub
	
Private Sub JOCat_ButtonPressed (mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			LogColor(GlobalVar.SelectedJOCat, Colors.Red)
			Select Case GlobalVar.SelectedJOCat
				Case 0 'Service Application Survey
					GlobalVar.SelectedJOCatCode = "SAS"
					JOWithType = 0
				
				Case 1 'New Connection
					GlobalVar.SelectedJOCatCode = "NC"
					JOWithType = 0
				
				Case 2 'Disconnection - Customer Request
					GlobalVar.SelectedJOCatCode = "DC-CR"
					JOWithType = 0
		
				Case 3 'Disconnection - Delinquent Account
					GlobalVar.SelectedJOCatCode = "DC-DA"
					JOWithType = 0
				
				Case 4 'Reconnection
					GlobalVar.SelectedJOCatCode = "RC"
					JOWithType = 0
				
				Case 5 'Change Meter
					GlobalVar.SelectedJOCatCode = "CM"
					JOWithType = 0
				
				Case 6 'Metering Concerns
					GlobalVar.SelectedJOCatCode = "MC"
					JOWithType = 1
				
				Case 7 'Repairs and Maintenance
					GlobalVar.SelectedJOCatCode = "RM"
					JOWithType = 1
				
				Case 8 'Illegal Connection
					GlobalVar.SelectedJOCatCode = "IC"
					JOWithType = 1
				
				Case 9 'Service Level
					GlobalVar.SelectedJOCatCode = "SL"
					JOWithType = 1
				
				Case 10 'Survey
					GlobalVar.SelectedJOCatCode = "SV"
					JOWithType = 1
				
				Case 11 'Others
					GlobalVar.SelectedJOCatCode = "OT"
					JOWithType = 0
				
				Case 12 'Change Account Classification
					GlobalVar.SelectedJOCatCode = "CAC"
					JOWithType = 0

			End Select
		
			If JOWithType = 0 Then
				StartActivity(actJO)
				mDialog.Dismiss
			Else
				mDialog.Dismiss
				ShowJOReasons(GlobalVar.SelectedJOCatCode)
			End If
			
			LogColor(GlobalVar.SelectedJOCatCode, Colors.Yellow)
		Case mDialog.ACTION_NEGATIVE
	End Select
End Sub

'///////////////////////////////////////////
Private Sub ShowJOReasons (sJOCatCode As String)
	Dim rsJOCat As Cursor
	Dim csTitle As CSBuilder
	Dim JOReason As String
	Dim JOReasonList() As String
	Dim pCount As Int
	
	Try
		Starter.strCriteria = "SELECT * FROM constant_jo_reasons " & _
						  "WHERE cat_code = '" & sJOCatCode & "' " & _
						  "ORDER BY id ASC"
							  
		LogColor(Starter.strCriteria, Colors.Blue)
		
		rsJOCat =  Starter.DBCon.ExecQuery (Starter.strCriteria)
		If rsJOCat.RowCount > 0 Then
			pCount = rsJOCat.RowCount
			Dim JOReasonList(pCount) As String
			
			For i = 0 To rsJOCat.RowCount - 1
				rsJOCat.Position = i
				JOReason = rsJOCat.GetString("reason_desc")
				JOReasonList(i) = JOReason
			Next
		Else
			snack.Initialize("", Activity, "No JO Reason found!",snack.DURATION_SHORT)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			snack.Show
			Return
		End If
	Catch
		snack.Initialize("", Activity, LastException,snack.DURATION_SHORT)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		snack.Show
		Return
	End Try


	csTitle.Initialize.Color(GlobalVar.PriColor).Bold.Size(16).Append($"SELECT J.O. Sub Category "$).PopAll
	MatDialogBuilder.Initialize("JOReason")
	MatDialogBuilder.Title(csTitle)
'	MatDialogBuilder.Items(Array As String($"Service Application Survey"$, $"New Connection"$, $"Metering Concerns"$, $"Change Meter"$, $"Disconnection - Delinquent Account"$, $"Disconnection - Customer Request"$, $"Reconnection"$, $"Service Level"$, $"Illegal Connection"$, $"Others"$))
	MatDialogBuilder.Items(JOReasonList)
	MatDialogBuilder.PositiveText($"SELECT"$).PositiveColor(GlobalVar.PosColor)
	MatDialogBuilder.NegativeText($"CANCEL"$).NegativeColor(GlobalVar.NegColor)
	MatDialogBuilder.Cancelable(False)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.itemsCallbackSingleChoice(0)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.Show
End Sub

Private Sub JOReason_OnDismiss (Dialog As MaterialDialog)
	Log("Dialog dismissed")
End Sub

Private Sub JOReason_SingleChoiceItemSelected (Dialog As MaterialDialog, Position As Int, Text As String)
	GlobalVar.SelectedJOCat = Position
	GlobalVar.SelectedJOCatCode = Text
	LogColor($"JO Category: "$ & Position & CRLF & $"JO Cat Code: "$ & Text, Colors.Magenta)
End Sub
	
Private Sub JOReason_ButtonPressed (mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			LogColor(GlobalVar.SelectedJOCat, Colors.Red)
			
			Select Case GlobalVar.SelectedJOCat
				Case 0 'Service Application Survey
					GlobalVar.SelectedJOCatCode = "SAS"
					StartActivity(actJO)
					LogColor(GlobalVar.SelectedJOCatCode, Colors.Yellow)
				
				Case 1 'New Connection
					GlobalVar.SelectedJOCatCode = "NC"
					StartActivity(actJO)
					LogColor(GlobalVar.SelectedJOCatCode, Colors.Yellow)
				
				Case 2 'Disconnection - Customer Request
					GlobalVar.SelectedJOCatCode = "DC-CR"
					StartActivity(actJO)
					LogColor(GlobalVar.SelectedJOCatCode, Colors.Yellow)
				
				Case 3 'Disconnection - Delinquent Account
					GlobalVar.SelectedJOCatCode = "DC-DA"
					StartActivity(actJO)
					LogColor(GlobalVar.SelectedJOCatCode, Colors.Yellow)
				
				Case 4 'Reconnection
					GlobalVar.SelectedJOCatCode = "RC"
					StartActivity(actJO)
					LogColor(GlobalVar.SelectedJOCatCode, Colors.Yellow)
				
				Case 5 'Change Meter
					GlobalVar.SelectedJOCatCode = "CM"
					StartActivity(actJO)
					LogColor(GlobalVar.SelectedJOCatCode, Colors.Yellow)
				
				Case 6 'Metering Concerns
					GlobalVar.SelectedJOCatCode = "MC"
					ShowJOReasons("MC")
					LogColor(GlobalVar.SelectedJOCatCode, Colors.Yellow)
				
				Case 7 'Repairs and Maintenance
					GlobalVar.SelectedJOCatCode = "RM"
				
				Case 8 'Illegal Connection
					GlobalVar.SelectedJOCatCode = "IC"
				
				Case 9 'Service Level
					GlobalVar.SelectedJOCatCode = "SL"
				
				Case 10 'Survey
					GlobalVar.SelectedJOCatCode = "SV"
				
				Case 11 'Others
					GlobalVar.SelectedJOCatCode = "OT"
				
				Case 12 'Change Account Classification
					GlobalVar.SelectedJOCatCode = "CAC"

			End Select
			
			Case mDialog.ACTION_NEGATIVE
	End Select
End Sub

#End Region

#Region Critical Point
Sub pnlCPM_Click
	If GlobalVar.UserPosID = 5 Then
		StartActivity(actCriticalPoint)
'	ShowWaterBalance
	Else
		vibration.vibrateOnce(1000)
		MyToast.DefaultTextColor = GlobalVar.RedColor
		MyToast.pnl.Color = Colors.White
		MyToast.Show($"You are Login as Plumber!"$ & CRLF & $"Login your Pump Operator Account first..."$)
	End If
End Sub

#End Region

#Region GPM

Sub pnlGPM_Click
	If GlobalVar.UserPosID = 5 Then
		GlobalVar.blnNewGPM = True
		StartActivity(actGPMCalc)
	Else
		vibration.vibrateOnce(1000)
		MyToast.DefaultTextColor = GlobalVar.RedColor
		MyToast.pnl.Color = Colors.White
		MyToast.Show($"You are Login as Plumber!"$ & CRLF & $"Login your Pump Operator Account first..."$)
	End If
End Sub

#End Region

Private Sub GetPumpInfo (iPumpStationID As Int)
	Dim rsPumpInfo As Cursor
	Try
		Starter.strCriteria = "SELECT Station.PumpHouseCode, Station.PumpLocation, " & _
							  "Station.PumpHouseID, Station.FMID, Station.FMNo, Station.LastRdg " & _
							  "FROM tblPumpStation AS Station " & _
							  "WHERE Station.StationID = " & iPumpStationID
		rsPumpInfo = Starter.DBCon.ExecQuery(Starter.strCriteria)
		
		If rsPumpInfo.RowCount > 0 Then
			rsPumpInfo.Position = 0
			
		End If
	Catch
		Log(LastException)
	End Try
End Sub

Sub pnlPumpSelection_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Sub clvPumpList_ItemClick (Index As Int, Value As Object)
	Dim Rec As PumpAssigned = Value
	Log(Rec.PumpID)
	GlobalVar.PumpHouseID = Rec.PumpID
	GlobalVar.PumpHouseCode = Rec.PumpCode
	
	GlobalVar.PumpDrainPipeType = DBaseFunctions.GetDrainPipeType(Rec.PumpID)
	GlobalVar.PumpDrainPipeSize = DBaseFunctions.GetDrainPipeSize(Rec.PumpID)
	
	pnlPumpSelection.Visible = False
	MyToast.DefaultTextColor = Colors.White
	MyToast.pnl.Color = GlobalVar.BlueColor
	MyFunctions.MyToastMsg(MyToast, $"Selected Pump: "$ & GlobalVar.PumpHouseCode)
End Sub

Sub clvPumpList_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 15 'List size
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvPumpList.Size - 1)
		Dim Pnl As B4XView = clvPumpList.GetPanel(i)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
				Dim PA As PumpAssigned = clvPumpList.GetValue(i)
				Pnl.LoadLayout("PumpList")
				lblPumpCode.TextColor = GlobalVar.BlueColor
				lblPumpLoc.TextColor = Colors.Gray
				lblPumpCode.Text = $"PUMP - "$ & PA.PumpCode
				lblPumpLoc.Text  = PA.PumpLoc
			End If
		Else 'Not visible
			If Pnl.NumberOfViews > 0 Then
				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
			End If
		End If
	Next
End Sub

Private Sub ShowAssignedPump(iUserID As Int)
	Dim SenderFilter As Object
	clvPumpList.Clear
	Try
		Starter.strCriteria = "SELECT Assignment.AssignedID, " & _
							  "Assignment.StationID, Station.PumpHouseCode, Station.PumpLocation " & _
							  "FROM tblAssignedStation AS Assignment " & _
							  "INNER JOIN tblPumpStation AS Station ON Assignment.StationID = Station.StationID " & _
							  "WHERE Assignment.OpID = " & iUserID & " " & _
							  "ORDER BY Station.PumpID ASC"
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			Dim StartTime As Long = DateTime.Now
			Do While RS.NextRow
				Dim PA As PumpAssigned
				PA.Initialize
				PA.PumpID = RS.GetInt("StationID")
				PA.PumpCode = RS.GetString("PumpHouseCode")
				PA.PumpLoc = RS.GetString("PumpLocation")

				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 10dip, 0dip, clvPumpList.AsView.Width - 10dip, 50dip) 'Panel height + 4 for drop shadow
				clvPumpList.Add(Pnl, PA)
			Loop
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If

		Log($"List of Time Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvPumpList.Size} Time Records"$)

	Catch
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
	Log(LastException)
End Try

End Sub


Sub btnCancel_Click
	pnlPumpSelection.Visible = False
End Sub

Private Sub SetDashboardIcons
	If GlobalVar.UserPosID = 5 Then
		pnlProd.Enabled = True
		img1.Bitmap = LoadBitmap(File.DirAssets,"production.png")
	Else If GlobalVar.UserPosID = 6 Then
		pnlProd.Enabled = False
		pnlProd.Color = Colors.LightGray
		img1.Bitmap = LoadBitmap(File.DirAssets,"prod-disable.png")
	Else
	End If
'	ImageView1.Bitmap = LoadBitmap(File.DirAssets, "someimage.jpg")
End Sub

Public Sub ShowResolutionDialog (SettingsStatus As LocationSettingsStatus) As ResumableSub
	SettingsStatus.StartResolutionDialog("srd")
	Wait For srd_ResolutionDialogDismissed(LocationSettingsUpdated As Boolean)
	Return LocationSettingsUpdated
End Sub

#Region Notifications
Private Sub Timer1_Tick
	If NotifyCountJO = True Then
		UpdateBadge("Notif", AddBadgeToIcon(NotifBMP, iJOUnreadCount))
	End If
End Sub

Private Sub NotifyCountJO As Boolean
	Dim bRetVal As Boolean
	
	bRetVal = False
	iJOUnreadCount = 0
	
	Try
		iJOUnreadCount = Starter.DBCon.ExecQuerySingleResult("SELECT COUNT(JOID) FROM tblJOs WHERE WasRead = 0 AND JOStatus = 1")
		bRetVal = True
	Catch
		iJOUnreadCount = 0
		bRetVal = False
		ToastMessageShow($"Unable to count JO due to "$ & LastException.Message, False)
		Log(LastException)
	End Try
	Return bRetVal
End Sub
#End Region

Private Sub SaveUserData
	Dim UserData As Map
	UserData.Initialize
	UserData.Put("UserID", GlobalVar.UserID)
	UserData.Put("UserName", GlobalVar.UserName)

	UserData.Put("UserPassword", GlobalVar.UserPW)
	UserData.Put("EmpName", GlobalVar.EmpName)
	UserData.Put("UserAvatar", GlobalVar.UserAvatar)
	
	UserData.Put("BranchID",GlobalVar.BranchID)
	UserData.Put("BranchCode", GlobalVar.BranchCode)
	UserData.Put("BranchName", GlobalVar.BranchName)
	
	UserData.Put("UserPosID", GlobalVar.UserPosID)
	UserData.Put("UserPosition", GlobalVar.UserPos)

	UserData.Put("SysMode", GlobalVar.SysMode)
	
	KVS.Put("user_data",UserData)
End Sub

Private Sub SaveTranDate
	
	Dim TransDate As Map
	TransDate.Initialize
	TransDate.Put("TransDate", GlobalVar.TranDate)
	
	KVS.Put("trans_date",TransDate)
End Sub

Private Sub ClearUserData
	KVS.Remove("user_data")
End Sub

Private Sub RemoveTranDate
	KVS.Remove("trans_date")
End Sub