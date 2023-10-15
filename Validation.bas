B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.8
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

Public Sub IsEmail(EmailAddress As String) As Boolean
  
	Dim MatchEmail As Matcher = Regex.Matcher("^(?i)[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])$", EmailAddress)

	If MatchEmail.Find = True Then
		Return True
	Else
		Return False
	End If
	
End Sub

Sub IsUrl(Url As String) As Boolean
	
	Dim pattern As String = "http(s)?://([\w+?\.\w+])+([a-zA-Z0-9\~\!\@\#\$\%\^\&\*\(\)_\-\=\+\\\/\?\.\:\;\'\,]*)?"
	If Regex.IsMatch(pattern, Url) = True Then
		Return True
	Else
		Return False
	End If
	
End Sub

Public Sub IsPostalCode(Code As String) As Boolean
	
	Try
		Return Regex.IsMatch("^[0-9]{2,10}$",Code)
	Catch
		Return False
	End Try
	
End Sub

'validate without first zero
'function remove first zero and proccess
Public Sub IsMobileNumber(Input As String) As Boolean
	
	Dim ph As String
	ph = Input
	If ph.StartsWith("0") Then
		ph = ph.SubString(1)
	End If
	
	Try
		Return Regex.IsMatch("^\d{10,16}$",ph)
	Catch
		Return False
	End Try
	
End Sub

' verify input of two textboxes
Sub IsSame(ValueToCheck As String, ValueToCheck2 As String) As Boolean
	ValueToCheck = ValueToCheck.Trim
	ValueToCheck2 = ValueToCheck2.Trim
	If ValueToCheck = ValueToCheck2 Then
		Return True
	Else
		Return False
	End If
End Sub

Sub IsBlank(ValueToCheck As String) As Boolean
	ValueToCheck = ValueToCheck.Trim
	If ValueToCheck.Length = 0 Then
		Return True
	Else
		Return False
	End If
End Sub

Sub DoNotMatch(ValueToCheck As String, ValueToCheck2 As String) As Boolean
	ValueToCheck = ValueToCheck.Trim
	ValueToCheck2 = ValueToCheck2.Trim
	If ValueToCheck <> ValueToCheck2 Then
		Return True
	Else
		Return False
	End If
End Sub

Public Sub IsArray(Var As Object) As Boolean
	Dim VarType As String = GetType(Var)
	Return VarType.StartsWith("[")
End Sub

Public Sub ArrayType(Var As Object) As String
	Dim Res As String

	Dim VarType As String = GetType(Var)

	If VarType.StartsWith("[") Then

		Dim SecondChar As String = VarType.SubString2(1,2)
		Select Case SecondChar
			Case "B"
				Res = "Byte"
			Case "S"
				Res = "Short"
			Case "I"
				Res = "Int"
			Case "J"
				Res = "Long"
			Case "F"
				Res = "Float"
			Case "D"
				Res = "Double"
			Case "C"
				Res = "Char"
			Case "L"
				If VarType.Contains("String") Then
					Res = "String"
				Else
					Res = "Object"
				End If
			Case Else
				Res = ""
		End Select

	End If

	Return Res

End Sub

Public Sub IsLocation(Location As String) As Boolean
	Return Regex.IsMatch("^-?\d+(\.\d+)?+,-?\d+(\.\d+)?+$",Location)
End Sub

Public Sub IsNationalID(ID As String) As Boolean
	Return Regex.IsMatch("^\d{9,14}$",ID)
End Sub

Public Sub IsNumbers(Data As String) As Boolean
	Return IsNumber(Data)
End Sub

Public Sub IsDate(Date As String) As Boolean
	Return Regex.IsMatch("\d{4}-\d{1,2}-\d{1,2}",Date)
End Sub

Public Sub IsDateTime(sDateTime As String) As Boolean
	Return Regex.IsMatch("\d{4}-\d{1,2}-\d{1,2} \d{1,2}:\d{1,2}:\d{1,2}",sDateTime)
End Sub

Public Sub IsTime(sTime As String) As Boolean
	Dim Matcher1 As Matcher
	Matcher1 = Regex.Matcher("(\d\d):(\d\d)",sTime)
	
	If Matcher1.Find Then
		Dim iHrs, iMins As Int
		iHrs = Matcher1.Group(1)
		iMins = Matcher1.Group(2)
		If iHrs < 0 Or iHrs > 23 Then Return False
		If iMins < 0 Or iMins > 59	Then Return False
		Return True
	Else
		Return False
	End If
	
'	Return Regex.IsMatch("\d{1,2}:\d{1,2}",sTime)
End Sub

'Public Sub ParseLocation(Location As String) As LatLng
'	
'	If Location.IndexOf(",") > -1 Then
'		
'		Dim loc() As String
'		loc	=	Regex.Split(",",Location.Replace(" ",""))
'		
'		If IsNumber(loc(0)) And IsNumber(loc(1)) Then
'			Dim lt As LatLng
'			lt.Initialize(loc(0),loc(1))
'			
'			Return lt
'		Else
'			Return Null
'		End If
'		
'	End If
'	
'	Return Null
'	
'End Sub

Public Sub IsNull(Data As Object) As Boolean
	
	Dim sType As String
	Try
		sType	=	GetType(Data)
	Catch
		Return True
	End Try
	
	If sType.ToLowerCase = "null" Then
		Return True
	End If
	
	Return False
	
End Sub

Public Sub IsMap(Data As Object) As Boolean
	
	If GetType(Data) = "anywheresoftware.b4a.objects.collections.Map$MyMap" Then
		Return True
	Else
		Return False
	End If
	
End Sub

Public Sub IsList(Data As Object) As Boolean
	
	If GetType(Data) = "java.util.ArrayList" Then
		Return True
	Else
		Return False
	End If
	
End Sub

' Checks if a view is an Activity
Sub IsActivity(v As View) As Boolean
    Try
        v.Left = 10dip
        Return False
    Catch
        Return True
    End Try
End Sub

Sub ParseInt(Str As String) As Int
	Dim int2 As Int
	int2 = Str
	Return int2
End Sub