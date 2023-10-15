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
	
	Private snack As DSSnackbar
	Private csAns As CSBuilder

	
	'Pump Time On
	Private mskTimeOn As MaskedEditText
	Private mskTimeOff As MaskedEditText

	Private optElectricity As B4XView
	Private optGenerator As B4XView

	Private chkDrain As B4XView
	Private txtDuration As EditText
	Private txtPSI As EditText
	Private txtDrainCum As EditText

	Private txtOnRemarks As EditText
	Private txtOffRemarks As EditText

	Private btnSave As ACButton
		
	Private sTimeOn As String
	Private sTimeOff As String
	Private iHrOn, iHrOff As Int
	
	Private TotDrainHrs, TotDrainCum As Double
	
	Private PowerSourceID As Int
	Private TotOpHrs As Double
	
	Private PumpPowerStatus As Int
	
	Private imeKeyboard As IME
	Private Alert As AX_CustomAlertDialog
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("EditPumpTimeRecords")
	
	Dim jo As JavaObject
	Dim xl As XmlLayoutBuilder
	
	GlobalVar.blnNewTime = False
	GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"EDIT PUMP TIME RECORD"$).PopAll
	GlobalVar.CSSubTitle.Initialize.Size(12).Append($"Transaction Date: "$ & GlobalVar.TranDate).PopAll
	btnSave.Text = Chr(0xE161) & $" UPDATE"$
	ClearDisplay
	GetTimeRecord(GlobalVar.TimeDetailID)

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
	InpTyp.SetInputType(txtOnRemarks,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_CORRECT, InpTyp.TYPE_TEXT_FLAG_CAP_SENTENCES))

	CDtxtBox.Initialize(Colors.Transparent,0)
	cdFixedText.Initialize(GlobalVar.BlueColor,0)
	mskTimeOn.Background = CDtxtBox
	txtDuration.Background = CDtxtBox
	txtDrainCum.Background = cdFixedText
	txtOnRemarks.Background = CDtxtBox
	txtOffRemarks.Background = CDtxtBox
	txtPSI.Background = CDtxtBox
	imeKeyboard.Initialize("")

	If FirstTime Then
		PumpPowerStatus = DBaseFunctions.GetPumpPowerStatus(GlobalVar.PumpHouseID)
	End If
	
	MyFunctions.SetButton(btnSave, 25, 25, 25, 25, 25, 25, 25, 25)
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
	PumpPowerStatus = DBaseFunctions.GetPumpPowerStatus(GlobalVar.PumpHouseID)
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

Sub chkDrain_CheckedChange(Checked As Boolean)
	If Checked =True Then
		txtDuration.Enabled = True
		txtDuration.RequestFocus
		imeKeyboard.ShowKeyboard(txtDuration)
		txtPSI.Enabled = True
	Else
		txtDuration.Enabled = False
		txtPSI.Enabled = False
		txtDuration.Text = ""
		txtDrainCum.Text = ""
	End If
End Sub

Sub btnSave_Click
	If Not(IsValidEntries) Then Return
	ConfirmSaveRecords(GlobalVar.blnNewTime)
End Sub

Private Sub GetTimeRecord(iDetailedID As Int)
	Dim iPowerSource As Int
	Dim SenderFilter As Object
	Dim sTimeOn, sTimeOff As String
	
	Dim Matcher1 As Matcher
	Dim Matcher2 As Matcher
	
	Dim iHrsOn, iMinsOn As Int
	Dim AmPmOn As String
	Dim sMinOn As String

	Dim iHrsOff, iMinsOff As Int
	Dim AmPmOff As String
	Dim sMinOff As String
	
	Try
	
		Starter.strCriteria = "SELECT Details.DetailID, Details.HeaderID, Details.PumpOnTime, Details.PumpOffTime, " & _
						  "Details.TotOpHrs, Details.PowerSourceID, Details.DrainPSI, Details.DrainTime, Details.DrainCum, " & _
						  "Details.TimeOnRemarks, Details.TimeOffRemarks " & _
						  "FROM OnOffDetails AS Details " & _
						  "WHERE Details.DetailID = " & iDetailedID
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			RS.Position = 0
			sTimeOn = RS.GetString("PumpOnTime")
			DateTime.TimeFormat = "HH:mm"
			Matcher1 = Regex.Matcher("(\d\d):(\d\d) (\S\S)", sTimeOn)
			If Matcher1.Find Then
				
				iHrsOn = Matcher1.Group(1)
				iMinsOn = Matcher1.Group(2)
				AmPmOn = Matcher1.Group(3)
				
				LogColor(AmPmOn, Colors.Cyan)
				
				If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMinsOn)) = 1 Then
					sMinOn = $"0"$ & iMinsOn
				Else
					sMinOn = iMinsOn
				End If

				If AmPmOn = "AM" Then
					If iHrsOn = 12 Then
						iHrOn = 0
						mskTimeOn.Text = $"0"$ & iHrOn & $":"$ & sMinOn
					Else
						iHrOn = iHrsOn
						If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrOn)) = 1 Then
							mskTimeOn.Text = $"0"$ & iHrOn & $":"$ & sMinOn
						Else
							mskTimeOn.Text = iHrOn & $":"$ & sMinOn
						End If
					End If
				Else
					If iHrsOn < 12 Then
						iHrOn = iHrsOn + 12
						mskTimeOn.Text = iHrOn & $":"$ & sMinOn
					Else
						iHrOn = iHrsOn
						mskTimeOn.Text = iHrOn & $":"$ & sMinOn
					End If
					iHrOn = iHrsOn + 12
					mskTimeOn.Text = iHrOn & $":"$ & sMinOn
				End If
			End If
			
			sTimeOff = RS.GetString("PumpOffTime")
			DateTime.TimeFormat = "HH:mm"
			Matcher2 = Regex.Matcher("(\d\d):(\d\d) (\S\S)", sTimeOff)
			If Matcher2.Find Then
				
				iHrsOff = Matcher2.Group(1)
				iMinsOff = Matcher2.Group(2)
				AmPmOff = Matcher2.Group(3)
				
				LogColor(AmPmOff, Colors.Cyan)
				
				If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMinsOff)) = 1 Then
					sMinOff = $"0"$ & iMinsOff
				Else
					sMinOff = iMinsOff
				End If

				If AmPmOff = "AM" Then
					If iHrsOff = 12 Then
						iHrOff = 0
						mskTimeOff.Text = $"0"$ & iHrOff & $":"$ & sMinOff
					Else
						iHrOff = iHrsOff
						If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrOff)) = 1 Then
							mskTimeOff.Text = $"0"$ & iHrOn & $":"$ & sMinOff
						Else
							mskTimeOff.Text = iHrOff & $":"$ & sMinOff
						End If
					End If
				Else
					If iHrsOff < 12 Then
						iHrOff = iHrsOff + 12
						mskTimeOff.Text = iHrOff & $":"$ & sMinOff
					Else
						iHrOff = iHrsOff
						mskTimeOff.Text = iHrOff & $":"$ & sMinOff
					End If
					iHrOff = iHrsOff + 12
					mskTimeOff.Text = iHrOff & $":"$ & sMinOff
				End If
			End If

			LogColor($"Time On: "$ & sTimeOn, Colors.Yellow)
			LogColor($"Time Off: "$ & sTimeOff,Colors.Cyan)
			
			iPowerSource = RS.GetInt("PowerSourceID")
			If iPowerSource = 1 Then
				optElectricity.Checked = True
				optGenerator.Checked = False
			Else
				optElectricity.Checked = False
				optGenerator.Checked = True
			End If

			txtPSI.Text = RS.GetInt("DrainPSI")
			txtDuration.Text = RS.GetInt("DrainTime")
			txtDrainCum.Text = RS.GetInt("DrainCum")
			
			If txtDrainCum.Text = Null Or txtDrainCum.Text = 0 Or txtDuration.Text = Null Or txtDuration.Text = 0 Then
				chkDrain.Checked = False
				txtPSI.Text = ""
				txtDuration.Text = ""
				txtDrainCum.Text = ""
			Else
				chkDrain.Checked = True
			End If
			txtOnRemarks.Text = RS.GetString("TimeOnRemarks")
			txtOffRemarks.Text = RS.GetString("TimeOffRemarks")
		Else
			snack.Initialize("", Activity,$"Error Due to"$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If
	Catch
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End Try
End Sub

Private Sub ClearDisplay
	mskTimeOn.Text = "__:__"
	mskTimeOff.Text = "__:__"
	optElectricity.Checked = True
	txtDuration.Text = ""
	txtDrainCum.Text = ""
	txtOnRemarks.Text = ""
	txtOffRemarks.Text = ""
End Sub

Private Sub IsValidEntries() As Boolean
	LogColor(mskTimeOn.Text, Colors.Yellow)
	Try
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(mskTimeOn.Text)) <= 0 Or mskTimeOn.Text = "__:__" Then
			RequiredMsgBox($"ERROR"$, $"Pump Time On cannot be blank!"$)
			mskTimeOn.RequestFocus
			Return False
			
		Else If Validation.IsTime(mskTimeOn.Text) = False Then
			RequiredMsgBox($"ERROR"$, $"Invalid Pump Time On!"$)
			mskTimeOn.RequestFocus
			Return False
		End If
		
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(mskTimeOff.Text)) <= 0 Or mskTimeOff.Text = "__:__" Then
			RequiredMsgBox($"ERROR"$, $"Pump Time Off cannot be blank!"$)
			mskTimeOff.RequestFocus
			Return False
			
		Else If Validation.IsTime(mskTimeOff.Text) = False Then
			RequiredMsgBox($"ERROR"$, $"Invalid Pump Time Of!"$)
			mskTimeOff.RequestFocus
			Return False
		End If

		If optElectricity.Checked = False And optGenerator.Checked = False Then
			RequiredMsgBox($"ERROR"$, $"No Power Source selected!"$)
			Return False
		End If
		
		If chkDrain.Checked = True Then
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtDuration.Text)) <= 0 Then
				RequiredMsgBox($"ERROR"$, $"Drain Time in minutes cannot be blank!"$)
				txtDuration.RequestFocus
				Return False
			End If
			
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtPSI.Text)) <= 0 Then
				RequiredMsgBox($"ERROR"$, $"Pump Pressure in PSI cannot be blank!"$)
				txtPSI.RequestFocus
				Return False
			End If

			If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtDrainCum.Text)) <= 0 Then
				RequiredMsgBox($"ERROR"$, $"Drain Production in CuM cannot be blank!"$)
				txtDrainCum.RequestFocus
				Return False
			End If
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
	
	lngDateTime = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss a"
	sAddedAt= DateTime.Date(lngDateTime)

	bRetVal = False
	Starter.DBCon.BeginTransaction
	Try
		
		Starter.DBCon.ExecNonQuery2("INSERT INTO TranHeader VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
							   Array As Object(GlobalVar.BranchID, GlobalVar.PumpHouseID, GlobalVar.TranDate, $"0"$, $"0"$, TotDrainCum, TotDrainHrs, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, GlobalVar.UserID, GlobalVar.UserID, $"0"$, GlobalVar.UserID, sAddedAt, Null, Null))


'		Starter.DBCon.ExecNonQuery2("INSERT INTO TranHeader VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
'							   Array As Object('HeaderID, BranchID, PumpID, TranDate, TotOpHrs, TotProduction, TotDrain, TotDrainHrs, MinPSI, MaxPSI, AvePSI, IsChlorinated, TotNonOpHours, DayOperatorID, NightOperatorID, WasUploaded, AddedBy, AddedAt, ModifiedBy, ModifiedAt))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

Private Sub InsertNewPumpTime() As Boolean
	Dim bRetVal As Boolean
	
	Dim sDateTime As String
	Dim lDate As Long
	Dim sRemarks, sLocation As String
	
	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	sDateTime = DateTime.Date(lDate)

	sRemarks = txtOnRemarks.Text
	
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
		Starter.DBCon.ExecNonQuery2("INSERT INTO OnOffDetails VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
													  	Array As Object(GlobalVar.TranHeaderID, sTimeOn, $""$, $"0"$, PowerSourceID, TotDrainHrs, TotDrainCum, sRemarks, $""$, $"0"$, GlobalVar.UserID, sDateTime, sLocation, Null, Null, $""$, $"0"$, $""$))
		'HeaderID, PumpOnTime, PumpOffTime, TotOpHrs, PowerSourceID, DrainTime, DrainCum, TimeOnRemarks, TimeOffRemarks, WasUploaded, AddedBy, AddedAt, AddedOn, ModifiedBy, ModifiedAt, ModifiedOn, UploadedBy, UploadedAt
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

Private Sub UpdatePumpTime(iTranHeaderID As Int, iDetailID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim sDateTime As String
	Dim lDate As Long
	Dim iPSI As Int
	Dim dDuration, dCuM As Double
	Dim sOnRemarks, sOffRemarks, sLocation As String
	
	Dim Matcher1, Matcher2 As Matcher
	Dim sMinOn, sMinOff As String
	
	Matcher1 = Regex.Matcher("(\d\d):(\d\d)", mskTimeOn.Text)
	
	If Matcher1.Find Then
		Dim iHrsOn, iMinsOn As Int
		
		iHrsOn = Matcher1.Group(1)
		iMinsOn = Matcher1.Group(2)
		
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMinsOn)) = 1 Then
			sMinOn = $"0"$ & iMinsOn
		Else
			sMinOn = iMinsOn
		End If

		If iHrsOn = 0 Then
			iHrOn = 12
			sTimeOn = iHrOn & ":" & sMinOn & " AM"
		Else If iHrsOn > 0 And iHrsOn < 12 Then
			iHrOn = iHrsOn
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrOn)) = 1 Then
				sTimeOn = $"0"$ & iHrOn & ":" & sMinOn & " AM"
			Else
				sTimeOn = iHrOn & ":" & sMinOn & " AM"
			End If
		Else If iHrsOn = 12 Then
			iHrOn = 12
			sTimeOn = iHrOn & ":" & sMinOn & " PM"
		Else
			iHrOn = iHrsOn - 12
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrOn)) = 1 Then
				sTimeOn = $"0"$ & iHrOn & ":" & sMinOn & " PM"
			Else
				sTimeOn = iHrOn & ":" & sMinOn & " PM"
			End If
		End If
	End If
	
	Matcher2 = Regex.Matcher("(\d\d):(\d\d)", mskTimeOff.Text)
	
	If Matcher2.Find Then
		Dim iHrsOff, iMinsOff As Int
		
		iHrsOff = Matcher2.Group(1)
		iMinsOff = Matcher2.Group(2)
		
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMinsOff)) = 1 Then
			sMinOff = $"0"$ & iMinsOff
		Else
			sMinOff = iMinsOff
		End If

		If iHrsOff= 0 Then
			iHrOff = 12
			sTimeOff = iHrOff & ":" & sMinOff & " AM"
		Else If iHrsOff > 0 And iHrsOff < 12 Then
			iHrOff = iHrsOff
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrOff)) = 1 Then
				sTimeOff = $"0"$ & iHrOff & ":" & sMinOff & " AM"
			Else
				sTimeOff = iHrOff & ":" & sMinOff & " AM"
			End If
		Else If iHrsOff = 12 Then
			iHrOff = 12
			sTimeOff = iHrOff & ":" & sMinOff & " PM"
		Else
			iHrOff = iHrsOff - 12
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrOff)) = 1 Then
				sTimeOff = $"0"$ & iHrOff & ":" & sMinOff & " PM"
			Else
				sTimeOff = iHrOff & ":" & sMinOff & " PM"
			End If
		End If
	End If

	LogColor(sTimeOn,Colors.Yellow)
	LogColor(sTimeOff,Colors.Magenta)
	
	If optElectricity.Checked = True Then
		PowerSourceID = 1
	Else
		PowerSourceID = 0
	End If
	
	If chkDrain.Checked = True Then
		iPSI = txtPSI.Text
		dDuration = txtDuration.Text
		dCuM = txtDrainCum.Text
	Else
		iPSI = 0
		dDuration = 0
		dCuM = 0
	End If
	
	LogColor($"Total Drain Duration: "$ & TotDrainHrs, Colors.Magenta)
	LogColor($"Total Drain CuM: "$ & TotDrainCum, Colors.Magenta)
	
	lDate = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	sDateTime = DateTime.Date(lDate)
	sOnRemarks = txtOnRemarks.Text
	sOffRemarks = txtOffRemarks.Text
	
	Starter.FLP.Connect

	Log($"FLP is COnnected? "$ & Starter.FLP.IsConnected)
	
	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)

	sLocation = GlobalVar.Lat & "," & GlobalVar.Lon
	LogColor($"Location is "$ & sLocation, Colors.Yellow)

	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
	LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Yellow)
	
	TotOpHrs = ComputeTotHrs(sTimeOn, sTimeOff)

	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE OnOffDetails SET " & _
						  "PumpOnTime = ?, " & _
						  "PumpOffTime = ?, " & _
						  "TotOpHrs = ?, " & _
						  "PowerSourceID = ?, " & _
						  "DrainPSI = ?, " & _
						  "DrainTime = ?, " & _
						  "DrainCum = ?, " & _
						  "TimeOnRemarks = ?, " & _
						  "TimeOffRemarks = ?, " & _
						  "ModifiedBy = ?, " & _
						  "ModifiedAt = ?, " & _
						  "ModifiedOn = ? " & _
						  "WHERE HeaderID = " & iTranHeaderID & " " & _
						  "AND DetailID = " & iDetailID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(sTimeOn, sTimeOff, TotOpHrs, PowerSourceID, iPSI, dDuration, dCuM, sOnRemarks, sOffRemarks, GlobalVar.UserID, sDateTime, sLocation))
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
		GTotOPHrs = rsHeader.GetDouble("TotOpHrs") + TotOpHrs
		GTotDuration = rsHeader.GetInt("TotDrainHrs") + TotDrainHrs
		GTotDrain = rsHeader.GetInt("TotDrain") + TotDrainCum
	Else
		GTotOPHrs = TotOpHrs
		GTotDuration = TotDrainHrs
		GTotDrain = TotDrainCum
	End If
	rsHeader.Close
	LogColor($"Total Op Hrs: "$ & GTotOPHrs, Colors.Magenta)
	
	bRetVal = False
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE TranHeader SET " & _
							  "TotOpHrs = ?, " & _
							  "TotDrainHrs = ?, " & _
							  "TotDrain = ?, " & _
							  "ModifiedBy = ?, " & _
							  "ModifiedAt = ? " & _
							  "WHERE HeaderID = " & iTranHeaderID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(GTotOPHrs, GTotDuration, GTotDrain, GlobalVar.UserID, sModifiedAt))
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
	Dim bRetVal As Boolean
	Dim GTotOPHrs As Double
	Dim GTotDrain, GTotDuration As Double

	Dim lngDateTime As Long
	Dim sModifiedAt As String
	
	DateTime.DateFormat = "yyyy-MM-dd"
	DateTime.TimeFormat = "hh:mm:ss a"
	lngDateTime = DateTime.Now
	sModifiedAt = DateTime.Date(lngDateTime) & $" "$ & DateTime.Time(lngDateTime)

	Dim rsDetail As Cursor
	
	Starter.strCriteria = "SELECT sum(TotOpHrs) as GTotOpHrs, sum(DrainTime) as GTotDrainTime, sum(DrainCum) as GTotDrain " & _
					  "FROM OnOffDetails WHERE HeaderID = " & iTranHeaderID & " " & _
					  "GROUP BY HeaderID"

	rsDetail = Starter.DBCon.ExecQuery(Starter.strCriteria)

	If rsDetail.RowCount > 0 Then
		rsDetail.Position = 0
		GTotOPHrs = rsDetail.GetDouble("GTotOpHrs")
		GTotDuration = rsDetail.GetInt("GTotDrainTime")
		GTotDrain = rsDetail.GetInt("GTotDrain")
	Else
		GTotOPHrs = TotOpHrs
		GTotDuration = TotDrainHrs
		GTotDrain = TotDrainCum
	End If
	rsDetail.Close
	
	bRetVal = False
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE TranHeader SET " & _
							  "TotOpHrs = ?, " & _
							  "TotDrainHrs = ?, " & _
							  "TotDrain = ?, " & _
							  "ModifiedBy = ?, " & _
							  "ModifiedAt = ? " & _
							  "WHERE HeaderID = " & iTranHeaderID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(GTotOPHrs, GTotDuration, GTotDrain, GlobalVar.UserID, sModifiedAt))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

Sub chkDefaultTimeOn_CheckedChange(Checked As Boolean)
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

		mskTimeOn.Text = sHour & ":" & sMin
	Else
		mskTimeOn.Text = "__:__"
	End If
End Sub

Sub txtPSI_TextChanged (Old As String, New As String)
	Dim Losses As Int
	
	Losses = 0
	If GlobalVar.SF.Len(txtDuration.Text) <= 0 Or GlobalVar.SF.Len(GlobalVar.PumpDrainPipesize) <= 0 Or GlobalVar.SF.Len(txtPSI.Text) <= 0 Then
		Losses = 0
	Else
		Losses = DBaseFunctions.ComputeWaterLoss(GlobalVar.PumpDrainPipeType, GlobalVar.PumpDrainPipeSize, txtPSI.Text, txtDuration.Text)
	End If
	txtDrainCum.Text = Losses
End Sub

Sub txtPSI_EnterPressed
	txtOnRemarks.RequestFocus
End Sub

Sub txtPSI_FocusChanged (HasFocus As Boolean)
	If HasFocus = True Then txtPSI.SelectAll
End Sub


Sub txtDuration_TextChanged (Old As String, New As String)
	Dim Losses As Int
	
	Losses = 0
	If GlobalVar.SF.Len(txtDuration.Text) <= 0 Or GlobalVar.SF.Len(GlobalVar.PumpDrainPipesize) <= 0 Or GlobalVar.SF.Len(txtPSI.Text) <= 0 Then
		Losses = 0
	Else
		Losses = DBaseFunctions.ComputeWaterLoss(GlobalVar.PumpDrainPipeType, GlobalVar.PumpDrainPipeSize, txtPSI.Text, txtDuration.Text)
	End If
	txtDrainCum.Text = Losses
End Sub

Sub txtDuration_EnterPressed
	txtPSI.RequestFocus
End Sub

Sub txtDuration_FocusChanged (HasFocus As Boolean)
	If HasFocus = True Then txtDuration.SelectAll
End Sub

Sub txtOnRemarks_FocusChanged (HasFocus As Boolean)
	If HasFocus = True Then txtOnRemarks.SelectAll
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
	
	Dim Alert As AX_CustomAlertDialog
	Dim sTitle, sContent As String
	
	Select bAddEdit
		Case True
			sTitle = $"CONFIRM SAVE?"$
			sContent = $"Save the Pump Time On?"$
		Case False
			sTitle = $"CONFIRM UPDATE?"$
			sContent = $"Modified the Pump Time On?"$
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
			.SetOnPositiveClicked("PumpOn") _	'listeners
			.SetNegativeText("Cancel") _
			.SetNegativeColor(GlobalVar.NegColor) _
			.SetNegativeTypeface(FontBold) _
			.SetOnNegativeClicked("PumpOn")	'listeners
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Listeners
Private Sub PumpOn_OnNegativeClicked (View As View, Dialog As Object)
'	ToastMessageShow("Negative Button Clicked!",False)
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub PumpOn_OnPositiveClicked (View As View, Dialog As Object)
'	ToastMessageShow("Positive Button Clicked!",False)
	
	Alert.Initialize.Dismiss2
	GlobalVar.blnNewTime = False
	LogColor($"Edit Time Record"$, Colors.Red)
	LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Yellow)
	LogColor($"Detail ID: "$ & GlobalVar.TimeDetailID, Colors.White)
	
	If DBaseFunctions.IsPumpTimeOverlappedEdit(DateTime.TimeParse(sTimeOn), DateTime.TimeParse(sTimeOff), GlobalVar.TranHeaderID, GlobalVar.TimeDetailID) = True Then
		RequiredMsgBox($"E R R O R"$,$"Unable to Add New Pump Time record due to it will Overlap existing records"$)
		Return
	End If
	
	If Not(UpdatePumpTime(GlobalVar.TranHeaderID, GlobalVar.TimeDetailID)) Then Return
	If Not(EditTranHeader(GlobalVar.TranHeaderID)) Then Return
	ShowSaveSuccess
End Sub

Private Sub ShowSaveSuccess()
	Dim csTitle As CSBuilder
	Dim csContent As CSBuilder
	
	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
	csContent.Initialize.Size(14).Color(Colors.Black).Append($"Pump time has been successfully updated!"$).PopAll
	
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
