; MACROS_INPUT.INC - Input handling macros

IFNDEF MACROS_INPUT_INC
MACROS_INPUT_INC EQU 1

SETUPKEYNOTIFICATIONS MACRO
    ; UP CONTROL
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [WkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionUp]
    LEA R9, QWORD PTR [WkeyNotifyHandle]
    CALL RegisterKeyNotify
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [littleWkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionUp]
    LEA R9, QWORD PTR [littleWkeyNotifyHandle]
    CALL RegisterKeyNotify
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [upkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionUp]
    LEA R9, QWORD PTR [upkeyNotifyHandle]
    CALL RegisterKeyNotify
    
    ; DOWN CONTROL
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [SkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionDown]
    LEA R9, QWORD PTR [SkeyNotifyHandle]
    CALL RegisterKeyNotify
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [littleSkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionDown]
    LEA R9, QWORD PTR [littleSkeyNotifyHandle]
    CALL RegisterKeyNotify
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [downkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionDown]
    LEA R9, QWORD PTR [downkeyNotifyHandle]
    CALL RegisterKeyNotify
    
    ; LEFT CONTROL
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [AkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionLeft]
    LEA R9, QWORD PTR [AkeyNotifyHandle]
    CALL RegisterKeyNotify
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [littleAkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionLeft]
    LEA R9, QWORD PTR [littleAkeyNotifyHandle]
    CALL RegisterKeyNotify
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [leftkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionLeft]
    LEA R9, QWORD PTR [leftkeyNotifyHandle]
    CALL RegisterKeyNotify
    
    ; RIGHT CONTROL
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [DkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionRight]
    LEA R9, QWORD PTR [DkeyNotifyHandle]
    CALL RegisterKeyNotify
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [littleDkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionRight]
    LEA R9, QWORD PTR [littleDkeyNotifyHandle]
    CALL RegisterKeyNotify
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [rightkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionRight]
    LEA R9, QWORD PTR [rightkeyNotifyHandle]
    CALL RegisterKeyNotify
    
    ; FIRE CONTROL
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [ZkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionFire]
    LEA R9, QWORD PTR [ZkeyNotifyHandle]
    CALL RegisterKeyNotify
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [littleZkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionFire]
    LEA R9, QWORD PTR [littleZkeyNotifyHandle]
    CALL RegisterKeyNotify
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [QkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionFire]
    LEA R9, QWORD PTR [QkeyNotifyHandle]
    CALL RegisterKeyNotify
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [littleQkeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionFire]
    LEA R9, QWORD PTR [littleQkeyNotifyHandle]
    CALL RegisterKeyNotify
    MOV RCX, TextInputEX
    LEA RDX, QWORD PTR [spacekeyDescriptor]
    LEA R8, [KeyNotificationCallbackFunctionFire]
    LEA R9, QWORD PTR [spacekeyNotifyHandle]
    CALL RegisterKeyNotify
ENDM

POINTERLOGIC MACRO
    LOCAL ENDPOINTERLOGIC
    LOCAL SETPOINTERX
    LOCAL SETPOINTERY
    LOCAL SETPLEFT
    LOCAL SETPRIGHT
    LOCAL SETPUP
    LOCAL SETPDOWN
    LOCAL CHECKPOINTERUPDOWN
    LOCAL AFTERPOINTERSET

    MOV RCX, SIMPLEPOINTER
    LEA RDX, QWORD PTR [POINTERSTATE]
    CALL POINTERGETSTATESMP
    CMP RAX, 00H
    JNZ ENDPOINTERLOGIC
    
    XOR RAX, RAX
    MOV AL, BYTE PTR [POINTERSTATE + 0CH]
    MOV BYTE PTR [POINTERBUTTON], AL
    XOR RAX, RAX
    MOV AL, BYTE PTR [POINTERSTATE + 0DH]
    MOV BYTE PTR [POINTERBUTTON + 08H], AL
    
    MOV AL, BYTE PTR [POINTERBUTTON]
    CMP AL, 01H
    JZ SETPOINTERX
        MOV RAX, 600
        MOV QWORD PTR [POINTERLOC], RAX
        MOV QWORD PTR [POINTERLOC + 08H], RAX
        JMP ENDPOINTERLOGIC
    
SETPOINTERX:
    MOV R8, POINTERMODE
    XOR RAX, RAX
    XOR RDX, RDX
    MOV EAX, DWORD PTR [POINTERSTATE]
    MOVSXD RAX, EAX
    MOV RBX, [R8]
    CQO
    IDIV RBX
    MOV RBX, QWORD PTR [POINTERLOC]
    ADD RAX, RBX
    CMP RAX, MAXX
    JA SETPOINTERY
    CMP RAX, MINX
    JB SETPOINTERY
    MOV QWORD PTR [POINTERLOC], RAX
    
SETPOINTERY:
    XOR RAX, RAX
    XOR RDX, RDX
    MOV EAX, DWORD PTR [POINTERSTATE + 04H]
    MOVSXD RAX, EAX
    MOV RBX, [R8 + 08H]
    CQO
    IDIV RBX
    MOV RBX, QWORD PTR [POINTERLOC + 08H]
    ADD RAX, RBX
    CMP RAX, MAXY
    JA ENDPOINTERLOGIC
    CMP RAX, MINY
    JB ENDPOINTERLOGIC
    MOV QWORD PTR [POINTERLOC + 08H], RAX
    
ENDPOINTERLOGIC:
    MOV AL, BYTE PTR [POINTERBUTTON + 08H]
    MOV BYTE PTR [POINTERFIRE], AL
    
    XOR RAX, RAX
    MOV DWORD PTR [POINTERLEFT], EAX
    
    MOV RAX, QWORD PTR [POINTERLOC]
    CMP RAX, TRIGGERLOW
    JB SETPLEFT
    CMP RAX, TRIGGERHIGH
    JB CHECKPOINTERUPDOWN
SETPRIGHT:
    INC BYTE PTR [POINTERRIGHT]
    JMP CHECKPOINTERUPDOWN
SETPLEFT:
    INC BYTE PTR [POINTERLEFT]
CHECKPOINTERUPDOWN:
    
    MOV RAX, QWORD PTR [POINTERLOC + 08H]
    CMP RAX, TRIGGERLOW
    JB SETPUP
    CMP RAX, TRIGGERHIGH
    JB AFTERPOINTERSET
SETPDOWN:
    INC BYTE PTR [POINTERDOWN]
    JMP AFTERPOINTERSET
SETPUP:
    INC BYTE PTR [POINTERUP]
AFTERPOINTERSET:
ENDM

KEYLOGIC MACRO
    LOCAL AFTERUPCOUNT
    LOCAL AFTERDOWNCOUNT
    LOCAL AFTERLEFTCOUNT
    LOCAL AFTERRIGHTCOUNT
    LOCAL AFTERFIRECOUNT
    
    XOR RAX, RAX
    MOV AL, BYTE PTR [KEYTIMERUP]
    CMP AL, 00H
    JZ AFTERUPCOUNT
    DEC BYTE PTR [KEYTIMERUP]
    JNZ AFTERUPCOUNT
        MOV BYTE PTR [PRESSEDUP], 00H
AFTERUPCOUNT:
    
    XOR RAX, RAX
    MOV AL, BYTE PTR [KEYTIMERDOWN]
    CMP AL, 00H
    JZ AFTERDOWNCOUNT
    DEC BYTE PTR [KEYTIMERDOWN]
    JNZ AFTERDOWNCOUNT
        MOV BYTE PTR [PRESSEDDOWN], 00H
AFTERDOWNCOUNT:
    
    XOR RAX, RAX
    MOV AL, BYTE PTR [KEYTIMERLEFT]
    CMP AL, 00H
    JZ AFTERLEFTCOUNT
    DEC BYTE PTR [KEYTIMERLEFT]
    JNZ AFTERLEFTCOUNT
        MOV BYTE PTR [PRESSEDLEFT], 00H
AFTERLEFTCOUNT:
    
    XOR RAX, RAX
    MOV AL, BYTE PTR [KEYTIMERRIGHT]
    CMP AL, 00H
    JZ AFTERRIGHTCOUNT
    DEC BYTE PTR [KEYTIMERRIGHT]
    JNZ AFTERRIGHTCOUNT
        MOV BYTE PTR [PRESSEDRIGHT], 00H
AFTERRIGHTCOUNT:
    
    XOR RAX, RAX
    MOV AL, BYTE PTR [KEYTIMERFIRE]
    CMP AL, 00H
    JZ AFTERFIRECOUNT
    DEC BYTE PTR [KEYTIMERFIRE]
    JNZ AFTERFIRECOUNT
        MOV BYTE PTR [PRESSEDFIRE], 00H
AFTERFIRECOUNT:
ENDM

ENDIF
