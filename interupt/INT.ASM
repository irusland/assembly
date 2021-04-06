.model tiny
.code
org 100h
locals @@
vector equ 9	; 8

pushr macro
	push ax
	push bx
	push cx
	push dx
    push SP
    push BP
    push SI
    push DI
endm

popr macro
    pop DI
    pop SI
    pop BP
    pop SP
	pop dx
	pop cx
	pop bx
	pop ax
endm

ccall macro func
	pusha
	call func
	popa
endm


_start:
jmp	begin

buffer	db 6 dup (0)
buflen equ 6
head	dw	offset buffer
tail	dw	offset buffer

old_di dw 0
my_int proc near

	push ax
	push di
	push es
	in al, 60h ; scan from Key board
	; xor bx, bx
	mov di, offset buffer ; addr of buffer
	; mov di, bx
	mov cx, ds
	mov es, cx
	stosb ; -> es:di

	; mov	bx, 0b800h
	; mov	es, bx
	; mov	di, cs:old_di ; screen char position
	; inc di
	; mov ax, ds
    ; mov	ah,	060h
	; stosb ; ax -> es:di	
	; mov cs:old_di, di

	pop	es
	pop di
	in	al, 61h ; al <- port   ввод порта PB
	mov ah, al
	or al, 80h ; установить бит "подтверждение ввода"
	out 61h, al ; port <- al
	xchg ah, al
	out 61h, al
	mov al, 20h
	out 20h, al
	pop ax

	; popr
	iret
	
	; db	0eah
old_addr	dw	0, 0
my_int endp
begin proc near
	mov	si,	4*vector ; vector addr 4 byte si point to 9th vector
	mov	di,	offset old_addr ; 0104
	push	ds		; 6028
	xor	ax,	ax
	mov	ds,	ax		; int table 0000

					; old_addr	<- addr int 9
	movsw			; 6028:0104 <- 0000:0024	; 	ES:DI   <- 	 DS:SI
	movsw			; 6028:0106 <- 0000:0026  
	push	ds
	push	es
	pop	ds	; 6028
	pop	es	; 0000
	mov	di,	4*vector
	mov	ax,	offset my_int ; 0103
	cli
			; int 9 	<- my_int
	stosw 	; 0000:0024	<- 0103	 ES:DI <- AX
	mov	ax,	cs	; 6028
	stosw	; 0000:0026	<- 6028
	sti
@@1:
;	hlt ; TODO HALT FOR SLEEP
	int 9h
	
	; xor bx, bx
	; mov bl, cs:buffer
	; mov si, bx
	mov si, offset buffer
	lodsb ; al <- DS:SI

	; push ax
	push es
	; push di
	mov	bx, 0b800h
	mov	es, bx
	mov	di, 360 ; screen char position
    mov	ah,	060h
    ; mov al, 39h
	stosb ; ax -> es:di	
	; pop di
	pop es
	; pop ax
	
	cmp	al,	1		 ; esc
	
	jnz	@@1
;
	mov	di,	4*vector
	mov	si,	offset old_addr
	cli
	movsw
	movsw
	sti
	pop	es
	ret
begin endp

to_buffer:
	mov	bx,	tail
	inc	bx
	cmp	bx,	offset buffer + buflen
	jnz	@@1
	mov	bx,	offset buffer
@@1:
	cmp	bx,	head
	jz	@@2
	mov	di,	tail
	stosb ; es:di <- al
	mov	tail,	bx
	clc
	ret
@@2:
	stc
	ret

end _start
