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

PAUSEGAME		DQ 00H
UPSCALE_MODE	DQ 00H	;0 FOR MULTI-CORE HARDWARE UPSCALED IMAGE OUTPUT, 1 FOR NO UPSCALING
SHOW_HITBOX		DQ 00H	;1 TO SHOW HIT BOXES
imageHandle 	DQ ?	;pointer to image handle
systemTable 	DQ ?	;pointer to system table 
helloMessage  	DW 	'S', 'T', 'A', 'R', 'T', 'I', 'N', 'G', ' ', 'U', 'E', 'F', 'I', ' ', 'P', 'R', 'G', 13, 10
				DW	'W', 'R', 'I', 'T', 'T', 'E', 'N', ' ', 'B', 'Y', ' '
				DW	'I', 'N', 'K', 'B', 'O', 'X', 13, 10, 0
endMessage		DW	'O', 'K', 13, 10, 0
monthMessage	DW	'-', '>', ' ', 'M', 13, 10, 0
fpsMessage		DW	'F', 'P', 'S', ':', ' ', 0
timeCapMessage 	DW	'N', 'A', 'N', 'O', ' ', 'O', 'U', 'T', ':', ' '
timeCapVal		DW	0, 0
cyclesMessage	DW 	'C', 'A', 'L', 'C', 'U', 'L', 'A', 'T', 'I', 'N', 'G'
				DW 	' ', 'C', 'P', 'U', ' ', 'S', 'P', 'E', 'E', 'D', 0
controlMessage	DW 	'U', 'D', 'L', 'R', 'F', 13, 10, 0
PRESSEDLEFTMessage	DW 'A', ' ', 'P', 'R', 'E', 'S', 'S', 'E', 'D', ':', ' ', 0
videoMessage1	DW 	'M', 'A', 'X', ' ', 'V', 'I', 'D', 'E', 'O', ' ', 'M', 'O', 'D', 'E', 'S', ':', ' ', 0
videoMessage2	DW 	'M', ':', ' ', 0
videoMessage3	DW	'F', 'O', 'R', 'M', 'A', 'T', ':', ' ', 0
videoMessage4	DW	'V', 'I', 'D', 'E', 'O', ' ', 'M', 'O', 'D', 'E', ' ', 'S', 'E', 'L', ':', ' ', 0
mouseMessage	DW	'M', 'O', 'U', 'S', 'E', ':', ' ', 10, 13, 0
columnMessage	DW	'C', 'O', 'L', 'U', 'M', 'N', ' ', 'C', 'O', 'U', 'N', 'T', ':', ' ', 10, 13, 0
returnLineMes	DW 	0DH, 0
spaceMessage	DW	' ', 0
xMessage		DW	'x', 0
bMessage		DW 	64 DUP (?)
BUFFER			DB 	64 DUP (?)
modeInfoBuffer	DQ	?
sizeOfInfo		DQ	?
curMode			DQ  ?
VIDEOX			DD	?
VIDEOY			DD	?
selectedMode	DQ	?
TITLECARD		DW	0612H, 060FH, 0600H, 0602H, 0604H, 05EDH, 0606H, 0600H, 060CH, 0604H
				DW	05EDH, 0605H, 060EH, 0611H, 05EDH, 0617H, 0620H, 061EH

;KEY RELATED
index	DQ ?
key		DQ ?
;EFI_INPUT_KEY
WkeyDescriptor		DW 0, 'W', 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
WkeyNotifyHandle	DQ ?
littleWkeyDescriptor DW 0, 'w', 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
littleWkeyNotifyHandle	DQ ?
upkeyDescriptor DW 01H, 0, 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
upkeyNotifyHandle	DQ ?
SkeyDescriptor		DW 0, 'S', 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
SkeyNotifyHandle	DQ ?
littleSkeyDescriptor DW 0, 's', 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
littleSkeyNotifyHandle	DQ ?
downkeyDescriptor DW 02H, 0, 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
downkeyNotifyHandle	DQ ?
AkeyDescriptor		DW 0, 'A', 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
AkeyNotifyHandle	DQ ?
littleAkeyDescriptor DW 0, 'a', 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
littleAkeyNotifyHandle	DQ ?
leftkeyDescriptor DW 04H, 0, 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
leftkeyNotifyHandle	DQ ?
DkeyDescriptor		DW 0, 'D', 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
DkeyNotifyHandle	DQ ?
littleDkeyDescriptor DW 0, 'd', 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
littleDkeyNotifyHandle	DQ ?
rightkeyDescriptor DW 03H, 0, 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
rightkeyNotifyHandle	DQ ?
ZkeyDescriptor		DW 0, 'Z', 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
ZkeyNotifyHandle	DQ ?
littleZkeyDescriptor DW 0, 'z', 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
littleZkeyNotifyHandle	DQ ?
QkeyDescriptor		DW 0, '?', 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
QkeyNotifyHandle	DQ ?
littleQkeyDescriptor DW 0, '/', 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
littleQkeyNotifyHandle	DQ ?
spacekeyDescriptor DW 00H, ' ', 00H, 00H	;SCANCODE, UNICODE CHAR, KeyShiftState + KeyToggleState
spacekeyNotifyHandle	DQ ?
PRESSEDLEFT			DB 0
KEYTIMERLEFT		DB 0
PRESSEDRIGHT		DB 0
KEYTIMERRIGHT		DB 0
PRESSEDUP			DB 0
KEYTIMERUP			DB 0
PRESSEDDOWN			DB 0
KEYTIMERDOWN		DB 0
PRESSEDFIRE			DB 0
KEYTIMERFIRE		DB 0
POINTERSTATE		DD 0, 0, 0, 0, 0, 0	;X, Y, Z, AND BUTTONS
POINTERLOC			DQ 600, 600
POINTERBUTTON		DQ 0, 0
POINTERLEFT			DB 0
POINTERRIGHT		DB 0
POINTERUP			DB 0
POINTERDOWN			DB 0
POINTERFIRE			DB 0
COMBLEFT			DB 0
COMBRIGHT			DB 0
COMBUP				DB 0
COMBDOWN			DB 0
COMBFIRE			DB 0

;GRAPHICS:
SPRITEVERSION	DQ 0
TILEMAP0		DW 0400H DUP (?)
TILEMAP1		DW 0400H DUP (?)
TM0XOFFSET		DB 0
TM0YOFFSET		DB 0
TM1XOFFSET		DB 0
TM1YOFFSET		DB 0
OUTPUTFBUFFER	DD  010000H DUP (?)	;262KB 256x256px FRAME BUFFER
OUTPUTFBUFFER_2	DD  010000H DUP (?)	;262KB 64x256px SPARE FRAME BUFFER FOR MEMORY SPILLAGE
UPSCALEDBUFFER	DQ ?	;4MB UPSCALED 1024x1024px FRAME BUFFER (POINTER)
UPSCALEDROW		DB 256 DUP (?)
UPSCALEDCOUNT	DQ 0
FAILEDCPULIST	DQ ?
SUCESSCPUS		DQ ?
NUMBERAP		DQ ?
ENABLEDAP		DQ ?

SPRITEOBJ STRUCT
	MODE DW  ?	;0 IF INACTIVE
	SPRITETILENUM DW ?
	X	DW ?
	Y	DW ?
SPRITEOBJ ENDS
SPRITES SPRITEOBJ 080H DUP(<>)	;128 SPRITE OBJECTS

ENEMYOBJ STRUCT
	MODE DW ?	;0 IF INACTIVE
	SPRITE DW ?
	X DW ?
	Y DW ?
	HITBOXX DB ?	;X & Y ARE OFFSET FROM TOP LEFT CORNER
	HITBOXY DB ?
	HITBOXW DB ?
	HITBOXH DB ?
	ALT		DB ?	;ALTITUDE
	TIMER	DB ?	;INTERNAL TIMER FOR SPRITE ANIMATIONS
ENEMYOBJ ENDS
ENEMYOBJSIZE = 0EH
ENEMY ENEMYOBJ 040H DUP(<>)	;64 ENEMIES

BOLTOBJ STRUCT
	MODE DW ?	;0 IF INACTIVE
	SPRITE DW ?
	X DW ?
	Y DW ?
	HITBOXX DB ?	;X & Y ARE OFFSET FROM TOP LEFT CORNER
	HITBOXY DB ?
	HITBOXW DB ?
	HITBOXH DB ?
	ALT		DB ?	;ALTITUDE
	TIMER	DB ?	;INTERNAL TIMER FOR SPRITE ANIMATIONS
BOLTOBJ ENDS
BOLTOBJSIZE = 0EH
BOLTS BOLTOBJ 08H DUP(<>)	;8 BOLTS
BOLTCOOLDOWN DQ 0
BOLTCOOLDOWNFRAMES EQU 24

COLORRED	DD	000FF0000H
COLORORANGE	DD	000FF8000H
COLORYELLOW	DD	000FFFF00H
COLORGREENN	DD	00039FF14H
COLORBLUE	DD	0000000FFH
COLORGREEN	DD	00000FF00H
COLORBLACK	DD	000000000H

;GAME VARIABLES
TITLEON DQ 1	;START WITH TITLE ON
STAGE		DQ 0
SHIPX DQ 0
SHIPY DQ 0
SHIPTILTY	DQ 0
SHIPHITBOX	DB 0, 0, 0, 0	;X, Y, W, H
SHIPALT		DB 0
SHIPFUEL	DB 0
SCROLLTIMER	DQ 0
SCROLLX		DQ 0
SCROLLY		DQ 0
LASTSCROLLX	DQ 0
LASTSCROOLY	DQ 0
GAMEMAPOFFSET DQ 258H
COLUMNTICK 	DQ 0
HIDESHADOW	DQ 0
HIT			DQ 0
NOFUEL		DQ 0
BONUSFUEL	EQU 020H	;AMOUNT OF BONUS FUEL FROM HITTING TANKS
PAUSESCROLL DQ 0
EXPLODETIMER	DQ 0
EXPLODEDELAYTIMER	DQ 0
RESET			DQ 0
WINTIMER 	DQ 0
;FRAMERULES:
MOVEMENTFRAMERULE 	EQU	2
MOVEMENTFRAMERULEC	DQ 	0
SCROLLFRAMERULE 	EQU	3	;HOW  FAST THE GAME BACKGROUND SCROLLS
SCROLLFRAMERULEC	DQ 	0
FUELFRAMERULE		EQU 20	;HOW QUICK FUEL IS DEPLETED
FUELFRAMERULEC		DQ 	0
ELOGICFRAMERULE		EQU 2
ELOGICFRAMERULEC	DQ 	0
EXPLODEFRAMERULE	EQU 8
EXPLODEFRAMERULEC	DQ 	0
BOSSMOVEFRAMERULE	EQU 4
BOSSMOVEFRAMERULEC	DQ	0
TITLECOUNTER 		DQ 	0
TITLESWAPCOUNTER	DQ  0

;GAME CONSTANTS
SHIPORGINX 	EQU 12
SHIPORGINY 	EQU 70
SHIPMAXX	EQU 112
SHIPMAXY	EQU 112

;TIME RELATED
time					DQ 4 DUP(?)
	;UINT16 Year;
    ;UINT8 Month;
    ;UINT8 Day;
    ;UINT8 Hour;
    ;UINT8 Minute;
    ;UINT8 Second;
    ;UINT8 Pad1;
    ;UINT32 Nanosecond;
    ;INT16 TimeZone;
    ;UINT8 Daylight;
    ;UINT8 PAD2;
EFI_TIME_CAPABILITIES	DQ ?, ?	;9 bytes used
SECONDS			DB ?
TSC_PS			DQ ?
TSC_PS2			DQ ?
CYCLESPERFRAME	DQ ?
NEXTFRAME@		DQ ?
FRAMERATE		DQ ?
FRAMECOUNT		DQ ?
S1	DQ ?
S2	DQ ?

;FRAME COUNTERS
MOVEMENTFC	DB ?

;PROTOCOL Globally Unique IDs:
TextInputExGUID		DD 0DD9E7534H         	;Data1
					DW 07762H             	;Data2
					DW 04698H            	;Data3
					DB 08CH, 014H, 0F5H, 085H, 017H, 0A6H, 025H, 0AAH	;Data4
GraphicsOutputGUID 	DD 09042A9DEH       ;Data1
					DW 23DCH            ;Data2
					DW 4A38H            ;Data3
					DB 096H, 0FBH, 07AH, 0DEH, 0D0H, 080H, 051H, 06AH 	;Data4
MPServicesGUID		DD 03FDDA605H			;Data1
					DW 0A76EH				;Data2
					DW 04F46H				;Data3
					DB 0ADH, 029H, 012H, 0F4H, 053H, 01BH, 03DH, 008H	;Data4
ABSOLUTEPOINTERGUID	DD 08D59D32BH			;Data1
					DW 0C655H				;Data2
					DW 04AE9H				;Data3
					DB 09BH, 015H, 0F2H, 059H, 004H, 099H, 02AH, 043H	;Data4
SIMPLEPOINTERGUID	DD 031878C87H			;Data1
					DW 00B75H				;Data2
					DW 011D5H				;Data3
					DB 09AH, 04FH, 000H, 090H, 027H, 03FH, 0C1H, 04DH	;Data4

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
