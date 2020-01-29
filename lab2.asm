.model small
.stack 100h
.data
prompt db 'Enter your string: $'
mas db 100h dup (?)
arr1 db 100h dup (?)
arr2 dw 100h dup (?)
len dw 0
num dw 0
.code
start:
    mov ax, @data
    mov ds, ax
    mov ah, 09h
    lea dx, prompt
    int 21h
skip:
    mov ah, 01
    int 21h
    cmp al, 13 ;CHECK FOR "ENTER"
    je exit
    cmp al, 32  ;CHECK FOR "SPACE BUTTON"
    je skip
    xor si, si
    xor di, di
    xor bx, bx
begin:
    mov arr2[bx], si
input:
    mov mas[si], al
    inc arr1[di]
    inc len
    inc si
    mov ah, 1
    int 21h
    cmp al, 13
    je verify
    cmp al, 32
    je space
    jmp input
space:
    mov mas[si], '$'
    inc arr1[di]
    inc len
    inc si
    inc num
    add bx, 2
    inc di
return:
    mov ah, 1
    int 21h
    cmp al, 13
    je verify
    cmp al, 32
    je return
    jmp begin
verify:
    mov si, len
    cmp mas[si - 1], '$'
    je main
    mov mas[si], '$'
    inc len
    inc num
    inc arr1[di]
main:
    xor si, si
    xor di, di
    xor bx, bx
nazad:
    mov al, arr1[si]
    mov di, si
    mov bx, si
normal:
    inc si
    cmp si, num
    je bye
    cmp al, arr1[si]
    jl change
    jmp normal
change:
    mov cl, arr1[si]
    mov arr1[si], al
    mov arr1[di], cl
    add si, si
    add di, di
    mov ax, arr2[si]
    mov cx, arr2[di]
    mov arr2[si], cx
    mov arr2[di], ax
    jmp main
bye:
    inc bx 
    cmp bx, num
    je final
    mov si, bx
    jmp nazad
final:
    mov ax, 3
    int 10h
    xor si, si
    xor di, di
    mov cx, num
output:
    mov ah, 9
    mov si, arr2[di]
    lea dx, mas[si]
    int 21h
    mov ah, 2
    mov dl, 32
    int 21h
    add di, 2
    loop output
exit:
    mov ax, 4c00h
    int 21h
end start