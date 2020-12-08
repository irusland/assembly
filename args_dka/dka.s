.data
msg:	.byte 0,48,49,50,51,52,53,50,50,50,0,0,0,0,0,0,0,0,0,0,0
lmsg	= . - msg
mmm:	.byte 0, 0xa
lmmm	= . - mmm
.align 4
char_tab: 
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,1,0,0,0,0,0,0,0,0,0,0,0,3,0,0
    .byte   0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

state_tab:
    .long   0, 0, 0, 0
    .long   0, 0, 0, 2
    .long   0, 3, 0, 0
    .long   0, 0, 4, 0
    .long   0, 0, 0, 5
    .long   0, 0, 0, 0

.globl  _start
.text
_start:
	pop	%r12
	pop	%r12
	pop	%r12
	mov	%r12,	%rsi
	
	mov	$1,     %ecx    # current state
	#mov	$msg,	%esi  
   	mov	$char_tab,	%rdi
1:
	xor	%eax,	%eax
	xor	%ebx,	%ebx
	lodsb
	test	%al,	%al
	jz	2f
	mov	(%rdi,	%rax,	1),	%bl
	mov	%ecx,	%edx
	shl	$4,	%edx	# *16
	mov	state_tab(%rdx,	%rbx,	4),	%ecx
	jmp	1b
2:
    	add 	$0x30,	%cl
	mov	%cl,	mmm

	mov	$mmm,	%rsi
	mov	$lmmm,	%edx
	mov	$1,	%edi
	mov	$1,	%eax
	syscall

	mov	$60,	%eax
	syscall
