	mov	$3,	%eax
	xor	%edx,	%edx
	xor	%rcx,	%rcx
	bt	%rcx,	%rax
# carry f + edx
	adc	$0,	%edx

