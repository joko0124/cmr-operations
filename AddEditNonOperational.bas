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
End Sub

Sub Globals
	Dim ActionBarButton As ACActionBar
	Private ToolBar As ACToolBarDark
	Private xmlIcon As XmlLayoutBuilder
	Private MatDialogBuilder As MaterialDialogBuilder
	Private CD, CDtxtBox, cdFixedText As ColorDrawable
	Private vibration As B4Avibrate
	Private vibratePattern() As Long
	
	Private Alert As AX_CustomAlertDialog

	Private snack As DSSnackbar
	Private csAns As CSBuilder

	Private btnSaveUpdate As ACButton
	Private mskTimeStart As MaskedEditText
	Private mskTimeFinished As MaskedEditText
	Private txtReason As EditText
	Private txtRemarks As EditText
	
	Private imeKeyboard As IME
	
	Private sTimeStart, sTimeFinished As String
	Private iHrs1, iHrs2, iMins1, iMins2 As Int
	Private iHrsStart, iHrsFinished As String
	Private sMin1, sMin2 As String
	Private sAmPm1, sAmPm2 As String
	Private TotNonOpHours As Float
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("AddEditPumpNonOperational")
	
	Dim jo As JavaObject
	Dim xl As XmlLayoutBuilder

	If GlobalVar.blnNewNonOp = True Then
		GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"ADD NEW PUMP NON-OPERATIONAL RECORD"$).PopAll
		GlobalVar.CSSubTitle.Initialize.Size(12).Append($"Transaction Date: "$ & GlobalVar.TranDate).PopAll
		ClearUI
		btnSaveUpdate.Text = Chr(0xE161) & $" SAVE"$
	Else
		GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"EDIT PUMP NON-OPERATIONAL RECORD"$).PopAll
		GlobalVar.CSSubTitle.Initialize.Size(12).Append($"Transaction Date: "$ & GlobalVar.TranDate).PopAll
		ClearUI
		btnSaveUpdate.Text = Chr(0xE161) & $" UPDATE"$
		GetNonOpRecord(GlobalVar.NonOpDetailID)
	End If

	jo = ToolBar
	jo.RunMethod("setPopupTheme", Array(xl.GetResourceId("style", "ToolbarMenu")))
	jo.RunMethod("setContentInsetStartWithNavigation", Array(1dip))
	jo.RunMethod("setTitleMarginStart", Array(0dip))

	ActionBarButton.Initialize
	ActionBarButton.ShowUpIndicator = True

	ToolBar.InitMenuListener
	ToolBar.Title = GlobalVar.CSTitle
	ToolBar.SubTitle = GlobalVar.CSSubTitle

	InpTyp.Initialize
	InpTyp.SetInputType(txtReason,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_CORRECT, InpTyp.TYPE_TEXT_FLAG_CAP_SENTENCES))
	InpTyp.SetInputType(txtRemarks,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_CORRECT, InpTyp.TYPE_TEXT_FLAG_CAP_SENTENCES))

	imeKeyboard.Initialize("")

	If FirstTime Then
	End If
	
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
	CheckPermissions
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
	Activity.Finish
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
End Sub

#End Region

Private Sub GetNonOpRecord(iDetailedID As Int)
	Dim iPowerSource As Int
	Dim SenderFilter As Object
	Dim sTimeOn, sTimeOff As String
	Dim lTimeOn As Long
	Dim Matcher1 As Matcher
	
	Try
	
		Starter.strCriteria = "SELECT Header.TranDate, " & _
						      "Pump.PumpHouseCode, Details.PumpOnTime, Details.PumpOffTime, Details.TotOpHrs, " & _
							  "Details.PowerSourceID, Details.DrainTime, Details.DrainCum, Details.TimeOnRemarks " & _
							  "FROM OnOffDetails AS Details " & _
							  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
							  "INNER JOIN tblPumpStation AS Pump ON Pump.StationID = Header.PumpID " & _
							  "WHERE Details.DetailID = " & iDetailedID
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			RS.Position = 0
			sTimeOn = RS.GetString("PumpOnTime")
			sTimeOff = RS.GetString("PumpOffTime")
			
			DateTime.TimeFormat = "HH:mm"
			Matcher1 = Regex.Matcher("(\d\d):(\d\d) (\S\S)", sTimeOn)
			If Matcher1.Find Then
			End If
		End If
	Catch
		Log(LastException)
	End Try
End Sub

Private Sub ClearUI
	mskTimeStart.Text = "__:__"
	mskTimeFinished.Text = "__:__"
	txtReason.Text = ""
	txtRemarks.Text = ""
	
	cdFixedText.Initialize2(Colors.Transparent, 0, 0, Colors.Transparent)
	mskTimeStart.Background = cdFixedText
	mskTimeFinished.Background = cdFixedText
	txtReason.Background = cdFixedText
	txtRemarks.Background = cdFixedText
	MyFunctions.SetButton(btnSaveUpdate, 25, 25, 25, 25, 25, 25, 25, 25)
End Sub

Private Sub IsValidEntries() As Boolean
	Dim sStart, sEnd As String
	Dim lStart, lEnd As Long
	
	sStart = mskTimeStart.Text & ":00"
	sEnd = mskTimeFinished.Text & ":00"
	
	DateTime.TimeFormat = "HH:mm:ss"
	lStart = DateTime.TimeParse(sStart)
	lEnd = DateTime.TimeParse(sEnd)
	Log(lStart & " " & lEnd)
	
	LogColor(mskTimeFinished.Text, Colors.Yellow)
	Try
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(mskTimeStart.Text)) <= 0 Or mskTimeStart.Text = "__:__" Then
			RequiredMsgBox($"ERROR"$, $"Time Start cannot be blank!"$)
			mskTimeStart.SelectAll
			mskTimeStart.RequestFocus
			Return False
		End If
		
		If Validation.IsTime(mskTimeStart.Text) = False Then
			RequiredMsgBox($"ERROR"$, $"Invalid Time Start!"$)
			mskTimeStart.SelectAll
			mskTimeStart.RequestFocus
			Return False
		End If
		
		If DBaseFunctions.IsFuturisticTime(GlobalVar.TranDate, mskTimeStart.Text) = True Then
			RequiredMsgBox($"ERROR"$, $"Time Start has not yet come!"$)
			mskTimeStart.SelectAll
			mskTimeStart.RequestFocus
			Return False
		End If

		If GlobalVar.SF.Len(GlobalVar.SF.Trim(mskTimeFinished.Text)) <= 0 Or mskTimeFinished.Text = "__:__" Then
			RequiredMsgBox($"ERROR"$, $"Time Finshed cannot be blank!"$)
			mskTimeFinished.SelectAll
			mskTimeFinished.RequestFocus
			Return False
		End If	
		
		If Validation.IsTime(mskTimeFinished.Text) = False Then
			RequiredMsgBox($"ERROR"$, $"Invalid Time Finished!"$)
			mskTimeFinished.SelectAll
			mskTimeFinished.RequestFocus
			Return False
		End If
		
		If DBaseFunctions.IsFuturisticTime(GlobalVar.TranDate, mskTimeFinished.Text) = True Then
			RequiredMsgBox($"ERROR"$, $"Time Finished has not yet come!"$)
			mskTimeFinished.SelectAll
			mskTimeFinished.RequestFocus
			Return False
		End If
		
		If lStart > lEnd Then
			RequiredMsgBox($"ERROR"$, $"Time Finished is earlier than Time Started!"$)
			mskTimeFinished.SelectAll
			mskTimeFinished.RequestFocus
			Return False
		End If

		If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtReason.Text)) <= 0 Then
			RequiredMsgBox($"ERROR"$, $"Non Operational Reason cannot be blank!"$)
			txtReason.RequestFocus
			Return False
		End If

	Catch
		Log(LastException)
		Return False
	End Try
	Return True
End Sub

Private Sub SaveTransHeader() As Boolean
	Dim bRetVal As Boolean
	Dim lngDateTime As Long
	Dim sAddedAt As String
	Dim fTotNonOpHrs As Float
	
	fTotNonOpHrs = ComputeTotHrs(sTimeStart, sTimeFinished)
	
	lngDateTime = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss a"
	sAddedAt= DateTime.Date(lngDateTime)

	bRetVal = False
	Starter.DBCon.BeginTransaction
	Try
		
		Starter.DBCon.ExecNonQuery2("INSERT INTO TranHeader VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
							   Array As Object(GlobalVar.BranchID, GlobalVar.PumpHouseID, GlobalVar.TranDate, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, fTotNonOpHrs, $"0"$, GlobalVar.UserID, sAddedAt, Null, Null, $"0"$, $""$, $""$))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

Private Sub SaveNewNonOpRec() As Boolean
	Dim bRetVal As Boolean
	
	Dim sDateTimeAdded As String
	Dim lDate As Long
	Dim sReason, sRemarks, sLocation As String
	
	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	sDateTimeAdded = DateTime.Date(lDate)
	
	TotNonOpHours = ComputeTotHrs(sTimeStart, sTimeFinished)

	sReason = txtReason.Text
	sRemarks = txtRemarks.Text
	
	Starter.FLP.Connect

	Log($"FLP is COnnected? "$ & Starter.FLP.IsConnected)
	
	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)

	sLocation = GlobalVar.Lat & "," & GlobalVar.Lon
	LogColor($"Location is "$ & sLocation, Colors.Yellow)

	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
	LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Yellow)

	Starter.DBCon.BeginTransaction
	Try
		Starter.DBCon.ExecNonQuery2("INSERT INTO NonOpDetails VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
							  Array As Object(GlobalVar.TranHeaderID, sTimeStart, sTimeFinished, TotNonOpHours, sReason, sRemarks, GlobalVar.UserID, sDateTimeAdded, sLocation, Null, Null, $""$, $"0"$, $""$, $""$))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

Private Sub UpdateNonOPRecord(iTranHeaderID As Int, iDetailID As Int) As Boolean
	Dim bRetVal As Boolean
	
	Dim sDateTimeModified As String
	Dim lDate As Long
	Dim sReason, sRemarks, sLocation As String
	
	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	sDateTimeModified = DateTime.Date(lDate)
	
	TotNonOpHours = ComputeTotHrs(sTimeStart, sTimeFinished)

	sReason = txtReason.Text
	sRemarks = txtRemarks.Text
	
	Starter.FLP.Connect

	Log($"FLP is COnnected? "$ & Starter.FLP.IsConnected)
	
	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)

	sLocation = GlobalVar.Lat & "," & GlobalVar.Lon
	LogColor($"Location is "$ & sLocation, Colors.Yellow)

	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
	LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Yellow)

	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE NonOpDetails SET " & _
						  "OffTime = ?, " & _
						  "OnTime = ?, " & _
						  "TotNonOpHrs = ?, " & _
						  "NonOpReason = ?, " & _
						  "Remarks = ?, " & _
						  "ModifiedBy = ?, " & _
						  "ModifiedAt = ?, " & _
						  "ModifiedOn = ? " & _
						  "WHERE HeaderID = " & iTranHeaderID & " " & _
						  "AND DetailID = " & iDetailID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(sTimeStart, sTimeFinished, TotNonOpHours, sReason, sRemarks, GlobalVar.UserID, sDateTimeModified, sLocation))
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
	Dim GTotNonOpHrs As Float

	Dim lngDateTime As Long
	Dim sModifiedAt As String
	
	lngDateTime = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	sModifiedAt = DateTime.Date(lngDateTime)

	Dim rsHeader As Cursor
	
	Starter.strCriteria = "SELECT * FROM TranHeader WHERE HeaderID = " & iTranHeaderID
	rsHeader = Starter.DBCon.ExecQuery(Starter.strCriteria)
	If rsHeader.RowCount > 0 Then
		rsHeader.Position = 0
		GTotNonOpHrs = rsHeader.GetDouble("TotNonOpHours") + TotNonOpHours
	Else
		GTotNonOpHrs = TotNonOpHours
	End If
	rsHeader.Close
	LogColor($"Total Op Hrs: "$ & GTotNonOpHrs, Colors.Magenta)
	
	bRetVal = False
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE TranHeader SET " & _
						  "TotNonOpHours = ?, " & _
						  "ModifiedBy = ?, " & _
						  "ModifiedAt = ? " & _
						  "WHERE HeaderID = " & iTranHeaderID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(GTotNonOpHrs, GlobalVar.UserID, sModifiedAt))
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
'	Dim bRetVal As Boolean
'	Dim GTotOPHrs As Double
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
'	Dim rsDetail As Cursor
'	
'	Starter.strCriteria = "SELECT sum(TotOpHrs) as GTotOpHrs, sum(DrainTime) as GTotDrainTime, sum(DrainCum) as GTotDrain " & _
'					  "FROM OnOffDetails WHERE HeaderID = " & iTranHeaderID & " " & _
'					  "GROUP BY HeaderID"
'
'	rsDetail = Starter.DBCon.ExecQuery(Starter.strCriteria)
'
'	If rsDetail.RowCount > 0 Then
'		rsDetail.Position = 0
'		GTotOPHrs = rsDetail.GetDouble("GTotOpHrs")
'		GTotDuration = rsDetail.GetInt("GTotDrainTime")
'		GTotDrain = rsDetail.GetInt("GTotDrain")
'	Else
'		GTotOPHrs = TotOpHrs
'		GTotDuration = TotDrainHrs
'		GTotDrain = TotDrainCum
'	End If
'	rsDetail.Close
'	
'	bRetVal = False
'	Starter.DBCon.BeginTransaction
'	Try
'		Starter.strCriteria = "UPDATE TranHeader SET " & _
'							  "TotOpHrs = ?, " & _
'							  "TotDrainHrs = ?, " & _
'							  "TotDrain = ?, " & _
'							  "ModifiedBy = ?, " & _
'							  "ModifiedAt = ? " & _
'							  "WHERE HeaderID = " & iTranHeaderID
'							  
'		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(GTotOPHrs, GTotDuration, GTotDrain, GlobalVar.UserID, sModifiedAt))
'		Starter.DBCon.TransactionSuccessful
'		bRetVal = True
'	Catch
'		Log(LastException)
'		bRetVal = False
'	End Try
'	Starter.DBCon.EndTransaction
'	Return bRetVal
End Sub

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

Private Sub ConfirmSaveRecords(bAddEdit As Boolean)
	
	Dim sTitle, sContent As String
	
	Select bAddEdit
		Case True
			sTitle = $"CONFIRM SAVE?"$
			sContent = $"Save the Non-Operational Record?"$
		Case False
			sTitle = $"CONFIRM UPDATE?"$
			sContent = $"Modified the Non-Operational Record?"$
	End Select
	
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
			.SetOnPositiveClicked("ConfirmSave") _	'listeners
			.SetNegativeText("Cancel") _
			.SetNegativeColor(GlobalVar.NegColor) _
			.SetNegativeTypeface(FontBold) _
			.SetOnNegativeClicked("ConfirmSave")	'listeners
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Confirm Save Listeners
Private Sub ConfirmSave_OnNegativeClicked (View As View, Dialog As Object)
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub ConfirmSave_OnPositiveClicked (View As View, Dialog As Object)
	Alert.Initialize.Dismiss2
	Select GlobalVar.blnNewNonOp 'New or Edit
		Case True
			GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
			LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Yellow)
	
			If GlobalVar.TranHeaderID = 0 Or Not(DBaseFunctions.IsTransactionHeaderExist(GlobalVar.PumpHouseID, GlobalVar.TranDate)) Then
				If Not(SaveTransHeader) Then Return
				If Not(SaveNewNonOpRec) Then Return
			Else				
				If Not(SaveNewNonOpRec) Then Return
				If Not(UpdateTranHeader(GlobalVar.TranHeaderID)) Then Return
			End If
		
			ShowSaveSuccess

		Case False
'			LogColor($"Edit Time Record"$, Colors.Red)
'			GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
'			LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Yellow)
'			If DBaseFunctions.IsPumpTimeOverlappedEdit(DateTime.TimeParse(sTimeStart), DateTime.TimeParse(sTimeStart), GlobalVar.TranHeaderID, GlobalVar.NonOpDetailID) = True Then
'				RequiredMsgBox($"E R R O R"$,$"Unable to Edit Pump Time record due to it will Overlap existing records"$)
'				Return
'			End If
'			If Not(UpdatePumpTime(GlobalVar.TranHeaderID, GlobalVar.NonOpDetailID)) Then Return
'			If Not(EditTranHeader(GlobalVar.TranHeaderID)) Then Return
'			ShowSaveSuccess
	End Select
End Sub

Private Sub ShowSaveSuccess()
	Dim csTitle As CSBuilder
	Dim csContent As CSBuilder
	
	If GlobalVar.blnNewNonOp = True Then
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"New pump time has been successfully saved!"$).PopAll
	Else
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"Pump time has been successfully updated!"$).PopAll
	End If

	MatDialogBuilder.Initialize("Success")
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content(csContent)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(False)
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
	MatDialogBuilder.Show
End Sub

Private Sub Success_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			imeKeyboard.HideKeyboard
			Activity.Finish
	End Select
End Sub

Sub btnSaveUpdate_Click
	If Not(IsValidEntries) Then Return
	
	Dim Matcher1, Matcher2 As Matcher
	
	Matcher1 = Regex.Matcher("(\d\d):(\d\d)", mskTimeStart.Text)
	
	If Matcher1.Find Then		
		iHrs1 = GlobalVar.SF.Val(Matcher1.Group(1))
		iMins1 = GlobalVar.SF.Val(Matcher1.Group(2))
		
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMins1)) = 1 Then
			sMin1 = $"0"$ & iMins1
		Else
			sMin1 = iMins1
		End If
		
		If iHrs1 > 12 Then
			iHrsStart = iHrs1 - 12
			sAmPm1 = "PM"
		Else If iHrs1 = 12 Then
			iHrsStart = iHrs1
			sAmPm1 = "PM"
		Else If iHrs1 < 12 Then
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrs1)) = 1 Then
				iHrsStart = $"0"$ & iHrs1
			Else
				iHrsStart = iHrs1
			End If
			sAmPm1 = "AM"
		End If

		sTimeStart = iHrsStart & $":"$ & sMin1 & $" "$ & sAmPm1
		LogColor($"Start Time: "$ & sTimeStart,Colors.Yellow)
	End If
	
'//////////////////////////////////////////////////////////////////////////////////////////////////

	Matcher2 = Regex.Matcher("(\d\d):(\d\d)", mskTimeFinished.Text)
	
	If Matcher2.Find Then
		iHrs2 = GlobalVar.SF.Val(Matcher2.Group(1))
		iMins2 = GlobalVar.SF.Val(Matcher2.Group(2))
		
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMins2)) = 1 Then
			sMin2 = $"0"$ & iMins2
		Else
			sMin2 = iMins2
		End If
		
		If iHrs2 > 12 Then
			iHrsFinished = iHrs2 - 12
			sAmPm2 = "PM"
		Else If iHrs2 = 12 Then
			iHrsFinished = iHrs2
			sAmPm2 = "PM"
		Else If iHrs2 < 12 Then
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrs2)) = 1 Then
				iHrsFinished = $"0"$ & iHrs2
			Else
				iHrsFinished = iHrs2
			End If
			sAmPm2 = "AM"
		End If

		sTimeFinished = iHrsFinished & $":"$ & sMin2 & $" "$ & sAmPm2
		LogColor($"Finished Time: "$ & sTimeFinished,Colors.Yellow)
	End If

	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
	LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Yellow)
	
	If GlobalVar.blnNewNonOp = True Then
		If GlobalVar.TranHeaderID > 0 Then	
			If DBaseFunctions.IsNonOperationalTimeOverlapped(DateTime.TimeParse(mskTimeStart.Text & ":00"), DateTime.TimeParse(mskTimeFinished.Text & ":00") ,GlobalVar.TranHeaderID,0, GlobalVar.blnNewNonOp) = True Then
				RequiredMsgBox($"E R R O R"$, $"Unable to Add New Non-Operational record due to it will Overlap existing records."$)
				mskTimeStart.RequestFocus
				Return
			End If
		End If
	Else
		If GlobalVar.TranHeaderID > 0 Then
			If DBaseFunctions.IsNonOperationalTimeOverlapped(sTimeStart, sTimeFinished ,GlobalVar.TranHeaderID, GlobalVar.NonOpDetailID, GlobalVar.blnNewNonOp) = True Then
				RequiredMsgBox($"E R R O R"$, $"Unable to Edit Non-Operational record due to it will Overlap existing records."$)
				mskTimeStart.RequestFocus
				Return
			End If
		End If
	End If
	
	ConfirmSaveRecords(GlobalVar.blnNewNonOp)
End Sub

Private Sub ComputeTotHrs(T1 As String, T2 As String) As Float
	Dim dRetVal As Float
	Dim StartTime, EndTime As Long
	
	Try
		DateTime.TimeFormat = "hh:mm a"
		StartTime = DateTime.TimeParse(T1)
		EndTime = DateTime.TimeParse(T2)
		
		Dim p As Period = DateUtils.PeriodBetween(StartTime, EndTime)
		
		dRetVal = p.Hours + (p.Minutes/60)
	Catch
		dRetVal = 0
		Log(LastException)
	End Try
	Return dRetVal
End Sub
