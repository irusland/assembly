.data
.align 4
_pi:	.long	0


.globl get_number
get_number:
	finit
	fldpi
	fst	_pi
	movss	_pi,	%xmm3

	mov	$1,	%eax
	cvtsi2sd	%eax,	%xmm1
	mov	$2,	%ebx
	cvtsi2sd	%ebx,	%xmm2

	comisd	%xmm1, 	%xmm2
	jb cf
	ret
cf:
	mov	$111,	%eax
	cvtsi2ss	%eax,	%xmm0
	ret

