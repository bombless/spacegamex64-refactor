; DATA.ASM - All data definitions
; Assemble: ml64 /c data.asm

INCLUDE .\include\structs.inc
INCLUDE .\include\externs.inc

.DATA

; Export all public symbols
PUBLIC PAUSEGAME, UPSCALE_MODE, SHOW_HITBOX
PUBLIC imageHandle, systemTable
PUBLIC helloMessage, endMessage, cyclesMessage, fpsMessage
PUBLIC controlMessage, videoMessage1, videoMessage2, videoMessage3, videoMessage4
PUBLIC mouseMessage, columnMessage, spaceMessage, xMessage
PUBLIC bMessage, BUFFER, modeInfoBuffer, sizeOfInfo, curMode
PUBLIC VIDEOX, VIDEOY, selectedMode, TITLECARD

; Key related exports
PUBLIC index, key
PUBLIC WkeyDescriptor, WkeyNotifyHandle, littleWkeyDescriptor, littleWkeyNotifyHandle
PUBLIC upkeyDescriptor, upkeyNotifyHandle
PUBLIC SkeyDescriptor, SkeyNotifyHandle, littleSkeyDescriptor, littleSkeyNotifyHandle
PUBLIC downkeyDescriptor, downkeyNotifyHandle
PUBLIC AkeyDescriptor, AkeyNotifyHandle, littleAkeyDescriptor, littleAkeyNotifyHandle
PUBLIC leftkeyDescriptor, leftkeyNotifyHandle
PUBLIC DkeyDescriptor, DkeyNotifyHandle, littleDkeyDescriptor, littleDkeyNotifyHandle
PUBLIC rightkeyDescriptor, rightkeyNotifyHandle
PUBLIC ZkeyDescriptor, ZkeyNotifyHandle, littleZkeyDescriptor, littleZkeyNotifyHandle
PUBLIC QkeyDescriptor, QkeyNotifyHandle, littleQkeyDescriptor, littleQkeyNotifyHandle
PUBLIC spacekeyDescriptor, spacekeyNotifyHandle

PUBLIC PRESSEDLEFT, KEYTIMERLEFT, PRESSEDRIGHT, KEYTIMERRIGHT
PUBLIC PRESSEDUP, KEYTIMERUP, PRESSEDDOWN, KEYTIMERDOWN
PUBLIC PRESSEDFIRE, KEYTIMERFIRE
PUBLIC POINTERSTATE, POINTERLOC, POINTERBUTTON
PUBLIC POINTERLEFT, POINTERRIGHT, POINTERUP, POINTERDOWN, POINTERFIRE
PUBLIC COMBLEFT, COMBRIGHT, COMBUP, COMBDOWN, COMBFIRE

; Graphics exports
PUBLIC SPRITEVERSION, TILEMAP0, TILEMAP1
PUBLIC TM0XOFFSET, TM0YOFFSET, TM1XOFFSET, TM1YOFFSET
PUBLIC OUTPUTFBUFFER, OUTPUTFBUFFER_2, UPSCALEDBUFFER
PUBLIC UPSCALEDROW, UPSCALEDCOUNT
PUBLIC FAILEDCPULIST, SUCESSCPUS, NUMBERAP, ENABLEDAP
PUBLIC SPRITES, ENEMY, BOLTS, BOLTCOOLDOWN
PUBLIC COLORRED, COLORORANGE, COLORYELLOW, COLORGREENN
PUBLIC COLORBLUE, COLORGREEN, COLORBLACK

; Game variables exports
PUBLIC TITLEON, STAGE, SHIPX, SHIPY, SHIPTILTY
PUBLIC SHIPHITBOX, SHIPALT, SHIPFUEL
PUBLIC SCROLLTIMER, SCROLLX, SCROLLY, LASTSCROLLX, LASTSCROOLY
PUBLIC GAMEMAPOFFSET, COLUMNTICK, HIDESHADOW, HIT, NOFUEL
PUBLIC PAUSESCROLL, EXPLODETIMER, EXPLODEDELAYTIMER, RESET, WINTIMER

; Framerule exports
PUBLIC MOVEMENTFRAMERULEC, SCROLLFRAMERULEC, FUELFRAMERULEC
PUBLIC ELOGICFRAMERULEC, EXPLODEFRAMERULEC, BOSSMOVEFRAMERULEC
PUBLIC TITLECOUNTER, TITLESWAPCOUNTER

; Time exports
PUBLIC time, EFI_TIME_CAPABILITIES, SECONDS
PUBLIC TSC_PS, TSC_PS2, CYCLESPERFRAME, NEXTFRAME@
PUBLIC FRAMERATE, FRAMECOUNT, S1, S2, MOVEMENTFC

; Protocol GUID exports
PUBLIC TextInputExGUID, GraphicsOutputGUID, MPServicesGUID
PUBLIC ABSOLUTEPOINTERGUID, SIMPLEPOINTERGUID

; Function pointer exports
PUBLIC conIn, conOut, RuntimeServices, BootServices
PUBLIC AllocatePages, OutputString, WaitForEvent, ReadKeyStroke, WaitForKey
PUBLIC SetCursorPosition, LocateProtocol, TextInputEX, RegisterKeyNotify
PUBLIC MPServices, StartupThisAP, StartupAllAPs, GetNumberOfAP, EnableDisableAP
PUBLIC LocateHandleBuffer, ABSOLUTEPOINTER, SIMPLEPOINTER
PUBLIC POINTERGETSTATEABS, POINTERGETSTATESMP, POINTERMODE
PUBLIC getTime, GOP, queryMode, setMode, BLT, mode, maxMode

; Graphics data exports
PUBLIC loadTitleImgBin, shipImg, bgTiles, tilemap, spriteTiles, spriteTiles2

; ============ DATA DEFINITIONS ============

PAUSEGAME       DQ 00H
UPSCALE_MODE    DQ 00H
SHOW_HITBOX     DQ 00H
imageHandle     DQ ?
systemTable     DQ ?

helloMessage    DW 'S', 'T', 'A', 'R', 'T', 'I', 'N', 'G', ' ', 'U', 'E', 'F', 'I', ' ', 'P', 'R', 'G', 13, 10
                DW 'W', 'R', 'I', 'T', 'T', 'E', 'N', ' ', 'B', 'Y', ' '
                DW 'I', 'N', 'K', 'B', 'O', 'X', 13, 10, 0
endMessage      DW 'O', 'K', 13, 10, 0
; ... (continue with all other data definitions from original)

; Function pointers
conIn               DQ ?
conOut              DQ ?
RuntimeServices     DQ ?
BootServices        DQ ?
AllocatePages       DQ ?
OutputString        DQ ?
WaitForEvent        DQ ?
ReadKeyStroke       DQ ?
WaitForKey          DQ ?
SetCursorPosition   DQ ?
LocateProtocol      DQ ?
TextInputEX         DQ ?
RegisterKeyNotify   DQ ?
MPServices          DQ ?
StartupThisAP       DQ ?
StartupAllAPs       DQ ?
GetNumberOfAP       DQ ?
EnableDisableAP     DQ ?
LocateHandleBuffer  DQ ?
ABSOLUTEPOINTER     DQ ?
SIMPLEPOINTER       DQ ?
POINTERGETSTATEABS  DQ ?
POINTERGETSTATESMP  DQ ?
POINTERMODE         DQ ?
getTime             DQ ?
GOP                 DQ ?
queryMode           DQ ?
setMode             DQ ?
BLT                 DQ ?
mode                DQ ?
maxMode             DD ?

; Include graphics data
INCLUDE .\graphics\loadImg.inc
INCLUDE .\graphics\loadImgShip.inc
INCLUDE .\graphics\bgTiles.inc
INCLUDE .\graphics\tilemap.inc
INCLUDE .\graphics\spriteTiles.inc
INCLUDE .\graphics\spriteTiles2.inc

END
