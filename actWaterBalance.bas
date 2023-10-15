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
	Private CD, CDtxtBox As ColorDrawable

	Private vibration As B4Avibrate
	Private snack As DSSnackbar
	Private cdReading As ColorDrawable

	Private btnSave As ACButton

	Private cboPSIPoint As ACSpinner
	Private lblCode As Label
	Private lblAddress As Label
	Private txtPSIRdg As EditText
	Private txtRemarks As EditText
	Private txtLocation As EditText
	
	Private ToastMsg As BCToast
	Private kBoard As IME
	
	Private PointNo As B4XDialog
	Private sPointNo As String
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("WaterBalance")

	GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"WATER BALANCE"$).PopAll
	GlobalVar.CSSubTitle.Initialize.Size(12).Append($"PUMP : "$ & GlobalVar.PumpHouseCode).PopAll

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