.data
.align 4
_pi:	.long	0


.globl sinus
.text
sinus:
	finit
	fldpi
	fst	_pi
	movss	_pi,	%xmm3

#	x
	cvtsi2ss	%edi,	%xmm0

#	taylor sum
	mov	$0,	%rax
	cvtsi2ss	%rax,	%xmm9

#	n member
	movss	%xmm0,	%xmm1

#	n counter
	xor	%rcx,	%rcx

#	n-1 member (previous)
	movss	%xmm9,	%xmm7

#	sum
for:
#	result in xmm9!!!
	addss	%xmm1,	%xmm9

#	counter++
	inc	%rcx

#	evaluate divisor
	mov	%rcx,	%rax	# rax = n
	add	%rax,	%rax	# rax = 2*n
	inc	%rax		# rax = 2*n+1
	mul	%rcx		# rax = n*(2*n+1)
	add	%rax,	%rax	# rax = 2*n*(2*n+1)
	cvtsi2ss	%rax,	%xmm3

#	-x*x
	movss	%xmm0,	%xmm2
	mulss   %xmm0,  %xmm2
	mov	$0,	%rbx
	cvtsi2ss	%rbx,	%xmm4
	subss	%xmm2,	%xmm4
	movss	%xmm4,	%xmm2

#	member *= -x*x
	mulss	%xmm2,	%xmm1
#	member *= -x*x/(2*n*(2*n+1))
	divss	%xmm3,	%xmm1

#	check if change was a little
	comiss	%xmm1,	%xmm7
	jnz	for

	movss	%xmm9,	%xmm0
	ret
