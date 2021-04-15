#IfWinActive, ahk_class POEWindowClass

global mouseX := 0
global mouseY := 0
global SHAPER_MAPS := ["Pit of the Chimera", "Maze of the Minotaur", "Lair of the Hydra", "Forge of the Phoenix"]

CheckMouse()
{
	MouseGetPos, xPos, yPos
	if Abs(mouseX - xPos) > 10 or Abs(mouseY - yPos) > 10
	{
		HideWindow()
	}
}

StartTimer()
{
	MouseGetPos, xPos, yPos
	mouseX := xPos
	mouseY := yPos
	SetTimer, CheckMouse, 100
}

StopTimer()
{
	SetTimer, CheckMouse, Off
}

HideWindow()
{
	Gui, Destroy
	StopTimer()
}

RegionForMap(map)
{
	mapRegion := 0
	Loop 8
	{
		idx = %A_Index%
		FileReadLine, line, %A_ScriptDir%\data\regions.txt, idx
		maps := StrSplit(line, ",")
		for index, element in maps
		{
			if element = %map%
			{
				mapRegion := idx
				break
			}
		}
	}
	retVal := "Unknown"
	if mapRegion = 1 
	{
		retVal := "Glennach Cairns"
	} 
	else if mapRegion = 2
	{
		retVal := "Haewark Hamlet"
	} 
	else if mapRegion = 3 
	{
		retVal := "Lex Ejoris"
	} 
	else if mapRegion = 4 
	{
		retVal := "Lex Proxima"
	} 
	else if mapRegion = 5 
	{
		retVal := "Lira Arthain"
	} 
	else if mapRegion = 6 
	{
		retVal := "New Vastir"
	} 
	else if mapRegion = 7 
	{
		retVal := "Tirn's End"
	} 
	else if mapRegion = 8 
	{
		retVal := "Valdo's Rest"
	}
	return retval
}

; tier: Int
; maps: Array<String>
; mapText: String
ShowWindow(tier, maps, mapText)
{
	HideWindow()
	; joined := Join("`n", maps)
	Gui, +AlwaysOnTop +Disabled -SysMenu +Owner  ; +Owner avoids a taskbar button.
	for index, element in maps
	{
		if InStr(mapText, element) {
			Gui, Font, cFF0000 s15, Verdana
		} else {
			Gui, Font, c000000 s15, Verdana
		}
		mapRegion := RegionForMap(element)
		Gui, Add, Text, Y+0, %index%. %element% (%mapRegion%)
	}
	MouseGetPos, xPos, yPos
	xPos := xPos + 25
	yPos := yPos - 150
	Gui, Show, NoActivate x%xPos% y%yPos%, Map tier: %tier%  ; NoActivate avoids deactivating the currently active window.
	StartTimer()
}

; returns: Bool (true if handled, false if not handled)
HandleShaperMap(mapText)
{
	for index, element in SHAPER_MAPS
	{
		if InStr(mapText, element)
		{
			ShowWindow(16, SHAPER_MAPS, mapText)
			return true
		}
	}
	return false
}

; mapText: String
; returns: Int (0 if not a map)
GetMapTier(mapText)
{
	split := StrSplit(mapText, "`n", "`r")
	for index, element in Split
	{
		if not InStr(element, "Map Tier:") = 0
		{
			return StrSplit(element, ": ")[2]
		}
	}
	return 0
}

; tier: Int
; returns: Array<String>
GetMaps(tier)
{
	FileReadLine, line, %A_ScriptDir%\data\maps.txt, tier
	return StrSplit(line, ",")
}

; mapText: String
; returns: Void
HandleNonShaperMap(mapText)
{
	tier := GetMapTier(mapText)
	maps := GetMaps(tier)
	ShowWindow(tier, maps, mapText)
}

SleepDefault()
{
	Sleep, 50
}

; returns: Bool
CopyToClipboard()
{
	clipboard := ""
	SleepDefault()
	Send ^{SC02E}
	ClipWait, 2
	if errorlevel
	{
	    return false
	}
	return true
}

; ctrl+H
^sc023::
{
	HideWindow()
	if not CopyToClipboard()
	{
		return
	}
	if HandleShaperMap(clipboard)
	{
		return
	}
	HandleNonShaperMap(clipboard)
}
