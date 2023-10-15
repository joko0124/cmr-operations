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
	Private CD As ColorDrawable
	Private vibration As B4Avibrate
	Private vibratePattern() As Long
	
	Private snack As DSSnackbar
	Private csAns As CSBuilder
	Dim kboard As IME

	Private pnlPSIDist As B4XView
	Dim theDate As Long
	
	'PSI Dist
	Type PressureDistRecords (ID As Int, sPSIPoint As String, sPSIDistRdgTime As String, sPSIDistLoc As String, iPSIDistRdg As Int)
	Private clvList As CustomListView
	Private lblDistTimeRead As B4XView
	Private lblLocation As B4XView
	Private lblDistPSIRdg As B4XView
	Private btnAddPSIDist As DSFloatingActionButton

	Private MyToast As BCToast
	Private PopSubMenu As ACPopupMenu
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("PSIRdgDistribution")

'	DateTime.DateFormat = "MM/dd/yyyy"
'	theDate = DateTime.DateParse(GlobalVar.TranDate)
'	GlobalVar.TranDate = DateTime.Date(theDate)

	GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"PUMP - "$ & GlobalVar.PumpHouseCode).PopAll
	GlobalVar.CSSubTitle.Initialize.Size(12).Append($"Transaction Date: "$ & GlobalVar.TranDate).PopAll
	
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
	
	kboard.Initialize("KeyBoard")
	If FirstTime Then
	End If
	
	MyToast.Initialize(Activity)
	
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
	GetPSIDistRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
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
	Dim csAll, csPoint As CSBuilder
	
	csAll.Initialize.Color(Colors.White).Append($"All"$).PopAll
	
	PopSubMenu.Initialize("FilterBy", ToolBar.GetView(3))
	PopSubMenu.AddMenuItem(0,csAll,xmlIcon.GetDrawable("baseline_gps_fixed_white_24dp"))

	Dim rsPoint As Cursor
	Dim sPointNum As String
	Dim pCount As Int
	
	Try
		Starter.strCriteria = "SELECT * FROM tblPressurePoint " & _
						  "WHERE PumpHouseID = " & GlobalVar.PumpHouseID & " " & _
						  "ORDER BY id ASC"
							  
		LogColor(Starter.strCriteria, Colors.Blue)
		
		rsPoint =  Starter.DBCon.ExecQuery (Starter.strCriteria)
		If rsPoint.RowCount > 0 Then
			pCount = rsPoint.RowCount
			Dim jID As Int
			For i = 0 To rsPoint.RowCount - 1
				rsPoint.Position = i
				sPointNum = rsPoint.GetString("PPointNo")
				jID = i + 1
				csPoint.Initialize.Color(Colors.White).Append(sPointNum).PopAll
				PopSubMenu.AddMenuItem(jID,csPoint,xmlIcon.GetDrawable("baseline_hub_white_24dp"))
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
End Sub

Sub ToolBar_NavigationItemClick 'Toolbar Arrow
	Activity.Finish
	kboard.HideKeyboard
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
	Select Item.Id
		Case 1
			PopSubMenu.Show
	End Select
End Sub
Sub FilterBy_ItemClicked (Item As ACMenuItem)
	Log("Popupmenu Item clicked: " & Item.Id & " - " & Item.Title)
	Select Case Item.Id
		Case 0
			GetPSIDistRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
		Case Else
			FilterPSIDistRec(GlobalVar.TranDate, GlobalVar.PumpHouseID, Item.Title)
	End Select
'	FilterJoList(Item.Id)
End Sub

#End Region

#Region PSI Distribution
Sub GetPSIDistRec(sTrandate As String, iPumpID As Int)
	Dim SenderFilter As Object
	clvList.Clear
	Try
		Starter.strCriteria = "SELECT DistPSIReading.RdgID, DistPSIReading.PSIPointID, PressurePoint.PPointNo, PressurePoint.PLocation, DistPSIReading.RdgDate, " & _
							  "DistPSIReading.RdgTime, DistPSIReading.PSIReading, DistPSIReading.Remarks " & _
							  "FROM PressureDistReadings AS DistPSIReading " & _
							  "INNER JOIN tblPressurePoint AS PressurePoint ON DistPSIReading.PSIPointID = PressurePoint.ID " & _
							  "WHERE PressurePoint.PumpHouseID = " & iPumpID & " " & _
							  "AND DistPSIReading.RdgDate =  '" & sTrandate & "' "  & _
							  "AND DistPSIReading.AddedBy =  " & GlobalVar.UserID & " "  & _
							  "ORDER BY DistPSIReading.RdgID ASC, DistPSIReading.RdgTime ASC"
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			Dim StartTime As Long = DateTime.Now
			Do While RS.NextRow
				Dim PR As PressureDistRecords
				PR.Initialize
				PR.ID = RS.GetInt("RdgID")
				PR.sPSIPoint = RS.GetString("PPointNo")
				PR.sPSIDistRdgTime = RS.GetString("RdgTime")
				PR.sPSIDistLoc = RS.GetString("PLocation")
				PR.iPSIDistRdg = RS.GetInt("PSIReading")

				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 10dip, 0, clvList.AsView.Width - 10dip, 50dip) 'Panel height + 4 for drop shadow
				clvList.Add(Pnl, PR)
			Loop
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If

		Log($"List of Time Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvList.Size} PSI Distribution Records."$)

	Catch
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End Try
End Sub

Sub clvList_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 15 'List size
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvList.Size - 1)
		Dim Pnl As B4XView = clvList.GetPanel(i)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
				Dim PR As PressureDistRecords = clvList.GetValue(i)
				Pnl.LoadLayout("ListPSIDistRecords")
				lblDistTimeRead.TextColor = GlobalVar.PriColor
'				lblLocation.TextColor = GlobalVar.PriColor
				lblDistPSIRdg.TextColor = GlobalVar.PriColor
				
				lblDistTimeRead.Text = PR.sPSIDistRdgTime
				lblLocation.Text = PR.sPSIPoint & " - " & PR.sPSIDistLoc
				lblDistPSIRdg.Text = PR.iPSIDistRdg
			End If
		Else 'Not visible
			If Pnl.NumberOfViews > 0 Then
				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
			End If
		End If
	Next

End Sub

Sub clvList_ItemClick (Index As Int, Value As Object)
	Dim Rec As PressureDistRecords = Value
	Log(Rec.ID)
	ShowPSIDistRecDetails(Rec.ID)
	GlobalVar.PSIDistDetailID = Rec.ID
End Sub

Sub ShowPSIDistRecDetails (iID As Int)
	Dim csTitle As CSBuilder
	Dim SenderFilter As Object
	Dim sDate, sPCode, sDistributionTime, sLocation, sRem As String
	Dim iPSIDistRdg As Int
	
	Starter.strCriteria = "SELECT PSIDistRdg.RdgDate as TranDate, PumpStation.PumpHouseCode, " & _
						  "PSIDistRdg.RdgTime, PPoint.PPointNo, PPoint.PLocation, " & _
						  "PSIDistRdg.PSIReading, PSIDistRdg.Remarks " & _
						  "FROM PressureDistReadings AS PSIDistRdg " & _
						  "INNER JOIN tblPressurePoint AS PPoint ON PSIDistRdg.PSIPointID = PPoint.ID " & _
						  "INNER JOIN tblPumpStation AS PumpStation ON PPoint.PumpHouseID = PumpStation.StationID " & _
						  "WHERE PSIDistRdg.RdgID = " & iID
							  
	SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
	Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
	If Success Then
		RS.Position = 0
		sDate = RS.GetString("TranDate")
		sPCode = RS.GetString("PumpHouseCode")
		sDistributionTime = RS.GetString("RdgTime")
		sLocation = RS.GetString("PPointNo") & " - " & RS.GetString("PLocation")
		iPSIDistRdg = RS.GetInt("PSIReading")
		sRem = RS.GetString("Remarks")
	Else
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End If
	
	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.BlueColor).Append($"PRESSURE (Distribution) RECORD DETAILS"$).PopAll

	MatDialogBuilder.Initialize("EditPSIDistRec")
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.BlueColor)
	MatDialogBuilder.NegativeText("EDIT").NegativeColor(GlobalVar.GreenColor)
	MatDialogBuilder.NeutralText("DELETE").NeutralColor(GlobalVar.RedColor)
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content($"  Pump: ${sPCode}
	Transaction Date: ${sDate}

	Time Read: ${sDistributionTime}
	Location: ${sLocation}
	Pressure Reading: ${iPSIDistRdg} PSI
	Remarks: ${sRem}"$)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(True)
	MatDialogBuilder.Show
End Sub

Private Sub EditPSIDistRec_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
		Case mDialog.ACTION_NEGATIVE
			GlobalVar.blnNewPSIDist = False
			StartActivity(AddEditPSIDistRecord)
		Case mDialog.ACTION_NEUTRAL
	End Select
End Sub

Sub btnAddPSIDist_Click
	GlobalVar.blnNewPSIDist = True
	StartActivity(AddEditPSIDistRecord)
End Sub

Sub FilterPSIDistRec(sTrandate As String, iPumpID As Int, sPointNo As String)
	Dim SenderFilter As Object
	clvList.Clear
	Try
		Starter.strCriteria = "SELECT DistPSIReading.RdgID, DistPSIReading.PSIPointID, PressurePoint.PPointNo, PressurePoint.PLocation, DistPSIReading.RdgDate, " & _
							  "DistPSIReading.RdgTime, DistPSIReading.PSIReading, DistPSIReading.Remarks " & _
							  "FROM PressureDistReadings AS DistPSIReading " & _
							  "INNER JOIN tblPressurePoint AS PressurePoint ON DistPSIReading.PSIPointID = PressurePoint.ID " & _
							  "WHERE PressurePoint.PumpHouseID = " & iPumpID & " " & _
							  "AND DistPSIReading.RdgDate =  '" & sTrandate & "' "  & _
							  "AND PressurePoint.PPointNo =  '" & sPointNo & "' "  & _
							  "AND DistPSIReading.AddedBy =  " & GlobalVar.UserID & " "  & _
							  "ORDER BY DistPSIReading.RdgID ASC, DistPSIReading.RdgTime ASC"
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			Dim StartTime As Long = DateTime.Now
			Do While RS.NextRow
				Dim PR As PressureDistRecords
				PR.Initialize
				PR.ID = RS.GetInt("RdgID")
				PR.sPSIPoint = RS.GetString("PPointNo")
				PR.sPSIDistRdgTime = RS.GetString("RdgTime")
				PR.sPSIDistLoc = RS.GetString("PLocation")
				PR.iPSIDistRdg = RS.GetInt("PSIReading")

				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 10dip, 0, clvList.AsView.Width - 10dip, 50dip) 'Panel height + 4 for drop shadow
				clvList.Add(Pnl, PR)
			Loop
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If

		Log($"List of Time Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvList.Size} PSI Distribution Records."$)

	Catch
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End Try
End Sub

#End Region