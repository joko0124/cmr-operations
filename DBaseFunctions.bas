B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=9.9
@EndOfDesignText@
Sub Process_Globals
	Private rsTemp As Cursor
	Private SF As StringFunctions
End Sub

#Region System Parameter
Public Sub GetParameters
	'Get System Parameters and Set to Global Variables
	Dim CountRec As Int
	Try
		CountRec = Starter.DBCon.ExecQuerySingleResult("SELECT COUNT(ID) FROM tblSysParam")
		If CountRec <=0 Then Return
		
		Starter.strCriteria = "SELECT * FROM tblSysParam"
		LogColor(Starter.strCriteria, Colors.Blue)
		rsTemp = Starter.DBCon.ExecQuery(Starter.strCriteria)
		
		If rsTemp.RowCount > 0 Then
			rsTemp.Position = 0
			GlobalVar.RdgFrom = rsTemp.GetString("RdgDateFrom")
			GlobalVar.RdgTo = rsTemp.GetString("RdgDateTo")
			GlobalVar.BranchID = rsTemp.GetInt("BranchID")
		Else
			ToastMessageShow($"Unable to fetch System Parameters due to "$ & LastException.Message, False)
		End If
	Catch
		ToastMessageShow($"Unable to fetch System Parameters due to "$ & LastException.Message, False)
		Log(LastException)
	End Try
End Sub

Public Sub GetDBVersionNo () As Int
	'Get Database Version Number
	Dim iRetVal As Int

	Try
		Starter.strCriteria = "SELECT DBVersionNo FROM tblSysParam"
		LogColor(Starter.strCriteria, Colors.Blue)
		
		iRetVal = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch Database Verion Number due to "$ & LastException.Message, False)
		Log(LastException)
		iRetVal = 0
	End Try
	Return iRetVal	
End Sub

Public Sub GetSystemMode(iBranchID As Int) As Int
	'Get Branch System Mode
	Dim iRetVal As Int

	Try
		Starter.strCriteria = "SELECT SysMode FROM tblBranches WHERE BranchID = " & iBranchID
		LogColor(Starter.strCriteria, Colors.Blue)
		
		iRetVal = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch Branch System Mode due to "$ & LastException.Message, False)
		Log(LastException)
		iRetVal = 0
	End Try
	Return iRetVal
End Sub
#End Region

#Region Pump House
Public Sub GetPumpHouseID(sCode As String) As Int
	'Get Pump House Station ID from its Code
	Dim iRetVal As Int

	Try
		Starter.strCriteria = "SELECT * FROM tblPumpStation WHERE PumpHouseCode = '" & sCode & "'"
		LogColor(Starter.strCriteria, Colors.Blue)
		
		iRetVal = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch Pump StationID due to "$ & LastException.Message, False)
		Log(LastException)
		iRetVal = 0
	End Try
	Return iRetVal
End Sub

Public Sub GetPumpPowerStatus(iStationID As Int) As Int
	'Get Pump House On/Off Status
	Dim iRetval As Int
	Try
		Starter.strCriteria = "SELECT OnOffStatus FROM tblPumpStation WHERE StationID = " & iStationID
		LogColor(Starter.strCriteria, Colors.Blue)
		
		iRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch Pump On/Off State due to "$ & LastException.Message, False)
		Log(LastException)
		iRetval = 0
	End Try
	Return iRetval
End Sub

Public Sub UpdatePumpPowerStatus(iPumpPowerStatus As Int, iPumpID As Int)
	
	Starter.DBCon.BeginTransaction
	Try
		Starter.strCriteria = "UPDATE tblPumpStation SET " & _
							  "OnOffStatus = ? " & _
							  "WHERE StationID = " & iPumpID
							  
		Starter.DBCon.ExecNonQuery2(Starter.strCriteria, Array As String(iPumpPowerStatus))
		Starter.DBCon.TransactionSuccessful
	Catch
		Log(LastException)
	End Try
	Starter.DBCon.EndTransaction
	
End Sub


Public Sub GetLastFMReading(iStationID As Int) As Double
	'Get Pump House Flow Meter Last Reading
	Dim dRetval As Double
	Try
		Starter.strCriteria = "SELECT LastRdg FROM tblPumpStation WHERE StationID = " & iStationID
		LogColor(Starter.strCriteria, Colors.Blue)
		
		dRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch Pump Last Reading due to "$ & LastException.Message, False)
		Log(LastException)
		dRetval = 0
	End Try
	Return dRetval
End Sub

Public Sub GetLastFMReadingTransID(iReading As Int, iBackFlow As Int) As Double
	'Get Last Production ID
	Dim dRetval As Double
	Try
		Starter.strCriteria = "SELECT DetailID FROM ProductionDetails " & _
						  "WHERE PresRdg = " & iReading & " " & _
						  "AND PresCum < " & iBackFlow
		LogColor(Starter.strCriteria, Colors.Blue)
		
		dRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch Detail Last Reading due to "$ & LastException.Message, False)
		Log(LastException)
		dRetval = 0
	End Try
	Return dRetval
End Sub

Public Sub GetDrainPipeType (iPumpID As Int) As String
	'Get Pump House Drain Pipe Type
	Dim sRetval As String

	sRetval = ""

	Try
		Starter.strCriteria = "SELECT DrainPipeType FROM tblPumpStation WHERE StationID = " & iPumpID
		LogColor(Starter.strCriteria, Colors.Blue)
		
		sRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch Pump Drain Pipe Type due to "$ & LastException.Message, False)
		Log(LastException)
		sRetval = ""
	End Try
	Return sRetval
	
End Sub

Public Sub GetDrainPipeSize (iPumpID As Int) As String
	'Get Pump House Drain Pipe Type
	Dim sRetval As String

	sRetval = ""

	Try
		Starter.strCriteria = "SELECT DrainPipeSize FROM tblPumpStation WHERE StationID = " & iPumpID
		LogColor(Starter.strCriteria, Colors.Blue)
		
		sRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch Pump Drain Pipe Size due to "$ & LastException.Message, False)
		Log(LastException)
		sRetval = ""
	End Try
	Return sRetval
	
End Sub
#End Region

#Region Transactions
Public Sub GetHeaderID (iPumpID As Int, sTranDate As String) As Int
	Dim iRetval As Int
	Try
		Starter.strCriteria = "SELECT HeaderID FROM TranHeader " & _
							  "WHERE PumpID = ? " & _
							  "AND TranDate = ?"
		LogColor(Starter.strCriteria, Colors.White)
		rsTemp = Starter.DBCon.ExecQuery2(Starter.strCriteria, Array As String(iPumpID, sTranDate))
		If rsTemp.RowCount > 0 Then
			rsTemp.Position = 0
			iRetval = rsTemp.GetInt("HeaderID")
		Else
			iRetval = 0
		End If
	Catch
		ToastMessageShow($"Unable to fetch Transaction Header due to "$ & LastException.Message, False)
		Log(LastException)
		iRetval = 0
	End Try
	rsTemp.Close
	Return iRetval
End Sub

Public Sub IsTransactionHeaderExist (iPumpID As Int, sTranDate As String) As Boolean
	Dim bRetVal As Boolean
	
	bRetVal = False
	Try
		Starter.strCriteria = "SELECT * FROM TranHeader " & _
						  "WHERE PumpID = " & iPumpID & " " & _
						  "AND TranDate = '" & sTranDate & "'"

		LogColor(Starter.strCriteria, Colors.White)
		
		rsTemp = Starter.DBCon.ExecQuery(Starter.strCriteria)
		
		If rsTemp.RowCount > 0 Then
			bRetVal = True
		Else
			bRetVal = False
		End If
	Catch
		bRetVal = False
		Log(LastException)
	End Try
	rsTemp.Close
	Return bRetVal
End Sub

Public Sub IsFMRdgDetailHeaderIDExist (iTranHeaderID As Int) As Boolean
	Dim bRetVal As Boolean
	
	bRetVal = False
	Try
		Starter.strCriteria = "SELECT * FROM ProductionDetails " & _
						  "WHERE HeaderID = " & iTranHeaderID

		LogColor(Starter.strCriteria, Colors.White)
		
		rsTemp = Starter.DBCon.ExecQuery(Starter.strCriteria)
		
		If rsTemp.RowCount > 0 Then
			bRetVal = True
		Else
			bRetVal = False
		End If
	Catch
		bRetVal = False
		Log(LastException)
	End Try
	rsTemp.Close
	Return bRetVal
End Sub

Public Sub IsGPMTransExist(iPumpID As Int, sTrandate As String) As Boolean
	Dim bRetVal As Boolean
	
	bRetVal = False
	Try
		Starter.strCriteria = "SELECT * FROM tblGPMHistory AS GPMHist " & _
						  "WHERE GPMHist.PumpID = "  & iPumpID & " " & _
						  "AND GPMHist.TranDate = '" & sTrandate & "'"
		LogColor(Starter.strCriteria, Colors.White)
		
		rsTemp = Starter.DBCon.ExecQuery(Starter.strCriteria)
		
		If rsTemp.RowCount > 0 Then
			bRetVal = True
		Else
			bRetVal = False
		End If
	Catch
		bRetVal = False
		Log(LastException)
	End Try
	rsTemp.Close
	Return bRetVal
End Sub

Public Sub GetIDByCode (sRetField As String, sTableName As String, sFieldToCompare As String, sCodeComparison As String) As Int
	Dim iRetval As Int
	iRetval = 0
	Try
		Starter.strCriteria = "SELECT " & sRetField & " FROM " & sTableName & " WHERE " & sFieldToCompare & " = '" & sCodeComparison & "'"
		LogColor(Starter.strCriteria, Colors.Blue)
		
		iRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch ID due to "$ & LastException.Message, False)
		Log(LastException)
		iRetval = 0
	End Try
	LogColor($"Return ID: "$ & iRetval, Colors.Yellow)
	Return iRetval
End Sub

Public Sub GetCodeByID (sRetField As String, sTableName As String, sCodeToCompare As String, iCodeComparison As Int) As String
	Dim sRetval As String
	sRetval = ""
	Try
		Starter.strCriteria = "SELECT " & sRetField & " FROM " & sTableName & " WHERE " & sCodeToCompare & " = " & iCodeComparison
		LogColor(Starter.strCriteria, Colors.Blue)
		
		sRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch Pump Last Reading due to "$ & LastException.Message, False)
		Log(LastException)
		sRetval = ""
	End Try
	Return sRetval
End Sub

Public Sub GetJODesc (sJOCAt As String) As String
	Dim sRetval As String
	sRetval = ""
	Try
		Starter.strCriteria = "SELECT jo_desc FROM constant_jo_categories WHERE jo_code = '"  & sJOCAt & "'"
		LogColor(Starter.strCriteria, Colors.Blue)
		
		sRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch JO Category due to "$ & LastException.Message, False)
		Log(LastException)
		sRetval = ""
	End Try
	Return sRetval
End Sub

Public Sub GetLastTimeOnID (sTrandate As String, iPumpID As Int) As Int
	Dim iRetval As Int
	iRetval = 0
	Try
		Starter.strCriteria = "SELECT Details.DetailID FROM OnOffDetails AS Details " & _
						  "INNER JOIN TranHeader AS Header ON Details.HeaderID = Header.HeaderID " & _
						  "WHERE Header.PumpID = " & iPumpID & " " & _
						  "AND Header.TranDate = '" & sTrandate & "' " & _
						  "ORDER BY substr(Details.PumpOnTime,7,2) || (Case WHEN substr(Details.PumpOnTime,1,2) = '12' AND substr(Details.PumpOnTime,7,2) ='AM' THEN '00' ELSE substr(Details.PumpOnTime,1,2) END) || ' ' || substr(Details.PumpOnTime,4,2) ASC"
		LogColor(Starter.strCriteria, Colors.Blue)
		
		iRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch ID due to "$ & LastException.Message, False)
		Log(LastException)
		iRetval = 0
	End Try
	LogColor($"Return ID: "$ & iRetval, Colors.Yellow)
	Return iRetval
End Sub

#End Region

#Region Users
Public Sub GetUserID (sUserName As String, sUserPass As String) As Int
	'Get User's ID from the specified User Name and Password
	Dim iRetval As Int
	Try
		Starter.strCriteria = "SELECT UserID FROM tblUsers WHERE UserName = '" & sUserName & "' " & _
							  "AND UserPassword = '" & sUserPass & "'"
		LogColor(Starter.strCriteria, Colors.Blue)
		
		iRetval = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
	Catch
		ToastMessageShow($"Unable to fetch User's ID due to "$ & LastException.Message, False)
		Log(LastException)
		iRetval = 0
	End Try
	Return iRetval
End Sub

Public Sub isGetUserInfo (iUserID As Int) As Boolean
	'Get User's Info from the specified User's ID
	Dim bRetVal As Boolean
	Try
		Starter.strCriteria = "SELECT * FROM tblUsers WHERE UserID = " & iUserID
		LogColor(Starter.strCriteria, Colors.Blue)
		
		rsTemp = Starter.DBCon.ExecQuery(Starter.strCriteria)
		
		If rsTemp.RowCount > 0 Then
			rsTemp.Position = 0
			GlobalVar.UserName = rsTemp.GetString("UserName")
			GlobalVar.UserPW = rsTemp.GetString("UserPassword")
			GlobalVar.EmpName = rsTemp.GetString("EmpName")
			GlobalVar.UserAvatar = SF.Upper(SF.Left(rsTemp.GetString("FirstName"),1) &SF.Left(rsTemp.GetString("LastName"),1))
			bRetVal = True
		Else
			bRetVal = False
		End If
	Catch
		ToastMessageShow($"Unable to fetch User's Info due to "$ & LastException.Message, False)
		Log(LastException)
		bRetVal = False
		rsTemp.Close
	End Try
	rsTemp.Close
	Return bRetVal
End Sub

Public Sub isGetBranchInfo (iBranchID As Int) As Boolean
	'Get Branch Info from the specified Branch ID
	Dim bRetVal As Boolean
	Try
		Starter.strCriteria = "SELECT * FROM tblBranches WHERE BranchID = " & iBranchID
		LogColor(Starter.strCriteria, Colors.Blue)
		
		rsTemp = Starter.DBCon.ExecQuery(Starter.strCriteria)
		
		If rsTemp.RowCount > 0 Then
			rsTemp.Position = 0
			GlobalVar.BranchCode = rsTemp.GetString("BranchCode")
			GlobalVar.BranchName = rsTemp.GetString("BranchName")
			bRetVal = True
		Else
			bRetVal = False
		End If
	Catch
		ToastMessageShow($"Unable to fetch Branch Info due to "$ & LastException.Message, False)
		Log(LastException)
		rsTemp.Close
		bRetVal = False
	End Try
	rsTemp.Close
	Return bRetVal
End Sub

Public Sub HasAssignment(iUserID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim iRetVal As Int
	Try
		bRetVal = False
		Starter.strCriteria = "SELECT Count(tblAssignedStation.AssignedID) FROM tblAssignedStation WHERE tblAssignedStation.OpID = " & iUserID
		LogColor(Starter.strCriteria, Colors.Blue)
		
		iRetVal = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
		
		If iRetVal > 0 Then
			bRetVal = True
		End If
	Catch
		ToastMessageShow($"Unable to fetch User's ID due to "$ & LastException.Message, False)
		Log(LastException)
		bRetVal = False
	End Try
	Return bRetVal
End Sub

Public Sub IsMultiPos(iUserID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim iRetVal As Int
	Try
		bRetVal = False
		Starter.strCriteria = "SELECT IsMultiPos FROM tblUsers WHERE UserID = " & iUserID
		LogColor(Starter.strCriteria, Colors.Blue)
		
		iRetVal = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
		
		If iRetVal = 1 Then
			bRetVal = True
		Else
			bRetVal = False
		End If
	Catch
		ToastMessageShow($"Unable to fetch User's ID due to "$ & LastException.Message, False)
		Log(LastException)
		bRetVal = False
	End Try
	Return bRetVal
End Sub

Public Sub GetPlumberIDs(sPlumber As String) As String
	Dim sRetVal As String
	Dim EmpCode As String
	Dim EmpID As String
	Dim EmpIDList As List
	
	EmpIDList.Initialize
	EmpIDList.Clear
	
	Try
		Dim arr() As String
'		arr = Regex.Split(",", spnPlumbers.SelectedItemsString)
		arr = Regex.Split(",", sPlumber)
		LogColor(arr.Length, Colors.Cyan)
		For i = 0 To arr.Length - 1
			Log(arr(i))
			EmpID = GetIDByCode("id", "tblPlumbers","EmpName",GlobalVar.SF.Trim(arr(i)))
			EmpIDList.Add(EmpID)
		Next
		
		LogColor(EmpIDList.Size, Colors.Cyan)
		
		For j = 0 To EmpIDList.Size - 1
			EmpCode =  EmpIDList.Get(j)
			LogColor(EmpCode,Colors.Magenta)
			If j = 0 Then
				sRetVal = GlobalVar.SF.Trim(EmpCode)
			Else
				sRetVal = sRetVal & "," & EmpCode
			End If
		Next
		
		Log (sRetVal)
'		sRetVal = EmpIDList.
	Catch
		Log(LastException)
	End Try
	LogColor(sRetVal, Colors.Cyan)
	Return GlobalVar.SF.Trim(sRetVal)
End Sub

Public Sub GetPlumberNames(sPlumber As String) As String
	Dim sRetVal As String
	Dim EmpCode As String
	Dim EmpName As String
	Dim EmpNameList As List
	
	EmpNameList.Initialize
	EmpNameList.Clear
	
	Try
		Dim arr() As String
'		arr = Regex.Split(",", spnPlumbers.SelectedItemsString)
		arr = Regex.Split(",", sPlumber)
		LogColor(arr.Length, Colors.Cyan)
		For i = 0 To arr.Length - 1
			Log(arr(i))
			EmpName = GetCodeByID("EmpName", "tblPlumbers","id", GlobalVar.SF.Trim(arr(i)))
			EmpNameList.Add(EmpName)
		Next
		
		LogColor(EmpNameList.Size, Colors.Cyan)
		
		For j = 0 To EmpNameList.Size - 1
			EmpCode =  EmpNameList.Get(j)
			LogColor(EmpCode,Colors.Magenta)
			If j = 0 Then
				sRetVal = GlobalVar.SF.Trim(EmpCode)
			Else
				sRetVal = sRetVal & ", " & EmpCode
			End If
		Next
		
		Log (sRetVal)
'		sRetVal = EmpIDList.
	Catch
		Log(LastException)
	End Try
	LogColor(sRetVal, Colors.Cyan)
	Return GlobalVar.SF.Trim(sRetVal)
End Sub


#End Region

#Region Time Computation
Public Sub IsPumpTimeOverlapped(lTimeOn As Long, lTimeOff As Long, iHeaderID As Int) As Boolean
	Dim IsTimeOverlapped, bRetVal As Boolean
	Dim sPumpTimeOn, sPumpTimeOff As String
	Dim lPumpTimeOn, lPumpTimeOff As Long
	
	Try
		Dim RS As ResultSet = Starter.DBCon.ExecQuery2("SELECT * FROM OnOffDetails WHERE HeaderID = ? " & "ORDER BY	DetailID ASC", Array As String(iHeaderID))
		LogColor("SELECT * FROM OnOffDetails WHERE HeaderID = " & iHeaderID & " ORDER BY DetailID ASC", Colors.White)
		bRetVal = False
		IsTimeOverlapped = False
		
		If RS.RowCount > 0 Then
'			RS.Position = 0
			Do While RS.NextRow
				sPumpTimeOn = RS.GetString("PumpOnTime")
				sPumpTimeOff = RS.GetString("PumpOffTime")
				DateTime.TimeFormat = "hh:mm a"
				lPumpTimeOn = DateTime.TimeParse(sPumpTimeOn)
				lPumpTimeOff = DateTime.TimeParse(sPumpTimeOff)
				LogColor(sPumpTimeOn,Colors.Yellow)
				LogColor(sPumpTimeOff,Colors.Yellow)
				
				LogColor($"Input On: "$ & lTimeOn,Colors.Red)
				LogColor($"Input Off: "$ & lTimeOff,Colors.Magenta)
				LogColor($"Data On: "$ & RS.Position & $" "$ & lPumpTimeOn,Colors.Red)
				LogColor($"Data Off: "$ & RS.Position & $" "$ & lPumpTimeOff,Colors.Magenta)

				If lTimeOn = lPumpTimeOn Or lTimeOff = lPumpTimeOff Or lTimeOn = lPumpTimeOff Or lTimeOff = lPumpTimeOn Then 'Time On Or time Off is Equal Existing Time On and Off
					IsTimeOverlapped = True
					Log($""$)
					LogColor("1st Test",Colors.White)
				Else If lTimeOn > lPumpTimeOn And lTimeOn < lPumpTimeOff Then 'Time On is between existing
					IsTimeOverlapped = True
					Log($""$)
					LogColor("2nd Test",Colors.White)
				Else If lTimeOff > lPumpTimeOn And lTimeOff < lPumpTimeOff Then 'Time of is between existing
					IsTimeOverlapped = True
					Log($""$)
					LogColor("3rd Test",Colors.White)
				Else If lPumpTimeOn > lTimeOn And lPumpTimeOn < lTimeOff Then 'Existing Time Off Between Input Time On and Time Off
					IsTimeOverlapped = True
					Log($""$)
					LogColor("4th Test",Colors.White)
				Else If lPumpTimeOff > lTimeOn And lPumpTimeOff < lTimeOff Then 'Existing Time Off Between Input Time On and Time Off
					IsTimeOverlapped = True
					Log($""$)
					LogColor("5th Test",Colors.White)
				End If
				
				If IsTimeOverlapped = True Then
					Exit
				End If
			Loop
				If IsTimeOverlapped = True Then
					bRetVal = True
				Else
					bRetVal = False
				End If
		Else
			bRetVal = False
		End If
	Catch
		Log(LastException)
	End Try
	Return bRetVal
End Sub

Public Sub IsPumpTimeOverlappedEdit(lTimeOn As Long, lTimeOff As Long, iHeaderID As Int, iDetailID As Int) As Boolean
	Dim IsTimeOverlapped, bRetVal As Boolean
	Dim sPumpTimeOn, sPumpTimeOff As String
	Dim lPumpTimeOn, lPumpTimeOff As Long
	
	Try
		Dim RS As ResultSet = Starter.DBCon.ExecQuery2("SELECT * FROM OnOffDetails WHERE HeaderID = ? AND DetailID <> ? " & "ORDER BY DetailID ASC", Array As String(iHeaderID, iDetailID))
		LogColor("SELECT * FROM OnOffDetails WHERE HeaderID = " & iHeaderID & " ORDER BY DetailID ASC", Colors.White)
		bRetVal = False
		IsTimeOverlapped = False
		
		If RS.RowCount > 0 Then
'			RS.Position = 0
			Do While RS.NextRow
				sPumpTimeOn = RS.GetString("PumpOnTime")
				sPumpTimeOff = RS.GetString("PumpOffTime")
				DateTime.TimeFormat = "hh:mm a"
				lPumpTimeOn = DateTime.TimeParse(sPumpTimeOn)
				lPumpTimeOff = DateTime.TimeParse(sPumpTimeOff)
				LogColor(sPumpTimeOn,Colors.Yellow)
				LogColor(sPumpTimeOff,Colors.Yellow)
				
				LogColor($"Input On: "$ & lTimeOn,Colors.Red)
				LogColor($"Input Off: "$ & lTimeOff,Colors.Magenta)
				LogColor($"Data On: "$ & RS.Position & $" "$ & lPumpTimeOn,Colors.Red)
				LogColor($"Data Off: "$ & RS.Position & $" "$ & lPumpTimeOff,Colors.Magenta)

				If lTimeOn = lPumpTimeOn Or lTimeOff = lPumpTimeOff Or lTimeOn = lPumpTimeOff Or lTimeOff = lPumpTimeOn Then 'Time On Or time Off is Equal Existing Time On and Off
					IsTimeOverlapped = True
					Log($""$)
					LogColor("1st Test",Colors.White)
				Else If lTimeOn > lPumpTimeOn And lTimeOn < lPumpTimeOff Then 'Time On is between existing
					IsTimeOverlapped = True
					Log($""$)
					LogColor("2nd Test",Colors.White)
				Else If lTimeOff > lPumpTimeOn And lTimeOff < lPumpTimeOff Then 'Time off is between existing
					IsTimeOverlapped = True
					Log($""$)
					LogColor("3rd Test",Colors.White)
				Else If lPumpTimeOn > lTimeOn And lPumpTimeOn < lTimeOff Then 'Existing Time On Between Input Time On and Time Off
					IsTimeOverlapped = True
					Log($""$)
					LogColor("4th Test",Colors.White)
				Else If lPumpTimeOff > lTimeOn And lPumpTimeOff < lTimeOff Then 'Existing Time Off Between Input Time On and Time Off
					IsTimeOverlapped = True
					Log($""$)
					LogColor("5th Test",Colors.White)
				End If
				
				If IsTimeOverlapped = True Then
					Exit
				End If
			Loop
				If IsTimeOverlapped = True Then
					bRetVal = True
				Else
					bRetVal = False
				End If
		Else
			bRetVal = False
		End If
	Catch
		Log(LastException)
	End Try
	Return bRetVal
End Sub

Public Sub IsTimeOnOverlapping (sTimeOn As String, iTranHeaderID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim sPumpOn, sPumpOff As String
	Dim lTimeOn, lPumpOn, lPumpOff As Long
	
	DateTime.TimeFormat = "hh:mm a"
	lTimeOn = DateTime.TimeParse(sTimeOn)
	
	LogColor($"String Inputted Time On : "$ & sTimeOn, Colors.Yellow)
	LogColor($"Parsed Inputted Time On : "$ & lTimeOn, Colors.Cyan)
	
	Try
		Dim RS As ResultSet = Starter.DBCon.ExecQuery2("SELECT * FROM OnOffDetails WHERE HeaderID = ? " & " ORDER BY DetailID ASC", Array As String(iTranHeaderID))
		
		LogColor("SELECT * FROM OnOffDetails WHERE HeaderID = " & iTranHeaderID & " ORDER BY DetailID ASC", Colors.Cyan)

		bRetVal = False
				
		If RS.RowCount > 0 Then
			Do While RS.NextRow
				sPumpOn = RS.GetString("PumpOnTime")
				sPumpOff = RS.GetString("PumpOffTime")
				DateTime.TimeFormat = "hh:mm a"
				
				lPumpOn = DateTime.TimeParse(sPumpOn)
				lPumpOff = DateTime.TimeParse(sPumpOff)
				
				If lTimeOn = lPumpOn Or lTimeOn = lPumpOff Then
					bRetVal = True 'Overlapped 1st Test
					Exit
				Else If lTimeOn > lPumpOn And lTimeOn < lPumpOff Then
					bRetVal = True 'Overlapped 2nd Test
					Exit
				End If
			Loop
			
		Else
			bRetVal = False
		End If
	Catch
		bRetVal = False
		Log(LastException)
	End Try
	Return bRetVal
End Sub

Public Sub IsTimeOffOverlapping (sTimeOff As String, iTranHeaderID As Int, iDetailedID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim sPumpOn, sPumpOff As String
	Dim lTimeOff, lPumpOn, lPumpOff As Long
	
	DateTime.TimeFormat = "hh:mm a"
	lTimeOff = DateTime.TimeParse(sTimeOff)
	LogColor($"String Inputted Time Off : "$ & sTimeOff, Colors.Yellow)
	LogColor($"Parsed Inputted Time Off : "$ & lTimeOff, Colors.Cyan)
	
	Try
		Dim RS As ResultSet = Starter.DBCon.ExecQuery2("SELECT * FROM OnOffDetails WHERE HeaderID = ? AND DetailID <> ? " & " ORDER BY DetailID ASC", Array As String(iTranHeaderID, iDetailedID))
		
		LogColor("SELECT * FROM OnOffDetails WHERE HeaderID = " & iTranHeaderID & " ORDER BY DetailID ASC", Colors.Cyan)

		bRetVal = False
				
		If RS.RowCount > 0 Then
			Do While RS.NextRow
				sPumpOn = RS.GetString("PumpOnTime")
				sPumpOff = RS.GetString("PumpOffTime")
				DateTime.TimeFormat = "hh:mm a"
				
				lPumpOn = DateTime.TimeParse(sPumpOn)
				lPumpOff = DateTime.TimeParse(sPumpOff)
				LogColor($"Parsed Existing Time Off : "$ & lPumpOff, Colors.Cyan)
				
				If lTimeOff = lPumpOn Or lTimeOff = lPumpOff Then
					bRetVal = True 'Overlapped 1st Test
					Exit
				Else If lTimeOff > lPumpOn And lTimeOff < lPumpOff Then
					bRetVal = True 'Overlapped 2nd Test
					Exit
				End If
			Loop
			
		Else
			bRetVal = False
		End If
	Catch
		bRetVal = False
		Log(LastException)
	End Try
	Return bRetVal
End Sub

Public Sub IsTimeOnOffOverlapping (sTimeOn As String, sTimeOff As String, iTranHeaderID As Int, iDetailedID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim sPumpOn, sPumpOff As String
	Dim lTimeOn, lTimeOff, lPumpOn, lPumpOff As Long
	
	DateTime.TimeFormat = "hh:mm a"
	lTimeOn = DateTime.TimeParse(sTimeOn)
	lTimeOff = DateTime.TimeParse(sTimeOff)
	LogColor($"String Inputted Time On : "$ & sTimeOn, Colors.Yellow)
	LogColor($"Parsed Inputted Time On : "$ & lTimeOn, Colors.Cyan)
	LogColor($"String Inputted Time Off : "$ & sTimeOff, Colors.Yellow)
	LogColor($"Parsed Inputted Time Off : "$ & lTimeOff, Colors.Cyan)
	
	Try
		Dim RS As ResultSet = Starter.DBCon.ExecQuery2("SELECT * FROM OnOffDetails WHERE HeaderID = ? AND DetailID <> ? " & " ORDER BY DetailID ASC", Array As String(iTranHeaderID, iDetailedID))
		
		LogColor("SELECT * FROM OnOffDetails WHERE HeaderID = " & iTranHeaderID & " ORDER BY DetailID ASC", Colors.Cyan)

		bRetVal = False
				
		If RS.RowCount > 0 Then
			Do While RS.NextRow
				sPumpOn = RS.GetString("PumpOnTime")
				sPumpOff = RS.GetString("PumpOffTime")
				DateTime.TimeFormat = "hh:mm a"
				
				lPumpOn = DateTime.TimeParse(sPumpOn)
				lPumpOff = DateTime.TimeParse(sPumpOff)
				
				If lTimeOn = lPumpOn Or lTimeOff = lPumpOff Or lTimeOn = lPumpOff Or lTimeOff = lPumpOn Then 'Time On Or time Off is Equal Existing Time On and Off
					bRetVal = True
					LogColor("1st Test",Colors.White)
				Else If lTimeOn > lPumpOn And lTimeOn < lPumpOff Then 'Time On is between existing
					bRetVal = True
					LogColor("2nd Test",Colors.White)
				Else If lTimeOff > lPumpOn And lTimeOff < lPumpOff Then 'Time off is between existing
					bRetVal = True
					LogColor("3rd Test",Colors.White)
				Else If lPumpOn > lTimeOn And lPumpOn < lTimeOff Then 'Existing Time On Between Input Time On and Time Off
					bRetVal = True
					LogColor("4th Test",Colors.White)
				Else If lPumpOff > lTimeOn And lPumpOff < lTimeOff Then 'Existing Time Off Between Input Time On and Time Off
					bRetVal = True
					LogColor("5th Test",Colors.White)
				End If
			Loop
			
		Else
			bRetVal = False
		End If
	Catch
		bRetVal = False
		Log(LastException)
	End Try
	Return bRetVal
End Sub

Public Sub IsTimeOnEarly (sTimeOn As String, iTranHeaderID As Int, iDetailedID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim sPumpOn As String
	Dim lTimeOn, lPumpOn As Long
	
	DateTime.TimeFormat = "hh:mm a"
	lTimeOn = DateTime.TimeParse(sTimeOn)
	LogColor($"String Inputted Time On : "$ & sTimeOn, Colors.Yellow)
	LogColor($"Parsed Inputted Time On : "$ & lTimeOn, Colors.Cyan)
	
	Try
		Dim RS As ResultSet = Starter.DBCon.ExecQuery2("SELECT * FROM OnOffDetails WHERE HeaderID = ? AND DetailID <> ? " & " ORDER BY PumpOnTime, DetailID ASC", Array As String(iTranHeaderID, iDetailedID))
		
		LogColor("SELECT * FROM OnOffDetails WHERE HeaderID = " & iTranHeaderID & " ORDER BY DetailID ASC", Colors.Cyan)

		bRetVal = False
				
		If RS.RowCount > 0 Then
			Do While RS.NextRow
				sPumpOn = RS.GetString("PumpOnTime")
				DateTime.TimeFormat = "hh:mm a"
				
				lPumpOn = DateTime.TimeParse(sPumpOn)
				
				If lTimeOn < lPumpOn Then
					bRetVal = True 'Force Turn Off
					Exit
				End If
			Loop
			
		Else
			bRetVal = False
		End If
	Catch
		bRetVal = False
		Log(LastException)
	End Try
	Return bRetVal
End Sub

Public Sub IsReadingTimeOverlapping (sReadTime As String, iTranHeaderID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim lReadTime, lRdgTime, lPumpOff As Long
	
	Dim Test1, Test2 As Boolean
	
	
	Test1 = False
	Test2 = False
	
	DateTime.TimeFormat = "hh:mm a"
'	lReadTime = DateTime.TimeParse(sReadTime)
	
	LogColor($"String Inputted Time On : "$ & sReadTime, Colors.Yellow)
	LogColor($"Parsed Inputted Time On : "$ & lReadTime, Colors.Cyan)
	
	Try
		Dim RS As ResultSet = Starter.DBCon.ExecQuery2("SELECT * FROM ProductionDetails WHERE Time('" & sReadTime & "') > TIME(RdgTime) AND Time('" & sReadTime & "') < TIME(RdgTime) AND HeaderID = ? " & " ORDER BY DetailID ASC", Array As String(iTranHeaderID))
		
		LogColor("SELECT * FROM ProductionDetails WHERE Time('" & sReadTime & "') > TIME(RdgTime) AND Time('" & sReadTime & "') < TIME(RdgTime) AND HeaderID = ? " & " ORDER BY DetailID ASC", Colors.Cyan)

		bRetVal = False
				
		If RS.RowCount > 0 Then
			Do While RS.NextRow
				sReadTime = RS.GetString("RdgTime")
				DateTime.TimeFormat = "hh:mm a"
				
				lRdgTime = DateTime.TimeParse(sReadTime)
				
				If lReadTime = lRdgTime Then
					Return True 'Overlapped 1st Test
				End If

				If lReadTime < lRdgTime Then
					Test1 = True 'Overlapped 1st Test
					Exit
				End If
				
				If lReadTime > lRdgTime Then
					Test2 = True 'Overlapped 2nd Test
				End If
			Loop
			
			If Test1 = True Then
				
			End If
			
		Else
			bRetVal = False
		End If
	Catch
		bRetVal = False
		Log(LastException)
	End Try
	Return bRetVal
End Sub

Private Sub GetFirstRdgTime (iTranHeaderID As Int) As String
	Dim RdgTime As String
	Try
		Starter.strCriteria = "SELECT MIN(CASE WHEN substr(RdgTime,1,2) = '12' And substr(RdgTime,7,2) = 'AM' Then '00' || substr(RdgTime,3,6) " & _
						  "ELSE RdgTime END) " & _
						  "FROM ProductionDetails " & _
						  "WHERE HeaderID = " & iTranHeaderID
						  
		LogColor(Starter.strCriteria, Colors.Yellow)

		RdgTime = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
		LogColor($"1st Rdg: "$ & RdgTime, Colors.Yellow)
	Catch
		RdgTime = ""
		ToastMessageShow($"Unable to fetch System Parameters due to "$ & LastException.Message, False)
		Log(LastException)
	End Try
	Return RdgTime
End Sub

Private Sub GetLastRdgTime (iTranHeaderID As Int) As String
	Dim RdgTime As String
	Try
		Starter.strCriteria = "SELECT MAX(CASE WHEN substr(RdgTime,1,2) = '12' And substr(RdgTime,7,2) = 'AM' Then '00' || substr(RdgTime,3,6) " & _
						  "ELSE RdgTime END) " & _
						  "FROM ProductionDetails " & _
						  "WHERE HeaderID = " & iTranHeaderID
						  
		LogColor(Starter.strCriteria, Colors.Yellow)

		RdgTime = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
		LogColor($"Last Rdg: "$ & RdgTime, Colors.Yellow)
	Catch
		RdgTime = ""
		ToastMessageShow($"Unable to fetch System Parameters due to "$ & LastException.Message, False)
		Log(LastException)
	End Try
	Return RdgTime
End Sub

Public Sub IsReadTimeOverlapse(sReadTime As String, iTranHeaderID As Int) As Boolean
	Dim bRetVal As Boolean
	Dim FirstRdgTime, LastRdgTime As String
	Dim lFirstRdgTime, lLastRdgTime As Long
	Dim lReadTime As Long
	
	bRetVal = False
	FirstRdgTime = 0
	LastRdgTime = 0
	
	DateTime.TimeFormat = "HH:mm"
	LogColor(DateTime.TimeParse(sReadTime),Colors.Yellow)
	
	lReadTime = DateTime.TimeParse(sReadTime)
	
	Try
		FirstRdgTime = GetFirstRdgTime(iTranHeaderID)
		LogColor(FirstRdgTime, Colors.Cyan)
	Catch
		Log(LastException)
		Return True
	End Try
	
	Try
		LastRdgTime = GetLastRdgTime(iTranHeaderID)
		LogColor(LastRdgTime, Colors.Magenta)
	Catch
		Log(LastException)
		Return True
	End Try
	
	DateTime.TimeFormat = "HH:mm"
	LogColor(DateTime.TimeParse(FirstRdgTime),Colors.Yellow)
	
	lFirstRdgTime = DateTime.TimeParse(FirstRdgTime)

	DateTime.TimeFormat = "HH:mm"
	LogColor(DateTime.TimeParse(LastRdgTime),Colors.Yellow)
	
	lLastRdgTime = DateTime.TimeParse(LastRdgTime)
	
	Try
		If lReadTime >= lFirstRdgTime And lReadTime <= lLastRdgTime Then
			bRetVal = True
		Else
			bRetVal = False
		End If
		
	Catch
		Log(LastException)
		Return True
	End Try
	Return bRetVal
End Sub

Public Sub IsFuturisticTime(sTrandate As String, sTranTime As String) As Boolean
	Dim bRetVal As Boolean
	Dim iTotalTime As Int
	bRetVal = False

	
	DateTime.DateFormat = "yyyy-MM-dd"
	DateTime.TimeFormat = "HH:mm:ss"
	iTotalTime = HoursBetween(DateTime.Date(DateTime.Now), DateTime.Time(DateTime.Now),sTrandate, sTranTime & ":00")
	Log(iTotalTime)

	Try
		If iTotalTime > 0 Then
			Return True
		End If
		
	Catch
		bRetVal = False
		Log(LastException)
	End Try
	Return bRetVal
End Sub

Sub HoursBetween(StartDate As String, StartTime As String, _
   EndDate As String, EndTime As String) As Int
	Dim s, e As Long
	s = ParseDateAndTime(StartDate, StartTime)
	e = ParseDateAndTime(EndDate, EndTime)
	Return (e - s) / DateTime.TicksPerMinute
End Sub

Sub ParseDateAndTime(d As String, t As String) As Long
	
	Dim dd = DateTime.DateParse(d), tt = DateTime.TimeParse(t) As Long
	tt = (tt + DateTime.TimeZoneOffset * DateTime.TicksPerHour) Mod DateTime.TicksPerDay
	Dim total As Long
	total = dd + tt + _
      (DateTime.GetTimeZoneOffsetAt(dd) - DateTime.GetTimeZoneOffsetAt(dd + tt)) _
      * DateTime.TicksPerHour
	Return total
End Sub

Public Sub IsNonOperationalTimeOverlapped(lTimeStart As Long, lTimeEnd As Long, iHeaderID As Int, iDetailID As Int, bEditMode As Boolean) As Boolean
	Dim IsTimeOverlapped, bRetVal As Boolean
	Dim sStartTime, sEndTime As String
	Dim lStartTime, lEndTime As Long
	
	Try
		If bEditMode = True Then
			Starter.strCriteria = "SELECT * FROM NonOpDetails " & _
						  	  "WHERE HeaderID = " & iHeaderID & " " & _
							  "AND DetailID <> " & iDetailID & " " & _
							  "ORDER BY substr(OffTime,7,2) || (Case WHEN substr(OffTime,1,2) = '12' AND substr(OffTime,7,2) ='AM' THEN '00' ELSE substr(OffTime,1,2) END) || ' ' || substr(OffTime,4,2) ASC"
		Else
			Starter.strCriteria = "SELECT * FROM NonOpDetails " & _
						  	  "WHERE HeaderID = " & iHeaderID & " " & _
							  "ORDER BY substr(OffTime,7,2) || (Case WHEN substr(OffTime,1,2) = '12' AND substr(OffTime,7,2) ='AM' THEN '00' ELSE substr(OffTime,1,2) END) || ' ' || substr(OffTime,4,2) ASC"
		End If
		
		Dim RS As ResultSet = Starter.DBCon.ExecQuery(Starter.strCriteria)
		LogColor(Starter.strCriteria, Colors.White)
		
		bRetVal = False
		IsTimeOverlapped = False
		
		If RS.RowCount > 0 Then
'			RS.Position = 0
			Do While RS.NextRow
				sStartTime = RS.GetString("OffTime")
				sEndTime = RS.GetString("OnTime")
				
				DateTime.TimeFormat = "hh:mm a"
				lStartTime = DateTime.TimeParse(sStartTime)
				lEndTime = DateTime.TimeParse(sEndTime)
				LogColor(sStartTime,Colors.Yellow)
				LogColor(sEndTime,Colors.Yellow)
				
				LogColor($"Input On: "$ & lTimeStart,Colors.Red)
				LogColor($"Input Off: "$ & lTimeEnd,Colors.Magenta)
				LogColor($"Data On: "$ & RS.Position & $" "$ & lStartTime,Colors.Red)
				LogColor($"Data Off: "$ & RS.Position & $" "$ & lEndTime,Colors.Magenta)

				If lTimeStart = lStartTime Or lTimeEnd = lEndTime Or lTimeStart = lEndTime Or lTimeEnd = lStartTime Then 'Time On Or time Off is Equal Existing Time On and Off
					IsTimeOverlapped = True
					Log($""$)
					LogColor("1st Test",Colors.White)
				Else If lTimeStart > lStartTime And lTimeStart < lEndTime Then 'Time On is between existing
					IsTimeOverlapped = True
					Log($""$)
					LogColor("2nd Test",Colors.White)
				Else If lTimeEnd > lStartTime And lTimeEnd < lEndTime Then 'Time off is between existing
					IsTimeOverlapped = True
					Log($""$)
					LogColor("3rd Test",Colors.White)
				Else If lStartTime > lTimeStart And lStartTime < lTimeEnd Then 'Existing Time On Between Input Time On and Time Off
					IsTimeOverlapped = True
					Log($""$)
					LogColor("4th Test",Colors.White)
				Else If lEndTime > lTimeStart And lEndTime < lTimeEnd Then 'Existing Time Off Between Input Time On and Time Off
					IsTimeOverlapped = True
					Log($""$)
					LogColor("5th Test",Colors.White)
				End If
				
				If IsTimeOverlapped = True Then
					Exit
				End If
			Loop
				If IsTimeOverlapped = True Then
					bRetVal = True
				Else
					bRetVal = False
				End If
		Else
			bRetVal = False
		End If
	Catch
		Log(LastException)
	End Try
	Return bRetVal
End Sub

Public Sub TimeOverlapping (TimeStart As String, TimeEnd As String, iHeaderID As Int) As Boolean
	Dim sInputTimeStart, sInputTimeEnd, sStartTime, sEndTime As String
	Dim lStartTime, lEndTime As Long
	Dim lInputStart, lInputEnd As Long
	
	Dim bRetVal As Boolean
	
	sInputTimeStart = TimeStart & ":00"
	sInputTimeEnd = TimeEnd & ":00"
	
	DateTime.TimeFormat = "HH:mm:ss"
	lInputStart = DateTime.TimeParse(sInputTimeStart)
	lInputEnd = DateTime.TimeParse(sInputTimeEnd)
	
	bRetVal = False
	Try
		Starter.strCriteria = "SELECT * FROM NonOpDetails " & _
						  "WHERE HeaderID = " & iHeaderID & " " & _
						  "ORDER BY substr(OffTime,7,2) || (CASE WHEN substr(OffTime,1,2) = '12' AND substr(OffTime,7,2) ='AM' THEN '00' ELSE substr(OffTime,1,2) END) || ' ' || substr(OffTime,4,2) ASC"

		Dim RS As ResultSet = Starter.DBCon.ExecQuery(Starter.strCriteria)

		LogColor(Starter.strCriteria, Colors.ARGB(255,255, 120, 0))
		
		If RS.RowCount > 0 Then
			Do While RS.NextRow
				sStartTime = RS.GetString("OffTime") & ":00"
				sEndTime = RS.GetString("OnTime") & ":00"
				LogColor($"Off Time: "$ & sStartTime, Colors.Magenta)
				LogColor($"On Time: "$ & sEndTime, Colors.Cyan)
				
				DateTime.TimeFormat = "HH:mm:ss"
				lStartTime = DateTime.TimeParse(sStartTime)
				lEndTime = DateTime.TimeParse(sEndTime)
				
				If lInputStart > lStartTime And lInputStart < lEndTime And lInputEnd > lStartTime And lInputEnd < lEndTime Then
					bRetVal = True
				Else
					bRetVal = False
				End If
				
			Loop
		Else
			Return False
		End If
	Catch
		Log(LastException)
	End Try
	Return bRetVal
End Sub
#End Region

#Region Water Loss Computation
Public Sub ComputeWaterLoss (sPipeType As String, sPipeSize As String, iPSI As Int, iMinute As Int) As Double
	Dim bWaterLoss As BigDecimal
	Dim lWaterLoss As Double	
	Dim ConstantValue As Double
	
	Try
		If iPSI > 30 Then Return 0
		Starter.strCriteria = "SELECT WaterLoss FROM LeakVolumeConstant WHERE PipeType='" & sPipeType & "' " & _
						  "AND PipeSize = '" & sPipeSize & "' " & _
						  "AND PSI = " & iPSI
						  
		LogColor(Starter.strCriteria, Colors.Yellow)

		ConstantValue = Starter.DBCon.ExecQuerySingleResult("SELECT WaterLoss FROM LeakVolumeConstant WHERE PipeType = '" & sPipeType & "' " & _
											       "AND PipeSize = '" & sPipeSize & "' " & _
												  "AND PSI = " & iPSI)
		
		lWaterLoss = ConstantValue * iMinute
	Catch
		lWaterLoss = 0
		ToastMessageShow($"Unable to fetch Constant Water Loss due to "$ & LastException.Message, False)
		Log(LastException)
	End Try
	bWaterLoss.Initialize(lWaterLoss)
	bWaterLoss = RoundBD(bWaterLoss,2)

	Return bWaterLoss
End Sub

Sub RoundBD(BD As BigDecimal, DP As Int) As BigDecimal
	BD.Round(BD.Precision - BD.Scale + DP, BD.ROUND_HALF_UP)
	Return BD
End Sub
#End Region

#Region PSI Computation
Public Sub GetMinPSI (dTranHeaderID As Int) As Double
	Dim dMinPSI As Double
	
	Try
		dMinPSI = 0
		
		Starter.strCriteria = "SELECT min(PSIReading) FROM PressureRdgDetails WHERE HeaderID = " & dTranHeaderID & " " & _
						  "GROUP BY HeaderID"
		
		dMinPSI = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
		LogColor(Starter.strCriteria, Colors.Cyan)

	Catch
		dMinPSI = 0
		Log(LastException)
		ToastMessageShow($"Unable to fetch Minimum Pressure Reading due to "$ & LastException.Message, False)
	End Try
	Return dMinPSI
End Sub

Public Sub GetMaxPSI (dTranHeaderID As Int) As Double
	Dim dMaxPSI As Double
	
	Try
		dMaxPSI = 0
		
		Starter.strCriteria = "SELECT max(PSIReading) FROM PressureRdgDetails WHERE HeaderID = " & dTranHeaderID & " " & _
						  "GROUP BY HeaderID"
		
		dMaxPSI = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
		LogColor(Starter.strCriteria, Colors.Cyan)

	Catch
		dMaxPSI = 0
		Log(LastException)
		ToastMessageShow($"Unable to fetch Minimum Pressure Reading due to "$ & LastException.Message, False)
	End Try
	Return dMaxPSI
End Sub

Public Sub GetAvePSI (dTranHeaderID As Int) As Double
	Dim dAvePSI As Double
	
	Try
		dAvePSI = 0
		
		Starter.strCriteria = "SELECT avg(PSIReading) FROM PressureRdgDetails WHERE HeaderID = " & dTranHeaderID & " " & _
						  "GROUP BY HeaderID"
		
		dAvePSI = Starter.DBCon.ExecQuerySingleResult(Starter.strCriteria)
		LogColor(Starter.strCriteria, Colors.Cyan)

	Catch
		dAvePSI = 0
		Log(LastException)
		ToastMessageShow($"Unable to fetch Minimum Pressure Reading due to "$ & LastException.Message, False)
	End Try
	Return dAvePSI
End Sub

Public Sub GetLastPSIRdg (dTranHeaderID As Int) As Double
	Dim dPSIRdg As Double
	Dim RS As Cursor
	Try
		dPSIRdg = 0
		
		Starter.strCriteria = "SELECT MAX(DetailID), PSIReading FROM PressureRdgDetails WHERE HeaderID = " & dTranHeaderID & " " & _
						  "GROUP BY HeaderID"
		
		LogColor(Starter.strCriteria, Colors.Cyan)
		RS = Starter.DBCon.ExecQuery(Starter.strCriteria)
		If RS.RowCount > 0 Then
			dPSIRdg = RS.GetInt("PSIReading")
		Else
			dPSIRdg = 0
		End If
	Catch
		dPSIRdg = 0
		Log(LastException)
		ToastMessageShow($"Unable to fetch Minimum Pressure Reading due to "$ & LastException.Message, False)
	End Try

	Return dPSIRdg
End Sub

Public Sub GetPrevPSIRdg As Double
	Dim dPSIRdg As Double
	Dim RS As Cursor
	
	Try
		dPSIRdg = 0
		
		Starter.strCriteria = "SELECT PSIReading, max(DetailID) from PressureRdgDetails ORDER BY DetailID DESC LIMIT 1"
		LogColor(Starter.strCriteria, Colors.Cyan)
		RS = Starter.DBCon.ExecQuery(Starter.strCriteria)
		If RS.RowCount > 0 Then
			dPSIRdg = RS.GetInt("PSIReading")
		Else
			dPSIRdg = 0
		End If
	Catch
		dPSIRdg = 0
		Log(LastException)
		ToastMessageShow($"Unable to fetch Minimum Pressure Reading due to "$ & LastException.Message, False)
	End Try
	Return dPSIRdg
End Sub

#End Region

#Region DBase'Tests whether the given table exists
Public Sub TableExists(SQL As SQL, TableName As String) As Boolean
	Dim count As Int = SQL.ExecQuerySingleResult2("SELECT count(name) FROM sqlite_master WHERE type='table' AND name=? COLLATE NOCASE", Array As String(TableName))
	Return count > 0
End Sub

'Deletes all the records of a table
Public Sub ClearTable(SQL As SQL, TableName As String)
	If TableExists(SQL, TableName) = False Then
		Return
	End If
	SQL.ExecNonQuery("DELETE FROM " & TableName)
End Sub

Public Sub ResetTableSequence(SQL As SQL, sTableName As String)
	SQL.BeginTransaction
	Try
		'Update JO Table
		Starter.strCriteria = "UPDATE sqlite_sequence " & _
						  "SET seq = ? " & _
						  "WHERE name = '" & sTableName & "'"
		SQL.ExecNonQuery2(Starter.strCriteria, Array As String($"0"$))
	Catch
		Log(LastException.Message)
	End Try
	SQL.TransactionSuccessful

End Sub
#End Region