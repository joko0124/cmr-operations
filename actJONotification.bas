B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=10
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
End Sub

Sub Globals
	Dim ActionBarButton As ACActionBar
	Private ToolBar As ACToolBarDark
	Private xmlIcon As XmlLayoutBuilder
	Private MatDialogBuilder As MaterialDialogBuilder
	
	Private snack As DSSnackbar
	Private csAns As CSBuilder

	Private clvJOs As CustomListView
	Private pnlJOInfo As Panel
	
	Dim cdSearch As ColorDrawable
	Private txtSearch As EditText
	Private PopSubMenu As ACPopupMenu
	Type JOs (JOID As Int, JONum As String, JOCategory As String, JOCatCode As String, JOStatus As Int, RefID As Int, RefNo As String, _
			CustName As String, CustAdd As String, AcctClass As String, AcctSubClass As String, iWasRead As Int, sJODate As String)
	
	Private JOCounts As Int
	Private Limit As Int = 2000
	Private IMEKeyboard As IME

	Private pnlStatus As Panel
	Private lblCount As Label
	
	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")

	
	'DialogButtons
	Dim Alert As AX_CustomAlertDialog
	
	Private lblCustomer As Label
	Private lblDate As Label
	Private lblJONum As Label

End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("JONotification")
	GlobalVar.SelectedJODesc = DBaseFunctions.GetJODesc(GlobalVar.SelectedJOCatCode)
	
	GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"Job Order Notifications"$).PopAll
	GlobalVar.CSSubTitle.Initialize.Size(12).Append($"List of Job Orders"$).PopAll
	
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
	
	cdSearch.Initialize(Colors.Transparent, 0)
	txtSearch.Background = cdSearch

	If FirstTime Then
		FillJOList
	End If
	
End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	If KeyCode = 4 Then
		ToolBar_NavigationItemClick
		Return True
	Else
		Return False
	End If
End Sub

Sub Activity_Resume
	FillJOList
End Sub



Sub Activity_Pause (UserClosed As Boolean)
End Sub

#End Region

#Region Toolbar
Sub Activity_CreateMenu(Menu As ACMenu)
	Dim Item As ACMenuItem
	
	Menu.Clear
	Menu.Add2(1, 1, "Filter by",xmlIcon.GetDrawable("baseline_filter_alt_white_24dp")).ShowAsAction = Item.SHOW_AS_ACTION_IF_ROOM
	CreateSubMenus
End Sub

Private Sub CreateSubMenus
	Dim csAll, csUnread, csRead As CSBuilder
	
	csAll.Initialize.Color(Colors.White).Append($"All"$).PopAll
	csUnread.Initialize.Color(Colors.White).Append($"Unread"$).PopAll
	csRead.Initialize.Color(Colors.White).Append($"Read"$).PopAll
	
	PopSubMenu.Initialize("FilterBy", ToolBar.GetView(3))
	PopSubMenu.AddMenuItem(0,csAll,xmlIcon.GetDrawable("ic_select_all_white_24dp"))
	PopSubMenu.AddMenuItem(1,csUnread,xmlIcon.GetDrawable("baseline_mark_email_unread_white_24dp"))
	PopSubMenu.AddMenuItem(2,csRead,xmlIcon.GetDrawable("baseline_mark_email_read_white_24dp"))
End Sub

Sub ToolBar_NavigationItemClick 'Toolbar Arrow
	IMEKeyboard.HideKeyboard
	Activity.Finish
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
	Select Item.Id
		Case 1
			PopSubMenu.Show
	End Select
End Sub

Sub FilterBy_ItemClicked (Item As ACMenuItem)
	Log("Popupmenu Item clicked: " & Item.Id & " - " & Item.Title)
	FilterJoList(Item.Id)
End Sub

#End Region

#Region JO Lists
Private Sub FillJOList 
	Dim SenderFilter As Object
	Dim sDateJO, sTimeJO As String
	Dim iHour, iMin As Int
	Dim amPm As String
	Dim Matcher1 As Matcher
	Try
		Starter.strCriteria = "SELECT * FROM tblJOs " & _
						  "WHERE WasUploaded = '" & 0 & "' " & _
						  "ORDER BY substr (JOAssignedAt,1,4) || ' ' || substr(JOAssignedAt,6,2) || ' ' || substr(JOAssignedAt,9,2) || ' ' || substr(JOAssignedAt,18,2) || ' ' || (Case WHEN substr(JOAssignedAt,12,2) = '12' AND substr(JOAssignedAt,18,2) = 'AM' THEN '00' ELSE substr(JOAssignedAt,12,2) END) || ' ' || substr(JOAssignedAt,15,2) DESC"
		LogColor(Starter.strCriteria, Colors.Yellow)

		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		If Success Then
			Dim StartTime As Long = DateTime.Now
			clvJOs.Clear
			Do While RS.NextRow
				Dim JOInfo As JOs
				JOInfo.Initialize
				JOInfo.JOID = RS.GetInt("JOID")
				JOInfo.JONum = GlobalVar.SF.Upper(RS.GetString("JONo"))
				JOInfo.JOCatCode = GlobalVar.SF.Upper(RS.GetString("JOCatCode"))
				JOInfo.JOCategory = GlobalVar.SF.Upper(RS.GetString("JoDesc"))
				JOInfo.RefID= RS.GetInt("RefID")
				JOInfo.RefNo= GlobalVar.SF.Upper(RS.GetString("RefNo"))
				JOInfo.CustName = GlobalVar.SF.Upper(RS.GetString("CustName"))
				JOInfo.CustAdd = GlobalVar.SF.Upper(RS.GetString("CustAddress"))
				JOInfo.AcctClass = GlobalVar.SF.Upper(RS.GetString("AcctClass"))
				JOInfo.AcctSubClass = GlobalVar.SF.Upper(RS.GetString("AcctSubClass"))
				JOInfo.JOStatus = RS.GetInt("JOStatus")
				JOInfo.iWasRead = RS.GetInt("WasRead")
				sDateJO = GlobalVar.SF.Left(RS.GetString("JOAssignedAt"),10)
				iHour = GlobalVar.SF.Val(GlobalVar.SF.Mid(RS.GetString("JOAssignedAt"),12,2))
				iMin = GlobalVar.SF.Val(GlobalVar.SF.Mid(RS.GetString("JOAssignedAt"),15,2))
				amPm =  GlobalVar.SF.Right(RS.GetString("JOAssignedAt"),2)
				Log(sDateJO)
					If amPm = "PM" And iHour <> 12 Then
						iHour = iHour + 12
					End If

					If amPm = "AM" And iHour = 12 Then
						iHour = 0
					End If
					
					If GlobalVar.SF.Len(iHour) = 1 Then
						If GlobalVar.SF.Len(iMin) = 1 Then
							sTimeJO = "0" & iHour & ":0" & iMin & ":00"
						Else
							sTimeJO = "0" & iHour & ":" & iMin & ":00"
						End If
					Else
						If GlobalVar.SF.Len(iMin) = 1 Then
							sTimeJO = iHour & ":0" & iMin & ":00"
						Else
							sTimeJO = iHour & ":" & iMin & ":00"
						End If
					End If
					Log(sTimeJO)
				DateTime.TimeFormat = "HH:mm:ss"
				LogColor(JOInfo.CustName, Colors.Cyan)
				If DaysBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) > 1 Then
					JOInfo.sJODate = DaysBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) & $" days ago"$
				Else If DaysBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) = 1 Then
					JOInfo.sJODate = DaysBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) & $" day ago"$
				Else if DaysBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) <= 0 Then
					LogColor (HoursBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)),Colors.Yellow)
					If HoursBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) > 1 Then
						JOInfo.sJODate = HoursBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) & $" hours ago"$
					Else If HoursBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) = 1 Then
						JOInfo.sJODate = HoursBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) & $" hour ago"$
					Else If HoursBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) <= 0 Then
						If MinBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) > 1 Then
							JOInfo.sJODate = MinBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) & $" mins. ago"$
						Else If MinBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) = 1 Then
							JOInfo.sJODate = MinBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) & $" min. ago"$
						Else If MinBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) <= 0 Then
							JOInfo.sJODate = "Just Now"
						End If
					End If
				End If
				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 5dip, 0, clvJOs.AsView.Width, 60dip) 'Panel height + 4 for drop shadow
				clvJOs.Add(Pnl, JOInfo)
			Loop
			lblCount.Text = RS.RowCount & $" Record(s) Found"$
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If

		Log($"List of Job Order Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvJOs.Size} Job Order Records"$)
	Catch
		Log(LastException)
	End Try

End Sub

Private Sub FilterJoList (iStatus As Int)
	Dim SenderFilter As Object
	Dim sDateJO, sTimeJO As String
	Dim iHour, iMin As Int
	Dim amPm As String
	Dim Matcher1 As Matcher

	clvJOs.Clear
	If iStatus = 0 Then
		Starter.strCriteria = "SELECT * FROM tblJOs " & _
						  "WHERE WasUploaded = '" & 0 & "' " & _
						  "ORDER BY JOAssignedAt DESC"
	Else If iStatus = 1 Then
		Starter.strCriteria = "SELECT * FROM tblJOs " & _
						  "WHERE WasUploaded = '" & 0 & "' " & _
						  "AND WasRead = '" & 0 & "' " & _
						  "ORDER BY JOAssignedAt DESC"
		
	Else If iStatus = 2 Then
		Starter.strCriteria = "SELECT * FROM tblJOs " & _
						  "WHERE WasUploaded = '" & 0 & "' " & _
						  "AND WasRead = '" & 1 & "' " & _
						  "ORDER BY JOAssignedAt DESC"
	Else
		Return
	End If
	LogColor(Starter.strCriteria, Colors.Magenta)

	Try
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		If Success Then
			Dim StartTime As Long = DateTime.Now
			clvJOs.Clear
			Do While RS.NextRow
				Dim JOInfo As JOs
				JOInfo.Initialize
				JOInfo.JOID = RS.GetInt("JOID")
				JOInfo.JONum = GlobalVar.SF.Upper(RS.GetString("JONo"))
				JOInfo.JOCatCode = GlobalVar.SF.Upper(RS.GetString("JOCatCode"))
				JOInfo.JOCategory = GlobalVar.SF.Upper(RS.GetString("JoDesc"))
				JOInfo.RefID= RS.GetInt("RefID")
				JOInfo.RefNo= GlobalVar.SF.Upper(RS.GetString("RefNo"))
				JOInfo.CustName = GlobalVar.SF.Upper(RS.GetString("CustName"))
				JOInfo.CustAdd = GlobalVar.SF.Upper(RS.GetString("CustAddress"))
				JOInfo.AcctClass = GlobalVar.SF.Upper(RS.GetString("AcctClass"))
				JOInfo.AcctSubClass = GlobalVar.SF.Upper(RS.GetString("AcctSubClass"))
				JOInfo.JOStatus = RS.GetInt("JOStatus")
				JOInfo.iWasRead = RS.GetInt("WasRead")
				sDateJO = GlobalVar.SF.Left(RS.GetString("JOAssignedAt"),10)
				iHour = GlobalVar.SF.Val(GlobalVar.SF.Mid(RS.GetString("JOAssignedAt"),12,2))
				iMin = GlobalVar.SF.Val(GlobalVar.SF.Mid(RS.GetString("JOAssignedAt"),15,2))
				amPm =  GlobalVar.SF.Right(RS.GetString("JOAssignedAt"),2)
				Log(sDateJO)
				Log(JOInfo.JOID & ", " & JOInfo.CustName)
				If amPm = "PM" And iHour <> 12 Then
					iHour = iHour + 12
				End If

				If amPm = "AM" And iHour = 12 Then
					iHour = 0
				End If
					
				If GlobalVar.SF.Len(iHour) = 1 Then
					If GlobalVar.SF.Len(iMin) = 1 Then
						sTimeJO = "0" & iHour & ":0" & iMin & ":00"
					Else
						sTimeJO = "0" & iHour & ":" & iMin & ":00"
					End If
				Else
					If GlobalVar.SF.Len(iMin) = 1 Then
						sTimeJO = iHour & ":0" & iMin & ":00"
					Else
						sTimeJO = iHour & ":" & iMin & ":00"
					End If
				End If
				Log(sTimeJO)
				DateTime.TimeFormat = "HH:mm:ss"
				If DaysBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) > 1 Then
					JOInfo.sJODate = DaysBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) & $" days ago"$
				Else If DaysBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) = 1 Then
					JOInfo.sJODate = DaysBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) & $" day ago"$
				Else if DaysBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) <= 0 Then
					LogColor (HoursBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)),Colors.Yellow)
					If HoursBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) > 1 Then
						JOInfo.sJODate = HoursBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) & $" hours ago"$
					Else If HoursBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) = 1 Then
						JOInfo.sJODate = HoursBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) & $" hour ago"$
					Else If HoursBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) <= 0 Then
						If MinBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) > 1 Then
							JOInfo.sJODate = MinBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) & $" mins. ago"$
						Else If MinBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) = 1 Then
							JOInfo.sJODate = MinBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) & $" min. ago"$
						Else If MinBetween(sDateJO, sTimeJO, DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now)) <= 0 Then
							JOInfo.sJODate = "Just Now"
						End If
					End If
				End If
				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 5dip, 0, clvJOs.AsView.Width, 60dip) 'Panel height + 4 for drop shadow
				clvJOs.Add(Pnl, JOInfo)
			Loop
			lblCount.Text = RS.RowCount & $" Record(s) Found"$
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If

		Log($"List of Job Order Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvJOs.Size} Job Order Records"$)
	Catch
		Log(LastException)
	End Try

End Sub

#End Region

Sub clvJOs_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 15 'List size
	clvJOs.Refresh
	
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvJOs.Size - 1)
		Dim Pnl As B4XView = clvJOs.GetPanel(i)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
				Dim JOInfo As JOs = clvJOs.GetValue(i)
				Pnl.LoadLayout("JONotifInfo")
				lblJONum.Text = JOInfo.JOCategory & " (" & JOInfo.JONum & ")"
				lblCustomer.Text = JOInfo.CustName & " / " & JOInfo.CustAdd
				lblDate.Text = JOInfo.sJODate
				
				lblJONum.Ellipsize = "END"
				lblCustomer.Ellipsize = "END"
				If JOInfo.iWasRead = 0 Then
					lblJONum.TextColor = 0xFF17A2B8
					lblJONum.Typeface = Typeface.LoadFromAssets("sourcesanspro-bold.ttf")
					lblDate.Typeface = Typeface.LoadFromAssets("sourcesanspro-bold.ttf")
				Else
					lblJONum.TextColor = Colors.DarkGray
					lblJONum.Typeface = Typeface.LoadFromAssets("sourcesanspro-regular.ttf")
					lblDate.Typeface = Typeface.LoadFromAssets("sourcesanspro-regular.ttf")
				End If
			End If
		Else 'Not visible
			If Pnl.NumberOfViews > 0 Then
				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
			End If
		End If
	Next
End Sub

Sub clvJOs_ItemClick (Index As Int, Value As Object)
	Dim JOInfo As JOs = Value
	LogColor(Value, Colors.Yellow)
	LogColor(JOInfo.JOID, Colors.Red)
	LogColor(JOInfo.JONum, Colors.Magenta)
	LogColor(JOInfo.JOStatus, Colors.Red)
	UpdateToReadJO(JOInfo.JOID)
	FillJOList
End Sub

Sub txtSearch_TextChanged (Old As String, New As String)
	If New.Length = 1 Or txtSearch.Text.Length = 2 Then Return
	clvJOs.Clear
	Sleep(0)

	Dim SenderFilter As Object
	If New.Length = 0  Then
		JOCounts = Starter.DBCon.ExecQuerySingleResult("SELECT COUNT(*) FROM `tblJOs`;")
		Starter.strCriteria = "SELECT * FROM tblJOs " & _
						  "WHERE WasUploaded = '" & 0 & "' " & _
						  "ORDER BY JOAssignedAt DESC"
		LogColor(Starter.strCriteria, Colors.Yellow)

		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
	Else
		JOCounts = 0
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", $"SELECT * FROM `tblJOs` WHERE `JoDesc` Like '%${New}%' ORDER BY JOAssignedAt DESC LIMIT 500;"$, Null) 'Limited for slower devices
	End If

	Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
	If Success Then
		Dim StartTime As Long = DateTime.Now
		clvJOs.Clear
		Do While RS.NextRow
			Dim JOInfo As JOs
			JOInfo.Initialize
			JOInfo.JOID = RS.GetInt("JOID")
			JOInfo.JONum = GlobalVar.SF.Upper(RS.GetString("JONo"))
			JOInfo.JOCatCode = GlobalVar.SF.Upper(RS.GetString("JOCatCode"))
			JOInfo.JOCategory = GlobalVar.SF.Upper(RS.GetString("JoDesc"))
			JOInfo.RefID= RS.GetInt("RefID")
			JOInfo.RefNo= GlobalVar.SF.Upper(RS.GetString("RefNo"))
			JOInfo.CustName = GlobalVar.SF.Upper(RS.GetString("CustName"))
			JOInfo.CustAdd = GlobalVar.SF.Upper(RS.GetString("CustAddress"))
			JOInfo.AcctClass = GlobalVar.SF.Upper(RS.GetString("AcctClass"))
			JOInfo.AcctSubClass = GlobalVar.SF.Upper(RS.GetString("AcctSubClass"))
			JOInfo.JOStatus = RS.GetInt("JOStatus")
			JOInfo.iWasRead = RS.GetInt("WasRead")
			Dim Pnl As B4XView = xui.CreatePanel("")
			Pnl.SetLayoutAnimated(0, 5dip, 0, clvJOs.AsView.Width, 60dip) 'Panel height + 4 for drop shadow
			clvJOs.Add(Pnl, JOInfo)
		Loop
		RS.Close
		lblCount.Text = RS.RowCount & $" Record(s) Found"$
	Else
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End If

	Log($"List of Job Order Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvJOs.Size} Job Order Records"$)
	
End Sub

Sub txtSearch_EnterPressed
	
End Sub

Sub ShowJODetails (iID As Int, sCatCode As String)
	Dim csTitle As CSBuilder
	Dim SenderFilter As Object
	Dim sJONo, sJOCatCode, sJODesc, sRefNo, sCustName, sCustAdd, sAcctClass, sConType As String
	Dim sDateCreated, sDateStart, sDateFinished As String
	

	sJONo = ""
	sJODesc = ""
	sRefNo = ""
	sCustName = ""
	sCustAdd = ""
	sAcctClass = ""
	sDateCreated = ""
	sDateStart = ""
	sDateFinished = ""
	sConType = ""

	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
	Try
		Starter.strCriteria = "SELECT JO.JONo, JO.JoDesc, " & _
						  "JO.RefNo AS App_AcctNo, JO.CustName, JO.CustAddress, " & _
						  "JO.AcctClass, JO.AcctSubClass, JO.ConType, " & _
						  "JO.JOAssignedAt, JO.DateStarted, JO.DateFinished " & _
						  "FROM tblJOs AS JO " & _
						  "WHERE JO.JOID = " & iID
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			RS.Position = 0
			sJONo = RS.GetString("JONo")
			sJODesc = RS.GetString("JoDesc")
			sRefNo = RS.GetString("App_AcctNo")
			sCustName = RS.GetString("CustName")
			sCustAdd = RS.GetString("CustAddress")
			sAcctClass = RS.GetString("AcctClass") & "-" & RS.GetString("AcctSubClass")
			sConType = RS.GetString("ConType")
			sDateCreated = RS.GetString("JOAssignedAt")
			sDateStart = RS.GetString("DateStarted")
			sDateFinished = RS.GetString("DateFinished")
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If
		
	Catch
		Log(LastException)
	End Try
	
	If sCatCode = "SAS" Then
		sJOCatCode = "Application No. :"
	Else
		sJOCatCode = "Account No. :"
	End If
	
	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.BlueColor).Append(sCatCode & $" "$ & $"JO DETAILS"$).PopAll

	If sCatCode = "SAS" Then
		MatDialogBuilder.Initialize("JODetails")
		MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
		MatDialogBuilder.NeutralText("EDIT").NeutralColor(GlobalVar.RedColor)
		MatDialogBuilder.Title(csTitle)
		MatDialogBuilder.Content($"  JO No. : ${sJONo}
		${sJODesc}
		Application No. : ${sRefNo}
		Customer Name : ${sCustName}
		Address : ${sCustAdd}
		F I N D I N G S
		
		Account Class: ${sAcctClass}
		Connection Type: ${sConType}"$)
		MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
		MatDialogBuilder.CanceledOnTouchOutside(False)
		MatDialogBuilder.Cancelable(True)
		MatDialogBuilder.Show
	Else
	End If
End Sub



Private Sub ConfirmStartJO(iJOID As Int)
	Dim Alert As AX_CustomAlertDialog

	Alert.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(Alert.STYLE_DIALOGUE) _
			.SetCancelable(False) _
			.SetTitle("START JO") _
			.SetTitleColor(GlobalVar.BlueColor) _
			.SetTitleTypeface(FontBold) _
			.SetMessage($"You are about to Start this JO,"$ & CRLF & $"JO Date & Time Started will be today."$ & CRLF & CRLF & $"Do you want to START this JO Now?"$) _
			.SetPositiveText("Confirm") _
			.SetPositiveColor(GlobalVar.PosColor) _
			.SetPositiveTypeface(FontBold) _
			.SetNegativeText("Cancel") _
			.SetNegativeColor(GlobalVar.NegColor) _
			.SetNegativeTypeface(Font) _
			.SetTitleTypeface(Font) _
			.SetMessageTypeface(Font) _
			.SetOnPositiveClicked("JO_Started") _	'listeners
			.SetOnNegativeClicked("JO_Started") _
			.SetOnViewBinder("JOFontSizeBinder") 	'listeners
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show

End Sub

'Listeners
Private Sub JO_Started_OnNegativeClicked (View As View, Dialog As Object)
'	ToastMessageShow("Negative Button Clicked!",False)
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub JO_Started_OnPositiveClicked (View As View, Dialog As Object)
'	ToastMessageShow("Positive Button Clicked!",False)

	LogColor(GlobalVar.SelectedJOID, Colors.Cyan)

	If StartJO(GlobalVar.SelectedJOID) = True Then
		Alert.Initialize.Dismiss(Dialog)
		FillJOList
		DispInfoMsg($"Selected JO Started..."$, $"JO UPDATED"$)
	Else
		Return
	End If

End Sub

Private Sub JOFontSizeBinder_OnBindView (View As View, ViewType As Int)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize
	If ViewType = Alert.VIEW_TITLE Then ' Title
		Dim lbl As Label = View
'		lbl.TextSize = 30
'		lbl.SetTextColorAnimated(2000,Colors.Magenta)
		
		
		Dim CS As CSBuilder
'		CS.Initialize.Typeface(Font).Append(lbl.Text & " ").Pop
'		CS.Typeface(Typeface.MATERIALICONS).Size(36).Color(Colors.Red).Append(Chr(0xE190))

		CS.Initialize.Typeface(Typeface.DEFAULT_BOLD).Typeface(Typeface.MATERIALICONS).Size(26).Color(Colors.Red).Append(Chr(0xE066) & " ")
		CS.Typeface(Font).Size(22).Append(lbl.Text).Pop

		lbl.Text = CS.PopAll
	End If
	If ViewType = Alert.VIEW_MESSAGE Then
		Dim lbl As Label = View
		lbl.TextSize = 16
		lbl.TextColor = Colors.Gray
	End If
	
	If ViewType = Alert.VIEW_NEGATIVE Or ViewType = Alert.VIEW_POSITIVE Then
		Dim lbl As Label = View
		lbl.TextSize = 18
	End If
	
End Sub


Private Sub DispInfoMsg(sMsg As String, sTitle As String)
	
	Dim InfoMsg As AX_CustomAlertDialog

	InfoMsg.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(InfoMsg.STYLE_DIALOGUE) _
			.SetCancelable(False) _
			.SetTitle(sTitle) _
			.SetMessage(sMsg) _
			.SetPositiveText("OK") _
			.SetPositiveColor(GlobalVar.PosColor) _
			.SetPositiveTypeface(FontBold) _
			.SetTitleTypeface(Font) _
			.SetMessageTypeface(Font) _
			.SetOnPositiveClicked("MessageBox") _	'listeners
			.SetOnViewBinder("FontSizeBinder") 'listeners
		
	InfoMsg.SetDialogBackground(MyFunctions.myCD)
	InfoMsg.Build.Show
End Sub

Private Sub MessageBox_OnPositiveClicked (View As View, Dialog As Object)
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub StartJO (iJOID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim lngDateTime As Long
	Dim sDateStart As String
	
	bRetVal = False
	lngDateTime = DateTime.Now
	DateTime.TimeFormat = "hh:mm:ss a"
	DateTime.DateFormat = "yyyy-MM-dd"
	sDateStart = DateTime.Date(lngDateTime) & $" "$ & DateTime.Time(lngDateTime)
	
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE tblJOs " & _
						  "SET JOStatus = ?, DateStarted = ? " & _
						  "WHERE JOID = " & iJOID
		
		LogColor(Starter.strCriteria,Colors.Yellow)
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String("2", sDateStart))
		Starter.DBCon.TransactionSuccessful

		bRetVal = True
	Catch
		bRetVal = False
		Log(LastException.Message)
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

Sub FontFromFile(Dir As String, FileName As String) As Typeface
   
	Dim R As Reflector
	Return R.RunStaticMethod("android.graphics.Typeface","createFromFile",Array As String(File.Combine(Dir,FileName)),Array As String("java.lang.String"))
End Sub

Private Sub UpdateToReadJO (iJOID As Int) As Boolean
	Dim bRetVal As Boolean
	
	bRetVal = False
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE tblJOs " & _
						  "SET WasRead = ? " & _
						  "WHERE JOID = " & iJOID
		
		LogColor(Starter.strCriteria,Colors.Yellow)
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String("1"))
		Starter.DBCon.TransactionSuccessful

		bRetVal = True
	Catch
		bRetVal = False
		Log(LastException.Message)
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

Private Sub StatusDate (sJODate As String, sJOTime As String) As String
	Dim sRetVal As String
	Dim iStatus As Int
	Dim isDay, isHour, isMin, isSec As Boolean
	
	sRetVal = ""
	iStatus = SecBetween(DateTime.Date(sJODate), DateTime.Time(sJOTime),DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now))

	If iStatus < 60 And iStatus > 1 Then
		sRetVal = iStatus & " seconds ago"
	Else If iStatus < 60 And iStatus = 1 Then
		sRetVal = iStatus & " second ago"
	Else If iStatus > 60 And iStatus < 3600 Then
		sRetVal = (iStatus/3600) & " minutes ago"

	End If
End Sub

Sub DaysBetween(StartDate As String, StartTime As String, EndDate As String, EndTime As String) As Int
	Dim s, e As Long
	s = ParseDateAndTime(StartDate, StartTime)
	e = ParseDateAndTime(EndDate, EndTime)
	Return (e - s) / DateTime.TicksPerDay
End Sub

Sub HoursBetween(StartDate As String, StartTime As String, EndDate As String, EndTime As String) As Int
	Dim s, e As Long
	s = ParseDateAndTime(StartDate, StartTime)
	e = ParseDateAndTime(EndDate, EndTime)
	Return (e - s) / DateTime.TicksPerHour
End Sub

Sub MinBetween(StartDate As String, StartTime As String, EndDate As String, EndTime As String) As Int
	Dim s, e As Long
	s = ParseDateAndTime(StartDate, StartTime)
	e = ParseDateAndTime(EndDate, EndTime)
	Return (e - s) / DateTime.TicksPerMinute
End Sub

Sub SecBetween(StartDate As String, StartTime As String, EndDate As String, EndTime As String) As Int
	Dim s, e As Long
	s = ParseDateAndTime(StartDate, StartTime)
	e = ParseDateAndTime(EndDate, EndTime)
	Return (e - s) / DateTime.TicksPerSecond
End Sub

Sub ParseDateAndTime(d As String, t As String) As Long
	Dim dd = DateTime.DateParse(d), tt = DateTime.TimeParse(t) As Long
	tt = (tt + DateTime.TimeZoneOffset * DateTime.TicksPerHour) Mod DateTime.TicksPerDay
	Dim total As Long
	total = dd + tt + _
      (DateTime.GetTimeZoneOffsetAt(dd) - DateTime.GetTimeZoneOffsetAt(dd + tt)) _
      * DateTime.TicksPerHour
	Return total
End Sub
