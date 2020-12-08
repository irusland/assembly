.globl	_start
.text
_start:
	mov	$0x55,	%eax
	xor	%ecx,	%ecx
1:
	bsf	%rax,	%rcx
	btr	%rcx,	%rax
	jc	1b
end:
	mov	$60,	%eax
	syscall

