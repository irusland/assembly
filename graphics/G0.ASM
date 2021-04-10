model	tiny
.code
org	100h
locals
_start:
	mov	ax,	4
	int	10h

	mov	ax,	1
	int	33h

	xor	ax,	ax
	int	16h
	mov	ax,	3
	int	16h
	ret
end _start
