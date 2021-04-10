model	tiny
.code
org	100h
locals
color = 03h
_start:
	mov	ax,	10h
	int	10h
	mov	ax,	1
	int	33h
	mov	ax,	0a000h
	mov	es,	ax

;	mov	di,	10*80+39
	mov	di,	0
	mov	ax,	color
	mov	cx,	640
	mov	dx,	0
@@1:
	push	ax
	push	cx
	mov	ah,	0ch
	mov	cx,	5
	inc	dx
;	add	cx,	dx
	xchg	cx,	dx
	int	10h
	xchg	cx,	dx
	pop	cx
	pop	ax
	inc	al
	loop	@@1

	xor	ax,	ax
	int	16h
	mov	ax,	3
	int	10h
	ret
end _start
