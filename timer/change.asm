.model tiny
.code
org 100h
locals @@
vector equ 8	; 8
_start:
jmp	begin
my_int proc near
	db	0eah
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
	xor	ax,	ax
	int	16h

	cmp	ah,	1
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
