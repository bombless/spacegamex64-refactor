; MACROS_GRAPHICS.INC - Graphics rendering macros

IFNDEF MACROS_GRAPHICS_INC
MACROS_GRAPHICS_INC EQU 1

BLTRECT MACRO sourceX, sourceY, destX, destY, W, H
    MOV RCX, GOP
    MOV R8, 00H
    MOV R9, sourceX
    PUSH 0
    PUSH H
    PUSH W
    PUSH destY
    PUSH destX
    PUSH sourceY
    SUB RSP, 20h
    CALL BLT
    ADD RSP, 20h
    ADD RSP, 30h
ENDM

BLTBUFF MACRO sourceX, sourceY, destX, destY, W, H
    MOV RCX, GOP
    MOV R8, 02H
    MOV R9, sourceX
    PUSH 0
    PUSH H
    PUSH W
    PUSH destY
    PUSH destX
    PUSH sourceY
    SUB RSP, 20h
    CALL BLT
    ADD RSP, 20h
    ADD RSP, 30h
ENDM

ENDIF
