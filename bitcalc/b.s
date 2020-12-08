.globl	_start
.text
_start:
	mov	$0x1245,	%eax
	mov	$0x1111,	%ebx
	xor	%rdx,		%rdx
	mov	$63,		%ecx
1:
        shl     $1,             %rdx
	bt	%rcx,		%rax
	jnc	2f
	inc	%rdx
2:
	bt	%rcx,		%rbx
	jnc	3f
	inc	%rdx
3:
	dec	%ecx
	jns	1b
end:
	mov	$60,		%eax
	syscall

