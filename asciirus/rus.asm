.model tiny
.code
org 100h
_start:
jmp @@1
translation equ 2 * 21
color equ 070h

setup proc near
    ; cls
    mov ah, 00h
    mov al, 03h
    int 10h

    ; select font
    ; mov ax, offset fonts_start
    ; mov font, ax

    ; load font
    mov ah, 11h
    mov al, 00h ; user font
    mov bx, ds
    mov es, bx ; es:bp table
    mov bp, font
    mov cx, 256 ; char count 
    mov dx, 0 ; table char (letter) offset
    mov bl, 0 ; font block (0-3)
    mov bh, 8 * 2 ; bytes per char
    int 10h

    ret
setup endp



teardown proc near
    mov ah, 00h
    mov al, 03h
    int 10h
    ret
teardown endp





begin proc near
@@b:
	xor	ah,	ah		; ROM BIOS 00h interrupt
	int	16h			; read scan -> ah, char -> al
	cmp al,	0
	je	@@change_font
	cmp	al,	1bh		; esc
	je	@@reboot
    jmp @@b

@@1:
    call setup

	cld
	mov	ax, 0b800h
	mov	es, ax
	mov	di, 160 ; screen char position

    push ds
    call draw_table
    pop ds
    jmp @@b

@@change_font:
	cmp ah,	48h
	je	@up
	cmp ah,	50h
	je	@down
    jmp @@1

@up:
    mov ax, font
    sub ax, font_size
    cmp ax, offset fonts_start
    jg good
    mov ax, offset fonts_end - font_size
    jmp good
@down:
    mov ax, font
    add ax, font_size
    cmp ax, offset fonts_end
    jb good
    mov ax, offset fonts_start
good:
    mov font, ax
	jmp @@1

@@reboot:
    call teardown
    ret


switch_symbol dw 0
shift_relative dw 0
begin endp

draw_table proc near

; CHARS --------------------
; cs shift relative
; bx base symbol
; ss switch symbol? (> 10 => ABCDEF)
; si skip base

mov ax, 2 * 2
mov ds, ax
; mov bx, 2 * 2
mov switch_symbol, 0 ; no switch

xor cx, cx
l: 
    mov ax, 160   ;  00a0h
    MUL cl  ; Теперь АХ = AL * BL
    mov si, 4*2 + 160*3 + translation
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
    mov si, 3*2 + translation
    mov cl, 20h
    call vline
    mov si, 1*2 + translation
    call vline
; void filler --------------------


; DIGITS ----------------
mov switch_symbol, 1
; row
mov cx, 2 * 2 ; shift
mov si, 4*2 + 160 + translation ; skip
call names
; col
mov cx, 160
mov si, 1*2 + 160 * 3  + translation
call names
; DIGITS --------------------



; horizontal lines _________
    mov si, translation
    mov cl, 0cdh ; =
    call hline
    mov si, 34 + translation
    call hline

    mov si, 160 * 2 + translation; 
    mov cl, 0c4h ; -
    call hline
    mov si, 160 * 2 + 34 + translation
    call hline

    mov si, 160 * 19 + translation; 
    mov cl, 0cdh ; =
    call hline
    mov si, 160 * 19 + 34 + translation
    call hline

; vertical lines _________
    mov si, translation
    mov cl, 0bah ; =
    call vline

    mov si, 2 * 2 + translation; 
    mov cl, 0b3h ; -
    call vline

    mov si, 19 * 2 + 34 + translation; 
    mov cl, 0bah ; =
    call vline

; corners _________
    mov al, 0c9h ; left upper
    mov di, translation
    call draw_char
    
    mov al, 0c7h ; left middle
    mov di, 160 * 2 + translation
    call draw_char

    mov al, 0c8h ; left bottom
    mov di, 160 * 19 + translation
    call draw_char


    ; right
    mov al, 0bbh ; upper
    mov di, 19 * 2 + 34 + translation
    call draw_char
    
    mov al, 0b6h ; middle
    mov di, 160 * 2 + 19 * 2 + 34 + translation
    call draw_char

    mov al, 0bch ; bottom
    mov di, 160 * 19 + 19 * 2 + 34 + translation
    call draw_char

    ; mid
    mov al, 0d1h ; upper
    mov di, 2 * 2 + translation
    call draw_char
    
    mov al, 0c5h ; middle
    mov di, 160 * 2 + 2 * 2 + translation
    call draw_char

    mov al, 0cfh ; bottom
    mov di, 160 * 19 + 2 * 2 + translation
    call draw_char
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
    cmp switch_symbol, 0 ; switch symbol
    je draw_char

    add al, 30h
    cmp al, 3ah
    jl draw_char
    add al, 7
draw_char:
	mov	ah,	color
	stosw ; ax -> es:di
    ; xor ax, ax
    mov ax, 20h
	ret
draw_table endp



font_size equ 4096

fonts_start label
include labels.asm
fonts_end label

fonts_max equ offset fonts_end
font dw offset fonts_start


end _start