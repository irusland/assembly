.include "mmul.s"
.globl main
.text
main:
	pop	%rax
	pop	%rax

	pop	%rax 
	xor	%rcx,	%rcx
	movb	(%rax),	%cl
#	mov	(%rax), %rax
	
#	mov	%al,	%cl
#	mov 	$2,	%cl
	prt	%rcx

	mov	(%rax),	%al
#	prt	(%rax)
	pop	%rax
	mov	(%rax),	%bl
#	prt	%rax
	
	mmul	rax	rbx
#	prt	%eax
	exit

