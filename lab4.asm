.MODEL SMALL

.STACK 100h

CR  EQU 0Dh
LF  EQU 0Ah
MaxBufLen   EQU 254
MaxWordNum  EQU MaxBufLen/2

.DATA
STRPAR LABEL  BYTE
MAXLEN DB 253
STRLEN DB ?
STRFLD DB 254 DUP('$')
     
sdPrompt DB   "Enter your string (empty string - exit)"
sdCrLf   DB   CR, LF, "$"
numWrd   DB   ?
sdWrdPar DW   2*MaxWordNum dup(?)

.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    LEA SI, STRFLD
    CALL inputStr
    JCXZ EXIT_0
    LEA  DI, sdWrdPar 
    CALL initLenPosArray
    CMP  CX, 1
    JB   EXIT_0
    JE   SHOW
    CALL sortWords
    SHOW:
    LEA  DX, STRFLD
    CALL showStr
EXIT_0:
    MOV AX, 4c00h
    INT 21h             
    
    
    

crLf PROC
    LEA DX, sdCrLf
    CALL showStr
    RET
crLf ENDP
    
showStr PROC
    MOV AH, 09h
    INT 21h
    RET 
showStr ENDP
inputStr PROC
    LEA DX, sdPrompt
    CALL showStr
    MOV AH,0Ah
    LEA DX,STRPAR
    INT 21h
    CALL crLf
    XOR CH, CH
    MOV CL,STRLEN
    RET
inputStr ENDP

initLenPosArray PROC
    PUSH DI
    PUSH SI
    MOV  AX, SI
    XOR  DX, DX      ; DX - NUMBER OF WORDS
wordloop:
    CALL getWord
    JCXZ EXIT_1
    SUB  BX, AX
    MOV  byte ptr [DI], BL
    INC  DI
    MOV  byte ptr [DI], CL
    INC  DI
    INC  DX
    JMP  wordloop
EXIT_1:
    MOV  CX, DX
    POP  SI
    POP  DI
    RET    
initLenPosArray ENDP

getWord PROC
    PUSH AX
    XOR CX, CX ; WORD LENGTH
skipspace:
    LODSB
    CMP AL, CR
    JE  EXIT_2
    CMP AL, 32
    JE  skipspace
itsword:
    DEC SI
    MOV BX, SI
searchwordterm:
    LODSB
    CMP AL, CR
    JE  wordfound
    CMP AL, 32
    JE  wordfound
nextchar:
    INC CX
    JMP searchwordterm
wordfound:
    DEC SI
EXIT_2:
    POP AX
    RET    
getWord ENDP

sortWords PROC
    MOV numWrd, CL
    XOR CX, CX
    XOR AX, AX
j2:
    MOV CL, numWrd  ;CL - Number of words
    DEC CL
    MOV AL, 02h
    MUL CL
    MOV CL, AL
c0:
    MOV BX, CX
    MOV AL, byte ptr sdWrdPar[BX+1]
    MOV AH, byte ptr sdWrdPar[BX-1]
    CMP AL, byte ptr sdWrdPar[BX-1]
    JA  j1
    DEC CX
    LOOP c0
    JMP j0
j1:
    MOV DX, sdWrdPar[BX-2]
    MOV AX, sdWrdPar[BX]
    MOV sdWrdPar[BX], DX  
    MOV sdWrdPar[BX-2], AX
    CALL swapWords
    
    
    
    MOV AL, byte ptr sdWrdPar[BX]
    MOV AH, byte ptr sdWrdPar[BX-2]
    MOV byte ptr sdWrdPar[BX-2], AL
    
      
    
    MOV AL, byte ptr sdWrdPar[BX+1]
    MOV DL, byte ptr sdWrdPar[BX-1]
    MOV DH, DL
    SUB DH, AL
    
    ADD AH, DH
    MOV byte ptr sdWrdPar[BX], AH
    
    JMP j2
    j0:
    RET
sortWords ENDP

swapWords PROC
         ;BX - INDEX OF ELEMENT in sdWrdPar
    CALL reverseStr
    SUB  BX, 2 
    CALL reverseStr
    CALL revSubStr
    ADD  BX, 2
EXIT: 
    RET
swapWords ENDP

reverseStr PROC
    PUSH SI
    PUSH DI
init:
    XOR CX, CX
    MOV CL, byte ptr sdWrdPar[BX+1]  ;CL - WORD LENGTH
    ADD SI, CX
    MOV CX, sdWrdPar[BX]             ;CX - WORD OFFSET
    XOR CH, CH  
    ADD SI, CX             ; SI - END OF WORD
    STD
    DEC SI
    MOV DI, CX
change_str:
    DEC SI
    INC DI
    CMP SI, DI
    JBE EXIT_3 
    INC SI
    DEC DI
    LODSB
    MOV AH, STRFLD[DI]  ; DI - begin
    MOV STRFLD[DI], AL
    MOV STRFLD[SI-1], AH
    INC DI
    JMP change_str
EXIT_3:
    POP DI
    POP SI
    RET
reverseStr ENDP

revSubStr PROC
    PUSH SI
    PUSH DI
    XOR CX, CX
    MOV CL, byte ptr sdWrdPar[BX+1]
    ADD SI, CX
    MOV CX, sdWrdPar[BX]
    XOR CH, CH
    ADD SI, CX         ; SI - END OF SUBSTRING
    DEC SI
    
    MOV CX, sdWrdPar[BX+2]
    XOR CH, CH
    MOV DI, CX
    STD
    
change_sub:
    DEC SI
    INC DI
    CMP SI, DI
    JBE EXIT_4
    INC SI
    DEC DI
    
    LODSB
    MOV AH, STRFLD[DI]  ; DI - begin
    MOV STRFLD[DI], AL
    MOV STRFLD[SI-1], AH
    INC DI
    JMP change_sub
EXIT_4:
    POP DI
    POP SI
    RET
revSubStr ENDP

    END START 