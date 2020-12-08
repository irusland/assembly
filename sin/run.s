.include "macro.s"
.text
.globl main
main:
	mov	$3,	%rax
	prt	%rax
	mov	$3,	%rax
	mov	$2,	%rbx
	bt	%rbx,	%rax
	jc	1f
	prt	%rax	
	exit
1:
	exit
