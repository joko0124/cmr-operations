B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=10
@EndOfDesignText@
Sub Process_Globals
	
End Sub

Sub Globals
	Private MatDialogBox As MaterialDialogBuilder

End Sub

#Region MsgBoxes
Public Sub ConfirmYN(sMessage As String)
	Dim bytChoice As Byte
	
End Sub

Public Sub DispMsg(sTitle As String, sMsg As String)
	Dim AlertMsg As AX_CustomAlertDialog
	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")

	AlertMsg.Initialize.Create _
			.SetDialogStyleName("MyDialogDisableStatus") _	'Manifest style name
			.SetStyle(AlertMsg.STYLE_DIALOGUE) _
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
	
	AlertMsg.SetDialogBackground(MyFunctions.myCD)
	AlertMsg.Build.Show
End Sub

'Listeners

Private Sub RequiredMsg_OnPositiveClicked (View As View, Dialog As Object)
	Dim AlertMsg As AX_CustomAlertDialog
	AlertMsg.Initialize.Dismiss2
End Sub

Private Sub FontSizeBinder_OnBindView (View As View, ViewType As Int)
	Dim AlertMsg As AX_CustomAlertDialog
	Private Font As Typeface = Typeface.LoadFromAssets("myfont.ttf")
	Private FontBold As Typeface = Typeface.LoadFromAssets("myfont_bold.ttf")

	AlertMsg.Initialize
	If ViewType = AlertMsg.VIEW_TITLE Then ' Title
		Dim lbl As Label = View
		lbl.TextSize = 30
'		lbl.SetTextColorAnimated(2000,Colors.Magenta)
		
		
		Dim CS As CSBuilder
		CS.Initialize.Typeface(Typeface.MATERIALICONS).Size(26).Color(Colors.Red).Append(Chr(0xE88E) & "  ")
		CS.Typeface(Font).Size(24).Append(lbl.Text).Pop

		lbl.Text = CS.PopAll
	End If
End Sub

#End Region

Public Sub IsValidDate(Date As String) As Boolean
	DateTime.DateFormat = "yyyy-MM-dd hh:mm:ss a"
	Try
		DateTime.DateParse(Date)
		Return True
	Catch
		Return False
	End Try
End Sub