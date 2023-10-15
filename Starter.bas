B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=9.9
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	'Database
	Public DBCon As SQL
	Public strCriteria As String
	Public DBPath As String
	Public RTP As RuntimePermissions

	Public SafeDirectory As String
	Public DBName As String = "MasterDB.db"
	
	Public GPS1 As GPS
	Private GPSStarted As Boolean
	
	Public FLP As FusedLocationProvider
	Private flpStarted As Boolean
End Sub

Sub Service_Create
'	rp.CheckAndRequest(rp.PERMISSION_WRITE_EXTERNAL_STORAGE)
'	rp.CheckAndRequest(rp.PERMISSION_READ_EXTERNAL_STORAGE)
'	GNSS1.Initialize("GNSS")
	Log(RTP.GetSafeDirDefaultExternal(""))
	DBPath = DBUtils.CopyDBFromAssets("MasterDB.db")

	Dim jo As JavaObject
	If jo.IsInitialized = False Then
		jo.InitializeStatic("java.util.Locale").RunMethod("setDefault", Array(jo.GetField("US")))		
	End If
	
	SafeDirectory = RTP.GetSafeDirDefaultExternal("")
	
	If File.Exists(SafeDirectory, DBName) = False Then
		Wait For (File.CopyAsync(File.DirAssets, DBName, SafeDirectory, DBName)) Complete (Success As Boolean) 'File.DirInternal
		ToastMessageShow($"DB Copied = ${Success}"$, False)
'		Log("Success: " & Success)
	End If
	CallSubDelayed(FirebaseMessaging, "SubscribeToTopics")

	GPS1.Initialize("GPS")
	FLP.Initialize("flp")
	FLP.Connect
	
	ConnectToDatabase
	Wait For SQLite_Ready (Success As Boolean)
	
End Sub
'SetManifestAttribute(android:installLocation, "auto")
Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground
End Sub


Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	Return True
End Sub

Sub Service_Destroy
	StopGps
End Sub
'CONNECT TO DATABASE A LOAD SETTINGS
Public Sub ConnectToDatabase
'	DBCon.Initialize(DBPath, "MasterDB.db",False)
	If DBCon.IsInitialized = False Then
		DBCon.Initialize(SafeDirectory, DBName, False)
	End If
	DBCon.Initialize(SafeDirectory, DBName, False)
End Sub

'gps events
#Region GPS
Public Sub StartGps
	If GPSStarted = False Then
		GPS1.Start(0, 0)
		GPSStarted = True
	End If
End Sub

Public Sub StopGps
	If GPSStarted Then
		GPS1.Stop
		GPSStarted = False
	End If
End Sub

Sub GPS_LocationChanged (Location1 As Location)
	CallSub2(Main, "LocationChanged", Location1)
End Sub

Sub GPS_GpsStatus (Satellites As List)
	CallSub2(Main, "GPSStatus", Satellites)
End Sub

#End Region

'flp events
#Region FusedLocationProvider
Sub flp_ConnectionSuccess
	Log("Connected to location provider")
	Dim location1 As Location
	location1.Initialize
	
	Log("Connected to location provider")
	LogColor(location1.Latitude,Colors.Cyan)
	LogColor(location1.Longitude,Colors.Magenta)

	GlobalVar.Lat = $"$1.4{location1.Latitude}"$
	GlobalVar.Lon = $"$1.4{location1.Longitude}"$
	LogColor($"Latitude: "$ & GlobalVar.Lat, Colors.Magenta)
	LogColor($"Longitude: "$ & GlobalVar.Lon, Colors.Cyan)
End Sub

Sub flp_ConnectionFailed(ConnectionResult1 As Int)
	Log("Failed to connect to location provider")
	Select ConnectionResult1
		Case FLP.ConnectionResult.NETWORK_ERROR
			'	a network error has occurred, this is likely to be a recoverable error
			'	so try to connect again
			FLP.Connect
		Case Else
			'	TODO handle other errors
	End Select
End Sub

Sub flp_ConnectionSuspended(SuspendedCause1 As Int)
	Log("FusedLocationProvider1_ConnectionSuspended")
	
	'	the FusedLocationProvider SuspendedCause object contains the various SuspendedCause constants
	
	Select SuspendedCause1
		Case FLP.SuspendedCause.CAUSE_NETWORK_LOST
			'	TODO take action
		Case FLP.SuspendedCause.CAUSE_SERVICE_DISCONNECTED
			'	TODO take action
	End Select
End Sub

Public Sub StartFLP
	Do While FLP.IsConnected = False
		Sleep(1000)
	Loop
	If flpStarted = False Then
		FLP.RequestLocationUpdates(CreateLocationRequest)
		flpStarted = True
	End If
End Sub

Private Sub flp_LocationChanged (Location1 As Location)
	GlobalVar.Lat = $"$1.4{Location1.Latitude}"$
	GlobalVar.Lon = $"$1.4{Location1.Longitude}"$
End Sub

Private Sub CreateLocationRequest As LocationRequest
	Dim lr As LocationRequest
	lr.Initialize
	lr.SetSmallestDisplacement(100)   '<-------------- add this line
	lr.SetInterval(1)
	lr.SetFastestInterval(lr.GetInterval / 2)
	lr.SetPriority(lr.Priority.PRIORITY_HIGH_ACCURACY)
	Return lr
End Sub

Public Sub StopFLP
	If flpStarted Then
		FLP.RemoveLocationUpdates
		flpStarted = False
	End If
End Sub

Public Sub StartLocationUpdates ()
	Dim Location1 As Location
	Location1.Initialize
	
	FLP.RequestLocationUpdates(CreateLocationRequest)
	GlobalVar.Lat = $"$1.4{Location1.Latitude}"$
	GlobalVar.Lon = $"$1.4{Location1.Longitude}"$	
End Sub

#End Region
