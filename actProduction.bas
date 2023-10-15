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
	Private InpTyp As SLInpTypeConst
End Sub

Sub Globals
'	Dim ActionBarButton As ACActionBar
'	Private ToolBar As ACToolBarDark
'	Private xmlIcon As XmlLayoutBuilder
'	Private MatDialogBuilder As MaterialDialogBuilder
'	Private CD As ColorDrawable
'	Private vibration As B4Avibrate
'	Private vibratePattern() As Long
'	
'	Private snack As DSSnackbar
'	Private csAns As CSBuilder
'	Dim kboard As IME
'
'	Private TabMenu As WobbleMenu
'	
'	Private PnlTime As B4XView
'	Private pnlFMRdg As B4XView
'	Private pnlPSIRdg As B4XView
'	Private pnlChlorinator As B4XView
'	Private pnlConcerns As B4XView
'	Dim theDate As Long
'	Dim Alert As AX_CustomAlertDialog
'	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
'	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")
'
'	'Pump Time On Off
'	Type TimeRecords (ID As Int, lTimeOn As Long, lTimeOff As Long, iTotOpHrs As Double)
'	Private clvTime As CustomListView
'	Private lblOpHrs As B4XView
'	Private lblTimeOff As B4XView
'	Private lblTimeOn As B4XView
'	Private btnAddTime As DSFloatingActionButton
'	Private lSelectedRecTimeOn As Long
'	
'	'Pump Time Off
'	Private mskTimeOff As MaskedEditText
'	Private btnPumpOffSave As ACButton
'	Private chkDefaultTimeOff As CheckBox
'	Private pnlPumpOff As Panel
'	Private txtOffRemarks As EditText
'	Private iHrOff As Int
'	Private sPumpTimeOff As String
'	Private TotOpHours As Float
'
'
'	
'	'Flow Meter Reading
'	Type FMRecords (ID As Int, sRdgTime As String, iPrevRdg As Int, iPresRdg As Int, _
'					 iTotProd As Int)
'	Private clvFM As CustomListView
'	Private lblPresCuM As B4XView
'	Private lblPrevCuM As B4XView
'	Private lblRdgTime As B4XView
'	Private lblTotProd As B4XView
'	Private btnAddFM As DSFloatingActionButton
'
'	'PSI Reading
'	Type PSIRecords (ID As Int, sRdgTime As String, iPSIRdg As Int)
'	Private clvPSI As CustomListView
'	Private lblPSIRdgTime As B4XView
'	Private lblPSIRdg As B4XView
'	Private btnAddPSI As DSFloatingActionButton
'
'	'Chlorinator
'	Type ChlorineRecords (ID As Int, sTimeRep As String, sChlorineType As String, iVolume As Int)
'	Private clvChlorine As CustomListView
'	Private lblTimeRep As B4XView
'	Private lblChlorineType As B4XView
'	Private lblVolume As B4XView
'	Private btnAddChlorine As DSFloatingActionButton
'	Private sUnit As String
'
'	'Problems Encountered
'	Type ConcernsRecords (ID As Int, sTimeEnc As String, sProblem As String)
'	Private clvConcerns As CustomListView
'	Private lblTimeEnc As Label
'	Private lblProblems As B4XView
'	Private btnAddConcerns As DSFloatingActionButton
'
'	Private iLastReading = 0 As Int
'	Private MyToast As BCToast
'		
'	Dim cdReading, cdRem As ColorDrawable
'
'	'Add/Edit FM Reading
'	Private btnSaveUpdateFMRdg As ACButton
'	Private pnlAddEditFMRdg As B4XView
'	Private pnlFMRdgHolder As B4XView
'	Private txtFMRdg As EditText
'	Private txtFMRemarks As EditText
'	Private btnFMRdgCancel As B4XView
'	
'	'Add/Edit PSI Reading
'	Private btnSaveUpdatePSIRdg As ACButton
'	Private pnlAddEditPSIRdg As B4XView
'	Private pnlPSIRdgHolder As B4XView
'	Private txtPSIRdg As EditText
'	Private txtPSIRemarks As EditText
'	Private btnPSIRdgCancel As B4XView
'
'	Private pnlProbEncDetails As Panel
'	Private pnlProbEncMsgBox As Panel
'	Private pnlProbSolved As Panel
'	Private lblTitle As Label
'	Private lblTitlePSI As Label
'	Private btnEditProb As ACButton
'	Private btnProbEncOK As ACButton
'	Private btnSolved As ACButton
'	Private chkCritical As CheckBox
'	Private lblActionTaken As Label
'	Private lblFindings As Label
'	Private lblProbDesc As Label
'	Private lblProbTitle As Label
'	Private lblPumpArea As Label
'	Private lblPumpCode As Label
'	Private lblRemarks As Label
'	Private lblTranDate As Label
'	
'	Private btnPumpOffCancel As ACButton
'	Private cdCancel As ColorDrawable
'	Private chkTimeFMRdg As CheckBox
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
'	MyScale.SetRate(0.5)
'	Activity.LoadLayout("Production")
'
'	DateTime.DateFormat = "MM/dd/yyyy"
'	theDate = DateTime.DateParse(GlobalVar.TranDate)
'	GlobalVar.TranDate = DateTime.Date(theDate)
'	
'	InpTyp.Initialize
'	InpTyp.SetInputType(txtFMRemarks,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_CORRECT, InpTyp.TYPE_TEXT_FLAG_CAP_SENTENCES))
'	InpTyp.SetInputType(txtPSIRemarks,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_CORRECT, InpTyp.TYPE_TEXT_FLAG_CAP_SENTENCES))
'
'	GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"PUMP - "$ & GlobalVar.PumpHouseCode).PopAll
'	GlobalVar.CSSubTitle.Initialize.Size(12).Append($"Transaction Date: "$ & GlobalVar.TranDate).PopAll
'	
'	ToolBar.InitMenuListener
'	ToolBar.Title = GlobalVar.CSTitle
'	ToolBar.SubTitle = GlobalVar.CSSubTitle
'	
'	Dim jo As JavaObject
'	Dim xl As XmlLayoutBuilder
'	jo = ToolBar
'	jo.RunMethod("setPopupTheme", Array(xl.GetResourceId("style", "ToolbarMenu")))
'	jo.RunMethod("setContentInsetStartWithNavigation", Array(1dip))
'	jo.RunMethod("setTitleMarginStart", Array(0dip))
'
'	ActionBarButton.Initialize
'	ActionBarButton.ShowUpIndicator = True
'	
'	kboard.Initialize("KeyBoard")
	If FirstTime Then
	End If
'	TabMenu.Initialize(Null,"")
	
'	TabMenu.SetTabTextIcon(1, "ON/OFF", Chr(0xF017), Typeface.FONTAWESOME)
'	TabMenu.SetTabTextIcon(2, "FM RDG", Chr(0xF0E4), Typeface.FONTAWESOME)
'	TabMenu.SetTabTextIcon(3, "PSI RDG", Chr(0xF012), Typeface.FONTAWESOME)
'	TabMenu.SetTabTextIcon(4, "CHLORINE", Chr(0xF171), Typeface.FONTAWESOME)
'	TabMenu.SetTabTextIcon(5, "CONCERNS", Chr(0xF044), Typeface.FONTAWESOME)
'	
'	TabMenu.SetCurrentTab(1)
'	MyToast.Initialize(Activity)
'	PnlTime.Visible = True
'	pnlPumpOff.Visible = False
'	
'	CD.Initialize2(GlobalVar.GreenColor, 30, 0, Colors.Transparent)
'	btnPumpOffSave.Background = CD
'	btnPumpOffSave.Text = Chr(0xE161) & $"  SAVE"$

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
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
End Sub

#End Region

#Region Pump Time
Sub TabMenu_Tab1Click
'	PnlTime.Visible = True
'	pnlFMRdg.Visible = False
'	pnlFMRdg.Visible = False
'	pnlPSIRdg.Visible = False
'	pnlChlorinator.Visible = False
'	pnlConcerns.Visible = False
'	GetPumpTimeRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
End Sub

Sub GetPumpTimeRec(sTrandate As String, iPumpID As Int)
'	Dim SenderFilter As Object
'	Dim sTimeON, sTimeOFF As String
'	Dim iPowerStatus As Int
'	
'	clvTime.Clear
'	
'	If DBaseFunctions.GetPumpPowerStatus(iPumpID) = 0 Then
'		iPowerStatus = 0
'	Else
'		iPowerStatus = 1
'	End If
'
'	Try
'		Starter.strCriteria = "SELECT Header.HeaderID, Header.PumpID, Details.DetailID, Details.PumpOnTime AS TimeOn, Details.PumpOffTime AS TimeOff, Details.TotOpHrs " & _
'						  "FROM TranHeader AS Header " & _
'						  "INNER JOIN OnOffDetails AS Details ON Header.HeaderID = Details.HeaderID " & _
'						  "WHERE Header.PumpID = " & iPumpID & " " & _
'						  "AND Header.TranDate = '" & sTrandate & "' "  & _
'						  "ORDER BY Details.DetailID, TimeOn ASC"
'							  
'		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
'		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
'		
'		If Success Then
'			Dim StartTime As Long = DateTime.Now
'			Do While RS.NextRow
'				Dim TR As TimeRecords
'				TR.Initialize
'				TR.ID = RS.GetInt("DetailID")
'
'				sTimeON = RS.GetString("TimeOn")
'				sTimeOFF = RS.GetString("TimeOff")
'
'				LogColor(sTimeON, Colors.White)
'				LogColor(sTimeOFF, Colors.White)
'				
'				DateTime.TimeFormat = "hh:mm a"
'				TR.lTimeOn = DateTime.TimeParse(sTimeON)
'				If sTimeOFF = "" Or sTimeOFF = Null Then
'					TR.lTimeOff = 0
'					TR.iTotOpHrs = 0
'				Else
'					TR.lTimeOff = DateTime.TimeParse(sTimeOFF)
'					TR.iTotOpHrs = RS.GetDouble("TotOpHrs")
'				End If
'
'				Dim Pnl As B4XView = xui.CreatePanel("")
'				Pnl.SetLayoutAnimated(0, 10dip, 0dip, clvTime.AsView.Width - 10dip, 30dip) 'Panel height + 4 for drop shadow
'				clvTime.Add(Pnl, TR)
'			Loop
'		Else
'			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'			snack.Show
'			Log(LastException)
'		End If
'
'		Log($"List of Time Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvTime.Size} Time Records"$)
'
'	Catch
'		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'		snack.Show
'		Log(LastException)
'	End Try
End Sub

Sub clvTime_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
'	Dim ExtraSize As Int = 15 'List size
'	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvTime.Size - 1)
'		Dim Pnl As B4XView = clvTime.GetPanel(i)
'		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
'			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
'				Dim TR As TimeRecords = clvTime.GetValue(i)
'				Pnl.LoadLayout("ListPumpTimeRecords")
'				lblTimeOn.TextColor = GlobalVar.PriColor
'				DateTime.TimeFormat = "hh:mm a"
'				lblTimeOn.Text = DateTime.Time(TR.lTimeOn)
'				If TR.lTimeOff = 0 Then
'					lblTimeOff.TextColor = GlobalVar.NegColor
'					lblOpHrs.TextColor = GlobalVar.NegColor
'					lblTimeOff.Text = "Running..."
'					lblOpHrs.Text = "---"
'				Else
'					lblTimeOff.TextColor = GlobalVar.PriColor
'					lblOpHrs.TextColor = GlobalVar.PriColor
'					lblTimeOff.Text = DateTime.Time(TR.lTimeOff)
'					lblOpHrs.Text = NumberFormat2(TR.iTotOpHrs,1, 2, 2,True) & $" Hr(s)."$
'				End If
'			End If
'		Else 'Not visible
'			If Pnl.NumberOfViews > 0 Then
'				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
'			End If
'		End If
'	Next

End Sub

Sub clvTime_ItemClick (Index As Int, Value As Object)
'	Dim Rec As TimeRecords = Value
'	Log(Rec.ID)
'
'
'	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
'	GlobalVar.TimeDetailID = Rec.ID
'	lSelectedRecTimeOn = Rec.lTimeOn
'
'	If Rec.lTimeOff = 0 Then
'		ConfirmPumpOff(GlobalVar.PumpHouseID)
'	Else
'		ShowPumpTimeRecDetails(Rec.ID)
'	End If
End Sub

Sub ShowPumpTimeRecDetails (iID As Int)
'	Dim csTitle As CSBuilder
'	Dim sDate, sPCode, sTimeOn, sTimeOff, sPowerSource, sRem As String
'	Dim iPowerSource, iDrainTime, iDrainCum As Int
'	Dim iTotOPHrs As Double
'	Dim rsDetails As Cursor
'	
'	LogColor (iID, Colors.White)
'	Try
'		Starter.strCriteria = "SELECT Header.TranDate, " & _
'						  "Pump.PumpHouseCode, Details.PumpOnTime, Details.PumpOffTime, Details.TotOpHrs, " & _
'						  "Details.PowerSourceID, Details.DrainTime, Details.DrainCum, Details.TimeOnRemarks, Details.TimeOffRemarks " & _
'						  "FROM OnOffDetails AS Details " & _
'						  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
'						  "INNER JOIN tblPumpStation AS Pump ON Pump.StationID = Header.PumpID " & _
'						  "WHERE Details.DetailID = " & iID
'							  
'		rsDetails = Starter.DBCon.ExecQuery(Starter.strCriteria)
'		If rsDetails.RowCount > 0 Then
'			rsDetails.Position = 0
'			sDate = rsDetails.GetString("TranDate")
'			sPCode = rsDetails.GetString("PumpHouseCode")
'			sTimeOn = rsDetails.GetString("PumpOnTime")
'			sTimeOff = rsDetails.GetString("PumpOffTime")
'			iTotOPHrs = rsDetails.GetDouble("TotOpHrs")
'			iPowerSource = rsDetails.GetInt("PowerSourceID")
'			If iPowerSource = 1 Then
'				sPowerSource = $"Electricity"$
'			Else
'				sPowerSource = $"Generator"$
'			End If
'			iDrainTime = rsDetails.GetInt("DrainTime")
'			iDrainCum = rsDetails.GetInt("DrainCum")
'			sRem = rsDetails.GetString("TimeOnRemarks") & " / " & rsDetails.GetString("TimeOffRemarks")
'		Else
''			snack.Initialize("", Activity,$"Cannot fetch detail information due to "$ & LastException.Message,5000)
''			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
''			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
''			snack.Show
''			Log(LastException)
'			Return
'		End If
'		
'	Catch
'		Log(LastException)
'	End Try
'	rsDetails.Close
'	
'	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.BlueColor).Append($"PUMP ON/OFF DETAILS"$).PopAll
'
'	MatDialogBuilder.Initialize("EditTime")
'	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.BlueColor)
'	MatDialogBuilder.NegativeText("EDIT").NegativeColor(GlobalVar.GreenColor)
'	MatDialogBuilder.NeutralText("DELETE").NeutralColor(GlobalVar.RedColor)
'	MatDialogBuilder.Title(csTitle)
'	MatDialogBuilder.Content($"  Pump: ${sPCode}
'	Transaction Date: ${sDate}
'
'	Time On:	${sTimeOn}
'	Time Off:	${sTimeOff}
'	Total Operating Hrs:	${NumberFormat2(iTotOPHrs,1, 2, 2,True)} Hr(s).
'	Power Source:	${sPowerSource}
'	Drain Time:	${iDrainTime} Min(s).
'	Drain CuM:	${iDrainCum} CuM
'	Remarks:	${sRem}"$)
'	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
'	MatDialogBuilder.CanceledOnTouchOutside(False)
'	MatDialogBuilder.Cancelable(True)
'	MatDialogBuilder.Show
End Sub

Private Sub EditTime_ButtonPressed(mDialog As MaterialDialog, sAction As String)
'	Select Case sAction
'		Case mDialog.ACTION_POSITIVE
'		Case mDialog.ACTION_NEGATIVE
'			GlobalVar.blnNewTime = False
'			StartActivity(AddEditTimeRecord)
'		Case mDialog.ACTION_NEUTRAL
''			StartActivity(SetTranDate)
'	End Select
End Sub

Sub btnAddTime_Click
'	GlobalVar.blnNewTime = True
'	If DBaseFunctions.GetPumpPowerStatus(GlobalVar.PumpHouseID) = 1 Then
'		ConfirmPumpOff(GlobalVar.PumpHouseID)
'	Else
'		StartActivity(AddEditTimeRecord)
'	End If
End Sub
#End Region

#Region FM Reading
Sub TabMenu_Tab2Click
'	PnlTime.Visible = False
'	pnlFMRdg.Visible = True
'	pnlPSIRdg.Visible = False
'	pnlChlorinator.Visible = False
'	pnlConcerns.Visible = False
'	
'	GetFMRdgRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
End Sub

Sub GetFMRdgRec(sTrandate As String, iPumpID As Int)
'	Dim SenderFilter As Object
'	clvFM.Clear
'	Try
'		Starter.strCriteria = "SELECT Details.DetailID, Details.RdgTime, " & _
'							  "Details.PrevRdg, Details.PresRdg, Details.PresCum " & _
'							  "FROM ProductionDetails AS Details " & _
'							  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
'							  "WHERE Header.PumpID = " & iPumpID & " " & _
'							  "AND Header.TranDate = '" & sTrandate & "' "  & _
'							  "ORDER BY Details.DetailID, Details.RdgTime ASC"
'							  
'		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
'		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
'		
'		If Success Then
'			Dim StartTime As Long = DateTime.Now
'			Do While RS.NextRow
'				Dim FMRec As FMRecords
'				FMRec.Initialize
'				FMRec.ID = RS.GetInt("DetailID")
'				FMRec.sRdgTime = RS.GetString("RdgTime")
'				FMRec.iPrevRdg = RS.GetInt("PrevRdg")
'				FMRec.iPresRdg = RS.GetInt("PresRdg")
'				FMRec.iTotProd = RS.GetInt("PresCum")
'
'				Dim Pnl As B4XView = xui.CreatePanel("")
'				Pnl.SetLayoutAnimated(0, 10dip, 0, clvFM.AsView.Width - 10dip, 30dip) 'Panel height + 4 for drop shadow
'				clvFM.Add(Pnl, FMRec)
'			Loop
'		Else
'			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'			snack.Show
'			Log(LastException)
'		End If
'
'		Log($"List of FM Reading Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvFM.Size} Flow Meter Reading Records"$)
'
'	Catch
'		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'		snack.Show
'		Log(LastException)
'	End Try
End Sub

Sub clvFM_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
'	Dim ExtraSize As Int = 15 'List size
'	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvFM.Size - 1)
'		Dim Pnl As B4XView = clvFM.GetPanel(i)
'		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
'			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
'				Dim FMRec As FMRecords = clvFM.GetValue(i)
'				Pnl.LoadLayout("ListFMRdg")
'				lblRdgTime.TextColor = GlobalVar.PriColor
'				lblPrevCuM.TextColor = GlobalVar.PriColor
'				lblPresCuM.TextColor = GlobalVar.PriColor
'				lblTotProd.TextColor = GlobalVar.PriColor
'				
'				lblRdgTime.Text = FMRec.sRdgTime
'				lblPrevCuM.Text = FMRec.iPrevRdg
'				lblPresCuM.Text = FMRec.iPresRdg
'				lblTotProd.Text = NumberFormat(FMRec.iTotProd,0,0) & $" CuM"$
'			End If
'		Else 'Not visible
'			If Pnl.NumberOfViews > 0 Then
'				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
'			End If
'		End If
'	Next

End Sub

Sub clvFM_ItemClick (Index As Int, Value As Object)
'	Dim Rec As FMRecords = Value
'	Log(Rec.ID)
'	ShowFMRdgRecDetails(Rec.ID)
'	GlobalVar.FMRdgDetailID = Rec.ID
End Sub

Sub ShowFMRdgRecDetails (iID As Int)
'	Dim csTitle As CSBuilder
'	Dim SenderFilter As Object
'	Dim sDate, sPCode, sReadTime, sRem As String
'	Dim iPreviousRdg, iPresentRdg, iTotCum As Int
'	
'	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
'	Try
'		Starter.strCriteria = "SELECT Header.TranDate, Pump.PumpHouseCode, " & _
'						  	  "Details.DetailID, Details.RdgTime, Details.PrevRdg, Details.PresRdg, " & _
'							  "Details.PresCum, Details.Remarks " & _
'							  "FROM ProductionDetails As Details " & _
'							  "INNER JOIN TranHeader As Header ON Details.HeaderID = Header.HeaderID " & _
'							  "INNER JOIN tblPumpStation AS Pump ON Pump.StationID = Header.PumpID " & _
'							  "WHERE Details.DetailID = " & iID
'							  
'		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
'		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
'		
'		If Success Then
'			RS.Position = 0
'			GlobalVar.FMRdgDetailID = RS.GetInt("DetailID")
'			sDate = RS.GetString("TranDate")
'			sPCode = RS.GetString("PumpHouseCode")
'			sReadTime = RS.GetString("RdgTime")
'			iPreviousRdg = RS.GetInt("PrevRdg")
'			iPresentRdg = RS.GetInt("PresRdg")
'			iTotCum = RS.GetInt("PresCum")
'			sRem = RS.GetString("Remarks")
'		Else
'			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'			snack.Show
'			Log(LastException)
'		End If
'		
'	Catch
'		Log(LastException)
'	End Try
'		
'	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.BlueColor).Append($"FLOW METER READING DETAILS"$).PopAll
'
'	MatDialogBuilder.Initialize("EditFMRdg")
'	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
'	If isLastFMReading(GlobalVar.FMRdgDetailID, GlobalVar.TranHeaderID) = True Then
'		MatDialogBuilder.NegativeText("EDIT").NegativeColor(GlobalVar.GreenColor)
'	Else
'		MatDialogBuilder.NegativeText("")
'	End If
'	MatDialogBuilder.NeutralText("DELETE").NeutralColor(GlobalVar.RedColor)
'	MatDialogBuilder.Title(csTitle)
'	MatDialogBuilder.Content($"  Pump: ${sPCode}
'	Transaction Date: ${sDate}
'
'	Reading Time: ${sReadTime}
'	Present Reading: ${iPresentRdg}
'	Previous Reading: ${iPreviousRdg}
'	Total Prod.: ${NumberFormat(iTotCum,0,0)} CuM
'	Remarks: ${sRem}"$)
'	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
'	MatDialogBuilder.CanceledOnTouchOutside(False)
'	MatDialogBuilder.Cancelable(True)
'	MatDialogBuilder.Show
End Sub

Private Sub EditFMRdg_ButtonPressed(mDialog As MaterialDialog, sAction As String)
'	Select Case sAction
'		Case mDialog.ACTION_POSITIVE
'		Case mDialog.ACTION_NEGATIVE
'			If pnlAddEditFMRdg.Visible = True Then Return
'			pnlAddEditFMRdg.Visible = True
'			lblTitle.Text = $"EDIT FLOW METER READING"$
'			cdReading.Initialize2(Colors.Black,0,0,0)
'			txtFMRdg.Background = cdReading
'			CD.Initialize2(GlobalVar.GreenColor, 30, 0, Colors.Transparent)
'			btnSaveUpdateFMRdg.Background = CD
'			btnSaveUpdateFMRdg.Text = Chr(0xE161) & " UPDATE READING"
'			cdRem.Initialize(Colors.Transparent, 0)
'			txtFMRemarks.Background = cdRem
'			txtFMRdg.Text = GetFMReading(GlobalVar.FMRdgDetailID)
'			txtFMRemarks.Text = GetFMReadingRemarks(GlobalVar.FMRdgDetailID)
'			txtFMRdg.RequestFocus
'			txtFMRdg.SelectAll
'			kboard.SetCustomFilter(txtFMRdg,txtFMRdg.INPUT_TYPE_NUMBERS, "0123456789")
'			kboard.SetLengthFilter(txtFMRdg, 10)
'			kboard.ShowKeyboard(txtFMRdg)
'			GlobalVar.blnNewFMRdg = False
'		Case mDialog.ACTION_NEUTRAL
''			StartActivity(SetTranDate)
'	End Select
End Sub

Private Sub GetFMReading(iDetailID As Int) As String
'	Dim sRetval As String
'	sRetval = ""
'	Try
'		sRetval = Starter.DBCon.ExecQuerySingleResult("SELECT PresRdg FROM ProductionDetails WHERE DetailID = " & iDetailID)
'		LogColor(sRetval, Colors.Yellow)
'	Catch
'		sRetval = ""
'		Log(LastException)
'	End Try
'	Return sRetval
End Sub

Private Sub GetFMReadingRemarks(iDetailID As Int) As String
'	Dim sRetval As String
'	sRetval = ""
'	Try
'		sRetval = Starter.DBCon.ExecQuerySingleResult("SELECT Remarks FROM ProductionDetails WHERE DetailID = " & iDetailID)
'		LogColor(sRetval, Colors.Yellow)
'	Catch
'		sRetval = ""
'		Log(LastException)
'	End Try
'	Return sRetval
End Sub

Sub btnAddFM_Click
'	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
'	If GlobalVar.TranHeaderID = 0 Then
'		snack.Initialize("", Activity, $"You cannot add Flow Meter Reading due to you didn't specify Pump Time yet."$, snack.DURATION_LONG)
'		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'		snack.Show
'		Return
'	End If
'	
'	If pnlAddEditFMRdg.Visible = True Then Return
'	
'	pnlAddEditFMRdg.Visible = True
'	lblTitle.Text = $"ADD NEW FLOW METER READING"$
'	cdReading.Initialize2(Colors.Black,0,0,0)
'	txtFMRdg.Background = cdReading
''	CD.Initialize2(GlobalVar.GreenColor, 30, 0, Colors.Transparent)
''	btnSaveUpdateFMRdg.Background = CD
'	MyFunctions.SetButton(btnSaveUpdateFMRdg, 25, 25, 25, 25, 25, 25, 25, 25)
'	btnSaveUpdateFMRdg.Text = Chr(0xE161) & " SAVE READING"
'	
'	cdRem.Initialize(Colors.Transparent, 0)
'	txtFMRemarks.Background = cdRem
'	txtFMRdg.Text = ""
'	txtFMRemarks.Text = ""
'	txtFMRdg.RequestFocus
'	kboard.SetCustomFilter(txtFMRdg,txtFMRdg.INPUT_TYPE_NUMBERS, "0123456789")
'	kboard.SetLengthFilter(txtFMRdg, 6)
'	kboard.ShowKeyboard(txtFMRdg)
'	GlobalVar.blnNewFMRdg = True
End Sub

Sub pnlAddEditFMRdg_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Sub btnSaveUpdateFMRdg_Click
'	MyToast.Initialize(Activity)
'	kboard.HideKeyboard
'	If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtFMRdg.Text)) <= 0 Then
'		MyToast.DefaultTextColor = Colors.White
'		MyToast.pnl.Color = GlobalVar.RedColor
'		MyFunctions.MyToastMsg(MyToast, $"Cannot save Blank Reading!!"$)
'		vibration.vibrateOnce(2000)
'		Return
'	End If
'	
'	Select GlobalVar.blnNewFMRdg
'		Case True 'New
'			iLastReading = DBaseFunctions.GetLastFMReading(GlobalVar.PumpHouseID)
'			LogColor(iLastReading, Colors.Yellow)
'			If GlobalVar.SF.Val(txtFMRdg.Text) = iLastReading Then
'				MyToast.DefaultTextColor = Colors.White
'				MyToast.pnl.Color = GlobalVar.RedColor
'				MyFunctions.MyToastMsg(MyToast, $"Cannot save Blank Reading!"$)
'				Return
'			Else If GlobalVar.SF.Val(txtFMRdg.Text) < iLastReading Then
'				MyToast.DefaultTextColor = Colors.White
'				MyToast.pnl.Color = GlobalVar.RedColor
'				MyFunctions.MyToastMsg(MyToast, $"Cannot save reading due to Negative CuM Production!"$)
'				vibration.vibrateOnce(2000)
'				Return
'				'Negative Production
'			End If
'			If Not(SaveFMRdg) Then Return
'			If Not(UpdateTranHeaderFM(GlobalVar.TranHeaderID)) Then Return
'			If Not(UpdateLastFMRdg(GlobalVar.PumpHouseID)) Then Return
'			ShowSaveFMSuccess
'		
'		Case False 'Edit
'			iLastReading = GetPreviousRdg(GlobalVar.FMRdgDetailID)
'			LogColor(iLastReading, Colors.Yellow)
'			If GlobalVar.SF.Val(txtFMRdg.Text) = iLastReading Then
'				MyToast.DefaultTextColor = Colors.White
'				MyToast.pnl.Color = GlobalVar.RedColor
'				MyFunctions.MyToastMsg(MyToast, $"Cannot save Blank Reading!"$ & LastException.Message)
'				Return
'			Else If txtFMRdg.Text < iLastReading Then
'				MyToast.DefaultTextColor = Colors.White
'				MyToast.pnl.Color = GlobalVar.RedColor
'				MyFunctions.MyToastMsg(MyToast, $"Cannot save reading due to Negative CuM Production!"$ & LastException.Message)
'				vibration.vibrateOnce(2000)
'				Return
'			End If
'			If Not(UpdateFMRdg(GlobalVar.FMRdgDetailID)) Then Return
'			If Not(UpdateTranHeaderFM(GlobalVar.TranHeaderID)) Then Return
'			If Not(UpdateLastFMRdg(GlobalVar.PumpHouseID)) Then Return
'			ShowSaveFMSuccess
'	End Select
End Sub

Sub btnFMRdgCancel_Click
'	kboard.HideKeyboard
'	pnlAddEditFMRdg.Visible = False
End Sub

Private Sub SaveFMRdg() As Boolean
'	Dim bRetVal As Boolean
'	Dim lTime As Long
'	Dim sRdgTime As String
'	Dim iTotCuM As Int
'	Dim sDateTime As String
'	Dim lDate As Long
'	
'	lDate = DateTime.Now
'	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
'	sDateTime = DateTime.Date(lDate)
'
'	
'	lTime = DateTime.TimeParse(DateTime.Time(DateTime.Now))
'	DateTime.TimeFormat = "hh:mm a"
'	sRdgTime = DateTime.Time(lTime)
'	
'	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
'	iLastReading = DBaseFunctions.GetLastFMReading(GlobalVar.PumpHouseID)
'	iTotCuM = GlobalVar.SF.Val(txtFMRdg.Text) - iLastReading
'
'	LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Yellow)
'
'	Starter.DBCon.BeginTransaction
'	Try
'		Starter.DBCon.ExecNonQuery2("INSERT INTO ProductionDetails VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
'								   Array As Object(GlobalVar.TranHeaderID, sRdgTime, iLastReading, txtFMRdg.Text, iTotCuM, txtFMRemarks.Text, $"0"$, Null, Null, GlobalVar.UserID, sDateTime, Null, Null))
'		Starter.DBCon.TransactionSuccessful
'		bRetVal = True
'	Catch
'		Log(LastException)
'		MyToast.DefaultTextColor = Colors.White
'		MyToast.pnl.Color = GlobalVar.RedColor
'		MyFunctions.MyToastMsg(MyToast, $"Unable to save Flow Meter Reading due to "$ & LastException.Message)
'		bRetVal = False
'	End Try
'	Starter.DBCon.EndTransaction
'	Return bRetVal
End Sub

Private Sub UpdateTranHeaderFM(iTranHeaderID As Int) As Boolean
'	Dim bRetVal As Boolean
'	Dim GTotProd As Double
'
'	Dim lngDateTime As Long
'	Dim sModifiedAt As String
'	
'	DateTime.DateFormat = "yyyy-MM-dd"
'	DateTime.TimeFormat = "hh:mm:ss a"
'	lngDateTime = DateTime.Now
'	sModifiedAt = DateTime.Date(lngDateTime) & $" "$ & DateTime.Time(lngDateTime)
'
'	Dim rsDetail As Cursor
'	
'	Starter.strCriteria = "SELECT sum(PresCum) as GTotProd " & _
'						  "FROM ProductionDetails WHERE HeaderID = " & iTranHeaderID & " " & _
'						  "GROUP BY HeaderID"
'	rsDetail = Starter.DBCon.ExecQuery(Starter.strCriteria)
'	If rsDetail.RowCount > 0 Then
'		rsDetail.Position = 0
'		GTotProd = rsDetail.GetDouble("GTotProd")
'	Else
'		GTotProd = 0
'	End If
'	rsDetail.Close
'	
'	bRetVal = False
'	Starter.DBCon.BeginTransaction
'	Try
'		Starter.strCriteria = "UPDATE TranHeader SET " & _
'							  "TotProduction = ?, " & _
'							  "ModifiedBy = ?, " & _
'							  "ModifiedAt = ? " & _
'							  "WHERE HeaderID = " & iTranHeaderID
'							  
'		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(GTotProd, GlobalVar.UserID, sModifiedAt))
'		Starter.DBCon.TransactionSuccessful
'		bRetVal = True
'	Catch
'		Log(LastException)
'		bRetVal = False
'	End Try
'	Starter.DBCon.EndTransaction
'	Return bRetVal
End Sub

Private Sub UpdateFMRdg(iDetailID As Int) As Boolean
'	Dim bRetVal As Boolean
'	Dim iTotCuM As Int
'	Dim sDateTime As String
'	Dim lDate As Long
'	
'	lDate = DateTime.Now
'	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
'	sDateTime = DateTime.Date(lDate)
'
'	
'	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
'	iLastReading = GetPreviousRdg(GlobalVar.FMRdgDetailID)
'
'	iTotCuM = GlobalVar.SF.Val(txtFMRdg.Text) - iLastReading
'
'	LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Yellow)
'
'	Starter.DBCon.BeginTransaction
'	Try
'		Starter.strCriteria = "UPDATE ProductionDetails SET " & _
'							  "PresRdg = ?, " & _
'							  "PresCum = ?, " & _
'							  "Remarks = ?, " & _
'							  "ModifiedBy = ?, " & _
'							  "ModifiedAt = ? " & _
'							  "WHERE DetailID = " & iDetailID
'							  
'		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(txtFMRdg.Text, iTotCuM, txtFMRemarks.Text, GlobalVar.UserID, sDateTime))
'		Starter.DBCon.TransactionSuccessful
'
'		bRetVal = True
'	Catch
'		Log(LastException)
'		MyToast.DefaultTextColor = Colors.White
'		MyToast.pnl.Color = GlobalVar.RedColor
'		MyFunctions.MyToastMsg(MyToast, $"Unable to save Flow Meter Reading due to "$ & LastException.Message)
'		bRetVal = False
'	End Try
'	Starter.DBCon.EndTransaction
'	Return bRetVal
End Sub

Private Sub UpdateLastFMRdg(iPumpHouseID As Int) As Boolean
'	Dim bRetVal As Boolean
'	bRetVal = False
'	Starter.DBCon.BeginTransaction
'	Try
'		Starter.strCriteria = "UPDATE tblPumpStation SET " & _
'							  "LastRdg = ? " & _
'							  "WHERE StationID = " & iPumpHouseID
'							  
'		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(txtFMRdg.Text))
'		Starter.DBCon.TransactionSuccessful
'		bRetVal = True
'	Catch
'		Log(LastException)
'		bRetVal = False
'	End Try
'	Starter.DBCon.EndTransaction
'	Return bRetVal
'End Sub
'
'Private Sub ShowSaveFMSuccess()
'	Dim csTitle As CSBuilder
'	Dim csContent As CSBuilder
'	
'	MatDialogBuilder.Initialize("SaveFMRdgSuccess")
'	If GlobalVar.blnNewFMRdg = True Then
'		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
'		csContent.Initialize.Size(14).Color(Colors.Black).Append($"New Flow Meter Reading has been successfully saved!"$).PopAll
'		MatDialogBuilder.NeutralText($"Add PSI Reading?"$).NeutralColor(GlobalVar.NegColor)
'	Else
'		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
'		csContent.Initialize.Size(14).Color(Colors.Black).Append($"Flow Meter Reading has been successfully updated!"$).PopAll
'		MatDialogBuilder.NeutralText($""$)
'	End If
'	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
'	MatDialogBuilder.Title(csTitle)
'	MatDialogBuilder.Content(csContent)
'	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
'	MatDialogBuilder.CanceledOnTouchOutside(False)
'	MatDialogBuilder.Cancelable(False)
'	MatDialogBuilder.Show
End Sub

Private Sub SaveFMRdgSuccess_ButtonPressed(mDialog As MaterialDialog, sAction As String)
'	Select Case sAction
'		Case mDialog.ACTION_POSITIVE
'			kboard.HideKeyboard
'			pnlAddEditFMRdg.Visible = False
'			GetFMRdgRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
'		Case mDialog.ACTION_NEUTRAL
'			pnlAddEditFMRdg.Visible = False
'			btnAddPSI_Click
'	End Select
End Sub

Private Sub isLastFMReading(iDetailsID As Int, iHeaderID As Int) As Boolean
'	Dim bRetVal As Boolean
'	Dim idCheck As Int
'	bRetVal = False
'	
'	Try
'		idCheck = Starter.DBCon.ExecQuerySingleResult("SELECT Max(DetailID) FROM ProductionDetails WHERE HeaderID = " & iHeaderID & " " & _
'													  "GROUP BY HeaderID")
'		LogColor($"Selected ID: "$ & iDetailsID & $" - Last ID: "$ & idCheck, Colors.Yellow)
'
'		If iDetailsID = idCheck Then
'			bRetVal = True
'		Else
'			bRetVal = False
'		End If
'	Catch
'		bRetVal = False
'		Log(LastException)
'	End Try
'	Return bRetVal
End Sub

Private Sub GetPreviousRdg(iDetailID As Int) As Int
'	Dim iRetval As Int
'	Try
'		Starter.strCriteria = "SELECT PrevRdg FROM ProductionDetails WHERE DetailID = " & iDetailID
'		LogColor(Starter.strCriteria, Colors.Blue)
'		
'		iRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
'	Catch
'		ToastMessageShow($"Unable to fetch Pump Last Reading due to "$ & LastException.Message, False)
'		Log(LastException)
'		iRetval = 0
'	End Try
'	Return iRetval
End Sub
#End Region

#Region PSI Reading
Sub TabMenu_Tab3Click
'	PnlTime.Visible = False
'	pnlFMRdg.Visible = False
'	pnlPSIRdg.Visible = True
'	pnlChlorinator.Visible = False
'	pnlConcerns.Visible = False
'	
'	GetPSIRdgRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
End Sub

Sub GetPSIRdgRec(sTrandate As String, iPumpID As Int)
'	Dim SenderFilter As Object
'	clvPSI.Clear
'	Try
'		Starter.strCriteria = "SELECT Details.DetailID, Details.RdgTime, Details.PSIReading " & _
'							  "FROM PressureRdgDetails AS Details " & _
'							  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
'							  "WHERE Header.PumpID = " & iPumpID & " " & _
'							  "AND Header.TranDate = '" & sTrandate & "' "  & _
'							  "ORDER BY Details.DetailID, Details.RdgTime ASC"
'							  
'		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
'		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
'		
'		If Success Then
'			Dim StartTime As Long = DateTime.Now
'			Do While RS.NextRow
'				Dim PSIRec As PSIRecords
'				PSIRec.Initialize
'				PSIRec.ID = RS.GetInt("DetailID")
'				PSIRec.sRdgTime = RS.GetString("RdgTime")
'				PSIRec.iPSIRdg = RS.GetInt("PSIReading")
'
'				Dim Pnl As B4XView = xui.CreatePanel("")
'				Pnl.SetLayoutAnimated(0, 10dip, 0, clvPSI.AsView.Width - 10dip, 30dip) 'Panel height + 4 for drop shadow
'				clvPSI.Add(Pnl, PSIRec)
'			Loop
'		Else
'			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'			snack.Show
'			Log(LastException)
'		End If
'
'		Log($"List of PSI Reading Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvPSI.Size} PSI Reading Records"$)
'
'	Catch
'		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'		snack.Show
'		Log(LastException)
'	End Try
End Sub

Sub clvPSI_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
'	Dim ExtraSize As Int = 15 'List size
'	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvPSI.Size - 1)
'		Dim Pnl As B4XView = clvPSI.GetPanel(i)
'		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
'			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
'				Dim PSIRec As PSIRecords = clvPSI.GetValue(i)
'				Pnl.LoadLayout("ListPSIRecords")
'				lblPSIRdgTime.TextColor = GlobalVar.PriColor
'				lblPSIRdg.TextColor = GlobalVar.PriColor
'				
'				lblPSIRdgTime.Text = PSIRec.sRdgTime
'				lblPSIRdg.Text = NumberFormat(PSIRec.iPSIRdg,0,2) & $" PSI"$
'			End If
'		Else 'Not visible
'			If Pnl.NumberOfViews > 0 Then
'				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
'			End If
'		End If
'	Next

End Sub

Sub clvPSI_ItemClick (Index As Int, Value As Object)
'	Dim Rec As PSIRecords = Value
'	Log(Rec.ID)
'	ShowPSIRdgRecDetails(Rec.ID)
'	GlobalVar.PSIRdgDetailID = Rec.ID
End Sub

Sub ShowPSIRdgRecDetails (iID As Int)
'	Dim csTitle As CSBuilder
'	Dim SenderFilter As Object
'	Dim sDate, sPCode, sReadTime, sRem As String
'	Dim iPressureRdg As Int
'	
'	Starter.strCriteria = "SELECT Header.TranDate, Pump.PumpHouseCode, " & _
'						  "Details.RdgTime, Details.PSIReading, Details.Remarks " & _
'						  "FROM PressureRdgDetails AS Details " & _
'						  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
'						  "INNER JOIN tblPumpStation AS Pump ON Pump.StationID = Header.PumpID " & _
'						  "WHERE Details.DetailID = " & iID
'							  
'	SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
'	Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
'		
'	If Success Then
'		RS.Position = 0
'		sDate = RS.GetString("TranDate")
'		sPCode = RS.GetString("PumpHouseCode")
'		sReadTime = RS.GetString("RdgTime")
'		iPressureRdg = RS.GetInt("PSIReading")
'		sRem = RS.GetString("Remarks")
'	Else
'		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'		snack.Show
'		Log(LastException)
'	End If
'	
'	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.BlueColor).Append($"PRESSURE READING DETAILS"$).PopAll
'
'	MatDialogBuilder.Initialize("EditPSIRdg")
'	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
'	LogColor(GlobalVar.PSIRdgDetailID, Colors.Yellow)
'	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
'	If isLastPSIReading(GlobalVar.PSIRdgDetailID, GlobalVar.TranHeaderID) = True Then
'		MatDialogBuilder.NegativeText("EDIT").NegativeColor(GlobalVar.GreenColor)
'	Else
'		MatDialogBuilder.NegativeText("")
'	End If
'	MatDialogBuilder.NeutralText("DELETE").NeutralColor(GlobalVar.RedColor)
'	MatDialogBuilder.Title(csTitle)
'	MatDialogBuilder.Content($"  Pump: ${sPCode}
'	Transaction Date: ${sDate}
'
'	Reading Time: ${sReadTime}
'	Pressure Reading: ${iPressureRdg}  PSI
'	Remarks: ${sRem}"$)
'	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
'	MatDialogBuilder.CanceledOnTouchOutside(False)
'	MatDialogBuilder.Cancelable(True)
'	MatDialogBuilder.Show
End Sub

Private Sub EditPSIRdg_ButtonPressed(mDialog As MaterialDialog, sAction As String)
'	Select Case sAction
'		Case mDialog.ACTION_NEGATIVE
'			If pnlAddEditPSIRdg.Visible = True Then Return
'			pnlAddEditPSIRdg.Visible = True
'			cdReading.Initialize2(Colors.Black,0,0,0)
'			txtPSIRdg.Background = cdReading
'			CD.Initialize2(GlobalVar.GreenColor, 30, 0, Colors.Transparent)
'			btnSaveUpdatePSIRdg.Background = CD
'			btnSaveUpdatePSIRdg.Text = Chr(0xE161) & " SAVE READING"
'	
'			cdRem.Initialize(Colors.Transparent, 0)
'			txtPSIRemarks.Background = cdRem
'			txtPSIRdg.Text = GetPSIReading(GlobalVar.PSIRdgDetailID)
'			txtPSIRemarks.Text = GetPSIReadingRemarks(GlobalVar.PSIRdgDetailID)
'			txtPSIRdg.SelectAll
'			txtPSIRdg.RequestFocus
'			kboard.SetCustomFilter(txtPSIRdg,txtFMRdg.INPUT_TYPE_NUMBERS, "0123456789")
'			kboard.SetLengthFilter(txtPSIRdg, 10)
'			kboard.ShowKeyboard(txtPSIRdg)
'			GlobalVar.blnNewPSIRdg = False
'	End Select
End Sub

Sub btnAddPSI_Click
'	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
'
'	If GlobalVar.TranHeaderID = 0 Then
'		snack.Initialize("", Activity, $"You cannot add PSI Reading due to you didn't specify Pump Time yet."$, snack.DURATION_LONG)
'		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'		snack.Show
'		Return
'	End If
'	
'	If pnlAddEditPSIRdg.Visible = True Then Return
'	pnlAddEditPSIRdg.Visible = True
'	cdReading.Initialize2(Colors.Black,0,0,0)
'	txtPSIRdg.Background = cdReading
'	MyFunctions.SetButton(btnSaveUpdatePSIRdg, 25, 25, 25, 25, 25, 25, 25, 25)
'	btnSaveUpdatePSIRdg.Text = Chr(0xE161) & " SAVE READING"
'	
'	cdRem.Initialize(Colors.Transparent, 0)
'	txtPSIRemarks.Background = cdRem
'	txtPSIRdg.Text = ""
'	txtPSIRemarks.Text = ""
'	txtPSIRdg.RequestFocus
'	kboard.SetCustomFilter(txtPSIRdg,txtFMRdg.INPUT_TYPE_NUMBERS, "0123456789")
'	kboard.SetLengthFilter(txtPSIRdg, 10)
'	kboard.ShowKeyboard(txtPSIRdg)
'	GlobalVar.blnNewPSIRdg = True
End Sub

Sub btnSaveUpdatePSIRdg_Click
'	If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtPSIRdg.Text)) <= 0 Then
'		MyToast.DefaultTextColor = Colors.White
'		MyToast.pnl.Color = GlobalVar.RedColor
'		MyFunctions.MyToastMsg(MyToast, $"Cannot save Blank Reading!"$ & LastException.Message)
'		vibration.vibrateOnce(2000)
'		kboard.HideKeyboard
'		Return
'	End If
'	
'	Try
'		Select Case GlobalVar.blnNewPSIRdg
'			Case True 'New
'				If Not(SavePSIRdg) Then Return
'				If Not(UpdateTranHeaderPSI(GlobalVar.TranHeaderID)) Then Return
'				ShowSavePSISuccess
'		
'			Case False 'Edit
'				If Not(UpdatePSIRdg(GlobalVar.PSIRdgDetailID)) Then Return
'				If Not(UpdateTranHeaderPSI(GlobalVar.TranHeaderID)) Then Return
'				ShowSavePSISuccess
'		End Select
'	Catch
'		MyToast.DefaultTextColor = Colors.White
'		MyToast.pnl.Color = GlobalVar.RedColor
'		MyFunctions.MyToastMsg(MyToast, $"Cannot save/update due to "$ & LastException.Message)
'		Log(LastException)
'	End Try
End Sub

Private Sub SavePSIRdg() As Boolean
'	Dim bRetVal As Boolean
'	Dim lTime As Long
'	Dim sRdgTime As String
'	Dim sDateTime As String
'	Dim lDate As Long
'	
'	lDate = DateTime.Now
'	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
'	sDateTime = DateTime.Date(lDate)
'
'	lTime = DateTime.TimeParse(DateTime.Time(DateTime.Now))
'	DateTime.TimeFormat = "hh:mm a"
'	sRdgTime = DateTime.Time(lTime)
'	
'	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
'
'	LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Yellow)
'
'	Starter.DBCon.BeginTransaction
'	Try
'		Starter.DBCon.ExecNonQuery2("INSERT INTO PressureRdgDetails VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
'								   Array As Object(GlobalVar.TranHeaderID, sRdgTime, txtPSIRdg.Text, txtPSIRemarks.Text, $"0"$, Null, Null, GlobalVar.UserID, sDateTime, Null, Null))
'		Starter.DBCon.TransactionSuccessful
'		bRetVal = True
'	Catch
'		Log(LastException)
'		MyToast.DefaultTextColor = Colors.White
'		MyToast.pnl.Color = GlobalVar.RedColor
'		MyFunctions.MyToastMsg(MyToast, $"Unable to save Pressure Reading due to "$ & LastException.Message)
'		bRetVal = False
'	End Try
'	Starter.DBCon.EndTransaction
'	Return bRetVal
End Sub

Private Sub UpdateTranHeaderPSI(iTranHeaderID As Int) As Boolean
'	Dim bRetVal As Boolean
'	Dim GMinPSI, GMaxPSI, GAvePSI As Double
'
'	Dim lngDateTime As Long
'	Dim sModifiedAt As String
'	
'	DateTime.DateFormat = "yyyy-MM-dd"
'	DateTime.TimeFormat = "hh:mm:ss a"
'	lngDateTime = DateTime.Now
'	sModifiedAt = DateTime.Date(lngDateTime) & $" "$ & DateTime.Time(lngDateTime)
'
'	Dim rsDetail As Cursor
'	
'	Starter.strCriteria = "SELECT Min(PressureRdgDetails.PSIReading) AS MinPSI, " & _
'						  "Max(PressureRdgDetails.PSIReading) AS MaxPSI, " & _
'						  "Avg(PressureRdgDetails.PSIReading) AS AvePSI " & _
'						  "FROM PressureRdgDetails " & _
'						  "WHERE HeaderID = " & iTranHeaderID & " " & _
'						  "GROUP BY HeaderID"
'	rsDetail = Starter.DBCon.ExecQuery(Starter.strCriteria)
'	If rsDetail.RowCount > 0 Then
'		rsDetail.Position = 0
'		GMinPSI = rsDetail.GetDouble("MinPSI")
'		GMaxPSI = rsDetail.GetDouble("MaxPSI")
'		GAvePSI = rsDetail.GetDouble("AvePSI")
'	Else
'		GMinPSI = 0
'		GMaxPSI = 0
'		GAvePSI = 0
'	End If
'	rsDetail.Close
'	
'	bRetVal = False
'	Starter.DBCon.BeginTransaction
'	Try
'		Starter.strCriteria = "UPDATE TranHeader SET " & _
'							  "MinPSI = ?, " & _
'							  "MaxPSI = ?, " & _
'							  "AvePSI = ?, " & _
'							  "ModifiedBy = ?, " & _
'							  "ModifiedAt = ? " & _
'							  "WHERE HeaderID = " & iTranHeaderID
'							  
'		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(GMinPSI, GMaxPSI, GAvePSI, GlobalVar.UserID, sModifiedAt))
'		Starter.DBCon.TransactionSuccessful
'		bRetVal = True
'	Catch
'		Log(LastException)
'		bRetVal = False
'	End Try
'	Starter.DBCon.EndTransaction
'	Return bRetVal
End Sub

Private Sub ShowSavePSISuccess()
'	Dim csTitle As CSBuilder
'	Dim csContent As CSBuilder
'	
'	If GlobalVar.blnNewFMRdg = True Then
'		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
'		csContent.Initialize.Size(14).Color(Colors.Black).Append($"New Pump Pressure Reading has been successfully saved!"$).PopAll
'	Else
'		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
'		csContent.Initialize.Size(14).Color(Colors.Black).Append($"Pump Pressure Reading has been successfully updated!"$).PopAll
'	End If
'	
'	MatDialogBuilder.Initialize("SavePSIRdgSuccess")
'	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
'	MatDialogBuilder.Title(csTitle)
'	MatDialogBuilder.Content(csContent)
'	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
'	MatDialogBuilder.CanceledOnTouchOutside(False)
'	MatDialogBuilder.Cancelable(False)
'	MatDialogBuilder.Show
End Sub

Private Sub SavePSIRdgSuccess_ButtonPressed(mDialog As MaterialDialog, sAction As String)
'	Select Case sAction
'		Case mDialog.ACTION_POSITIVE
'			kboard.HideKeyboard
'			pnlAddEditPSIRdg.Visible = False
'			GetPSIRdgRec(GlobalVar.TranDate,GlobalVar.PumpHouseID)
'		Case mDialog.ACTION_NEGATIVE
'	End Select
End Sub

Sub btnPSIRdgCancel_Click
'	kboard.HideKeyboard
'	pnlAddEditPSIRdg.Visible = False
End Sub

Private Sub GetPSIReading(iDetailID As Int) As String
	Dim sRetval As String
	sRetval = ""
	Try
		sRetval = Starter.DBCon.ExecQuerySingleResult("SELECT PSIReading FROM PressureRdgDetails WHERE DetailID = " & iDetailID)
		LogColor(sRetval, Colors.Yellow)
	Catch
		sRetval = ""
		Log(LastException)
	End Try
	Return sRetval
End Sub

Private Sub GetPSIReadingRemarks(iDetailID As Int) As String
	Dim sRetval As String
	sRetval = ""
	Try
		sRetval = Starter.DBCon.ExecQuerySingleResult("SELECT Remarks FROM PressureRdgDetails WHERE DetailID = " & iDetailID)
		LogColor(sRetval, Colors.Yellow)
	Catch
		sRetval = ""
		Log(LastException)
	End Try
	Return sRetval
End Sub

Private Sub UpdatePSIRdg(iDetailID As Int) As Boolean
'	Dim bRetVal As Boolean
'	Dim sDateTime As String
'	Dim lDate As Long
'	
'	lDate = DateTime.Now
'	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
'	sDateTime = DateTime.Date(lDate)
'
'	
'	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
'
'	LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Yellow)
'
'	Starter.DBCon.BeginTransaction
'	Try
'		Starter.strCriteria = "UPDATE PressureRdgDetails SET " & _
'							  "PSIReading = ?, " & _
'							  "Remarks = ?, " & _
'							  "ModifiedBy = ?, " & _
'							  "ModifiedAt = ? " & _
'							  "WHERE DetailID = " & iDetailID
'							  
'		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(txtPSIRdg.Text, txtPSIRemarks.Text, GlobalVar.UserID, sDateTime))
'		Starter.DBCon.TransactionSuccessful
'
'		bRetVal = True
'	Catch
'		Log(LastException)
'		MyToast.DefaultTextColor = Colors.White
'		MyToast.pnl.Color = GlobalVar.RedColor
'		MyFunctions.MyToastMsg(MyToast, $"Unable to update Pump Pressure Reading due to "$ & LastException.Message)
'		bRetVal = False
'	End Try
'	Starter.DBCon.EndTransaction
'	Return bRetVal
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
Sub TabMenu_Tab4Click
'	PnlTime.Visible = False
'	pnlFMRdg.Visible = False
'	pnlPSIRdg.Visible = False
'	pnlChlorinator.Visible = True
'	pnlConcerns.Visible = False
'	
'	GetChlorineRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
'End Sub
'
'Sub GetChlorineRec(sTrandate As String, iPumpID As Int)
'	Dim SenderFilter As Object
'	clvChlorine.Clear
'	Try
'		Starter.strCriteria = "SELECT Details.DetailID, Details.TimeReplenished, Details.ChlorineType, Details.Volume, Details.UoM " & _
'							  "FROM ChlorineDetails AS Details " & _
'							  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
'							  "WHERE Header.PumpID = " & iPumpID & " " & _
'							  "AND Header.TranDate = '" & sTrandate & "' "  & _
'							  "ORDER BY Details.DetailID, TimeReplenished ASC"
'							  
'		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
'		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
'		
'		If Success Then
'			Dim StartTime As Long = DateTime.Now
'			Do While RS.NextRow
'				Dim CR As ChlorineRecords
'				CR.Initialize
'				CR.ID = RS.GetInt("DetailID")
'				CR.sTimeRep = RS.GetString("TimeReplenished")
'				CR.sChlorineType = RS.GetString("ChlorineType")
'				CR.iVolume = RS.GetInt("Volume")
'				sUnit = RS.GetString("UoM")
'
'				Dim Pnl As B4XView = xui.CreatePanel("")
'				Pnl.SetLayoutAnimated(0, 10dip, 0, clvChlorine.AsView.Width - 10dip, 30dip) 'Panel height + 4 for drop shadow
'				clvChlorine.Add(Pnl, CR)
'			Loop
'		Else
'			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'			snack.Show
'			Log(LastException)
'		End If
'
'		Log($"List of Time Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvChlorine.Size} Chlorine Records"$)
'
'	Catch
'		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'		snack.Show
'		Log(LastException)
'	End Try
End Sub

Sub clvChlorine_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
'	Dim ExtraSize As Int = 15 'List size
'	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvChlorine.Size - 1)
'		Dim Pnl As B4XView = clvChlorine.GetPanel(i)
'		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
'			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
'				Dim CR As ChlorineRecords = clvChlorine.GetValue(i)
'				Pnl.LoadLayout("ListChlorinatorRecords")
'				lblTimeRep.TextColor = GlobalVar.PriColor
'				lblChlorineType.TextColor = GlobalVar.PriColor
'				lblVolume.TextColor = GlobalVar.PriColor
'				
'				lblTimeRep.Text = CR.sTimeRep
'				lblChlorineType.Text = CR.sChlorineType
'				lblVolume.Text = CR.iVolume & $" "$ & sUnit & $"(s)"$
'			End If
'		Else 'Not visible
'			If Pnl.NumberOfViews > 0 Then
'				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
'			End If
'		End If
'	Next

End Sub

Sub clvChlorine_ItemClick (Index As Int, Value As Object)
'	Dim Rec As ChlorineRecords = Value
'	Log(Rec.ID)
'	ShowChlorinatorRecDetails(Rec.ID)
'	GlobalVar.ChlorineDetailID = Rec.ID
End Sub

Sub ShowChlorinatorRecDetails (iID As Int)
'	Dim csTitle As CSBuilder
'	Dim SenderFilter As Object
'	Dim sDate, sPCode, sTimeReplenished, sChloType, sRem As String
'	Dim iKG As Int
'	
'	Starter.strCriteria = "SELECT Header.TranDate, Pump.PumpHouseCode, " & _
'						  "Details.TimeReplenished, Details.ChlorineType, Details.Volume, Details.Remarks " & _
'						  "FROM ChlorineDetails AS Details " & _
'						  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
'						  "INNER JOIN tblPumpStation AS Pump ON Pump.StationID = Header.PumpID " & _
'						  "WHERE Details.DetailID = " & iID
'							  
'	SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
'	Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
'		
'	If Success Then
'		RS.Position = 0
'		sDate = RS.GetString("TranDate")
'		sPCode = RS.GetString("PumpHouseCode")
'		sTimeReplenished = RS.GetString("TimeReplenished")
'		sChloType = RS.GetString("ChlorineType")
'		iKG = RS.GetInt("Volume")
'		sRem = RS.GetString("Remarks")
'	Else
'		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'		snack.Show
'		Log(LastException)
'	End If
'	
'	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.BlueColor).Append($"CHLORINATOR RECORD DETAILS"$).PopAll
'
'	MatDialogBuilder.Initialize("EditChlorineTime")
'	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.BlueColor)
'	MatDialogBuilder.NegativeText("EDIT").NegativeColor(GlobalVar.GreenColor)
'	MatDialogBuilder.NeutralText("DELETE").NeutralColor(GlobalVar.RedColor)
'	MatDialogBuilder.Title(csTitle)
'	MatDialogBuilder.Content($"  Pump: ${sPCode}
'	Transaction Date: ${sDate}
'
'	Time Replenished: ${sTimeReplenished}
'	Chlorine Type: ${sChloType}
'	Volume: ${iKG} Kg(s).
'	Remarks: ${sRem}"$)
'	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
'	MatDialogBuilder.CanceledOnTouchOutside(False)
'	MatDialogBuilder.Cancelable(True)
'	MatDialogBuilder.Show
End Sub

Private Sub EditChlorineTime_ButtonPressed(mDialog As MaterialDialog, sAction As String)
'	Select Case sAction
'		Case mDialog.ACTION_POSITIVE
'		Case mDialog.ACTION_NEGATIVE
'			GlobalVar.blnNewChlorine = False
'			StartActivity(AddEditChlorineRecord)
'		Case mDialog.ACTION_NEUTRAL
''			StartActivity(SetTranDate)
'	End Select
End Sub

Sub btnAddChlorine_Click
'	GlobalVar.blnNewChlorine = True
'	StartActivity(AddEditChlorineRecord)
End Sub

#End Region

#Region Problems Encountered
'Sub TabMenu_Tab5Click
'	PnlTime.Visible = False
'	pnlFMRdg.Visible = False
'	pnlPSIRdg.Visible = False
'	pnlChlorinator.Visible = False
'	pnlConcerns.Visible = True
'	GetProblemsRec(GlobalVar.TranDate, GlobalVar.PumpHouseID)
'End Sub
'
Sub GetProblemsRec(sTrandate As String, iPumpID As Int)
'	Dim SenderFilter As Object
'	clvConcerns.Clear
'	Try
'		Starter.strCriteria = "SELECT Problem.DetailID, Problem.TimeStart, Problem.ProblemTitle " & _
'							  "FROM ProblemDetails AS Problem " & _
'							  "INNER JOIN TranHeader AS Header ON Problem.HeaderID = Header.HeaderID " & _
'							  "WHERE Header.PumpID = " & iPumpID & " " & _
'							  "AND Header.TranDate = '" & sTrandate & "' "  & _
'							  "ORDER BY Problem.DetailID, Problem.TimeStart ASC"
'							  
'		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
'		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
'		
'		If Success Then
'			Dim StartTime As Long = DateTime.Now
'			Do While RS.NextRow
'				Dim ConcernRec As ConcernsRecords
'				ConcernRec.Initialize
'				ConcernRec.ID = RS.GetInt("DetailID")
'				ConcernRec.sTimeEnc = RS.GetString("TimeStart")
'				ConcernRec.sProblem= RS.GetString("ProblemTitle")
'
'				Dim Pnl As B4XView = xui.CreatePanel("")
'				Pnl.SetLayoutAnimated(0, 10dip, 0, clvConcerns.AsView.Width - 10dip, 30dip) 'Panel height + 4 for drop shadow
'				clvConcerns.Add(Pnl, ConcernRec)
'			Loop
'		Else
'			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'			snack.Show
'			Log(LastException)
'		End If
'
'		Log($"List of PSI Reading Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvConcerns.Size} PSI Reading Records"$)
'
'	Catch
'		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'		snack.Show
'		Log(LastException)
'	End Try
End Sub

Sub clvConcerns_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
'	Dim ExtraSize As Int = 15 'List size
'	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvConcerns.Size - 1)
'		Dim Pnl As B4XView = clvConcerns.GetPanel(i)
'		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
'			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
'				Dim ConcernRec As ConcernsRecords = clvConcerns.GetValue(i)
'				Pnl.LoadLayout("ListProblemsRecords")
'				lblTimeEnc.TextColor = GlobalVar.PriColor
'				lblProblems.TextColor = GlobalVar.PriColor
'				
'				lblTimeEnc.Text = ConcernRec.sTimeEnc
'				lblProblems.Text = ConcernRec.sProblem
'			End If
'		Else 'Not visible
'			If Pnl.NumberOfViews > 0 Then
'				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
'			End If
'		End If
'	Next

End Sub

Sub clvConcerns_ItemClick (Index As Int, Value As Object)
	Dim Rec As ConcernsRecords = Value
	Log(Rec.ID)
	ShowProblemRecDetails(Rec.ID)
	GlobalVar.ProblemDetailID = Rec.ID
End Sub

Sub pnlAddEditPSIRdg_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Sub pnlProbEncDetails_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Sub btnSolved_Click
	
End Sub

Sub btnProbEncOK_Click
'	pnlProbEncDetails.Visible = False
End Sub

Sub btnEditProb_Click
'	pnlProbEncDetails.Visible = False
'	GlobalVar.blnNewProblem = False
'	StartActivity(AddEditProblem)
End Sub

Sub ShowProblemRecDetails (iID As Int)
'	Dim csTitle As CSBuilder
'	Dim SenderFilter As Object
'	Dim sDate, sPCode As String
'	Dim sTimeEnc, sTimeFin, sArea, sProbTitle, sProbDesc, sCritical, sRem As String
'	Dim sFindings, sActionTaken, sWasSolved As String
'	Dim isCritical, wasSolved As Int
'	
'	Dim cdSolve, cdEdit, cdOk As ColorDrawable
'	
'	cdSolve.Initialize(GlobalVar.BlueColor, 20)
'	btnSolved.Background = cdSolve
'	
'	cdEdit.Initialize(GlobalVar.GreenColor, 20)
'	btnEditProb.Background = cdEdit
'	
'	cdOk.Initialize(GlobalVar.PriColor, 20)
'	btnProbEncOK.Background = cdOk
'	
'	Starter.strCriteria = "SELECT Header.TranDate, Station.PumpHouseCode, " & _
'						  "Problem.TimeStart, Problem.TimeFinished, PAreas.PumpArea, Problem.IsCritical, " & _
'						  "Problem.ProblemTitle, Problem.ProbDesc, Problem.Remarks, " & _
'						  "Problem.WasSolved, Problem.Findings, Problem.ActionTaken " & _
'						  "FROM ProblemDetails AS Problem " & _
'						  "INNER JOIN TranHeader AS Header ON Problem.HeaderID = Header.HeaderID " & _
'						  "INNER JOIN tblPumpStation AS Station ON Header.PumpID = Station.StationID " & _
'						  "INNER JOIN PumpAreas AS PAreas ON Problem.AreaID = PAreas.ID " & _
'						  "WHERE Problem.DetailID = " & iID
'							  
'	SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
'	Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
'		
'	If Success Then
'		RS.Position = 0
'		sDate = RS.GetString("TranDate")
'		sPCode = RS.GetString("PumpHouseCode")
'		sTimeEnc = RS.GetString("TimeStart")
'		sTimeFin = RS.GetString("TimeFinished")
'		sArea = RS.GetString("PumpArea")
'		sProbTitle = RS.GetString("ProblemTitle")
'		sProbDesc = RS.GetString("ProbDesc")
'		sRem = RS.GetString("Remarks")
'		isCritical = RS.GetInt("IsCritical")
'		
'		wasSolved = RS.GetInt("WasSolved")
'		sFindings = RS.GetString("Findings")
'		sActionTaken = RS.GetString("ActionTaken")
'	Else
'		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
'		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
'		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
'		snack.Show
'		Log(LastException)
'	End If
'	
'	
'	pnlProbEncDetails.Visible = True
'	If wasSolved = 1 Then
'		pnlProbEncMsgBox.Height = 75%y
'		pnlProbEncMsgBox.Top = pnlProbEncDetails.Height /2 - (pnlProbEncMsgBox.Height / 2 + 5%y)
'		pnlProbSolved.Visible = True
'		lblFindings.Text = sFindings
'		lblActionTaken.Text = sActionTaken
'		lblRemarks.Text = sRem
'		
'		btnSolved.Top = pnlProbSolved.Top + pnlProbSolved.Height + 5dip
'		btnSolved.Height = 5.5%y
'		btnSolved.Visible = False
'		
'		btnEditProb.Top = pnlProbSolved.Top + pnlProbSolved.Height + 5dip
'		btnEditProb.Height = 5.5%y
'		btnEditProb.Visible = False
'
'		btnProbEncOK.Top = pnlProbSolved.Top + pnlProbSolved.Height + 5dip
'		btnProbEncOK.Height = 5.5%y
'	Else
'		pnlProbEncMsgBox.Height = 48%y
'		pnlProbEncMsgBox.Top = pnlProbEncDetails.Height / 2 - (pnlProbEncMsgBox.Height / 2 + 10%y)
'		pnlProbSolved.Visible = False
'		lblFindings.Text = ""
'		lblActionTaken.Text = ""
'		lblRemarks.Text = ""
'
'		btnSolved.Top = lblProbDesc.Top + lblProbDesc.Height
'		btnSolved.Height = 5.5%y
'		btnSolved.Visible = True
'
'		btnEditProb.Top = lblProbDesc.Top + lblProbDesc.Height
'		btnEditProb.Height = 5.5%y
'		btnEditProb.Visible = True
'
'		btnProbEncOK.Top = lblProbDesc.Top + lblProbDesc.Height
'		btnProbEncOK.Height = 5.5%y
'	End If
'
'
'	lblPumpCode.Text =  sPCode
'	lblTranDate.Text =  sDate
'	lblTimeEnc.Text = sTimeEnc
'	lblPumpArea.Text = sArea
'	lblProbTitle.Text = sProbTitle
'	lblProbDesc.Text =  sProbDesc
'	
'	If isCritical = 1 Then
'		chkCritical.Checked = True
'	Else
'		chkCritical.Checked = False
'	End If
End Sub

Sub btnAddConcerns_Click
	GlobalVar.blnNewProblem = True
	StartActivity(AddEditProblem)
End Sub
#End Region

Private Sub ConfirmPumpOff(iPumpID As Int)
'	Dim Alert As AX_CustomAlertDialog
'
'	Alert.Initialize.Create _
'			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
'			.SetStyle(Alert.STYLE_DIALOGUE) _
'			.SetCancelable(False) _
'			.SetTitle("PUMP OFF TIME") _
'			.SetTitleColor(GlobalVar.BlueColor) _
'			.SetTitleTypeface(FontBold) _
'			.SetMessage($"Pump is currently on,"$ & CRLF & $"Do you want to Record the Pump Off Time Now?"$) _
'			.SetPositiveText("Confirm") _
'			.SetPositiveColor(GlobalVar.PosColor) _
'			.SetPositiveTypeface(FontBold) _
'			.SetNegativeText("Cancel") _
'			.SetNegativeColor(GlobalVar.NegColor) _
'			.SetNegativeTypeface(Font) _
'			.SetTitleTypeface(Font) _
'			.SetMessageTypeface(Font) _
'			.SetOnPositiveClicked("PumpOff") _	'listeners
'			.SetOnNegativeClicked("PumpOff")	'listeners
'	Alert.SetDialogBackground(MyFunctions.myCD)
'	Alert.Build.Show

End Sub

''Listeners
'Private Sub PumpOff_OnNegativeClicked (View As View, Dialog As Object)
''	ToastMessageShow("Negative Button Clicked!",False)
'	Alert.Initialize.Dismiss(Dialog)
'End Sub
'
'Private Sub PumpOff_OnPositiveClicked (View As View, Dialog As Object)
''	ToastMessageShow("Positive Button Clicked!",False)
'	
'	LogColor(GlobalVar.SelectedJOID, Colors.Cyan)
'	pnlPumpOff.Visible = True
'	cdCancel.Initialize2(GlobalVar.RedColor, 20, 0, Colors.Transparent)
'	btnPumpOffCancel.Background = cdCancel
'	btnPumpOffCancel.Text =Chr(0xE5C9) & $" CANCEL"$
'
'	Alert.Initialize.Dismiss2
'End Sub
'
'Sub chkDefaultTimeOff_CheckedChange(Checked As Boolean)
'	If Checked = True Then
'		DateTime.TimeFormat = "hh:mm a"
'		mskTimeOff.Text = DateTime.GetHour(DateTime.Now) & ":" & DateTime.GetMinute(DateTime.Now)
'	Else
'		mskTimeOff.Text = "__:__"
'	End If
'	
'End Sub
'
'
'Sub btnPumpOffCancel_Click
'	pnlPumpOff.Visible = False
'End Sub
'
'Sub pnlPumpOff_Touch (Action As Int, X As Float, Y As Float)
'	
'End Sub
'
'Sub btnPumpOffSave_Click
'	Dim Matcher1 As Matcher
'	Dim sMin As String
'
'	If GlobalVar.SF.Len(GlobalVar.SF.Trim(mskTimeOff.Text)) <= 0 Or mskTimeOff.Text = "__:__" Then
'		ToastMessageShow($"Pump Time Off cannot be blank!"$, True)
'		mskTimeOff.RequestFocus
'		Return
'	End If
'
'	Matcher1 = Regex.Matcher("(\d\d):(\d\d)", mskTimeOff.Text)
'	If Matcher1.Find Then
'		Dim iHrs, iMins As Int
'		iHrs = Matcher1.Group(1)
'		iMins = Matcher1.Group(2)
'		
'		If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMins)) = 1 Then
'			sMin = $"0"$ & iMins
'		Else
'			sMin = iMins
'		End If
'
'		If iHrs = 0 Then
'			iHrOff = 12
'			sPumpTimeOff = iHrOff & ":" & sMin & " AM"
'		Else If iHrs > 0 And iHrs < 12 Then
'			iHrOff = iHrs
'			If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrOff)) = 1 Then
'				sPumpTimeOff = $"0"$ & iHrOff & ":" & sMin & " AM"
'			Else
'				sPumpTimeOff = iHrOff & ":" & sMin & " AM"
'			End If
'		Else If iHrs = 12 Then
'			iHrOff = 12
'			sPumpTimeOff = iHrOff & ":" & sMin & " PM"
'		Else
'			iHrOff = iHrs - 12
'			If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrOff)) = 1 Then
'				sPumpTimeOff = $"0"$ & iHrOff & ":" & sMin & " PM"
'			Else
'				sPumpTimeOff = iHrOff & ":" & sMin & " PM"
'			End If
'		End If
'	End If
'	
'	If DBaseFunctions.IsTimeOffOverlapping(sPumpTimeOff, GlobalVar.TranHeaderID, GlobalVar.TimeDetailID) = True Then
'		ToastMessageShow($"Pump Time Off overlaps!"$, True)
'		mskTimeOff.RequestFocus
'		Return
'	End If
'	
'	LogColor(sPumpTimeOff,Colors.Yellow)
'
'	ConfirmSavePumpTimeOff(GlobalVar.TranHeaderID)
'End Sub
'
'Private Sub ShowSaveSuccess()
'	Dim csTitle As CSBuilder
'	Dim csContent As CSBuilder
'	
'	If GlobalVar.blnNewTime = True Then
'		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
'		csContent.Initialize.Size(14).Color(Colors.Black).Append($"New pump time has been successfully saved!"$).PopAll
'	Else
'		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
'		csContent.Initialize.Size(14).Color(Colors.Black).Append($"Pump time has been successfully updated!"$).PopAll
'	End If
'	
'	
'	Alert.Initialize.Dismiss2
''	
''	MatDialogBuilder.Initialize("SaveSuccess")
''	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
''	MatDialogBuilder.Title(csTitle)
''	MatDialogBuilder.Content(csContent)
''	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
''	MatDialogBuilder.CanceledOnTouchOutside(False)
''	MatDialogBuilder.Cancelable(False)
''	MatDialogBuilder.Show	
'
'	Alert.Initialize.Create _
'			.SetDialogStyleName("SaveSuccess") _	'Manifest style name
'			.SetStyle(Alert.STYLE_DIALOGUE) _
'			.SetTitle(csTitle) _
'			.SetMessage(csContent) _
'			.SetPositiveText("OK") _
'			.SetPositiveColor(GlobalVar.PosColor) _
'			.SetPositiveTypeface(FontBold) _
'			.SetTitleTypeface(Font) _
'			.SetMessageTypeface(Font) _
'			.SetOnPositiveClicked("Success") _	'listeners
'			.SetOnViewBinder("FontSizeBinder") _ 'listeners
'			.SetDialogBackground(myCD)
'	
'	Alert.Build.Show
'
'End Sub
'
'Private Sub myCD As ColorDrawable
'	Private mCD As ColorDrawable
'	mCD.Initialize(Colors.RGB(240,240,240),0)
'	Return mCD
'End Sub
'
'
'Private Sub Success_OnPositiveClicked (View As View, Dialog As Object)
'	ToastMessageShow("Positive Button Clicked!",False)
'	Dim Alert As AX_CustomAlertDialog
'	Activity.Finish
'	Alert.Initialize.Dismiss2
'End Sub
'
'Private Sub ConfirmSavePumpTimeOff(iPumpID As Int)
'	Dim Alert As AX_CustomAlertDialog
'
'	Alert.Initialize.Create _
'			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
'			.SetStyle(Alert.STYLE_DIALOGUE) _
'			.SetCancelable(False) _
'			.SetTitle("SAVE PUMP OFF TIME RECORD?") _
'			.SetTitleColor(GlobalVar.BlueColor) _
'			.SetTitleTypeface(FontBold) _
'			.SetMessage($"Do you want to SAVE the Pump Off Time Record now?"$) _
'			.SetPositiveText("Confirm") _
'			.SetPositiveColor(GlobalVar.PosColor) _
'			.SetPositiveTypeface(FontBold) _
'			.SetNegativeText("Cancel") _
'			.SetNegativeColor(GlobalVar.NegColor) _
'			.SetNegativeTypeface(Font) _
'			.SetTitleTypeface(Font) _
'			.SetMessageTypeface(Font) _
'			.SetOnPositiveClicked("SavePumpOffTime") _	'listeners
'			.SetOnNegativeClicked("SavePumpOffTime")	'listeners
'	Alert.SetDialogBackground(MyFunctions.myCD)
'	Alert.Build.Show
'
'End Sub
'
''Listeners
'Private Sub SavePumpOffTime_OnNegativeClicked (View As View, Dialog As Object)
''	ToastMessageShow("Negative Button Clicked!",False)
'	Alert.Initialize.Dismiss2
'End Sub
'
'
'Private Sub SavePumpOffTime_OnPositiveClicked (View As View, Dialog As Object)
''	ToastMessageShow("Positive Button Clicked!",False)
'	Alert.Initialize.Dismiss(Dialog)
'	If  Not (UpdatePumpTime(GlobalVar.TranHeaderID, GlobalVar.TimeDetailID)) Then Return
'	If Not (UpdateTranHeader(GlobalVar.TranHeaderID)) Then Return
'	DBaseFunctions.UpdatePumpPowerStatus (0, GlobalVar.PumpHouseID)
'	ShowSaveSuccess
'End Sub
'
'Private Sub UpdatePumpTime(iTranHeaderID As Int, iDetailID As Int) As Boolean
'	Dim bRetVal As Boolean
'	Dim sDateTime As String
'	Dim lDate As Long
'	
'	lDate = DateTime.Now
'	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
'	sDateTime = DateTime.Date(lDate)
'
'	LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Yellow)
'	TotOpHours = ComputeTotHrs(lSelectedRecTimeOn, sPumpTimeOff)
'	
'	Starter.DBCon.BeginTransaction
'	Try
'		Starter.strCriteria = "UPDATE OnOffDetails SET " & _
'							  "PumpOffTime = ?, " & _
'							  "TotOpHrs = ?, " & _
'							  "TimeOffRemarks = ?, " & _
'							  "ModifiedBy = ?, " & _
'							  "ModifiedAt = ? " & _
'							  "WHERE HeaderID = " & iTranHeaderID & " " & _
'							  "AND DetailID = " & iDetailID
'							  
'		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(sPumpTimeOff, TotOpHours, txtOffRemarks.Text, GlobalVar.UserID, sDateTime))
'		Starter.DBCon.TransactionSuccessful
'		bRetVal = True
'	Catch
'		Log(LastException)
'		bRetVal = False
'	End Try
'	Starter.DBCon.EndTransaction
'	Return bRetVal
'End Sub
'
'Private Sub ComputeTotHrs(T1 As String, T2 As String) As Float
'	Dim dRetVal As Float
'	Dim StartTime, EndTime As Long
'	
'	Try
'		DateTime.TimeFormat = "hh:mm a"
'		StartTime = T1
'		EndTime = DateTime.TimeParse(T2)
'		
'		Dim p As Period = DateUtils.PeriodBetween(StartTime, EndTime)
'		
'		dRetVal = p.Hours + (p.Minutes/60)
'	Catch
'		dRetVal = 0
'		Log(LastException)
'	End Try
'	Return dRetVal
'End Sub
'
'Private Sub UpdateTranHeader(iTranHeaderID As Int) As Boolean
'	Dim bRetVal As Boolean
'	Dim GTotOPHrs As Float
'	Dim GTotDrain, GTotDuration As Double
'
'	Dim lngDateTime As Long
'	Dim sModifiedAt As String
'	
'	DateTime.DateFormat = "yyyy-MM-dd"
'	DateTime.TimeFormat = "hh:mm:ss a"
'	lngDateTime = DateTime.Now
'	sModifiedAt = DateTime.Date(lngDateTime) & $" "$ & DateTime.Time(lngDateTime)
'
'	Dim rsHeader As Cursor
'	
'	Starter.strCriteria = "SELECT * FROM TranHeader WHERE HeaderID = " & iTranHeaderID
'	rsHeader = Starter.DBCon.ExecQuery(Starter.strCriteria)
'	If rsHeader.RowCount > 0 Then
'		rsHeader.Position = 0
'		GTotOPHrs = rsHeader.GetDouble("TotOpHrs") + TotOpHours
'	Else
'		GTotOPHrs = TotOpHours
'	End If
'	rsHeader.Close
'	LogColor($"Total Op Hrs: "$ & GTotOPHrs, Colors.Magenta)
'	
'	bRetVal = False
'	Starter.DBCon.BeginTransaction
'	Try
'		Starter.strCriteria = "UPDATE TranHeader SET " & _
'							  "TotOpHrs = ?, " & _
'							  "ModifiedBy = ?, " & _
'							  "ModifiedAt = ? " & _
'							  "WHERE HeaderID = " & iTranHeaderID
'							  
'		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(GTotOPHrs, GlobalVar.UserID, sModifiedAt))
'		Starter.DBCon.TransactionSuccessful
'		bRetVal = True
'	Catch
'		Log(LastException)
'		bRetVal = False
'	End Try
'	Starter.DBCon.EndTransaction
'	Return bRetVal
'End Sub
'
'
'Sub chkTimeFMRdg_CheckedChange(Checked As Boolean)
'	
'End Sub