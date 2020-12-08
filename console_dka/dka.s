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
    .long   0, 2, 0, 0
    .long   0, 0, 3, 0
    .long   0, 0, 0, 4
    .long   0, 0, 0, 5
    .long   0, 0, 0, 0

.globl  _start
.text
_start:
        xor     %eax,   %eax    # rax <- 0 (syscall number for 'read')
        xor     %edi,   %edi    # edi <- 0 (stdin file descriptor)
        mov     $msg,   %rsi    # rsi <- address of the buffer.  lea rsi, [rel buffer]
        mov     $lmsg,  %edx    # rdx <- size of the buffer
        syscall                 # execute  read(0, buffer, BUFSIZE)
	
	xor	%edi,	%edi
	xor	%rsi,	%rsi
	xor	%edx,	%edx
	
	mov	$1,     %ecx    # current state
	mov	$msg,	%esi  
   	mov	$char_tab,	%rdi
1:
	xor	%eax,	%eax
	xor	%ebx,	%ebx
	lodsb
	cmp	$0xa,	%al
	je	2f
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
