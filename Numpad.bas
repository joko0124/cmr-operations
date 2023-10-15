B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=5.8
@EndOfDesignText@

#DesignerProperty: Key: DecimalButton, DisplayName: Show Decimal, FieldType: Boolean, DefaultValue: True
#DesignerProperty: Key: Hint, DisplayName: Hint, FieldType: String, DefaultValue: Enter a number
#DesignerProperty: Key: AnimationDuration, DisplayName: Animation Duration, FieldType: Int, DefaultValue: 300
#DesignerProperty: Key: BackgroundColor, DisplayName: Background Color, FieldType: Color, DefaultValue: #FFEDEEF2

Sub Class_Globals
	Private EventName As String 'ignore
	Private CallBack As Object 'ignore
	Private mBase As Panel
	Private pnlNumpad As Panel
	Private const spHeight = 265dip, spWidth = 176dip As Int
	Private side As Int
	Private const SIDE_UP = 1, SIDE_DOWN = 2, SIDE_LEFT = 3, SIDE_RIGHT = 4 As Int
	Private top, left As Int
	Private mProps As Map
'	Private btnDecimal As Button
'	Private flEditText1 As FloatLabeledEditText
	Private focused As Boolean
'	Private txtNum As EditText
	Private flEditText1 As FloatLabeledEditText
End Sub

Public Sub Initialize (vCallback As Object, vEventName As String)
	EventName = vEventName
	CallBack = vCallback
End Sub

Public Sub DesignerCreateView (Base As Panel, Lbl As Label, Props As Map)
	mBase = Base
	Dim parent As Panel = mBase.Parent
	pnlNumpad.Initialize("")
	pnlNumpad.Visible = False
'	left = Min(mBase.Left + mBase.Width / 2 - 95dip, 100%x - spWidth)
'	If 100%y - mBase.Top - mBase.Height - spHeight > 0 Then
'		'below
'		side = SIDE_DOWN
'		top = mBase.Top + mBase.Height
'	Else If mBase.Top > spHeight Then
'		'above
'		side = SIDE_UP
'		top = mBase.Top - spHeight
'	Else If mBase.Left + mBase.Width + spWidth < 100%x Then
'		'right
'		side = SIDE_RIGHT
'		top = 100%y - spHeight
'		left = mBase.Left + mBase.Width
'	Else
'		'left
'		side = SIDE_LEFT
'		top = 100%y - spHeight
'		left = mBase.Left - spWidth
'	End If
	parent.AddView(pnlNumpad, 5%x, 0%y, 100%x, 100%y)
	mProps = Props
	CallSubDelayed(Me, "LoadPanelLayout")
End Sub

Private Sub LoadPanelLayout
	pnlNumpad.LoadLayout("JokoKeyboard")
	pnlNumpad.Elevation = 10dip
	Dim cd, txtBG As ColorDrawable
'	cd.Initialize(mProps.Get("BackgroundColor"), 3dip)
	cd.Initialize2(0xFFEDEEF2, 3dip, 0, Colors.Transparent)
'	txtBG.Initialize2(Colors.Black,0,0,0)
	pnlNumpad.Background = cd
'	btnDecimal.Visible = mProps.Get("DecimalButton")
	flEditText1.RemoveView
'	flEditText1.InputType = flEditText1.INPUT_TYPE_NONE
	flEditText1.EditText.InputType = flEditText1.EditText.INPUT_TYPE_NONE
	flEditText1.Hint = mProps.Get("Hint")
'	flEditText1.Background = txtBG
	
	Dim xui As XUI
	Dim bb As B4XView = flEditText1.EditText
	bb.SetColorAndBorder(xui.Color_Red,1dip,xui.Color_White,10dip)
	
'	flEditText1.EditText.TextColor = 0xFFADFF2F
'	pnlNumpad.AddView(flEditText1, 0, 0, pnlNumpad.Width, pnlNumpad.Height)
'	flEditText1.EditText.TextColor = Colors.Black
'	SetBackgroundTintList(flEditText1, Colors.Red, 0xFF0020FF)
	mBase.AddView(flEditText1, 0, 0, mBase.Width, mBase.Height)
End Sub

Private Sub flEditText1_FocusChanged (HasFocus As Boolean)
	focused = HasFocus
	If HasFocus Then
		Show
	Else
		Hide
	End If
End Sub

Private Sub flEditText1_Click
	If focused Then Show
End Sub


Public Sub Show
	If pnlNumpad.Visible Then Return
'	If side = SIDE_UP Then
	'		pnlNumpad.SetLayout(left, top + spHeight, spWidth, 0)
'	else if side = SIDE_DOWN Then
'		pnlNumpad.SetLayout(left, top, spWidth, 0)
'	Else If side = SIDE_LEFT Then
'		pnlNumpad.SetLayout(mBase.Left, top, 0, spHeight)
'	Else If side = SIDE_RIGHT Then
'		pnlNumpad.SetLayout(mBase.Left + mBase.Width, top, 0, spHeight)
'	End If
	pnlNumpad.SetLayout(0%x, 63%y, 100%x, 100%y)
	
	pnlNumpad.Visible = True
'	pnlNumpad.SetLayoutAnimated(mProps.Get("AnimationDuration"), 5%x, 58%y, 100%x, 100%y)
End Sub

Public Sub Hide
	pnlNumpad.Visible = False
End Sub

Public Sub GetBase As Panel
	Return mBase
End Sub

Private Sub btnOK_Click
	Hide
End Sub

Private Sub btnX_Click
	flEditText1.Text = ""
End Sub

Private Sub numpadButton_Click
	Dim b As Button = Sender
	If b.Text = "." And flEditText1.Text.Contains(".") Then Return
	flEditText1.Text = flEditText1.Text & b.Text
	
	LogColor(flEditText1.Text, Colors.Cyan)
End Sub

Private Sub btnDel_Click
	If flEditText1.Text.Length > 0 Then
		flEditText1.Text = flEditText1.Text.SubString2(0, flEditText1.Text.Length - 1)
	End If
End Sub

Private Sub btnDel_LongClick
	flEditText1.Text = ""
End Sub

Public Sub getText As String
	Return flEditText1.Text
End Sub

Public Sub setText(s As String)
	If flEditText1.IsInitialized = False Then
		CallSubDelayed2(Me, "setText", s)
		Return
	End If
	flEditText1.Text = s
End Sub

Sub SetBackgroundTintList(View As View,Active As Int, Enabled As Int)
	Dim States(2,1) As Int
	States(0,0) = 16842908     'Active
	States(1,0) = 16842910    'Enabled
	Dim Color(2) As Int = Array As Int(Active,Enabled)
	Dim CSL As JavaObject
	CSL.InitializeNewInstance("android.content.res.ColorStateList",Array As Object(States,Color))
	Dim jo As JavaObject
	jo.InitializeStatic("android.support.v4.view.ViewCompat")
	jo.RunMethod("setBackgroundTintList", Array(View, CSL))
End Sub