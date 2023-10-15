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

	Private CD, cdCancel, CDtxtBox As ColorDrawable

	Private vibration As B4Avibrate
	Private vibratePattern() As Long
	
	Private snack As DSSnackbar
	Private csAns As CSBuilder
	Dim kboard As IME

	
	Private MatDialogBuilder As MaterialDialogBuilder
	Dim Alert As AX_CustomAlertDialog
	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")

	'Pump Time Off
	Private mskTimeOff As MaskedEditText
	Private chkDefaultTimeOff As CheckBox
	Private pnlPumpOff As Panel
	Private txtOffRemarks As EditText
	Private iHrOff As Int
	Private sPumpTimeOff As String
	Private TotOpHours As Float
	Private MyToast As BCToast

	Private btnPumpOffSave As ACButton
	Private btnPumpOffCancel As ACButton
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("PumpOffTime")

	
	InpTyp.Initialize
	InpTyp.SetInputType(txtOffRemarks,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_CORRECT, InpTyp.TYPE_TEXT_FLAG_CAP_SENTENCES))

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
	
	CDtxtBox.Initialize(Colors.Transparent,0)
	mskTimeOff.Background = CDtxtBox
	txtOffRemarks.Background = CDtxtBox


	CD.Initialize2(GlobalVar.GreenColor, 30, 0, Colors.Transparent)
	btnPumpOffSave.Background = CD
	btnPumpOffSave.Text = Chr(0xE161) & $"  SAVE"$

	cdCancel.Initialize2(GlobalVar.RedColor, 20, 0, Colors.Transparent)
	btnPumpOffCancel.Background = cdCancel
	btnPumpOffCancel.Text =Chr(0xE5C9) & $" CANCEL"$
	CheckPermissions
End Sub

Private Sub CheckPermissions
	Log("Checking Permissions")
  
	Starter.RTP.CheckAndRequest(Starter.RTP.PERMISSION_READ_EXTERNAL_STORAGE)
	Starter.RTP.CheckAndRequest(Starter.RTP.PERMISSION_WRITE_EXTERNAL_STORAGE)
	Starter.RTP.GetAllSafeDirsExternal("")

	Starter.RTP.CheckAndRequest(Starter.RTP.PERMISSION_ACCESS_COARSE_LOCATION)
	Starter.RTP.CheckAndRequest(Starter.RTP.PERMISSION_ACCESS_FINE_LOCATION)
	Return
End Sub

Sub Activity_PermissionResult (Permission As String, Result As Boolean)
	If Result Then
		If Permission = Starter.RTP.PERMISSION_READ_EXTERNAL_STORAGE Then
			LogColor($"Permission to Read External Storage GRANTED"$, Colors.Yellow)
			GlobalVar.ReadStoragePermission = True
		Else If Permission = Starter.RTP.PERMISSION_WRITE_EXTERNAL_STORAGE Then
			LogColor($"Permission to Write External Storage GRANTED"$, Colors.White)
			GlobalVar.WriteStoragePermission = True
		Else If Permission = Starter.RTP.PERMISSION_ACCESS_COARSE_LOCATION Then
			LogColor($"Permission to Access Coarse Location GRANTED"$, Colors.Magenta)
			GlobalVar.CoarseLocPermission = True
		Else If Permission = Starter.RTP.PERMISSION_ACCESS_FINE_LOCATION Then
			LogColor($"Permission to Access Fine Location GRANTED"$, Colors.Cyan)
			GlobalVar.FineLocPermission = True
		End If
		Starter.StartFLP
	Else
		GlobalVar.ReadStoragePermission = False
		GlobalVar.WriteStoragePermission = False
		GlobalVar.CoarseLocPermission = False
		GlobalVar.FineLocPermission = False
		Result = False
	End If
	Log (Permission)
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
	MyToast.Initialize(Activity)
	CheckPermissions
End Sub

Sub Activity_Pause (UserClosed As Boolean)
End Sub

#End Region

#Region Toolbar
Sub Activity_CreateMenu(Menu As ACMenu)
End Sub

Sub ToolBar_NavigationItemClick 'Toolbar Arrow
	Activity.Finish
	kboard.HideKeyboard
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
End Sub

#End Region

Sub chkDefaultTimeOff_CheckedChange(Checked As Boolean)
	If Checked = True Then
		DateTime.TimeFormat = "hh:mm a"
		Dim sMin, sHr As String
		If GlobalVar.SF.Len(DateTime.GetHour(DateTime.Now)) = 1 Then
			sHr = $"0"$ & DateTime.GetHour(DateTime.Now)
		Else
			sHr = DateTime.GetHour(DateTime.Now)
		End If

		If GlobalVar.SF.Len(DateTime.GetMinute(DateTime.Now)) = 1 Then
			sMin = $"0"$ & DateTime.GetMinute(DateTime.Now)
		Else
			sMin = DateTime.GetMinute(DateTime.Now)
		End If

		mskTimeOff.Text = sHr & ":" & sMin
	Else
		mskTimeOff.Text = "__:__"
	End If
End Sub

Sub btnPumpOffCancel_Click
	Activity.Finish
End Sub

Sub pnlPumpOff_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Sub btnPumpOffSave_Click
	Dim Matcher1 As Matcher
	Dim sMin As String

	If GlobalVar.SF.Len(GlobalVar.SF.Trim(mskTimeOff.Text)) <= 0 Or mskTimeOff.Text = "__:__" Then
		ToastMessageShow($"Pump Time Off cannot be blank!"$, True)
		mskTimeOff.RequestFocus
		Return
	End If

	Matcher1 = Regex.Matcher("(\d\d):(\d\d)", mskTimeOff.Text)
	If Matcher1.Find Then
		Dim iHrs, iMins As Int
		iHrs = Matcher1.Group(1)
		iMins = Matcher1.Group(2)
		
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMins)) = 1 Then
			sMin = $"0"$ & iMins
		Else
			sMin = iMins
		End If

		If iHrs = 0 Then
			iHrOff = 12
			sPumpTimeOff = iHrOff & ":" & sMin & " AM"
		Else If iHrs > 0 And iHrs < 12 Then
			iHrOff = iHrs
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrOff)) = 1 Then
				sPumpTimeOff = $"0"$ & iHrOff & ":" & sMin & " AM"
			Else
				sPumpTimeOff = iHrOff & ":" & sMin & " AM"
			End If
		Else If iHrs = 12 Then
			iHrOff = 12
			sPumpTimeOff = iHrOff & ":" & sMin & " PM"
		Else
			iHrOff = iHrs - 12
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrOff)) = 1 Then
				sPumpTimeOff = $"0"$ & iHrOff & ":" & sMin & " PM"
			Else
				sPumpTimeOff = iHrOff & ":" & sMin & " PM"
			End If
		End If
	End If

	If DBaseFunctions.IsFuturisticTime(GlobalVar.TranDate,mskTimeOff.Text) = True Then
		RequiredMsgBox($"E R R O R"$,$"Unable to Add New Pump Time record due to specified time is too soon."$)
		mskTimeOff.RequestFocus
		Return
	End If

	If DBaseFunctions.IsTimeOffOverlapping(sPumpTimeOff, GlobalVar.TranHeaderID, GlobalVar.TimeDetailID) = True Then
		RequiredMsgBox($"E R R O R"$,$"Unable to Save Pump Time record due to it will overlap the existing reccords."$)
		mskTimeOff.RequestFocus
		Return
	End If
	
	LogColor(sPumpTimeOff,Colors.Yellow)

	ConfirmSavePumpTimeOff
End Sub

Private Sub ShowSaveSuccess()
	Dim csTitle As CSBuilder
	Dim csContent As CSBuilder
	
	If GlobalVar.blnNewTime = True Then
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"New pump time has been successfully saved!"$).PopAll
	Else
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"Pump time has been successfully updated!"$).PopAll
	End If
	MatDialogBuilder.Initialize("AddPumpTimeOffRecords")
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content(csContent)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(False)
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
	MatDialogBuilder.Show
End Sub

Private Sub AddPumpTimeOffRecords_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			kboard.HideKeyboard
			Activity.Finish
	End Select
End Sub

Private Sub FontSizeBinder_OnBindView (View As View, ViewType As Int)
	Dim SaveAlert As AX_CustomAlertDialog
	SaveAlert.Initialize
	If ViewType = Alert.VIEW_TITLE Then ' Title
		Dim lbl As Label = View
		lbl.TextSize = 30
'		lbl.SetTextColorAnimated(2000,Colors.Magenta)
		
		
		Dim CS As CSBuilder
'		CS.Initialize.Typeface(Font).Append(lbl.Text & " ").Pop
'		CS.Typeface(Typeface.MATERIALICONS).Size(36).Color(Colors.Red).Append(Chr(0xE190))

		CS.Initialize.Typeface(Typeface.MATERIALICONS).Size(26).Color(Colors.Red).Append(Chr(0xE88E) & "  ")
		CS.Typeface(Font).Size(26).Append(lbl.Text).Pop

		lbl.Text = CS.PopAll
	End If
End Sub

Private Sub ConfirmSavePumpTimeOff
	Alert.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(Alert.STYLE_DIALOGUE) _
			.SetCancelable(False) _
			.SetTitleTypeface(FontBold) _
			.SetTitle("SAVE PUMP OFF TIME RECORD?") _
			.SetTitleColor(GlobalVar.BlueColor) _
			.SetTitleTypeface(FontBold) _
			.SetMessage($"Do you want to SAVE the Pump Off Time Record now?"$) _
			.SetPositiveText("Confirm") _
			.SetPositiveColor(GlobalVar.PosColor) _
			.SetPositiveTypeface(FontBold) _
			.SetNegativeText("Cancel") _
			.SetNegativeColor(GlobalVar.NegColor) _
			.SetNegativeTypeface(Font) _
			.SetMessageTypeface(Font) _
			.SetOnPositiveClicked("SavePumpOffTime") _	'listeners
			.SetOnNegativeClicked("SavePumpOffTime")	'listeners
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Listeners
Private Sub SavePumpOffTime_OnNegativeClicked (View As View, Dialog As Object)
	Alert.Initialize.Dismiss2
End Sub

Private Sub SavePumpOffTime_OnPositiveClicked (View As View, Dialog As Object)
	
	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID,GlobalVar.TranDate)
	If  Not (UpdatePumpTime(GlobalVar.TranHeaderID, GlobalVar.TimeDetailID)) Then Return
	If Not (UpdateTranHeader(GlobalVar.TranHeaderID)) Then
		Return
	Else
		DBaseFunctions.UpdatePumpPowerStatus (0, GlobalVar.PumpHouseID)
	End If
	ShowSaveSuccess
End Sub

Private Sub UpdatePumpTime(iTranHeaderID As Int, iDetailID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim sDateTime As String
	Dim lDate As Long
	Dim sRemarks, sLocation As String
	
	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	sDateTime = DateTime.Date(lDate)

	sRemarks = txtOffRemarks.Text

	Starter.FLP.Connect

	Log($"FLP is COnnected? "$ & Starter.FLP.IsConnected)
	
	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)

	sLocation = GlobalVar.Lat & "," & GlobalVar.Lon
	LogColor($"Location is "$ & sLocation, Colors.Yellow)

	LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Yellow)
	TotOpHours = ComputeTotHrs(GlobalVar.SelectedPumpTime, sPumpTimeOff)
	
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE OnOffDetails SET " & _
							  "PumpOffTime = ?, " & _
							  "TotOpHrs = ?, " & _
							  "TimeOffRemarks = ?, " & _
							  "ModifiedBy = ?, " & _
							  "ModifiedAt = ?, " & _
							  "ModifiedOn = ? " & _
							  "WHERE HeaderID = " & iTranHeaderID & " " & _
							  "AND DetailID = " & iDetailID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(sPumpTimeOff, TotOpHours, sRemarks, GlobalVar.UserID, sDateTime, sLocation))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

Private Sub ComputeTotHrs(T1 As String, T2 As String) As Float
	Dim dRetVal As Float
	Dim StartTime, EndTime As Long
	
	Try
		DateTime.TimeFormat = "hh:mm a"
		StartTime = T1
		EndTime = DateTime.TimeParse(T2)
		
		Dim p As Period = DateUtils.PeriodBetween(StartTime, EndTime)
		
		dRetVal = p.Hours + (p.Minutes/60)
	Catch
		dRetVal = 0
		Log(LastException)
	End Try
	Return dRetVal
End Sub

Private Sub UpdateTranHeader(iTranHeaderID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim GTotOPHrs As Float
	Dim GTotDrain, GTotDuration As Double

	Dim lngDateTime As Long
	Dim sModifiedAt As String
	
	DateTime.DateFormat = "yyyy-MM-dd"
	DateTime.TimeFormat = "hh:mm:ss a"
	lngDateTime = DateTime.Now
	sModifiedAt = DateTime.Date(lngDateTime) & $" "$ & DateTime.Time(lngDateTime)

	Dim rsHeader As Cursor
	
	Starter.strCriteria = "SELECT * FROM TranHeader WHERE HeaderID = " & iTranHeaderID
	rsHeader = Starter.DBCon.ExecQuery(Starter.strCriteria)
	If rsHeader.RowCount > 0 Then
		rsHeader.Position = 0
		GTotOPHrs = rsHeader.GetDouble("TotOpHrs") + TotOpHours
	Else
		GTotOPHrs = TotOpHours
	End If
	rsHeader.Close
	LogColor($"Total Op Hrs: "$ & GTotOPHrs, Colors.Magenta)
	
	bRetVal = False
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE TranHeader SET " & _
							  "TotOpHrs = ?, " & _
							  "ModifiedBy = ?, " & _
							  "ModifiedAt = ? " & _
							  "WHERE HeaderID = " & iTranHeaderID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(GTotOPHrs, GlobalVar.UserID, sModifiedAt))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub


Sub chkTimeFMRdg_CheckedChange(Checked As Boolean)
	
End Sub

Private Sub RequiredMsgBox(sTitle As String, sMsg As String)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss2
	
	Alert.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(Alert.STYLE_DIALOGUE) _
			.SetCancelable(False) _
			.SetTitle(sTitle) _
			.SetTitleColor(GlobalVar.RedColor) _
			.SetTitleTypeface(FontBold) _
			.SetMessage(sMsg) _
			.SetPositiveText("OK") _
			.SetPositiveColor(GlobalVar.PosColor) _
			.SetPositiveTypeface(FontBold) _
			.SetMessageTypeface(Font) _
			.SetOnPositiveClicked("RequiredMsg") _ 'listeners
			.SetOnViewBinder("ReqMsg") 'listeners
	
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Listeners

Private Sub RequiredMsg_OnPositiveClicked (View As View, Dialog As Object)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub ReqMsg_OnBindView (View As View, ViewType As Int)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize
	If ViewType = Alert.VIEW_TITLE Then ' Title
		Dim lbl As Label = View
		lbl.TextSize = 30
		lbl.SetTextColorAnimated(2000,Colors.Magenta)
		
		
		Dim CS As CSBuilder
'		CS.Initialize.Typeface(Font).Append(lbl.Text & " ").Pop
'		CS.Typeface(Typeface.MATERIALICONS).Size(36).Color(Colors.Red).Append(Chr(0xE190))

		CS.Initialize.Typeface(Typeface.MATERIALICONS).Size(26).Color(Colors.Red).Append(Chr(0xE88E) & "  ")
		CS.Typeface(Font).Size(24).Append(lbl.Text).Pop

		lbl.Text = CS.PopAll
	End If
End Sub
