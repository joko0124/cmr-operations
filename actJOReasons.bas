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
	Private lblAppNo As Label
	Private lblCustAddress As Label
	Private lblCustName As Label
	Private lblStatus As Label
	Private lblJONum As Label
'	Private lblJOType As Label
	Private pnlJOInfo As Panel
	
	Dim cdSearch As ColorDrawable
	Private txtSearch As EditText
	Private PopSubMenu As ACPopupMenu
	Type JOReasonDetails (JOID As Int, JONum As String, JOCatCode As String, JODesc As String, JOStatus As Int, RefID As Int, RefNo As String, _
				   CustName As String, CustAdd As String, AcctClass As String, AcctSubClass As String)
	
	Private JOCounts As Int
	Private Limit As Int = 2000
	Private IMEKeyboard As IME

	Private lblRefTitle As Label
	Private pnlStatus As Panel
	Private lblCount As Label
	
	Private SelectedPosition As Int = -1 'SelectorDialog2 Selected position
	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")

	
	'/////////// Accomplished JO Details
	Private pnlSASDetails As Panel
	Private btnSASEdit As ACButton
	Private btnSASOK As ACButton
	Private lbllSASAppNo As Label
	Private lblSASAcctClass As Label
	Private lblSASConType As Label
	Private lblSASCustAddress As Label
	Private lblSASCustName As Label
	Private lblSASFindings As Label
	Private lblSASJONo As Label
	
	Private lblSASDateAccomplished As Label
	Private lblSASDatesStart As Label
	
	'DialogButtons
	Dim cdDialogEdit, cdDialogCancel, cdDialogOk As ColorDrawable
	Dim Alert As AX_CustomAlertDialog
	
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("JOList")
	
	GlobalVar.CSTitle.Initialize.Size(15).Bold.Append(GlobalVar.SelectedJODesc & $" - Job Order(s)"$).PopAll
	GlobalVar.CSSubTitle.Initialize.Size(12).Append($"List of Job Orders"$).PopAll
	
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
	txtSearch.Background = cdSearch

	If FirstTime Then
		FillJOList(GlobalVar.SelectedJOCatCode, GlobalVar.SelectedJODesc)
		HideDialogs
	End If
	
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
	FillJOList(GlobalVar.SelectedJOCatCode, GlobalVar.SelectedJODesc)
	HideDialogs
End Sub

Sub Activity_Pause (UserClosed As Boolean)
End Sub

#End Region

#Region Toolbar
Sub Activity_CreateMenu(Menu As ACMenu)
	Dim Item As ACMenuItem
	
	Menu.Clear
	Menu.Add2(1, 1, "Filter by",xmlIcon.GetDrawable("baseline_filter_alt_white_24dp")).ShowAsAction = Item.SHOW_AS_ACTION_IF_ROOM
'	Menu.Add2(2, 2, "Settings",xmlIcon.GetDrawable("ic_settings_white_24dp")).ShowAsAction = Item.SHOW_AS_ACTION_ALWAYS
	CreateSubMenus
End Sub

Private Sub CreateSubMenus
	Dim csAll, csPending, csAccomp, csOnGoing, csCan As CSBuilder
	
	csAll.Initialize.Color(Colors.White).Append($"All"$).PopAll
	csPending.Initialize.Color(Colors.White).Append($"Pending"$).PopAll
	csOnGoing.Initialize.Color(Colors.White).Append($"On-Going"$).PopAll
	csAccomp.Initialize.Color(Colors.White).Append($"Accomplished"$).PopAll
	csCan.Initialize.Color(Colors.White).Append($"Cancelled"$).PopAll
	
	PopSubMenu.Initialize("FilterBy", ToolBar.GetView(3))
	PopSubMenu.AddMenuItem(0,csAll,xmlIcon.GetDrawable("ic_select_all_white_24dp"))
	PopSubMenu.AddMenuItem(1,csPending,xmlIcon.GetDrawable("baseline_pending_actions_white_24dp"))
	PopSubMenu.AddMenuItem(2,csOnGoing,xmlIcon.GetDrawable("baseline_engineering_white_24dp"))
	PopSubMenu.AddMenuItem(3,csAccomp,xmlIcon.GetDrawable("baseline_assignment_turned_in_white_24dp"))
	PopSubMenu.AddMenuItem(4,csCan,xmlIcon.GetDrawable("baseline_cancel_presentation_white_24dp"))
End Sub

Sub ToolBar_NavigationItemClick 'Toolbar Arrow
	IMEKeyboard.HideKeyboard
	Activity.Finish
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
	Select Item.Id
		Case 1
			PopSubMenu.Show
	End Select
End Sub

Sub FilterBy_ItemClicked (Item As ACMenuItem)
	Log("Popupmenu Item clicked: " & Item.Id & " - " & Item.Title)
	FilterJoList(GlobalVar.SelectedJOCatCode, GlobalVar.SelectedJODesc, Item.Id)
End Sub

#End Region

#Region JO Lists
Private Sub FillJOList (sSelectedJOCat As String, sSelectedJODesc As String)
	Dim SenderFilter As Object
	Try
		Starter.strCriteria = "SELECT * FROM tblJOs " & _
						  "WHERE JOCatCode = '" & sSelectedJOCat & "' " & _
						  "AND JoDesc = '" & sSelectedJODesc & "' " & _
						  "ORDER BY JOCreatedAt ASC"
		LogColor(Starter.strCriteria, Colors.Yellow)

		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		If Success Then
			Dim StartTime As Long = DateTime.Now
			clvJOs.Clear
			Do While RS.NextRow
				Dim JORec As JOReasonDetails
				JORec.Initialize
				JORec.JOID = RS.GetInt("JOID")
				JORec.JONum = GlobalVar.SF.Upper(RS.GetString("JONo"))
				JORec.JOCatCode = GlobalVar.SF.Upper(RS.GetString("JOCatCode"))
				JORec.RefID= RS.GetInt("RefID")
				JORec.RefNo= GlobalVar.SF.Upper(RS.GetString("RefNo"))
				JORec.CustName = GlobalVar.SF.Upper(RS.GetString("CustName"))
				JORec.CustAdd = GlobalVar.SF.Upper(RS.GetString("CustAddress"))
				JORec.AcctClass = GlobalVar.SF.Upper(RS.GetString("AcctClass"))
				JORec.AcctSubClass = GlobalVar.SF.Upper(RS.GetString("AcctSubClass"))
				JORec.JOStatus = RS.GetInt("JOStatus")
				
				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 10dip, 0, clvJOs.AsView.Width , 150dip) 'Panel height + 4 for drop shadow
				clvJOs.Add(Pnl, JORec)
			Loop
			lblCount.Text = RS.RowCount & $" Record(s) Found"$
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If

		Log($"List of Job Order Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvJOs.Size} Flow Meter Reading Records"$)
	Catch
		Log(LastException)
	End Try

End Sub

Private Sub FilterJoList (sSelectedJOCat As String, sSelectedJODesc As String, iStatus As Int)
	Dim SenderFilter As Object

	clvJOs.Clear
	Try

		If iStatus = 0 Then
			clvJOs.Clear
			clvJOs.Refresh
			FillJOList(sSelectedJOCat, sSelectedJODesc)
			Return
		End If
		Try
			Starter.strCriteria = "SELECT * FROM tblJOs " & _
				"WHERE JOCatCode = '" & sSelectedJOCat & "' " & _
				"AND JOStatus = " & iStatus & " " & _
				"ORDER BY JOCreatedAt ASC"
		Catch
			Log(LastException)
		End Try


		LogColor(Starter.strCriteria, Colors.Yellow)
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		If Success Then
			Dim StartTime As Long = DateTime.Now
			Do While RS.NextRow
				Dim JORec As JOReasonDetails
				JORec.Initialize
				JORec.JOID = RS.GetInt("JOID")
				JORec.JONum = GlobalVar.SF.Upper(RS.GetString("JONo"))
				JORec.JOCatCode = GlobalVar.SF.Upper(RS.GetString("JOCatCode"))
				JORec.RefID= RS.GetInt("RefID")
				JORec.RefNo= GlobalVar.SF.Upper(RS.GetString("RefNo"))
				JORec.CustName = GlobalVar.SF.Upper(RS.GetString("CustName"))
				JORec.CustAdd = GlobalVar.SF.Upper(RS.GetString("CustAddress"))
				JORec.AcctClass = GlobalVar.SF.Upper(RS.GetString("AcctClass"))
				JORec.AcctSubClass = GlobalVar.SF.Upper(RS.GetString("AcctSubClass"))
				JORec.JOStatus = RS.GetInt("JOStatus")
				
				'Add to List
				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 10dip, 0, clvJOs.AsView.Width , 150dip) 'Panel height + 4 for drop shadow
				clvJOs.Add(Pnl, JORec)
			Loop
			lblCount.Text = RS.RowCount & $" Record(s) Found"$
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If

		Log($"List of Job Order Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvJOs.Size} SAS JO Records"$)
	Catch
		Log(LastException)
	End Try
End Sub

#End Region

Sub clvJOs_ItemClick (Index As Int, Value As Object)
	Dim JORec As JOReasonDetails = Value
	LogColor(Value, Colors.Yellow)
	LogColor(JORec.JOID, Colors.Red)
	LogColor(JORec.JONum, Colors.Magenta)
	LogColor(JORec.JOStatus, Colors.Red)
	
	GlobalVar.SelectedJOID = JORec.JOID
	Select JORec.JOStatus
		Case 1	'PENDING
			vibration.vibrateOnce(2000)
			ConfirmStartJO(JORec.JOID)
		Case 2	'STARTED
			Select JORec.JOCatCode
				Case "MC"
					StartActivity(actMCJOFindings)
			End Select
		Case 3	'ACCOMPLISHED
			Select JORec.JOCatCode
				Case "SAS"
					StartActivity(actJOAccomplishedSAS)
				Case "NC"
					StartActivity(actNCJOFindings)
				Case "DC-CR"
					StartActivity(actDCCRJOFindings)
				Case "DC-DA"
					StartActivity(actDCDAJOFindings)
				Case "RC"
					StartActivity(actRCJOFindings)
				Case "CM"
					StartActivity(actCMJOFindings)
				Case Else
					ShowSASJODetails(JORec.JOID)
			End Select
		Case 4	'CANCELLED
		Case 5	'UPLOADED
	End Select

End Sub

Sub clvJOs_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 15 'List size
	clvJOs.Refresh
	
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvJOs.Size - 1)
		Dim Pnl As B4XView = clvJOs.GetPanel(i)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
				Dim JORec As JOReasonDetails = clvJOs.GetValue(i)
				Pnl.LoadLayout("JOInfo")
				lblRefTitle.Text = $"Account No.: "$
				lblJONum.Text = JORec.JONum
				lblAppNo.Text = JORec.RefNo
				lblCustName.Text = JORec.CustName
				lblCustAddress.Text = JORec.CustAdd
				lblCustAddress.Ellipsize = "END"

				If JORec.JOStatus = 1 Then
					lblStatus.Color = GlobalVar.GrayColor
					lblStatus.Text = "PENDING"
				Else If JORec.JOStatus = 2 Then
					lblStatus.Color = GlobalVar.YellowColor
					lblStatus.Text = "ON GOING"
				Else If JORec.JOStatus = 3 Then
					lblStatus.Color = GlobalVar.GreenColor
					lblStatus.Text = "ACCOMPLISHED"
				Else If JORec.JOStatus = 4 Then
					lblStatus.Color= GlobalVar.RedColor
					lblStatus.Text = "CANCELLED"
				Else If JORec.JOStatus = 5 Then
					lblStatus.Color= GlobalVar.BlueColor
					lblStatus.Text = "UPLOADED"
				End If
			End If
		Else 'Not visible
			If Pnl.NumberOfViews > 0 Then
				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
			End If
		End If
	Next
End Sub

Sub txtSearch_TextChanged (Old As String, New As String)
	If New.Length = 1 Or txtSearch.Text.Length = 2 Then Return
	clvJOs.Clear
	Sleep(0)

	Dim SenderFilter As Object
	If New.Length = 0  Then
		JOCounts = Starter.DBCon.ExecQuerySingleResult("SELECT COUNT(*) FROM `tblJOs`;")
		Starter.strCriteria = "SELECT * FROM tblJOs " & _
						  	  "WHERE JOCatCode = '" & GlobalVar.SelectedJOCatCode & "' " & _
							  "ORDER BY JOCreatedAt ASC"
		LogColor(Starter.strCriteria, Colors.Yellow)

		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
'		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", $"SELECT * FROM `tblJOs` ORDER BY `JONo` ASC LIMIT ${Limit};"$, Null) 'I NO NOT RECOMMEND that you load the whole database
	Else
		JOCounts = 0
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", $"SELECT * FROM `tblJOs` WHERE `CustName` Like '%${New}%' ORDER BY `JONo` ASC LIMIT 500;"$, Null) 'Limited for slower devices
	End If

	Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
	If Success Then
		clvJOs.Clear
		clvJOs.Refresh
		Dim StartTime As Long = DateTime.Now
		Do While RS.NextRow
			Dim JORec As JOReasonDetails
			JORec.Initialize
			JORec.JOID = RS.GetInt("JOID")
			JORec.JONum = GlobalVar.SF.Upper(RS.GetString("JONo"))
			JORec.JOCatCode = GlobalVar.SF.Upper(RS.GetString("JOCatCode"))
			JORec.RefID= RS.GetInt("RefID")
			JORec.RefNo= GlobalVar.SF.Upper(RS.GetString("RefNo"))
			JORec.CustName = GlobalVar.SF.Upper(RS.GetString("CustName"))
			JORec.CustAdd = GlobalVar.SF.Upper(RS.GetString("CustAddress"))
			JORec.AcctClass = GlobalVar.SF.Upper(RS.GetString("AcctClass"))
			JORec.AcctSubClass = GlobalVar.SF.Upper(RS.GetString("AcctSubClass"))
			JORec.JOStatus = RS.GetInt("JOStatus")
			Dim Pnl As B4XView = xui.CreatePanel("")
			Pnl.SetLayoutAnimated(0, 10dip, 0, clvJOs.AsView.Width , 150dip) 'Panel height + 4 for drop shadow
			clvJOs.Add(Pnl, JORec)
		Loop
		RS.Close
		
		Log($"List population time = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 1, 2, 2, False)} seconds to populate ${clvJOs.Size} airport names"$)
	Else
		Log(LastException)
	End If
	
End Sub

Sub txtSearch_EnterPressed
	
End Sub

Sub ShowJODetails (iID As Int, sCatCode As String)
	Dim csTitle As CSBuilder
	Dim SenderFilter As Object
	Dim sJONo, sJOCatCode, sJODesc, sRefNo, sCustName, sCustAdd, sAcctClass, sConType As String
	Dim sDateCreated, sDateStart, sDateFinished As String
	

	sJONo = ""
	sJODesc = ""
	sRefNo = ""
	sCustName = ""
	sCustAdd = ""
	sAcctClass = ""
	sDateCreated = ""
	sDateStart = ""
	sDateFinished = ""
	sConType = ""

	GlobalVar.TranHeaderID = DBaseFunctions.GetHeaderID(GlobalVar.PumpHouseID, GlobalVar.TranDate)
	Try
		Starter.strCriteria = "SELECT JO.JONo, JO.JoDesc, " & _
						  "JO.RefNo AS App_AcctNo, JO.CustName, JO.CustAddress, " & _
						  "JO.AcctClass, JO.AcctSubClass, JO.ConType, " & _
						  "JO.JOCreatedAt, JO.DateStarted, JO.DateFinished " & _
						  "FROM tblJOs AS JO " & _
						  "WHERE JO.JOID = " & iID
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			RS.Position = 0
			sJONo = RS.GetString("JONo")
			sJODesc = RS.GetString("JoDesc")
			sRefNo = RS.GetString("App_AcctNo")
			sCustName = RS.GetString("CustName")
			sCustAdd = RS.GetString("CustAddress")
			sAcctClass = RS.GetString("AcctClass") & "-" & RS.GetString("AcctSubClass")
			sConType = RS.GetString("ConType")
			sDateCreated = RS.GetString("JOCreatedAt")
			sDateStart = RS.GetString("DateStarted")
			sDateFinished = RS.GetString("DateFinished")
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
	
	If sCatCode = "SAS" Then
		sJOCatCode = "Application No. :"
	Else
		sJOCatCode = "Account No. :"
	End If
	
	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.BlueColor).Append(sCatCode & $" "$ & $"JO DETAILS"$).PopAll

	If sCatCode = "SAS" Then
		MatDialogBuilder.Initialize("JODetails")
		MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.PosColor)
		MatDialogBuilder.NeutralText("EDIT").NeutralColor(GlobalVar.RedColor)
		MatDialogBuilder.Title(csTitle)
		MatDialogBuilder.Content($"  JO No. : ${sJONo}
		${sJODesc}
		Application No. : ${sRefNo}
		Customer Name : ${sCustName}
		Address : ${sCustAdd}
		F I N D I N G S
		
		Account Class: ${sAcctClass}
		Connection Type: ${sConType}"$)
		MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
		MatDialogBuilder.CanceledOnTouchOutside(False)
		MatDialogBuilder.Cancelable(True)
		MatDialogBuilder.Show
	Else
	End If
End Sub
	
Sub ShowSASJODetails (iID As Int)
	
	Dim csTitle As CSBuilder
	Dim SenderFilter As Object
	Dim sJONo, sJOCatCode, sJODesc, sRefNo, sCustName, sCustAdd, sAcctClass, sConType As String
	Dim sDateCreated, sDateStart, sDateFinished As String
	

	sJONo = ""
	sJODesc = ""
	sRefNo = ""
	sCustName = ""
	sCustAdd = ""
	sAcctClass = ""
	sDateCreated = ""
	sDateStart = ""
	sDateFinished = ""
	sConType = ""

	Try
		Starter.strCriteria = "SELECT JO.JONo, JO.JoDesc, " & _
						  "JO.RefNo AS App_AcctNo, JO.CustName, JO.CustAddress, " & _
						  "JO.AcctClass, JO.AcctSubClass, JO.ConType, " & _
						  "JO.JOCreatedAt, JO.DateStarted, JO.DateFinished " & _
						  "FROM tblJOs AS JO " & _
						  "WHERE JO.JOID = " & iID
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			RS.Position = 0
			sJONo = RS.GetString("JONo")
			sJODesc = RS.GetString("JoDesc")
			sRefNo = RS.GetString("App_AcctNo")
			sCustName = RS.GetString("CustName")
			sCustAdd = RS.GetString("CustAddress")
			sAcctClass = RS.GetString("AcctClass") & "-" & RS.GetString("AcctSubClass")
			sConType = RS.GetString("ConType")
			sDateCreated = RS.GetString("JOCreatedAt")
			sDateStart = RS.GetString("DateStarted")
			sDateFinished = RS.GetString("DateFinished")
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If
		pnlSASDetails.Visible = True
		lblSASJONo.Text = sJONo
		lbllSASAppNo.Text = sRefNo
		lblSASCustName.Text = sCustName
		lblSASCustAddress.Text = sCustAdd
	
		lblSASAcctClass.Text = sAcctClass
		lblSASConType.Text = sConType
		lblSASDatesStart.Text = sDateStart
		lblSASDateAccomplished.Text = sDateFinished
	
		cdDialogEdit.Initialize2(GlobalVar.YellowColor, 10, 0, Colors.Transparent)
		btnSASEdit.Background = cdDialogEdit
'	btnSASEdit.Text = Chr(0xE254) & $" Edit"$
		btnSASEdit.Text = Chr(0xE8AD) & $" Print JO"$

		cdDialogOk.Initialize2(GlobalVar.GreenColor, 10, 0, Colors.Transparent)
		btnSASOK.Background = cdDialogOk
		btnSASOK.Text = Chr(0xE5CA) & $" Ok"$
	Catch
		Log(LastException)
	End Try
End Sub


Sub pnlSASDetails_Touch (Action As Int, X As Float, Y As Float)
	
End Sub

Sub pnlSASDetails_Click
	
End Sub

Sub btnSASOK_Click
	HideDialogs
End Sub

Sub btnEdit_Click
	
End Sub

Private Sub ConfirmStartJO(iJOID As Int)
	Dim Alert As AX_CustomAlertDialog

	Alert.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(Alert.STYLE_DIALOGUE) _
			.SetCancelable(False) _
			.SetTitle("START JO") _
			.SetTitleColor(GlobalVar.BlueColor) _
			.SetTitleTypeface(FontBold) _
			.SetMessage($"You are about to Start this JO,"$ & CRLF & $"JO Date & Time Started will be today."$ & CRLF & CRLF & $"Do you want to START this JO Now?"$) _
			.SetPositiveText("Confirm") _
			.SetPositiveColor(GlobalVar.PosColor) _
			.SetPositiveTypeface(FontBold) _
			.SetNegativeText("Cancel") _
			.SetNegativeColor(GlobalVar.NegColor) _
			.SetNegativeTypeface(Font) _
			.SetMessageTypeface(Font) _
			.SetOnPositiveClicked("JO_Started") _	'listeners
			.SetOnNegativeClicked("JO_Started") _
			.SetOnViewBinder("JOFontSizeBinder") 	'listeners
	Alert.SetDialogBackground(MyFunctions.myCD)
	Alert.Build.Show

End Sub

'Listeners
Private Sub JO_Started_OnNegativeClicked (View As View, Dialog As Object)
'	ToastMessageShow("Negative Button Clicked!",False)
	vibration.vibrateCancel
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub JO_Started_OnPositiveClicked (View As View, Dialog As Object)
'	ToastMessageShow("Positive Button Clicked!",False)
	vibration.vibrateCancel
	LogColor(GlobalVar.SelectedJOID, Colors.Cyan)

	If StartJO(GlobalVar.SelectedJOID) = True Then
		Alert.Initialize.Dismiss(Dialog)
		FillJOList(GlobalVar.SelectedJOCatCode, GlobalVar.SelectedJODesc)
		DispInfoMsg($"Selected JO Started..."$, $"JO UPDATED"$)
	Else
		Return
	End If

End Sub

Private Sub JOFontSizeBinder_OnBindView (View As View, ViewType As Int)
	Dim Alert As AX_CustomAlertDialog
	Alert.Initialize
	If ViewType = Alert.VIEW_TITLE Then ' Title
		Dim lbl As Label = View
'		lbl.TextSize = 30
'		lbl.SetTextColorAnimated(2000,Colors.Magenta)
		
		
		Dim CS As CSBuilder
'		CS.Initialize.Typeface(Font).Append(lbl.Text & " ").Pop
'		CS.Typeface(Typeface.MATERIALICONS).Size(36).Color(Colors.Red).Append(Chr(0xE190))

		CS.Initialize.Typeface(Typeface.DEFAULT_BOLD).Typeface(Typeface.MATERIALICONS).Size(26).Color(Colors.Red).Append(Chr(0xE066) & " ")
		CS.Typeface(Font).Size(22).Append(lbl.Text).Pop

		lbl.Text = CS.PopAll
	End If
	If ViewType = Alert.VIEW_MESSAGE Then
		Dim lbl As Label = View
		lbl.TextSize = 16
		lbl.TextColor = Colors.Gray
	End If
	
	If ViewType = Alert.VIEW_NEGATIVE Or ViewType = Alert.VIEW_POSITIVE Then
		Dim lbl As Label = View
		lbl.TextSize = 18
	End If
	
End Sub


Private Sub DispInfoMsg(sMsg As String, sTitle As String)
	
	Dim InfoMsg As AX_CustomAlertDialog

	InfoMsg.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(InfoMsg.STYLE_DIALOGUE) _
			.SetCancelable(False) _
			.SetTitle(sTitle) _
			.SetMessage(sMsg) _
			.SetPositiveText("OK") _
			.SetPositiveColor(GlobalVar.PosColor) _
			.SetPositiveTypeface(FontBold) _
			.SetTitleTypeface(Font) _
			.SetMessageTypeface(Font) _
			.SetOnPositiveClicked("MessageBox") _	'listeners
			.SetOnViewBinder("FontSizeBinder") 'listeners
		
	InfoMsg.SetDialogBackground(MyFunctions.myCD)
	InfoMsg.Build.Show
End Sub

Private Sub MessageBox_OnPositiveClicked (View As View, Dialog As Object)
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub StartJO (iJOID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim lngDateTime As Long
	Dim sDateStart As String
	
	bRetVal = False
	lngDateTime = DateTime.Now
	DateTime.TimeFormat = "hh:mm:ss a"
	DateTime.DateFormat = "yyyy-MM-dd"
	sDateStart = DateTime.Date(lngDateTime) & $" "$ & DateTime.Time(lngDateTime)
	
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE tblJOs " & _
						  "SET JOStatus = ?, DateStarted = ? " & _
						  "WHERE JOID = " & iJOID
		
		LogColor(Starter.strCriteria,Colors.Yellow)
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String("2", sDateStart))
		Starter.DBCon.TransactionSuccessful

		bRetVal = True
	Catch
		bRetVal = False
		Log(LastException.Message)
	End Try
	Starter.DBCon.EndTransaction
	Return bRetVal
End Sub

'Dialogs
Private Sub HideDialogs
	pnlSASDetails.Visible = False
End Sub

