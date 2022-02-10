AutoHotScrip key
Window arrangement:
TL = Function (filtered for Manager_ && __readData)
TR = Code window
BL = Programmer Notepad with tab saving the manager data on tab 1

Keys:
q = click down, copy data over
w = If the function did not load in time, it will ask if you want to overwrite. w is set up to cancel the save and redo the copy

w::
	Click, 320 105
	Click, 785 488
	WinActivate, CodeBrowser
	WinWait, CodeBrowser
	Click, 700 420
	Sleep, 200
	Send, ^a
	Send, ^c
	WinActivate, Programmer's Notepad
	WinWait, Programmer's Notepad
	Click, 49 92
	Send, ^a
	Send, ^v
	Send, {F3}
	Sleep, 100
	Send, ^c
	Send, !f
	Send, a
	Send, ^v
	Send, {Enter}
	Return

q::
if WinExist("Programmer's Notepad") && WinExist("Functions [CodeBrowser") && WinExist("CodeBrowser: FLO")
{
	{
		WinActivate, Functions [CodeBrowser
		WinWait, Functions [CodeBrowser
		Click, 836 437
		Sleep, 200
		Click, 605 436
		Sleep, 1000
		WinActivate, CodeBrowser
		WinWait, CodeBrowser
		Click, 700 420
		Sleep, 200
		Send, ^a
		Send, ^c
		WinActivate, Programmer's Notepad
		WinWait, Programmer's Notepad
		Click, 49 92
		Send, ^a
		Send, ^v
		Send, {F3}
		Sleep, 100
		Send, ^c
		Send, !f
		Send, a
		Send, ^v
		Send, {Enter}
		Return
	}
}