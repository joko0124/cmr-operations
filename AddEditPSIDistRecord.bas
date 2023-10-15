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
	Dim TYPE_TEXT_FLAG_NO_SUGGESTIONS  As Int = 0x80000
End Sub

Sub Globals
	Dim ActionBarButton As ACActionBar
	Private ToolBar As ACToolBarDark

	Private MatDialogBuilder As MaterialDialogBuilder
	Private CD, CDtxtBox As ColorDrawable

	Private vibration As B4Avibrate
	Private snack As DSSnackbar
	Private cdReading As ColorDrawable
	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")
	
	'UI
	Private lblCode As Label
	Private cboPSIPoint As ACSpinner
	Private txtLocation As EditText
	Private chkDefaultTimeRead As CheckBox
	Private mskTimeRead As MaskedEditText
	Private txtPSIRdg As EditText
	Private sRdgTime As String
	Private txtRemarks As EditText
	Private btnSaveUpdate As ACButton
	
	Private cKeyboard As CustomKeyboard
	Private imeKeyboard As IME
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("NewPsiRdgDist")

	lblCode.Text = GlobalVar.PumpHouseCode & $" - "$ & GetPumpLocation(GlobalVar.PumpHouseID)
	imeKeyboard.Initialize("ime")
	
	InpTyp.Initialize
	InpTyp.SetInputType(txtRemarks,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_CORRECT, InpTyp.TYPE_TEXT_FLAG_CAP_SENTENCES))
	
	GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"SERVICE LINE PRESSURE READING"$).PopAll
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
	FillPressurePoint(GlobalVar.PumpHouseID)

	If GlobalVar.blnNewPSIDist = True Then
		ClearUI
		btnSaveUpdate.Text = Chr(0xE161) & $" SAVE"$
	Else
		btnSaveUpdate.Text = Chr(0xE161) & $" UPDATE"$
		ClearUI
		GetPSIDistRdgDetails(GlobalVar.PSIDistDetailID)
	End If

	If FirstTime Then
		FillPressurePoint(GlobalVar.PumpHouseID)
	End If
	txtPSIRdg.InputType = Bit.Or(txtPSIRdg.InputType,TYPE_TEXT_FLAG_NO_SUGGESTIONS)
	txtPSIRdg.SingleLine = True
	txtPSIRdg.ForceDoneButton = True
	cKeyboard.Initialize("CKB","keyboardview_trans")
	cKeyboard.RegisterEditText(txtPSIRdg,"txtPSIRdg","num",True)

	MyFunctions.SetButton(btnSaveUpdate, 25, 25, 25, 25, 25, 25, 25, 25)
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
End Sub

Sub Activity_Pause (UserClosed As Boolean)
End Sub

#End Region

#Region Toolbar
Sub Activity_CreateMenu(Menu As ACMenu)
'	Dim Item As ACMenuItem
	Menu.Clear
End Sub

Sub ToolBar_NavigationItemClick 'Toolbar Arroww
	If cKeyboard.IsSoftKeyboardVisible = True Then
		cKeyboard.HideKeyboard
	Else
		Activity.Finish
	End If
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
End Sub
#End Region

Sub btnSaveUpdate_Click
	If Not(IsValidEntries) Then Return

	Dim Matcher1 As Matcher
	Dim sMin, sHr As String
	sRdgTime = ""

	If Not(IsValidEntries) Then Return 'Check Entries
	
	Matcher1 = Regex.Matcher("(\d\d):(\d\d)", mskTimeRead.Text)
	
	If Matcher1.Find Then 'Split
		Dim iHrs, iMins As Int
		
		iHrs = Matcher1.Group(1)
		iMins = Matcher1.Group(2)
		
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMins)) = 1 Then 'Test length of mins
			sMin = $"0"$ & iMins
		Else
			sMin = iMins
		End If

		If iHrs = 0 Then '12 AM
			sHr = 12
			sRdgTime = sHr & ":" & sMin & " AM"
		Else If iHrs > 0 And iHrs < 12 Then '1 to 11 AM
			sHr = iHrs
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(sHr)) = 1 Then
				sRdgTime = $"0"$ & sHr & ":" & sMin & " AM"
			Else
				sRdgTime = sHr & ":" & sMin & " AM"
			End If
			
		Else If iHrs = 12 Then '12 Noon
			sHr = 12
			sRdgTime = sHr & ":" & sMin & " PM"
		Else ' 1 to 11 PM
			sHr = iHrs - 12
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(sHr)) = 1 Then
				sRdgTime = $"0"$ & sHr & ":" & sMin & " PM"
			Else
				sRdgTime = sHr & ":" & sMin & " PM"
			End If
		End If
	End If
		
	LogColor($"Reading Time: "$ & sRdgTime,Colors.Yellow)

	ConfirmSaveUpdateReading
End Sub

Sub cboPSIPoint_ItemClick (Position As Int, Value As Object)
	LogColor($"Selected "$ & Position & " - " & Value,Colors.Yellow)
	txtLocation.Text = GetLocation(Value)
End Sub

Sub chkDefaultTimeRead_CheckedChange(Checked As Boolean)
	Dim sHour As String
	Dim sMin As String
	Dim lHour, lMin As Long
	
	If Checked = True Then
		DateTime.TimeFormat = "hh:mm a"
		lHour = DateTime.GetHour(DateTime.Now)
		lMin = DateTime.GetMinute(DateTime.Now)
		
		If GlobalVar.SF.Len(lHour) = 1 Then
			sHour = $"0"$ & lHour
		Else
			sHour = lHour
		End If

		If GlobalVar.SF.Len(lMin) = 1 Then
			sMin = $"0"$ & lMin
		Else
			sMin = lMin
		End If

		mskTimeRead.Text = sHour & ":" & sMin
		mskTimeRead.Enabled = False
	Else
		mskTimeRead.Enabled = True
		mskTimeRead.Text = "__:__"
		mskTimeRead.RequestFocus
		imeKeyboard.ShowKeyboard(mskTimeRead)
	End If
	
End Sub

Sub mskTimeRead_FocusChanged(HasFocus As Boolean)
	
End Sub

Sub txtPSIRdg_EnterPressed
	txtRemarks.RequestFocus
	cKeyboard.HideKeyboard
End Sub

Sub txtPSIRdg_FocusChanged (HasFocus As Boolean)
	If HasFocus = True Then
		cKeyboard.ShowKeyboard(txtPSIRdg)
	Else
		cKeyboard.HideKeyboard
	End If
End Sub

#Region NEW PSI Reading
Private Sub SavePSIDistRdg() As Boolean
	Dim bRetVal As Boolean
	Dim DateRead, TimeRead As String
	Dim PSIPointID As Int
	Dim sDateTime As String
	Dim lDate As Long
	Dim iPSI As Int
	Dim sLocation, sRemarks As String
	
	bRetVal = False
	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss a"
	sDateTime = DateTime.Date(lDate)

	'Reading Date and Time**************************************
	TimeRead = sRdgTime
	DateRead = GlobalVar.TranDate
	'***********************************************************
	
	PSIPointID = GetPointID(cboPSIPoint.SelectedItem)
	iPSI = GlobalVar.SF.Val(txtPSIRdg.Text)
	sRemarks = txtRemarks.Text
	Starter.FLP.Connect

	Log($"FLP is COnnected? "$ & Starter.FLP.IsConnected)
	
	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)

	sLocation = GlobalVar.Lat & "," & GlobalVar.Lon
	LogColor($"Location is "$ & sLocation, Colors.Yellow)
	
	Starter.DBCon.BeginTransaction
	Try
		Starter.DBCon.ExecNonQuery2("INSERT INTO PressureDistReadings VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
							  Array As Object(GlobalVar.BranchID, PSIPointID, DateRead, TimeRead, iPSI, sRemarks, GlobalVar.UserID, sDateTime, sLocation, Null, Null, $""$, $"0"$, Null, Null))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		ToastMessageShow($"Unable to save Pressure from Distribution Reading due to "$ & LastException.Message,True)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

#End Region

#Region Edit PSI Reading
Private Sub GetPSIDistRdgDetails(iRdgID As Int)
	Dim sPointNo As String
	Dim sTimeRdg As String
	Dim Matcher1 As Matcher

	Try
		Dim SenderFilter As Object
	
		Starter.strCriteria = "SELECT PressurePointRdg.RdgID, " & _
						  "PressurePoint.PumpHouseID, PressurePointRdg.PSIPointID, PressurePoint.PPointNo,PressurePoint.PLocation, " & _
						  "PressurePointRdg.RdgTime, PressurePointRdg.PSIReading, PressurePointRdg.Remarks " & _
						  "FROM PressureDistReadings AS PressurePointRdg " & _
						  "INNER JOIN tblPressurePoint AS PressurePoint ON PressurePointRdg.PSIPointID = PressurePoint.ID " & _
						  "WHERE PressurePointRdg.RdgID = " & iRdgID
						  							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			RS.Position = 0
			GlobalVar.PumpHouseID = RS.GetInt("PumpHouseID")
			sPointNo = RS.GetString("PPointNo")
			cboPSIPoint.SelectedIndex = cboPSIPoint.IndexOf(sPointNo)
			txtLocation.Text = RS.GetString("PLocation")
			chkDefaultTimeRead.Checked = False
			sTimeRdg = RS.GetString("RdgTime")
			txtPSIRdg.Text = RS.GetString("PSIReading")
			txtRemarks.Text = RS.GetString("Remarks")
			
			DateTime.TimeFormat = "HH:mm"
			Matcher1 = Regex.Matcher("(\d\d):(\d\d) (\S\S)", sTimeRdg)
			If Matcher1.Find Then
				Dim iHrs, iMins As Int
				Dim AmPm As String
				Dim sMin As String
				
				iHrs = Matcher1.Group(1)
				iMins = Matcher1.Group(2)
				AmPm = Matcher1.Group(3)
				
				LogColor(AmPm,Colors.Cyan)
				
				If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMins)) = 1 Then
					sMin = $"0"$ & iMins
				Else
					sMin = iMins
				End If

				If AmPm = "AM" Then
					If iHrs = 12 Then
						mskTimeRead.Text = $"00:"$ & sMin
					Else
						If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrs)) = 1 Then
							mskTimeRead.Text = $"0"$ & iHrs & $":"$ & sMin
						Else
							mskTimeRead.Text = iHrs & $":"$ & sMin
						End If
					End If
				Else
					If iHrs < 12 Then
						mskTimeRead.Text = (iHrs + 12) & $":"$ & sMin
					Else
						mskTimeRead.Text = iHrs & $":"$ & sMin
					End If
				End If
			End If
			
		Else
			
			snack.Initialize("", Activity,$"Cannot Return PSI Distribution Reading due to "$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If

		Starter.strCriteria = ""
		LogColor(Starter.strCriteria, Colors.Magenta)
		
	Catch
		snack.Initialize("", Activity,$"Cannot Return PSI Distribution Reading due to "$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End Try
End Sub

Private Sub UpdatePSIDistRdg(iRdgID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim DateRead, TimeRead As String
	Dim PSIPointID As Int
	Dim sDateTime As String
	Dim lDate As Long
	Dim iPSI As Int
	Dim sLocation, sRemarks As String
	
	bRetVal = False
	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss a"
	sDateTime = DateTime.Date(lDate)

	'Reading Date and Time**************************************
	TimeRead = sRdgTime
	DateRead = GlobalVar.TranDate
	'***********************************************************
	
	PSIPointID = GetPointID(cboPSIPoint.SelectedItem)
	iPSI = GlobalVar.SF.Val(txtPSIRdg.Text)
	sRemarks = txtRemarks.Text
	Starter.FLP.Connect

	Log($"FLP is COnnected? "$ & Starter.FLP.IsConnected)
	
	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)

	sLocation = GlobalVar.Lat & "," & GlobalVar.Lon
	LogColor($"Location is "$ & sLocation, Colors.Yellow)
	
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE PressureDistReadings SET " & _
						  "PSIPointID = ?, " & _
						  "RdgDate = ?, " & _
						  "RdgTime = ?, " & _
						  "PSIReading = ?, " & _
						  "Remarks = ?, " & _
						  "ModifiedBy = ?, " & _
						  "ModifiedAt = ?, " & _
						  "ModifiedOn = ? " & _
						  "WHERE RdgID = " & iRdgID
		LogColor(Starter.strCriteria, Colors.Yellow)
		
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(PSIPointID, DateRead, TimeRead, iPSI, sRemarks, GlobalVar.UserID, sDateTime, sLocation))
		Starter.DBCon.TransactionSuccessful
	Catch
		Log(LastException)
		ToastMessageShow($"Unable to Update Pressure Reading upon Distribution due to "$ & LastException.Message,True)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
	
End Sub
#End Region

#Region Misc Function

Private Sub ClearUI
	cboPSIPoint.Clear
	txtLocation.Text = ""
	chkDefaultTimeRead.Checked = False
	mskTimeRead.Text = "__:__"
	txtPSIRdg.Text = ""
	txtRemarks.Text = ""
	CDtxtBox.Initialize(Colors.Transparent,0)

	txtLocation.Background = CDtxtBox
	mskTimeRead.Background = CDtxtBox
	txtRemarks.Background = CDtxtBox
	cboPSIPoint.Background = CDtxtBox
	
	cdReading.Initialize2(Colors.Black,0,0,0)
	txtPSIRdg.Background = cdReading
End Sub

Private Sub GetPumpLocation (iPumpID As Int) As String
	Dim sRetval As String
	sRetval = ""
	Try
		Starter.strCriteria = "SELECT PumpLocation FROM tblPumpStation WHERE StationID = " & iPumpID
		sRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		sRetval = ""
		Log(LastException)
	End Try
	Return sRetval
End Sub


Sub FillPressurePoint(iPumpID As Int)
	Dim SenderFilter As Object
	cboPSIPoint.Clear
	Try
		Starter.strCriteria = "SELECT PPointNo FROM tblPressurePoint WHERE PumpHouseID = " & iPumpID

		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			Do While RS.NextRow
				cboPSIPoint.Add(GlobalVar.SF.Upper(RS.GetString("PPointNo")))
			Loop
		Else
			snack.Initialize("", Activity, $"Cannot get Pressure Point due to "$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If
		txtLocation.Text = GetLocation(cboPSIPoint.SelectedItem)

	Catch
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End Try
End Sub

Private Sub GetLocation (sValue As String) As String
	Dim sRetval As String
	sRetval = ""
	Try
		Starter.strCriteria = "SELECT PLocation FROM tblPressurePoint WHERE UPPER(PPointNo) = '" & sValue & "'"
		sRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		sRetval = ""
		Log(LastException)
	End Try
	Return sRetval
End Sub

Private Sub GetPointID (sValue As String) As Int
	Dim iRetval As Int
	iRetval = 0
	Try
		Starter.strCriteria = "SELECT ID FROM tblPressurePoint WHERE UPPER(PPointNo) = '" & sValue & "'"
		iRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		iRetval = 0
		Log(LastException)
	End Try
	Return iRetval
End Sub

Private Sub IsValidEntries () As Boolean
	Try
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(cboPSIPoint.SelectedItem)) <=0 Then
			RequiredMsgBox($"ERROR"$, $"Pressure Point cannot be blank!"$)
			cboPSIPoint.RequestFocus
			Return False
		End If
		
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(mskTimeRead.Text)) <= 0 Or mskTimeRead.Text = "__:__" Then
			RequiredMsgBox($"ERROR"$, $"Reading Time cannot be blank!"$)
			mskTimeRead.RequestFocus
			Return False
			
		Else If Validation.IsTime(mskTimeRead.Text) = False Then
			RequiredMsgBox($"ERROR"$, $"Invalid Reading Time!"$)
			mskTimeRead.RequestFocus
			Return False
		End If
		
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtPSIRdg.Text)) <=0 Then
			RequiredMsgBox($"ERROR"$, $"Pressure Reading cannot be blank!"$)
			txtPSIRdg.RequestFocus
			Return False
		End If

		Return True
	Catch
		Return False
		Log(LastException)
	End Try
End Sub
#End Region

#Region MessageBox

'Custom Message Box
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
			.SetOnViewBinder("FontSizeBinder") 'listeners
	
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Listeners

Private Sub RequiredMsg_OnPositiveClicked (View As View, Dialog As Object)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
End Sub


'Normal Reading
Private Sub ConfirmSaveUpdateReading
	Dim Alert As AX_CustomAlertDialog
	Dim sTitle, sMsg As String
	
	If GlobalVar.blnNewPSIDist = True Then
		sTitle = $"SAVE NEW PSI READING"$
		sMsg = $"Save New Pressure Reading?"$
	Else
		sTitle = $"UPDATE PSI READING"$
		sMsg = $"Update Pressure Reading?"$
	End If

	Alert.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(Alert.STYLE_DIALOGUE) _
			.SetCancelable(False) _
			.SetTitle(sTitle) _
			.SetTitleColor(GlobalVar.BlueColor) _
			.SetTitleTypeface(FontBold) _
			.SetMessage(sMsg) _
			.SetMessageTypeface(Font) _
			.SetPositiveText("Confirm") _
			.SetPositiveColor(GlobalVar.PosColor) _
			.SetPositiveTypeface(FontBold) _
			.SetNegativeText("Cancel") _
			.SetNegativeColor(GlobalVar.NegColor) _
			.SetNegativeTypeface(Font) _
			.SetOnPositiveClicked("SavePSIReading") _	'listeners
			.SetOnNegativeClicked("SavePSIReading")	'listeners
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Listeners
Private Sub SavePSIReading_OnNegativeClicked (View As View, Dialog As Object)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub SavePSIReading_OnPositiveClicked (View As View, Dialog As Object)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
	If GlobalVar.blnNewPSIDist = True Then
		If Not(SavePSIDistRdg) Then
			RequiredMsgBox($"ERRORS SAVING"$,$"Unable to Save Pressure Reading due to"$ & LastException.Message)
			Return
		End If
	Else
		UpdatePSIDistRdg(GlobalVar.PSIDistDetailID)
	End If
	ShowSaveSuccess
End Sub

Private Sub FontSizeBinder_OnBindView (View As View, ViewType As Int)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize
	If ViewType = Alert.VIEW_TITLE Then ' Title
		Dim lbl As Label = View
		lbl.TextSize = 30
		lbl.SetTextColorAnimated(2000,Colors.Magenta)
		
		Dim CS As CSBuilder
		CS.Initialize.Typeface(Typeface.MATERIALICONS).Size(26).Color(Colors.Red).Append(Chr(0xE88E) & "  ")
		CS.Typeface(Font).Size(24).Append(lbl.Text).Pop

		lbl.Text = CS.PopAll
	End If
End Sub

'Material Dialog Message Box
Private Sub ShowSaveSuccess()
	Dim csTitle As CSBuilder
	Dim csContent As CSBuilder

	If GlobalVar.blnNewPSIDist = True Then
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"New Pressure Reading has been successfully saved!"$).PopAll
	Else
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"Pressure Reading has been successfully updated!"$).PopAll
	End If
	
	MatDialogBuilder.Initialize("AddUpdatePSIReading")
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content(csContent)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(False)
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
	MatDialogBuilder.Show
End Sub

Private Sub AddUpdatePSIReading_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			imeKeyboard.HideKeyboard
			Activity.Finish
	End Select
End Sub


#End Region