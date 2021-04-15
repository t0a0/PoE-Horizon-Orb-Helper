#IfWinActive, ahk_class POEWindowClass

global mouseX := 0
global mouseY := 0
global SHAPER_MAPS := ["Pit of the Chimera", "Maze of the Minotaur", "Lair of the Hydra", "Forge of the Phoenix"]
global REGIONS := ["Glennach Cairns", "Haewark Hamlet", "Lex Ejoris", "Lex Proxima", "Lira Arthain", "New Vastir", "Tirn's End", "Valdo's Rest"]

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
	mapRegion := 9
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
	return mapRegion
}

; maps: Array<String>
; returns: {String: [String]}
GroupMapsByRegion(maps)
{
	groups := []
	for idx, rgn in REGIONS
	{
		groups[idx] := ""
	}
	for idx, map in maps
	{
		mapRegion := RegionForMap(map)
		grp := groups[mapRegion]
		if StrLen(grp)
		{
			grp := grp . ","
		}
		grp := grp . map
		groups[mapRegion] := grp
	}
	return groups
}

; tier: Int
; maps: Array<String>
; mapText: String
ShowWindow(tier, maps, mapText)
{
	Gui, +AlwaysOnTop +Disabled -SysMenu +Owner  ; +Owner avoids a taskbar button.
	groups := GroupMapsByRegion(maps)
	mapNumber := 1
	padding := 5
	for regionIdx, mapList in groups
	{
		if not StrLen(mapList)
		{
			continue
		}
		for i, mapName in StrSplit(mapList, ",")
		{
			clr := "000000"
			if InStr(mapText, mapName) 
			{
				clr := "FF0000"
			}
			Gui, Font, c%clr% s13, Verdana
			mapRegion := REGIONS[regionIdx]
			if regionIdx = 9
			{
				Gui, Add, Text, Y+%padding%, %mapNumber%. %mapName%
			}
			else
			{
				Gui, Add, Text, Y+%padding%, %mapNumber%. %mapName% (%mapRegion%)
			}
			mapNumber += 1
			padding := 0
		}
		padding := 15
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
