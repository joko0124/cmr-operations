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
	Private CD As ColorDrawable
	Private vibration As B4Avibrate
	Private vibratePattern() As Long
	
	Private snack As DSSnackbar
	Private csAns As CSBuilder

	Private clvJOs As CustomListView
	Private lblAppNum As Label
	Private lblCustAddress As Label
	Private lblCustName As Label
	Private lblStatus As Label
	Private lblJONum As Label
	Private pnlJOInfo As Panel
	
	Dim cdSearch As ColorDrawable
	Private txtSearch As EditText
	Private PopSubMenu As ACPopupMenu
	Private JOCounts As Int
	Private Limit As Int = 2000

	Private txtRemarks As EditText
	
	Type JOSASDetails(ID As Int, Num As String, CatCode As String, Status As Int, JOID As Int, AppNo As String, _
				   CustName As String, CustAdd As String)

	Private lblJOCat As Label
	Private cboAcctClass As ACSpinner
	Private cboConType As ACSpinner
	Private cboSubClass As ACSpinner
	Private btnSaveUpdate As ACButton
	Private pnlSignature As Panel
	Private SignaturePad As SignPad
	Private imgSignature As ImageView

	Private SigFolderName As String
	Private SigPicPath As String
	Private SigFilename As String
	Private RootDir As String = File.DirRootExternal
	Private HasSign As Boolean

	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")

	Private pnlConfirmSig As Panel
	Private btnCancel As ACButton
	Private btnClear As ACButton
	Private btnOk As ACButton
	
	Private cdConfirm, cdCancel, cdClear, cdOK As ColorDrawable
	Private eSig As Object
	Private btnConfirmSig As ACButton
	Private spnPlumbers As MultiSelectSpinner
	Private txtDateTimeStarted As EditText
	Private txtDateTimeFinished As EditText

	'Plumber Location
'	Private flp As FusedLocationProvider
'	Private LastLocation As Location

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
	Activity.LoadLayout("SASJOFindings")
	
	GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"Service Application Survey"$).PopAll
	GlobalVar.CSSubTitle.Initialize.Size(12).Append($"Accomplishment Form"$).PopAll
	
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
	
	cdSearch.Initialize(Colors.Transparent, 0)
	txtRemarks.Background = cdSearch
	txtDateTimeStarted.Background = cdSearch
	txtDateTimeFinished.Background = cdSearch
	
	InpTyp.Initialize
	InpTyp.SetInputType(txtRemarks,Array As Int(InpTyp.TYPE_CLASS_TEXT, InpTyp.TYPE_TEXT_FLAG_AUTO_COMPLETE, InpTyp.TYPE_TEXT_FLAG_CAP_WORDS))

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

	cdConfirm.Initialize2(GlobalVar.GreenColor, 20, 0, Colors.Transparent)
	btnConfirmSig.Background = cdConfirm
	
	btnConfirmSig.Text = Chr(0xE5C8) & $" CONFIRM SIGNATURE"$

	If FirstTime Then
		HasSign = False
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
	ClearUI
	FillJORecord(GlobalVar.SelectedJOID)
	FillCombos
	HasSign = False
	FillJORecord(GlobalVar.SelectedJOID)
	CheckPermissions
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	CallSubDelayed(Starter,"StopFLP")
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

Sub ToolBar_MenuItemClick (Item As ACMenuItem)
	
End Sub

#End Region

#Region JO Lists

Private Sub FillJORecord (iJOID As Int)
	Dim RSJOSASDetails As Cursor
	
	Try
		Starter.strCriteria = "SELECT * FROM tblJOs " & _
						  "WHERE JOID = " & iJOID
		LogColor(Starter.strCriteria, Colors.Yellow)

		RSJOSASDetails = Starter.DBCon.ExecQuery(Starter.strCriteria)
		
		If RSJOSASDetails.RowCount > 0 Then
			RSJOSASDetails.Position = 0
			lblJONum.Text = RSJOSASDetails.GetString("JONo")
			lblAppNum.Text = RSJOSASDetails.GetString("RefNo")
			lblJOCat.Text = GlobalVar.SF.Upper(RSJOSASDetails.GetString("JoDesc"))
			lblCustName.Text = GlobalVar.SF.Upper(RSJOSASDetails.GetString("CustName"))
			lblCustAddress.Text = GlobalVar.SF.Upper(RSJOSASDetails.GetString("CustAddress"))
			txtDateTimeStarted.Text = RSJOSASDetails.GetString("DateStarted")
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
			Return
		End If
		
	Catch
		Log(LastException)
	End Try
	RSJOSASDetails.Close		
End Sub

Private Sub FillCombos
	cboAcctClass.Clear
	cboAcctClass.Add($"RES"$)
	cboAcctClass.Add($"COM"$)
	cboAcctClass.Add($"IND"$)
	cboAcctClass.Add($"GOV"$)
	cboAcctClass.Add($"REL"$)

	cboSubClass.Clear
	cboSubClass.Add($"A"$)
	cboSubClass.Add($"B"$)
	cboSubClass.Add($"C"$)

	cboConType.Clear
	cboConType.Add($"Plug Connection"$)
	cboConType.Add($"Tapping Connection"$)
	cboConType.Add($"Across Soil"$)
	cboConType.Add($"Across Pavement"$)
End Sub
#End Region

Sub cboAcctClass_ItemClick (Position As Int, Value As Object)
	
End Sub

Sub cboSubClass_ItemClick (Position As Int, Value As Object)
	
End Sub

Sub cboConType_ItemClick (Position As Int, Value As Object)
	
End Sub

Private Sub ClearUI
	If txtRemarks.IsInitialized = False Then
		txtRemarks.Initialize("txtRemarks")
	End If
	lblJONum.Text = ""
	lblJOCat.Text = ""
	lblCustName.Text = ""
	lblCustAddress.Text = ""
	lblAppNum.Text = ""
	txtRemarks.Text = ""
	cboAcctClass.Clear
	cboSubClass.Clear
	cboConType.Clear
	pnlSignature.Visible = False
	pnlConfirmSig.Visible = False
End Sub

Sub btnSaveUpdate_Click
	Dim cdSig As ColorDrawable
	If Not(ValidateEntries) Then
		Return
	End If
	
	pnlSignature.Visible = True
	cdSig.Initialize2(0xFFD3D3D3,0,0,Colors.Transparent)
	
	SignaturePad.Background = cdSig
	SignaturePad.clear
	SignaturePad.StrokeWidth = 15
	SignaturePad.Visible = True
	imgSignature.Bitmap = Null
	SignaturePad.Capture(True)
	HasSign = False
End Sub

Private Sub ValidateEntries () As Boolean
	Dim bRetVal As Boolean
	bRetVal =False
	
	Try
		If GlobalVar.SF.Len(cboAcctClass.SelectedItem) <= 0 Then
			bRetVal = False
		End If
		If GlobalVar.SF.Len(cboSubClass.SelectedItem) <= 0 Then
			bRetVal = False
		End If
		If GlobalVar.SF.Len(cboConType.SelectedItem) <= 0 Then
			bRetVal = False
		End If
		bRetVal = True
	Catch
		Log(LastException)
		bRetVal = False
	End Try
	Return bRetVal
End Sub

Private Sub UpdateJO (iJOID As Int) 
	Dim sRemarks As String
	Dim sAcctClass As String
	Dim sSubClass As String
	Dim sConType As String
	Dim iConType As Int

	Dim lngDateTime As Long
	Dim sDatePosted As String
	Dim sAccomplishedBy As String
	Dim sLocation As String

	sAcctClass = cboAcctClass.SelectedItem
	sSubClass = cboSubClass.SelectedItem
	sConType = cboConType.SelectedItem
	iConType = DBaseFunctions.GetIDByCode("id", "constant_con_types","ConTypeDesc",sConType)
	
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
						  "SET AcctClass = ?, AcctSubClass = ?, ConType = ?, JOStatus = ? , DateFinished = ?, AccomplishedBy = ?, SigFileName = ?, PostedAt = ?, PostedOn = ? " & _
						  "WHERE JOID = " & iJOID
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(sAcctClass, sSubClass, sConType, 3, txtDateTimeFinished.Text, sAccomplishedBy, SigFolderName & "/" & SigFilename, sDatePosted, sLocation))
		
		'Insert to SAS Findings Table
		Starter.strCriteria = "INSERT INTO tblJOSASFindings VALUES (?, ?, ?, ?, ?)"
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array(GlobalVar.SelectedJOID, sAcctClass, sSubClass, iConType, sRemarks))
		
		'Insert to JO Water Loss Table
		Starter.strCriteria = "INSERT INTO JOWaterLoss VALUES (" & Null & ", ?, ?, ?, ?, ?, ?, ?)"
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array(GlobalVar.SelectedJOID, $"SAS"$, Null, Null, $"0"$, $"0"$, $"0"$))

		Starter.DBCon.TransactionSuccessful
		DispInfoMsg($"JO ACCOMPLISHED"$,$"JO has been successfully accomplished."$)

	Catch
		Log(LastException.Message)
	End Try
	Starter.DBCon.EndTransaction
End Sub



Sub btnOk_Click
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
		
	If Not(MiscFunctions.IsValidDate(txtDateTimeFinished.Text)) Or	GlobalVar.SF.Len(GlobalVar.SF.Trim(txtDateTimeFinished.Text)) = 0 Then
		RequiredMsgBox($"ERROR"$, $"Invalid date finished!"$)
		txtDateTimeFinished.RequestFocus
		Return
	End If
	ConfirmJOAccomplishment
End Sub

Sub btnClear_Click
	pnlSignature.Visible = True
	pnlConfirmSig.Visible = False
	SignaturePad.clear
	HasSign = False
	SignaturePad.Visible = True
	SignaturePad.StrokeWidth = 15
	imgSignature.Bitmap = Null
	SignaturePad.Capture(True)
	
	LogColor(spnPlumbers.SelectedItemsString, Colors.Magenta)
End Sub

Sub btnCancel_Click
	pnlSignature.Visible = False
	pnlConfirmSig.Visible = False
End Sub

Sub SignaturePad_onSigned(sign As Object)
'	SignaturePad.Visible = False
	eSig = sign
	HasSign = True
End Sub

Sub pnlSignature_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Sub pnlConfirmSig_Touch (Action As Int, X As Float, Y As Float)
	
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

	AddPlumbers
End Sub

Sub spnPlumbers_onItemSelected(position As Int, isChecked As Boolean, item As String)
	
End Sub

Private Sub AddPlumbers
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
			.SetTitleTypeface(Font) _
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

Private Sub DispInformationMsg_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
			Activity.Finish
		Case mDialog.ACTION_NEGATIVE
	End Select
End Sub

#End Region


'GPS/FLP
'Private Sub flp_ConnectionSuccess
'	Log("Connected to location provider")
'	Dim Loc1 As Location
'	Loc1.Initialize
'	GlobalVar.Lat = $"$1.4{Loc1.Latitude}"$
'	GlobalVar.Lon = $"$1.4{Loc1.Longitude}"$
'	LogColor($"Latitude is "$ & GlobalVar.Lat & " " & $"Longitude is "$ & GlobalVar.Lon, Colors.Yellow)
'
'	Dim LocationRequest1 As LocationRequest
'	LocationRequest1.Initialize
'	LocationRequest1.SetInterval(10)	'	1000 milliseconds
'	LocationRequest1.SetPriority(LocationRequest1.Priority.PRIORITY_HIGH_ACCURACY)
'	LocationRequest1.SetSmallestDisplacement(1)	'	1 meter
'	flp.RequestLocationUpdates(LocationRequest1)
'End Sub
'
'Private Sub flp_ConnectionFailed(ConnectionResult1 As Int)
'	Log("Failed to connect to location provider")
'	Select ConnectionResult1
'		Case flp.ConnectionResult.NETWORK_ERROR
'			'	a network error has occurred, this is likely to be a recoverable error
'			'	so try to connect again
'			flp.Connect
'		Case Else
'			'	TODO handle other errors
'	End Select
'End Sub
'
'Sub flp_ConnectionSuspended(SuspendedCause1 As Int)
'	Log("FusedLocationProvider1_ConnectionSuspended")
'	
'	'	the FusedLocationProvider SuspendedCause object contains the various SuspendedCause constants
'	
'	Select SuspendedCause1
'		Case flp.SuspendedCause.CAUSE_NETWORK_LOST
'			'	TODO take action
'		Case flp.SuspendedCause.CAUSE_SERVICE_DISCONNECTED
'			'	TODO take action
'	End Select
'End Sub
'
'Private Sub flp_LocationChanged (Location1 As Location)
'	GlobalVar.Lat = $"$1.4{Location1.Latitude}"$
'	GlobalVar.Lon = $"$1.4{Location1.Longitude}"$
'End Sub
'
'
'Sub SetState (msg As String)
'	Log("State: " & msg)
'End Sub
'
'Private Sub CheckLocationSettingStatus As ResumableSub
'	Dim f As LocationSettingsRequestBuilder
'	f.Initialize
'	f.AddLocationRequest(CreateLocationRequest)
'	flp.CheckLocationSettings(f.Build)
'	Wait For flp_LocationSettingsChecked(LocationSettingsResult1 As LocationSettingsResult)
'	Return LocationSettingsResult1
'End Sub
'
'Private Sub StartLocationUpdates
'	flp.RequestLocationUpdates(CreateLocationRequest)
'End Sub
'
'Private Sub CreateLocationRequest As LocationRequest
'	Dim lr As LocationRequest
'	lr.Initialize
'	lr.SetSmallestDisplacement(100)   '<-------------- add this line
'	lr.SetInterval(1)
'	lr.SetFastestInterval(lr.GetInterval / 2)
'	lr.SetPriority(lr.Priority.PRIORITY_HIGH_ACCURACY)
'	Return lr
'End Sub
'
'Sub SettingsAreGood
'	SetState("Location enabled - waiting for updates")
'	StartLocationUpdates
'End Sub
'
'Private Sub GetLastLocation
'	Dim LastLocation As Location = flp.GetLastKnownLocation
'	If LastLocation <> Null Then
'		Dim lat As Double = LastLocation.Latitude
'		Dim lng As Double = LastLocation.Longitude
'		GlobalVar.Lat = lat
'		GlobalVar.Lon = lng
'	End If
'	
'	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
'	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)
'End Sub
