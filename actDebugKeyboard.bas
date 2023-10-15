B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=10
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Private xui As XUI
	Dim TYPE_TEXT_FLAG_NO_SUGGESTIONS  As Int = 0x80000

End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.

	Private txtFMRdg As EditText
	Private cKeyboard As CustomKeyboard
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("DebugKeyboard")
	txtFMRdg.InputType = Bit.Or(txtFMRdg.InputType,TYPE_TEXT_FLAG_NO_SUGGESTIONS)
	txtFMRdg.SingleLine = True
	txtFMRdg.ForceDoneButton = True
	
	cKeyboard.Initialize("CKB","keyboardview_trans")
	cKeyboard.RegisterEditText(txtFMRdg,"txtFMRdg","num",True)
	cKeyboard.ShowKeyboard(txtFMRdg)

End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub
