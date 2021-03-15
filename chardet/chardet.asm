.model tiny
.code
org 100h
_start:
	cld
	mov	ax, 0b800h
	mov	es, ax
	mov	di, 660 ; screen char position
@@1:
	xor	ah,	ah		; ROM BIOS 00h interrupt
	int	16h			; read charnum -> ah, char -> al

	cmp	al,	1bh		; esc
	je	@return

	push ax
    call print_charnum
    pop ax
    call print_char

	call draw_char 		
	jmp	@@1


print_charnum:
    mov bx, 10h

    ret


print_char:

    ret

del_color:
	mov	ah,	007h
	ret

draw_char:
	mov	ah,	070h
	stosw ; ax -> es:di
	ret

clear_char:
	dec di
	dec di
	mov	al,	0
	call del_color
	stosw
	dec di
	dec di
	ret

@return:
	ret

@cls:
	call clear_char
	jmp @@1

@ascii_extend:
	cmp ah,	48h
	je	@up
	cmp ah,	50h
	je	@down
	cmp ah,	4dh
	je	@right
	cmp ah,	4bh
	je	@left
	jmp @@1

@up:
	sub	di,	162
	xor al,	al
	call draw_char
	jmp @@1

@down:
	add	di,	158
	xor al,	al
	call draw_char
	jmp @@1

@right:
	xor al,	al
	call draw_char
	jmp @@1

@left:
	sub	di, 4
	xor al,	al
	call draw_char
	jmp @@1

end _start