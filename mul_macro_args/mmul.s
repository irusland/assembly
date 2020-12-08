.nolist
.macro	mmul	numa	numb
	mov	%\numa,	%rbx
	mov	%\numb,	%rax
	mul	%rbx
.endm


.macro  exit    exit_code=$0
        mov     $60,    %eax
        mov     \exit_code,     %edi
        syscall
.endm


.macro 	prt	reg	
.text
	mov     $format,	%rdi         
	mov     \reg,	%rsi         
        xor     %rax,	%rax
        call    printf    
.data
format:
        .asciz  "%20ld\n"
.text
.endm

.list
