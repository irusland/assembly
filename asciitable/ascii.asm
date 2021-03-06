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
; cs shift relative
; bx base symbol
; ss switch symbol? (> 10 => ABCDEF)
; si skip base

mov ax, 2 * 2
mov ds, ax
; mov bx, 2 * 2
mov word [switch_symbol], 0 ; no switch

xor cx, cx
l: 
    mov ax, 160   ;  00a0h
    MUL cl  ; Теперь АХ = AL * BL
    mov si, 4*2 + 160*3
    add si, ax

    mov ax, 16
    mul cl
    mov bx, ax; loop inc

    call draw_iter_char

    inc cx    
    cmp cx, 16
    jl l
; CHARS --------------------


; void filler --------------------
    mov si, 3*2
    mov cl, 0h
    call vline
    mov si, 1*2
    call vline
; void filler --------------------


; DIGITS ----------------
mov [switch_symbol], 1
; row
mov cx, 2 * 2 ; shift
mov si, 4*2 + 160 ; skip
call names
; col
mov cx, 160
mov si, 1*2 + 160 * 3 
call names
; DIGITS --------------------



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

names: ; cx: shift  |  si: skip
    xor dx, dx
@1:
    mov ax, cx ; shift
    mul dl
    mov di, ax ; point

    add di, si; skip

    mov ax, dx

    call draw_dig
    call draw_char

    inc dx    
    cmp dx, 16
    jl @1
    ret


; cs shift relative
; bx base symbol
; ss switch symbol? (> 10 => ABCDEF)
; si skip base
draw_iter_char:
    xor dx, dx
ll:
    mov di, si ; skip

    mov ax, ds
    mul dl
    add di, ax ; point

    mov ax, bx
    add ax, dx

    call draw_dig
    call draw_char

    inc dx    
    cmp dx, 16
    jl ll
    ret

hline: ; cl: char  |  si: skip
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
    cmp [switch_symbol], 0 ; switch symbol
    je draw_char

    add al, 30h
    cmp al, 3ah
    jl draw_char
    add al, 7
draw_char:
	mov	ah,	070h
	stosw ; ax -> es:di
    xor ax, ax
	ret

; .data
switch_symbol dw 0
shift_relative dw 0

end _start