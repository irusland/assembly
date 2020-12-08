.data
msg:    .asciz  "asm"
mmm: .byte 0, 0xa
lmmm = . - mmm
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
    .long   0, 0, 0, 0

.globl  _start
.text
_start:
    mov $1, %ecx    # current state
    mov $msg, %esi  
    mov $char_tab, %rdi
1:
    xor %eax, %eax
    xor %ebx, %ebx
    lodsb
    test %al, %al
    jz 2f
    mov (%rdi, %rax, 1), %bl
    mov %ecx, %edx
    shl $4, %edx    # *16
    mov state_tab(%rdx, %rbx, 4), %ecx
    jmp 1b
2:
    add $48, %cl
    mov %cl, mmm
    mov $mmm, %rsi
    mov $lmmm, %rdi
    mov $1, %edi
    mov $1, %eax
    syscall
    mov $60, %eax
    syscall

