.model tiny
.code
.386
org 100h

pushr macro
	push ax
	push bx
	push cx
	push dx
    push SP
    push BP
    push SI
    push DI
endm

popr macro
    pop DI
    pop SI
    pop BP
    pop SP
	pop dx
	pop cx
	pop bx
	pop ax
endm

ccall macro func
	pusha
	call func
	popa
endm

_start:
	cld
	mov	ax, 0b800h
	mov	es, ax
	mov	di, 660 ; screen char position
@@1:
	xor	ah,	ah		; ROM BIOS 00h interrupt
	int	16h			; read charnum -> ah, char -> al

	cmp	al,	1bh		; esc
	je	@return

	mov	di, 660     ; screen char position

    mov dx, ax       ; Set the value we want to print to dx
    ; mov dx, 01b0fh       ; Set the value we want to print to dx
    ccall print_hex    ; Print the hex value

	jmp	@@1

@return:
	ret

;--------------------------------------------------------
print_hex:
;    pusha             ; save the register values to the stack for later

    mov cx,4          ; Start the counter: we want to print 4 characters
                    ; 4 bits per char, so we're printing a total of 16 bits

char_loop:
    dec cx            ; Decrement the counter
    mov ax,dx         ; copy bx into ax so we can mask it for the last chars
    shr dx,4          ; shift bx 4 bits to the right
    and ax,0fh        ; mask ah to get the last 4 bits

    mov bx, offset HEX_OUT   ; set bx to the memory address of our string
    add bx, 2         ; skip the '0x'
    add bx, cx        ; add the current counter to the address

    cmp ax, 0ah        ; Check to see if it's a letter or number
    jl set_letter     ; If it's a number, go straight to setting the value
    add al, 27h   ; If it's a letter, add 7
                    ; Why this magic number? ASCII letters start 17
                    ; characters after decimal numbers. We need to cover that
                    ; distance. If our value is a 'letter' it's already
                    ; over 10, so we need to add 7 more.
    jl set_letter

set_letter:
    add al, 030h      ; For and ASCII number, add 0x30
    mov byte [bx], al  ; Add the value of the byte to the char at bx

    cmp cx, 0          ; check the counter, compare with 0
    je print_hex_done ; if the counter is 0, finish
    jmp char_loop     ; otherwise, loop again

print_hex_done:
    mov bx, offset HEX_OUT   ; print the string pointed to by bx
    ccall print_string

;    popa              ; pop the initial register values back from the stack
    ret               ; return the function

;--------------------------------------------------------
print_string:     ; Push registers onto the stack
;    pusha

string_loop:
    mov al, [bx]    ; Set al to the value at bx
    cmp al, 0       ; Compare the value in al to 0 (check for null terminator)
    jne print_char  ; If it's not null, print the character at al
                  ; Otherwise the string is done, and the function is ending
;    popa            ; Pop all the registers back onto the stack
    ret             ; return execution to where we were

print_char:
    call draw_char        ; Print character
    add bx, 1       ; Shift bx to the next character
    jmp string_loop ; go back to the beginning of our loop

draw_char:
	mov	ah,	070h ; color
	stosw ; ax -> es:di
	ret
;--------------------------------------------------------
.data
; global variables
HEX_OUT: db '0x0000 ',0

end _start