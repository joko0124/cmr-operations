B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=9.9
@EndOfDesignText@
Sub Process_Globals
	
End Sub

#Region Styles
Public Sub SetSnackBarBackground(pSnack As DSSnackbar, pColor As Int)
	Dim v As View
	v = pSnack.View
	v.Color = pColor
End Sub

Public Sub SetSnackBarTextColor(pSnack As DSSnackbar, pColor As Int)
	Dim p As Panel
	p = pSnack.View
	For Each v As View In p.GetAllViewsRecursive
		If v Is Label Then
			Dim textv As Label
			textv = v
			textv.TextColor = pColor
			Exit
		End If
	Next
End Sub

Public Sub FontBit (icon As String, font_size As Float, color As Int, awesome As Boolean) As Bitmap
	'''''''''''''''''''''''''''''''''''Fontawesome to bitmap
	If color = 0 Then color = Colors.White
	Dim typ As Typeface = Typeface.MATERIALICONS
	If awesome Then typ = Typeface.FONTAWESOME
	Dim bmp As Bitmap
	bmp.InitializeMutable(32dip, 32dip)
	Dim cvs As Canvas
	cvs.Initialize2(bmp)
	Dim h As Double
	If Not(awesome) Then
		h = cvs.MeasureStringHeight(icon, typ, font_size) + 10dip
	Else
		h = cvs.MeasureStringHeight(icon, typ, font_size)
	End If
	cvs.DrawText(icon, bmp.Width / 2, bmp.Height / 2 + h / 2, typ, font_size, color, "CENTER")
	Return bmp
End Sub

Public Sub ShowCustomToast(Text As Object, LongDuration As Boolean, BackgroundColor As Int, Height As Int)
	Dim ctxt As JavaObject
	ctxt.InitializeContext
	Dim duration As Int
	If LongDuration Then duration = 1 Else duration = 0
	Dim toast As JavaObject
	toast = toast.InitializeStatic("android.widget.Toast").RunMethod("makeText", Array(ctxt, Text, duration))
	Dim v As View = toast.RunMethod("getView", Null)
	Dim cd As ColorDrawable
	cd.Initialize(BackgroundColor, 20dip)
	v.Background = cd
'	uncomment To show toast in the center:
	toast.RunMethod("setGravity", Array( _
	       Bit.Or(Gravity.CENTER_HORIZONTAL, Gravity.BOTTOM), 0, 0))
	toast.RunMethod("show", Null)
End Sub

Public Sub MyToastMsg(MyToast As BCToast,  sMessage As String)
'	MyToast.Initialize(Main)
	MyToast.DurationMs = 1600
	MyToast.Show(sMessage)
End Sub

Public Sub SetButton(v As View, Rx_TopLeft As Float, Ry_TopLeft As Float, Rx_TopRight As Float, Ry_TopRight As Float, Rx_BottomRight As Float, Ry_BottomRight As Float, Rx_BottomLeft As Float, Ry_BottomLeft As Float)
	Dim GradButton As GradientDrawable
	Dim Clrs(2) As Int
	Clrs(0) = GlobalVar.GreenColor
	Clrs(1) = GlobalVar.GreenColor2
	If Not(GradButton.IsInitialized) Then GradButton.Initialize("TR_BL",Clrs)
	v.Background = GradButton
	
	Dim jo As JavaObject = v.Background
	If v.Background Is ColorDrawable Or v.Background Is GradientDrawable Then
		jo.RunMethod("setCornerRadii", Array As Object(Array As Float(Rx_TopLeft, Ry_TopLeft, Rx_TopRight, Ry_TopRight, Rx_BottomRight, Ry_BottomRight, Rx_BottomLeft, Ry_BottomLeft)))
	End If
End Sub

Public Sub SetCancelButton(v As View, Rx_TopLeft As Float, Ry_TopLeft As Float, Rx_TopRight As Float, Ry_TopRight As Float, Rx_BottomRight As Float, Ry_BottomRight As Float, Rx_BottomLeft As Float, Ry_BottomLeft As Float)
	Dim GradButton As GradientDrawable
	Dim Clrs(2) As Int
	Clrs(0) = GlobalVar.RedColor
	Clrs(1) = GlobalVar.NegColor
	If Not(GradButton.IsInitialized) Then GradButton.Initialize("TR_BL",Clrs)
	v.Background = GradButton
	
	Dim jo As JavaObject = v.Background
	If v.Background Is ColorDrawable Or v.Background Is GradientDrawable Then
		jo.RunMethod("setCornerRadii", Array As Object(Array As Float(Rx_TopLeft, Ry_TopLeft, Rx_TopRight, Ry_TopRight, Rx_BottomRight, Ry_BottomRight, Rx_BottomLeft, Ry_BottomLeft)))
	End If
End Sub

#End Region

Public Sub myCD As ColorDrawable
	Dim mCD As ColorDrawable
	mCD.Initialize(Colors.RGB(240,240,240),0)
	Return mCD
End Sub
