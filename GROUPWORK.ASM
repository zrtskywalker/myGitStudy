; =====================================================
; 8086 Assembly Language Teaching Version
; Interactive String Processing Tool
; =====================================================

DATA SEGMENT
; ---------------- Menu ----------------
MENU_MSG DB 0DH,0AH,'========= String Processing Tool =========',0DH,0AH
         DB '1. Input String',0DH,0AH
         DB '2. Count Length',0DH,0AH
         DB '3. Search Character',0DH,0AH
         DB '4. Replace Character',0DH,0AH
         DB '5. Display Result',0DH,0AH
         DB '6. Exit Program',0DH,0AH
         DB '=========================================',0DH,0AH
         DB 'Select (1-6): $'

; ---------------- Prompts ----------------
MSG_INPUT     DB 0DH,0AH,'Input string (max 200 chars): $'
MSG_LENGTH    DB 0DH,0AH,'String length: $'
MSG_CHAR      DB 0DH,0AH,'Input target character: $'
MSG_OLD       DB 0DH,0AH,'Character to replace: $'
MSG_NEW       DB 0DH,0AH,'New character: $'
MSG_POSITION  DB 0DH,0AH,'Character position: $'
MSG_NOTFOUND  DB 0DH,0AH,'Character not found!',0DH,0AH,'$'
MSG_ORIGINAL  DB 0DH,0AH,'Original string: $'
MSG_PROCESSED DB 0DH,0AH,'Processed string: $'
MSG_NOINPUT   DB 0DH,0AH,'Please input string first!',0DH,0AH,'$'
MSG_INVALID   DB 0DH,0AH,'Invalid selection!',0DH,0AH,'$'
NEWLINE       DB 0DH,0AH,'$'

; ---------------- Buffers ----------------
INPUT_BUF DB 200
          DB 0
          DB 200 DUP(?)

ORIGINAL_STR  DB 201 DUP(0)
PROCESSED_STR DB 201 DUP(0)

STR_LEN   DW 0
HAS_INPUT DB 0

NUM_BUF DB 10 DUP(?)

DATA ENDS

STACK SEGMENT STACK
    DW 100H DUP(?)
STACK ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA, SS:STACK

START:
    MOV AX, DATA
    MOV DS, AX

MAIN_LOOP:
    CALL SHOW_MENU

    MOV AH,01H
    INT 21H

    CMP AL,'1'
    JE MENU_INPUT
    CMP AL,'2'
    JE MENU_LENGTH
    CMP AL,'3'
    JE MENU_SEARCH
    CMP AL,'4'
    JE MENU_REPLACE
    CMP AL,'5'
    JE MENU_OUTPUT
    CMP AL,'6'
    JE MENU_EXIT

    LEA DX, MSG_INVALID
    MOV AH,09H
    INT 21H
    JMP MAIN_LOOP

MENU_INPUT:
    CALL INPUT_STRING
    JMP MAIN_LOOP

MENU_LENGTH:
    CALL COUNT_LENGTH
    JMP MAIN_LOOP

MENU_SEARCH:
    CALL SEARCH_CHAR
    JMP MAIN_LOOP

MENU_REPLACE:
    CALL REPLACE_CHAR
    JMP MAIN_LOOP

MENU_OUTPUT:
    CALL OUTPUT_RESULT
    JMP MAIN_LOOP

MENU_EXIT:
    CALL EXIT_PROGRAM

; =====================================================
; Show Menu
; =====================================================
SHOW_MENU PROC
    PUSH AX
    PUSH DX

    LEA DX, MENU_MSG
    MOV AH,09H
    INT 21H

    POP DX
    POP AX
    RET
SHOW_MENU ENDP

; =====================================================
; Input String
; =====================================================
INPUT_STRING PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    LEA DX, MSG_INPUT
    MOV AH,09H
    INT 21H

    MOV BYTE PTR INPUT_BUF,200
    LEA DX, INPUT_BUF
    MOV AH,0AH
    INT 21H

    MOV AL, INPUT_BUF+1
    CBW
    MOV STR_LEN, AX

    LEA SI, INPUT_BUF+2
    LEA DI, ORIGINAL_STR
    MOV CX, AX
    REP MOVSB
    MOV BYTE PTR [DI],0

    ; clear processed string
    MOV CX,201
    LEA DI, PROCESSED_STR
CLR_PS:
    MOV BYTE PTR [DI],0
    INC DI
    LOOP CLR_PS

    MOV HAS_INPUT,1

    POP DI
    POP SI
    POP DX
    POP CX
    POP AX
    RET
INPUT_STRING ENDP

; =====================================================
; Count Length
; =====================================================
COUNT_LENGTH PROC
    PUSH AX
    PUSH DX

    CMP HAS_INPUT,0
    JNE CL_OK

    LEA DX, MSG_NOINPUT
    MOV AH,09H
    INT 21H
    JMP CL_EXIT

CL_OK:
    LEA DX, MSG_LENGTH
    MOV AH,09H
    INT 21H

    MOV AX, STR_LEN
    CALL PRINT_NUMBER

CL_EXIT:
    POP DX
    POP AX
    RET
COUNT_LENGTH ENDP

; =====================================================
; Search Character
; =====================================================
SEARCH_CHAR PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    CMP HAS_INPUT,0
    JNE SC_OK

    LEA DX, MSG_NOINPUT
    MOV AH,09H
    INT 21H
    JMP SC_EXIT

SC_OK:
    LEA DX, MSG_CHAR
    MOV AH,09H
    INT 21H

    MOV AH,01H
    INT 21H
    MOV BL, AL

    LEA SI, ORIGINAL_STR
    MOV CX, STR_LEN
    XOR AX, AX

SC_LOOP:
    INC AX
    CMP [SI], BL
    JE SC_FOUND
    INC SI
    LOOP SC_LOOP

    LEA DX, MSG_NOTFOUND
    MOV AH,09H
    INT 21H
    JMP SC_EXIT

SC_FOUND:
    LEA DX, MSG_POSITION
    MOV AH,09H
    INT 21H
    CALL PRINT_NUMBER

SC_EXIT:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SEARCH_CHAR ENDP

; =====================================================
; Replace Character
; =====================================================
REPLACE_CHAR PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    CMP HAS_INPUT,0
    JNE RC_OK

    LEA DX, MSG_NOINPUT
    MOV AH,09H
    INT 21H
    JMP RC_EXIT

RC_OK:
    LEA DX, MSG_OLD
    MOV AH,09H
    INT 21H
    MOV AH,01H
    INT 21H
    MOV BL, AL

    LEA DX, MSG_NEW
    MOV AH,09H
    INT 21H
    MOV AH,01H
    INT 21H
    MOV BH, AL

    LEA SI, ORIGINAL_STR
    LEA DI, PROCESSED_STR
    MOV CX, STR_LEN

RC_LOOP:
    MOV AL, [SI]
    CMP AL, BL
    JNE RC_NEXT
    MOV AL, BH
RC_NEXT:
    MOV [DI], AL
    INC SI
    INC DI
    LOOP RC_LOOP
    MOV BYTE PTR [DI],0

RC_EXIT:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
REPLACE_CHAR ENDP

; =====================================================
; Output Result
; =====================================================
OUTPUT_RESULT PROC
    PUSH AX
    PUSH DX
    PUSH SI

    CMP HAS_INPUT,0
    JNE OR_OK

    LEA DX, MSG_NOINPUT
    MOV AH,09H
    INT 21H
    JMP OR_EXIT

OR_OK:
    LEA DX, MSG_ORIGINAL
    MOV AH,09H
    INT 21H
    LEA SI, ORIGINAL_STR
    CALL PRINT_STRING

    LEA DX, MSG_PROCESSED
    MOV AH,09H
    INT 21H
    LEA SI, PROCESSED_STR
    CALL PRINT_STRING

    LEA DX, MSG_LENGTH
    MOV AH,09H
    INT 21H
    MOV AX, STR_LEN
    CALL PRINT_NUMBER

OR_EXIT:
    POP SI
    POP DX
    POP AX
    RET
OUTPUT_RESULT ENDP

; =====================================================
; Exit Program
; =====================================================
EXIT_PROGRAM PROC
    MOV AX,4C00H
    INT 21H
EXIT_PROGRAM ENDP

; =====================================================
; Print String (0-terminated)
; =====================================================
PRINT_STRING PROC
    PUSH AX
    PUSH DX

PS_LOOP:
    MOV AL,[SI]
    CMP AL,0
    JE PS_DONE
    MOV DL,AL
    MOV AH,02H
    INT 21H
    INC SI
    JMP PS_LOOP

PS_DONE:
    LEA DX, NEWLINE
    MOV AH,09H
    INT 21H

    POP DX
    POP AX
    RET
PRINT_STRING ENDP

; =====================================================
; Print Number
; =====================================================
PRINT_NUMBER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV BX,10
    XOR CX,CX
    LEA SI, NUM_BUF

PN_DIV:
    XOR DX,DX
    DIV BX
    ADD DL,'0'
    MOV [SI],DL
    INC SI
    INC CX
    CMP AX,0
    JNE PN_DIV

PN_PRINT:
    DEC SI
    MOV DL,[SI]
    MOV AH,02H
    INT 21H
    LOOP PN_PRINT

    LEA DX, NEWLINE
    MOV AH,09H
    INT 21H

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUMBER ENDP

CODE ENDS
END START
