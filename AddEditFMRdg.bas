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
	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")
	Private InpTyp As SLInpTypeConst
	
	Private soundsAlarmChannel As SoundPool
	Private TTS1 As TTS
	Dim TYPE_TEXT_FLAG_NO_SUGGESTIONS  As Int = 0x80000
End Sub

Sub Globals
	Dim ActionBarButton As ACActionBar
	Private ToolBar As ACToolBarDark
	
	Private xmlIcon As XmlLayoutBuilder
	Private MatDialogBuilder As MaterialDialogBuilder
	
	Private CDtxtBox, cdFixedText As ColorDrawable

	Private snack As DSSnackbar
	Private csAns As CSBuilder

	Private imeKeyboard As IME
	Private Alert As AX_CustomAlertDialog

	Private cdOK As ColorDrawable
	Private cdCancel As ColorDrawable

	Private vibration As B4Avibrate
	Private vibratePattern() As Long
	Private SoundID As Int

	'UI
	Private chkDefaultTimeRead As CheckBox
	Private mskTimeRead As MaskedEditText
	Private txtFMRdg As EditText
	Private txtFMRdgRemarks As EditText
	Private btnCancel As ACButton
	Private btnSaveUpdate As ACButton
	
	Private dLastFMRdg As Double
	Private dPreviousRdg As Double
	Private dBackFlow As Double
	
	'Zero Reading
	Private pnlZeroProdMsg As Panel
	Private btnZeroOk As ACButton
	Private btnZeroCancel As ACButton
	Private lblZeroMsg As Label
	Private txtZeroRemarks As EditText
	
	'Negative Reading
	Private pnlNegativeProdMsg As Panel
	Private btnNegativeOk As ACButton
	Private lblNegativeMsg As Label
	Private chkBackFlow As CheckBox
	Private txtBackFlowCum As EditText
	Private isNegativeRdg As Boolean
	Private btnNegativeCancel As ACButton
	Private txtNegativeRemarks As EditText
	
	'High Reading
	Private pnlHighProdMsg As Panel
	Private btnHighCancel As ACButton
	Private btnHighOk As ACButton
	
	'Confirm High
	Private pnlHighBillConfirmation As Panel
	Private txtPresRdgConfirm As EditText
	Private btnHBConfirmCancel As ACButton
	Private btnHBConfirmSave As ACButton
	Private txtHighRemarks As EditText
	Private sHighRdg As String

	'Low Reading
	Private pnlLowProdMsg As Panel
	Private btnLowCancel As ACButton
	Private btnLowOk As ACButton
	
	'/////////////////////////////////////////
	Private sRdgTime As String
	Private cKeyboard As CustomKeyboard
	Private pnlKeyboard As Panel
	
	Private sUploadReading As String
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("PumpFMReading")
	
	Dim jo As JavaObject
	Dim xl As XmlLayoutBuilder
	jo.InitializeStatic("java.util.Locale").RunMethod("setDefault", Array(jo.GetField("US")))

	jo = ToolBar
	jo.RunMethod("setPopupTheme", Array(xl.GetResourceId("style", "ToolbarMenu")))
	jo.RunMethod("setContentInsetStartWithNavigation", Array(1dip))
	jo.RunMethod("setTitleMarginStart", Array(0dip))

	ActionBarButton.Initialize
	ActionBarButton.ShowUpIndicator = True

	If GlobalVar.blnNewFMRdg = True Then
		GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"ADD NEW FLOW METER READING RECORD"$).PopAll
		GlobalVar.CSSubTitle.Initialize.Size(12).Append($"Transaction Date: "$ & GlobalVar.TranDate).PopAll
	Else
		GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"EDIT FLOW METER READING RECORD"$).PopAll
		GlobalVar.CSSubTitle.Initialize.Size(12).Append($"Transaction Date: "$ & GlobalVar.TranDate).PopAll
	End If

	ToolBar.InitMenuListener
	ToolBar.Title = GlobalVar.CSTitle
	ToolBar.SubTitle = GlobalVar.CSSubTitle
	
	txtFMRdg.InputType = Bit.Or(txtFMRdg.InputType,TYPE_TEXT_FLAG_NO_SUGGESTIONS)
	txtFMRdg.SingleLine = True
	txtFMRdg.ForceDoneButton = True
	cKeyboard.Initialize("CKB","keyboardview_trans")
	cKeyboard.RegisterEditText(txtFMRdg,"txtFMRdg","num",True)

	InpTyp.Initialize
	InpTyp.SetInputType(txtFMRdgRemarks,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_CORRECT, InpTyp.TYPE_TEXT_FLAG_CAP_SENTENCES))
'	InpTyp.SetInputType(txtFMRdg,Array As Int(InpTyp.TYPE_CLASS_NUMBER))

	imeKeyboard.Initialize("")
	soundsAlarmChannel.Initialize(2)
	ClearUI
	HidePanels
	
	If GlobalVar.blnNewFMRdg = True Then
		btnSaveUpdate.Text = Chr(0xE161) & $"  SAVE"$
		btnCancel.Text = Chr(0xE5C9) & $"  CANCEL"$
	Else
		btnSaveUpdate.Text = Chr(0xE161) & $" UPDATE"$
		btnCancel.Text = Chr(0xE5C9) & $"  CANCEL"$
		GetFMRdgRecord(GlobalVar.FMRdgDetailID)
	End If

	dLastFMRdg = DBaseFunctions.GetLastFMReading(GlobalVar.PumpHouseID)
	
	csAns.Initialize.Color(Colors.White).Bold.Append($"YES"$).PopAll
	
'	imeKeyboard.SetCustomFilter(txtFMRdg, txtFMRdg.INPUT_TYPE_NUMBERS, "0123456789")
'	imeKeyboard.SetLengthFilter(txtFMRdg, 8)

	MyFunctions.SetButton(btnSaveUpdate, 25, 25, 25, 25, 25, 25, 25, 25)
	MyFunctions.SetCancelButton(btnCancel, 25, 25, 25, 25, 25, 25, 25, 25)
	sRdgTime = ""

	cdCancel.Initialize2(GlobalVar.RedColor, 20, 0, Colors.Transparent)
	cdOK.Initialize2(GlobalVar.GreenColor, 20, 0, Colors.Transparent)
	
	CheckPermissions
	pnlKeyboard.Initialize("")
	pnlKeyboard.BringToFront
'	cKeyboard.ShowKeyboard(txtFMRdg)
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
	SoundID = soundsAlarmChannel.Load(File.DirAssets,"beep.wav")
	vibratePattern = Array As Long(500, 500, 300, 500)
	If soundsAlarmChannel.IsInitialized = False Then 	soundsAlarmChannel.Initialize(2)
	txtFMRdg.InputType = Bit.Or(txtFMRdg.InputType,TYPE_TEXT_FLAG_NO_SUGGESTIONS)
	txtFMRdg.SingleLine = True
	txtFMRdg.ForceDoneButton = True
	cKeyboard.Initialize("CKB","keyboardview_trans")
	cKeyboard.RegisterEditText(txtFMRdg,"txtFMRdg","num",True)

End Sub

Sub Activity_Pause (UserClosed As Boolean)
End Sub

#End Region

#Region Toolbar
Sub Activity_CreateMenu(Menu As ACMenu)
'	Dim Item As ACMenuItem
	Menu.Clear
End Sub

Sub ToolBar_NavigationItemClick 'Toolbar Arrow
	If pnlZeroProdMsg.Visible = True Then
		btnZeroCancel_Click
		imeKeyboard.HideKeyboard
	Else If pnlNegativeProdMsg.Visible = True Then
		btnNegativeOk_Click
		imeKeyboard.HideKeyboard
	Else If cKeyboard.IsSoftKeyboardVisible = True Then
		cKeyboard.HideKeyboard
	Else
		imeKeyboard.HideKeyboard
		Activity.Finish
	End If
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
End Sub

#End Region

#Region UI
Private Sub ClearUI
	Try
		CDtxtBox.Initialize(Colors.Transparent,0)
		cdFixedText.Initialize2(Colors.Black,0,0,0)
		
		txtFMRdg.Background = cdFixedText
		txtBackFlowCum.Background = CDtxtBox
		txtNegativeRemarks.Background = CDtxtBox
		mskTimeRead.Background = CDtxtBox
		txtFMRdgRemarks.Background = CDtxtBox
		txtZeroRemarks.Background = CDtxtBox
		txtHighRemarks.Background = CDtxtBox
		
		chkDefaultTimeRead.Checked = False
		mskTimeRead.Text = "__:__"
		txtFMRdg.Text = ""
		txtFMRdgRemarks.Text = ""

		isNegativeRdg = False
		sHighRdg = ""
	Catch
		Log(LastException)
	End Try
End Sub

Private Sub HidePanels
	pnlZeroProdMsg.Visible = False
	pnlNegativeProdMsg.Visible = False
	pnlLowProdMsg.Visible = False
	pnlHighProdMsg.Visible = False
	pnlHighBillConfirmation.Visible = False
End Sub

#End Region

#Region Database

Private Sub GetFMRdgRecord(iDetailedID As Int) 'Edit Reading
	Dim SenderFilter As Object
	
	Dim dPresentRdg As Int
	Dim sRdgTime, sRemarks As String

	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
	Try
		Starter.strCriteria = "SELECT FMDetails.RdgTime, FMDetails.PrevRdg, FMDetails.PresRdg, " & _
						  "FMDetails.PresCum, FMDetails.Remarks " & _
						  "FROM ProductionDetails AS FMDetails " & _
						  "WHERE FMDetails.DetailID = " & iDetailedID
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			RS.Position = 0
			sRdgTime = RS.GetString("RdgTime")
			dPresentRdg= RS.GetInt("PresRdg")
			sRemarks = RS.GetString("Remarks")
		Else
			snack.Initialize("", Activity,$"Unable to Fetch Flow Meter Reading Details due to "$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Return
			Log(LastException)
		End If
		
	Catch
		Log(LastException)
	End Try
	
	chkDefaultTimeRead.Enabled = False
	mskTimeRead.Text = sRdgTime
	txtFMRdg.Text = dPresentRdg
	txtFMRdgRemarks.Text = sRemarks

End Sub

#End Region

Private Sub IsValidEntries() As Boolean
	Dim bRetVal As Boolean
	LogColor(mskTimeRead.Text, Colors.Yellow)
	
	bRetVal = True
	Try
		If chkDefaultTimeRead.Checked = True Then
			If Validation.IsTime(mskTimeRead.Text) = False Then
				RequiredMsgBox($"ERROR"$, $"Invalid Reading Time!"$)
				mskTimeRead.RequestFocus
				bRetVal = False
			End If
		Else
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(mskTimeRead.Text)) <= 0 Or mskTimeRead.Text = "__:__" Then
				RequiredMsgBox($"ERROR"$, $"Reading Time cannot be blank!"$)
				mskTimeRead.RequestFocus
				bRetVal = False
			
			Else If Validation.IsTime(mskTimeRead.Text) = False Then
				RequiredMsgBox($"ERROR"$, $"Invalid Reading Time!"$)
				mskTimeRead.RequestFocus
				bRetVal = False
			End If
		End If
		
	Catch
		Log(LastException)
		Return False
	End Try
	Return bRetVal
End Sub

Private Sub SaveTransHeader() As Boolean
	Dim bRetVal As Boolean
	Dim lngDateTime As Long
	Dim sAddedAt As String
	Dim TotProd As Double
	
	bRetVal = False
	lngDateTime = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss a"
	sAddedAt= DateTime.Date(lngDateTime)

	If isNegativeRdg = True Then
		TotProd = 0
	Else
		TotProd = GlobalVar.SF.Val(txtFMRdg.Text) -  dLastFMRdg
	End If
		
	Starter.DBCon.BeginTransaction
	Try
		
		Starter.DBCon.ExecNonQuery2("INSERT INTO TranHeader VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
							   Array As Object(GlobalVar.BranchID, GlobalVar.PumpHouseID, GlobalVar.TranDate, $"0"$, TotProd, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, GlobalVar.UserID, sAddedAt, Null, Null, $"0"$, Null, Null))

		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

Private Sub UpdateTranHeader(iTranHeaderID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim GTotProd As Double

	Dim lngDateTime As Long
	Dim sModifiedAt As String
	Dim dTotCum As Double
	
	
	dTotCum = 0
	If isNegativeRdg = True Then
		dTotCum = dLastFMRdg - GlobalVar.SF.Val(txtFMRdg.Text)
	Else
		dTotCum = GlobalVar.SF.Val(txtFMRdg.Text) - dLastFMRdg
	End If
	
	LogColor($"Total CuM: "$ & dTotCum, Colors.Yellow)
	
	lngDateTime = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss a"
	sModifiedAt = DateTime.Date(lngDateTime)

	Dim rsHeader As Cursor
	
	Starter.strCriteria = "SELECT * FROM TranHeader WHERE HeaderID = " & iTranHeaderID
	rsHeader = Starter.DBCon.ExecQuery(Starter.strCriteria)

	If rsHeader.RowCount > 0 Then
		rsHeader.Position = 0
		GTotProd = rsHeader.GetDouble("TotProduction") + dTotCum
	Else
		GTotProd =  dTotCum
	End If
	rsHeader.Close
	
	LogColor($"Total Production: "$ & GTotProd, Colors.Cyan)
	
	bRetVal = False
	
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE TranHeader SET " & _
						  "TotProduction = ?, " & _
						  "ModifiedBy = ?, " & _
						  "ModifiedAt = ? " & _
						  "WHERE HeaderID = " & iTranHeaderID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(GTotProd, GlobalVar.UserID, sModifiedAt))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

Private Sub EditTranHeader(iTranHeaderID As Int) As Boolean
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
'		txtFMRdg.RequestFocus
'		imeKeyboard.ShowKeyboard(txtFMRdg)
		mskTimeRead.Enabled = False
	Else
		mskTimeRead.Enabled = True
		mskTimeRead.Text = "__:__"
		mskTimeRead.RequestFocus
		imeKeyboard.ShowKeyboard(mskTimeRead)
	End If
End Sub

Sub txtFMRdg_EnterPressed
	cKeyboard.HideKeyboard
	txtFMRdgRemarks.RequestFocus
End Sub

Sub mskTimeRead_EnterPressed
'	txtFMRdg.RequestFocus
End Sub

Sub btnSaveUpdate_Click
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

	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
	LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Cyan)
	
	If DBaseFunctions.IsFMRdgDetailHeaderIDExist(GlobalVar.TranHeaderID) = True Then	
		If DBaseFunctions.IsReadTimeOverlapse(sRdgTime, GlobalVar.TranHeaderID) = True Then
			RequiredMsgBox($"TIME OVERLAPPING"$, $"Unable to Save transaction for it will overlapped existing reading!"$)
			chkDefaultTimeRead.Checked = False
			mskTimeRead.RequestFocus
			Return
		End If
	End If
	
	If GlobalVar.SF.Val(txtFMRdg.Text) < dLastFMRdg Then
		'Negative Reading
		isNegativeRdg = True
		ShowNegativeWarning
		Return
	Else If GlobalVar.SF.Val(txtFMRdg.Text) = dLastFMRdg Then
		'Zero Reading
		isNegativeRdg = False
		ShowZeroWarning
		Return
	Else If (GlobalVar.SF.Val(txtFMRdg.Text) - dLastFMRdg)  >= 200 Then
		'High Reading
		isNegativeRdg = False
		sHighRdg = txtFMRdg.Text
		ShowHighWarning
'		ConfirmSaveRdg
	Else If (GlobalVar.SF.Val(txtFMRdg.Text) - dLastFMRdg)  <= 50 Then
		'Low Reading
		isNegativeRdg = False
		ConfirmSaveRdg
	Else
		isNegativeRdg = False
		ConfirmSaveRdg
	End If
	
'	SaveUpdateFMReading
End Sub


Sub btnCancel_Click
	Activity.Finish
End Sub

Private Sub InsertNewFlowMeterReading() As Boolean
	Dim bRetVal As Boolean
	Dim sRemarks, sLocation As String
	Dim sDateAdded As String
	Dim lDate As Long
	Dim iBackFlowCum As Int
	Dim dTotCum As Double
	
	iBackFlowCum = 0
	dTotCum = 0
	dTotCum = GlobalVar.SF.Val(txtFMRdg.Text) - dLastFMRdg

	sRemarks = txtFMRdgRemarks.Text
	Starter.FLP.Connect

	Log($"FLP is COnnected? "$ & Starter.FLP.IsConnected)
	
	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)

	sLocation = GlobalVar.Lat & "," & GlobalVar.Lon
	LogColor($"Location is "$ & sLocation, Colors.Yellow)
	
	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	sDateAdded = DateTime.Date(lDate)
	
	
	Starter.DBCon.BeginTransaction
	Try
		Starter.DBCon.ExecNonQuery2("INSERT INTO ProductionDetails VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
							  Array As Object(GlobalVar.TranHeaderID, sRdgTime, dLastFMRdg, txtFMRdg.Text, dTotCum, iBackFlowCum, sRemarks, $"0"$, $""$, $""$, GlobalVar.UserID, sDateAdded, sLocation, Null, Null, $""$))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

Private Sub InsertNewNegativeRdg() As Boolean
	Dim bRetVal As Boolean
	Dim iNewReading, iLastReading, iLastCuM As Int
	Dim sRemarks, sLocation As String
	Dim lDate As Long
	Dim sDateAdded As String
	Dim dTotCum As Double
	
	bRetVal = False
	
	'Previous Reading ////////////////////////////////////////////////////////////////////
	Dim iPrevDetailedID As Int
	
	iPrevDetailedID = DBaseFunctions.GetLastFMReadingTransID(dLastFMRdg, dBackFlow)
	
	If iPrevDetailedID = 0 Then 'Request to Net
		'Request Last Transaction of Pump ID
		Return False
	Else
		Starter.strCriteria = "SELECT PresRdg FROM ProductionDetails WHERE DetailID = " & iPrevDetailedID
		LogColor(Starter.strCriteria, Colors.Magenta)
		
		iLastReading = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
		
		If iLastReading = 0 Then
			iLastReading = iLastReading
		Else
			iLastReading = iLastReading - GlobalVar.SF.Val(txtBackFlowCum.Text)
		End If
		
		Starter.strCriteria = "SELECT PresCum FROM ProductionDetails WHERE DetailID = " & iPrevDetailedID
		LogColor(Starter.strCriteria, Colors.Cyan)
		
		iLastCuM = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)

		If iLastCuM = 0 Then
			iLastCuM = iLastCuM
		Else
			iLastCuM = iLastCuM - dBackFlow
		End If
	End If
	'////////////////////////////////////////////////////////////////////////////////////
	
	'Present Reading ////////////////////////////////////////////////////////////////////////////////////////
	dTotCum = 0

	iNewReading = GlobalVar.SF.Val(txtFMRdg.Text)
	dTotCum = iNewReading - iLastReading
	
	sRemarks = txtFMRdgRemarks.Text
	Starter.FLP.Connect

	Log($"FLP is COnnected? "$ & Starter.FLP.IsConnected)
	
	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)

	sLocation = GlobalVar.Lat & "," & GlobalVar.Lon
	LogColor($"Location is "$ & sLocation, Colors.Yellow)
	
	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	sDateAdded = DateTime.Date(lDate)
		
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE ProductionDetails SET " & _
						  "PresRdg = ?, " & _
						  "PresCum = ?, " & _
						  "BackFlowCum = ?, " & _
						  "ModifiedBy = ?, " & _
						  "ModifiedAt = ?, " & _
						  "ModifiedOn = ? " & _
						  "WHERE DetailID = " & iPrevDetailedID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(iLastReading, iLastCuM, dBackFlow, GlobalVar.UserID, sDateAdded, sLocation))

		Starter.DBCon.ExecNonQuery2("INSERT INTO ProductionDetails VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
							  Array As Object(GlobalVar.TranHeaderID, sRdgTime, dLastFMRdg, txtFMRdg.Text, dTotCum, dBackFlow, sRemarks, $"0"$, $""$, $""$, GlobalVar.UserID, sDateAdded, sLocation, Null, Null, $""$))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

Private Sub InsertNegativeRdg(iTranHeaderID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim iNewReading, iLastReading, iLastCuM As Int
	Dim sRemarks, sLocation As String
	Dim lDate As Long
	Dim sDateAdded As String
	Dim dTotCum As Double
	Dim rsLast As Cursor
	
	bRetVal = False
	
	'Previous Reading ////////////////////////////////////////////////////////////////////
	Dim iPrevDetailedID As Int
	
	Starter.strCriteria = "SELECT MAX(DetailID) FROM ProductionDetails " & _
					  "WHERE HeaderID = " & iTranHeaderID
					  
	LogColor(Starter.strCriteria, Colors.Blue)
		
	iPrevDetailedID = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	
	If iPrevDetailedID = 0 Then 'Request to Net
		'Request Last Transaction of Pump ID
		Return False
	Else

		Starter.strCriteria = "SELECT * FROM ProductionDetails WHERE DetailID = " & iPrevDetailedID
		LogColor(Starter.strCriteria, Colors.Magenta)
		
		rsLast = Starter.DBCon.ExecQuery(Starter.strCriteria)
		If rsLast.RowCount > 0 Then
			rsLast.Position = 0
			iLastReading = rsLast.GetInt("PresRdg")
			iLastCuM = rsLast.GetInt("PresCum")
		Else
			iLastReading = 0
			iLastCuM = 0
		End If
	End If
	
	iLastReading = iLastReading - GlobalVar.SF.Val(txtBackFlowCum.Text)
	iLastCuM = iLastCuM - GlobalVar.SF.Val(txtBackFlowCum.Text)
	dBackFlow = GlobalVar.SF.Val(txtBackFlowCum.Text)
	
	'////////////////////////////////////////////////////////////////////////////////////
	
	'Present Reading ////////////////////////////////////////////////////////////////////////////////////////
	dTotCum = 0

	iNewReading = GlobalVar.SF.Val(txtFMRdg.Text)
	dTotCum = iNewReading - iLastReading
	
	sRemarks = txtFMRdgRemarks.Text
	Starter.FLP.Connect

	Log($"FLP is COnnected? "$ & Starter.FLP.IsConnected)
	
	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)

	sLocation = GlobalVar.Lat & "," & GlobalVar.Lon
	LogColor($"Location is "$ & sLocation, Colors.Yellow)
	
	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	sDateAdded = DateTime.Date(lDate)
		
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE ProductionDetails SET " & _
						  "PresRdg = ?, " & _
						  "PresCum = ?, " & _
						  "BackFlowCum = ?, " & _
						  "ModifiedBy = ?, " & _
						  "ModifiedAt = ?, " & _
						  "ModifiedOn = ? " & _
						  "WHERE DetailID = " & iPrevDetailedID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(iLastReading, iLastCuM, dBackFlow, GlobalVar.UserID, sDateAdded, sLocation))

		Starter.DBCon.ExecNonQuery2("INSERT INTO ProductionDetails VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
							  Array As Object(GlobalVar.TranHeaderID, sRdgTime, iLastReading, txtFMRdg.Text, dTotCum, $"0"$, sRemarks, $"0"$, $""$, $""$, GlobalVar.UserID, sDateAdded, sLocation, Null, Null, $""$))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

Private Sub UpdateLastFMReadings(iPumpID As Int)
	
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE tblPumpStation " & _
						  "SET LastRdg = ? " & _
						  "WHERE StationID = " & iPumpID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(txtFMRdg.Text))
		Starter.DBCon.TransactionSuccessful
	Catch
		Log(LastException)
	End Try
	Starter.DBCon.EndTransaction
End Sub

Private Sub SaveUpdateFMReading
	Select Case GlobalVar.blnNewFMRdg
	
		Case True
			GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
			LogColor(GlobalVar.TranHeaderID, Colors.Magenta)
			
			If GlobalVar.TranHeaderID = 0 Then
				If Not(SaveTransHeader) Then Return
				GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
				LogColor(GlobalVar.TranHeaderID, Colors.Cyan)				
				If Not(InsertNewFlowMeterReading) Then
					vibration.vibrateOnce(1000)
					snack.Initialize("", Activity, $"Unable to Add New Flow Meter Reading due to "$ & LastException.Message, snack.DURATION_LONG)
					MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
					MyFunctions.SetSnackBarTextColor(snack, Colors.White)
					snack.Show
					Return
				End If
			Else
				If Not(InsertNewFlowMeterReading) Then
					vibration.vibrateOnce(1000)
					snack.Initialize("", Activity, $"Unable to Add New Flow Meter Reading due to "$ & LastException.Message, snack.DURATION_LONG)
					MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
					MyFunctions.SetSnackBarTextColor(snack, Colors.White)
					snack.Show
					Return
				End If
				If Not(UpdateTranHeader(GlobalVar.TranHeaderID)) Then
					Return
				End If
			End If
			UpdateLastFMReadings(GlobalVar.PumpHouseID)
			GlobalVar.FMRdgDetailID = GetLatestRdgID(GlobalVar.TranHeaderID, txtFMRdg.Text)
			If GlobalVar.FMRdgDetailID = 0 Then
			Else
				sUploadReading = SavetoJSON(GlobalVar.FMRdgDetailID)
			End If
			If GlobalVar.SF.Len(sUploadReading) = 0 Then
			Else
				UploadReadingData(sUploadReading)
			End If
			ShowSaveSuccess
		Case False			
	End Select

End Sub

#Region Upload
Private Sub GetLatestRdgID(iHeaderID As Int, sPresRdg As String) As Int
	Dim iRetVal As Int
	
	Try
		Starter.strCriteria = "SELECT MAX(ProductionDetails.DetailID) FROM ProductionDetails " & _
						  "INNER JOIN TranHeader ON ProductionDetails.HeaderID = TranHeader.HeaderID " & _
						  "WHERE ProductionDetails.HeaderID = " & iHeaderID & " " & _
						  "AND PresRdg = '" & sPresRdg & "' " & _
						  "AND TranHeader.PumpID = " & GlobalVar.PumpHouseID
						  
		LogColor(Starter.strCriteria, Colors.Blue)
		
		iRetVal = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch Pump Last Reading due to "$ & LastException.Message, False)
		Log(LastException)
		iRetVal = 0
	End Try
	Return iRetVal
End Sub

Private Sub SavetoJSON(iRdgID As Int) As String
	Dim sJSON As String
	Dim JSONGen As JSONGenerator
	Dim JSONList As List
	Dim JSONMap As Map
	Dim RS As Cursor

	
	Try
		
		Starter.strCriteria = "SELECT * FROM ProductionDetails " & _
						  "WHERE DetailID = " & iRdgID
		LogColor(Starter.strCriteria, Colors.Cyan)
		
		RS = Starter.DBCon.ExecQuery(Starter.strCriteria)
		
		If RS.RowCount > 0 Then
			JSONList.Initialize
			JSONMap.Initialize
			RS.Position = 0

			JSONMap.Put("pump_id", GlobalVar.PumpHouseID)
			JSONMap.Put("transaction_date", GlobalVar.TranDate)
			JSONMap.Put("transaction_time", mskTimeRead.Text)
			JSONMap.Put("reading_previous", RS.GetInt("PrevRdg"))
			JSONMap.Put("reading_present", RS.GetInt("PresRdg"))
			JSONMap.Put("production", RS.GetInt("PresCum"))
			JSONMap.Put("remarks", RS.GetString("Remarks"))
			JSONMap.Put("pump_operator", RS.GetInt("AddedBy"))
			JSONMap.Put("coordinates", RS.GetString("AddedOn"))
			JSONGen.Initialize(JSONMap)

			Log (JSONGen.ToString)
			sJSON = JSONGen.ToString
			Log (sJSON)
			
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
	Return sJSON
End Sub

Sub UploadReadingData(sData As String)
	Dim retVal As String
	Dim jParser As JSONParser
	
	Dim j As HttpJob
	j.Initialize("", Me)
	
	j.PostString(GlobalVar.BaseURL & "logs/production", sData)
	j.GetRequest.SetHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.92 Safari/537.36")
	j.GetRequest.SetContentType("plain/text")
	Log(sData)
	
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		retVal = j.GetString
		jParser.Initialize(retVal)
		Log(retVal)
		ProgressDialogHide
		j.Release
	Else
		ProgressDialogHide
		Log(j.ErrorMessage)
'				RetVal=Job.
		jParser.Initialize(retVal)
		Log(retVal)
				
		ToastMessageShow("Unable to Upload Reading Data due to " & j.ErrorMessage,True)
		j.Release
		Log(j.ErrorMessage)
		Return
	End If
End Sub

#End Region

#Region Zero Production
Sub pnlZeroProdMsg_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Private Sub ShowZeroWarning
	HidePanels
	pnlZeroProdMsg.Visible = True
	btnZeroCancel.Background = cdCancel
	btnZeroOk.Background = cdOK
	
	vibration.vibratePattern(vibratePattern, 0)
	soundsAlarmChannel.Play(SoundID,1,1,1,0,1)
	
	If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtFMRdgRemarks.Text)) <= 0 Then
		lblZeroMsg.Text = $"It seems that your Pump Flow Meter didn't move from your Previous Reading"$ & CRLF & CRLF & $"Reading Remarks is required this time."$
		txtZeroRemarks.Text = ""
	Else
		lblZeroMsg.Text = $"It seems that your Pump Flow Meter didn't move from your Previous Reading"$ & CRLF & CRLF & $"Do you wish to save this record anyway?"$
		txtZeroRemarks.Text = txtFMRdgRemarks.Text
	End If
End Sub

Sub btnZeroOk_Click
	vibration.vibrateCancel
	soundsAlarmChannel.Stop(SoundID)
	
	If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtZeroRemarks.Text)) <= 0 Then
		RequiredMsgBox($"REMARKS REQUIRED"$, $"Remarks is required for this reading!"$)
		txtZeroRemarks.RequestFocus
		imeKeyboard.ShowKeyboard(txtZeroRemarks)
		Return
	Else
		txtFMRdgRemarks.Text = txtZeroRemarks.Text
	End If
	ConfirmSaveRdg
End Sub

Sub btnZeroCancel_Click
	vibration.vibrateCancel
	soundsAlarmChannel.Stop(SoundID)
	HidePanels
	txtFMRdg.RequestFocus
End Sub

#End Region

#Region Negative Warning
Sub pnlNegativeProdMsg_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Private Sub ShowNegativeWarning
	HidePanels
	
	pnlNegativeProdMsg.Visible = True

	chkBackFlow.Checked = False
	txtBackFlowCum.Text = ""
	txtBackFlowCum.Hint = (GlobalVar.SF.Val(txtFMRdg.Text) - dLastFMRdg) & " CuM Back flow"

	txtNegativeRemarks.Text = ""
			
	btnNegativeCancel.Background = cdCancel
	btnNegativeOk.Background = cdOK
	
	vibration.vibratePattern(vibratePattern, 0)
	soundsAlarmChannel.Play(SoundID,1,1,1,0,1)
End Sub

Sub chkBackFlow_CheckedChange(Checked As Boolean)
	If Checked = True Then
		txtBackFlowCum.Enabled = True
		txtBackFlowCum.RequestFocus
	Else
		txtBackFlowCum.Enabled = False
		txtBackFlowCum.Text = ""
	End If
End Sub

Sub btnNegativeOk_Click
	If GlobalVar.blnNewFMRdg = True Then
		If GlobalVar.SF.Len(txtBackFlowCum.Text) <=0 Then
			RequiredMsgBox($"E R R O R"$, $"Unable to save Reading due to Back flow in CuM is blank!"$)
			txtBackFlowCum.RequestFocus
			dBackFlow = 0
			Return
		End If
		If GlobalVar.SF.Len(txtNegativeRemarks.Text) <=0 Then
			RequiredMsgBox($"E R R O R"$, $"Unable to save Reading due to Reading Remarks is required!"$)
			txtNegativeRemarks.RequestFocus
			Return
		End If
		ConfirmSaveNegativeRdg
	Else 'Edit Flow Meter Reading Negative
	End If
End Sub

Sub btnNegativeCancel_Click
	vibration.vibrateCancel
	soundsAlarmChannel.Stop(SoundID)
	HidePanels
End Sub
#End Region


#Region Low Production
Sub pnlLowProdMsg_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Private Sub ShowLowWarning
	HidePanels
	pnlLowProdMsg.Visible = True
	btnLowCancel.Background = cdCancel
	btnLowOk.Background = cdOK
	
	vibration.vibratePattern(vibratePattern, 0)
	soundsAlarmChannel.Play(SoundID,1,1,1,0,1)
End Sub

Sub btnLowOk_Click
	pnlLowProdMsg.Visible = False

	vibration.vibrateCancel
	soundsAlarmChannel.Stop(SoundID)
	
	If GlobalVar.SF.Len(txtFMRdgRemarks.Text) <= 0 Then
		RequiredMsgBox($"REMARKS REQUIRED"$, $"Remarks is required for this reading!"$)
		txtFMRdgRemarks.RequestFocus
		imeKeyboard.ShowKeyboard(txtFMRdgRemarks)
		Return
	Else
		SaveUpdateFMReading
	End If
	
End Sub

Sub btnLowCancel_Click
	
End Sub
#End Region

#Region High Production
Sub pnlHighProdMsg_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Private Sub ShowHighWarning
	HidePanels
	pnlHighProdMsg.Visible = True
	btnHighCancel.Background = cdCancel
	btnHighOk.Background = cdOK
	
	vibration.vibratePattern(vibratePattern, 0)
	soundsAlarmChannel.Play(SoundID,1,1,1,0,1)
	
	If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtFMRdgRemarks.Text)) <= 0 Then
		txtHighRemarks.Text = ""
	Else
		txtHighRemarks.Text = txtFMRdgRemarks.Text
	End If
End Sub

Sub btnHighOk_Click
	vibration.vibrateCancel
	soundsAlarmChannel.Stop(SoundID)
	
	If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtHighRemarks.Text)) <= 0 Then
		RequiredMsgBox($"REMARKS REQUIRED"$, $"Remarks is required for this reading!"$)
		txtHighRemarks.RequestFocus
		imeKeyboard.ShowKeyboard(txtHighRemarks)
		Return
	Else
		txtFMRdgRemarks.Text = txtHighRemarks.Text
	End If
	ShowHighConfirmationWarning
End Sub

Sub btnHighCancel_Click
	vibration.vibrateCancel
	soundsAlarmChannel.Stop(SoundID)
	HidePanels
	txtFMRdg.RequestFocus
End Sub
#End Region

#Region High Confirmation
Sub pnlHighBillConfirmation_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Private Sub ShowHighConfirmationWarning
	HidePanels
	pnlHighBillConfirmation.Visible = True
	btnHBConfirmCancel.Background = cdCancel
	btnHBConfirmSave.Background = cdOK
	
	vibration.vibratePattern(vibratePattern, 0)
	soundsAlarmChannel.Play(SoundID,1,1,1,0,1)
	txtPresRdgConfirm.Background = cdFixedText
	txtPresRdgConfirm.Text = ""
	btnHBConfirmSave.Enabled = False
End Sub

Sub txtPresRdgConfirm_EnterPressed
	
End Sub

Sub txtPresRdgConfirm_TextChanged (Old As String, New As String)
	If txtFMRdg.Text = New Or sHighRdg = New Then
		btnHBConfirmSave.Enabled = True
	Else
		btnHBConfirmSave.Enabled = False
	End If
End Sub

Sub btnHBConfirmSave_Click
	ConfirmSaveRdg
End Sub

Sub btnHBConfirmCancel_Click
	vibration.vibrateCancel
	soundsAlarmChannel.Stop(SoundID)
	HidePanels
	txtFMRdg.RequestFocus
End Sub
#End Region

#Region Transaction Header
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

Private Sub ConfirmSaveNegativeRdg
	Dim Alert As AX_CustomAlertDialog

	Alert.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(Alert.STYLE_DIALOGUE) _
			.SetCancelable(False) _
			.SetTitle("SAVE NEGATIVE READING") _
			.SetTitleColor(GlobalVar.BlueColor) _
			.SetTitleTypeface(FontBold) _
			.SetMessage($"Continuing this may ALTER your previous reading due to back flow"$ & CRLF & $"Save reading anyway?"$) _
			.SetPositiveText("Confirm") _
			.SetPositiveColor(GlobalVar.PosColor) _
			.SetPositiveTypeface(FontBold) _
			.SetNegativeText("Cancel") _
			.SetNegativeColor(GlobalVar.NegColor) _
			.SetNegativeTypeface(Font) _
			.SetMessageTypeface(Font) _
			.SetOnPositiveClicked("SaveNegative") _	'listeners
			.SetOnNegativeClicked("SaveNegative")	'listeners
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Listeners
Private Sub SaveNegative_OnNegativeClicked (View As View, Dialog As Object)
'	ToastMessageShow("Negative Button Clicked!",False)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
	HidePanels
End Sub

Private Sub SaveNegative_OnPositiveClicked (View As View, Dialog As Object)
'	ToastMessageShow("Positive Button Clicked!",False)

	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)

	vibration.vibrateCancel
	soundsAlarmChannel.Stop(SoundID)
	pnlNegativeProdMsg.Visible = False
	
	dBackFlow = GlobalVar.SF.Val(txtBackFlowCum.Text)
	dPreviousRdg = dLastFMRdg - dBackFlow
	
	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
				
	If GlobalVar.TranHeaderID = 0 Then 'New FM Reading for the day
		If Not(SaveTransHeader) Then
			ToastMessageShow($"Unable to save negative reading header due to "$ & LastException, True)
			Return
		End If
		
		If Not(InsertNewNegativeRdg) Then
			ToastMessageShow($"Unable to save negative reading details due to "$ & LastException, True)
			dBackFlow = 0
			Return
		End If
							
	Else 'New FM Reading for the given Transaction Header ID and Date
		
		If Not(UpdateTranHeader(GlobalVar.TranHeaderID)) Then
			Return
		End If
		
		'Update Production Details
		If Not(InsertNegativeRdg(GlobalVar.TranHeaderID)) Then
			Return
		End If
		
	End If
	UpdateLastFMReadings(GlobalVar.PumpHouseID)
	ShowSaveSuccess

End Sub

'Normal Reading
Private Sub ConfirmSaveRdg
	Dim Alert As AX_CustomAlertDialog

	Alert.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(Alert.STYLE_DIALOGUE) _
			.SetCancelable(False) _
			.SetTitle("SAVE NEW READING") _
			.SetTitleColor(GlobalVar.BlueColor) _
			.SetTitleTypeface(FontBold) _
			.SetMessage($"Save New Pump Flow Meter Reading?"$) _
			.SetPositiveText("Confirm") _
			.SetPositiveColor(GlobalVar.PosColor) _
			.SetPositiveTypeface(FontBold) _
			.SetNegativeText("Cancel") _
			.SetNegativeColor(GlobalVar.NegColor) _
			.SetNegativeTypeface(Font) _
			.SetMessageTypeface(Font) _
			.SetOnPositiveClicked("NormalReading") _	'listeners
			.SetOnNegativeClicked("NormalReading")	'listeners
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Listeners
Private Sub NormalReading_OnNegativeClicked (View As View, Dialog As Object)
'	ToastMessageShow("Negative Button Clicked!",False)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub NormalReading_OnPositiveClicked (View As View, Dialog As Object)
'	ToastMessageShow("Positive Button Clicked!",False)

	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
	SaveUpdateFMReading
End Sub


Private Sub FontSizeBinder_OnBindView (View As View, ViewType As Int)
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

'Material Dialog Message Box
Private Sub DispInfoMsg(sTitle As String, sMsg As String)
	MatDialogBuilder.Initialize("DispInformationMsg")
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
	MatDialogBuilder.Title(sTitle)
	MatDialogBuilder.Content(sMsg)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(False)
	MatDialogBuilder.Show
End Sub

Private Sub DispInformationMsg_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			Activity.Finish
		Case mDialog.ACTION_NEGATIVE
	End Select
End Sub

Private Sub ShowSaveSuccess()
	Dim csTitle As CSBuilder
	Dim csContent As CSBuilder

	HidePanels
	If GlobalVar.blnNewFMRdg = True Then
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"New Pump Flow Meter Reading has been successfully saved!"$).PopAll
	Else
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"Pump Flow Meter Reading has been successfully updated!"$).PopAll
	End If
	MatDialogBuilder.Initialize("AddPumpTimeOnRecords")
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content(csContent)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(False)
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
	MatDialogBuilder.Show
End Sub

Private Sub AddPumpTimeOnRecords_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			imeKeyboard.HideKeyboard
			Activity.Finish
	End Select
End Sub


#End Region


Sub mskTimeRead_FocusChanged(HasFocus As Boolean)
	If HasFocus = True Then mskTimeRead.SelectAll
End Sub


Sub txtFMRdg_FocusChanged (HasFocus As Boolean)
	If HasFocus = True Then
'		pnlKeyboard.Visible = True
'		pnlKeyboard.BringToFront
		cKeyboard.ShowKeyboard(txtFMRdg)
	Else
		pnlKeyboard.Visible = False
		cKeyboard.HideKeyboard
	End If
End Sub