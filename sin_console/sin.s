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
.macro exit code=$0
	mov	\code,	%edi
	mov	$60,	%eax
	syscall
.endm

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
	jne	has_arg
	printstr "Write value\n"
	exit

has_arg:	
	pop 	%rsi
	pop	%rsi
	call 	read_arg
	call	convert
	call	sinus
	call	print_sinus
	call	print_count
	
	exit


#------------------------------

read_arg:
	xor	%eax,	%eax
	mov	$10,	%ebx
read_char:
	push	%rax
	xor	%eax,	%eax
	lodsb
	test	%al,	%al
	jz	correct
	cmp	$0x30,	%al
	jb	error
	cmp	$0x39,	%al
	ja	error
	sub	$0x30,	%eax
	mov	%eax,	%ecx
	pop	%rax
	mul	%ebx
	add	%ecx,	%eax
	cmp	$90,	%eax	
	jbe	read_char
error:
	printstr	"Invalid argument\n"
	exit	
	
correct:
	pop	%rax
	ret

#------------------------------

convert:
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

#------------------------------

sinus:

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
for:
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
	jnz	for

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

#	extract fraction
1:
	xor	%rdx,	%rdx
	mov     $10,    %r12
#	% 10 -> dl
	div	%r12
#	num to ascii num char
	add	$48,	%dl
	mov	%dl,	fract(%r11)
	dec	%r11
	jns	1b

#	integer part
	xor	%rdx,	%rdx
	div	%r12
	add	$0x30,	%dl
	mov	%dl,	int


	print	answer, lans
	ret

#------------------------

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

