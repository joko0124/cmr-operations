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

	Private MatDialogBuilder As MaterialDialogBuilder
	Private CDtxtBox As ColorDrawable


	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")

	Private btnSaveUpdate As ACButton

	Private cboType As ACSpinner
	Private lblBrand As Label
	Private lblCode As Label
	Private lblModel As Label
	Private lblSerial As Label
	Private lblSPM As Label
	Private lblUnit As Label
	Private txtRemarks As EditText
	Private txtSPMPercent As EditText
	Private txtSPMRate As EditText
	Private txtVolume As EditText
	
	Private SPMRate = 0 As Int
	Private kBoard As IME
	Private sChloType As String
	Private sUOM As String
	Private chkDefaultTimeReplenish As CheckBox
	Private sRepTime As String

	Private mskTimeReplenish As MaskedEditText
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("ChlorinatorRecords")
		
	GetChlorinatorData(GlobalVar.PumpHouseID)
	
	InpTyp.Initialize
	InpTyp.SetInputType(txtRemarks,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_CORRECT, InpTyp.TYPE_TEXT_FLAG_CAP_SENTENCES))
	
	If GlobalVar.blnNewChlorine = True Then
		GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"ADD NEW CHLORINE RECORD"$).PopAll
		GlobalVar.CSSubTitle.Initialize.Size(12).Append($"Transaction Date: "$ & GlobalVar.TranDate).PopAll
		btnSaveUpdate.Text = Chr(0xE161) & $" SAVE"$
		FillChlorineType
		ClearUI
	Else
		GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"EDIT CHLORINE RECORD"$).PopAll
		GlobalVar.CSSubTitle.Initialize.Size(12).Append($"Transaction Date: "$ & GlobalVar.TranDate).PopAll
		btnSaveUpdate.Text = Chr(0xE161) & $" UPDATE"$
		FillChlorineType
		ClearUI
		GetChlorineDetails(GlobalVar.ChlorineDetailID)
	End If
	
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
	
	If FirstTime Then
	End If
	kBoard.Initialize("")
	CheckPermissions
End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	If KeyCode = 4 Then
		ToolBar_NavigationItemClick
		Return True
	Else
		Return False
	End If
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
	kBoard.HideKeyboard
	Activity.Finish
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
End Sub
#End Region

#Region UI
Private Sub ClearUI
	lblCode.Text = ""
	lblBrand.Text = ""
	lblModel.Text = ""
	lblSerial.Text = ""
	lblSPM.Text = ""
	chkDefaultTimeReplenish.Checked = False
	mskTimeReplenish.Text = "__:__"
	
	txtVolume.Text = ""
	txtSPMRate.Text = ""
	txtSPMPercent.Text = 0

	CDtxtBox.Initialize(Colors.Transparent,0)
	cboType.Background = CDtxtBox
	txtVolume.Background = CDtxtBox
	txtSPMRate.Background = CDtxtBox
	txtSPMPercent.Background = CDtxtBox
	txtRemarks.Background = CDtxtBox
	mskTimeReplenish.Background = CDtxtBox
	
	MyFunctions.SetButton(btnSaveUpdate, 25, 25, 25, 25, 25, 25, 25, 25)
End Sub

Sub btnSaveUpdate_Click
	If Not(IsValidEntries) Then Return

	Dim Matcher1 As Matcher
	Dim sMin, sHr As String
	sRepTime = ""

	If Not(IsValidEntries) Then Return 'Check Entries
	
	Matcher1 = Regex.Matcher("(\d\d):(\d\d)", mskTimeReplenish.Text)
	
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
			sRepTime = sHr & ":" & sMin & " AM"
		Else If iHrs > 0 And iHrs < 12 Then '1 to 11 AM
			sHr = iHrs
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(sHr)) = 1 Then
				sRepTime = $"0"$ & sHr & ":" & sMin & " AM"
			Else
				sRepTime = sHr & ":" & sMin & " AM"
			End If
			
		Else If iHrs = 12 Then '12 Noon
			sHr = 12
			sRepTime = sHr & ":" & sMin & " PM"
		Else ' 1 to 11 PM
			sHr = iHrs - 12
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(sHr)) = 1 Then
				sRepTime = $"0"$ & sHr & ":" & sMin & " PM"
			Else
				sRepTime = sHr & ":" & sMin & " PM"
			End If
		End If
	End If
		
	LogColor($"Reading Time: "$ & sRepTime,Colors.Yellow)

	ConfirmSaveUpdateChlorine

End Sub

Sub chkDefaultTimeReplenish_CheckedChange(Checked As Boolean)
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

		mskTimeReplenish.Text = sHour & ":" & sMin
		mskTimeReplenish.Enabled = False
	Else
		mskTimeReplenish.Enabled = True
		mskTimeReplenish.Text = "__:__"
		mskTimeReplenish.RequestFocus
		mskTimeReplenish.SelectionStart = 0
		kBoard.ShowKeyboard(mskTimeReplenish)
	End If
End Sub

Sub cboType_ItemClick (Position As Int, Value As Object)
	LogColor($"Selected "$ & Position & " - " & Value,Colors.Yellow)
	sUOM = GetUOM(Value)
	lblUnit.Text = sUOM
End Sub

Sub txtSPMRate_TextChanged (Old As String, New As String)
	If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtSPMRate.Text)) <= 0 Or SPMRate = 0 Then
		txtSPMPercent.Text = 0
	Else
		txtSPMPercent.Text = Round2(((GlobalVar.SF.Val(txtSPMRate.Text) / SPMRate) * 100),2)
	End If
End Sub

#End Region

#Region Misc Function
Sub GetChlorinatorData(iPumpID As Int)
	Dim SenderFilter As Object
	Try
		Starter.strCriteria = "SELECT Chlorinator.code AS ChloCode, Chlorinator.brand_name AS BrandName, " & _
							  "Chlorinator.model_no AS ModelNo, Chlorinator.serial_no AS SerialNo, Chlorinator.stroke_per_minute AS SPM " & _
							  "FROM tblChlorinator AS Chlorinator " & _
							  "INNER JOIN tblPumpStation AS Station ON Chlorinator.id = Station.ChlorinatorID " & _
							  "WHERE Station.StationID = 1 = " & iPumpID

		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			RS.Position = 0
			lblCode.Text = GlobalVar.SF.Upper(RS.GetString("ChloCode"))
			lblBrand.Text = GlobalVar.SF.Upper(RS.GetString("BrandName"))
			lblModel.Text = GlobalVar.SF.Upper(RS.GetString("ModelNo"))
			lblSerial.Text = GlobalVar.SF.Upper(RS.GetString("SerialNo"))
			SPMRate = RS.GetString("SPM")
			lblSPM.Text = SPMRate & " SPM"
		Else
			lblCode.Text = ""
			lblBrand.Text = ""
			lblModel.Text = ""
			lblSerial.Text = ""
			lblSPM.Text = 0
			SPMRate = 0
			ToastMessageShow($"Cannot get Chlorinator Data due to "$ & LastException.Message,True)
			Log(LastException)
		End If

	Catch
		ToastMessageShow($"Cannot get Chlorinator Data due to "$ & LastException.Message,True)
		Log(LastException)
	End Try
End Sub

Sub FillChlorineType()
	Dim SenderFilter As Object
	cboType.Clear
	Try
		Starter.strCriteria = "SELECT Chlorine.ChlorineType FROM cons_chlorine AS Chlorine"

		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			Do While RS.NextRow
				cboType.Add(GlobalVar.SF.Upper(RS.GetString("ChlorineType")))
			Loop
		Else
			ToastMessageShow($"Cannot get Chlorine Type due to "$ & LastException.Message,True)
			Log(LastException)
		End If
		lblUnit.Text = GetUOM(cboType.SelectedItem)

	Catch
		ToastMessageShow($"Cannot get Chlorine Type due to "$ & LastException.Message,True)
		Log(LastException)
	End Try
End Sub

Private Sub GetUOM (sValue As String) As String
	Dim sRetval As String
	sRetval = ""
	Try
		Starter.strCriteria = "SELECT UOM FROM cons_chlorine WHERE UPPER(ChlorineType) = '" & sValue & "'"
		sRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		sRetval = ""
		Log(LastException)
	End Try
	Return sRetval
End Sub

Private Sub GetChlorineDetails(iDetailID As Int)
	Dim sTimeRep As String
	Dim Matcher1 As Matcher

	Try
		Dim SenderFilter As Object
	
		Starter.strCriteria = "SELECT TimeReplenished, ChlorineType, Volume, SPMRate, Remarks " & _
						  "FROM ChlorineDetails " & _
						  "WHERE DetailID = " & iDetailID
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			RS.Position = 0
			sTimeRep = RS.GetString("TimeReplenished")
			sChloType = RS.GetString("ChlorineType")
			cboType.SelectedIndex = cboType.IndexOf(sChloType)
			txtVolume.Text = RS.GetInt("Volume")
			txtSPMRate.Text = RS.GetInt("SPMRate")
			txtRemarks.Text = RS.GetString("Remarks")
			DateTime.TimeFormat = "HH:mm"
			Matcher1 = Regex.Matcher("(\d\d):(\d\d) (\S\S)", sTimeRep)
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
						mskTimeReplenish.Text = $"00:"$ & sMin
					Else
						If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrs)) = 1 Then
							mskTimeReplenish.Text = $"0"$ & iHrs & $":"$ & sMin
						Else
							mskTimeReplenish.Text = iHrs & $":"$ & sMin
						End If
					End If
				Else
					If iHrs < 12 Then
						mskTimeReplenish.Text = (iHrs + 12) & $":"$ & sMin
					Else
						mskTimeReplenish.Text = iHrs & $":"$ & sMin
					End If
				End If
			End If
		Else
			sChloType = ""
			cboType.SelectedIndex = 0
			txtVolume.Text = "0"
			txtSPMRate.Text = "0"
			txtRemarks.Text = ""
			ToastMessageShow($"Unable to fetch chlorine record due to "$ & LastException.Message, True)
		End If
	Catch
		Log(LastException)
	End Try
End Sub

Private Sub IsValidEntries () As Boolean
	Try
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(mskTimeReplenish.Text)) <= 0 Or mskTimeReplenish.Text = "__:__" Then
			RequiredMsgBox($"ERROR"$, $"Replenish Time cannot be blank!"$)
			mskTimeReplenish.RequestFocus
			Return False
			
		Else If Validation.IsTime(mskTimeReplenish.Text) = False Then
			RequiredMsgBox($"ERROR"$, $"Invalid Replenish Time!"$)
			mskTimeReplenish.RequestFocus
			Return False
		End If
		
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(cboType.SelectedItem)) <=0 Then
			RequiredMsgBox($"ERROR"$, $"Chlorine Type cannot be blank!"$)
			cboType.RequestFocus
			Return False
		End If

		If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtVolume.Text)) <=0 Then
			RequiredMsgBox($"ERROR"$, $"Chlorine Volume cannot be blank!"$)
			txtVolume.RequestFocus
			Return False
		End If

		If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtSPMRate.Text)) <=0 Then
			RequiredMsgBox($"ERROR"$, $"Stroke Per Minute cannot be blank!"$)
			txtSPMRate.RequestFocus
			Return False
		End If
		Return True
	Catch
		Return False
		Log(LastException)
	End Try
End Sub
#End Region

#Region Database Saving
'New Chlorine Record
Private Sub SaveChlorineDetails() As Boolean
	Dim bRetVal As Boolean
	Dim TimeRead As String
	Dim iVol, iStroke As Int
	Dim lPercentage As Long
	Dim sChlorineType, sRemarks, sLocation As String

	Dim lDate As Long
	Dim sDateTimeAdded As String
	
	bRetVal = False
	sChlorineType = cboType.SelectedItem
	TimeRead = sRepTime
	iVol = GlobalVar.SF.Val(txtVolume.Text)
	sUOM = lblUnit.Text
	iStroke = GlobalVar.SF.Val(txtSPMRate.Text)
	lPercentage = GlobalVar.SF.Val(txtSPMPercent.Text)
	sRemarks = txtRemarks.Text

	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss a"
	sDateTimeAdded = DateTime.Date(lDate)

	Starter.FLP.Connect
	Log($"FLP is COnnected? "$ & Starter.FLP.IsConnected)
	
	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)

	sLocation = GlobalVar.Lat & "," & GlobalVar.Lon
	LogColor($"Location is "$ & sLocation, Colors.Yellow)
	
	Starter.DBCon.BeginTransaction
	Try
		Starter.DBCon.ExecNonQuery2("INSERT INTO ChlorineDetails VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
							    Array As Object(GlobalVar.TranHeaderID, TimeRead, sChlorineType, iVol, sUOM, iStroke, lPercentage, sRemarks, GlobalVar.UserID, sDateTimeAdded, sLocation, Null, Null, $""$, $"0"$, Null, Null))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		ToastMessageShow($"Unable to save Chlorine Records due to "$ & LastException.Message,True)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

'Update Chlorine Record
Private Sub UpdateChlorineRecord(iDetailID As Int, iTranHeaderID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim TimeRead As String
	Dim iVol, iStroke As Int
	Dim lPercentage As Long
	Dim sChlorineType, sRemarks, sLocation As String

	Dim lDate As Long
	Dim sDateTimeAdded As String
	
	bRetVal = False
	sChlorineType = cboType.SelectedItem
	TimeRead = sRepTime
	iVol = GlobalVar.SF.Val(txtVolume.Text)
	sUOM = lblUnit.Text
	iStroke = GlobalVar.SF.Val(txtSPMRate.Text)
	lPercentage = GlobalVar.SF.Val(txtSPMPercent.Text)
	sRemarks = txtRemarks.Text

	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss a"
	sDateTimeAdded = DateTime.Date(lDate)

	Starter.FLP.Connect
	Log($"FLP is COnnected? "$ & Starter.FLP.IsConnected)
	
	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)

	sLocation = GlobalVar.Lat & "," & GlobalVar.Lon
	LogColor($"Location is "$ & sLocation, Colors.Yellow)
	
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE ChlorineDetails SET " & _
						  "ChlorineType = ?, " & _
						  "Volume = ?, " & _
						  "UoM = ?, " & _
						  "SPMRate = ?, " & _
						  "SPMPercent = ?, " & _
						  "Remarks = ?, " & _
						  "ModifiedBy = ?, " & _
						  "ModifiedAt = ?, " & _
						  "ModifiedOn = ? " & _
						  "WHERE HeaderID = " & iTranHeaderID & " " & _
						  "AND DetailID = " & iDetailID
		LogColor(Starter.strCriteria, Colors.Yellow)
		
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(sChlorineType, iVol, sUOM, iStroke, lPercentage, sRemarks, GlobalVar.UserID, sDateTimeAdded, sLocation))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

'New Transaction Header
Private Sub SaveTransHeader() As Boolean
	Dim bRetVal As Boolean
	Dim lngDateTime As Long
	Dim sAddedAt As String
	
	bRetVal = False
	lngDateTime = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss a"
	sAddedAt= DateTime.Date(lngDateTime)

		
	Starter.DBCon.BeginTransaction
	Try
		
		Starter.DBCon.ExecNonQuery2("INSERT INTO TranHeader VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
							   Array As Object(GlobalVar.BranchID, GlobalVar.PumpHouseID, GlobalVar.TranDate, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"1"$, $"0"$, $"0"$, GlobalVar.UserID, sAddedAt, Null, Null, $"0"$, Null, Null))

		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

'Update Transaction Header
Private Sub UpdateTranHeader(iTranHeaderID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim GMinPSI, GMaxPSI, GAvePSI As Double
	Dim lngDateTime As Long
	Dim sModifiedAt As String
	
	bRetVal = False
	
	GMinPSI = DBaseFunctions.GetMinPSI(iTranHeaderID)
	GMaxPSI = DBaseFunctions.GetMaxPSI(iTranHeaderID)
	GAvePSI = DBaseFunctions.GetAvePSI(iTranHeaderID)

	lngDateTime = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss a"
	sModifiedAt = DateTime.Date(lngDateTime)
	
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE TranHeader SET " & _
						  "MinPSI = ?, " & _
						  "MaxPSI = ?, " & _
						  "AvePSI = ?, " & _
						  "ModifiedBy = ?, " & _
						  "ModifiedAt = ? " & _
						  "WHERE HeaderID = " & iTranHeaderID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(GMinPSI, GMaxPSI, GAvePSI, GlobalVar.UserID, sModifiedAt))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub
#End Region

#Region Messagebox
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

'Required MessageBox Listeners
Private Sub RequiredMsg_OnPositiveClicked (View As View, Dialog As Object)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
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

Private Sub ConfirmSaveUpdateChlorine
	Dim Alert As AX_CustomAlertDialog
	Dim sTitle, sMsg As String
	
	If GlobalVar.blnNewChlorine = True Then
		sTitle = $"SAVE NEW CHLORINE RECORDS"$
		sMsg = $"Save New Chlorine Record?"$
	Else
		sTitle = $"UPDATE CHLORINE RECORDS"$
		sMsg = $"Update Chlorine Record?"$
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
			.SetOnPositiveClicked("SaveUpdateChlorine") _	'listeners
			.SetOnNegativeClicked("SaveUpdateChlorine")	'listeners
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Confirm Save/Update Chlorine Listeners
Private Sub SaveUpdateChlorine_OnNegativeClicked (View As View, Dialog As Object)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub SaveUpdateChlorine_OnPositiveClicked (View As View, Dialog As Object)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
	If GlobalVar.blnNewChlorine = True Then
		If DBaseFunctions.IsTransactionHeaderExist(GlobalVar.PumpHouseID, GlobalVar.TranDate) = True Then
			GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
			LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Cyan)

			If Not(SaveChlorineDetails) Then
				ToastMessageShow($"Unable to Save Chlorinator Records due to "$ & LastException.Message, True)
				Return
			End If

			If Not(UpdateTranHeader(GlobalVar.TranHeaderID)) Then
				ToastMessageShow($"Unable to Save Chlorinator Records due to "$ & LastException.Message, True)
				Return
			End If
		Else
			If Not(SaveTransHeader) Then
				ToastMessageShow($"Unable to Save Chlorinator Records due to "$ & LastException.Message, True)
				Return
			End If
			GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)

			If Not(SaveChlorineDetails) Then
				ToastMessageShow($"Unable to Save Chlorinator Records due to "$ & LastException.Message, True)
				Return
			End If
		End If
		
	Else '
		GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
		If Not(UpdateChlorineRecord(GlobalVar.ChlorineDetailID, GlobalVar.TranHeaderID)) Then
			ToastMessageShow($"Unable to Save Chlorinator Records due to "$ & LastException.Message, True)
			Return
		End If
		If Not(UpdateTranHeader(GlobalVar.TranHeaderID)) Then
			ToastMessageShow($"Unable to Save Chlorinator Records due to "$ & LastException.Message, True)
			Return
		End If
	End If
	
	ShowSaveSuccess
End Sub

'Material Dialog Message Box
Private Sub ShowSaveSuccess()
	Dim csTitle As CSBuilder
	Dim csContent As CSBuilder

	If GlobalVar.blnNewChlorine = True Then
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"New Chlorinator Record has been successfully saved!"$).PopAll
	Else
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"Chlorinator Record has been successfully updated!"$).PopAll
	End If
	
	MatDialogBuilder.Initialize("AddUpdateChlorineRec")
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content(csContent)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(False)
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
	MatDialogBuilder.Show
End Sub

Private Sub AddUpdateChlorineRec_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			Activity.Finish
		Case mDialog.ACTION_NEGATIVE
	End Select
End Sub
#End Region
