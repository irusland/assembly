.model tiny
.code
org 100h
locals @@
key_vector equ 9
timer_vector equ 8

pushr macro
	push ax
	push bx
	push cx
	push dx
    push SP
    push BP
    push SI
    push DI
	push es
endm

popr macro
	pop es
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


screen_width equ 160
screen_vertical_mid equ 12
screen_horizontal_mid equ screen_width / 2
screen_height equ 24

ticks	dw	0
max_ticks dw 3

frame_start label near
frames db '|/-\'
frame_end label	near            ;метка конца кода
frame_count  equ     offset frame_end - offset frame_start
frame_current dw 0
; --------------------------------

key_int proc near
	push ax
	push di
	push es

	mov cx, ds
	mov es, cx ; ВОТ В ЧЕМ БЫЛА ПРОБЛЕМА es 0000 а ds 6028

	mov di, offset buffer; addr of buffer

	in al, 60h ; scan from Key board
	cmp al, 1
	jne skip
	mov al, 2 ; 2nd command
	call to_buffer
skip:
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
key_int_old_addr	dw	0, 0
key_int endp
; --------------------------------

timer_int proc near
	push ax
	push es

	mov cx, ds
	mov es, cx ; ВОТ В ЧЕМ БЫЛА ПРОБЛЕМА es 0000 а ds 6028

	mov bx, ticks
	inc bx
	cmp bx, max_ticks
	jnz @@1
	mov ax, 1
    call to_buffer ; al -> 
	mov bx, 0
@@1:
	mov ticks, bx

; interupt accept!!!
	mov al, 20h
	out 20h, al
	pop es
	pop ax
	iret
	; db	0eah		
timer_int_old_addr	dw	0, 0
timer_int endp
; --------------------------------


begin proc near
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    ; intercept      ; INTERCEPT VECTOR
	; INT TIMER
	push	ds		; 6028

	mov	si,	4*timer_vector ; vector addr 4 byte si point to 9th vector
	mov	di,	offset timer_int_old_addr ; 0104
	xor	ax,	ax
	mov	ds,	ax		; int table 0000

					; old_addr	<- addr int 9
	movsw			; 6028:0104 <- 0000:0024	; 	ES:DI   <- 	 DS:SI
	movsw			; 6028:0106 <- 0000:0026  
	push	ds
	push	es
	pop	ds	; 6028
	pop	es	; 0000
	mov	di,	4*timer_vector
	mov	ax,	offset timer_int ; 0103
	cli
			; int 9 	<- my_int
	stosw 	; 0000:0024	<- 0103	 ES:DI <- AX
	mov	ax,	cs	; 6028
	stosw	; 0000:0026	<- 6028
	sti

	pop es
	push	es		; 6028
;	INT KEY
	mov	si,	4*key_vector ; vector addr 4 byte si point to 9th vector
	mov	di,	offset key_int_old_addr ; 0104
	xor	ax,	ax
	mov	ds,	ax		; int table 0000

					; old_addr	<- addr int 9
	movsw			; 6028:0104 <- 0000:0024	; 	ES:DI   <- 	 DS:SI
	movsw			; 6028:0106 <- 0000:0026  
	push	ds
	push	es
	pop	ds	; 6028
	pop	es	; 0000
	mov	di,	4*key_vector
	mov	ax,	offset key_int ; 0103
	cli
			; int 9 	<- my_int
	stosw 	; 0000:0024	<- 0103	 ES:DI <- AX
	mov	ax,	cs	; 6028
	stosw	; 0000:0026	<- 6028
	sti

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; перевести видеоподсистему в режим №1
; mov ah, 00h
; mov al, 1
; int 10h
; ; убрать курсор
; mov ah, 01h
; mov ch, 06h
; mov cl, 07h
; int 10h
;

push es
@@1:
	hlt ; TODO HALT FOR SLEEP
    ; exits if interrupt occurs
	; int 08h

    call from_buffer ; al <- if carry
    jnc @@1   ; jump carry flag CF == 0
	clc

	cmp	al,	1		 ; command 1
	jz @@c1
	cmp	al,	2		 ; command 1
	jz @@c2
	jmp @@1
@@c1:
	mov bx, frame_current
	inc bx
	cmp bx, frame_count
	jnz @@f
	mov bx, 0
@@f:
	mov frame_current, bx
	
	mov ax, bx
	add ax, 30h
	
	mov	bx, 0b800h
	mov	es, bx
	mov	di, screen_width * screen_vertical_mid + screen_horizontal_mid ; screen char position
	mov ah, 070h
	stosw ; ax -> es:di	
	jmp @@1

@@c2:
	

	pop es
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ; revert     ; REVER INTERCEPT VECTOR
	; INT TIMER
	mov	di,	4*timer_vector
	mov	si,	offset timer_int_old_addr
	cli
	movsw ; 	ES:DI   <- 	 DS:SI
	movsw
	sti
	; INT KEYBOARD
	mov	di,	4*key_vector
	mov	si,	offset key_int_old_addr
	cli
	movsw ; 	ES:DI   <- 	 DS:SI
	movsw
	sti

	pop	es
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; cls
	; mov ah, 00h
	; mov al, 3
	; int 10h

    ret
begin endp
; --------------------------------


intercept macro
	mov	si,	4*timer_vector ; vector addr 4 byte si point to 9th vector
	mov	di,	offset timer_int_old_addr ; 0104
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
	mov	di,	4*timer_vector
	mov	ax,	offset timer_int ; 0103
	cli
			; int 9 	<- my_int
	stosw 	; 0000:0024	<- 0103	 ES:DI <- AX
	mov	ax,	cs	; 6028
	stosw	; 0000:0026	<- 6028
	sti
endm
; --------------------------------

revert macro
	mov	di,	4*timer_vector
	mov	si,	offset timer_int_old_addr
	cli
	movsw ; 	ES:DI   <- 	 DS:SI
	movsw
	sti
	pop	es
endm


to_buffer proc near ; al -> buffer[tail+1]
	mov	bx,	tail
	inc	bx          ; bx is next
	cmp	bx,	offset buffer + buflen
	jnz	@@1
	mov	bx,	offset buffer

@@1:
	cmp	bx,	head 
	jz	@@2         ; next is head => FULL
	mov	di,	tail
	stosb           ; es:di <- al
	mov	tail,	bx  ; tail += 1 mod buflen
	stc             ; set carry
	ret         ; ADDED

@@2:            ; FULL was not added
	clc             ; clear carry
	ret
to_buffer endp
; --------------------------------

from_buffer proc near ; buffer[head] -> al
	mov	bx,	head
	mov dx, tail
    cmp bx, dx
    jz @@empty 

	inc bx
	cmp	bx,	offset buffer + buflen
	jnz	@@has_new
	mov	bx,	offset buffer

@@has_new:
	mov	si,	head
    lodsb       ; al <- ds:si
	mov	head,	bx  ; tail += 1 mod buflen
    stc
    ret
@@empty:
    clc
	ret

from_buffer endp
; --------------------------------

end _start
