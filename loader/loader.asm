.model tiny
.code
org 100h
begin:
	jmp short _start
	nop
operator	db 'MBR.180K'
; BPB
BytesPerSec	dw 200h
SectPerClust	db 1
RsvdSectors	dw 1
NumFATs		db 2
RootEntryCnt	dw 64		; 2 ᥪ�� �� root dir
TotalSectors	dw 360	
MediaByte	db 0FCh		; 1 ������ 9 ᥪ�஢ 40 樫���஢
FATsize		dw 2		; 2 ᥪ�� �� ����� FAT
SecPerTrk	dw 9
NumHeads	dw 1
HidSec		dw 0, 0
TotSec32	dd 0
DrvNum		db 0
Reserved	db 0
Signatura	db ')'		; 29h
; 
Vol_ID		db 'XDRV'
DiskLabel	db 'TestMBRdisk'
FATtype		db 'FAT12   '
;
_start:
    mov ah, 02h ; int 13 02h
    mov al, 18  ; number of sectors to read
    mov ch, 2   ; cylinder/track number 
    mov cl, 1   ; starting sector number
    mov dh, 0   ; head number
    mov dl, 0   ; drive number
    mov bx, 3000h
    mov es, bx  ; address of memory buffer es:bx
    mov bx, 100h
    int 13h ; floppy -> memory

    mov ax, 3000h
    cli ; clear interrupt enable flag
    ; CS register cannot be changed directly. The CS register is automatically updated during far jump, far call and far return instructions.
    mov es, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0
    push sp ; уменьшает указатель стека SP на 2 для 16-битного размера операнда 
            ; 0 - 2 = 0xFFFE
    sti ; set int


db  0eah, 0, 1, 0, 30h  ; jmp far ptr 3000:100  ; sets CS:IP = 3000:100

    mov si, offset d1   ; ds:si
    mov di, 0           ; es:di
    mov cx, 5
    rep movsb

    mov al, 0eah
    stosb
    mov al, 0
    stosb
    mov al, 07ch
    stosb
    mov ax, 0
    stosw

    mov ah, 4ch 
    int 21h

.data
d1  db  0eah, 0, 07ch, 0, 0     ; jmp far ptr 0:7c00
d2  db  0eah, 0, 1, 0, 30h      ; jmp far ptr 3000:100

org	766
dw	0aa55h
end begin