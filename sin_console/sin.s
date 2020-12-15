.data
answer:	.ascii "sin(x)\t"
int:	.ascii "0."
fract:	.ascii "000000000\n"
lans = . - answer
cnt_answer:	.ascii "cycles\t"
cnt:	.ascii "    \n"
lcnt = . - cnt_answer	

.align 4
_pi:	.long	0

.nolist

.macro print straddr strlen
	mov	$1,	%rax
	mov	%rax,	%rdi
	mov	$\straddr,	%rsi
	mov	$\strlen,	%rdx
	syscall
.endm

.macro printstr str
.data
99:	.ascii "\str"
len = . - 99b
.text
	print 99b len
.endm
.list


.text
.globl _start
_start:
	pop	%rbx
	cmp	$1,	%ebx
	jne	1f
	printstr "Input x\n"
	jmp	exit

1:	
	pop 	%rax
	pop	%rax
	call 	read_arg
	call	to_radians
	call	sin		# %xmm0 = sin(x)	cycles = %r10
	call	print_sinus
	call	print_count

exit:
	mov     $0,  %edi
	mov     $60,    %eax
	syscall


#------------------------------

read_arg:
	mov	%rax,	%rsi
	xor	%eax,	%eax
	mov	$10,	%ebx
read_char:
	push	%rax
	xor	%eax,	%eax
	lodsb
	test	%al,	%al
	jz	correct
	cmp	$0x30,	%al
	jb	1f
	cmp	$0x39,	%al
	ja	1f
	sub	$0x30,	%eax
	mov	%eax,	%ecx
	pop	%rax
	mul	%ebx
	add	%ecx,	%eax
	cmp	$91,	%eax	
	jb	read_char
1:
	printstr	"x in [0, 90]\n"
	jmp	exit
	
correct:
	pop	%rax
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


print_sinus:
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
	mov	%dl,	fract(%r11)
	dec	%r11
	jns	1b

#	extract integer
	call	get_digit	
	mov	%dl,	int

	print	answer, lans
	ret


#	last digit of rax -> dl
get_digit:
        mov     $10,    %r12
	xor     %rdx,   %rdx
	div     %r12
	add     $0x30,  %dl
	ret


#	integer print from lectures
print_count:
	mov	%r10,	%rax
	mov	$cnt,	%rdi
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
	print 	cnt_answer, lcnt
	ret

