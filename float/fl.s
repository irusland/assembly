.data
.align 4
_pi:	.long	0


.globl get_number
.text
get_number:
	finit
	fldpi
	fst	_pi
#
	movss	_pi,	%xmm0

	mov	$1,	%eax
#	movss	%eax,	%xmm1
	cvtsi2ss	%eax,	%xmm2
#	cvtsi2sd	%xmm1,	%xmm3
	cvtss2sd        %xmm2,  %xmm4
#ret 1	movss	%xmm2,	%xmm0
#sqr pi	sqrtss	%xmm0,	%xmm0

	ret

