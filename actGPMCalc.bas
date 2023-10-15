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

	Private Timer1 As Timer
	Private StartTime As Long

End Sub

Sub Globals
	Dim ActionBarButton As ACActionBar
	Private xmlIcon As XmlLayoutBuilder

	Private ToolBar As ACToolBarDark

	Private MatDialogBuilder As MaterialDialogBuilder
	Private CDTotGPM, CDtxtBox, CDButton, cdRem, cdGPM As ColorDrawable
	
	Private vibration As B4Avibrate
	Private snack As DSSnackbar
	Private cdReading As ColorDrawable

	Private btnSaveUpdate As ACButton

	
	Private ToastMsg As BCToast
	Private kBoard As IME
	
	Private txtBucketSize As EditText
	Private cboUOM As ACSpinner
	
	Private SW1 As MLStopWatch
	Private SW2 As MLStopWatch
	Private SW3 As MLStopWatch
	
	Private cdStart As ColorDrawable
	Private cdStop As ColorDrawable
	Private cdReset As ColorDrawable
	Private cdPause As ColorDrawable
	
	Private txtGPM As EditText
	
	Private txtRemarks As EditText
	Private txtWaterQuality As EditText
	

	Private btnShowTimer1 As ACButton
	Private btnShowTimer2 As ACButton
	Private btnShowTimer3 As ACButton
	

	Dim Alert As AX_CustomAlertDialog
	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")
	
	Private iTimer As Int
	Private dTime1, dTime2, dTime3 As Double
	Private sTime1, sTime2, sTime3 As String
	Private pnlMainTimer As Panel
	Private pnlStopWatch As Panel
	Private btnReset As ACButton
	Private btnPause As ACButton
	Private btnStart As ACButton
	Private btnStop As ACButton
	Private txtTry1 As EditText
	Private txtTry2 As EditText
	Private txtTry3 As EditText
	Private chkManual As CheckBox

	Private btnOk As ACButton
	Private btnCancel As ACButton
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("NewGPMCalc")

	GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"GPM CALCULATOR"$).PopAll
	GlobalVar.CSSubTitle.Initialize.Size(12).Append($"PUMP: "$ & GlobalVar.PumpHouseCode).PopAll

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

	CDButton.Initialize2(GlobalVar.GreenColor, 30, 0, Colors.Transparent)
	btnSaveUpdate.Background = CDButton
	btnSaveUpdate.Text = Chr(0xE161) & $" SAVE"$
	
	InpTyp.Initialize
	kBoard.Initialize("")
	
	InpTyp.SetInputType(txtBucketSize,Array As Int(InpTyp.TYPE_CLASS_NUMBER, InpTyp.TYPE_NUMBER_FLAG_DECIMAL, InpTyp.TYPE_NUMBER_FLAG_SIGNED))
	InpTyp.SetInputType(txtWaterQuality,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_CORRECT, InpTyp.TYPE_TEXT_FLAG_CAP_SENTENCES))
	InpTyp.SetInputType(txtRemarks,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_CORRECT, InpTyp.TYPE_TEXT_FLAG_CAP_SENTENCES))
	InpTyp.SetInputType(txtTry1,Array As Int(InpTyp.TYPE_CLASS_NUMBER, InpTyp.TYPE_NUMBER_FLAG_DECIMAL, InpTyp.TYPE_NUMBER_FLAG_SIGNED))
	InpTyp.SetInputType(txtTry2,Array As Int(InpTyp.TYPE_CLASS_NUMBER, InpTyp.TYPE_NUMBER_FLAG_DECIMAL, InpTyp.TYPE_NUMBER_FLAG_SIGNED))
	InpTyp.SetInputType(txtTry3,Array As Int(InpTyp.TYPE_CLASS_NUMBER, InpTyp.TYPE_NUMBER_FLAG_DECIMAL, InpTyp.TYPE_NUMBER_FLAG_SIGNED))

	CDtxtBox.Initialize(Colors.Transparent,0)
	txtBucketSize.Background = CDtxtBox
	txtTry1.Background = CDtxtBox
	txtTry2.Background = CDtxtBox
	txtTry3.Background = CDtxtBox
	
	cdGPM.Initialize2(Colors.Black, 0, 0, Colors.Transparent)
	txtGPM.Background = cdGPM
	txtGPM.TextColor = 0xFFADFF2F
	
	cdRem.Initialize2(Colors.Transparent, 0, 0, Colors.Transparent)
	txtRemarks.Background = cdRem
	txtWaterQuality.Background = cdRem

	If Not(GlobalVar.blnNewGPM) Then
		FillUOM
		FillRecords(GlobalVar.GPMId)
	Else
		ClearDisplay
		FillUOM
	End If
	
	If FirstTime Then
		txtBucketSize.RequestFocus
		kBoard.ShowKeyboard(txtBucketSize)
	End If

	kBoard.ShowKeyboard(txtBucketSize)
	MyFunctions.SetButton(btnSaveUpdate, 25, 25, 25, 25, 25, 25, 25, 25)

	SetButtonColors
	InitObjects
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
	FillUOM
	iTimer = 0
End Sub

Sub Activity_Pause (UserClosed As Boolean)
End Sub

#End Region

#Region Toolbar
Sub Activity_CreateMenu(Menu As ACMenu)
	Dim Item As ACMenuItem
	Menu.Clear
	'Chr(0xF274)
	Menu.Add2(1, 1, "GPM History",xmlIcon.GetDrawable("baseline_history_white_18dp")).ShowAsAction = Item.SHOW_AS_ACTION_IF_ROOM
End Sub

Sub ToolBar_NavigationItemClick 'Toolbar Arroww
	kBoard.HideKeyboard
	Activity.Finish
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
	Select Case Item.Id
		Case 1
			Activity.Finish
			StartActivity(actGPMHistory)
	End Select
End Sub
#End Region


Sub cboUOM_ItemClick (Position As Int, Value As Object)
	If GlobalVar.SF.Len(txtBucketSize.Text) <= 0 Or GlobalVar.SF.Len(cboUOM.SelectedItem) <= 0 Or GlobalVar.SF.Len(txtTry1.Text) <= 0 Or GlobalVar.SF.Len(txtTry2.Text) <= 0 Or GlobalVar.SF.Len(txtTry3.Text) <= 0 Then
		txtGPM.Text = 0
		Return
	End If
	txtGPM.Text = ComputeGPM	
End Sub

Sub btnSaveUpdate_Click
	If Not(IsValidEntries) Then Return
	
	If DBaseFunctions.IsGPMTransExist(GlobalVar.PumpHouseID, GlobalVar.TranDate) = True Then
		ShowGPMExist
		Return
	End If

	If Not(GlobalVar.blnNewGPM) Then
		If Not(UpdateGPM(GlobalVar.GPMId, GlobalVar.TranDate, GlobalVar.PumpHouseID)) Then Return
	Else
		If Not(SaveNewGPM) Then Return
	End If
	ShowSaveSuccess
End Sub

Private Sub SaveNewGPM() As Boolean
	Dim bRetVal As Boolean
	Dim sDateTime As String
	Dim lDate As Long
	
	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	sDateTime = DateTime.Date(lDate)
	
	bRetVal = False
	Starter.DBCon.BeginTransaction
	Try
		Starter.DBCon.ExecNonQuery2("INSERT INTO tblGPMHistory VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
							   Array As Object(GlobalVar.PumpHouseID, GlobalVar.TranDate, txtBucketSize.Text, cboUOM.SelectedItem, txtTry1.Text, txtTry2.Text, txtTry3.Text, txtGPM.Text, txtWaterQuality.Text, txtRemarks.Text, $"0"$, Null, Null, GlobalVar.UserID, sDateTime, Null, Null))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal		
End Sub

Private Sub UpdateGPM(iGPMID As Int, sTranDate As String, iPumpID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim sDateTime As String
	Dim lDate As Long
	
	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	sDateTime = DateTime.Date(lDate)
	
	bRetVal = False
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE tblGPMHistory SET " & _
						      "BucketSize = ?, " & _
							  "UnitOfMeasurement = ?, " & _
							  "Trial1 = ?, " & _
							  "Trial2 = ?, " & _
							  "Trial3 = ?, " & _
							  "GPMResult = ?, " & _
							  "WaterQuality = ?, " & _
							  "Remarks = ?, " & _
							  "ModifiedBy = ?, " & _
							  "ModifiedAt = ? " & _
							  "WHERE GPMID = " & iGPMID & " " & _
							  "AND TranDate = '" & sTranDate & "' " & _
							  "AND PumpID = " & iPumpID
						  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(txtBucketSize.Text, cboUOM.SelectedItem, _
									txtTry1.Text, txtTry2.Text, txtTry3.Text, txtGPM.Text, txtWaterQuality.Text, txtRemarks.Text, GlobalVar.UserID, sDateTime))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub


Private Sub GetGPMID (sTranDate As String, iPumpID As Int) As Int
	Dim iRetval As Int
	Try
		Starter.strCriteria = "SELECT GPMID FROM tblGPMHistory " & _
							  "WHERE PumpID = " & iPumpID & " " & _
							  "AND TranDate = '" & sTranDate & "'"
		LogColor(Starter.strCriteria, Colors.Blue)
		
		iRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch GPM Record ID due to "$ & LastException.Message, False)
		Log(LastException)
		iRetval = 0
	End Try
	Return iRetval	
End Sub

Private Sub ShowSaveSuccess()
	Dim csTitle As CSBuilder
	Dim csContent As CSBuilder
	
	If GlobalVar.blnNewGPM = True Then
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"New GPM Result has been successfully saved!"$).PopAll
	Else
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"GPM Result has been successfully updated!"$).PopAll
	End If
	
	MatDialogBuilder.Initialize("SaveSuccess")
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
	MatDialogBuilder.NeutralText($"Close GPM Calculator?"$).NeutralColor(GlobalVar.NeutralColor)
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content(csContent)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(False)
	MatDialogBuilder.Show
End Sub

Private Sub SaveSuccess_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			ClearDisplay
		Case mDialog.ACTION_NEUTRAL
			Activity.Finish
	End Select
End Sub

Private Sub ShowGPMExist()
	Dim csTitle As CSBuilder
	Dim csContent As CSBuilder
	
	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"Confirm Save!"$).PopAll
	csContent.Initialize.Size(14).Color(Colors.Black).Append($"GPM Result is already exist for the specified Pump and Transaction Date."$ & CRLF & $"Do you want to overwrite existing GPM result?"$).PopAll
	MatDialogBuilder.Initialize("GPMExist")
	MatDialogBuilder.PositiveText("YES").PositiveColor(GlobalVar.BlueColor)
	MatDialogBuilder.NegativeText("NO").NegativeColor(GlobalVar.RedColor)
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content(csContent)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(False)
	MatDialogBuilder.Show
End Sub

Private Sub GPMExist_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			GlobalVar.blnNewGPM = False
			GlobalVar.GPMId = GetGPMID(GlobalVar.TranDate, GlobalVar.PumpHouseID)
			If Not(UpdateGPM(GlobalVar.GPMId, GlobalVar.TranDate, GlobalVar.PumpHouseID)) Then Return
			ShowSaveSuccess
		Case mDialog.ACTION_NEGATIVE
			Return
	End Select
End Sub

Private Sub ClearDisplay
	txtGPM.Text = ""
	txtBucketSize.Text = ""
	txtRemarks.Text = ""
	chkManual.Checked = False
	txtTry1.Text = ""
	txtTry2.Text = ""
	txtTry3.Text = ""
	txtWaterQuality.Text = ""
	btnShowTimer1.Enabled = True
	btnShowTimer2.Enabled = False
	btnShowTimer3.Enabled = False
End Sub

Private Sub FillUOM
	cboUOM.Clear
	cboUOM.Add("Liter (L)")
	cboUOM.Add("Milliliter (mL)")
	cboUOM.Add("Gallon (gal)")
End Sub

Private Sub FillRecords (iGPMID As Int)
	Dim SenderFilter As Object
	Dim sUOM As String
	Try
	
		Starter.strCriteria = "SELECT BucketSize, UnitOfMeasurement, Trial1, Trial2, Trial3, WaterQuality, Remarks " & _
						      "FROM tblGPMHistory " & _
							  "WHERE GPMID = " & iGPMID
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		If Success Then
			RS.Position = 0
			txtBucketSize.Text = RS.GetInt("BucketSize")
			sUOM = RS.GetString("UnitOfMeasurement")
			txtTry1.Text = RS.GetString("Trial1")
			txtTry2.Text = RS.GetString("Trial2")
			txtTry3.Text = RS.GetString("Trial3")
			txtWaterQuality.Text = RS.GetString("WaterQuality")
			txtRemarks.Text = RS.GetString("Remarks")
			cboUOM.SelectedIndex = cboUOM.IndexOf(sUOM)
		End If
	Catch
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End Try
	
End Sub

Private Sub ComputeGPM() As Double
	Dim dTry1, dTry2, dTry3 As Double
	Dim aveSec As Double
	Dim TotalGPM As BigDecimal
	Dim dRetVal As Double
	Dim mass, hr As Double

	Dim Matcher1, Matcher2, Matcher3 As Matcher
	Dim iMins1, iSecs1, iMilSecs1 As Double
	Dim iMins2, iSecs2, iMilSecs2 As Double
	Dim iMins3, iSecs3, iMilSecs3 As Double
	
	If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtTry1.Text)) > 0 And chkManual.Checked = False Then
		Matcher1 = Regex.Matcher("(\d\d):(\d\d).(\d\d)", txtTry1.Text)
		If Matcher1.Find Then

			iMins1 = Matcher1.Group(1)
			iSecs1 = Matcher1.Group(2)
			iMilSecs1 = Matcher1.Group(3)/100
				
			LogColor($"Minutes : "$ & iMins1, Colors.Cyan)
			LogColor($"Seconds : "$ & iSecs1, Colors.Magenta)
			LogColor($"Milliseconds : "$ & iMilSecs1, Colors.Green)
				
			If iMins1 > 1 Then
				dTry1 = (iMins1 * 60) + iSecs1 + iMilSecs1
			Else
				dTry1 = iSecs1 + iMilSecs1
			End If
		End If
	Else If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtTry1.Text)) > 0 And chkManual.Checked = True Then
		dTry1 = GlobalVar.SF.Val(txtTry1.Text)
	End If

	If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtTry2.Text)) > 0 And chkManual.Checked = False Then
		Matcher2 = Regex.Matcher("(\d\d):(\d\d).(\d\d)", txtTry2.Text)
		If Matcher2.Find Then

			iMins2 = Matcher2.Group(1)
			iSecs2 = Matcher2.Group(2)
			iMilSecs2 = Matcher2.Group(3)/100
				
			LogColor($"Minutes : "$ & iMins2, Colors.Cyan)
			LogColor($"Seconds : "$ & iSecs2, Colors.Magenta)
			LogColor($"Milliseconds : "$ & iMilSecs2, Colors.Green)
				
			If iMins2 > 1 Then
				dTry2 = (iMins2 * 60) + iSecs2 + iMilSecs2
			Else
				dTry2 = iSecs2 + iMilSecs2
			End If
		End If
	Else If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtTry2.Text)) > 0 And chkManual.Checked = True Then
		dTry2 = GlobalVar.SF.Val(txtTry2.Text)
	End If

	If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtTry3.Text)) > 0 And chkManual.Checked = False Then
		Matcher3 = Regex.Matcher("(\d\d):(\d\d).(\d\d)", txtTry3.Text)
		If Matcher3.Find Then

			iMins3 = Matcher3.Group(1)
			iSecs3 = Matcher3.Group(2)
			iMilSecs3 = Matcher3.Group(3)/100
				
			LogColor($"Minutes : "$ & iMins3, Colors.Cyan)
			LogColor($"Seconds : "$ & iSecs3, Colors.Magenta)
			LogColor($"Milliseconds : "$ & iMilSecs3, Colors.Green)
				
			If iMins3 > 1 Then
				dTry3 = (iMins3 * 60) + iSecs3 + iMilSecs3
			Else
				dTry3 = iSecs3 + iMilSecs3
			End If
		End If
	Else If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtTry3.Text)) > 0 And chkManual.Checked = True Then
		dTry3 = GlobalVar.SF.Val(txtTry3.Text)
	End If

	LogColor($"Try 1: "$ & dTry1 & $" Try 2: "$ & dTry2 & $" Try 3: "$ & dTry3, Colors.Cyan)

	If cboUOM.SelectedItem = "Liter (L)" Then
		mass = GlobalVar.SF.Val(txtBucketSize.Text) / 3.785
	Else
		mass = GlobalVar.SF.Val(txtBucketSize.Text)
	End If

	aveSec = 0
	aveSec =  (dTry1 + dTry2 + dTry3) / 3
	
	hr = 60 / aveSec
	
	dRetVal = mass * hr
	
	TotalGPM.Initialize(dRetVal)
	TotalGPM = RoundBD(TotalGPM,2)
	
	LogColor($"Average seconds: "$ & aveSec, Colors.White)
	LogColor($"Hour: "$ & hr, Colors.Green)
	LogColor($"Mass: "$ & mass, Colors.Magenta)
	LogColor($"Total GPM: "$ & TotalGPM, Colors.Cyan)
	
	Return TotalGPM
End Sub

Sub RoundBD(BD As BigDecimal, DP As Int) As BigDecimal
	BD.Round(BD.Precision - BD.Scale + DP, BD.ROUND_HALF_UP)
	Return BD
End Sub


'Sub btnStart1_Click
'	ShowTimer_Click
'End Sub
'
'
'Sub btnStart2_Click
'End Sub
'
'
'Sub btnStart3_Click
''	Select Case btnStart3.Text
''		Case "START"
''			If Not(SW3.IsInitialized) Then
''				Return
''			End If
''			SW3.Start
''						
''			btnStart3.Text = "STOP"
''			btnStart3.Enabled = False
''			
''		Case "STOP"
''			sTime3 = SW3.Text
''			LogColor($"Trial 3: "$ & sTime3, Colors.Yellow)
''			ConfirmStopTimer($"CONFIRM TIMER STOP"$, $"Do you want to stop the timer and get this time as 3rd Try?"$, 3)
''	End Select
'End Sub

Private Sub ConvertMillisecondsToString(t As Long) As String
	Dim hours, minutes, seconds, msec As Int
	hours = t / DateTime.TicksPerHour
	minutes = (t Mod DateTime.TicksPerHour) / DateTime.TicksPerMinute
	seconds = (t Mod DateTime.TicksPerMinute) / DateTime.TicksPerSecond
	msec = DateTime.TicksPerSecond / 100
	Return $"$1.0{hours}:$2.0{minutes}:$2.0{seconds}.$2.0{msec}"$
End Sub

Private Sub Timer1_Tick
	Dim milliseconds As Long = DateTime.Now - StartTime
'	txt1st.Text = ConvertMillisecondsToString(milliseconds)
End Sub

Public Sub CreateButtonColor(FocusedColor As Int, EnabledColor As Int, DisabledColor As Int, PressedColor As Int) As StateListDrawable

	Dim RetColor As StateListDrawable
	Dim drwFocusedColor, drwEnabledColor, drwDisabledColor, drwPressedColor As ColorDrawable

	'drwFocusedColor.Initialize2(FocusedColor, 5, 0, Colors.LightGray) 'border roundness, thickness, and color on Android TV
	'drwEnabledColor.Initialize2(EnabledColor, 5, 0, Colors.DarkGray)
	'drwDisabledColor.Initialize2(DisabledColor, 5, 0, Colors.White)
	'drwPressedColor.Initialize2(PressedColor, 5, 0, Colors.Black)
'	CD.Initialize(0xFF1976D2, 25)
	RetColor.Initialize
	
	drwFocusedColor.Initialize2(FocusedColor, 25, 0, Colors.Black)
	drwEnabledColor.Initialize2(EnabledColor, 25, 0, Colors.Black)
	drwDisabledColor.Initialize2(DisabledColor, 25, 2, Colors.Black)
	drwPressedColor.Initialize2(PressedColor, 25, 0, Colors.Black)

	RetColor.AddState(RetColor.State_Focused, drwFocusedColor)
	RetColor.AddState(RetColor.State_Pressed, drwPressedColor)
	RetColor.AddState(RetColor.State_Enabled, drwEnabledColor)
	RetColor.AddState(RetColor.State_Disabled, drwDisabledColor)
	RetColor.AddCatchAllState(drwFocusedColor)
	RetColor.AddCatchAllState(drwEnabledColor)
	RetColor.AddCatchAllState(drwDisabledColor)
	RetColor.AddCatchAllState(drwPressedColor)
	Return RetColor

End Sub

Private Sub SetButtonColors()
'	0xFF1976D2
	btnShowTimer1.Background = CreateButtonColor(0xFF28A745, 0xFF1976D2,0xFF1E88E5, 0xFF28A745)
	btnShowTimer2.Background = CreateButtonColor(0xFF28A745, 0xFF1976D2,0xFF1E88E5, 0xFF28A745)
	btnShowTimer3.Background = CreateButtonColor(0xFF28A745, 0xFF1976D2,0xFF1E88E5, 0xFF28A745)
End Sub

Private Sub ConfirmStopTimer(sTitle As String, sMsg As String, iSender As Int)
	iTimer = iSender
	Alert.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(Alert.STYLE_DIALOGUE) _
			.SetCancelable(False) _
			.SetTitle(sTitle) _
			.SetTitleColor(GlobalVar.BlueColor) _
			.SetTitleTypeface(FontBold) _
			.SetMessage(sMsg) _
			.SetPositiveText("Confirm") _
			.SetPositiveColor(GlobalVar.PosColor) _
			.SetPositiveTypeface(FontBold) _
			.SetNegativeText("Cancel") _
			.SetNegativeColor(GlobalVar.NegColor) _
			.SetNegativeTypeface(Font) _
			.SetMessageTypeface(Font) _
			.SetOnPositiveClicked("StopTimer") _	'listeners
			.SetOnNegativeClicked("StopTimer")	'listeners
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Listeners
Private Sub StopTimer_OnNegativeClicked (View As View, Dialog As Object)
	Alert.Initialize.Dismiss2
End Sub


Private Sub StopTimer_OnPositiveClicked (View As View, Dialog As Object)
	Dim RetVal As Double
	Dim bdTime As BigDecimal
	Dim sMin As String
	
	Alert.Initialize.Dismiss2
	
	
	LogColor($"Return Value is: "$ & RetVal, Colors.Yellow)
	
	bdTime.Initialize(RetVal)
	bdTime = RoundBD(bdTime,2)
	
	
	Select Case iTimer
		Case 1
			txtTry1.Text = SW1.Text
			dTime1 =  bdTime
			LogColor($"1st Try: "$ & dTime1, Colors.Magenta)
			btnShowTimer2.Enabled = True
		Case 2
			txtTry2.Text = SW1.Text
			dTime2 =  bdTime
			LogColor($"2nd Try: "$ & dTime2, Colors.Yellow)
			btnShowTimer3.Enabled = True
		Case 3
			txtTry3.Text = SW1.Text
			dTime3 =  bdTime
			LogColor($"3rd Try: "$ & dTime3, Colors.Cyan)
		End Select

	pnlMainTimer.Visible = False

End Sub


Sub ShowTimer
	cdStart.Initialize2(GlobalVar.GreenColor2, 20, 0, Colors.Transparent)
	cdPause.Initialize2(GlobalVar.YellowColor, 20, 0, Colors.Transparent)
	cdStop.Initialize2(GlobalVar.RedColor, 20, 0, Colors.Transparent)
	cdReset.Initialize2(GlobalVar.BlueColor, 25, 0, Colors.Transparent)
	
	pnlMainTimer.Visible = True
	SW1.Initialize("")
	pnlStopWatch.AddView(SW1,1%x, 1%y, pnlStopWatch.Width - 1%x, pnlStopWatch.Height - 1%y)
	SW1.Color = Colors.Black
	SW1.TextColor = 0xFFADFF2F
	SW1.TextSize = 40
	SW1.Typeface = Typeface.DEFAULT_BOLD
	SW1.Gravity = Gravity.CENTER
	
	btnStart.Background = cdStart
	btnStop.Background = cdStop
	btnPause.Background = cdPause
	btnReset.Background = cdReset
	MyFunctions.SetButton(btnOk, 20, 20, 20, 20, 20, 20, 20, 20)
	MyFunctions.SetCancelButton(btnCancel, 20, 20, 20, 20, 20, 20, 20, 20)

	btnStart.Enabled = True
	btnStop.Enabled = False
	btnPause.Enabled = False
	btnOk.Enabled = False
	btnCancel.Enabled = True
	btnReset.Enabled = False
End Sub

Sub btnReset_Click
	If Not(SW1.IsInitialized) Then
		Return
	End If
	SW1.Reset
	
	btnReset.Enabled = False
	btnPause.Enabled = False
	btnStop.Enabled = False
	btnStart.Enabled = True
	btnOk.Enabled = True
	
End Sub

Sub btnStop_Click
	If Not(SW1.IsInitialized) Then
		Return
	End If
	SW1.Stop
	
	btnReset.Enabled = True
	btnPause.Enabled = False
	btnStop.Enabled = False
	btnStart.Enabled = False
	btnOk.Enabled = True
	btnCancel.Enabled = True
End Sub

Sub btnStart_Click
	If Not(SW1.IsInitialized) Then
		Return
	End If
	SW1.Start

	btnStart.Enabled = False
	btnStop.Enabled = True
	btnPause.Enabled = True
	btnReset.Enabled = False
	btnCancel.Enabled = False
End Sub

Sub btnPause_Click
	Select Case btnPause.Text
		Case "PAUSE"
			If Not(SW1.IsInitialized) Then
				Return
			End If
			SW1.Pause
			btnStart.Enabled = False
			btnStop.Enabled = False
			btnPause.Enabled = True
			btnReset.Enabled = False
			btnPause.Text = "RESUME"
			btnReset.Enabled = True
			btnCancel.Enabled = True
		Case "RESUME"
			If Not(SW1.IsInitialized) Then
				Return
			End If
			SW1.Resume

			btnStart.Enabled = False
			btnStop.Enabled = True
			btnPause.Enabled = True
			btnReset.Enabled = False
			btnPause.Text = "PAUSE"
			btnReset.Enabled = False
			btnCancel.Enabled = True
	End Select
End Sub


Sub txtTry1_TextChanged (Old As String, New As String)
	If GlobalVar.SF.Len(txtBucketSize.Text) <= 0 Or GlobalVar.SF.Len(cboUOM.SelectedItem) <= 0 Or GlobalVar.SF.Len(txtTry1.Text) <= 0 Or GlobalVar.SF.Len(txtTry2.Text) <= 0 Or GlobalVar.SF.Len(txtTry3.Text) <= 0 Then
		txtGPM.Text = 0
		Return
	End If
	txtGPM.Text = ComputeGPM
End Sub

Sub txtTry2_TextChanged (Old As String, New As String)
	If GlobalVar.SF.Len(txtBucketSize.Text) <= 0 Or GlobalVar.SF.Len(cboUOM.SelectedItem) <= 0 Or GlobalVar.SF.Len(txtTry1.Text) <= 0 Or GlobalVar.SF.Len(txtTry2.Text) <= 0 Or GlobalVar.SF.Len(txtTry3.Text) <= 0 Then
		txtGPM.Text = 0
		Return
	End If
	txtGPM.Text = ComputeGPM	
End Sub

Sub txtTry3_TextChanged (Old As String, New As String)
	If GlobalVar.SF.Len(txtBucketSize.Text) <= 0 Or GlobalVar.SF.Len(cboUOM.SelectedItem) <= 0 Or GlobalVar.SF.Len(txtTry1.Text) <= 0 Or GlobalVar.SF.Len(txtTry2.Text) <= 0 Or GlobalVar.SF.Len(txtTry3.Text) <= 0 Then
		txtGPM.Text = 0
		Return
	End If
	txtGPM.Text = ComputeGPM
End Sub

Sub btnShowTimer1_Click
	iTimer = 1 
	ShowTimer
End Sub

Sub btnShowTimer2_Click
	iTimer = 2
	ShowTimer	
End Sub

Sub btnShowTimer3_Click
	iTimer = 3
	ShowTimer
End Sub

Sub txtBucketSize_TextChanged (Old As String, New As String)
	If GlobalVar.SF.Len(txtBucketSize.Text) <= 0 Or GlobalVar.SF.Len(cboUOM.SelectedItem) <= 0 Or GlobalVar.SF.Len(txtTry1.Text) <= 0 Or GlobalVar.SF.Len(txtTry2.Text) <= 0 Or GlobalVar.SF.Len(txtTry3.Text) <= 0 Then
		txtGPM.Text = 0
		Return
	End If
	txtGPM.Text = ComputeGPM
End Sub

Sub txtBucketSize_EnterPressed
	cboUOM.RequestFocus
End Sub

Sub chkManual_CheckedChange(Checked As Boolean)
	If Checked Then
		btnShowTimer1.Enabled = False
		btnShowTimer2.Enabled = False
		btnShowTimer3.Enabled = False
		txtTry1.Text = ""
		txtTry2.Text = ""
		txtTry3.Text = ""
		txtTry1.Enabled = True
		txtTry2.Enabled = True
		txtTry3.Enabled = True
		txtTry1.RequestFocus
	Else
		btnShowTimer1.Enabled = True
		txtTry1.Text = ""
		txtTry2.Text = ""
		txtTry3.Text = ""
		txtTry1.Enabled = False
		txtTry2.Enabled = False
		txtTry3.Enabled = False
	End If
End Sub

Private Sub InitObjects
	chkManual.Checked = False
	txtGPM.Text = "0"
	txtBucketSize.Text = ""
	txtTry1.Text = ""
	txtTry2.Text = ""
	txtTry3.Text = ""
	txtWaterQuality.Text = ""
	txtRemarks.Text = ""
	txtTry1.Enabled = False
	txtTry2.Enabled = False
	txtTry3.Enabled = False
	btnShowTimer1.Enabled = True
	btnShowTimer2.Enabled = False
	btnShowTimer3.Enabled = False
	pnlMainTimer.Visible = False
End Sub

Sub btnOk_Click
	Select Case iTimer
		Case 1
			ConfirmStopTimer($"CONFIRM TIME"$, $"Do you want to fetch this as your Trial 1 time?"$, iTimer)
		Case 2
			ConfirmStopTimer($"CONFIRM TIME"$, $"Do you want to fetch this as your Trial 2 time?"$, iTimer)
		Case 3
			ConfirmStopTimer($"CONFIRM TIME"$, $"Do you want to fetch this as your Trial 3 time?"$, iTimer)
	End Select
End Sub

Sub btnCancel_Click
	If Not(SW1.IsInitialized) Then
		Return
	End If
	SW1.Stop
	pnlMainTimer.Visible = False
End Sub

Private Sub RequiredMsgBox(sTitle As String, sMsg As String)
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
			.SetOnViewBinder("FontSizeBinder") 'listeners
	
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Listeners

Private Sub RequiredMsg_OnPositiveClicked (View As View, Dialog As Object)
	Alert.Initialize.Dismiss2
End Sub

Private Sub IsValidEntries() As Boolean
	Dim blnRetVal As Boolean
	
	blnRetVal = False

	Try
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtBucketSize.Text)) <= 0 Or txtBucketSize.Text = "" Then
			RequiredMsgBox($"E R R O R"$, "Bucket size cannot be blank!")
			txtBucketSize.RequestFocus
			Return False
		End If
	
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtTry1.Text)) = 0 Or txtTry1.Text = "" Then
			RequiredMsgBox($"E R R O R"$, "First Try cannot be blank!")
			If chkManual.Checked = True Then
				txtTry1.Enabled = True
				txtTry1.RequestFocus
			Else
				txtTry1.Enabled = False
				btnShowTimer1.Enabled = True
				btnShowTimer1.RequestFocus
			End If
			Return False
		Else If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtTry2.Text)) = 0 Or txtTry2.Text = "" Then
			RequiredMsgBox($"E R R O R"$, "Second Try cannot be blank!")
			If chkManual.Checked = True Then
				txtTry2.Enabled = True
				txtTry2.RequestFocus
			Else
				txtTry2.Enabled = False
				btnShowTimer2.Enabled = True
				btnShowTimer1.RequestFocus
			End If
			Return False
		Else If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtTry3.Text)) = 0 Or txtTry3.Text = "" Then
			RequiredMsgBox($"E R R O R"$, "Third Try cannot be blank!")
			If chkManual.Checked = True Then
				txtTry3.Enabled = True
				txtTry3.RequestFocus
			Else
				txtTry3.Enabled = False
				btnShowTimer3.Enabled = True
				btnShowTimer3.RequestFocus
			End If
			Return False
		End If
	
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtWaterQuality.Text)) <= 0 Or txtWaterQuality.Text = "" Then
			RequiredMsgBox($"E R R O R"$, "Water Quality cannot be blank!")
			txtWaterQuality.RequestFocus
			Return False
		End If
		blnRetVal = True		
	Catch
		blnRetVal = False
		Log(LastException)
	End Try
	Return blnRetVal
End Sub

Private Sub FontSizeBinder_OnBindView (View As View, ViewType As Int)
	Dim SaveAlert As AX_CustomAlertDialog
	SaveAlert.Initialize
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

Sub pnlMainTimer_Click
	
End Sub