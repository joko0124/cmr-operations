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
	Dim Alert As AX_CustomAlertDialog
	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("JOList")
	
	GlobalVar.SelectedJODesc = DBaseFunctions.GetJODesc(GlobalVar.SelectedJOCatCode)
	
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

	If FirstTime Then
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
End Sub

Sub Activity_Pause (UserClosed As Boolean)
End Sub

#End Region

#Region Toolbar
Sub Activity_CreateMenu(Menu As ACMenu)
End Sub

Private Sub CreateSubMenus
End Sub

Sub ToolBar_NavigationItemClick 'Toolbar Arrow
	Activity.Finish
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
	Select Item.Id
		Case 1
	End Select
End Sub

Sub FilterBy_ItemClicked (Item As ACMenuItem)
End Sub

#End Region

#Region JO Information
Private Sub FillJOList (sSelectedJOCat As String)
	Dim SenderFilter As Object


	Try
		Starter.strCriteria = "SELECT * FROM tblJOs " & _
						  	  "WHERE JOCatCode = '" & sSelectedJOCat & "' " & _
							  "ORDER BY JOCreatedAt ASC"
		LogColor(Starter.strCriteria, Colors.Yellow)

		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		If Success Then
		Else
			Log(LastException)
		End If
	Catch
		Log(LastException)
	End Try

End Sub
#End Region

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
			.SetTitleTypeface(Font) _
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
	Alert.Initialize.Dismiss(Dialog)
End Sub

Private Sub JO_Started_OnPositiveClicked (View As View, Dialog As Object)
'	ToastMessageShow("Positive Button Clicked!",False)

	LogColor(GlobalVar.SelectedJOID, Colors.Cyan)

	If StartJO(GlobalVar.SelectedJOID) = True Then
		Alert.Initialize.Dismiss(Dialog)
		FillJOList(GlobalVar.SelectedJOCatCode)
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