B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=9.9
@EndOfDesignText@
Sub Process_Globals
	Public DBVersion As Int
	Public ServerAddress As String
	Public APIController As String = "ApiController"
	Public BaseURL As String = "https://bowa-api.bwsi.com.ph/api/"
	
	Public CSTitle As CSBuilder
	Public CSSubtitle As CSBuilder
	
	Public PriColor = 0xFF007BFF As Double 'primary
	Public SecColor = 0xFF7FBDFF As Double
	
	Public PosColor = 0xFF007BFF As Double
	Public NegColor = 0xFFDC3545 As Double
	Public NeutralColor = 0xFF7FBDFF As Double
	
	Public BlueColor = 0xFF17A2B7 As Double 'info color
	Public GreenColor = 0xFF28A745 As Double 'success color 85ffa1
	Public GreenColor2 = 0xFF188731 As Double 'success color 85ffa1
	Public RedColor = 0xFFDC3545 As Double 'danger color
	Public YellowColor = 0xFFFFC107 As Double 'warning color
	Public GrayColor = 0xFF62789E As Double
	
	Public SF As StringFunctions
	
	Public UserID As Int
	Public UserName As String
	Public UserPW As String
	Public UserAvatar As String
	Public EmpName As String
	Public UserPosID As Int
	Public UserPos As String
	
	Public BranchID As Int
	Public BranchCode As String
	Public BranchName As String
	Public SysMode As Int
	
	Public RdgFrom, RdgTo As String
	Public TranDate As String
	Public PumpHouseID As Int
	Public PumpHouseCode As String
	Public PumpDrainPipeType As String
	Public PumpDrainPipeSize As String
	
	Public TranHeaderID As Int
	
	'Pump Time On Off
	Public blnNewTime As Boolean
	Public TimeDetailID As Int
	Public SelectedPumpTime As Long

	'FM Reading
	Public blnNewFMRdg As Boolean
	Public FMRdgDetailID As Int

	'PSI Reading
	Public blnNewPSIRdg As Boolean
	Public PSIRdgDetailID As Int

	'Chlorinator
	Public blnNewChlorine As Boolean
	Public ChlorineDetailID As Int

	'Problems Encountered
	Public blnNewProblem As Boolean
	Public ProblemDetailID As Int

	'PSI Dist
	Public blnNewPSIDist As Boolean
	Public PSIDistDetailID As Int
	
	'Non Operational
	Public blnNewNonOp As Boolean
	Public NonOpDetailID As Int
	'JOs
	Public SelectedJOID As Int
	Public SelectedJOCat As Int
	Public SelectedJOCatCode As String
	Public SelectedJODesc As String
	Public SelectedJOReason As String
	
	'GPM
	Public blnNewGPM As Boolean
	Public GPMId As Int
	
	Public RepMainID As Int
	Public RepMainDesc As String
	
	'GPS
	Public Lat, Lon As String
	Public Speed As Double
	Public Sat As String
	Public GNSSStats As String
	
	'Permissions
	Public ReadStoragePermission As Boolean
	Public WriteStoragePermission As Boolean
	Public CoarseLocPermission As Boolean
	Public FineLocPermission As Boolean
End Sub