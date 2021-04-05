.model tiny
.code
org 100h
locals @@
vector equ 9	; 8
_start:
jmp	begin
my_int proc near
	mov ah, 08h
	mov al, 33h
	int 23h
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
	xor	ax,	ax
	int	16h		     ; read scan -> ah, ascii -> al
	cmp	ah,	1		 ; esc
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
end _start
