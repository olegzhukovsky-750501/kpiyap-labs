.model small

.stack 100h

.data
	plane_pos dw 150,180		;��������� ������� ��������
	smile_pos db 10,3,12,4,15,2,19,4,21,1,25,5,28,3,30,1,9,2,7,5,1,2,33,3,35,2,0,0		;��������� ������� ������(y,x)
	destroy	  db 0			;���� �� ����
	delay_timer db 0
	old_handler_seg dw 0
	old_handler_off dw 0
	timecontrol db 18		;�������� ��������
	message db 'Your score:','$'
	score db 3 dup('0'),'$';���� ��� ����� ��� �����������
    	score_b db 00h ;�������� ��� �����, ������������ ��� ��������
	;���� ������� ����
    	message_welcome db '~~~~~~~~~~~~~ Welcome to game ~~~~~~~~~~~~','$'
    	message_operation db "How to play:",'$'
    	message_operation1 db "Move:left right up and down",'$'
    	message_operation2 db 'Shoot:space bar','$'
		message_operation3 db 'Score: hit(+1) miss opponents(-5) collide(Game Over)','$'
    	message_operation4 db 'Now,you can:','$'
    	start_button db "Press 'Enter' to start the game$"
    	end_button db "Press 'ESC' to quit the game$"
    	message_end db '********GOOD LUCK!*********','$'
	message_easy db "1.Easy",'$'
	message_mid db "2.Middle",'$'
	message_hard db "3.Hard",'$'
	message_veryhard db "4.Extremely hard",'$'
	message_choose db "Please choose:",'$'
	    message_over1 db '****************************','$'
		message_over2 db '*******   GAME OVER  *******','$'
    	message_over3 db '****************************','$'

.code

main PROC
;	mov al,34h   ; ���������� �������� ������������ �����
;	out 43h,al   ; �������� ����������� ����� � ������� ������������ ����� 
;	mov ax,0ffffh ; ��������� ������� ����������
;	out 40h,al   ; �������� ������� ���� �������� 0
;	mov al,ah    ; AL=AH 
;	out 40h,al   ; �������� �������� ���� �������� 0 

	mov ax,@data
	mov ds,ax 
	
    call help_view       
	call choose_view
    
    
    mov ah, 35h
    mov al, 8h
    int 21h
    
	mov old_handler_off, bx
	mov old_handler_seg, es
	
	mov ah, 25h
	mov al, 8h
	mov dx, cs
	mov ds, dx
	mov dx, offset int8_handler
	int 21h
	
	;pushf
;	cli
;	mov word ptr ds:[20h],offset Timer	;���������� ����� �������� ������� ���������� ������� � 8 ������ ���������� (32/4)
;	mov ax,cs 
;	mov word ptr ds:[22h],ax		; ���������� ����� �������� ������� ���������� ������� = CS
;	popf
		   
	mov ax, @data
	mov ds,ax  
		 
        mov ah,00H		;��������� ������ ����������� �� 320 * 200 ������� ����������� �����
        mov al,04H
        int 10H 
        
		mov ah,02;��������� ������� �������
		mov bh,00 ;��������
		mov dh,0  ;������
		mov dl,0  ;�������
		int 10h 
		
		mov ah,09
		mov dx,offset message
		int 21h
		
        mov bx,150   ;���������� ��������� �������������� ��������� ��������
       	mov bp,180   ;���������� ��������� ������������ ��������� ��������
        mov [plane_pos],bx
        mov [plane_pos+2],bp      
		call play_smile		;��������� ������
lop3: 
      	call play_plane1	;������� ���������� ������ ��������
      	call play_plane		;��������� ��������		
      	mov cx,bx
      	mov dx,bp
again:		
		mov ah,01      ;��������, ���� �� ������, ���� ����, ��� ������
		int 16h
		jz again		;��� ������ ��������, ��������� ��� ���
        ;������ ������� �� ����������          
      	mov ah,0H	
      	int 16H
	 	  
      	cmp ah,72
      	je up
      	cmp ah,80
      	je down
      	cmp ah,75
      	je left
      	cmp ah,77
      	je right
	    cmp ah,57	;������
	    je shoot
      	cmp ah,01	;����� 
      	je endthegame
      	jmp lop3

up: 	
        cmp bp, 12
        jbe again
        sub bp,3
      	jmp lop3

down: 	cmp bp, 180
        jae again
        add bp,3
      	jmp lop3

left: 	
        cmp bx, 3
        jbe again
        sub bx,3 
       	jmp lop3
right: 	
        cmp bx, 305
        jae again
        add bx,3
        jmp lop3   

shoot:
	call shoot_plane
	jmp lop3

    ret
main endp

int8_handler proc far
	push ax
	mov al,byte ptr ds:[timecontrol]
	cmp byte ptr ds:[delay_timer],al
	pop ax
	jnz	exit_int8_handler
	mov byte ptr ds:[delay_timer],0
	call move_smile
	JC exitgame_int8_handler
	;call delay2
	call play_smile		;��������� ������
	JMP exit_int8_handler
exitgame_int8_handler:
    jmp endthegame   
exit_int8_handler:
	inc byte ptr [delay_timer]
	push ax
	mov al,20h			; AL = EOI
	out 20h,al			;
	out 0A0h,al			; 
	pop ax
	iret			;������� �� ����������
int8_handler endp


    
;���������� ������� ������ �������� ��������
;bx ������������� �������������� ��������� �������� BP ������������� 
;������������ ��������� ��������. BX, BP ���������� ��������� ��������
play_plane proc    
	push cx
	push dx
	push es
	push si
	push di
	push ax
	
	jmp sk

play_plane_1: dw 6,1,1,5,2,3,5,3,3,5,4,3,4,5,5,3,6,7,1,7,11,1,8,11,4,9,5,5,10,3,4,11,5,3,12,7,4,13,2,7,13,2 ;X,Y,�����

sk: 
	mov cx,ax
	mov ax,cs
	mov es,ax
	mov di,0
         
lop2: 
	mov cx,word ptr es:[play_plane_1+di]    ;x
    add cx,bx                          
    mov dx,word ptr es:[play_plane_1+di+2]   ;y
    add dx,bp
    mov si,word ptr es:[play_plane_1+di+4]   ;�����
    
 	call sp_line
 	add di,6
 	cmp di,84
 	jne lop2
     	
	;�������� ������� ��������
	mov ds:[plane_pos],bx
    mov ds:[plane_pos+2],bp 

 	pop ax 
 	pop di
 	pop si
 	pop es
 	pop dx
 	pop CX

     	ret
play_plane endp
;//////////////////////      

    
play_plane1 proc ;������� �������. ��������� ������� CX - X, DX, Y
     
      push si
      push di
   
      inc cx
      mov si,13
      
      mov di,0
lop5: inc di
      inc dx
      call sp_line1
      cmp di,14     ;14 ��� �� Y
      jne lop5
      pop di
      pop si

      ret
play_plane1 endp
;////////////////////////////////////////

;//�������� ������
play_smile proc
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	mov si,offset smile_pos
	inc si
	mov di,offset smile_pos
show_smile:	
	;��������� ������� �������
	mov ah,02H
	mov bh,0                    ;��������
	mov dh,byte ptr [si]		;Y ������
	mov dl,byte ptr [di]		;X �������
	int 10H
	;�������� �������
        mov ah,09H
        mov al,2           ;�������
        mov bl,011111001b  ;������� �������
        mov	cx,1           ;��������� 1 ���
        int 10H
	inc si                 ;��������� �� �������� ���� ���������
	inc si
	inc di
	inc di
	cmp byte ptr [si],0    ;���� 0, �� �������, ����� ������� �� ����� ������
	jnz show_smile
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
play_smile endp

;����������� ������, ������� ��������� ��������� ��������� ������, 
;�������� ������ � ����������� �������
move_smile proc
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	;call delay2	
	mov si,offset smile_pos
	inc si
	mov di,offset smile_pos
erase_smile:	
	;��������� ������� �������
	mov ah,02H
	mov bh,0
	mov dh,byte ptr [si]		;������
	mov dl,byte ptr [di]		;�������
	int 10H
	;������� �������
        mov ah,09H
        mov al,2	
        mov bl,0	;������ ����
        mov cx,1
        int 10H
		
	;���������� ������������	
	mov ax,word ptr [plane_pos]	;������
	mov bl,8
	div bl 
	cmp al,dl
	jz  row 
	inc al
	cmp al,dl
	jz row	
	inc al
	cmp al,dl
	jnz notexit
row:
	mov ax,word ptr [plane_pos+2]	;�������
	mov bl,8
	div bl
	cmp al,dh
	jz exit_game
notexit:		
	;��������� ��������� ��������
	inc byte ptr [si]
	cmp byte ptr [si],25
	jnz goon
	mov byte ptr [si],1
	xor ax,ax
	mov al,byte ptr ds:[score_b]
	cmp al,5	
	jb	exit_game		;����� 5 ���� ��������
	;�����
	sub al,5
	mov byte ptr ds:[score_b],al	;����� 5 �������	
	
	push ax
	push si
	push bx
	push dx	
	mov si,offset score
	call b2asc
	mov ah,02	;�������� ���������� ����
    mov bh,00
    mov dh,0
    mov dl,11
    int 10h
    mov ah,09
    mov dx,offset score
    int 21h
	pop dx
	pop bx
	pop si
	pop ax
	
goon:
	inc si
	inc si
	inc di
	inc di
	cmp byte ptr [si],0
	jnz erase_smile
	CLC
	jmp exit_move_smile

exit_game:
    STC   
exit_move_smile:	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
move_smile endp

;������� �������� ���������� ������ ������� �������� ������ bx + 5, bp
shoot_plane proc
	push ax
	push bx
	push cx
	push dx
	push si
	push bp
	mov cx,bx
 	add cx,5	;x - BX+5
	mov dx,bp	;y ����������	
	dec	dx
	push dx
	;��������, ���� �� � ������� ���������� ����
	mov si,offset smile_pos	
lop7:
	mov ax,0
	mov al,byte ptr [si]
	cmp ax,0
	jz next
	mov bl,8   
	mul bl     ;40*25 ��������������, AL*BL = AX
	mov dx,9
lop8:
	cmp ax,cx	;��������� ��� ���������� �������� X ���� ��� ��������� � ����������� X ������ �������
	jz same
	inc ax
	dec dx
	jnz lop8
	inc si 
	inc si
	jmp lop7

same:	
	;� ���� ������� ���� ����, ������ ��
	mov byte ptr ds:[destroy],1
	push ax
	push si
	push bx
	push dx
	xor ax,ax
	mov al,byte ptr ds:[score_b]
	add al,1
	mov byte ptr ds:[score_b],al
	mov si,offset score
	call b2asc
	mov ah,02;�������� ����
    mov bh,00
    mov dh,0
    mov dl,11
    int 10h
    mov ah,09
    mov dx,offset score
    int 21h
	pop dx
	pop bx
	pop si
	pop ax
	jmp next

next:	
	pop dx
a0: 
	;�������� ���������� �������
	MOV BX, 2   ;������
	INC DX      ;��������� �� �������
a1:	MOV AH,0CH	;��������� ����������� �����
	MOV AL,0	;����	
	INT 10H
	INC CX      ;��������� �� ��������
	DEC BX
	JNZ a1		;������� �����
 	SUB CX,2
	MOV BX,2
	DEC DX
	
a2:	MOV AH,0Ch
	MOV AL,11	;����	
	INT 10H
	INC CX   
	DEC BX
	JNZ a2		;���������� ������ ��������
 	SUB CX,2
	CALL delay
	DEC DX
	CMP DX,6	;���� ��������� ��������
	JA a0
	cmp byte ptr ds:[destroy],0
	jz notdes

	;��������� ������� �������
	MOV AH,02H
	MOV BH,0
	MOV DH,byte ptr [si+1]		
	MOV DL,byte ptr [si]
	INT 10H
	;������� �������
    MOV AH,09H
    MOV AL,2	
    MOV BL,0	;��������� ������
    MOV CX,1
    INT 10H
	mov byte ptr [si+1],1	;���������� ������
	mov byte ptr ds:[destroy],0
notdes:	
	;������� ��������� ������
	mov bp,sp
	mov cx,word ptr ss:[bp+8]
	add cx,5
	mov dx,7
	MOV AH,0CH	;�������� � ���� ����������� �����
	MOV AL,0	;����	
	INT 10H
	inc cx
	MOV AH,0CH
	MOV AL,0	;����	
	INT 10H
	pop bp
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
shoot_plane endp

;��������� �������������� ������ �����
; ������� �������� CX ������������ X DX ������������ Y, si ����� ����������� BL �������

sp_line proc
         push ax
         push bx
         
         MOV BL,2    ;���� �������� - �������
         MOV AH,0Ch  ;�������� �����
         MOV AL,BL
lop:   	 INT 10H
         inc CX
         dec si
         
         jnz lop
         pop bx
         pop ax
         ret
sp_line endp
;/////////////////////////////


; ��������� �������������� ������ �����
; ������� �������� CX ������������ X, DX ������������ Y, si ����� ����������� BL �������
sp_line1 proc
         push ax
         push bx
         push bp
         push di     
         
     	 MOV bp,CX
      
         MOV di,11   ;�������� 11 ��������
         MOV BL,0    
         MOV AH,0cH
         MOV AL,BL   ;������ ����
lop1: 	 INT 10H
         inc CX      ;��� �������������
         dec di
      
         jnz lop1    
         MOV CX,bp
         
         pop di
         pop bp
         pop bx
         pop ax
         ret
sp_line1 endp
;/////////////////////////////
        

;��������� ������������ �����
;������� �������� CX - X0. DX - y0. si ����� ����������� BL �������

sp_line2 proc
         pusH ax   
         MOV AH,0cH
         MOV AL,BL
lop6:   INT 10H
         inc dx
         dec si
         jnz lop6
         pop ax
         ret
sp_line2 endp
;/////////////////////////////




;/////////////////��������
delay proc 
	pusH dx
	pusH CX

	MOV CX,02H
sleep2:
	MOV dx,02f0H ;��������� ���������

sleep1: 
	dec dx
	CMP dx,0
	jne sleep1

	dec CX
	CMP CX,0
	jne sleep2

	pop CX
	pop dx
	ret
delay endp
;//////////////////

;/////////////////
delay2 proc 
	push dx
	push cx

	MOV CX,20H
sleep4:
	MOV dx,0ffffH

sleep3: 
	dec dx
	CMP dx,0
	jne sleep3

	dec CX
	CMP CX,0
	jne sleep4

	pop cx
	pop dx
	ret
delay2 endp
;//////////////////

help_view proc  ; ����������� ����
     call clearscreen ;�������� �����
	 mov ah,02        ;��������� ������� �������
	 mov bh,00
	 mov dh,04
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset message_welcome
	 int 21h	 
	 mov ah,02
	 mov bh,00
	 mov dh,06
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset message_operation
	 int 21h	 
	 mov ah,02
	 mov bh,00
	 mov dh,08
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset message_operation1
	 int 21h	 
	  mov ah,02
	 mov bh,00
	  mov dh,10
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset message_operation2
	 int 21h	 
	  mov ah,02
	 mov bh,00
	  mov dh,12
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset message_operation3
	 int 21h
	  mov ah,02
	 mov bh,00
	  mov dh,14
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset message_operation4
	 int 21h
	  mov ah,02
	 mov bh,00
	  mov dh,16
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset start_button
	 int 21h
	  mov ah,02
	 mov bh,00
	  mov dh,18
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset end_button
	 int 21h 
	  mov ah,02
	 mov bh,00
	  mov dh,20
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset message_end
	 int 21h
	 ;�������� �� ������� �������
checkbutton:
	 mov ah,01   ;�������� ���������� �������
	 int 16h
	 jz checkbutton ;���� ������ �����
	 mov ah,0       ;������(�������) ��������� ������� �������
	 int 16h
	 cmp ah,1ch; ���� ���� ������ ������� enter
	 je startthegame
	 cmp ah,01h;Esc key
	 je exit_from_game
	 jmp checkbutton
startthegame:
     call clearscreen ;������� ������
	 ret
exit_from_game:
     call clearscreen
     mov ax, 4c00h
     int 21h
help_view endp
;-------------------------------------------------------------------

choose_view proc  ;�������� ���� ������ ���������
	 mov ah,02
	 mov bh,00
	 mov dh,04
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset message_easy
	 int 21h	 
	 mov ah,02
	 mov bh,00
	 mov dh,06
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset message_mid
	 int 21h	 
	 mov ah,02
	 mov bh,00
	 mov dh,08
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset message_hard
	 int 21h	 
	  mov ah,02
	 mov bh,00
	  mov dh,10
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset message_veryhard
	 int 21h
	  mov ah,02
	 mov bh,00
	  mov dh,12
	 mov dl,23
	 int 10h
	 mov ah,09
	 mov dx,offset message_choose
	 int 21h	 
	 ;�������� ������� �������
checkbutton2:
	 mov ah,01
	 int 16h      
	 jz checkbutton2
	 mov ah,0
	 int 16h
	 cmp al,'1'
	 je easy
	 cmp al,'2'
	 je middle
	 cmp al,'3'
	 je hard
	 cmp al,'4'
	 je veryhard
	 jmp checkbutton2

easy:
	mov byte ptr [smile_pos+12],0
	mov byte ptr [smile_pos+13],0
	mov byte ptr [timecontrol],18
	jmp sta
middle:
	mov byte ptr [smile_pos+18],0
	mov byte ptr [smile_pos+19],0	 
	mov byte ptr [timecontrol],15 
	jmp sta
hard:
	mov byte ptr [timecontrol],11 
	jmp sta
veryhard:
	mov byte ptr [timecontrol],7
sta:    
	call clearscreen
	ret
choose_view endp
;-------------------------------------------------------------------



;-------------------------------------------------------------------
clearscreen proc ;�������� �����
	push ax
	push bx
	push cx
	push dx  
	
	mov ah,06  ;������ �� ������� ������
	mov al,00  
	mov bh,07  ;���������� �������(�����/�����)
	mov ch,00  ;������� ����� �������
	mov cl,00
	mov dh,24   ;������ ������ �������
	mov dl,79
	int 10h   
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
clearscreen endp
;----------------------------------------------------------------------
;-----------------------------------------------------------------------
b2asc proc ;�������� ��� -->  ����
	pushf
	push bx
	push dx
	mov bx,10
	mov byte ptr [si],'0'
	inc si
	mov byte ptr [si],'0'
	inc si
	mov byte ptr [si],'0'
 b2a_loop:
     xor dx,dx
     div bx
     or dx,30h
     mov [si],dl
     dec si
     cmp ax,0
     ja b2a_loop
     pop dx
     pop bx
     popf
     ret
b2asc endp


endthegame:
     call delay2
     
     push ds
     mov dx, old_handler_off
	 mov ds, old_handler_seg
	 mov ah, 25h
	 mov al, 8h
	 int 21h
	 pop ds 
	 
	 mov ah,00
	 mov al,00
	 int 10h
	 call clearscreen 
	 mov ah,02
	 mov bh,00
	 mov dh,9
	 mov dl,6
	 int 10h
	 mov ah,09
	 mov dx,offset message_over1
	 int 21h	 
	 mov ah,02
	 mov bh,00
	 mov dh,11
	 mov dl,6
	 int 10h
	 mov ah,09
	 mov dx,offset message_over2
	 int 21h	 
	 mov ah,02
	 mov bh,00
	 mov dh,13
	 mov dl,6
	 int 10h
	 mov ah,09
	 mov dx,offset message_over3
	 int 21h
	 
	 call delay2 
	 
	 mov ah,00H		;��������� ������������ ������
     mov al,03H
     int 10H
     
     mov al,20h			;EOI
	 out 20h,al	
	 out 0A0h,al		
	 
	 mov ax, 4c00h
	 int 21h