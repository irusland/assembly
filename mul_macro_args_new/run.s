.global main

        .text
main:
        push    %r12         
        push    %r13
        push    %r14
       

        cmp     $3, %rdi            
        jne     error1

        mov     %rsi, %r12           

        mov     16(%r12), %rdi       
        call    atoi                    
        mov     %eax, %r13d            

        mov     8(%r12), %rdi           # argv
        call    atoi                    # x in eax
        mov     %eax, %r14d             # x in r14d

        mov     $1, %eax                # start with answer = 1
        imul    %r14d, %eax
	imul	%r13d,	%eax

gotit:                                
        mov     $answer, %rdi
        movslq  %eax, %rsi
        xor     %rax, %rax
        call    printf
        jmp     done
error1:                                 
        mov     $badArgumentCount, %edi
        call    puts
        jmp     done
error2:                                 # print error message
        mov     $negativeExponent, %edi
        call    puts
done:                                   # restore saved registers
        pop     %r14
        pop     %r13
        pop     %r12
        ret

answer:
        .asciz  "%d\n"
badArgumentCount:
        .asciz  "\n"
negativeExponent:
        .asciz  "\n"
