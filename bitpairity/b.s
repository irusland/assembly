.data
buff:	.byte 0, 0xa

.text
.globl _start
_start:
	pop	%rax
	pop	%rax
	pop	%rax

	mov 	(%rax),	%bl
	sub	$0x30,	%bl
	xor	%ecx,	%ecx
	xor	%edx,	%edx
	mov	$32,	%ecx
1:
	mov	%ecx,	%eax
	dec	%eax
	bt	%eax,	%ebx
	adc	$0,	%edx
	and	$1,	%edx
	loop	1b

	add	$0x30,	%dl
	mov	%dl,	buff
prt:
	mov	$1,	%rdi	#arg1 stdout
	mov	$buff,	%rsi	#arg2 *buf
	mov	$2,	%rdx	#arg3 count
	mov	$1,	%rax	#print(...)
	syscall
		
end:
	mov	$60,		%eax
	syscall

