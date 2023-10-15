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
	Private InpTyp As SLInpTypeConst
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

	Private TabMenu As WobbleMenu
	
	Private PnlTime As B4XView
	Private pnlFMRdg As B4XView
	Private pnlPSIRdg As B4XView
	Private pnlChlorinator As B4XView
	Private pnlConcerns As B4XView
	Dim theDate As Long

	'Pump Time On/Off
	Type TimeRecords (ID As Int, lTimeOn As Long, lTimeOff As Long, iTotOpHrs As Double)
	Private clvTime As CustomListView
	Private lblOpHrs As B4XView
	Private lblTimeOff As B4XView
	Private lblTimeOn As B4XView
	Private btnAddTime As DSFloatingActionButton
	Private lSelectedRecTimeOn As Long
	Private blnAddTime As Boolean

	'Flow Meter Reading
	Type FMRecords (ID As Int, sRdgTime As String, iPrevRdg As Int, iPresRdg As Int, _
					 iTotProd As Int, iBackFlow As Int)
	Private clvFM As CustomListView
	Private lblPresCuM As B4XView
	Private lblPrevCuM As B4XView
	Private lblRdgTime As B4XView
	Private lblTotProd As B4XView
	Private btnAddFM As DSFloatingActionButton

	'PSI Reading
	Type PSIRecords (ID As Int, sRdgTime As String, iPrevRdg As Int, iPSIRdg As Int)
	Private clvPSI As CustomListView
	Private lblPSIRdgTime As B4XView
	Private lblPSIRdg As B4XView
	Private btnAddPSI As DSFloatingActionButton

	'Chlorinator
	Type ChlorineRecords (ID As Int, sTimeRep As String, sChlorineType As String, iVolume As Int)
	Private clvChlorine As CustomListView
	Private lblTimeRep As B4XView
	Private lblChlorineType As B4XView
	Private lblVolume As B4XView
	Private btnAddChlorine As DSFloatingActionButton
	Private sUnit As String

	'Problems Encountered
	Type ConcernsRecords (ID As Int, sTimeEnc As String, sProblem As String)
	Private clvConcerns As CustomListView
	Private lblTimeEnc As Label
	Private lblProblems As B4XView
	Private btnAddConcerns As DSFloatingActionButton

	Private iLastReading = 0 As Int
	Private MyToast As BCToast
		
	Dim cdReading, cdRem As ColorDrawable
	Dim Alert As AX_CustomAlertDialog
	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")

End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("Production")

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
	
	TabMenu.SetTabTextIcon(1, "ON/OFF", Chr(0xF017), Typeface.FONTAWESOME)
	TabMenu.SetTabTextIcon(2, "FM RDG", Chr(0xF0E4), Typeface.FONTAWESOME)
	TabMenu.SetTabTextIcon(3, "PSI RDG", Chr(0xF012), Typeface.FONTAWESOME)
	TabMenu.SetTabTextIcon(4, "CHLORINE", Chr(0xF171), Typeface.FONTAWESOME)
	TabMenu.SetTabTextIcon(5, "CONCERNS", Chr(0xF044), Typeface.FONTAWESOME)
	
	TabMenu.SetCurrentTab(1)
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
	GetPumpTimeRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
	GetFMRdgRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
	GetPSIRdgRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
	GetChlorineRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
	GetProblemsRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
	MyToast.Initialize(Activity)

End Sub

Sub Activity_Pause (UserClosed As Boolean)
End Sub

#End Region

#Region Toolbar
Sub Activity_CreateMenu(Menu As ACMenu)
'	Dim Item As ACMenuItem
'	Menu.Clear
	'Chr(0xF274)
'	Menu.Add2(1, 1, "Transaction Date",xmlIcon.GetDrawable("ic_date_range_white_24dp")).ShowAsAction = Item.SHOW_AS_ACTION_IF_ROOM
'	Menu.Add2(2, 2, "Settings",xmlIcon.GetDrawable("ic_settings_white_24dp")).ShowAsAction = Item.SHOW_AS_ACTION_ALWAYS
End Sub

Sub ToolBar_NavigationItemClick 'Toolbar Arrow
	Activity.Finish
	kboard.HideKeyboard
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
End Sub

#End Region

#Region Tabs

Sub TabMenu_Tab1Click 'Pump On/Off Time
	PnlTime.Visible = True
	GetPumpTimeRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
	pnlFMRdg.Visible = False
	pnlFMRdg.Visible = False
	pnlPSIRdg.Visible = False
	pnlChlorinator.Visible = False
	pnlConcerns.Visible = False
End Sub

Sub TabMenu_Tab2Click ' Flow Meter Reading
	PnlTime.Visible = False
	pnlPSIRdg.Visible = False
	pnlChlorinator.Visible = False
	pnlConcerns.Visible = False
	
	pnlFMRdg.Visible = True
	GetFMRdgRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
End Sub

Sub TabMenu_Tab3Click ' PSI Reading
	PnlTime.Visible = False
	pnlFMRdg.Visible = False
	pnlChlorinator.Visible = False
	pnlConcerns.Visible = False
	
	pnlPSIRdg.Visible = True
	GetPSIRdgRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
End Sub

Sub TabMenu_Tab4Click ' Chlorinator
	PnlTime.Visible = False
	pnlFMRdg.Visible = False
	pnlPSIRdg.Visible = False
	pnlConcerns.Visible = False
	
	pnlChlorinator.Visible = True
	GetChlorineRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
End Sub

Sub TabMenu_Tab5Click ' Problems Encountered
	PnlTime.Visible = False
	pnlFMRdg.Visible = False
	pnlPSIRdg.Visible = False
	pnlChlorinator.Visible = False

	pnlConcerns.Visible = True
	GetProblemsRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
End Sub

#End Region

#Region Pump Time

Sub GetPumpTimeRec(sTrandate As String, iPumpID As Int)
	Dim SenderFilter As Object
	Dim sTimeON, sTimeOFF As String
	Dim iPowerStatus As Int
	
	clvTime.Clear
	
	If DBaseFunctions.GetPumpPowerStatus(iPumpID) = 0 Then
		iPowerStatus = 0
	Else
		iPowerStatus = 1
	End If

	Try
		Starter.strCriteria = "SELECT Header.HeaderID, Header.PumpID, Details.DetailID, Details.PumpOnTime AS TimeOn, Details.PumpOffTime AS TimeOff, Details.TotOpHrs " & _
						  "FROM TranHeader AS Header " & _
						  "INNER JOIN OnOffDetails AS Details ON Header.HeaderID = Details.HeaderID " & _
						  "WHERE Header.PumpID = " & iPumpID & " " & _
						  "AND Header.TranDate = '" & sTrandate & "' "  & _
						  "ORDER BY Details.DetailID, TimeOn ASC"
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			Dim StartTime As Long = DateTime.Now
			Do While RS.NextRow
				Dim TR As TimeRecords
				TR.Initialize
				TR.ID = RS.GetInt("DetailID")

				sTimeON = RS.GetString("TimeOn")
				sTimeOFF = RS.GetString("TimeOff")

				LogColor(sTimeON, Colors.White)
				LogColor(sTimeOFF, Colors.White)
				
				DateTime.TimeFormat = "hh:mm a"
				TR.lTimeOn = DateTime.TimeParse(sTimeON)
				If sTimeOFF = "" Or sTimeOFF = Null Then
					TR.lTimeOff = 0
					TR.iTotOpHrs = 0
				Else
					TR.lTimeOff = DateTime.TimeParse(sTimeOFF)
					TR.iTotOpHrs = RS.GetDouble("TotOpHrs")
				End If

				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 10dip, 0dip, clvTime.AsView.Width - 10dip, 30dip) 'Panel height + 4 for drop shadow
				clvTime.Add(Pnl, TR)
			Loop
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If

		Log($"List of Time Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvTime.Size} Time Records"$)

	Catch
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End Try
End Sub

Sub clvTime_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 15 'List size
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvTime.Size - 1)
		Dim Pnl As B4XView = clvTime.GetPanel(i)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
				Dim TR As TimeRecords = clvTime.GetValue(i)
				Pnl.LoadLayout("ListPumpTimeRecords")
				lblTimeOn.TextColor = GlobalVar.PriColor
				DateTime.TimeFormat = "hh:mm a"
				lblTimeOn.Text = DateTime.Time(TR.lTimeOn)
				If TR.lTimeOff = 0 Then
					lblTimeOff.TextColor = GlobalVar.NegColor
					lblOpHrs.TextColor = GlobalVar.NegColor
					lblTimeOff.Text = "Running..."
					lblOpHrs.Text = "---"
				Else
					lblTimeOff.TextColor = GlobalVar.PriColor
					lblOpHrs.TextColor = GlobalVar.PriColor
					lblTimeOff.Text = DateTime.Time(TR.lTimeOff)
					lblOpHrs.Text = NumberFormat2(TR.iTotOpHrs,1, 2, 2,True) & $" Hr(s)."$
				End If
			End If
		Else 'Not visible
			If Pnl.NumberOfViews > 0 Then
				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
			End If
		End If
	Next

End Sub

Sub clvTime_ItemClick (Index As Int, Value As Object)
	Dim Rec As TimeRecords = Value
	Log(Rec.ID)


	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
	GlobalVar.TimeDetailID = Rec.ID
	GlobalVar.SelectedPumpTime = Rec.lTimeOn

	If Rec.lTimeOff = 0 Then
		blnAddTime = False
		ConfirmPumpOff
	Else
		ShowPumpTimeRecDetails(GlobalVar.TimeDetailID)
	End If
End Sub

Sub ShowPumpTimeRecDetails (iID As Int)
	Dim csTitle As CSBuilder
	Dim sDate, sPCode, sTimeOn, sTimeOff, sPowerSource, sRem As String
	Dim iPowerSource, iDrainTime, iDrainCum As Int
	Dim iTotOPHrs As Double
	Dim rsDetails As Cursor
	
	LogColor (iID, Colors.White)
	Try
		Starter.strCriteria = "SELECT Header.TranDate, " & _
						  "Pump.PumpHouseCode, Details.PumpOnTime, Details.PumpOffTime, Details.TotOpHrs, " & _
						  "Details.PowerSourceID, Details.DrainTime, Details.DrainCum, Details.TimeOnRemarks, Details.TimeOffRemarks " & _
						  "FROM OnOffDetails AS Details " & _
						  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
						  "INNER JOIN tblPumpStation AS Pump ON Pump.StationID = Header.PumpID " & _
						  "WHERE Details.DetailID = " & iID
							  
		rsDetails = Starter.DBCon.ExecQuery(Starter.strCriteria)
		If rsDetails.RowCount > 0 Then
			rsDetails.Position = 0
			sDate = rsDetails.GetString("TranDate")
			sPCode = rsDetails.GetString("PumpHouseCode")
			sTimeOn = rsDetails.GetString("PumpOnTime")
			sTimeOff = rsDetails.GetString("PumpOffTime")
			iTotOPHrs = rsDetails.GetDouble("TotOpHrs")
			iPowerSource = rsDetails.GetInt("PowerSourceID")
			If iPowerSource = 1 Then
				sPowerSource = $"Electricity"$
			Else
				sPowerSource = $"Generator"$
			End If
			iDrainTime = rsDetails.GetInt("DrainTime")
			iDrainCum = rsDetails.GetInt("DrainCum")
			sRem = rsDetails.GetString("TimeOnRemarks") & " / " & rsDetails.GetString("TimeOffRemarks")
		Else
'			snack.Initialize("", Activity,$"Cannot fetch detail information due to "$ & LastException.Message,5000)
'			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'			snack.Show
'			Log(LastException)
			Return
		End If
		
	Catch
		Log(LastException)
	End Try
	rsDetails.Close
	
	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.BlueColor).Append($"PUMP ON/OFF DETAILS"$).PopAll

	MatDialogBuilder.Initialize("EditTime")
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.BlueColor)
	MatDialogBuilder.NegativeText("EDIT").NegativeColor(GlobalVar.GreenColor)
	MatDialogBuilder.NeutralText("DELETE").NeutralColor(GlobalVar.RedColor)
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content($"  Pump: ${sPCode}
	Transaction Date: ${sDate}

	Time On:	${sTimeOn}
	Time Off:	${sTimeOff}
	Total Operating Hrs:	${NumberFormat2(iTotOPHrs,1, 2, 2,True)} Hr(s).
	Power Source:	${sPowerSource}
	Drain Time:	${iDrainTime} Min(s).
	Drain CuM:	${iDrainCum} CuM
	Remarks:	${sRem}"$)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(True)
	MatDialogBuilder.Show
End Sub

Private Sub EditTime_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
		Case mDialog.ACTION_NEGATIVE
			GlobalVar.blnNewTime = False
			LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Magenta)
			LogColor($"Detail ID: "$ & GlobalVar.TimeDetailID, Colors.Yellow)
			StartActivity(EditTimeRecord)
		Case mDialog.ACTION_NEUTRAL
'			StartActivity(SetTranDate)
	End Select
End Sub

Sub btnAddTime_Click
	GlobalVar.blnNewTime = True
	If DBaseFunctions.GetPumpPowerStatus(GlobalVar.PumpHouseID) = 1 Then
		GlobalVar.TimeDetailID = DBaseFunctions.GetLastTimeOnID(GlobalVar.TranDate, GlobalVar.PumpHouseID)
		blnAddTime = True
		ConfirmPumpOff
	Else
		blnAddTime = False
		StartActivity(AddEditTimeRecord)
	End If
End Sub

Private Sub ConfirmPumpOff
	Dim Alert As AX_CustomAlertDialog
	
	Dim sTitle, sContent As String

	If blnAddTime = True Then
		sTitle = $"CONFIRM PUMP OFF TIME"$
		sContent = $"Cannot add new Time record due to Pump is currently running..."$ & CRLF & $"Do you want to Record the Pump Off Time Now?"$
	Else
		sTitle = $"CONFIRM PUMP OFF TIME"$
		sContent = $"Do you want to Record the Pump Off Time Now?"$
	End If
	
	Alert.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(Alert.STYLE_DIALOGUE) _
			.SetCancelable(False) _
			.SetTitleTypeface(FontBold) _
			.SetTitle(sTitle) _
			.SetTitleColor(GlobalVar.NegColor) _
			.SetMessageTypeface(Font) _
			.SetMessage(sContent) _
			.SetPositiveText("Confirm") _
			.SetPositiveColor(GlobalVar.PosColor) _
			.SetPositiveTypeface(FontBold) _
			.SetOnPositiveClicked("PumpOff") _	'listeners
			.SetNegativeText("Cancel") _
			.SetNegativeColor(GlobalVar.NegColor) _
			.SetNegativeTypeface(FontBold) _
			.SetOnNegativeClicked("PumpOff")	'listeners
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Listeners
Private Sub PumpOff_OnNegativeClicked (View As View, Dialog As Object)
'	ToastMessageShow("Negative Button Clicked!",False)
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub PumpOff_OnPositiveClicked (View As View, Dialog As Object)
'	ToastMessageShow("Positive Button Clicked!",False)
	
	LogColor(GlobalVar.SelectedJOID, Colors.Cyan)
	Alert.Initialize.Dismiss2
	StartActivity(actPumpOff)
End Sub

#End Region

#Region FM Reading

Sub GetFMRdgRec(sTrandate As String, iPumpID As Int)
	Dim SenderFilter As Object
	clvFM.Clear
	Try
		Starter.strCriteria = "SELECT Details.DetailID, Details.RdgTime, " & _
							  "Details.PrevRdg, Details.PresRdg, Details.PresCum, Details.BackFlowCum " & _
							  "FROM ProductionDetails AS Details " & _
							  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
							  "WHERE Header.PumpID = " & iPumpID & " " & _
							  "AND Header.TranDate = '" & sTrandate & "' "  & _
							  "ORDER BY Details.DetailID, Details.RdgTime ASC"
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			Dim StartTime As Long = DateTime.Now
			Do While RS.NextRow
				Dim FMRec As FMRecords
				FMRec.Initialize
				FMRec.ID = RS.GetInt("DetailID")
				FMRec.sRdgTime = RS.GetString("RdgTime")
				FMRec.iPrevRdg = RS.GetInt("PrevRdg")
				FMRec.iPresRdg = RS.GetInt("PresRdg")
				FMRec.iTotProd = RS.GetInt("PresCum")
				FMRec.iBackFlow = RS.GetInt("BackFlowCum")

				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 10dip, 0, clvFM.AsView.Width - 10dip, 30dip) 'Panel height + 4 for drop shadow
				clvFM.Add(Pnl, FMRec)
			Loop
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If

		Log($"List of FM Reading Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvFM.Size} Flow Meter Reading Records"$)

	Catch
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End Try
End Sub

Sub clvFM_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 15 'List size

	Dim Matcher1 As Matcher
	Dim sMin As String

	
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvFM.Size - 1)
		Dim Pnl As B4XView = clvFM.GetPanel(i)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
				Dim FMRec As FMRecords = clvFM.GetValue(i)
				Pnl.LoadLayout("ListFMRdg")
				If FMRec.iBackFlow >0 Then
					lblRdgTime.TextColor = GlobalVar.RedColor
					lblPrevCuM.TextColor = GlobalVar.RedColor
					lblPresCuM.TextColor = GlobalVar.RedColor
					lblTotProd.TextColor = GlobalVar.RedColor
				Else
					lblRdgTime.TextColor = GlobalVar.PriColor
					lblPrevCuM.TextColor = GlobalVar.PriColor
					lblPresCuM.TextColor = GlobalVar.PriColor
					lblTotProd.TextColor = GlobalVar.PriColor					
				End If
				
				
'				Matcher1 = Regex.Matcher("(\d\d):(\d\d)", FMRec.sRdgTime)
'				If Matcher1.Find Then
'					Dim iHrs, iMins As Int
'					iHrs = Matcher1.Group(1)
'					iMins = Matcher1.Group(2)
'		
'					If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMins)) = 1 Then
'						sMin = $"0"$ & iMins
'					Else
'						sMin = iMins
'					End If
'
'					If iHrs = 0 Then
'						lblRdgTime.Text = $"12:"$ & sMin & " AM"
'					Else If iHrs > 0 And iHrs < 12 Then
'						If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrs)) = 1 Then
'							lblRdgTime.Text = $"0"$ & iHrs & ":" & sMin & " AM"
'						Else
'							lblRdgTime.Text = iHrs & ":" & sMin & " AM"
'						End If
'					Else If iHrs = 12 Then
'						lblRdgTime.Text = $"12:"$ & sMin & " PM"
'					Else
'						If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrs - 12)) = 1 Then
'							lblRdgTime.Text = $"0"$ & (iHrs - 12) & ":" & sMin & " PM"
'						Else
'							lblRdgTime.Text = (iHrs - 12) & ":" & sMin & " PM"
'						End If
'					End If
'				End If

				lblRdgTime.Text = FMRec.sRdgTime
				lblPrevCuM.Text = FMRec.iPrevRdg
				lblPresCuM.Text = FMRec.iPresRdg
				lblTotProd.Text = NumberFormat(FMRec.iTotProd,0,0) & $" CuM"$
			End If
		Else 'Not visible
			If Pnl.NumberOfViews > 0 Then
				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
			End If
		End If
	Next

End Sub

Sub btnAddFM_Click
	GlobalVar.blnNewFMRdg = True
	StartActivity(AddEditFMRdg)
End Sub

Sub clvFM_ItemClick (Index As Int, Value As Object)
	Dim Rec As FMRecords = Value
	Log(Rec.ID)
	ShowFMRdgRecDetails(Rec.ID)
End Sub

Sub ShowFMRdgRecDetails (iID As Int)
	Dim csTitle As CSBuilder
	Dim SenderFilter As Object
	Dim sDate, sPCode, sReadTime, sRem As String
	Dim iPreviousRdg, iPresentRdg, iTotCum, iBackFlow As Int
	
	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
	Try
		Starter.strCriteria = "SELECT Header.TranDate, Pump.PumpHouseCode, " & _
						  	  "Details.DetailID, Details.RdgTime, Details.PrevRdg, Details.PresRdg, " & _
							  "Details.PresCum, Details.Remarks, BackFlowCum " & _
							  "FROM ProductionDetails As Details " & _
							  "INNER JOIN TranHeader As Header ON Details.HeaderID = Header.HeaderID " & _
							  "INNER JOIN tblPumpStation AS Pump ON Pump.StationID = Header.PumpID " & _
							  "WHERE Details.DetailID = " & iID
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			RS.Position = 0
			GlobalVar.FMRdgDetailID = RS.GetInt("DetailID")
			sDate = RS.GetString("TranDate")
			sPCode = RS.GetString("PumpHouseCode")
			sReadTime = RS.GetString("RdgTime")
			iPreviousRdg = RS.GetInt("PrevRdg")
			iPresentRdg = RS.GetInt("PresRdg")
			iTotCum = RS.GetInt("PresCum")
			sRem = RS.GetString("Remarks")
			iBackFlow = RS.GetInt("BackFlowCum")
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
		
	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.BlueColor).Append($"FLOW METER READING DETAILS"$).PopAll

	MatDialogBuilder.Initialize("EditFMRdg")
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
	If isLastFMReading(GlobalVar.FMRdgDetailID, GlobalVar.TranHeaderID) = True Then
		MatDialogBuilder.NegativeText("EDIT").NegativeColor(GlobalVar.GreenColor)
	Else
		MatDialogBuilder.NegativeText("")
	End If
	MatDialogBuilder.NeutralText("DELETE").NeutralColor(GlobalVar.RedColor)
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content($"  Pump: ${sPCode}
	Transaction Date: ${sDate}

	Reading Time: ${sReadTime}
	Present Reading: ${iPresentRdg}
	Previous Reading: ${iPreviousRdg}
	Total Prod.: ${NumberFormat(iTotCum,0,0)} CuM
	Backflow: ${NumberFormat(iBackFlow,0,0)} CuM
	Remarks: ${sRem}"$)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(True)
	MatDialogBuilder.Show
End Sub

Private Sub EditFMRdg_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
		Case mDialog.ACTION_NEGATIVE
			GlobalVar.blnNewFMRdg = False
			StartActivity(AddEditFMRdg)
		Case mDialog.ACTION_NEUTRAL
'			StartActivity(SetTranDate)
	End Select
End Sub

Sub pnlAddEditFMRdg_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Private Sub isLastFMReading(iDetailsID As Int, iHeaderID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim idCheck As Int
	bRetVal = False
	
	Try
		idCheck = Starter.DBCon.ExecQuerySingleResult("SELECT Max(DetailID) FROM ProductionDetails WHERE HeaderID = " & iHeaderID & " " & _
													  "GROUP BY HeaderID")
		LogColor($"Selected ID: "$ & iDetailsID & $" - Last ID: "$ & idCheck, Colors.Yellow)

		If iDetailsID = idCheck Then
			bRetVal = True
		Else
			bRetVal = False
		End If
	Catch
		bRetVal = False
		Log(LastException)
	End Try
	Return bRetVal
End Sub

#End Region

#Region PSI Reading

Sub GetPSIRdgRec(sTrandate As String, iPumpID As Int)
	Dim SenderFilter As Object
	clvPSI.Clear
	Try
		Starter.strCriteria = "SELECT Details.DetailID, Details.RdgTime, Details.PSIReading " & _
						  "FROM PressureRdgDetails AS Details " & _
						  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
						  "WHERE Header.PumpID = " & iPumpID & " " & _
						  "AND Header.TranDate = '" & sTrandate & "' "  & _
						  "ORDER BY Details.DetailID, Details.RdgTime ASC"
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			Dim StartTime As Long = DateTime.Now
			Do While RS.NextRow
				Dim PSIRec As PSIRecords
				PSIRec.Initialize
				PSIRec.ID = RS.GetInt("DetailID")
				PSIRec.sRdgTime = RS.GetString("RdgTime")
				PSIRec.iPSIRdg = RS.GetInt("PSIReading")

				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 10dip, 0, clvPSI.AsView.Width - 10dip, 30dip) 'Panel height + 4 for drop shadow
				clvPSI.Add(Pnl, PSIRec)
			Loop
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If

		Log($"List of PSI Reading Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvPSI.Size} PSI Reading Records"$)

	Catch
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End Try
End Sub

Sub clvPSI_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 15 'List size
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvPSI.Size - 1)
		Dim Pnl As B4XView = clvPSI.GetPanel(i)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
				Dim PSIRec As PSIRecords = clvPSI.GetValue(i)
				Pnl.LoadLayout("ListPSIRecords")
				lblPSIRdgTime.TextColor = GlobalVar.PriColor
				lblPSIRdg.TextColor = GlobalVar.PriColor
				
				lblPSIRdgTime.Text = PSIRec.sRdgTime
				lblPSIRdg.Text = NumberFormat(PSIRec.iPSIRdg,0,2) & $" PSI"$
			End If
		Else 'Not visible
			If Pnl.NumberOfViews > 0 Then
				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
			End If
		End If
	Next

End Sub

Sub clvPSI_ItemClick (Index As Int, Value As Object)
	Dim Rec As PSIRecords = Value
	Log(Rec.ID)
	ShowPSIRdgRecDetails(Rec.ID)
	GlobalVar.PSIRdgDetailID = Rec.ID
End Sub

Sub ShowPSIRdgRecDetails (iID As Int)
	Dim csTitle As CSBuilder
	Dim SenderFilter As Object
	Dim sDate, sPCode, sReadTime, sRem As String
	Dim iPressureRdg As Int
	
	Starter.strCriteria = "SELECT Header.TranDate, Pump.PumpHouseCode, " & _
						  "Details.RdgTime, Details.PSIReading, Details.Remarks " & _
						  "FROM PressureRdgDetails AS Details " & _
						  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
						  "INNER JOIN tblPumpStation AS Pump ON Pump.StationID = Header.PumpID " & _
						  "WHERE Details.DetailID = " & iID
							  
	SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
	Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
	If Success Then
		RS.Position = 0
		sDate = RS.GetString("TranDate")
		sPCode = RS.GetString("PumpHouseCode")
		sReadTime = RS.GetString("RdgTime")
		iPressureRdg = RS.GetInt("PSIReading")
		sRem = RS.GetString("Remarks")
	Else
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End If
	
	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.BlueColor).Append($"PRESSURE READING DETAILS"$).PopAll

	MatDialogBuilder.Initialize("EditPSIRdg")
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
	LogColor(GlobalVar.PSIRdgDetailID, Colors.Yellow)
	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
	If isLastPSIReading(GlobalVar.PSIRdgDetailID, GlobalVar.TranHeaderID) = True Then
		MatDialogBuilder.NegativeText("EDIT").NegativeColor(GlobalVar.GreenColor)
	Else
		MatDialogBuilder.NegativeText("")
	End If
	MatDialogBuilder.NeutralText("DELETE").NeutralColor(GlobalVar.RedColor)
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content($"  Pump: ${sPCode}
	Transaction Date: ${sDate}

	Reading Time: ${sReadTime}
	Pressure Reading: ${iPressureRdg}  PSI
	Remarks: ${sRem}"$)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(True)
	MatDialogBuilder.Show
End Sub

Private Sub EditPSIRdg_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_NEGATIVE
			GlobalVar.blnNewPSIRdg = False
			StartActivity(AddEditPSIRdg)
	End Select
End Sub

Sub btnAddPSI_Click
	GlobalVar.blnNewPSIRdg = True
	StartActivity(AddEditPSIRdg)
End Sub

Private Sub isLastPSIReading(iDetailsID As Int, iHeaderID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim idCheck As Int
	bRetVal = False
	
	Try
		idCheck = Starter.DBCon.ExecQuerySingleResult("SELECT Max(DetailID) FROM PressureRdgDetails WHERE HeaderID = " & iHeaderID & " " & _
													  "GROUP BY HeaderID")
		LogColor($"Selected ID: "$ & iDetailsID & $" - Last ID: "$ & idCheck, Colors.Yellow)

		If iDetailsID = idCheck Then
			bRetVal = True
		Else
			bRetVal = False
		End If
	Catch
		bRetVal = False
		Log(LastException)
	End Try
	Return bRetVal
End Sub


#End Region

#Region Chlorinator

Sub GetChlorineRec(sTrandate As String, iPumpID As Int)
	Dim SenderFilter As Object
	clvChlorine.Clear
	Try
		Starter.strCriteria = "SELECT Details.DetailID, Details.TimeReplenished, Details.ChlorineType, Details.Volume, Details.UoM " & _
							  "FROM ChlorineDetails AS Details " & _
							  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
							  "WHERE Header.PumpID = " & iPumpID & " " & _
							  "AND Header.TranDate = '" & sTrandate & "' "  & _
							  "ORDER BY Details.DetailID, TimeReplenished ASC"
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			Dim StartTime As Long = DateTime.Now
			Do While RS.NextRow
				Dim CR As ChlorineRecords
				CR.Initialize
				CR.ID = RS.GetInt("DetailID")
				CR.sTimeRep = RS.GetString("TimeReplenished")
				CR.sChlorineType = RS.GetString("ChlorineType")
				CR.iVolume = RS.GetInt("Volume")
				sUnit = RS.GetString("UoM")

				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 10dip, 0, clvChlorine.AsView.Width - 10dip, 30dip) 'Panel height + 4 for drop shadow
				clvChlorine.Add(Pnl, CR)
			Loop
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If

		Log($"List of Time Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvChlorine.Size} Chlorine Records"$)

	Catch
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End Try
End Sub

Sub clvChlorine_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 15 'List size
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvChlorine.Size - 1)
		Dim Pnl As B4XView = clvChlorine.GetPanel(i)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
				Dim CR As ChlorineRecords = clvChlorine.GetValue(i)
				Pnl.LoadLayout("ListChlorinatorRecords")
				lblTimeRep.TextColor = GlobalVar.PriColor
				lblChlorineType.TextColor = GlobalVar.PriColor
				lblVolume.TextColor = GlobalVar.PriColor
				
				lblTimeRep.Text = CR.sTimeRep
				lblChlorineType.Text = CR.sChlorineType
				lblVolume.Text = CR.iVolume & $" "$ & sUnit & $"(s)"$
			End If
		Else 'Not visible
			If Pnl.NumberOfViews > 0 Then
				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
			End If
		End If
	Next

End Sub

Sub clvChlorine_ItemClick (Index As Int, Value As Object)
	Dim Rec As ChlorineRecords = Value
	Log(Rec.ID)
	ShowChlorinatorRecDetails(Rec.ID)
	GlobalVar.ChlorineDetailID = Rec.ID
End Sub

Sub ShowChlorinatorRecDetails (iID As Int)
	Dim csTitle As CSBuilder
	Dim SenderFilter As Object
	Dim sDate, sPCode, sTimeReplenished, sChloType, sRem As String
	Dim iKG As Int
	
	Starter.strCriteria = "SELECT Header.TranDate, Pump.PumpHouseCode, " & _
						  "Details.TimeReplenished, Details.ChlorineType, Details.Volume, Details.Remarks " & _
						  "FROM ChlorineDetails AS Details " & _
						  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
						  "INNER JOIN tblPumpStation AS Pump ON Pump.StationID = Header.PumpID " & _
						  "WHERE Details.DetailID = " & iID
							  
	SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
	Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
	If Success Then
		RS.Position = 0
		sDate = RS.GetString("TranDate")
		sPCode = RS.GetString("PumpHouseCode")
		sTimeReplenished = RS.GetString("TimeReplenished")
		sChloType = RS.GetString("ChlorineType")
		iKG = RS.GetInt("Volume")
		sRem = RS.GetString("Remarks")
	Else
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End If
	
	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.BlueColor).Append($"CHLORINATOR RECORD DETAILS"$).PopAll

	MatDialogBuilder.Initialize("EditChlorineTime")
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.BlueColor)
	MatDialogBuilder.NegativeText("EDIT").NegativeColor(GlobalVar.GreenColor)
	MatDialogBuilder.NeutralText("DELETE").NeutralColor(GlobalVar.RedColor)
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content($"  Pump: ${sPCode}
	Transaction Date: ${sDate}

	Time Replenished: ${sTimeReplenished}
	Chlorine Type: ${sChloType}
	Volume: ${iKG} Kg(s).
	Remarks: ${sRem}"$)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(True)
	MatDialogBuilder.Show
End Sub

Private Sub EditChlorineTime_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
		Case mDialog.ACTION_NEGATIVE
			GlobalVar.blnNewChlorine = False
			StartActivity(AddEditChlorineRecord)
		Case mDialog.ACTION_NEUTRAL
'			StartActivity(SetTranDate)
	End Select
End Sub

Sub btnAddChlorine_Click
	GlobalVar.blnNewChlorine = True
	StartActivity(AddEditChlorineRecord)
End Sub

#End Region

#Region Problems Encountered

Sub btnAddConcerns_Click
	GlobalVar.blnNewProblem = True
	StartActivity(AddEditProblem)
End Sub

Sub GetProblemsRec(sTrandate As String, iPumpID As Int)
	Dim SenderFilter As Object
	clvConcerns.Clear
	Try
		Starter.strCriteria = "SELECT Problem.DetailID, Problem.TimeStart, Problem.ProblemTitle " & _
							  "FROM ProblemDetails AS Problem " & _
							  "INNER JOIN TranHeader AS Header ON Problem.HeaderID = Header.HeaderID " & _
							  "WHERE Header.PumpID = " & iPumpID & " " & _
							  "AND Header.TranDate = '" & sTrandate & "' "  & _
							  "ORDER BY Problem.DetailID, Problem.TimeStart ASC"
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			Dim StartTime As Long = DateTime.Now
			Do While RS.NextRow
				Dim ConcernRec As ConcernsRecords
				ConcernRec.Initialize
				ConcernRec.ID = RS.GetInt("DetailID")
				ConcernRec.sTimeEnc = RS.GetString("TimeStart")
				ConcernRec.sProblem= RS.GetString("ProblemTitle")

				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 10dip, 0, clvConcerns.AsView.Width - 10dip, 30dip) 'Panel height + 4 for drop shadow
				clvConcerns.Add(Pnl, ConcernRec)
			Loop
		Else
			ToastMessageShow($"Unable to fetch Problem Encountered Record due to ""$ & LastException.Message, True)
			Log(LastException)
		End If

		Log($"List of Problem Encountered Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvConcerns.Size} PSI Reading Records"$)

	Catch
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End Try
End Sub

Sub clvConcerns_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 15 'List size
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvConcerns.Size - 1)
		Dim Pnl As B4XView = clvConcerns.GetPanel(i)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
				Dim ConcernRec As ConcernsRecords = clvConcerns.GetValue(i)
				Pnl.LoadLayout("ListProblemsRecords")
				lblTimeEnc.TextColor = GlobalVar.PriColor
				lblProblems.TextColor = GlobalVar.PriColor
				
				lblTimeEnc.Text = ConcernRec.sTimeEnc
				lblProblems.Text = ConcernRec.sProblem
			End If
		Else 'Not visible
			If Pnl.NumberOfViews > 0 Then
				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
			End If
		End If
	Next

End Sub

Sub clvConcerns_ItemClick (Index As Int, Value As Object)
	Dim Rec As ConcernsRecords = Value
	Log(Rec.ID)
	GlobalVar.ProblemDetailID = Rec.ID
	ShowProblemRecDetails(GlobalVar.ProblemDetailID)
End Sub

Sub ShowProblemRecDetails (iID As Int)
	Dim csTitle As CSBuilder
	Dim SenderFilter As Object
	Dim sTrandate, sPumpCode, sPumpArea As String
	Dim iIsCritical, iWasSolved As Int
	Dim sIsCritical, sWasSolved, sProbTitle, sProbDesc, sTimeStart, sTimeFinished, sActionTaken As String
	
	LogColor(iID, Colors.Yellow)
	Try
		Starter.strCriteria = "SELECT Header.TranDate, Station.PumpHouseCode, Areas.PumpArea, " & _
					  	  "ProblemDtls.IsCritical, ProblemDtls.ProblemTitle, ProblemDtls.ProbDesc, " & _
						  "ProblemDtls.TimeStart, ProblemDtls.TimeFinished, " & _
						  "ProblemDtls.WasSolved, ProblemDtls.ActionTaken " & _
						  "FROM ProblemDetails AS ProblemDtls " & _
						  "INNER JOIN TranHeader AS Header ON ProblemDtls.HeaderID = Header.HeaderID " & _
						  "INNER JOIN tblPumpStation AS Station ON Header.PumpID = Station.StationID " & _
						  "INNER JOIN PumpAreas AS Areas ON ProblemDtls.AreaID = Areas.ID " & _
						  "WHERE ProblemDtls.DetailID = " & iID
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			RS.Position = 0
			sTrandate = RS.GetString("TranDate")
			sPumpCode = RS.GetString("PumpHouseCode")
			sPumpArea = RS.GetString("PumpArea")
			iIsCritical = RS.GetInt("IsCritical")
			If iIsCritical = 1 Then
				sIsCritical = $"YES"$
			Else
				sIsCritical = $"NO"$
			End If
			sProbTitle = RS.GetString("ProblemTitle")
			sProbDesc = RS.GetString("ProbDesc")
			sTimeStart = RS.GetString("TimeStart")
			sTimeFinished = RS.GetString("TimeFinished")
			iWasSolved = RS.GetInt("WasSolved")
			If iWasSolved = 1 Then
				sWasSolved = $"YES"$
			Else
				sWasSolved = $"NO"$
			End If
			sActionTaken = RS.GetString("ActionTaken")
		Else
			ToastMessageShow($"Unable to fetch Problem Details due to "$ & LastException.Message, True)
			Log(LastException)
			Return
		End If
		
	Catch
		Log(LastException)
	End Try
	
	
	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.BlueColor).Append($"PROBLEM ENCOUNTERED DETAILS"$).PopAll

	MatDialogBuilder.Initialize("EditProblemRecord")
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
	MatDialogBuilder.NegativeText("EDIT").NegativeColor(GlobalVar.GreenColor)
	MatDialogBuilder.NeutralText("DELETE").NeutralColor(GlobalVar.RedColor)
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content($"  Pump: ${sPumpCode}
	Transaction Date: ${sTrandate}

	Pump Area: ${sPumpArea}
	Is Critical: ${sIsCritical}
	Time Started: ${sTimeStart}
	Time Finished: ${sTimeFinished}
	Problem Title: ${sProbTitle}
	Problem Detail: ${sProbDesc}
	Was Solved?: ${sWasSolved}
	Action Taken: ${sActionTaken}"$)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(True)
	MatDialogBuilder.Show
End Sub

Private Sub EditProblemRecord_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_NEGATIVE
			GlobalVar.blnNewProblem = False
			StartActivity(AddEditProblem)
	End Select
End Sub
#End Region