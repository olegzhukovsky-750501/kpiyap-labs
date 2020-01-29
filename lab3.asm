.MODEL SMALL
.STACK 100h

CR EQU 0Dh   ;CARRIAGE RETURN
LF EQU 0Ah   ;LINE FEED

MAX_ROW EQU '5'
MAX_COL EQU '6'

.DATA
matrix DW ?, ?, ?, ?, ?, ?
       DW ?, ?, ?, ?, ?, ?
       DW ?, ?, ?, ?, ?, ?
       DW ?, ?, ?, ?, ?, ?
       DW ?, ?, ?, ?, ?, ?
rows DB ?
cols DB ?

promptDimsStr DB "Enter dimensions of your matrix", CR, LF, '$'
promptElemsStr DB CR, LF, "Enter elements of your matrix", CR, LF, '$'

rowsInputStr DB CR, LF, "Rows: ", '$'
colsInputStr DB CR, LF, "Columns: ", '$'

incorrectMsgStr DB CR, LF, "Incorrect input", '$'
overflowStr DB "Overflow", '$'

elemInputStr_1 DB CR, LF, "arr["
elemInputStr_2 DB ?
elemInputStr_3 DB "]["
elemInputStr_4 DB ?
elemInputStr_5 DB "] = $"

BUFSTR LABEL BYTE
MAXLEN DB 7
STRLEN DB ?
STRFLD DB 6 DUP('$')

resultStr_1 DB CR, LF, "Column "
resultStr_2 DB ?
resultStr_3 DB ": "
resultStr_4 DB 12 DUP('$') 

.CODE
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    CALL showDimsPrompt
    CALL inputDims

    CALL showElemsPrompt
    CALL inputData
    
    CALL mulCols
    
    MOV AX, 4c00h
    INT 21h
    
showStr PROC
    PUSH AX
    
    MOV AH, 09h
    INT 21h
    
    POP AX
    RET
showStr ENDP

showDimsPrompt PROC
    PUSH DX
    
    LEA DX, promptDimsStr
    CALL showStr
    
    POP DX
    RET
showDimsPrompt ENDP

showRowsInput PROC
    PUSH DX
    
    LEA DX, rowsInputStr
    CALL showStr
    
    POP DX
    RET
showRowsInput ENDP

showColsInput PROC
    PUSH DX
    
    LEA DX, colsInputStr
    CALL showStr
    
    POP DX
    RET
showColsInput ENDP

showIncMsg PROC
    PUSH DX
    
    LEA DX, incorrectMsgStr
    CALL showStr
    
    POP DX
    RET
showIncMsg ENDP

showOverflowMsg PROC
    PUSH DX
    
    LEA DX, OverflowStr
    CALL showStr
    
    POP DX
    RET
showOverflowMsg ENDP

showElemsPrompt PROC
    PUSH DX
    
    LEA DX, promptElemsStr
    CALL showStr
    
    POP DX
    RET
showElemsPrompt ENDP

showElemInput PROC
   ;PREPARE TO OUTPUT
    PUSH DX
    
    MOV DH, CH
    ADD DH, '0'
    MOV elemInputStr_2, DH

    MOV DL, CL
    ADD DL, '0'
    MOV elemInputStr_4, DL

    LEA DX, elemInputStr_1
    CALL showStr
    
    POP DX
    RET
showElemInput ENDP

showResult PROC
    PUSH DX
    
    LEA DX, resultStr_1
    CALL showStr
    
    POP DX
    RET
showResult ENDP

inputDims PROC
    LOOP_DIMS_ROWS:
    CALL showRowsInput
 
    CALL inputChar
    CMP AL, MAX_ROW
    JG ERROR_INPDIM_ROWS
    CMP AL, '0'
    JLE ERROR_INPDIM_ROWS
    
    SUB AL, '0'
    MOV rows, AL

    CALL inputChar
    CMP AL, CR
    JNE ERROR_INPDIM_ROWS

    LOOP_DIMS_COLS:
    CALL showColsInput

    CALL inputChar
    CMP AL, MAX_COL
    JG ERROR_INPDIM_COLS
    CMP AL, '0'
    JLE ERROR_INPDIM_COLS
    
    SUB AL, '0'
    MOV cols, AL

    CALL inputChar
    CMP AL, CR
    JNE ERROR_INPDIM_COLS

    JMP EXIT_INPDIM
ERROR_INPDIM_ROWS:
    CALL showIncMsg
    JMP LOOP_DIMS_ROWS
ERROR_INPDIM_COLS:
    CALL showIncMsg
    JMP LOOP_DIMS_COLS
EXIT_INPDIM:
    RET
inputDims ENDP

inputData PROC
    PUSH CX
    PUSH DX
    PUSH BX
    
    XOR CX, CX ;CH - ROW, CL - COLUMN
    XOR DX, DX ;DH - ROW NUM CHAR, DL - COL NUM CHAR
NEXT_COL:
    CMP CL, cols
    JE NEXT_ROW
INPUT_PROMPT:
    CALL showElemInput ;CH, CL SHOULD HAVE CORRECT VALUES
    CALL inputStr
    CALL strToSDec

    JC ERROR_INPUT
    
    PUSH AX
    MOV AL, CH   ;AL - multiplier
    MUL cols     ;AX - result
    
    MOV BX, AX
    ADD BL, CL   ;GET INDEX IN BX
    
    POP AX
    
    ADD BX, BX   ;BX*2, 1 EL - 2 B
    MOV matrix[BX], AX
    INC CL
    INC DL
    
    JMP NEXT_COL
ERROR_INPUT:
    CALL showIncMsg
    JMP INPUT_PROMPT
NEXT_ROW:
    INC CH
    INC DH
    
    CMP CH, rows
    JE EXIT_INPUT
    
    XOR CL, CL
    XOR DL, DL
    JMP NEXT_COL
EXIT_INPUT:
    POP BX
    POP DX
    POP CX  
    RET
inputData ENDP

inputChar PROC
    MOV AH, 01h
    INT 21h
    RET
inputChar ENDP

inputStr PROC
    PUSH AX
    PUSH DX
    
    MOV AH, 0Ah
    LEA DX, BUFSTR
    INT 21h
    
    POP DX
    POP AX
    RET
inputStr ENDP

strToUDec PROC
    PUSH CX
    PUSH BX
    PUSH SI
    PUSH DI
    
    MOV DI, 10
    MOV SI, DX
    MOV CL, AL ;CX - COUNTER, AL - STRING LENGTH
    MOV CH, 00
    JCXZ ERROR_STRTOUDEC
    XOR AX, AX
    XOR BX, BX

LOOP_STRTOUDEC:
    MOV BL, [SI]
    INC SI
    CMP BL, '0'
    JL ERROR_STRTOUDEC
    CMP BL, '9'
    JG ERROR_STRTOUDEC
    SUB BL, '0'
    MUL DI
    JC ERROR_STRTOUDEC ;IF RESULT GROWER THAN 16 BITS - ERROR
    ADD AX, BX ;ADD DIGIT
    JC ERROR_STRTOUDEC ;IF OVERFLOW - ERROR
    LOOP LOOP_STRTOUDEC
    JMP EXIT_STRTOUDEC ;CF = 0 - ALWAYS
ERROR_STRTOUDEC:
    XOR AX, AX
    STC  ; CF = 1 (ERROR)
EXIT_STRTOUDEC:
    POP DI
    POP SI
    POP BX
    POP CX
    RET
strToUDec ENDP

strToSDec PROC
    PUSH BX
    PUSH DX
    MOV AL, STRLEN
    LEA DX, STRFLD
    TEST AL, AL ;CHECK STRING LENGTH
    JZ ERROR_STRTOSDEC
    MOV BX, DX ;BX - String Address
    MOV BL, [BX] ;BL - First char in string
    CMP BL, '-'
    JNE CONVERT_NO_SIGN
    INC DX
    DEC AL
CONVERT_NO_SIGN:
    CALL strToUDec
    JC EXIT_STRTOSDEC
    CMP BL, '-'
    JNE PLUS_STRTOSDEC
    CMP AX, 32768
    JA ERROR_STRTOSDEC
    NEG AX
    JMP OK_STRTOSDEC
PLUS_STRTOSDEC:
    CMP AX, 32767
    JA ERROR_STRTOSDEC
OK_STRTOSDEC:
    CLC
    JMP EXIT_STRTOSDEC
ERROR_STRTOSDEC:
    XOR AX, AX
    STC
EXIT_STRTOSDEC:
    POP DX
    POP BX
    RET
strToSDec ENDP

mulCols PROC
    PUSH SI
    PUSH DI
    PUSH CX
    PUSH AX
    PUSH BX
    
    XOR CX, CX; CH - ROW, CL - COLUMN
    XOR BX, BX
START_ROW:    
    MOV BL, CL
    ADD BX, BX
    MOV AX, [matrix+BX]    ; GET FIRST EL OF COL
    
NEXT_ROW_MUL:
    
    PUSH DX
    MOV DH, rows
    SUB DH, 1
    CMP DH, CH
    POP DX
    
    JE NEXT_COL_MUL
    
    
    PUSH AX
    MOV AL, CH
    MUL cols
    MOV BX, AX
    ADD BL, CL
    POP AX
    
    ADD BL, cols
    ADD BX, BX
    
    IMUL [matrix+BX]
    
    JC OVERFLOW_MUL
      
    INC CH
    
    JMP NEXT_ROW_MUL
    
OVERFLOW_MUL:
    PUSH CX
    CLD
    LEA SI, overflowStr
    LEA DI, resultStr_4
    MOV CX, 9
    REP MOVSB
    POP CX
    JMP SHOW_RESULT_MUL
NEXT_COL_MUL:
    
    LEA DI, resultStr_4
    CALL wordToSdecStr
SHOW_RESULT_MUL:
    ADD CL, '0'
    MOV resultStr_2, CL
    SUB CL, '0'
    CALL showResult
    
    INC CL
    CMP CL, cols
    JE EXIT_MUL
    
    XOR CH, CH
    
    JMP START_ROW
    
EXIT_MUL:
    POP BX 
    POP AX
    POP CX
    POP DI
    POP SI
    RET
mulCols ENDP

wordToSdecStr PROC
    PUSH AX
    TEST AX, AX ;CHECK SIGN, SET SF, ZF, PF; OF, CF - SET 0
    JNS  NO_SIGN_WTSDS
    MOV [DI], '-'
    INC DI
    NEG AX
NO_SIGN_WTSDS:
    CALL wordToUdecStr
    POP AX
    RET
wordToSdecStr ENDP

wordToUdecStr PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH BX
    
    XOR CX, CX
    MOV BX, 10
    
LOOP_WTUDS_1:
    XOR DX, DX ;HIGH PART - NULL
    DIV BX     ; AX = (DX:AX)/BX, DX - REMAINDER OF THE DIVISION
    ADD DL, '0'; CONVERT REMAINDER TO SYMBOL CODE
    PUSH DX    ; SAVE REMAINDER IN STACK
    INC CX     
    TEST AX, AX
    JNZ LOOP_WTUDS_1
LOOP_WTUDS_2:
    POP DX       ;GETTING FROM STACK REMAINDERS
    MOV [DI], DL
    INC DI
    LOOP LOOP_WTUDS_2
    
    MOV [DI], '$'
    
    POP BX
    POP DX
    POP CX
    POP AX
    RET
wordToUdecStr ENDP
