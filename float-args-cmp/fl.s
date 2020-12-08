.data
.align 4
_pi:	.long	0


.globl get_number
.text
get_number:
	finit
	fldpi
	fst	_pi
	movss	_pi,	%xmm3

	cvtsi2ss	%edi,	%xmm0
        cvtsi2ss        %esi,   %xmm1
	sqrtss	%xmm0,	%xmm0
	sqrtss	%xmm3,	%xmm3
for:
	mulss	%xmm3,	%xmm0
	comiss	%xmm1,	%xmm0
	jb	for
	ret
cf:
	mov	$111,	%eax
	cvtsi2ss	%eax,	%xmm0
	ret

