; MACROS_UEFI.INC - UEFI setup and protocol macros

IFNDEF MACROS_UEFI_INC
MACROS_UEFI_INC EQU 1

GETUEFIFUNCTIONS MACRO
    ; RDX = SystemTable
    MOV RAX, QWORD PTR [RDX + 30H]
        MOV conIn, RAX
    MOV RAX, QWORD PTR [RDX + 40H]
        MOV conOut, RAX
    MOV RAX, QWORD PTR [RDX + 58H]
        MOV RuntimeServices, RAX
    MOV RAX, QWORD PTR [RDX + 60H]
        MOV BootServices, RAX
    MOV RAX, conOut
    MOV R8, QWORD PTR [RAX + 08H]
        MOV OutputString, R8
    MOV R8, QWORD PTR [RAX + 38H]
        MOV SetCursorPosition, R8
    MOV RAX, BootServices
    MOV R8, QWORD PTR [RAX + 28H]
        MOV AllocatePages, R8
    MOV R8, QWORD PTR [RAX + 60H]
        MOV WaitForEvent, R8
    MOV R8, QWORD PTR [RAX + 138H]
        MOV LocateHandleBuffer, R8
    MOV R8, QWORD PTR [RAX + 140H]
        MOV LocateProtocol, R8
    MOV RAX, conIn
    MOV R8, QWORD PTR [RAX + 08H]
        MOV ReadKeyStroke, R8
    MOV R8, QWORD PTR [RAX + 10H]
        MOV WaitForKey, R8
    MOV RAX, RuntimeServices
    MOV R8, QWORD PTR [RAX + 18H]
        MOV getTime, R8
        
    ; LOCATE TextInputEX
    LEA RCX, [TextInputExGUID]
    XOR RDX, RDX
    LEA R8, QWORD PTR [TextInputEX]
    CALL LocateProtocol
    OUTPUT64BITNUMBER 00H
    
    MOV RAX, TextInputEX
    MOV R8, QWORD PTR [RAX + 20H]
        MOV RegisterKeyNotify, R8

    ; LOCATE GraphicsOutputProtocol
    LEA RCX, [GraphicsOutputGUID]
    XOR RDX, RDX
    LEA R8, QWORD PTR [GOP]
    CALL LocateProtocol
    OUTPUT64BITNUMBER 00H
    
    MOV RAX, GOP
    MOV R8, QWORD PTR [RAX]
        MOV queryMode, R8
    MOV R8, QWORD PTR [RAX + 08H]
        MOV setMode, R8
    MOV R8, QWORD PTR [RAX + 10H]
        MOV BLT, R8
    MOV R8, QWORD PTR [RAX + 18H]
        MOV mode, R8
    LEA RAX, QWORD PTR [mode]
    MOV RBX, [RAX]
    MOV RAX, [RBX]
        MOV DWORD PTR [maxMode], EAX
    
    ; LOCATE MPServicesProtocol
    LEA RCX, [MPServicesGUID]
    XOR RDX, RDX
    LEA R8, QWORD PTR [MPServices]
    CALL LocateProtocol
    OUTPUT64BITNUMBER 00H
    
    MOV RAX, MPServices
    MOV R8, QWORD PTR [RAX]
        MOV GetNumberOfAP, R8
    MOV R8, QWORD PTR [RAX + 10H]
        MOV StartupAllAPs, R8
    MOV R8, QWORD PTR [RAX + 18H]
        MOV StartupThisAP, R8
    MOV R8, QWORD PTR [RAX + 28H]
        MOV EnableDisableAP, R8
        
    MOV RCX, conOut
    LEA RDX, [mouseMessage]
    CALL OutputString
    
    ; LOCATE ABSOLUTEPOINTER PROTOCOL
    LEA RCX, [ABSOLUTEPOINTERGUID]
    XOR RDX, RDX
    LEA R8, QWORD PTR [ABSOLUTEPOINTER]
    CALL LocateProtocol
    OUTPUT64BITNUMBER 00H
    
    MOV RAX, ABSOLUTEPOINTER
    MOV R8, QWORD PTR [RAX + 08H]
        MOV POINTERGETSTATEABS, R8
    
    ; LOCATE SIMPLEPOINTER PROTOCOL
    LEA RCX, [SIMPLEPOINTERGUID]
    XOR RDX, RDX
    LEA R8, QWORD PTR [SIMPLEPOINTER]
    CALL LocateProtocol
    OUTPUT64BITNUMBER 00H
    
    MOV RAX, SIMPLEPOINTER
    MOV R8, QWORD PTR [RAX + 08H]
        MOV POINTERGETSTATESMP, R8
    MOV R8, QWORD PTR [RAX + 18H]
        MOV POINTERMODE, R8
ENDM

ESTIMATECYCLESFORFPS MACRO
    LOCAL WAITFORNEXTSECOND
    LOCAL WAITFORNEXTSECOND2
    
    LEA RCX, [time]
    LEA RDX, [EFI_TIME_CAPABILITIES]
    CALL getTime
    MOV AL, BYTE PTR [time + 06H]
    MOV BYTE PTR [SECONDS], AL
    
WAITFORNEXTSECOND:
    LEA RCX, [time]
    LEA RDX, [EFI_TIME_CAPABILITIES]
    CALL getTime
    MOV AL, BYTE PTR [time + 06H]
    CMP AL, BYTE PTR [SECONDS]
    JZ WAITFORNEXTSECOND
    MOV BYTE PTR [SECONDS], AL
    MOV BYTE PTR [S1], AL
    
    RDTSC
    MOV DWORD PTR [TSC_PS], EAX
    MOV DWORD PTR [TSC_PS + 04H], EDX
    
WAITFORNEXTSECOND2:
    LEA RCX, [time]
    LEA RDX, [EFI_TIME_CAPABILITIES]
    CALL getTime
    MOV AL, BYTE PTR [time + 06H]
    CMP AL, BYTE PTR [SECONDS]
    JZ WAITFORNEXTSECOND2
    MOV BYTE PTR [S2], AL
    
    RDTSC
    SHL RDX, 20H
    OR RAX, RDX
    SUB RAX, TSC_PS
    MOV QWORD PTR [TSC_PS2], RAX
    SHR RAX, 07H
    MOV QWORD PTR [CYCLESPERFRAME], RAX
ENDM

RUNGOPINIT MACRO
    LOCAL CALLQUERY
    LOCAL CHECKNEXTMODE
    LOCAL MODESELECTED
    
    MOV RCX, MPServices
    LEA RDX, QWORD PTR [NUMBERAP]
    LEA R8, QWORD PTR [ENABLEDAP]
    CALL GetNumberOfAP
    OUTPUT64BITNUMBER 00H
    MOV RAX, QWORD PTR [NUMBERAP]
    OUTPUT64BITNUMBER 00H
    MOV RAX, QWORD PTR [ENABLEDAP]
    OUTPUT64BITNUMBER 00H
    
    MOV RCX, conOut
    LEA RDX, [videoMessage1]
    CALL OutputString
    XOR RAX, RAX
    MOV EAX, DWORD PTR [maxMode]
    OUTPUT64BITNUMBER 00H
    
CALLQUERY:
    MOV R10, QWORD PTR [curMode]
    MOV RCX, GOP
    MOV RDX, R10
    LEA R8, QWORD PTR [sizeOfInfo]
    LEA R9, QWORD PTR [modeInfoBuffer]
    CALL queryMode
    
    MOV RCX, conOut
    LEA RDX, [videoMessage2]
    CALL OutputString
    MOV RAX, QWORD PTR [curMode]
    OUTPUT64BITNUMBER 01H
    MOV RCX, conOut
    LEA RDX, [spaceMessage]
    CALL OutputString
    MOV RBX, QWORD PTR [modeInfoBuffer]
    XOR RAX, RAX
    MOV EAX, DWORD PTR [RBX + 04H]
    MOV DWORD PTR [VIDEOX], EAX
    OUTPUT64BITNUMBER 01H
    MOV RCX, conOut
    LEA RDX, [xMessage]
    CALL OutputString
    MOV RBX, QWORD PTR [modeInfoBuffer]
    XOR RAX, RAX
    MOV EAX, DWORD PTR [RBX + 08H]
    MOV DWORD PTR [VIDEOY], EAX
    OUTPUT64BITNUMBER 01H
    MOV RCX, conOut
    LEA RDX, [spaceMessage]
    CALL OutputString
    MOV RCX, conOut
    LEA RDX, [videoMessage3]
    CALL OutputString
    MOV RBX, QWORD PTR [modeInfoBuffer]
    XOR RAX, RAX
    MOV EAX, DWORD PTR [RBX + 0CH]
    OUTPUT64BITNUMBER 00H
    
    CMP DWORD PTR [VIDEOX], 0500H
    JNE CHECKNEXTMODE
    CMP DWORD PTR [VIDEOY], 0400H
    JNE CHECKNEXTMODE
        XOR RAX, RAX
        MOV EAX, DWORD PTR [curMode]
        MOV QWORD PTR [selectedMode], RAX
        JMP MODESELECTED
        
CHECKNEXTMODE:
    INC DWORD PTR [curMode]
    XOR EAX, EAX
    MOV EAX, DWORD PTR [maxMode]
    CMP EAX, DWORD PTR [curMode]
    JNE CALLQUERY
    
MODESELECTED:
    MOV RCX, conOut
    LEA RDX, [videoMessage4]
    CALL OutputString
    MOV RAX, selectedMode
    OUTPUT64BITNUMBER 00H
    
    MOV RCX, GOP
    MOV RDX, QWORD PTR [selectedMode]
    CALL setMode
    
    MOV RCX, 00H
    MOV RDX, 04H
    MOV R8, 0800H
    LEA R9, UPSCALEDBUFFER
    CALL AllocatePages
ENDM

RESETAPS MACRO
    XOR R10, R10
DISABLEALLAPS:
    MOV RCX, MPServices
    MOV RDX, R10
    MOV R8, 00H
    MOV R9, 00H
    CALL EnableDisableAP
    INC R10
    CMP R10, NUMBERAP
    JNZ DISABLEALLAPS
    
    XOR R10, R10
ENABLEALLAPS:
    MOV RCX, MPServices
    MOV RDX, R10
    MOV R8, 01H
    MOV R9, 00H
    CALL EnableDisableAP
    INC R10
    CMP R10, NUMBERAP
    JNZ ENABLEALLAPS
ENDM

ENDIF
