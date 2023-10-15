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
	Private lblAcctNo As B4XView
	Private lblCustAddress As B4XView
	Private lblCustName As B4XView
	Private lblJONo As B4XView
	Private lblJOType As B4XView
	Private pnlJO As B4XView
	
	Dim cdSearch As ColorDrawable
	Private txtSearch As EditText
	Private PopSubMenu As ACPopupMenu
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
	Dim Item As ACMenuItem
	
	Menu.Clear
	Menu.Add2(1, 1, "Filter by",xmlIcon.GetDrawable("baseline_filter_alt_white_24dp")).ShowAsAction = Item.SHOW_AS_ACTION_IF_ROOM
'	Menu.Add2(2, 2, "Settings",xmlIcon.GetDrawable("ic_settings_white_24dp")).ShowAsAction = Item.SHOW_AS_ACTION_ALWAYS
	CreateSubMenus
End Sub

Private Sub CreateSubMenus
	Dim csAll, csPending, csAccomp, csCan As CSBuilder
	
	csAll.Initialize.Color(Colors.White).Append($"All"$).PopAll
	csPending.Initialize.Color(Colors.White).Append($"Pending"$).PopAll
	csAccomp.Initialize.Color(Colors.White).Append($"Accomplished"$).PopAll
	csCan.Initialize.Color(Colors.White).Append($"Cancelled"$).PopAll
	
	PopSubMenu.Initialize("FilterBy", ToolBar.GetView(3))
	PopSubMenu.AddMenuItem(0,csAll,xmlIcon.GetDrawable("ic_select_all_white_24dp"))
	PopSubMenu.AddMenuItem(1,csPending,xmlIcon.GetDrawable("baseline_pending_actions_white_24dp"))
	PopSubMenu.AddMenuItem(2,csAccomp,xmlIcon.GetDrawable("baseline_assignment_turned_in_white_24dp"))
	PopSubMenu.AddMenuItem(3,csCan,xmlIcon.GetDrawable("baseline_cancel_presentation_white_24dp"))
End Sub

Sub ToolBar_NavigationItemClick 'Toolbar Arrow
	Activity.Finish
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
	Select Item.Id
		Case 1
			PopSubMenu.Show
	End Select
End Sub

#End Region