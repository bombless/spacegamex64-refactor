; MAIN.ASM - Main entry point
; Assemble: ml64 /c main.asm

INCLUDE .\include\structs.inc
INCLUDE .\include\externs.inc
INCLUDE .\include\macros_util.inc
INCLUDE .\include\macros_uefi.inc
INCLUDE .\include\macros_input.inc
INCLUDE .\include\macros_graphics.inc
INCLUDE .\include\macros_game.inc
INCLUDE .\include\macros_game_ui.inc
INCLUDE .\include\macros_game_objects.inc

.CODE

EFI_MAIN PROC
    MOV imageHandle, RCX
    MOV systemTable, RDX
    GETUEFIFUNCTIONS
    RUNGOPINIT
    RESETCONSOLEPOSITION
    
    MOV RCX, conOut
    LEA RDX, [helloMessage]
    CALL OutputString

    LEA RCX, [time]
    LEA RDX, [EFI_TIME_CAPABILITIES]
    CALL getTime

    MOV RCX, conOut
    LEA RDX, [cyclesMessage]
    CALL OutputString
    ESTIMATECYCLESFORFPS
    MOV RAX, QWORD PTR [CYCLESPERFRAME]
    OUTPUT64BITNUMBER 00H
    
    MOV AL, BYTE PTR [time + 06H]
    MOV BYTE PTR [SECONDS], AL
    
    SETUPKEYNOTIFICATIONS
    INITTITLE
    
    RDTSC
    SHL RDX, 20H
    OR RAX, RDX
    ADD RAX, CYCLESPERFRAME
    MOV NEXTFRAME@, RAX

WAITNEXTFRAME:
    RDTSC
    SHL RDX, 20H
    OR RAX, RDX
    CMP NEXTFRAME@, RAX
    JA WAITNEXTFRAME
    ADD RAX, CYCLESPERFRAME
    MOV NEXTFRAME@, RAX
    
RUNFRAME:
    MOV RAX, TITLEON
    CMP AL, 00H
    JZ AFTERTITLE
        KEYLOGIC
        POINTERLOGIC
        TITLELOGIC
        JMP WAITNEXTFRAME
AFTERTITLE:
    RESETCONSOLEPOSITION
    KEYLOGIC
    POINTERLOGIC
    MOV RAX, PAUSEGAME
    CMP RAX, 00H
    JNZ AFTERGAMELOGIC
        GAMELOGIC
AFTERGAMELOGIC:
    MOV RAX, TITLEON
    CMP RAX, 01H
    JZ AFTERHITBOX
        RENDERGRAPHICS
        MOV RAX, SHOW_HITBOX
        CMP RAX, 01H
        JNZ AFTERHITBOX
            RENDERHITBOXES
AFTERHITBOX:
    
    INC FRAMECOUNT
    LEA RCX, [time]
    LEA RDX, [EFI_TIME_CAPABILITIES]
    CALL getTime
    MOV AL, BYTE PTR [time + 06H]
    CMP AL, BYTE PTR [SECONDS]
    JZ OUTPUTFPS
        MOV RAX, QWORD PTR [FRAMECOUNT]
        MOV FRAMERATE, RAX
        MOV FRAMECOUNT, 00H
OUTPUTFPS:
    MOV RCX, conOut
    LEA RDX, [fpsMessage]
    CALL OutputString
    MOV RAX, FRAMERATE
    OUTPUT64BITNUMBER 00H
    MOV RAX, PAUSEGAME
    OUTPUT64BITNUMBER 00H
    
    JMP WAITNEXTFRAME

WAITEVENT:
    MOV RCX, 01H
    LEA RDX, [WaitForKey]
    LEA R8, [index]
    CALL WaitForEvent
    
    MOV RCX, conIn
    LEA RDX, [key]
    CALL ReadKeyStroke
    
    MOV RCX, conOut
    LEA RDX, [endMessage]
    CALL OutputString
    
    MOV RCX, 01H
    LEA RDX, [WaitForKey]
    LEA R8, [index]
    CALL WaitForEvent
    
    MOV RAX, 00H
    RET
EFI_MAIN ENDP

END
