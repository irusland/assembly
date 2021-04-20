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
	push ds
endm

popr macro
	pop ds
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


screen_width equ 40 * 2
screen_horizontal_mid equ screen_width / 2
screen_height equ 25 
screen_vertical_mid equ screen_height / 2

position dw screen_width * screen_vertical_mid + screen_horizontal_mid - 2

ticks	dw	0
max_ticks dw 3

propeller_frame_start label near
; propeller_frames db '|/-\'
; propeller_frames db 186, 201, 205, 187
; propeller_frames db '.', 'o', 'O', '@', '*'
; propeller_frames db 'p', 'd', 'b', 'o'
; propeller_frames db '|[/-\]'
; propeller_frames db '|[{(COo.oOD)}]'
propeller_frames db '|[{(|)}]'

propeller_frame_end label	near            ;метка конца кода
propeller_frame_count  equ     offset propeller_frame_end - offset propeller_frame_start
propeller_frame_current dw 0

cmd_vectors	dw 0h
			dw offset timer_tick
			dw 0h
			dw offset speed
			dw offset speed
			dw offset speed
			dw offset speed
			dw offset change_direction
			dw offset change_direction
			dw offset change_direction
			dw offset change_direction
			dw offset change_direction

; --------------------------------
direction db 0
under dw 0
change_direction proc
	sub al, 7
	mov direction, al
	ret
change_direction endp

key_int proc near
	push ax
	push di
	push es

	mov cx, ds
	mov es, cx ; ВОТ В ЧЕМ БЫЛА ПРОБЛЕМА es 0000 а ds 6028

	mov di, offset buffer; addr of buffer

	in al, 60h ; scan from Key board
	cmp al, 1
	je @@esc

	xor cl, cl
	cmp al, 0bh
	je @@key0
	cmp al, 02h
	je @@key1
	cmp al, 03h
	je @@key2
	cmp al, 04h
	je @@key3
	cmp al, 39h
	je @@key_space
	cmp al, 4bh
	je @@key_left
	cmp al, 4d
	je @@key_right

	jmp skip

@@key3:
	inc cl
@@key2:
	inc cl
@@key1:
	inc cl
@@key0:
	add cl, 3 ; base cmd
	mov al, cl
	call to_buffer
	jmp skip

@@key_space:
	mov al, 7
	call to_buffer
	jmp skip
@@key_left:
	mov al, 8
	call to_buffer
	jmp skip
@@key_right:
	mov al, 9
	call to_buffer
	jmp skip

@@esc:
	mov al, 0 ; 2nd command
	call to_buffer
	jmp skip

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
	jb @@1
	ja @@reset
	mov ax, 1
    call to_buffer ; al -> 
@@reset:
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
mov ah, 00h
mov al, 1
int 10h
; ; убрать курсор
mov ah, 01h
mov ch, 01h
mov cl, 00h
int 10h
;

push es
@@1:
	hlt ; TODO HALT FOR SLEEP
    ; exits if interrupt occurs
	; int 08h

    call from_buffer ; al <- if carry
	; 0 - exit
	; 1 - timer
	; 2 - 
	; 3 - speed 0
	; 4 - 1
	; 5 - 2
	; 6 - 3
	; 7 - stop
	; 8 - left
	; 9 - right
	; 10 - up
	; 11 - down


    jnc @@1   ; jump carry flag CF == 0
	clc

	cmp al, 0
	jz @@exit
	
; cmd table
	xor bx, bx
    mov bl, al
    shl bx, 1 ; *2 dw 
    ccall cmd_vectors[bx]
	jmp @@1

; ------------------------

speed:
	sub	al,	3
	xor	ah, ah
	mov max_ticks,	ax
	ret
; ------------------------
@@exit:
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
	mov ah, 00h
	mov al, 3
	int 10h

    ret
begin endp
; --------------------------------

timer_tick proc near
	; push ds

	mov	bx, 0b800h
	mov	es, bx
	; mov ds, bx

	mov bx, propeller_frame_current
	inc bx
	cmp bx, propeller_frame_count
	jnz @@f

	mov bx, 0
	mov dl, direction
	cmp dl, 0
	jz @@f
	cmp dl, 1
	jz @@left
	cmp dl, 2
	jz @@right
	cmp dl, 3
	jz @@up
	cmp dl, 4
	jz @@down

@@left:
	; mov ax, under
	; mov di, position
	; stosw

	; mov si, position - 2 ; new position
	; lodsw
	; mov under, ax

	; mov position, si
	jmp @@f

@@right:
	; mov ax, under
	; mov di, position
	; stosw

	; mov si, position + 2 ; new possition
	; lodsw
	; mov under, ax

	; mov position, si
	jmp @@f

@@up:
	jmp @@f

@@down:
	jmp @@f

@@f:
	mov propeller_frame_current, bx
	mov al, propeller_frames[bx]

	mov	di, position ; screen char position

	mov ah, 070h
	stosw ; ax -> es:di	

	; pop ds
	ret
timer_tick endp


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
