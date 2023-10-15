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
	
	Private clvJOs As CustomListView
	Private imeKeyboard As IME

	Dim cdSearch As ColorDrawable
	Private txtSearch As EditText

	Type JOReason (JOCatCode As String, JODesc As String, TotalPending As Int, TotalOnGoing As Int, TotalAccomplished As Int, TotalCancelled As Int, JOTotals As Int)
	Private lblCount As Label
		
	Private lblJOCatDesc As Label
	Private lblPending As Label
	Private lblOnGoing As Label
	Private lblAccomplished As Label
	Private lblCancelled As Label
	Private lblTotals As Label
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("JOSummaryList")
	
	GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"Job Order Summary"$).PopAll
	GlobalVar.CSSubTitle.Initialize.Size(12).Append($"List of Assigned Job Orders"$).PopAll
	
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
		imeKeyboard.Initialize("")
		FillJOList(GlobalVar.UserID, GlobalVar.BranchID)
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
	txtSearch.Text = ""
	FillJOList(GlobalVar.UserID, GlobalVar.BranchID)
End Sub



Sub Activity_Pause (UserClosed As Boolean)
End Sub

#End Region

#Region Toolbar
Sub Activity_CreateMenu(Menu As ACMenu)
'	Dim Item As ACMenuItem
'	
'	Menu.Clear
'	Menu.Add2(1, 1, "Filter by",xmlIcon.GetDrawable("baseline_filter_alt_white_24dp")).ShowAsAction = Item.SHOW_AS_ACTION_IF_ROOM
''	Menu.Add2(2, 2, "Settings",xmlIcon.GetDrawable("ic_settings_white_24dp")).ShowAsAction = Item.SHOW_AS_ACTION_ALWAYS
End Sub

Sub ToolBar_NavigationItemClick 'Toolbar Arrow
	imeKeyboard.HideKeyboard
	Activity.Finish
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
End Sub

#End Region

#Region JO Lists
Private Sub FillJOList (iUserID As Int, iBranchID As Int)
	Dim SenderFilter As Object

	Try
		Starter.strCriteria = "SELECT sum(CASE WHEN JOs.JOStatus = 1 THEN 1 ELSE 0 END) AS PendingJOs, " & _
						  "sum(CASE WHEN JOs.JOStatus = 2 THEN 1 ELSE 0 END) AS OnGoingJOs, " & _
						  "sum(CASE WHEN JOs.JOStatus = 3 THEN 1 ELSE 0 END) AS AccomplishedJOs, " & _
						  "sum(CASE WHEN JOs.JOStatus = 4 THEN 1 ELSE 0 END) AS CancelledJOs, " & _
						  "count(JOs.JOCatCode) AS TotalJOs, JOs.JOCatCode, JOCat.jo_desc " & _
						  "FROM tblJOs AS JOs " & _
						  "INNER JOIN constant_jo_categories AS JOCat ON JOs.JOCatCode = JOCat.jo_code " & _
						  "WHERE JOs.JOAssignedTo = " & iUserID & " " & _
						  "AND JOs.BranchID = " & iBranchID & " " & _
						  "GROUP BY JOs.JOCatCode " & _
						  "ORDER BY JOCat.id ASC"						  
		LogColor(Starter.strCriteria, Colors.Yellow)

		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		If Success Then
			Dim StartTime As Long = DateTime.Now
			clvJOs.Clear
			Do While RS.NextRow
				Dim JOCount As JOReason
				JOCount.Initialize
				JOCount.TotalPending = RS.GetInt("PendingJOs")
				JOCount.TotalOnGoing = RS.GetInt("OnGoingJOs")
				JOCount.TotalAccomplished = RS.GetInt("AccomplishedJOs")
				JOCount.TotalCancelled = RS.GetInt("CancelledJOs")
				JOCount.JOTotals = RS.GetInt("TotalJOs")
				JOCount.JOCatCode = GlobalVar.SF.Upper(RS.GetString("JOCatCode"))
				JOCount.JODesc = RS.GetString("jo_desc")
				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 10dip, 0, clvJOs.AsView.Width, 120dip) 'Panel height + 4 for drop shadow
				clvJOs.Add(Pnl, JOCount)
			Loop
			If JOCount.JOTotals > 1 Then
				lblCount.Text = RS.RowCount & $" Job Order Categories Found"$
			Else
				lblCount.Text = RS.RowCount & $" Job Order Category Found"$
			End If
		Else
			Log(LastException)
		End If

		Log($"List of Job Order Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvJOs.Size} Job Order Records"$)
	Catch
		Log(LastException)
	End Try

End Sub


#End Region

Sub clvJOs_ItemClick (Index As Int, Value As Object)
	Dim JOCount As JOReason = Value
	
	LogColor(Value, Colors.Yellow)
	LogColor(JOCount.JOCatCode, Colors.Red)
	LogColor(JOCount.JODesc, Colors.Magenta)
	LogColor(JOCount.JOTotals, Colors.Red)
	
	GlobalVar.SelectedJOCatCode = JOCount.JOCatCode
	GlobalVar.SelectedJODesc = GlobalVar.SF.Proper(JOCount.JODesc)
	
	Select Case GlobalVar.SelectedJOCatCode
		Case "IC", "MC", "RM", "SL", "SV"
			StartActivity(actJOWithReasons)
		Case Else
			StartActivity(actJO)
	End Select
End Sub

Sub clvJOs_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 15 'List size
	clvJOs.Refresh
	
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvJOs.Size - 1)
		Dim Pnl As B4XView = clvJOs.GetPanel(i)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
				Dim JORec As JOReason = clvJOs.GetValue(i)
				Pnl.LoadLayout("JOCategories")
				
				lblJOCatDesc.Text = JORec.JODesc
				lblPending.Text = JORec.TotalPending
				lblOnGoing.Text = JORec.TotalOnGoing
				lblAccomplished.Text = JORec.TotalAccomplished
				lblCancelled.Text = JORec.TotalCancelled				
				lblTotals.Text = JORec.JOTotals
				
				If JORec.TotalPending > 0 Then
					lblPending.TextColor = GlobalVar.RedColor
				Else
					lblPending.TextColor = GlobalVar.BlueColor
				End If
				
				If JORec.TotalOnGoing > 0 Then
					lblOnGoing.TextColor = GlobalVar.RedColor
				Else
					lblOnGoing.TextColor = GlobalVar.BlueColor
				End If
				
				If JORec.TotalAccomplished <= 0 Then
					lblAccomplished.TextColor = GlobalVar.RedColor
				Else
					lblAccomplished.TextColor = GlobalVar.BlueColor
				End If
				
				If JORec.TotalCancelled > 0 Then
					lblCancelled.TextColor = GlobalVar.RedColor
				Else
					lblCancelled.TextColor = GlobalVar.BlueColor
				End If
				
				If JORec.JOTotals > 0 Then
					lblTotals.TextColor = GlobalVar.RedColor
				Else
					lblTotals.TextColor = GlobalVar.BlueColor
				End If
				
			End If
		Else 'Not visible
			If Pnl.NumberOfViews > 0 Then
				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
			End If
		End If
	Next
End Sub

Sub txtSearch_TextChanged (Old As String, New As String)
	If New.Length = 1 Or txtSearch.Text.Length = 2 Then Return
	clvJOs.Clear
	Sleep(0)

	Dim SenderFilter As Object
	If New.Length = 0  Then
		Starter.strCriteria = "SELECT sum(CASE WHEN JOs.JOStatus = 1 THEN 1 ELSE 0 END) AS PendingJOs, " & _
						  "sum(CASE WHEN JOs.JOStatus = 2 THEN 1 ELSE 0 END) AS OnGoingJOs, " & _
						  "sum(CASE WHEN JOs.JOStatus = 3 THEN 1 ELSE 0 END) AS AccomplishedJOs, " & _
						  "sum(CASE WHEN JOs.JOStatus = 4 THEN 1 ELSE 0 END) AS CancelledJOs, " & _
						  "count(JOs.JOCatCode) AS TotalJOs, JOs.JOCatCode, JOCat.jo_desc " & _
						  "FROM tblJOs AS JOs " & _
						  "INNER JOIN constant_jo_categories AS JOCat ON JOs.JOCatCode = JOCat.jo_code " & _
						  "WHERE JOs.JOAssignedTo = " & GlobalVar.UserID & " " & _
						  "AND JOs.BranchID = " & GlobalVar.BranchID & " " & _
						  "GROUP BY JOs.JOCatCode " & _
						  "ORDER BY JOCat.id ASC LIMIT 100"
	Else
		Starter.strCriteria = "SELECT sum(CASE WHEN JOs.JOStatus = 1 THEN 1 ELSE 0 END) AS PendingJOs, " & _
						  "sum(CASE WHEN JOs.JOStatus = 2 THEN 1 ELSE 0 END) AS OnGoingJOs, " & _
						  "sum(CASE WHEN JOs.JOStatus = 3 THEN 1 ELSE 0 END) AS AccomplishedJOs, " & _
						  "sum(CASE WHEN JOs.JOStatus = 4 THEN 1 ELSE 0 END) AS CancelledJOs, " & _
						  "count(JOs.JOCatCode) AS TotalJOs, JOs.JOCatCode, JOCat.jo_desc " & _
						  "FROM tblJOs AS JOs " & _
						  "INNER JOIN constant_jo_categories AS JOCat ON JOs.JOCatCode = JOCat.jo_code " & _
						  "WHERE JOs.JOAssignedTo = " & GlobalVar.UserID & " " & _
						  "AND JOs.BranchID = " & GlobalVar.BranchID & " " & _
						  "AND JOCat.jo_desc LIKE '%" & New & "%' " & _
						  "GROUP BY JOs.JOCatCode " & _
						  "ORDER BY JOCat.id ASC LIMIT 100"
	End If

	LogColor(Starter.strCriteria, Colors.Yellow)
	SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null) 'Limited for slower devices
	
	Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
	If Success Then
		Dim StartTime As Long = DateTime.Now
		clvJOs.Clear
		Do While RS.NextRow
		Dim JOCount As JOReason
			JOCount.Initialize
			JOCount.TotalPending = RS.GetInt("PendingJOs")
			JOCount.TotalOnGoing = RS.GetInt("OnGoingJOs")
			JOCount.TotalAccomplished = RS.GetInt("AccomplishedJOs")
			JOCount.TotalCancelled = RS.GetInt("CancelledJOs")
			JOCount.JOTotals = RS.GetInt("TotalJOs")
			JOCount.JOCatCode = GlobalVar.SF.Upper(RS.GetString("JOCatCode"))
			JOCount.JODesc = GlobalVar.SF.Upper(RS.GetString("jo_desc"))
			Dim Pnl As B4XView = xui.CreatePanel("")
			Pnl.SetLayoutAnimated(0, 10dip, 0, clvJOs.AsView.Width , 120dip) 'Panel height + 4 for drop shadow
			clvJOs.Add(Pnl, JOCount)
			Loop
			If JOCount.JOTotals > 1 Then
			lblCount.Text = RS.RowCount & $" Job Order Categories Found"$
			Else
		lblCount.Text = RS.RowCount & $" Job Order Category Found"$
		End If
		Else
		Log(LastException)
	End If
		
	Log($"List of Job Order Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvJOs.Size} Job Order Records"$)

End Sub

Sub txtSearch_EnterPressed
	
End Sub