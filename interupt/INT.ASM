.model tiny
.code
org 100h
locals @@
vector equ 9	; 8

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
	pushr
	call func
	popr
endm


_start:
jmp	begin

buffer	db 6 dup (0)
buflen equ 6
head	dw	offset buffer
tail	dw	offset buffer

old_di dw 0
my_int proc near

	push ax
	push di
	push es
	in al, 60h ; scan from Key board
	mov di, offset buffer ; addr of buffer
	mov cx, ds
	mov es, cx ; ВОТ В ЧЕМ БЫЛА ПРОБЛЕМА es 0000 а ds 6028
	stosb ; -> es:di

	pop	es
	pop di
	in	al, 61h ; al <- port   ввод порта PB
	mov ah, al
	or al, 80h ; установить бит "подтверждение ввода"
	out 61h, al ; port <- al
	xchg ah, al
	out 61h, al
	mov al, 20h
	out 20h, al
	pop ax

	iret
	
	; db	0eah
old_addr	dw	0, 0
my_int endp
begin proc near
	mov	si,	4*vector ; vector addr 4 byte si point to 9th vector
	mov	di,	offset old_addr ; 0104
	push	ds		; 6028
	xor	ax,	ax
	mov	ds,	ax		; int table 0000

					; old_addr	<- addr int 9
	movsw			; 6028:0104 <- 0000:0024	; 	ES:DI   <- 	 DS:SI
	movsw			; 6028:0106 <- 0000:0026  
	push	ds
	push	es
	pop	ds	; 6028
	pop	es	; 0000
	mov	di,	4*vector
	mov	ax,	offset my_int ; 0103
	cli
			; int 9 	<- my_int
	stosw 	; 0000:0024	<- 0103	 ES:DI <- AX
	mov	ax,	cs	; 6028
	stosw	; 0000:0026	<- 6028
	sti
@@1:
	hlt ; TODO HALT FOR SLEEP
	; int 9h
	
	
	mov si, offset buffer
	lodsb ; al <- DS:SI

	push es
	mov	bx, 0b800h
	mov	es, bx
	mov	di, 720 ; screen char position
    mov	ah,	060h
    ; mov al, 39h
	stosw ; ax -> es:di	
	mov dx, ax
	ccall to_hex
	ccall print_hex

	pop es
	
	cmp	al,	1		 ; esc
	
	jnz	@@1
;
	mov	di,	4*vector
	mov	si,	offset old_addr
	cli
	movsw
	movsw
	sti
	pop	es
	ret
begin endp

; todo buffer
to_buffer:
	mov	bx,	tail
	inc	bx
	cmp	bx,	offset buffer + buflen
	jnz	@@1
	mov	bx,	offset buffer
@@1:
	cmp	bx,	head
	jz	@@2
	mov	di,	tail
	stosb ; es:di <- al
	mov	tail,	bx
	clc
	ret
@@2:
	stc
	ret


;--------------------------------------------------------
to_hex:
;    pushr             ; save the register values to the stack for later

    mov cx,4          ; Start the counter: we want to print 4 characters
                    ; 4 bits per char, so we're printing a total of 16 bits

char_loop:
    dec cx            ; Decrement the counter
    mov ax,dx         ; copy bx into ax so we can mask it for the last chars
    shr dx,4          ; shift bx 4 bits to the right
    and ax,0fh        ; mask ah to get the last 4 bits

    mov bx, offset HEX_OUT   ; set bx to the memory address of our string
    
    add bx, 1         ; skip the '> '
    cmp cx, 2
    jae skip
continue:

    add bx, cx        ; add the current counter to the address

    cmp ax, 0ah        ; Check to see if it's a letter or number
    jl set_letter     ; If it's a number, go straight to setting the value
    add al, 27h
    jmp set_letter

skip:
    add bx, 1
    jmp continue


set_letter:
    add al, 030h      ; For and ASCII number, add 0x30
    mov byte [bx], al  ;  the value of the byte to the char at bx

    cmp cx, 0          ; check the counter, compare with 0
    je print_hex_done ; if the counter is 0, finish
    jmp char_loop     ; otherwise, loop again

print_hex_done:
    ret               ; return the function

;--------------------------------------------------------
print_hex:     ; Push registers onto the stack
    mov bx, offset HEX_OUT   ; print the string pointed to by bx

string_loop:
    mov al, [bx]    ; Set al to the value at bx
    cmp al, 0       ; Compare the value in al to 0 (check for null terminator)
    jne print_char  ; If it's not null, print the character at al
                  ; Otherwise the string is done, and the function is ending
    ;popr            ; Pop all the registers back onto the stack
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
HEX_OUT: db '> __ __ =',0

end _start
