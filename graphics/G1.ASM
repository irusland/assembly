model	tiny
.code
org	100h
locals
color = 05555h
_start:
	mov	ax,	4h
	int	10h
	mov	ax,	1
	int	33h
	mov	ax,	0b800h
	mov	es,	ax

	mov	di,	10*80+39
	mov	ax,	color
	stosw
	add	di,	78
	stosw
	add	di,	78
	stosw
	add	di,	78
	stosw
	mov	di,	2000h+10*80+39
	stosw
	add	di,	78
	stosw
	add	di,	78
	stosw
	add	di,	78
	stosw
	xor	ax,	ax
	int	16h
	mov	ax,	3
	int	10h
	ret
end _start
