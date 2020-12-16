.data
no_x:	.ascii	"ArgumentNullException", "\n"
lno_x = . - no_x

x_in:	.ascii	"ArgumentOutOfRangeException", "\n"
lx_in = . - x_in

ssin:	.ascii	"sin(x)", "\t"
ssin_h:	.ascii	"0", ","
ssin_l:	.ascii	"000000000", "\n"
lssin = . - ssin

scyc:	.ascii "cycles", "\t"
scycc:	.ascii "      ", "\n"
lscyc = . - scyc

.align 4
_pi:	.long	0




.text
.globl _start
_start:
#	argument validation
	pop	%rax

#	check if exists
	cmp	$1,	%rax
	jne	1f

#	print error info
        mov	$no_x,	%rsi
	mov	$lno_x,	%rdx
	call	print
	jmp	exit

1:
#	get argument to parse
	pop 	%rax
	pop	%rax

#	calculations
	call 	parse		# stdin -> %eax degrees
	call	to_radians	# %eax degrees -> %xmm0 radians
	call	sin		# %xmm0 = sin(x); cycles = %r10

#	final output
	call	sin_print
	call	cycles
	jmp	exit


parse:
#	argument -> %rsi
	mov	%rax,	%rsi
	xor	%eax,	%eax
	mov	$10,	%ebx
step:
#	save x in %rdx
	mov	%rax,	%rdx
	xor	%eax,	%eax

#	load char on %rsi
	lodsb

#	check 0
	cmp	$0,	%al
	je	2f

#	[0...9]
	cmp	$0x30,	%al
	jb	1f
	cmp	$0x39,	%al
	ja	1f
	sub	$0x30,	%eax
	mov	%eax,	%ecx

	mov	%rdx,	%rax

#	* 10
	mul	%ebx
#	+ n
	add	%ecx,	%eax

	cmp	$91,	%eax
	jb	step
1:
#	print out of range exception
	mov	$x_in,	%rsi
	mov	$lx_in,	%rdx
	call	print
	jmp	exit
	
2:
#	x -> %rax
	mov	%rdx,	%rax
	ret


#	%eax degrees -> %xmm0 radians
to_radians:
	finit
	fldpi
	fst	_pi	
	movss	_pi,	%xmm1
	cvtsi2ss %eax,	%xmm0
	mov	$180,	%eax
	cvtsi2ss %eax,	%xmm2
	mulss	%xmm1,	%xmm0
	divss	%xmm2,	%xmm0
	ret


sin:

#	taylor sum
	mov	$0,	%rax
	cvtsi2ss	%rax,	%xmm9

#	n member
	movss	%xmm0,	%xmm1

#	n counter
	xor	%r10,	%r10

#	n-1 member (previous)
	movss	%xmm9,	%xmm7

#	sum as recurrence relation
1:
#	result in xmm9!!!
	addss	%xmm1,	%xmm9

#	counter++
	inc	%r10

#	evaluate divisor
	mov	%r10,	%rax	# rax = n
	add	%rax,	%rax	# rax = 2*n
	inc	%rax		# rax = 2*n+1
	mul	%r10		# rax = n*(2*n+1)
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
	movss   %xmm1,  %xmm7
	jnz	1b

	movss	%xmm9,	%xmm0
	ret


sin_print:
#	precision 9 digits
	mov	$1000000000,	%rax
	cvtsi2ss %rax,	%xmm1
	mulss	%xmm1,	%xmm0
#	round
	cvtss2si %xmm0,	%rax
#	digit counter
	mov	$8,	%r11

1:
#	extract fraction
	call	get_digit
	mov	%dl,	ssin_l(%r11)
#	next digit
	dec	%r11
	jns	1b

#	extract integer
	call	get_digit	
	mov	%dl,	ssin_h

	mov	$ssin,	%rsi
	mov	$lssin,	%rdx
	call	print
	ret


#	last digit of rax -> dl
get_digit:
        mov     $10,    %r12
	xor     %rdx,   %rdx
	div     %r12
	add     $0x30,  %dl
	ret


#	integer print from lectures
cycles:
	mov	%r10,	%rax
	mov	$scycc,	%rdi
	xor	%rcx,	%rcx	
1:
	xor	%rdx,	%rdx
	div	%r12
	push	%rdx
	inc	%ecx
	test	%rax,	%rax
	jnz	1b
2:
	pop	%rax
	add	$0x30,	%al
	stosb
	dec	%ecx
	jnz	2b
	mov	$scyc,	%rsi
	mov	$lscyc,	%rdx
	call	print
	ret


exit:
	mov     $0,     %edi
	mov     $60,    %eax
	syscall

print:
	mov     $1,    %rax
	mov     $1,     %rdi
	syscall
	ret
