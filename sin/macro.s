.list
.macro  mmul    numa    numb
        mov     %\numa, %rbx
        mov     %\numb, %rax
        mul     %rbx
.endm


.macro  exit    exit_code=$0
        mov     $60,    %eax
        mov     \exit_code,     %edi
        syscall
.endm


.macro  prt     reg
.text
        mov     $999f,        %rdi
        mov     \reg,   %rsi
        xor     %rax,   %rax
        call    printf
.data
999:
        .asciz  "%20ld\n"
.text
.endm

.list

