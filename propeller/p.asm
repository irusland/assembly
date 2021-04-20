model tiny 
.code 
org 100h
_start:
    jmp begin
msg1 db '1', 0dh, 0ah, 24h
msg2 db '2', 0dh, 0ah, 24h
msg3 db '3', 0dh, 0ah, 24h

tab dw offset m1
    dw offset m2
    dw offset m3
begin:
    mov al, 1

    mov si, offset tab
    xor bx, bx
    mov bl, al
    shl bx, 1
    add si, bx
    ; jmp [si]
    call tab[bx]
m0:
    ret
m1:
    mov dx, offset msg1
    jmp m4
m2:
    mov dx, offset msg2
    jmp m4
m3:
    mov dx, offset msg2
m4:
    mov ah, 9
    int 21h
    jmp m0
end _start