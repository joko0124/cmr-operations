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
	Dim InpTyp As SLInpTypeConst
End Sub

Sub Globals
	Dim ActionBarButton As ACActionBar
	Private ToolBar As ACToolBarDark
	Private xmlIcon As XmlLayoutBuilder
	
	Private MatDialogBuilder As MaterialDialogBuilder
			
	Private snack As DSSnackbar
		
	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")
	
	'Main Screens
	Private CD, cdRemBorder, cdWL As ColorDrawable
	Private scvMain As ScrollView
	Private pnlMain As Panel
	
	'JO Details
	Private lblJONum As Label
	Private lblJOCat As Label
	Private lblAppNum As Label
	Private lblCustName As Label
	Private lblCustAddress As Label
	Private lblAcctClass As Label
	Private lblMeterNo As Label
	
	'Findings
	Private cboActionTaken As ACSpinner
	Private txtMeterFindings As EditText
	Private txtPrevRdg As EditText
	Private txtFinalRdg As EditText
	
	'Water Loss
	Private cboPipeType As ACSpinner
	Private cboPipeSize As ACSpinner
	Private txtPSI As EditText
	Private txtMinutes As EditText
	Private txtWaterLoss As EditText
	Private WaterLoss As Double

	'Remarks
	Private pnlRemarks As Panel
	Private txtRemarks As EditText

	'Accomplish Button
	Private btnSaveUpdate As ACButton

	'Signature
	Private pnlSignature As Panel
	Private SignaturePad As SignPad
	Private btnConfirmSig As ACButton

	Private pnlConfirmSig As Panel
	Private imgSignature As ImageView
	Private spnPlumbers As MultiSelectSpinner
	Private txtDateTimeFinished As EditText
	Private txtDateTimeStarted As EditText

	Private btnCancel As ACButton
	Private btnClear As ACButton
	Private btnOk As ACButton

	Private cdCancel, cdClear, cdOK, cdSig As ColorDrawable
	Private eSig As Object

	Private SigFolderName As String
	Private SigPicPath As String
	Private SigFilename As String
	Private RootDir As String = File.DirRootExternal
	Private HasSign As Boolean

	'Permissions
	Private ReadStoragePermission As Boolean
	Private WriteStoragePermission As Boolean
	Private CoarseLocPermission As Boolean
	Private FineLocPermission As Boolean
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("JOFindingsMain")
	scvMain.Panel.LoadLayout("DCCRJOFindings")
	scvMain.Panel.Height = pnlMain.Height
	
	GlobalVar.CSSubTitle.Initialize.Size(12).Append($"Accomplishment Form"$).PopAll
	GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"Disconnection-Delinquent Account JO"$).PopAll
	
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
		HasSign = False
		ClearUI
		FillJORecord(GlobalVar.SelectedJOID)
		cboActionTaken.RequestFocus
	End If
	InpTyp.Initialize
	InpTyp.SetInputType(txtRemarks,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_COMPLETE, InpTyp.TYPE_TEXT_FLAG_CAP_WORDS))
	InpTyp.SetInputType(txtMeterFindings,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_COMPLETE, InpTyp.TYPE_TEXT_FLAG_CAP_WORDS))
	
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
			ReadStoragePermission = True
		Else If Permission = Starter.RTP.PERMISSION_WRITE_EXTERNAL_STORAGE Then
			LogColor($"Permission to Write External Storage GRANTED"$, Colors.White)
			WriteStoragePermission = True
		Else If Permission = Starter.RTP.PERMISSION_ACCESS_COARSE_LOCATION Then
			LogColor($"Permission to Access Coarse Location GRANTED"$, Colors.Magenta)
			CoarseLocPermission = True
		Else If Permission = Starter.RTP.PERMISSION_ACCESS_FINE_LOCATION Then
			LogColor($"Permission to Access Fine Location GRANTED"$, Colors.Cyan)
			FineLocPermission = True
		End If
		Starter.StartFLP
	Else
		ReadStoragePermission = False
		WriteStoragePermission = False
		CoarseLocPermission = False
		FineLocPermission = False
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
	HasSign = False
	ClearUI
	FillJORecord(GlobalVar.SelectedJOID)
	cboActionTaken.RequestFocus
	CheckPermissions
End Sub

Sub Activity_Pause (UserClosed As Boolean)
End Sub

#End Region

#Region Toolbar
Sub Activity_CreateMenu(Menu As ACMenu)
	Dim Item As ACMenuItem
	
	Menu.Clear
	Menu.Add2(1, 1, "Cancel JO",xmlIcon.GetDrawable("baseline_delete_forever_white_24dp")).ShowAsAction = Item.SHOW_AS_ACTION_WITH_TEXT
End Sub

Sub ToolBar_NavigationItemClick 'Toolbar Arrow
	Activity.Finish
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
'	Select Item.Id
'		Case 1
'			PopSubMenu.Show
'	End Select
End Sub

#End Region


Sub scvMain_ScrollChanged(Position As Int)
	
End Sub

Private Sub ClearUI
	cdRemBorder.Initialize2(Colors.White, 0, 0, Colors.Transparent)
	
	cboActionTaken.Background = cdRemBorder
	txtMeterFindings.Background = cdRemBorder
	txtPrevRdg.Background = cdRemBorder
	txtFinalRdg.Background = cdRemBorder

	cboPipeType.Background = cdRemBorder
	cboPipeSize.Background = cdRemBorder
	txtPSI.Background = cdRemBorder
	txtMinutes.Background = cdRemBorder

	txtRemarks.Background = cdRemBorder

	txtDateTimeStarted.Background = cdRemBorder
	txtDateTimeFinished.Background = cdRemBorder

	cdWL.Initialize(0xFF1A535C,0)
	txtWaterLoss.Background = cdWL

	CD.Initialize2(GlobalVar.GreenColor, 30, 0, Colors.Transparent)
	btnSaveUpdate.Background = CD
	btnSaveUpdate.Text = Chr(0xE161) & $" ACCOMPLISH JO"$

	cdCancel.Initialize2(GlobalVar.RedColor, 20, 0, Colors.Transparent)
	btnCancel.Background = cdCancel
	btnCancel.Text = $"CANCEL"$
	
	cdClear.Initialize2(GlobalVar.YellowColor, 20, 0, Colors.Transparent)
	btnClear.Background = cdClear
	btnClear.Text = $"RETRY"$
	
	cdOK.Initialize2(GlobalVar.GreenColor, 20, 0, Colors.Transparent)
	btnOk.Background = cdOK
	btnOk.Text = $"SAVE"$

	lblJONum.Text = ""
	lblJOCat.Text = ""
	lblAppNum.Text = ""
	lblCustName.Text = ""
	lblCustAddress.Text = ""
	lblAcctClass.Text = ""
	
	txtMeterFindings.Text = ""
	txtPrevRdg.Text = ""
	txtFinalRdg.Text = ""

	txtMinutes.Text = ""
	txtWaterLoss.Text = ""
	txtRemarks.Text = ""

	txtDateTimeStarted.Text = ""
	txtDateTimeFinished.Text = ""
	WaterLoss = 0
	
	pnlSignature.Visible = False
	pnlConfirmSig.Visible = False
	
	cboActionTaken.Clear
	cboActionTaken.Add($"Pullout Meter"$)
	cboActionTaken.Add($"Lock Meter"$)
	
	FillPipeTypes
	FillPipeSizes
End Sub

Private Sub FillJORecord (iJOID As Int)
	Dim rsJONCDetails As Cursor
	Dim dMeterID As Double
	Try
		Starter.strCriteria = "SELECT * FROM tblJOs " & _
						  "WHERE JOID = " & iJOID
		LogColor(Starter.strCriteria, Colors.Yellow)

		rsJONCDetails = Starter.DBCon.ExecQuery(Starter.strCriteria)
		
		If rsJONCDetails.RowCount > 0 Then
			rsJONCDetails.Position = 0
			DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss a"
			lblJONum.Text = rsJONCDetails.GetString("JONo")
			lblAppNum.Text = rsJONCDetails.GetString("RefNo")
			lblJOCat.Text = GlobalVar.SF.Upper(rsJONCDetails.GetString("JoDesc"))
			lblCustName.Text = GlobalVar.SF.Upper(rsJONCDetails.GetString("CustName"))
			lblCustAddress.Text = GlobalVar.SF.Upper(rsJONCDetails.GetString("CustAddress"))
			lblAcctClass.Text = GlobalVar.SF.Upper(rsJONCDetails.GetString("AcctClass")) & "-" & GlobalVar.SF.Upper(rsJONCDetails.GetString("AcctSubClass"))
			dMeterID = GlobalVar.SF.Upper(rsJONCDetails.GetString("MeterID"))
			txtDateTimeStarted.Text = GlobalVar.SF.Upper(rsJONCDetails.GetString("DateStarted"))
			txtPrevRdg.Text = GlobalVar.SF.Upper(rsJONCDetails.GetString("PrevRdg"))
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
			Return
		End If
		lblMeterNo.Text = DBaseFunctions.GetCodeByID("MeterNo", "tblMeters","MeterID", dMeterID)
	Catch
		Log(LastException)
	End Try
	rsJONCDetails.Close
End Sub


Sub btnSaveUpdate_Click
	Dim cdSig As ColorDrawable
	If Not(ValidateEntries) Then
		Return
	End If
	
	pnlSignature.Visible = True
	cdOK.Initialize2(GlobalVar.GreenColor, 20, 0, Colors.Transparent)
	btnConfirmSig.Background = cdOK
	btnConfirmSig.Text = Chr(0xE5C8) & $" CONFIRM SIGNATURE"$

	cdSig.Initialize2(0xFFD3D3D3,0,0,Colors.Transparent)
	SignaturePad.Background = cdSig

	SignaturePad.clear
	SignaturePad.StrokeWidth = 15
	SignaturePad.Visible = True
	imgSignature.Bitmap = Null
	SignaturePad.Capture(True)
	scvMain.ScrollPosition = 0%x
	HasSign = False
	scvMain.Enabled = False
	Dim r As Reflector
	r.Target = scvMain
	r.RunMethod2("setVerticalScrollBarEnabled", False, "java.lang.boolean")
	r.RunMethod2("setOverScrollMode", 2, "java.lang.int" )
	r.SetOnTouchListener("scvTouch")
End Sub

Sub scvTouch(viewtag As Object, action As Int, X As Float, Y As Float, motionevent As Object) As Boolean
	Return True
End Sub

Sub SignaturePad_onSigned(sign As Object)
	eSig = sign
	HasSign = True
End Sub

Sub btnConfirmSig_Click
	Dim lngDateTime As Long
	lngDateTime = DateTime.Now
	
	If HasSign = False Then
		RequiredMsgBox(Chr(0xE002) & $" ERROR"$,$"Customer Signature is required."$)
		Return
	End If
	
	Log("SignaturePad_onSigned(sign)")
	
	pnlConfirmSig.Visible = True
	pnlSignature.Visible = False

	Dim bmp As Bitmap = eSig
	imgSignature.Bitmap = bmp
	spnPlumbers.Items = Array As String("")
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	txtDateTimeFinished.Text = DateTime.Date(lngDateTime)
	scvMain.ScrollPosition = 0%x

	FillPlumbers

	Dim r As Reflector
	r.Target = scvMain
	r.RunMethod2("setVerticalScrollBarEnabled", False, "java.lang.boolean")
	r.RunMethod2("setOverScrollMode", 2, "java.lang.int" )
End Sub

Sub btnClear_Click
	pnlSignature.Visible = True
	pnlConfirmSig.Visible = False
	
	cdOK.Initialize2(GlobalVar.GreenColor, 20, 0, Colors.Transparent)
	btnConfirmSig.Background = cdOK
	btnConfirmSig.Text = Chr(0xE5C8) & $" CONFIRM SIGNATURE"$

	cdSig.Initialize2(0xFFD3D3D3,0,0,Colors.Transparent)
	SignaturePad.Background = cdSig
	SignaturePad.clear
	SignaturePad.StrokeWidth = 15
	SignaturePad.Visible = True
	imgSignature.Bitmap = Null
	SignaturePad.Capture(True)
	scvMain.ScrollPosition = 0%x
	HasSign = False
	scvMain.Enabled = False
	Dim r As Reflector
	r.Target = scvMain
	r.RunMethod2("setVerticalScrollBarEnabled", False, "java.lang.boolean")
	r.RunMethod2("setOverScrollMode", 2, "java.lang.int" )
	r.SetOnTouchListener("scvTouch")
End Sub

Sub btnCancel_Click
	pnlSignature.Visible = False
	pnlConfirmSig.Visible = False
End Sub

Sub pnlSignature_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Sub pnlConfirmSig_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Sub btnOK_Click
	If spnPlumbers.SelectedItemsString = "" Then
		RequiredMsgBox($"ERROR"$, $"Unable to Accomplshed JO due to No selected plumber(s)."$)
		spnPlumbers.RequestFocus
		Log("No Selected")
		Return
	End If
	
	If Not(MiscFunctions.IsValidDate(txtDateTimeStarted.Text)) Or GlobalVar.SF.Len(GlobalVar.SF.Trim(txtDateTimeStarted.Text)) = 0 Then
		RequiredMsgBox($"ERROR"$, $"Invalid date Started!"$)
		txtDateTimeStarted.RequestFocus
		Return
	End If
		
	If Not(MiscFunctions.IsValidDate(txtDateTimeFinished.Text)) Or GlobalVar.SF.Len(GlobalVar.SF.Trim(txtDateTimeFinished.Text)) = 0 Then
		RequiredMsgBox($"ERROR"$, $"Invalid date finished!"$)
		txtDateTimeFinished.RequestFocus
		Return
	End If

	scvMain.ScrollPosition = 0%x
	ConfirmJOAccomplishment
End Sub

#Region Combo Boxes
Private Sub FillPipeTypes
	Dim rsPipeType As Cursor
	cboPipeType.Clear
	Try
		Starter.strCriteria = "SELECT * FROM cons_pipe_type"
		rsPipeType = Starter.DBCon.ExecQuery(Starter.strCriteria)
		If rsPipeType.RowCount > 0 Then
			For i = 0 To rsPipeType.RowCount - 1
				rsPipeType.Position = i
				cboPipeType.Add(GlobalVar.SF.Proper(rsPipeType.GetString("PipeDesc")))
			Next
		End If
	Catch
		ToastMessageShow("Unable to Load Pipe Type due to " & LastException.Message,False)
		Log(LastException)
	End Try
	rsPipeType.Close
End Sub

Private Sub FillPipeSizes
	Dim rsPipeSize As Cursor
	cboPipeSize.Clear
	Try
		Starter.strCriteria = "SELECT * FROM cons_pipe_size"
		rsPipeSize = Starter.DBCon.ExecQuery(Starter.strCriteria)
		If rsPipeSize.RowCount > 0 Then
			For i = 0 To rsPipeSize.RowCount - 1
				rsPipeSize.Position = i
				cboPipeSize.Add(GlobalVar.SF.Lower(rsPipeSize.GetString("SizeDesc")))
			Next
		End If
	Catch
		ToastMessageShow("Unable to Load Pipe Type due to " & LastException.Message,False)
		Log(LastException)
	End Try
	rsPipeSize.Close
End Sub

Private Sub FillPlumbers
	Dim rsPlumbers As Cursor
	
	Dim EmpName As String
	Dim EmpNameList() As String
	Dim pCount As Int
	
	Try
		Starter.strCriteria = "SELECT * FROM tblPlumbers " & _
						  "ORDER BY id ASC"
							  
		LogColor(Starter.strCriteria, Colors.Blue)
		
		rsPlumbers =  Starter.DBCon.ExecQuery (Starter.strCriteria)
		If rsPlumbers.RowCount > 0 Then
			pCount = rsPlumbers.RowCount
			Dim EmpNameList(pCount) As String
			
			For i = 0 To rsPlumbers.RowCount - 1
				rsPlumbers.Position = i
				EmpName = rsPlumbers.GetString("EmpName")
				EmpNameList(i) = EmpName
			Next
		Else
			snack.Initialize("", Activity, "No plumber(s) found!",snack.DURATION_SHORT)
			MyFunctions.SetSnackBarBackground(snack, Colors.Red)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			snack.Show
			Return
		End If
	Catch
		snack.Initialize("", Activity, LastException,snack.DURATION_SHORT)
		MyFunctions.SetSnackBarBackground(snack, Colors.Red)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		snack.Show
		Return
	End Try
	
	spnPlumbers.Items = EmpNameList
End Sub

#End Region

Private Sub ValidateEntries () As Boolean
	
	Try
		If GlobalVar.SF.Len(cboActionTaken.SelectedItem) <= 0 Then
			RequiredMsgBox($"ERROR"$, $"Unable to Accomplshed JO due to No selected Book."$)
			cboActionTaken.RequestFocus
			Return False
		End If
	
		If GlobalVar.SF.Len(txtMeterFindings.Text) <= 0 Then
			RequiredMsgBox($"ERROR"$, $"Unable to Accomplshed JO due to No specified Meter Findings."$)
			txtMeterFindings.RequestFocus
			Return False
		End If

		If GlobalVar.SF.Len(txtPrevRdg.Text) <= 0 Then
			RequiredMsgBox($"ERROR"$, $"Unable to Accomplshed JO due to No specified Meter Number."$)
			txtPrevRdg.RequestFocus
			Return False
		End If

		If GlobalVar.SF.Len(txtFinalRdg.Text) <= 0 Then
			RequiredMsgBox($"ERROR"$, $"Unable to Accomplshed JO due to No specified Initial Reading."$)
			txtFinalRdg.RequestFocus
			Return False
		End If
		
		If GlobalVar.SF.Val(txtFinalRdg.Text) < GlobalVar.SF.Val(txtPrevRdg.Text) Then
			RequiredMsgBox($"ERROR"$, $"Unable to Accomplshed JO due to Reading Went Back."$)
			txtFinalRdg.RequestFocus
		End If

		If GlobalVar.SF.Len(cboPipeType.SelectedItem) <= 0 Then
			RequiredMsgBox($"ERROR"$, $"Unable to Accomplshed JO due to Water Loss Computation is missing."$)
			cboPipeType.RequestFocus
			Return False
		End If
		
		If GlobalVar.SF.Len(cboPipeSize.SelectedItem) <= 0 Then
			RequiredMsgBox($"ERROR"$, $"Unable to Accomplshed JO due to Water Loss Computation is missing."$)
			cboPipeSize.RequestFocus
			Return False
		End If

		If GlobalVar.SF.Len(txtPSI.Text) <= 0 Then
			RequiredMsgBox($"ERROR"$, $"Unable to Accomplshed JO due to Water Loss Computation is missing."$)
			txtPSI.RequestFocus
			Return False
		End If

		If GlobalVar.SF.Len(txtMinutes.Text) <= 0 Then
			RequiredMsgBox($"ERROR"$, $"Unable to Accomplshed JO due to Water Loss Computation is missing."$)
			txtMinutes.RequestFocus
			Return False
		End If

		If GlobalVar.SF.Len(txtWaterLoss.Text) <= 0 Then
			Return False
		End If

		Return True
	Catch
		Log(LastException)
		Return False
	End Try
End Sub

#Region Activity Objects

Sub cboPipeSize_ItemClick (Position As Int, Value As Object)
	If GlobalVar.SF.Len(cboPipeType.SelectedItem) <= 0 Or GlobalVar.SF.Len(cboPipeSize.SelectedItem) <= 0 Or GlobalVar.SF.Len(txtMinutes.Text) <=0 Or GlobalVar.SF.Len(txtPSI.Text) <=0 Then
		WaterLoss = 0
	Else
		If txtPSI.Text <= 30 Then
			WaterLoss = DBaseFunctions.ComputeWaterLoss(cboPipeType.SelectedItem, GlobalVar.SF.Lower(cboPipeSize.SelectedItem), txtPSI.Text, txtMinutes.Text)
		Else
			WaterLoss = 0
		End If
	End If
	txtWaterLoss.Text = WaterLoss
End Sub

Sub cboPipeType_ItemClick (Position As Int, Value As Object)
	If GlobalVar.SF.Len(cboPipeType.SelectedItem) <= 0 Or GlobalVar.SF.Len(cboPipeSize.SelectedItem) <= 0 Or GlobalVar.SF.Len(txtMinutes.Text) <=0 Or GlobalVar.SF.Len(txtPSI.Text) <=0 Then
		WaterLoss = 0
	Else
		If txtPSI.Text <= 30 Then
			WaterLoss = DBaseFunctions.ComputeWaterLoss(cboPipeType.SelectedItem, GlobalVar.SF.Lower(cboPipeSize.SelectedItem), txtPSI.Text, txtMinutes.Text)
		Else
			WaterLoss = 0
		End If
	End If
	txtWaterLoss.Text = WaterLoss
End Sub

Sub txtPSI_TextChanged (Old As String, New As String)
	If GlobalVar.SF.Len(cboPipeType.SelectedItem) <= 0 Or GlobalVar.SF.Len(cboPipeSize.SelectedItem) <= 0 Or GlobalVar.SF.Len(txtMinutes.Text) <=0 Or GlobalVar.SF.Len(txtPSI.Text) <=0 Then
		WaterLoss = 0
	Else
		If txtPSI.Text <= 30 Then
			WaterLoss = DBaseFunctions.ComputeWaterLoss(cboPipeType.SelectedItem, GlobalVar.SF.Lower(cboPipeSize.SelectedItem), txtPSI.Text, txtMinutes.Text)
		Else
			WaterLoss = 0
		End If
	End If
	txtWaterLoss.Text = WaterLoss
End Sub

Sub txtPSI_FocusChanged (HasFocus As Boolean)
	txtPSI.SelectAll
End Sub

Sub txtPSI_EnterPressed
	txtMinutes.RequestFocus
End Sub

Sub txtMinutes_TextChanged (Old As String, New As String)
	If GlobalVar.SF.Len(cboPipeType.SelectedItem) <= 0 Or GlobalVar.SF.Len(cboPipeSize.SelectedItem) <= 0 Or GlobalVar.SF.Len(txtMinutes.Text) <=0 Or GlobalVar.SF.Len(txtPSI.Text) <=0 Then
		WaterLoss = 0
	Else
		If txtPSI.Text <= 30 Then
			WaterLoss = DBaseFunctions.ComputeWaterLoss(cboPipeType.SelectedItem, GlobalVar.SF.Lower(cboPipeSize.SelectedItem), txtPSI.Text, txtMinutes.Text)
		Else
			WaterLoss = 0
		End If
	End If
	txtWaterLoss.Text = WaterLoss
End Sub

Sub txtMinutes_FocusChanged (HasFocus As Boolean)
	txtMinutes.SelectAll
End Sub

Sub txtRemarks_FocusChanged (HasFocus As Boolean)
	Dim Send As EditText
	
	If HasFocus Then
		Send = Sender
		scvMain.ScrollPosition = btnSaveUpdate.Top
		txtRemarks.SelectAll
	End If
End Sub


Sub spnPlumbers_onItemSelected(position As Int, isChecked As Boolean, item As String)
	LogColor(item, Colors.Yellow)
End Sub


#End Region

Private Sub UpdateJO (iJOID As Int)
	Dim sActionTaken, sRemarks As String
	Dim dMeterID, dPrevRdg, dFinalRdg, dAddCons As Double
	
	'WaterLoss
	Dim sPipeType, sPipeSize As String
	Dim iPSI, iMinutes As Int
	Dim dWaterLoss As Double

	Dim lngDateTime As Long
	Dim sDatePosted As String
	Dim sAccomplishedBy As String
	Dim sLocation As String

	'Findings
	sActionTaken = ""
	
	dMeterID = 0
	dPrevRdg = 0
	dFinalRdg = 0
	dAddCons = 0
	
	sActionTaken = cboActionTaken.SelectedItem
	
	dMeterID = DBaseFunctions.GetIDByCode("MeterId", "tblMeters", "MeterNo", lblMeterNo.Text)
	dPrevRdg = txtPrevRdg.Text
	dFinalRdg = txtFinalRdg.Text
	dAddCons = GlobalVar.SF.Val(txtFinalRdg.Text) - GlobalVar.SF.Val(txtPrevRdg.Text)
	
	'Water Loss
	sPipeType = cboPipeType.SelectedItem
	sPipeSize = cboPipeSize.SelectedItem
	iPSI = txtPSI.Text
	iMinutes = txtMinutes.Text
	dWaterLoss = txtWaterLoss.Text
	
	'Remarks
	sRemarks = txtRemarks.Text
	Starter.FLP.Connect

	Log($"FLP is COnnected? "$ & Starter.FLP.IsConnected)
	
	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)

	sLocation = GlobalVar.Lat & "," & GlobalVar.Lon
	LogColor($"Location is "$ & sLocation, Colors.Yellow)

	lngDateTime = DateTime.Now
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	sDatePosted = DateTime.Date(lngDateTime)
	sAccomplishedBy = DBaseFunctions.GetPlumberIDs(spnPlumbers.SelectedItemsString)

	If WriteStoragePermission = False Then
		ToastMessageShow ($"Unable to Save Signature Image due to permission to write was denied"$,True)
	Else
		SigPicPath = File.Combine(RootDir, "DCIM")
		SigFolderName = File.Combine(SigPicPath, "BWSI-OP")
		If File.Exists(SigFolderName, "") = False Then
			File.MakeDir(SigPicPath, "BWSI-OP")
			SigFolderName = File.Combine(SigPicPath, "BWSI-OP")
		End If
	End If
	
	SigFilename = GlobalVar.SelectedJOCatCode & " -"& lblJONum.Text & "-" & lblAppNum.Text & ".jpg"
	Dim bmp As Bitmap = SignaturePad.TransparentSignatureBitmap
	imgSignature.Bitmap = bmp
	
	'Save image to file
	SignaturePad.saveBitmapToJPG(bmp,File.Combine(SigFolderName, SigFilename))
	Log(SigFilename & " Saved")
	
	Dim Phone As Phone
	Dim i As Intent
	i.Initialize("android.intent.action.MEDIA_SCANNER_SCAN_FILE", _
		"file://" & File.Combine(SigFolderName, SigFilename))
	Phone.SendBroadcastIntent(i)

	Starter.DBCon.BeginTransaction
	Try
		'Update JO Table
		Starter.strCriteria = "UPDATE tblJOs " & _
						  "SET FinalRdg = ?, JOStatus = ? , DateFinished = ?, AccomplishedBy = ?, SigFileName = ?, PostedAt = ?, PostedOn = ? " & _
						  "WHERE JOID = " & iJOID
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(dFinalRdg, 3, txtDateTimeFinished.Text, sAccomplishedBy, SigFolderName & "/" & SigFilename, sDatePosted, sLocation))
		
		'Insert to SAS Findings Table
		Starter.strCriteria = "INSERT INTO tblJODCFindings VALUES (?, ?, ?, ?, ?, ?, ?)"
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array(GlobalVar.SelectedJOID, dMeterID, dPrevRdg, dFinalRdg, dAddCons, sActionTaken, sRemarks))
		
		'Insert to JO Water Loss Table
		Starter.strCriteria = "INSERT INTO JOWaterLoss VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?)"
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array(GlobalVar.SelectedJOID, $"DC-DA"$, sPipeType, sPipeSize, iPSI, iMinutes, dWaterLoss))

		Starter.DBCon.TransactionSuccessful
		DispInfoMsg($"JO ACCOMPLISHED"$,$"JO has been successfully accomplished."$)
	Catch
		Log(LastException.Message)
	End Try
	Starter.DBCon.EndTransaction
End Sub

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

Private Sub ConfirmJOAccomplishment
	Dim Alert As AX_CustomAlertDialog

	Alert.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(Alert.STYLE_DIALOGUE) _
			.SetCancelable(False) _
			.SetTitle("JO Accomplishment") _
			.SetTitleColor(GlobalVar.BlueColor) _
			.SetTitleTypeface(FontBold) _
			.SetMessage("Do you want to Accomplish this JO Now?") _
			.SetPositiveText("Confirm") _
			.SetPositiveColor(GlobalVar.PosColor) _
			.SetPositiveTypeface(FontBold) _
			.SetNegativeText("Cancel") _
			.SetNegativeColor(GlobalVar.NegColor) _
			.SetNegativeTypeface(Font) _
			.SetMessageTypeface(Font) _
			.SetOnPositiveClicked("Accomplished") _	'listeners
			.SetOnNegativeClicked("Accomplished")	'listeners
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show
End Sub

'Listeners
Private Sub Accomplished_OnNegativeClicked (View As View, Dialog As Object)
'	ToastMessageShow("Negative Button Clicked!",False)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub Accomplished_OnPositiveClicked (View As View, Dialog As Object)
'	ToastMessageShow("Positive Button Clicked!",False)

	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize.Dismiss(Dialog)

	UpdateJO(GlobalVar.SelectedJOID)
End Sub


Private Sub FontSizeBinder_OnBindView (View As View, ViewType As Int)
	Dim alert As AX_CustomAlertDialog
	alert.Initialize
	If ViewType = alert.VIEW_TITLE Then ' Title
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

Private Sub DispInofrmationMsg_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			Activity.Finish
		Case mDialog.ACTION_NEGATIVE
	End Select
End Sub

#End Region