.model tiny
.code
org 100h
locals @@
_start:
	jmp	begin
buffer	db 6 dup (0)
buflen equ 6
head	dw	offset buffer
tail	dw	offset buffer

begin:
	xor	ax,	ax
	int	16h
	call	to_buffer
	jnc	begin
	ret

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
	stosb
	mov	tail,	bx
	clc
	ret
@@2:
	stc
	ret
end	_start
