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
    add di, 4*2 + 160*3 ; skip 3 lines and chars 3

    mov ax, 2 * 2
    mul dl
    add di, ax ; point

    MOV bl, 16
    sub bl, cl
    mov ax, 16
    mul bl
    add ax, dx

    call draw_char
    call draw_char

    inc dx    
    cmp dx, 16
    jl ll
    
    loop l
; CHARS --------------------


; void filler --------------------
    mov si, 3*2
    mov cl, 0h
    call vline
    mov si, 1*2
    call vline
; void filler --------------------

; ROW DIGITS --------------------
    xor dx, dx
@1:
    mov ax, 160   ;  00a0h

    mov di, ax
    add di, 4*2 ; skip 3

    mov ax, 2 * 2
    mul dl
    add di, ax ; point

    mov ax, dx

    call draw_dig
    call draw_char

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



; horizontal lines _________
    xor si, si
    mov cl, 0cdh ; =
    call hline
    mov si, 34
    call hline

    mov si, 160 * 2 ; 
    mov cl, 0c4h ; -
    call hline
    mov si, 160 * 2 + 34
    call hline

    mov si, 160 * 19 ; 
    mov cl, 0cdh ; =
    call hline
    mov si, 160 * 19 + 34
    call hline

; vertical lines _________
    xor si, si
    mov cl, 0bah ; =
    call vline

    mov si, 2 * 2 ; 
    mov cl, 0b3h ; -
    call vline

    mov si, 19 * 2 + 34; 
    mov cl, 0bah ; =
    call vline

; corners _________
    mov al, 0c9h ; left upper
    mov di, 0
    call draw_char
    
    mov al, 0c7h ; left middle
    mov di, 160 * 2
    call draw_char

    mov al, 0c8h ; left bottom
    mov di, 160 * 19
    call draw_char


    ; right
    mov al, 0bbh ; upper
    mov di, 19 * 2 + 34
    call draw_char
    
    mov al, 0b6h ; middle
    mov di, 160 * 2 + 19 * 2 + 34
    call draw_char

    mov al, 0bch ; bottom
    mov di, 160 * 19 + 19 * 2 + 34
    call draw_char

    ; mid
    mov al, 0d1h ; upper
    mov di, 2 * 2
    call draw_char
    
    mov al, 0c5h ; middle
    mov di, 160 * 2 + 2 * 2
    call draw_char

    mov al, 0cfh ; bottom
    mov di, 160 * 19 + 2 * 2
    call draw_char

; ESC __________
	xor	ah,	ah		; ROM BIOS 00h interrupt
	int	16h			; read charnum -> ah, char -> al

	cmp	al,	1bh		; esc
	je	@return

@return:
	ret

; cl: char  |  si: skip
hline:
    xor dx, dx
    mov bx, 2
    jmp line
vline:
    xor dx, dx
    mov bx, 160
line:
    mov ax, bx
    mul dl
    mov di, ax ; point
    add di, si

    mov al, cl
    call draw_char

    inc dx    
    cmp dx, 20
    jl line
    ret


draw_dig:
    add al, 30h
    cmp al, 3ah
    jl draw_char
    add al, 7
draw_char:
	mov	ah,	070h
	stosw ; ax -> es:di
    xor ax, ax
	ret

.data
shift dw 0030

end _start