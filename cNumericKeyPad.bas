Type=Class
Version=7.3
ModulesStructureVersion=1
B4A=true
@EndOfDesignText@
#Region Class_Globals
Sub Class_Globals
	Public  gKBSoundOn  	 						As Boolean = True


	Private ACTION_DOWN = 0 As Int	
	
	Type TKB_ColorDrawable(BGColor As Int, Radius As Int)
	
	Type TKB_FieldInfo(AllowDecimals As Boolean, AllowPrevNext As Boolean, DefaultTextColor  As Int, DefaultBackground  As TKB_ColorDrawable, _
												 						   SelectedTextColor As Int, SelectedBackground As TKB_ColorDrawable, PrefixRoutine As String)

'	Type TKB_FieldInfo(AllowDecimals As Boolean, AllowPrevNext As Boolean, DefaultTextColor  As Int, DefaultBackground  As GradientDrawable, _
'												 						   SelectedTextColor As Int, SelectedBackground As GradientDrawable, PrefixRoutine As String)
												 
	Type TKB_FieldEntry(Field As Label, FieldInfo_PreviousValue As String, FieldInfo As TKB_FieldInfo, DoNextPrev As Boolean, RelativeOnFly As Boolean, RelativeX As Int, RelativeY As Int)
	
	Private sID_KB_Frame 							As Panel
	Private 	sID_KB_DragBar 						As Panel	
	Private 		sID_DragHere 					As Label
	Private			sID_SoundToggle					As ImageView
	
	Private 	sID_KB_Panel						As Panel	
	Private 		sID_KB 							As Panel
	Private 			sID_KB_Next 				As Button
	Private 			sID_KB_Clear 				As Button	
	Private 			sID_KB_Previous 			As Button	
	Private	 			sID_KB_1 					As Button
	Private 			sID_KB_2 					As Button
	Private 			sID_KB_3 					As Button
	
	Private 			sID_KB_4 					As Button
	Private 			sID_KB_5 					As Button
	Private 			sID_KB_6 					As Button
	
	Private 			sID_KB_7 					As Button
	Private 			sID_KB_8 					As Button
	Private 			sID_KB_9 					As Button
	
	Private 			sID_KB_0 					As Button	
	Private 			sID_KB_Decimal 				As Button
	Private 			sID_KB_Enter 				As Button

	Private mInitialize								As Boolean = False
			
	Private mKBShowing								As Boolean = False	

	Private mRelativeOnFly							As Boolean = False
	Private mDoNextPrev								As Boolean = True	

	Private mKBSound	    					    As MediaPlayer	
    Private mBeeperOK1 							    As Beeper
    Private mBeeperOK2 							    As Beeper
		
	Private mKBSoundOn_Bitmap						As BitmapDrawable
	Private mKBSoundOff_Bitmap						As BitmapDrawable
		
	Private mView									As View
	Private mObjectAP								As Object
	
	Private mCallBack								As Object
	
	Private mKeyBoardPanel							As Panel
	
	Private mDownX									As Float = -1
	Private mDownY									As Float = -1

	Private mShowPressed							As String		
	
	Private mFieldsList								As List
	Private mEditingField							As Int	 = -1		
	
    Private mIMELibrary   		                    As IME
End Sub
#end Region

#Region MakeKBFieldInfo
Public  Sub MakeKBColorDrawable(BGColor As Int, Radius As Int) As TKB_ColorDrawable
    		Dim GradDrawable As TKB_ColorDrawable

    		GradDrawable.Initialize
			GradDrawable.BGColor	 = BGColor
			GradDrawable.Radius		 = Radius
			
			Return GradDrawable
End Sub

Public  Sub MakeKBFieldInfo(AllowDecimals As Boolean, AllowPrevNext As Boolean,	DefaultTextColor  As Int, DefaultBackground  As TKB_ColorDrawable, _
													  							SelectedTextColor As Int, SelectedBackground As TKB_ColorDrawable, PrefixRoutine As String) As TKB_FieldInfo	
	   		Dim FieldInfo As TKB_FieldInfo
	   
	   		FieldInfo.Initialize
			FieldInfo.AllowDecimals		 = AllowDecimals
			FieldInfo.AllowPrevNext		 = AllowPrevNext

			FieldInfo.DefaultTextColor	 = DefaultTextColor			
			FieldInfo.SelectedTextColor	 = SelectedTextColor
			FieldInfo.PrefixRoutine		 = PrefixRoutine

			
			FieldInfo.DefaultBackground.Initialize
	   		FieldInfo.DefaultBackground.BGColor 		= DefaultBackground.BGColor
			FieldInfo.DefaultBackground.Radius 			= DefaultBackground.Radius

			FieldInfo.SelectedBackground.Initialize
	   		FieldInfo.SelectedBackground.BGColor 		= SelectedBackground.BGColor
			FieldInfo.SelectedBackground.Radius 		= SelectedBackground.Radius
											
			Return FieldInfo
End Sub
#end Region

#Region Initialize
Public  Sub Initialize(CallBack As Object, UseAP As Object, KeyClickSoundOn As Boolean)
	
			mObjectAP	  	= UseAP
			mView		  	= UseAP
			
			mCallBack	  	= CallBack
			
			gKBSoundOn		= KeyClickSoundOn
			
			mShowPressed  	= ""
			mEditingField 	= -1
		   
		   
		   
		    LoadKeyBoard
			
			HideKeyBoard
			
			mFieldsList.Initialize
									
			mKBShowing  = False
			
			mBeeperOK1.Initialize2(100, 2000, mBeeperOK1.VOLUME_NOTIFICATION)			
			mBeeperOK2.Initialize2(100, 2250, mBeeperOK2.VOLUME_NOTIFICATION)	
			
			mInitialize = True		
			
		    mIMELibrary.Initialize("")
End Sub
#end Region

#region IsShowing
Public  Sub IsShowing As Boolean
			Return mKBShowing
End Sub
#End Region

#Region LoadKeyBoard
Private Sub LoadKeyBoard
						
			If  mKeyBoardPanel.IsInitialized = False Then 
			    mKeyBoardPanel.Initialize("KeyBoardPad")
			    mKeyBoardPanel.Color   = Colors.Transparent
			    mKeyBoardPanel.Visible = False
			    mKeyBoardPanel.Enabled = False
			   			
			    mKeyBoardPanel.RemoveAllViews
			
			    If  mObjectAP Is Panel Then
			   	  	Dim UseView As Panel = mObjectAP
				  
			      	UseView.AddView(mKeyBoardPanel, 0, 0, mView.Width, mView.Height)
			    Else
'			   	  	Dim UseAct  As Activity = mObjectAP
				  
			      	UseView.AddView(mKeyBoardPanel, 0, 0, mView.Width, mView.Height)				  
			    End If
			   			
				If  Starter.gScrollingScreen Or cUserPreferences.UserSmallerKeyPad Then
					mKeyBoardPanel.LoadLayout("sNumericKeyPad_Small")
				Else				
				   	mKeyBoardPanel.LoadLayout("sNumericKeyPad")
				End If
			
		       	mKBSound.Initialize
    		   	mKBSound.Load(File.DirAssets, "kbsound.ogg")
			
		       	mKBSoundOn_Bitmap.Initialize(LoadBitmap(File.DirAssets, "speakeron.png"))
		       	mKBSoundOff_Bitmap.Initialize(LoadBitmap(File.DirAssets, "speakeroff.png"))
						   
			   	ShowSoundIcon						
			   
			   	sID_KB_Frame.Left = (mView.Width  - sID_KB_Frame.Width)  / 2
			   	sID_KB_Frame.Top  = (mView.Height - sID_KB_Frame.Height) / 2			   			   
			End If
End Sub
#end Region

#Region AddFieldsArray
Public  Sub AddFieldsArray(ClearBeforeAdding As Boolean, Fields() As Label, KBInfo As TKB_FieldInfo)
	
			Dim i As Int
		
			If mInitialize = False				 Then Return
			
			If mFieldsList.IsInitialized = False Then mFieldsList.Initialize
			
			If ClearBeforeAdding 				 Then mFieldsList.Clear
			
			For i = 0 To Fields.Length-1
				Dim FieldEntry As TKB_FieldEntry
				
				FieldEntry.Initialize
				FieldEntry.FieldInfo 	 = KBInfo
				FieldEntry.Field	 	 = Fields(i)
				
				FieldEntry.DoNextPrev	 = mDoNextPrev
				FieldEntry.RelativeOnFly = mRelativeOnFly	
				
			    FieldEntry.RelativeX 	 = cRelativePosition.Left(Fields(i))
			    FieldEntry.RelativeY 	 = cRelativePosition.Top(Fields(i))
				
				mFieldsList.Add(FieldEntry)
			Next
End Sub
#end Region

#Region AddSingleFieldEdit
Public  Sub AddSingleFieldEdit(Field As Label, KBInfo As TKB_FieldInfo)
			If mInitialize = False				 Then Return
			
			If mFieldsList.IsInitialized = False Then mFieldsList.Initialize
			
			mFieldsList.Clear
			
			Dim FieldEntry As TKB_FieldEntry
				
			FieldEntry.Initialize
			FieldEntry.FieldInfo 	 = KBInfo
			FieldEntry.Field	 	 = Field
				
			FieldEntry.DoNextPrev	 = False
			FieldEntry.RelativeOnFly = mRelativeOnFly	
				
			FieldEntry.RelativeX 	 = cRelativePosition.Left(Field)
			FieldEntry.RelativeY 	 = cRelativePosition.Top(Field)
				
			mFieldsList.Add(FieldEntry)
			
			EditingFieldByID(0)
End Sub
#end region

#Region DoneEditingField                                          
Private Sub DoneEditingField(FieldEntry As TKB_FieldEntry, CallNow As Boolean)
			If mInitialize = False Then Return
			
			StopEdit(FieldEntry, True)
			
			If 	SubExists(mCallBack, FieldEntry.FieldInfo.PrefixRoutine&"_OnDone") Then 
				If  CallNow Then
					CallSub3(mCallBack, FieldEntry.FieldInfo.PrefixRoutine&"_OnDone", FieldEntry.Field, FieldEntry.FieldInfo_PreviousValue)
				Else
					CallSubDelayed3(mCallBack, FieldEntry.FieldInfo.PrefixRoutine&"_OnDone", FieldEntry.Field, FieldEntry.FieldInfo_PreviousValue)					
				End If
#if Debug				
			Else
				CallSubDelayed3("Main", "Error_MsgBox", "SubRoutine: [" &FieldEntry.FieldInfo.PrefixRoutine &"_OnDone] - NOT Found", "DoneEditingField")
#end if			
			End If
End Sub
#end Region

#Region EditingField
Public  Sub EditingFieldByID(FieldID As Int)
			If mInitialize = False Then Return
	
			If FieldID >= 0 And FieldID < mFieldsList.Size Then ShowEditingField(FieldID)
End Sub
#end Region

#Region EditByField
Public  Sub EditByField(Field As Label)
			If mInitialize = False Then Return
	
			Dim WasEditing As Int = mEditingField
			
			If mEditingField <> -1 Then DoneEditingField(mFieldsList.Get(mEditingField), False)
			
			mEditingField = -1
			
			Dim i 	  	  	  As Int
			Dim Entry 	  	  As TKB_FieldEntry
			
			Dim RelativeX 	  As Int = cRelativePosition.Left(Field)
			Dim RelativeY 	  As Int = cRelativePosition.Top(Field)
			
			For i = 0 To mFieldsList.Size-1
				Entry = mFieldsList.Get(i)
			
				If Entry.RelativeOnFly Then
				   Entry.RelativeX = cRelativePosition.Left(Entry.Field)
				   Entry.RelativeY = cRelativePosition.Top(Entry.Field)
				End If					

				If RelativeY = Entry.RelativeY And RelativeX = Entry.RelativeX And Field.Width = Entry.Field.Width And Field.Height = Entry.Field.Height Then
				   If WasEditing = i Then Return
				   
				   ShowEditingField(i)
				   Return
				End If
			Next			
End Sub
#end Region

#Region HideKeyBoard
Public  Sub HideKeyBoard As Boolean
			Dim CalledDone As Boolean = False
			
			If mInitialize = False Then Return CalledDone
	
			If mEditingField <> -1 Then  
			   CalledDone = True
			   DoneEditingField(mFieldsList.Get(mEditingField), False)
			End If
			
			mKBShowing				= False
			
			mKeyBoardPanel.Enabled	= False
			mKeyBoardPanel.Visible  = False
			
			
			mEditingField = -1
			mShowPressed  = ""
			
			Return CalledDone
End Sub
#end Region

Public  Sub EditingAField As Boolean
			If mEditingField <> -1 And mEditingField >= 0 And mEditingField < mFieldsList.Size Then Return True
			
			Return False
End Sub

Public  Sub EditingThisField As TKB_FieldEntry
			
			If mEditingField <> -1 And mEditingField >= 0 And mEditingField < mFieldsList.Size Then Return mFieldsList.Get(mEditingField)
			

			Dim EmptyField As TKB_FieldEntry

			EmptyField.Initialize
			EmptyField.Field.Initialize("")
			EmptyField.FieldInfo.Initialize

			Return EmptyField	
End Sub

Public  Sub DoneEditing
			If mInitialize = False Then Return
	
			If mEditingField <> -1 Then DoneEditingField(mFieldsList.Get(mEditingField), False)
End Sub

Public  Sub DoneEditingCallNow
			If mInitialize = False Then Return
	
			If mEditingField <> -1 Then DoneEditingField(mFieldsList.Get(mEditingField), True)
End Sub

#Region Sets / Gets
Public  Sub setDoNextPrev(DoNextPrev As Boolean)
			mDoNextPrev = DoNextPrev
End Sub

Public  Sub setTop(Top As Int)
			sID_KB_Frame.Top = Top			
End Sub

Public  Sub getTop As Int
			Return sID_KB_Frame.Top			
End Sub

Public  Sub setLeft(Left As Int)
			sID_KB_Frame.Left = Left
End Sub

Public  Sub getLeft As Int
			Return sID_KB_Frame.Left
End Sub

Public  Sub getWidth As Int
			Return sID_KB_Frame.Width
End Sub

Public  Sub getHeight As Int
			Return sID_KB_Frame.Height						
End Sub
#end Region

Private Sub MakeColorDrawable(KBColorDrawable As TKB_ColorDrawable) As ColorDrawable
	
			Dim MakeCD As ColorDrawable

			MakeCD.Initialize(KBColorDrawable.BGColor, KBColorDrawable.Radius)
	
			Return MakeCD
End Sub	

#Region ShowEditingField
Private Sub ShowEditingField(Editing As Int)
	
			If mInitialize = False Then Return
	
			mIMELibrary.HideKeyboard
			
			If Editing < 0 Or Editing >= mFieldsList.Size Then Return
			
			mEditingField   = Editing 
			
			If mEditingField = -1 Then Return
			
			Dim FieldEntry As TKB_FieldEntry = mFieldsList.Get(mEditingField)
	
			FieldEntry.Field.Background 		= MakeColorDrawable(FieldEntry.FieldInfo.SelectedBackground)
			FieldEntry.Field.TextColor  		= FieldEntry.FieldInfo.SelectedTextColor
			FieldEntry.FieldInfo_PreviousValue	= FieldEntry.Field.Text
			

			If mKeyBoardPanel.IsInitialized = False Then LoadKeyBoard
			
			ShowSoundIcon			
			
			If mKBShowing = False Then
			   mKBShowing = True
			   
			   mKeyBoardPanel.Enabled  = True
			   mKeyBoardPanel.Visible  = True
			End If
			
			mKeyBoardPanel.BringToFront

			Dim FieldEntry As TKB_FieldEntry = mFieldsList.Get(mEditingField)
			
		    sID_KB_Decimal.Enabled  = FieldEntry.FieldInfo.AllowDecimals
		    sID_KB_Decimal.Visible  = FieldEntry.FieldInfo.AllowDecimals
			
			sID_KB_Previous.Enabled = FieldEntry.FieldInfo.AllowPrevNext
			sID_KB_Previous.Visible = FieldEntry.FieldInfo.AllowPrevNext			
			
			sID_KB_Next.Enabled 	= FieldEntry.FieldInfo.AllowPrevNext
			sID_KB_Next.Visible 	= FieldEntry.FieldInfo.AllowPrevNext			
			
			
			Dim RelativeX As Int = cRelativePosition.Left(FieldEntry.Field)
			Dim RelativeY As Int = cRelativePosition.Top(FieldEntry.Field)

			Dim FieldRect As Rect
			Dim KBRect	  As Rect
			
			FieldRect.Initialize(RelativeX, 	 RelativeY, 	   (RelativeX + FieldEntry.Field.Width), 	 (RelativeY + FieldEntry.Field.Height))
			KBRect.Initialize(sID_KB_Frame.Left, sID_KB_Frame.Top, (sID_KB_Frame.Left + sID_KB_Frame.Width), (sID_KB_Frame.Top + sID_KB_Frame.Height))
			
			If KBOverlaps(FieldRect, KBRect) Or KBOffScreen(KBRect) Then 
			   KBRect = MoveKB(FieldRect, KBRect)

			   sID_KB_Frame.Top  = KBRect.Top			   
			   sID_KB_Frame.Left = KBRect.Left			   
			End If
End Sub
#end Region

#Region s_ID_KB_Frame_Touch
Public  Sub sID_KB_Frame_Touch(Action As Int, X As Float, Y As Float)

#if Debug
			Log("sID_KB_Frame_Touch")			
#end if
			
    		If Action = ACTION_DOWN Then 
	   		   mDownX = X
	   		   mDownY = Y
	   		   Return
    		End If

			Dim WasLeft As Int = sID_KB_Frame.Left 			
			Dim WasTop  As Int = sID_KB_Frame.Top
			
    		sID_KB_Frame.Left = sID_KB_Frame.Left + X - mDownX
    		sID_KB_Frame.Top  = sID_KB_Frame.Top  + Y - mDownY	
			
			If sID_KB_Frame.Left < 0 Or sID_KB_Frame.Left > (mView.Width  - sID_KB_Frame.Width)  Then sID_KB_Frame.Left = WasLeft
			If sID_KB_Frame.Top  < 0 Or sID_KB_Frame.Top  > (mView.Height - sID_KB_Frame.Height) Then sID_KB_Frame.Top  = WasTop
End Sub
#end Region

#Region sID_KB_Key_Click
Private Sub sID_KB_Key_Click
			If  mEditingField = -1 Then Return
				
			If  gKBSoundOn		  Then mKBSound.Play
								
									
			Dim PrevEditing   As Int    = mEditingField									
			Dim NextEditing   As Int    = -1
			
			Dim ButtonPressed As Button = Sender
		    Dim FieldEntry	  As TKB_FieldEntry
			Dim PrevField	  As TKB_FieldEntry = mFieldsList.Get(mEditingField)


			If  ButtonPressed.Tag = "Enter" Then
			    HideKeyBoard
			   
			    DoneEditingField(PrevField, False)			   
			    Return
			End If

									
			If  ButtonPressed.Tag = "Clr" Then
			    mShowPressed 		 = ""
			   
			    FieldEntry			 = mFieldsList.Get(mEditingField)			   
			    FieldEntry.Field.Text = mShowPressed			   
			    Return
			End If
		
			If  ButtonPressed.Tag = ">" Or ButtonPressed.Tag = "<" Then			   
			    '-------------------------------------------------------------------------------------------------------
			    '  Does the user want to handle next / prev keys	
			    '-------------------------------------------------------------------------------------------------------			   
			   If  PrevField.DoNextPrev = False Then
			   	   '----------------------------------------------------------------------------------------------------
				   '  The user does.  Complete this field
				   '----------------------------------------------------------------------------------------------------
				   StopEdit(PrevField, False)
				  				  
				   '----------------------------------------------------------------------------------------------------
				   '  See if Next / Prev Sub Routine exists and if it does call it
				   '----------------------------------------------------------------------------------------------------
				  If  ButtonPressed.Tag = ">" Then
				     If  SubExists(mCallBack, PrevField.FieldInfo.PrefixRoutine&"_NextField") Then 
					     CallSubDelayed3(mCallBack, PrevField.FieldInfo.PrefixRoutine&"_NextField", PrevField.Field, PrevField.FieldInfo_PreviousValue)
#if Debug				
				     Else
					     CallSubDelayed3("Main", "Error_MsgBox", "SubRoutine: [" &PrevField.FieldInfo.PrefixRoutine &"_NextField] - NOT Found", "NextField")
#end if			
				     End If
				  Else
				     If  SubExists(mCallBack, PrevField.FieldInfo.PrefixRoutine&"_PrevField") Then 
					      CallSubDelayed3(mCallBack, PrevField.FieldInfo.PrefixRoutine&"_PrevField", PrevField.Field, PrevField.FieldInfo_PreviousValue)
#if Debug				
				     Else
					      CallSubDelayed3("Main", "Error_MsgBox", "SubRoutine: [" &PrevField.FieldInfo.PrefixRoutine &"_PrevField] - NOT Found", "PrevField")
#end if			
				     End If
				  End If				  	
				  
				  Return
			   End If 
				
			   Dim i  As Int
				
			   mShowPressed = ""
			   
			   If  ButtonPressed.Tag = ">" Then			   	
			   	   For i = mEditingField+1 To mFieldsList.Size-1
				  	   FieldEntry = mFieldsList.Get(i)
					  
					   If  FieldEntry.Field.Visible And FieldEntry.Field.Enabled Then Exit	
				   Next
				  
				   If  i >= mFieldsList.Size Then
			   	   	   For i = 0 To mFieldsList.Size-1
				  	 	   FieldEntry = mFieldsList.Get(i)
					  
					  	   If  FieldEntry.Field.Visible And FieldEntry.Field.Enabled Then Exit	
				  	   Next
				  
				  	   If  i < 0 Or i >= mFieldsList.Size Then Return
				   End If
				  
				   NextEditing = i
			   Else
			   	   For i = mEditingField-1 To 0 Step -1
				  	   FieldEntry = mFieldsList.Get(i)
					  
					   If  FieldEntry.Field.Visible And FieldEntry.Field.Enabled Then Exit	
				   Next
				  
				   If  i < 0 Then 
				  	   For i = mFieldsList.Size-1 To 0 Step -1
					  	   FieldEntry = mFieldsList.Get(i)
					  
					  	   If  FieldEntry.Field.Visible And FieldEntry.Field.Enabled Then Exit						 	
					   Next
				  
				  	   If  i < 0 Or i >= mFieldsList.Size Then Return
			 	  End If
				  		 
				  NextEditing = i
			   End If
	
			   If  PrevEditing <> -1 Then DoneEditingField(PrevField, False)		   				  	   
			   If  NextEditing <> -1 Then ShowEditingField(NextEditing)
			   Return
			End If
		
						
			mShowPressed = mShowPressed &ButtonPressed.Tag
			
			FieldEntry 		      = mFieldsList.Get(mEditingField)			
			FieldEntry.Field.Text = mShowPressed
End Sub
#end Region

#region StopEdit
Public  Sub StopEditing
			If mInitialize = False  Then Return
			If mEditingField <> -1 Then StopEdit(mFieldsList.Get(mEditingField), True)
End Sub

Public  Sub StopEdit(FieldEntry As TKB_FieldEntry, Hide As Boolean)
		    mEditingField  = -1
			mShowPressed   = ""

			FieldEntry.Field.Background = MakeColorDrawable(FieldEntry.FieldInfo.DefaultBackground)
			FieldEntry.Field.TextColor  = FieldEntry.FieldInfo.DefaultTextColor
			
			If Hide Then HideKeyBoard
End Sub
#end region

#Region sID_SoundToggle_LongClick	
Private Sub sID_SoundToggle_LongClick
			mBeeperOK1.Beep
			mBeeperOK2.Beep
	
			gKBSoundOn = Not(gKBSoundOn)
			
			ShowSoundIcon
End Sub

Private Sub ShowSoundIcon	
			If  gKBSoundOn Then
	   	        sID_SoundToggle.Background = mKBSoundOn_Bitmap
			Else
	   		    sID_SoundToggle.Background = mKBSoundOff_Bitmap	
			End If
End Sub	

Public  Sub KBClick
			If  gKBSoundOn Then mKBSound.Play
End Sub
#end Region

'#Region GetRelativeX
'Private Sub GetRelativeX(V As JavaObject) As Int
'			Try 	
'	   		   Dim parent 	  As Object = V.RunMethod("getParent", Null)
'
'	   		   If parent = Null 													Then Return 0
'
'	   		   Dim parentType As String = GetType(parent)
'	   
'	   		   #if Debug
''			   Log("RelativeX ParentType: " &parentType)
'			   #end if
'				If parentType = "anywheresoftware.b4a.objects.ScrollViewWrapper$MyScrollView"				Then Return 0	   			   
'	   			If parentType = "android.widget.FrameLayout"				 								Then Return 0
'				If parentType = "anywheresoftware.b4a.objects.HorizontalScrollViewWrapper$MyHScrollView"	Then Return 0
'				If parentType = "flm.b4a.scrollview2d.ScrollView2DWrapper$MyScrollView"						Then Return 0				
'	   			If parentType = "android.widget.FrameLayout$LayoutParams"									Then Return 0				
'	   			If parentType = "anywheresoftware.b4a.objects.IME$ExtendedBALayout"							Then Return 0
'	   			If parentType = "anywheresoftware.b4a.BALayout$LayoutParams"								Then Return 0
'			   
'       		   Dim VW As View = V
'
'       		   Return VW.Left + GetRelativeX(parent)			   
'			Catch
'			   Return 0
'			End Try
'End Sub
'#End Region
'
'#Region GetRelativeY
'Public  Sub GetRelativeY(V As JavaObject) As Int
'			Try	
'	   			Dim parent 	  As Object = V.RunMethod("getParent", Null)
'
'	   			If parent = Null													Then Return 0
'
'	   			Dim parentType As String = GetType(parent)
'				
'	   		    #if Debug
''			    Log("RelativeY ParentType: " &parentType)
'			    #end if
'				If parentType = "anywheresoftware.b4a.objects.ScrollViewWrapper$MyScrollView"				Then Return 0	   
'	   			If parentType = "android.widget.FrameLayout"				 								Then Return 0
'				If parentType = "anywheresoftware.b4a.objects.HorizontalScrollViewWrapper$MyHScrollView"	Then Return 0
'				If parentType = "flm.b4a.scrollview2d.ScrollView2DWrapper$MyScrollView"						Then Return 0				
'	   			If parentType = "android.widget.FrameLayout$LayoutParams"									Then Return 0				
'	   			If parentType = "anywheresoftware.b4a.objects.IME$ExtendedBALayout"							Then Return 0
'	   			If parentType = "anywheresoftware.b4a.BALayout$LayoutParams"								Then Return 0
'				
'       			Dim VW As View = V
'
'       			Return VW.Top + GetRelativeY(parent)				
'			Catch
'				Return 0
'			End Try			
'End Sub
'#end Region

#Region KBOffScreen / KBOverlaps [Intersects] / PointInsideKB
Private Sub KBOffScreen(KB As Rect) As Boolean
			Dim Width  As Int = mView.Width
			Dim Height As Int = mView.Height
			
			Dim KBWidth	 As Int = KB.Left + KB.Right
			Dim KBHeight As Int = KB.Top + KB.Bottom
			
			If  KBHeight > Height Or KBWidth  > Width  Then  Return True
			   
			Return False
End Sub


Private Sub KBOverlaps(Field As Rect, KB As Rect) As Boolean
		    If Field.Left  < KB.Right  And Field.Right  > KB.Left And  _
			   Field.Top   < KB.Bottom And Field.Bottom > KB.Top  Then Return True
			   
			Return False
End Sub

'Private Sub PointInsideKB(x As Int, y As Int, KB As Rect) As Boolean
'			If x >= KB.Left And x < KB.Right And _
'			   y >= KB.Top  And y < KB.Bottom Then Return True
'				
'			Return False
'End Sub
#end Region

#Region MoveKB
Private Sub MoveKB(Field As Rect, KB As Rect) As Rect
	
			Dim NewX As Int
			Dim NewY As Int
			
#Region Try To Move Right			
			'------------------------------------------
			'  Try to move to the Right
			'------------------------------------------
			NewX = Field.Right + 5dip
			NewY = KB.Top
			
		    If (NewX + (KB.Right - KB.Left)) < mView.Width Then 
			    KB.Top  = NewY			   	
			 	KB.Left = NewX
				   
				'---------------------------------------
				'  Seeing as we are moving the KB
				'     can we align the two tops?
				'---------------------------------------
				If (Field.Top + (KB.Bottom - KB.Top)) < mView.Height Then
					KB.Top = Field.Top
				End If
																	
				Return KB
			End If	 
#end Region

#Region Try To Move Left
			'------------------------------------------
			'  Try to move to the left
			'------------------------------------------
			NewX = Field.Left - ((KB.Right - KB.Left) + 5dip)
			NewY = KB.Top
			
		    If NewX > 0  Then 
			   KB.Top  = NewY			   	
			   KB.Left = NewX
				   
			   '---------------------------------------
			   '  Seeing as we are moving the KB
			   '     can we align the two tops?
			   '---------------------------------------
			   If (Field.Top + (KB.Bottom - KB.Top)) < mView.Height Then
			       KB.Top = Field.Top
			   End If
				   
			   Return KB
			End If	 
#end Region			

#Region Try To Move Down
			'--------------------------------------------
			'  Can't move to Left or Right			
			'------------------------------------------
			'  Try to move to the Down
			'------------------------------------------
			NewX = KB.Left
			NewY = Field.Bottom + 5dip
			
		    If (NewY + (KB.Bottom - KB.Top)) < mView.Height  Then 
			   KB.Top  = NewY			   	
			   KB.Left = NewX
			   Return KB
			End If	 
#end Region			
			
#Region Try To Move Up			
			'------------------------------------------
			'  Try to move to the Up
			'------------------------------------------
			NewX = KB.Left
			NewY = Field.Top - ((KB.Bottom - KB.Top) + 5dip)
			
		    If NewY >= 0  Then 
			   KB.Top  = NewY			   	
			   KB.Left = NewX
			   Return KB
			End If	 
#end region					
			Return KB
End Sub
#end Region
