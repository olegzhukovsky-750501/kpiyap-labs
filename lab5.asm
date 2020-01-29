;Вариант 12
;В выходной файл поместить только те строки
;входного файла, которые не содержат все указанные символы   

.model small

.stack 100h

.data       

LF EQU 0Dh    ;LINE FEED
CR EQU 0Ah    ;CARRIAGE RETURN
ENDL EQU 0    ;END OF CMD LINE

CMDLEN EQU 80h
CMDADR EQU 81h

CMDMAXSIZE EQU 127  ;AFTER 80h
CMDMINSIZE EQU 7

cmd_size DB 0

cmd_buf DB CMDMAXSIZE + 2 dup(0)
path_src DB 129 dup (0)
path_src_tmp DB 128 dup (0)

chars_from_cmdline DB 200 dup('$')
chars_from_cmdline_size DW 0

path_dst DB "lab5out.txt", 0
ext DB "txt", '$'

buf DB 0
src_id DW 0
dst_id DW 0

absPosLow DW 0
absPosHigh DW 0

lowLinePos  DW 0
highLinePos DW 0


strbuf DB 200 dup('$')
size_strbuf DW 0

intro_msg DB "Success, you are here!", CR, LF, '$'
cmd_err_msg DB "bad args in cmdline", CR, LF, '$'
read_src_err_msg DB "Reading error from file", CR, LF, '$'
file_err_msg DB "File opening error", CR, LF, '$'
file_not_found_msg DB "File not found", CR, LF, '$'
exit_msg DB "Goodbye !!!", CR, LF, '$'
processing_msg DB "We are going to work !!!", CR, LF, '$'
  

.code

main PROC
    MOV AX, @DATA ; INIT DATA
    MOV ES, AX  
      
      
      
    ;WRITE CMD LINE TO cmd_buf
    MOV CL, DS:[CMDLEN]  ; DS POINTS TO PSP
    
    DEC CL     ;DEC CL BECAUSE FIRST CHAR IS SPACE
    MOV BL, CL
    
    MOV SI, CMDADR
    INC SI        ;STAY AT FIRST CHAR AFTER SPACE 
    
    LEA DI, cmd_buf
    
    REP MOVSB
    
    MOV DS, AX     ; NOW DS POINTS TO DATA SEGMENT 
    MOV cmd_size, BL 
    
    CMP cmd_size, 1
    JLE main_exit  
    
    print intro_msg
    
    CALL scanCmdLine                           
    
    JC main_exit
    
    CALL openFiles 
    JC main_exit
    
    print processing_msg
    CALL processData
main_exit:
    print exit_msg
    MOV AX, 4C00h
    INT 21h 
ENDP

scanCmdLine PROC
    XOR CX, CX
    XOR AX, AX
    
    CMP cmd_size, CMDMINSIZE
    JB  scanCmdLine_ERROR    
  
    MOV CL, cmd_size
                  
    LEA DI, cmd_buf
    ;INC DI         ;FIRST CHAR IS SPACE
    
search_for_first_space:
    MOV AL, [DI]
  
    CMP AL, ' '
    JE first_space_found     
    INC DI
    LOOP search_for_first_space    ;ex:at the end CX -3
first_space_not_found:
    JMP scanCmdLine_ERROR    
first_space_found:
    MOV CH, cmd_size
    SUB CH, CL    ;CH - HOW MUCH WE READED  ;ex:CH=11 -3 =8
    JMP go_back_from_first_space

go_back_from_first_space:
    CMP CH, 5              ;MINIMUM ex:c.txt
    JB scanCmdLine_ERROR
    MOV CL, CH           ;SAVE HOW MUCH WE READED IN CL
    XOR CH, CH
    
    PUSH CX             ;SAVE IN STACK CL
    
    MOV CX, 3
    
    LEA SI, ext     
    ADD SI, 3       ;POINT TO END OF EXT
    
loop_go_back_from_first_space:       ;CHECK EXTENSION
    DEC DI
    DEC SI
    MOV AL, [DI]
    MOV AH, [SI]
    CMP AL, AH
    JNE scanCmdLine_ERR_WITH_POP   
    LOOP loop_go_back_from_first_space
    
    DEC DI
    MOV AL, [DI]
    CMP AL, '.'
    JNE scanCmdLine_ERR_WITH_POP
    
    POP CX      ;CL - LENGTH OF FILE NAME TO THE FIRST SPACE
    
    PUSH CX
    
    MOV CH, 4   
    
    SUB CL, CH   ;LENGTH OF FILE NAME WITHOUT EXTENSION
    
    XOR CH, CH   ;BECAUSE LOOP DECREMENTS CX
;loop_go_back_from_point:       
;    DEC DI
;    MOV AL, [DI]
;    CMP AL, ' '
;    JE scanCmdLine_ERR_WITH_POP
;    LOOP loop_go_back_from_point

    POP CX       ;GET LENGTH OF FILE NAME
    PUSH CX      ;SAVE AGAIN
    XOR CH, CH   ;BECAUSE WE DECREMENT CX
    LEA SI, cmd_buf
    
    LEA DI, path_src
              
    REP MOVSB  ;NOW FILE NAME IS IN path_src
    
    POP CX
    
    LEA SI, cmd_buf  ;STAY TO FIRST CHAR AFTER FIRST SPACE 
    ADD SI, CX
    INC SI
    
    LEA DI, chars_from_cmdline
    
    INC CX

loop_copy_to_chars_string:    
    MOV AL, [SI]
    CMP CX, 125
    JE scanCmdLine_ERROR 
    CMP AL, 0  
    JE scanCmdLine_EXIT
     
    INC chars_from_cmdline_size
    INC CX
    MOV [DI], AL
    INC DI
    INC SI
    JMP loop_copy_to_chars_string
scanCmdLine_ERR_WITH_POP:
    POP CX       
scanCmdLine_ERROR:
    print cmd_err_msg
    STC
    RET
scanCmdLine_EXIT:
    MOV CX, chars_from_cmdline_size
    CMP CX, 0
    JE scanCmdLine_ERROR
    MOV [DI], LF
    CLC
    RET
    
ENDP

print MACRO msg
    PUSH AX
    PUSH DX
    
    MOV AH, 09h
    LEA DX, msg
    INT 21h
    
    POP DX
    POP AX
ENDM

openFiles PROC
    PUSH BX
    PUSH DX
    PUSH SI
    
    MOV AH, 3Dh ;OPEN EXISTING FILE
    MOV AL, 00h ;MODE - READ
    LEA DX, path_src
    INT 21h
    
    JC open_file_error
    
    MOV src_id, AX      ;FILE IDENTIFIER
                       
    MOV AH, 3Ch        ;3Ch - CREATE FILE
    XOR CX, CX         ;CX - FILE ATTRIBUTES
    LEA DX, path_dst
    INT 21h
    
    JC open_file_error
    
    MOV AH, 3Dh        ;OPEN DESTINATION FILE
    MOV AL, 02h        ;MODE - WRITE
    LEA DX, path_dst
    INT 21h
    
    JC open_file_error
    
    MOV dst_id, AX
    
    CLC                ;RETURN CODE - 0
    JMP open_files_exit
open_file_error:
    print file_err_msg
    
    CMP AX, 02h         ;AX - ERROR CODE, FILE NOT FOUND
    JE file_not_found_err
    
    JMP open_files_err_exit
file_not_found_err:
    print file_not_found_msg
open_files_err_exit:
    STC                ;RETURN CODE - 1
open_files_exit:
    POP SI
    POP DX
    POP BX
    RET
ENDP

processData PROC
next_line_in_file:
    MOV lowLinePos, 0  ;CHAR COUNTER IN LINE
    MOV highLinePos, 0   ;
    
    MOV BX, src_id       ;SOURCE FILE IDENTIFIER
    CALL setPointer      ;SET PTR TO BEGIN OF LINE
    
    LEA SI, chars_from_cmdline ;STAY AT BEGIN OF CMDLINE
read_line_in_file:
    CALL readCharFromFile
    
    incLinePos 1
    
    CMP AX, 0                 ;AX - NUMBER OF READED BYTES
    JE processData_EXIT
    
    CMP [buf], 0              ;IF NULL WAS READED - EOF
    JE processData_EXIT
    
    CMP [buf], CR
    JE end_of_string_reached
    CMP [buf], LF
    JE end_of_string_reached

    XOR AX, AX
    XOR BX, BX
    
    MOV AL, buf
    MOV BL, [SI]
    
    CMP AL, BL
    JE  check_end_of_line
    
    JMP read_line_in_file
end_of_string_reached:
    CALL writeStr
    JMP next_line_in_file
check_end_of_line:
    INC SI
    
    XOR BX, BX
    MOV BL, [SI]
    
    CMP BL, LF
    JE if_reached_end
    
    CMP BL, CR
    JE if_reached_end
    
    CMP BL, ENDL
    JE if_reached_end
    
    MOV lowLinePos, 0
    MOV highLinePos, 0
    
    MOV bx, src_id
    CALL setPointer
    
    JMP read_line_in_file
if_reached_end:
    CALL goToEnd
    JMP next_line_in_file
processData_EXIT:
    CALL writeStr        
    RET
ENDP

writeStr proc
    MOV BX, src_id
    CALL setPointer
    
    MOV BX, dst_id
    
    MOV lowLinePos, 1
    MOV highLinePos, 0

write:
    CALL readCharFromFile
    CALL incAbsPos
    
    CMP AX, 0
    JE endAll
    
    CMP [buf], CR
    JE endWrite
    CMP [buf], ENDL
    JE endAll
    
    MOV AH, 40h
    MOV CX, 1
    LEA DX, buf
    INT 21h
    
    JMP write
    
endWrite:
    MOV AH, 40h
    MOV CX, 1        ;1 BYTE TO WRITE
    LEA DX, buf
    INT 21h
endAll:

    RET
ENDP

incLinePos MACRO num
    ADD lowLinePos, num
    JO overflowLinePos
    JMP endIncLinePos

overflowLinePos:
    INC highLinePos
    ADD lowLinePos, 32769
endIncLinePos:
ENDM

incAbsPos PROC
    PUSH AX
    MOV AX, lowLinePos
    ADD absPosLow, AX
    JO overflow
    JMP endIncrement
    
overflow:
    INC absPosHigh
    ADD absPosLow, 32769
endIncrement:
    MOV AX, highLinePos
    ADD absPosHigh, AX
    
    POP AX
    RET
ENDP 

goToEnd PROC
    MOV BX, src_id
    CALL setPointer
    
    MOV lowLinePos, 1
    MOV highLinePos, 0
goEnd:
    CALL readCharFromFile
    CALL incAbsPos
    
    CMP AX, 0
    JE itsEnd
    
    CMP [buf], CR
    JE itsEnd
    CMP [buf], 0
    JE itsEnd
    
    jmp goEnd
    
itsEnd:
    RET
    ENDP

readCharFromFile PROC
    PUSH BX
    PUSH DX
    
    MOV AH, 3Fh     ;3F - read from file
    MOV BX, src_id
    MOV CX, 1       ;CX - number of readed chars
    LEA DX, buf
    INT 21h
    
    JNB readCharFromFile_SUCCESS     ;IF CF == 0
    
    print read_src_err_msg
    MOV AX, 0
    ;JC readCharFromFile_ERROR
    
    ;JMP readCharFromFile_SUCCESS

;readCharFromFile_SUCCESS:
;    CLC
;    JMP readCharFromFile_EXIT
;readCharFromFile_ERROR:
;    print read_src_err_msg
;    STC
readCharFromFile_SUCCESS:
    POP DX
    POP BX
    RET    
ENDP    


setPointer PROC  ;USES  absPosLow, absPosHigh
    PUSH CX
    PUSH BX
    
    MOV BX, src_id
    fseek absPosLow
    
    CMP absPosHigh, 0
    JE  setPointer_exit
    XOR CX, CX
    MOV CX, absPosHigh

set_offset:
    MOV BX, src_id
    fseekFromCurrent 32767
    LOOP set_offset
setPointer_exit:

    POP BX
    POP CX
    RET
ENDP

fseek MACRO position
    PUSH AX
    PUSH CX
    PUSH DX
    
    MOV AH, 42h   ;42h - SET FILE POINTER
    MOV AL, 0     ;SET POINTER TO BEGIN OF FILE
    XOR CX, CX            ;CX:DX
    MOV DX, position      ;(CX*65536)+DX
    INT 21h
    
    POP DX
    POP CX
    POP AX
ENDM

fseekFromCurrent MACRO offs
    PUSH AX
    PUSH CX
    PUSH DX
    
    MOV AH, 42h
    MOV AL, 1    ;FROM CURRENT POSITION
    MOV CX, 0
    MOV DX, offs
    INT 21h
    
    POP DX
    POP CX
    POP AX
ENDM                                        