.model tiny
.code
org 100h
_start:
	cld
	mov	ax, 0b800h
	mov	es, ax
	mov	di, 160 ; screen char position
@@1:

; CHARS --------------------
mov cx, 16
l: 
    xor dx, dx
ll:
    mov ax, 160   ;  00a0h
    MOV bl, 16
    sub bl, cl
    MUL bl  ; Теперь АХ = AL * BL

    mov di, ax
    add di, 6 + 160*3 ; skip 3 lines and chars 3

    mov ax, 2
    mul dl
    add di, ax ; point

    MOV bl, 16
    sub bl, cl
    mov ax, 16
    mul bl
    add ax, dx

    call draw_char

    inc dx    
    cmp dx, 16
    jl ll
    
    loop l
; CHARS --------------------



; ROW DIGITS --------------------
    xor dx, dx
@1:
    mov ax, 160   ;  00a0h

    mov di, ax
    add di, 3*2 ; skip 3

    mov ax, 2
    mul dl
    add di, ax ; point

    mov ax, dx

    call draw_dig

    inc dx    
    cmp dx, 16
    jl @1
; ROW DIGITS --------------------


; COL DIGITS --------------------

    xor dx, dx
@2:
    mov ax, 158   ;  00a0h
    MUL dl

    mov di, ax
    add di, 1*2 + 160 * 3 ; skip 1 char 3 lines

    mov ax, 2
    mul dl
    add di, ax ; point

    mov ax, dx

    call draw_dig

    inc dx    
    cmp dx, 16
    jl @2
    

; COL DIGITS --------------------




	xor	ah,	ah		; ROM BIOS 00h interrupt
	int	16h			; read charnum -> ah, char -> al

	cmp	al,	1bh		; esc
	je	@return

@return:
	ret

draw_dig:
    add al, 30h
    cmp al, 3ah
    jl draw_char
    add al, 7
draw_char:
	mov	ah,	070h
	stosw ; ax -> es:di
	ret

end _start