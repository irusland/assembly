model	tiny
.code
org	100h
locals
color = 0ffffh
_start:
	mov	ax,	10h
	int	10h
	mov	ax,	1
	int	33h
	mov	ax,	0a000h
	mov	es,	ax

;	mov	di,	10*80+39
	mov	di,	2000h
	mov	ax,	color
	mov	cx,	40
	rep	stosw
;	add	di,	78
;	stosw
;	add	di,	78
;	stosw
;	add	di,	78
;	stosw
;	mov	di,	2000h+10*80+39
;	stosw
;	add	di,	78
;	stosw
;	add	di,	78
;	stosw
;	add	di,	78
;	stosw
	xor	ax,	ax
	int	16h
	mov	ax,	3
	int	10h
	ret
end _start
