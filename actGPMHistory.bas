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
	Dim kboard As IME

	Private pnlPSIDist As B4XView
	Dim theDate As Long
	
	'PSI Dist
	Type GPMRecords (ID As Int, sTrandate As String,iBucketSize As Int, sUOM As String, dResult As Double, sWaterQuality As String)
	Private clvList As CustomListView
	Private MyToast As BCToast
		
	Private lblTestDate As B4XView
	Private lblWaterQuality As B4XView
	Private lblGPMRes As B4XView
	Private btnAddGPM As DSFloatingActionButton
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("GPMHistory")

	GlobalVar.CSTitle.Initialize.Size(15).Bold.Append($"GPM History"$).PopAll
	GlobalVar.CSSubTitle.Initialize.Size(12).Append($"PUMP - "$ & GlobalVar.PumpHouseCode).PopAll
	
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
	
	kboard.Initialize("KeyBoard")
	If FirstTime Then
	End If
'	TabMenu.Initialize(Null,"")
	
	MyToast.Initialize(Activity)
	
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
	GetGPMRec(GlobalVar.PumpHouseID)
End Sub

Sub Activity_Pause (UserClosed As Boolean)
End Sub

#End Region

#Region Toolbar
Sub Activity_CreateMenu(Menu As ACMenu)
'	Dim Item As ACMenuItem
'	Menu.Clear
	'Chr(0xF274)
'	Menu.Add2(1, 1, "Transaction Date",xmlIcon.GetDrawable("ic_date_range_white_24dp")).ShowAsAction = Item.SHOW_AS_ACTION_IF_ROOM
'	Menu.Add2(2, 2, "Settings",xmlIcon.GetDrawable("ic_settings_white_24dp")).ShowAsAction = Item.SHOW_AS_ACTION_ALWAYS
End Sub

Sub ToolBar_NavigationItemClick 'Toolbar Arrow
	Activity.Finish
	kboard.HideKeyboard
End Sub

Sub ToolBar_MenuItemClick (Item As ACMenuItem)'Icon Menus
End Sub

#End Region

#Region GPM
Sub btnAddGPM_Click
	GlobalVar.blnNewGPM = True
	StartActivity(actGPMCalc)
End Sub

Sub GetGPMRec(iPumpID As Int)
	Dim SenderFilter As Object
	clvList.Clear
	Try
		Starter.strCriteria = "SELECT GPMID, TranDate, " & _
							  "BucketSize, UnitOfMeasurement, GPMResult, WaterQuality " & _
							  "FROM tblGPMHistory " & _
							  "WHERE PumpID = " & iPumpID & " " & _
							  "ORDER BY TranDate, GPMID ASC"
							  
		SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
		Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
		If Success Then
			Dim StartTime As Long = DateTime.Now
			Do While RS.NextRow
				Dim GPMR As GPMRecords
				GPMR.Initialize
				GPMR.ID = RS.GetInt("GPMID")
				GPMR.sTrandate = RS.GetString("TranDate")
				GPMR.iBucketSize = RS.GetInt("BucketSize")
				GPMR.sUOM = RS.GetString("UnitOfMeasurement")
				GPMR.dResult = RS.GetDouble("GPMResult")
				GPMR.sWaterQuality = RS.GetString("WaterQuality")

				Dim Pnl As B4XView = xui.CreatePanel("")
				Pnl.SetLayoutAnimated(0, 10dip, 0, clvList.AsView.Width - 10dip, 30dip) 'Panel height + 4 for drop shadow
				clvList.Add(Pnl, GPMR)
			Loop
		Else
			snack.Initialize("", Activity,$""$ & LastException.Message,5000)
			MyFunctions.SetSnackBarTextColor(snack, Colors.White)
			MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
			snack.Show
			Log(LastException)
		End If

		Log($"List of Time Records = ${NumberFormat2((DateTime.Now - StartTime) / 1000, 0, 2, 2, False)} seconds to populate ${clvList.Size} Chlorine Records"$)

	Catch
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End Try
End Sub

Sub clvList_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 15 'List size
	For i = Max(0, FirstIndex - ExtraSize) To Min(LastIndex + ExtraSize, clvList.Size - 1)
		Dim Pnl As B4XView = clvList.GetPanel(i)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			If Pnl.NumberOfViews = 0 Then 'Add each item/layout to the list/main layout
				Dim GPMR As GPMRecords = clvList.GetValue(i)
				Pnl.LoadLayout("ListGPMResults")
				lblTestDate.TextColor = GlobalVar.PriColor
				lblGPMRes.TextColor = GlobalVar.PriColor
				lblWaterQuality.TextColor = GlobalVar.PriColor
				
				lblTestDate.Text = GPMR.sTrandate
				lblGPMRes.Text = GPMR.dResult & $" GPM"$
				lblWaterQuality.Text = GPMR.sWaterQuality
			End If
		Else 'Not visible
			If Pnl.NumberOfViews > 0 Then
				Pnl.RemoveAllViews 'Remove none visable item/layouts from the list/main layout
			End If
		End If
	Next
End Sub

Sub clvList_ItemClick (Index As Int, Value As Object)
	Dim Rec As GPMRecords = Value
	Log(Rec.ID)
	ShowGPMResDetails(Rec.ID)
	GlobalVar.GPMId = Rec.ID
End Sub

Sub ShowGPMResDetails (iID As Int)
	Dim csTitle As CSBuilder
	Dim SenderFilter As Object
	Dim sPCode, sDate, sBucketSize As String
	Dim iTry1, iTry2, iTry3 As String
	Dim sUOM, sWaterQuality, sRem As String
	Dim dRes As Double
	
	Starter.strCriteria = "SELECT Station.PumpHouseCode, GPMHist.TranDate, " & _
						  "GPMHist.BucketSize, GPMHist.UnitOfMeasurement, " & _
						  "GPMHist.Trial1, GPMHist.Trial2, GPMHist.Trial3, " & _
						  "GPMHist.GPMResult, GPMHist.WaterQuality, GPMHist.Remarks " & _
						  "FROM tblGPMHistory AS GPMHist " & _
						  "INNER JOIN tblPumpStation AS Station ON GPMHist.PumpID = Station.StationID " & _
						  "WHERE GPMHist.GPMID = " & iID
							  
	SenderFilter = Starter.DBCon.ExecQueryAsync("SQL", Starter.strCriteria, Null)
	Wait For (SenderFilter) SQL_QueryComplete (Success As Boolean, RS As ResultSet)
		
	If Success Then
		RS.Position = 0
		sDate = RS.GetString("TranDate")
		sPCode = RS.GetString("PumpHouseCode")
		sBucketSize = RS.GetInt("BucketSize") & $" "$ & RS.GetString("UnitOfMeasurement")
		iTry1 = RS.GetString("Trial1")
		iTry2 = RS.GetString("Trial2")
		iTry3 = RS.GetString("Trial3")
		dRes = RS.GetDouble("GPMResult")
		sWaterQuality = RS.GetString("WaterQuality")
		sRem = RS.GetString("Remarks")
	Else
		snack.Initialize("", Activity,$""$ & LastException.Message,5000)
		MyFunctions.SetSnackBarTextColor(snack, Colors.White)
		MyFunctions.SetSnackBarBackground(snack, GlobalVar.RedColor)
		snack.Show
		Log(LastException)
	End If
	
	csTitle.Initialize.Size(18).Bold.Color(GlobalVar.BlueColor).Append($"GPM RESULT DETAILS"$).PopAll
	
	MatDialogBuilder.Initialize("EditGPMRec")
	MatDialogBuilder.PositiveText("OK").PositiveColor(GlobalVar.BlueColor)
	MatDialogBuilder.NegativeText("EDIT").NegativeColor(GlobalVar.GreenColor)
	MatDialogBuilder.NeutralText("DELETE").NeutralColor(GlobalVar.RedColor)
	MatDialogBuilder.Title(csTitle)
	MatDialogBuilder.Content($"  Pump: ${sPCode}
	Transaction Date: ${sDate}
	
	Bucket Size: ${sBucketSize}
	1st Trial: ${iTry1} sec(s).
	2nd Trial: ${iTry2} sec(s).
	3rd Trial: ${iTry3} sec(s).
	GPM Result: ${dRes} GPM
	Water Quality: ${sWaterQuality}
	Remarks: ${sRem}"$)
	MatDialogBuilder.Theme(MatDialogBuilder.THEME_LIGHT)
	MatDialogBuilder.CanceledOnTouchOutside(False)
	MatDialogBuilder.Cancelable(True)
	MatDialogBuilder.Show
End Sub

Private Sub EditGPMRec_ButtonPressed(mDialog As MaterialDialog, sAction As String)
	Select Case sAction
		Case mDialog.ACTION_POSITIVE
		Case mDialog.ACTION_NEGATIVE
			GlobalVar.blnNewGPM = False
			StartActivity(actGPMCalc)
		Case mDialog.ACTION_NEUTRAL
	End Select
End Sub

#End Region