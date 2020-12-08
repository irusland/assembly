.globl	_start
.text
_start:
	mov	$0x1245,	%eax
	xor	%ecx,		%ecx
1:
	btc	%rcx,		%rax
	jc	2f
	inc	%ecx
	jmp	1b
2:
end:
	mov	$60,		%eax
	syscall

