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
	Private lblJOCat As Label
	Private lblJONo As Label
	Private lblRef_No As Label
	Private lblRefNo As Label
	Private lblCustName As Label
	Private lblCustAddress As Label

	Private lblAcctClass As Label
	Private lblConType As Label
	Private lblRemarks As Label

	Private lblDatesStart As Label
	Private lblDateAccomplished As Label
	Private lblAccomplishedBy As Label
	Private btnOk As ACButton
	Private btnPrint As ACButton
	
	Private cdOk, cdPrint As ColorDrawable
End Sub
#End Region

#Region Activity Events
Sub Activity_Create(FirstTime As Boolean)
	MyScale.SetRate(0.5)
	Activity.LoadLayout("JOAccomplishedDetailsSAS")
	
	If FirstTime Then
		ClearUI
		FillJORecord(GlobalVar.SelectedJOID)
	End If

End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	If KeyCode = 4 Then
		Return True
	Else
		Return False
	End If
End Sub

Sub Activity_Resume
	ClearUI
	FillJORecord(GlobalVar.SelectedJOID)
End Sub

Sub Activity_Pause (UserClosed As Boolean)
End Sub

#End Region

#Region Activity Objects
Private Sub ClearUI
	lblJOCat.Text = ""
	lblJONo.Text = ""
	lblRef_No.Text = ""
	lblRefNo.Text = ""
	lblCustName.Text = ""
	lblCustAddress.Text = ""

	lblAcctClass.Text = ""
	lblConType.Text = ""
	lblRemarks.Text = ""

	lblDatesStart.Text = ""
	lblDateAccomplished.Text = ""
	lblAccomplishedBy.Text = ""

	cdOk.Initialize(GlobalVar.GreenColor, 15)
	cdPrint.Initialize(GlobalVar.YellowColor, 15)
	
	btnOk.Background = cdOk
	btnPrint.Background = cdPrint
	
	btnPrint.Text = Chr(0xE8AD) & " PRINT"
	btnOk.Text = Chr(0xE8CE) & " OK"
End Sub

Sub btnOk_Click
	Activity.Finish
End Sub

Sub btnEdit_Click
	ToastMessageShow($"Printing not yet ready..."$, False)
End Sub
#End Region

#Region JO Lists

Private Sub FillJORecord (iJOID As Int)
	Dim RSJOSASDetails As Cursor
	Dim sPlumbersID As String
	Try
		Starter.strCriteria = "SELECT JOs.JOCatCode, JOs.JoDesc, JOs.JONo, JOs.RefNo, JOs.CustName, JOs.CustAddress, " & _
						  "Findings.AcctClass || ' - ' || Findings.AcctSubClass As AcctClassification, Findings.ConType, Findings.Remarks, " & _
						  "JOs.DateStarted, JOs.DateFinished, JOs.AccomplishedBy, constant_con_types.ConTypeDesc " & _
						  "FROM tblJOs As JOs " & _
						  "INNER JOIN tblJOSASFindings AS Findings ON JOs.JOID = Findings.JOID " & _
						  "INNER JOIN constant_con_types ON Findings.ConType = constant_con_types.id " & _
						  "WHERE Findings.JOID = " & iJOID
		LogColor(Starter.strCriteria, Colors.Yellow)

		RSJOSASDetails = Starter.DBCon.ExecQuery(Starter.strCriteria)
		
		If RSJOSASDetails.RowCount > 0 Then
			RSJOSASDetails.Position = 0
			lblJOCat.Text = GlobalVar.SF.Upper(RSJOSASDetails.GetString("JoDesc"))
			lblJONo.Text = GlobalVar.SF.Upper(RSJOSASDetails.GetString("JONo"))
			lblRef_No.Text = $"Application No. :"$
			lblRefNo.Text = GlobalVar.SF.Upper(RSJOSASDetails.GetString("RefNo"))
			lblCustName.Text = GlobalVar.SF.Upper(RSJOSASDetails.GetString("CustName"))
			lblCustAddress.Text = GlobalVar.SF.Upper(RSJOSASDetails.GetString("CustAddress"))

			lblAcctClass.Text = GlobalVar.SF.Upper(RSJOSASDetails.GetString("AcctClassification"))
			lblConType.Text = GlobalVar.SF.Upper(RSJOSASDetails.GetString("ConTypeDesc"))
			lblRemarks.Text = GlobalVar.SF.Upper(RSJOSASDetails.GetString("Remarks"))

			lblDatesStart.Text = GlobalVar.SF.Upper(RSJOSASDetails.GetString("DateStarted"))
			lblDateAccomplished.Text = GlobalVar.SF.Upper(RSJOSASDetails.GetString("DateFinished"))
			sPlumbersID = RSJOSASDetails.GetString("AccomplishedBy")	
			lblAccomplishedBy.Text = GlobalVar.SF.Upper(DBaseFunctions.GetPlumberNames(sPlumbersID))
		Else
			Log(LastException)
			Return
		End If
		
	Catch
		Log(LastException)
	End Try
	RSJOSASDetails.Close
End Sub

#End Region