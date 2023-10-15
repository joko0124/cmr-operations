Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=3
@EndOfDesignText@
'Class module
Sub Class_Globals
End Sub
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
End Sub
Sub SetInputType(ET As EditText,IType() As Int)
	Dim Res As Int = 0
	For Each I As Int In IType
		Res=Bit.Or(Res,I)
	Next
	Dim R As Reflector
	R.Target=ET
	R.RunMethod2("setInputType",Res,"java.lang.int")
End Sub
'Get the InputType for the specified EditText
Sub GetInputType(ET As EditText) As Int
	Dim R As Reflector
	R.Target=ET
	Return R.RunMethod("getInputType")
End Sub
'Get the InputType Class for the specified EditText
Sub GetInputTypeClass(ET As EditText) As Int
	Dim R As Reflector
	R.Target=ET
	Return Bit.And(R.RunMethod("getInputType"),TYPE_MASK_CLASS)
End Sub
'Get the InputType Flags for the specified EditText
Sub GetInputTypeFlags(ET As EditText) As Int
	Dim R As Reflector
	R.Target=ET
	Return Bit.And(R.RunMethod("getInputType"),TYPE_MASK_FLAGS)
End Sub
'Get the InputType Variations for the specified EditText
Sub GetInputTypeVariation(ET As EditText) As Int
	Dim R As Reflector
	R.Target=ET
	Return Bit.And(R.RunMethod("getInputType"),TYPE_MASK_VARIATION)
End Sub
'Added In API level 3 Value = 4 (0x00000004)
'Class For dates AND times. It supports the following variations: TYPE_DATETIME_VARIATION_NORMAL TYPE_DATETIME_VARIATION_DATE, AND TYPE_DATETIME_VARIATION_TIME,.
Sub TYPE_CLASS_DATETIME As Int
	Return 4 '(0x00000004)
End Sub
'Added In API level 3 Value = 2 (0x00000002)
'Class For numeric text. This class supports the following flag: TYPE_NUMBER_FLAG_SIGNED AND TYPE_NUMBER_FLAG_DECIMAL. It also supports the following variations: TYPE_NUMBER_VARIATION_NORMAL AND TYPE_NUMBER_VARIATION_PASSWORD. If you Do Not recognize the variation, normal should be assumed.
Sub TYPE_CLASS_NUMBER As Int
	Return 2 '(0x00000002)
End Sub 
'Added In API level 3 Value = 3 (0x00000003)
'Class For a phone number. This class currently supports no variations OR flags.
Sub TYPE_CLASS_PHONE As Int
	Return 3 '(0x00000003)
End Sub 
'Added In API level 3 Value = 1 (0x00000001)
'Class For normal text. This class supports the following flags (only one of which should be set): TYPE_TEXT_FLAG_CAP_CHARACTERS, TYPE_TEXT_FLAG_CAP_WORDS, AND. TYPE_TEXT_FLAG_CAP_SENTENCES. It also supports the following variations: TYPE_TEXT_VARIATION_NORMAL, AND TYPE_TEXT_VARIATION_URI. If you Do Not recognize the variation, normal should be assumed.
Sub TYPE_CLASS_TEXT As Int
	Return 1 '(0x00000001)
End Sub 
'Added In API level 3 Value = 16 (0x00000010)
'Default variation of TYPE_CLASS_DATETIME: allows entering only a date.
Sub TYPE_DATETIME_VARIATION_DATE As Int
	Return 16 '(0x00000010)
End Sub 
'Added In API level 3 Value = 0 (0x00000000)
'Default variation of TYPE_CLASS_DATETIME: allows entering both a date AND time.
Sub TYPE_DATETIME_VARIATION_NORMAL As Int
	Return 0 '(0x00000000)
End Sub 
'Added In API level 3 Value = 32 (0x00000020)
'Default variation of TYPE_CLASS_DATETIME: allows entering only a time.
Sub TYPE_DATETIME_VARIATION_TIME As Int
	Return 32 '(0x00000020)
End Sub 
'Added In API level 3 Value = 15 (0x0000000f)
'Mask of bits that determine the overall class of text being given. Currently supported classes are: TYPE_CLASS_TEXT, TYPE_CLASS_NUMBER, TYPE_CLASS_PHONE, TYPE_CLASS_DATETIME. If the class Is Not one you understand, assume TYPE_CLASS_TEXT with NO variation OR flags.
Sub TYPE_MASK_CLASS As Int
	Return 15 '(0x0000000f)
End Sub 
'Added In API level 3 Value = 16773120 (0x00fff000)
'Mask of bits that provide addition Bit flags of options.
Sub TYPE_MASK_FLAGS As Int
	Return 16773120 '(0x00fff000)
End Sub 
'Added In API level 3 Value = 4080 (0x00000ff0)
'Mask of bits that determine the variation of the base content class.
Sub TYPE_MASK_VARIATION As Int
	Return 4080 '(0x00000ff0)
End Sub 
'Added In API level 3 Value = 0 (0x00000000)
'Special content Type For when no explicit Type has been specified. This should be interpreted To mean that the target input connection Is Not rich, it can Not process AND show things like candidate text nor retrieve the current text, so the input method will need To run In a limited "generate key events" mode.
Sub TYPE_NULL As Int
	Return 0 '(0x00000000)
End Sub 
'Added In API level 3 Value = 8192 (0x00002000)
'Flag of TYPE_CLASS_NUMBER: the number Is decimal, allowing a decimal point To provide fractional values.
Sub TYPE_NUMBER_FLAG_DECIMAL As Int
	Return 8192 '(0x00002000)
End Sub 
'Added In API level 3 Value = 4096 (0x00001000)
'Flag of TYPE_CLASS_NUMBER: the number Is signed, allowing a positive OR negative sign at the start.
Sub TYPE_NUMBER_FLAG_SIGNED As Int
	Return 4096 '(0x00001000)
End Sub 
'Added In API level 11 Value = 0 (0x00000000)
'Default variation of TYPE_CLASS_NUMBER: plain normal numeric text. This was added In HONEYCOMB. An IME must target this API version OR later To see this input Type; If it doesn't, a request for this type will be dropped when passed through EditorInfo.makeCompatible(int).
Sub TYPE_NUMBER_VARIATION_NORMAL As Int
	Return 0 '(0x00000000)
End Sub 
'Added In API level 11 Value = 16 (0x00000010)
'Variation of TYPE_CLASS_NUMBER: entering a numeric password. This was added In HONEYCOMB. An IME must target this API version OR later To see this input Type; If it doesn't, a request for this type will be dropped when passed through EditorInfo.makeCompatible(int). 
Sub TYPE_NUMBER_VARIATION_PASSWORD As Int
	Return 16 '(0x00000010)
End Sub 
''Added In API level 3 Value = 65536 (0x00010000) Requires system to be written
''Flag For TYPE_CLASS_TEXT: the text editor Is performing auto-completion of the text being entered based on its own semantics, which it will present To the user As they Type. This generally means that the input method should Not be showing candidates itself, but can expect For the editor To supply its own completions/candidates from InputMethodSession.displayCompletions() As a result of the editor calling InputMethodManager.displayCompletions().
'Sub TYPE_TEXT_FLAG_AUTO_COMPLETE
'	Return 65536 '(0x00010000)
'End Sub

'Added In API level 3 Value = 32768 (0x00008000)
'Flag For TYPE_CLASS_TEXT: the user Is entering free-form text that should have auto-correction applied To it.
Sub TYPE_TEXT_FLAG_AUTO_CORRECT As Int
	Return 32768 '(0x00008000)
End Sub 
'Added In API level 3 Value = 65536 (0x00010000)
'Flag For TYPE_CLASS_TEXT: the user Is entering free-form text that should have auto-correction applied To it.
Sub TYPE_TEXT_FLAG_AUTO_COMPLETE As Int
	Return 65536 '(0x00008000)
End Sub
'Added In API level 3 Value = 4096 (0x00001000)
'Flag For TYPE_CLASS_TEXT: capitalize all characters. Overrides TYPE_TEXT_FLAG_CAP_WORDS AND TYPE_TEXT_FLAG_CAP_SENTENCES. This value Is explicitly defined To be the same As CAP_MODE_CHARACTERS.
Sub TYPE_TEXT_FLAG_CAP_CHARACTERS As Int
	Return 4096 '(0x00001000)
End Sub 
'Added In API level 3 Value = 16384 (0x00004000)
'Flag For TYPE_CLASS_TEXT: capitalize first character of Each sentence. This value Is explicitly defined To be the same As CAP_MODE_SENTENCES.
Sub TYPE_TEXT_FLAG_CAP_SENTENCES As Int
	Return 16384 '(0x00004000)
End Sub 
'Added In API level 3 Value = 8192 (0x00002000)
'Flag For TYPE_CLASS_TEXT: capitalize first character of all words. Overrides TYPE_TEXT_FLAG_CAP_SENTENCES. This value Is explicitly defined To be the same As CAP_MODE_WORDS.
Sub TYPE_TEXT_FLAG_CAP_WORDS As Int
	Return 8192 '(0x00002000)
End Sub 
'Added In API level 3 Value = 262144 (0x00040000)
'Flag For TYPE_CLASS_TEXT: the regular text View associated with this should Not be multi-line, but when a fullscreen input method Is providing text it should use multiple lines If it can.
Sub TYPE_TEXT_FLAG_IME_MULTI_LINE As Int
	Return 262144 '(0x00040000)
End Sub 
'Added In API level 3 Value = 131072 (0x00020000)
'Flag For TYPE_CLASS_TEXT: multiple lines of text can be entered into the field. If this flag Is Not set, the text field will be constrained To a single line.
Sub TYPE_TEXT_FLAG_MULTI_LINE As Int
	Return 131072 '(0x00020000)
End Sub 
'Added In API level 5 = 524288 (0x00080000)
'Flag For TYPE_CLASS_TEXT: the input method does Not need To display any dictionary-based candidates. This Is useful For text views that Do Not contain words from the language AND Do Not benefit from any dictionary-based completions OR corrections. It overrides the TYPE_TEXT_FLAG_AUTO_CORRECT value when set.
Sub TYPE_TEXT_FLAG_NO_SUGGESTIONS As Int
	Return 524288 '(0x00080000)
End Sub 
'Added In API level 3 Value = 32 (0x00000020)
'Variation of TYPE_CLASS_TEXT: entering an e-mail address.
Sub TYPE_TEXT_VARIATION_EMAIL_ADDRESS As Int
	Return 32 '(0x00000020)
End Sub 
'Added In API level 3 Value = 48 (0x00000030)
'Variation of TYPE_CLASS_TEXT: entering the subject line of an e-mail.
Sub TYPE_TEXT_VARIATION_EMAIL_SUBJECT As Int
	Return 48 '(0x00000030)
End Sub 
'Added In API level 3 Value = 176 (0x000000b0)
'Variation of TYPE_CLASS_TEXT: entering text To filter contents of a List etc.
Sub TYPE_TEXT_VARIATION_FILTER As Int
	Return 176 '(0x000000b0)
End Sub 
'Added In API level 3 Value = 80 (0x00000050)
'Variation of TYPE_CLASS_TEXT: entering the content of a Long, possibly formal message such As the body of an e-mail.
Sub TYPE_TEXT_VARIATION_LONG_MESSAGE As Int
	Return 80 '(0x00000050)
End Sub 
'Added In API level 3 Value = 0 (0x00000000)
'Default variation of TYPE_CLASS_TEXT: plain old normal text.
Sub TYPE_TEXT_VARIATION_NORMAL As Int
	Return 0 '(0x00000000)
End Sub 
'Added In API level 3 Value = 128 (0x00000080)
'Variation of TYPE_CLASS_TEXT: entering a password.
Sub TYPE_TEXT_VARIATION_PASSWORD As Int
	Return 128 '(0x00000080)
End Sub 
'Added In API level 3 Value = 96 (0x00000060)
'Variation of TYPE_CLASS_TEXT: entering the name of a person.
Sub TYPE_TEXT_VARIATION_PERSON_NAME As Int
	Return 96 '(0x00000060)
End Sub 
'Added In API level 3 Value = 192 (0x000000c0)
'Variation of TYPE_CLASS_TEXT: entering text For phonetic pronunciation, such As a phonetic name field In contacts.
Sub TYPE_TEXT_VARIATION_PHONETIC As Int
	Return 192 '(0x000000c0)
End Sub 
'Added In API level 3 Value = 112 (0x00000070)
'Variation of TYPE_CLASS_TEXT: entering a postal mailing address.
Sub TYPE_TEXT_VARIATION_POSTAL_ADDRESS As Int
	Return 112 '(0x00000070)
End Sub 
'Added In API level 3 Value = 64 (0x00000040)
'Variation of TYPE_CLASS_TEXT: entering a Short, possibly informal message such As an instant message OR a text message.
Sub TYPE_TEXT_VARIATION_SHORT_MESSAGE As Int
	Return 64 '(0x00000040)
End Sub 
'Added In API level 3 Value = 16 (0x00000010)
'Variation of TYPE_CLASS_TEXT: entering a URI.
Sub TYPE_TEXT_VARIATION_URI As Int
	Return 16 '(0x00000010)
End Sub 
'Added In API level 3 Value = 144 (0x00000090)
'Variation of TYPE_CLASS_TEXT: entering a password, which should be visible To the user.
Sub TYPE_TEXT_VARIATION_VISIBLE_PASSWORD As Int
	Return 144 '(0x00000090)
End Sub 
'Added In API level 3 Value = 160 (0x000000a0)
'Variation of TYPE_CLASS_TEXT: entering text inside of a web form.
Sub TYPE_TEXT_VARIATION_WEB_EDIT_TEXT As Int
	Return 160 '(0x000000a0)
End Sub 
'Added In API level 11 Value = 208 (0x000000d0)
'Variation of TYPE_CLASS_TEXT: entering e-mail address inside of a web form. This was added In HONEYCOMB. An IME must target this API version OR later To see this input Type; If it doesn't, a request for this type will be seen as TYPE_TEXT_VARIATION_EMAIL_ADDRESS when passed through EditorInfo.makeCompatible(int).
Sub TYPE_TEXT_VARIATION_WEB_EMAIL_ADDRESS As Int
	Return 208 '(0x000000d0)
End Sub 
'Added In API level 11 Value = 224 (0x000000e0)
'Variation of TYPE_CLASS_TEXT: entering password inside of a web form. This was added In HONEYCOMB. An IME must target this API version OR later To see this input Type; If it doesn't, a request for this type will be seen as TYPE_TEXT_VARIATION_PASSWORD when passed through EditorInfo.makeCompatible(int).
Sub TYPE_TEXT_VARIATION_WEB_PASSWORD As Int
	Return 224 '(0x000000e0)
End Sub