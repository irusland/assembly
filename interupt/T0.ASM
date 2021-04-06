.model tiny
.data
	HEX_Map   DB  '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
.code
org 100h
locals @@
vector equ 9	; 8
_start:
jmp	begin

buffer	db 6 dup (0)
buflen equ 6
head	dw	offset buffer
tail	dw	offset buffer


my_int proc near
	push 	ax
	push 	di
	push 	es
	xor ax, ax
	
	in 		al, 	60h
	
	;mov es, offset buffer

	mov 	cx, 	ds
	mov 	es, 	cx
	call to_buffer
	;mov 	di, 	offset buffer
	;stosb	
	
	
	
	
	pop 	es
	pop 	di
	in 		al, 	61h
	mov 	ah, 	al
	or 		al, 	80h
	out 	61h, 	al
	xchg 	ah, 	al
	out 	6ah, 	al
	mov 	al, 	20h
	out 	20h, 	al
	pop 	ax
	iret
	
	
	
	;push ax
	;push di
	;push es
	;mov ax, 0b800h
	;mov es, ax
	
	;mov di, 850
	;mov al, 3dh
	;mov ah, 02h
	;stosw
	;pop es
	;pop di
	;pop ax
;skip:
;	db	0eah
old_addr	dw	0, 0
my_int endp
begin proc near
	mov	si,	4*vector
	mov	di,	offset old_addr
	push	ds
	xor	ax,	ax
	mov	ds,	ax
	movsw
	movsw
	push	ds
	push	es
	pop	ds
	pop	es
	mov	di,	4*vector
	mov	ax,	offset my_int
	cli
	stosw
	mov	ax,	cs
	stosw
	sti
@@1:
	sti 
	hlt
	cli
	push di
	push es
	;push si
	;jmp nosc
	call from_buffer
	jc @@1
	push ax
	
	;push ds
	;push si
	;mov bx, 0b800h
	;mov ds, bx
	;mov es, bx
	;mov si, 160
	;mov di, 0
	;mov cx, 160*24
	;xor ax, ax
	;rep movsw
	;pop si
	;pop ds
	call scroll
	
	pop ax
	
	mov bx, 0b800h
	mov di, 160 * 24 + 8
	mov es, bx
	;mov 	di, 	offset buffer
	;lea 	ax, 	buffer
	;lodsb
	mov ah, 02h
	push ax
	;stosw
	call to_HEX
	
	pop ax
	
	cmp al, 0b9h
	jnz nospace
	push ax
	call scroll
	mov al, '-'
	mov bx, 0b800h
	mov di, 160 * 24 + 8
	mov es, bx
	call _print
	call _print
	call _print
	call _print
	pop ax
nospace:
	pop es
	pop di
	cmp al, 1
	jnz @@1
	;jmp @@1
	;jnc @@1
	

restore:	
;
	mov	di,	4*vector
	mov	si,	offset old_addr
	cli
	movsw
	movsw
	sti
	;pop	es
	ret
	
to_buffer:
	mov	bx,	tail
	inc	bx
	cmp	bx,	offset buffer + buflen
	jnz	@@first
	mov	bx,	offset buffer
@@first:
	cmp	bx,	head
	jz	@@second
	mov	di,	tail
	stosb
	mov	tail,	bx
	;clc
	ret
@@second:
	;stc
	ret
	
from_buffer:
	mov bx, head
	cmp bx, offset buffer + buflen
	jnz from_1
	mov bx, offset buffer
from_1:
	cmp bx, tail
	jz from_2
	mov si, head
	lodsb
	inc bx
	mov head, bx
	clc 
	ret
from_2:
	stc
	ret
	
to_HEX:
	mov si, OFFSET HEX_Map        
	xor bx, bx
	push ax
    mov bl, al                      
	xor ax, ax
    shr bx, 4		;high 4 bits
    mov dl, [si+bx] 
	mov al, dl	
	call _print
	
	xor bx, bx
	pop ax
	mov bl, al                      
	xor ax, ax
	and bl, 0Fh		;low 4 bits
	mov dl, [si+bx]
	mov al, dl	
	call _print
	
	ret

_print:
	mov	ah, 02h
	stosw
	ret
	
scroll:
	push ds
	push si
	mov bx, 0b800h
	mov ds, bx
	mov es, bx
	mov si, 160
	mov di, 0
	mov cx, 160*24
	xor ax, ax
	rep movsw
	pop si
	pop ds
	ret
begin endp
end _start
