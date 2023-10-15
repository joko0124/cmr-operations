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

	Private sTimeStarted As String
	Private sTimeFinished As String

	Private mskTimeFrom As MaskedEditText
	Private mskTimeTo As MaskedEditText

	Private cboPumpArea As ACSpinner
	Private chkCritical As CheckBox
	
	Private txtProbTitle As EditText
	Private txtProbDetails As EditText
	Private btnSaveUpdate As ACButton
	
	Private kBoard As IME
	Private scvMain As ScrollView
	Private pnlMain As Panel
	Private chkWasSolved As CheckBox
	Private txtActionTaken As EditText
End Sub

#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("ProblemEncMain")
	scvMain.Panel.LoadLayout("ProblemRecords")
	scvMain.Panel.Height = pnlMain.Height
	
	If GlobalVar.blnNewProblem = True Then
		GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"ADD NEW PROBLEM(S) ENCOUNTERED"$).PopAll
		GlobalVar.CSSubTitle.Initialize.Size(12).Append($"Transaction Date: "$ & GlobalVar.TranDate).PopAll
		btnSaveUpdate.Text = Chr(0xE161) & $" SAVE"$
		FillPumpArea
		ClearUI
	Else
		GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"EDIT PROBLEM(S) ENCOUNTERED"$).PopAll
		GlobalVar.CSSubTitle.Initialize.Size(12).Append($"Transaction Date: "$ & GlobalVar.TranDate).PopAll
		btnSaveUpdate.Text = Chr(0xE161) & $" UPDATE"$
		FillPumpArea
		ClearUI
		GetProblemDetails(GlobalVar.ProblemDetailID)
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
	InpTyp.Initialize
	InpTyp.SetInputType(txtProbTitle,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_CORRECT, InpTyp.TYPE_TEXT_FLAG_CAP_SENTENCES))
	InpTyp.SetInputType(txtProbDetails,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_CORRECT, InpTyp.TYPE_TEXT_FLAG_CAP_SENTENCES))
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
	mskTimeFrom.Text = "__:__"
	mskTimeTo.Text = "__:__"
	chkCritical.Checked = False
	
	txtProbTitle.Text = ""
	txtProbDetails.Text = ""
	chkWasSolved.Checked = False
	txtActionTaken.Text = ""
	txtActionTaken.Enabled = False
	
	CDtxtBox.Initialize(Colors.Transparent,0)
	cboPumpArea.Background = CDtxtBox
	txtProbTitle.Background = CDtxtBox
	txtProbDetails.Background = CDtxtBox
	txtActionTaken.Background = CDtxtBox
	mskTimeFrom.Background = CDtxtBox
	mskTimeTo.Background = CDtxtBox
	
	MyFunctions.SetButton(btnSaveUpdate, 25, 25, 25, 25, 25, 25, 25, 25)
End Sub

Sub scvMain_ScrollChanged(Position As Int)
	
End Sub

Sub btnSaveUpdate_Click
	Dim Matcher1, Matcher2 As Matcher
	Dim sMin1, sHr1, sMin2, sHr2 As String
	Dim lngTimeStarted, lngTimeFinished As Long
	
	sTimeStarted = ""

	If Not(IsValidEntries) Then Return 'Check Entries
	
	Matcher1 = Regex.Matcher("(\d\d):(\d\d)", mskTimeFrom.Text)
	
	If Matcher1.Find Then 'Split
		Dim iHrs1, iMins1 As Int
		
		iHrs1 = Matcher1.Group(1)
		iMins1 = Matcher1.Group(2)
		
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMins1)) = 1 Then 'Test length of mins
			sMin1 = $"0"$ & iMins1
		Else
			sMin1 = iMins1
		End If

		If iHrs1 = 0 Then '12 AM
			sHr1 = 12
			sTimeStarted = sHr1 & ":" & sMin1 & " AM"
		Else If iHrs1 > 0 And iHrs1 < 12 Then '1 to 11 AM
			sHr1 = iHrs1
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(sHr1)) = 1 Then
				sTimeStarted = $"0"$ & sHr1 & ":" & sMin1 & " AM"
			Else
				sTimeStarted = sHr1 & ":" & sMin1 & " AM"
			End If
			
		Else If iHrs1 = 12 Then '12 Noon
			sHr1 = 12
			sTimeStarted = sHr1 & ":" & sMin1 & " PM"
		Else ' 1 to 11 PM
			sHr1 = iHrs1 - 12
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(sHr1)) = 1 Then
				sTimeStarted = $"0"$ & sHr1 & ":" & sMin1 & " PM"
			Else
				sTimeStarted = sHr1 & ":" & sMin1 & " PM"
			End If
		End If
	End If
		
	LogColor($"Start Time: "$ & sTimeStarted,Colors.Yellow)

	Matcher2 = Regex.Matcher("(\d\d):(\d\d)", mskTimeTo.Text)
	
	If Matcher2.Find Then 'Split
		Dim iHrs2, iMins2 As Int
		
		iHrs2 = Matcher2.Group(1)
		iMins2 = Matcher2.Group(2)
		
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMins2)) = 1 Then 'Test length of mins
			sMin2 = $"0"$ & iMins2
		Else
			sMin2 = iMins2
		End If

		If iHrs2 = 0 Then '12 AM
			sHr2 = 12
			sTimeFinished = sHr2 & ":" & sMin2 & " AM"
		Else If iHrs2 > 0 And iHrs2 < 12 Then '1 to 11 AM
			sHr2 = iHrs2
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(sHr2)) = 1 Then
				sTimeFinished = $"0"$ & sHr2 & ":" & sMin2 & " AM"
			Else
				sTimeFinished = sHr2 & ":" & sMin2 & " AM"
			End If
			
		Else If iHrs2 = 12 Then '12 Noon
			sHr2 = 12
			sTimeFinished = sHr2 & ":" & sMin2 & " PM"
		Else ' 1 to 11 PM
			sHr2 = iHrs2 - 12
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(sHr2)) = 1 Then
				sTimeFinished = $"0"$ & sHr2 & ":" & sMin2 & " PM"
			Else
				sTimeFinished = sHr2 & ":" & sMin2 & " PM"
			End If
		End If
	End If
		
	LogColor($"End Time: "$ & sTimeFinished,Colors.Yellow)
	DateTime.TimeFormat = "HH:mm"
	lngTimeStarted = DateTime.TimeParse(mskTimeFrom.Text)
	lngTimeFinished = DateTime.TimeParse(mskTimeTo.Text)
	
	LogColor($"Time Start: "$ & lngTimeStarted, Colors.Yellow)
	LogColor($"Time Finished: "$ & lngTimeFinished, Colors.Cyan)
	
	If lngTimeStarted > lngTimeFinished Then
		RequiredMsgBox($"ERROR"$, $"Time End is earlier than Time Started!"$)
		Return
	End If
	
	ConfirmSaveUpdateProblem
End Sub

Sub cboPumpArea_ItemClick (Position As Int, Value As Object)
	LogColor($"Selected "$ & Position & " - " & Value,Colors.Yellow)	
End Sub

Sub chkWasSolved_CheckedChange(Checked As Boolean)
	If Checked = True Then
		txtActionTaken.Enabled = True
		txtActionTaken.RequestFocus
	Else
		txtActionTaken.Enabled = False
		txtActionTaken.Text = ""
	End If
End Sub
#End Region

#Region Misc Function
Sub FillPumpArea()
	Dim SenderFilter As Object
	cboPumpArea.Clear
	Try
		Starter.strCriteria = "SELECT PumpArea FROM PumpAreas"

		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			Do While RS.NextRow
				cboPumpArea.Add(RS.GetString("PumpArea"))
			Loop
		Else
			ToastMessageShow($"Cannot get Pump Areas due to "$ & LastException.Message,True)
			Log(LastException)
		End If

	Catch
		ToastMessageShow($"Cannot get Pump Areas due to "$ & LastException.Message,True)
		Log(LastException)
	End Try
End Sub

Private Sub GetProblemDetails(iDetailID As Int)
	Dim sTimeStart, sTimeEnd As String
	Dim sArea, sActionTake As String
	Dim iArea, iIsCritical As Int
	Dim Matcher1, Matcher2 As Matcher

	Try
		Dim SenderFilter As Object
	
		Starter.strCriteria = "SELECT * FROM ProblemDetails " & _
						  "WHERE DetailID = " & iDetailID
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			RS.Position = 0
			sTimeStart = RS.GetString("TimeStart")
			sTimeEnd = RS.GetString("TimeFinished")
			iArea = RS.GetInt("AreaID")
			sArea = DBaseFunctions.GetCodeByID("PumpArea","PumpAreas","ID", iArea)
			iIsCritical = RS.GetInt("IsCritical")
			If iIsCritical = 1 Then
				chkCritical.Checked = True
			Else
				chkCritical.Checked = False
			End If
			cboPumpArea.SelectedIndex = cboPumpArea.IndexOf(sArea)
			txtProbTitle.Text = RS.GetString("ProblemTitle")
			txtProbDetails.Text = RS.GetString("ProbDesc")
			sActionTake = RS.GetString("ActionTaken")
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(sActionTake)) <= 0 Then
				chkWasSolved.Checked = False
				txtActionTaken.Enabled = False
			Else
				chkWasSolved.Checked = True
				txtActionTaken.Text = sActionTake
				txtActionTaken.Enabled = True
			End If
			
			
			DateTime.TimeFormat = "HH:mm"
			Matcher1 = Regex.Matcher("(\d\d):(\d\d) (\S\S)", sTimeStart)
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
						mskTimeFrom.Text = $"00:"$ & sMin
					Else
						If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrs)) = 1 Then
							mskTimeFrom.Text = $"0"$ & iHrs & $":"$ & sMin
						Else
							mskTimeFrom.Text = iHrs & $":"$ & sMin
						End If
					End If
				Else
					If iHrs < 12 Then
						mskTimeFrom.Text = (iHrs + 12) & $":"$ & sMin
					Else
						mskTimeFrom.Text = iHrs & $":"$ & sMin
					End If
				End If
			End If
			'//////////////////////////////////////////////// End Time  /////////////////////////////////////
			DateTime.TimeFormat = "HH:mm"
			Matcher2 = Regex.Matcher("(\d\d):(\d\d) (\S\S)", sTimeEnd)
			If Matcher2.Find Then
				Dim iHrs2, iMins2 As Int
				Dim AmPm2 As String
				Dim sMin2 As String
				
				iHrs2 = Matcher2.Group(1)
				iMins2 = Matcher2.Group(2)
				AmPm2 = Matcher2.Group(3)
				
				LogColor(AmPm2,Colors.Cyan)
				
				If GlobalVar.SF.Len(GlobalVar.SF.Trim(iMins2)) = 1 Then
					sMin2 = $"0"$ & iMins2
				Else
					sMin2 = iMins2
				End If

				If AmPm2 = "AM" Then
					If iHrs2 = 12 Then
						mskTimeTo.Text = $"00:"$ & sMin2
					Else
						If GlobalVar.SF.Len(GlobalVar.SF.Trim(iHrs2)) = 1 Then
							mskTimeTo.Text = $"0"$ & iHrs2 & $":"$ & sMin2
						Else
							mskTimeTo.Text = iHrs2 & $":"$ & sMin2
						End If
					End If
				Else
					If iHrs2 < 12 Then
						mskTimeTo.Text = (iHrs2 + 12) & $":"$ & sMin2
					Else
						mskTimeTo.Text = iHrs2 & $":"$ & sMin2
					End If
				End If
			End If
		Else
			ToastMessageShow($"Unable to fetch problem record due to "$ & LastException.Message, True)
		End If
	Catch
		Log(LastException)
	End Try
End Sub

Private Sub IsValidEntries () As Boolean
	Try
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(mskTimeFrom.Text)) <= 0 Or mskTimeFrom.Text = "__:__" Then
			RequiredMsgBox($"ERROR"$, $"Time Started cannot be blank!"$)
			mskTimeFrom.RequestFocus
			Return False
			
		Else If Validation.IsTime(mskTimeFrom.Text) = False Then
			RequiredMsgBox($"ERROR"$, $"Time Started cannot be blank!"$)
			mskTimeFrom.RequestFocus
			Return False
		End If

		If DBaseFunctions.IsFuturisticTime(GlobalVar.TranDate,mskTimeFrom.Text) = True Then
			RequiredMsgBox($"E R R O R"$, $"Unable to Add/Update New Problem Encountered record due to specified time is too soon."$)
			mskTimeFrom.RequestFocus
			Return False
		End If
		
		If GlobalVar.SF.Len(GlobalVar.SF.Trim(mskTimeTo.Text)) <= 0 Or mskTimeTo.Text = "__:__" Then
			RequiredMsgBox($"ERROR"$, $"Time Finished cannot be blank!"$)
			mskTimeTo.RequestFocus
			Return False
			
		Else If Validation.IsTime(mskTimeTo.Text) = False Then
			RequiredMsgBox($"ERROR"$, $"Time Finished cannot be blank!"$)
			mskTimeTo.RequestFocus
			Return False
		End If

		If DBaseFunctions.IsFuturisticTime(GlobalVar.TranDate,mskTimeTo.Text) = True Then
			RequiredMsgBox($"E R R O R"$, $"Unable to Add/Update New Problem Encountered record due to specified time is too soon."$)
			mskTimeTo.RequestFocus
			Return False
		End If

		If GlobalVar.SF.Len(GlobalVar.SF.Trim(cboPumpArea.SelectedItem)) <=0 Then
			RequiredMsgBox($"ERROR"$, $"Pump Area cannot be blank!"$)
			cboPumpArea.RequestFocus
			Return False
		End If

		If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtProbTitle.Text)) <=0 Then
			RequiredMsgBox($"ERROR"$, $"Problem Title cannot be blank!"$)
			txtProbTitle.RequestFocus
			Return False
		End If

		If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtProbDetails.Text)) <=0 Then
			RequiredMsgBox($"ERROR"$, $"Problem Details cannot be blank!"$)
			txtProbDetails.RequestFocus
			Return False
		End If

		If chkWasSolved.Checked = True Then
			If GlobalVar.SF.Len(GlobalVar.SF.Trim(txtActionTaken.Text)) <=0 Then
				RequiredMsgBox($"ERROR"$, $"Problem Details cannot be blank!"$)
				txtActionTaken.RequestFocus
				Return False
			End If
		End If
		Return True
	Catch
		Return False
		Log(LastException)
	End Try
End Sub
#End Region

#Region Database Saving
'New Problem Record
Private Sub SaveProblemDetails() As Boolean
	Dim bRetVal As Boolean
	Dim TimeStart, TimeFinished As String
	Dim iAreaID As Int
	Dim IsCritical, WasSolved As Int
	Dim sProblemTitle, sDesc, sAction, sLocation As String

	Dim lDate As Long
	Dim sDateTimeAdded As String
	
	bRetVal = False
	iAreaID = DBaseFunctions.GetIDByCode("ID","PumpAreas","PumpArea", cboPumpArea.SelectedItem)
	TimeStart = sTimeStarted
	TimeFinished = sTimeFinished

	If chkCritical.Checked = True Then
		IsCritical = 1
	Else
		IsCritical = 0
	End If

	If chkWasSolved.Checked = True Then
		WasSolved = 1
		sAction = txtActionTaken.Text
	Else
		WasSolved = 0
		sAction = ""
	End If
	
	sProblemTitle = txtProbTitle.Text
	sDesc = txtProbDetails.Text
	
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
		Starter.DBCon.ExecNonQuery2("INSERT INTO ProblemDetails VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _
							    Array As Object(GlobalVar.TranHeaderID, TimeStart, TimeFinished, iAreaID, IsCritical, sProblemTitle, sDesc, WasSolved, sAction, GlobalVar.UserID, sDateTimeAdded, sLocation, Null, Null, $""$, $"0"$, Null, Null))
		Starter.DBCon.TransactionSuccessful
		bRetVal = True
	Catch
		Log(LastException)
		ToastMessageShow($"Unable to save Problem Encountered Record due to "$ & LastException.Message,True)
		bRetVal = False
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

'Update Problem Record
Private Sub UpdateProblemRecord(iDetailID As Int, iTranHeaderID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim TimeStart, TimeFinished As String
	Dim iAreaID As Int
	Dim IsCritical, WasSolved As Int
	Dim sProblemTitle, sDesc, sAction, sLocation As String

	Dim lDate As Long
	Dim sDateTimeAdded As String
	
	bRetVal = False
	iAreaID = DBaseFunctions.GetIDByCode("ID","PumpAreas","PumpArea",cboPumpArea.SelectedItem)
	TimeStart = sTimeStarted
	TimeFinished = sTimeFinished

	If chkCritical.Checked = True Then
		IsCritical = 1
	Else
		IsCritical = 0
	End If

	If chkWasSolved.Checked = True Then
		WasSolved = 1
		sAction = txtActionTaken.Text
	Else
		WasSolved = 0
		sAction = ""
	End If
	sProblemTitle = txtProbTitle.Text
	sDesc = txtProbDetails.Text
	
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
		Starter.strCriteria = "UPDATE ProblemDetails SET " & _
						  "TimeStart = ?, " & _
						  "TimeFinished = ?, " & _
						  "AreaID = ?, " & _
						  "IsCritical = ?, " & _
						  "ProblemTitle = ?, " & _
						  "ProbDesc = ?, " & _
						  "WasSolved = ?, " & _
						  "ActionTaken = ?, " & _
						  "ModifiedBy = ?, " & _
						  "ModifiedAt = ?, " & _
						  "ModifiedOn = ? " & _
						  "WHERE HeaderID = " & iTranHeaderID & " " & _
						  "AND DetailID = " & iDetailID
		LogColor(Starter.strCriteria, Colors.Yellow)
		
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(TimeStart, TimeFinished, iAreaID, IsCritical, sProblemTitle, sDesc, WasSolved, sAction, GlobalVar.UserID, sDateTimeAdded, sLocation))
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
							   Array As Object(GlobalVar.BranchID, GlobalVar.PumpHouseID, GlobalVar.TranDate, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"0"$, $"1"$, GlobalVar.UserID, sAddedAt, Null, Null, $"0"$, Null, Null))

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
	Dim lngDateTime As Long
	Dim sModifiedAt As String
	
	bRetVal = False
	
	lngDateTime = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss a"
	sModifiedAt = DateTime.Date(lngDateTime)
	
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE TranHeader SET " & _
						  "HasProblem = ?, " & _
						  "ModifiedBy = ?, " & _
						  "ModifiedAt = ? " & _
						  "WHERE HeaderID = " & iTranHeaderID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String($"1"$, GlobalVar.UserID, sModifiedAt))
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

Private Sub ConfirmSaveUpdateProblem
	Dim Alert As AX_CustomAlertDialog
	Dim sTitle, sMsg As String
	
	If GlobalVar.blnNewProblem = True Then
		sTitle = $"SAVE NEW PROBLEM(S) ENCOUNTERED RECORD"$
		sMsg = $"Save New Problem Encountered Record?"$
	Else
		sTitle = $"UPDATE PROBLEM(S) ENCOUNTERED RECORD"$
		sMsg = $"Update Problem Encountered Record?"$
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
			.SetOnPositiveClicked("SaveUpdateProblem") _	'listeners
			.SetOnNegativeClicked("SaveUpdateProblem")	'listeners
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Confirm Save/Update Chlorine Listeners
Private Sub SaveUpdateProblem_OnNegativeClicked (View As View, Dialog As Object)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub SaveUpdateProblem_OnPositiveClicked (View As View, Dialog As Object)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
	If GlobalVar.blnNewProblem = True Then
		If DBaseFunctions.IsTransactionHeaderExist(GlobalVar.PumpHouseID, GlobalVar.TranDate) = True Then
			GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
			LogColor($"Header ID: "$ & GlobalVar.TranHeaderID, Colors.Cyan)

			If Not(SaveProblemDetails) Then
				ToastMessageShow($"Unable to Save Problem Encountered Records due to "$ & LastException.Message, True)
				Return
			End If

			If Not(UpdateTranHeader(GlobalVar.TranHeaderID)) Then
				ToastMessageShow($"Unable to Save Problem Encountered Records due to "$ & LastException.Message, True)
				Return
			End If
		Else
			If Not(SaveTransHeader) Then
				ToastMessageShow($"Unable to Save Problem Encountered Records due to "$ & LastException.Message, True)
				Return
			End If
			GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)

			If Not(SaveProblemDetails) Then
				ToastMessageShow($"Unable to Save Problem Encountered Records due to "$ & LastException.Message, True)
				Return
			End If
		End If
		
	Else '
		GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
		If Not(UpdateProblemRecord(GlobalVar.ProblemDetailID, GlobalVar.TranHeaderID)) Then
			ToastMessageShow($"Unable to Save Problem Encountered Records due to "$ & LastException.Message, True)
			Return
		End If
		If Not(UpdateTranHeader(GlobalVar.TranHeaderID)) Then
			ToastMessageShow($"Unable to Save Problem Encountered Records due to "$ & LastException.Message, True)
			Return
		End If
	End If
	
	ShowSaveSuccess
End Sub

'Material Dialog Message Box
Private Sub ShowSaveSuccess()
	Dim csTitle As CSBuilder
	Dim csContent As CSBuilder

	If GlobalVar.blnNewProblem = True Then
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"New Problem Encountered Record has been successfully saved!"$).PopAll
	Else
		csTitle.Initialize.Size(18).Bold.Color(GlobalVar.PosColor).Append($"S U C C E S S!"$).PopAll
		csContent.Initialize.Size(14).Color(Colors.Black).Append($"Problem Encountered Record has been successfully updated!"$).PopAll
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