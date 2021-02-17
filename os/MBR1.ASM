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
	cld
	mov	ax, 0b800h
	mov	es, ax
	mov	di, 660 ; screen char position
@@1:
	xor	ah,	ah		; ROM BIOS 00h interrupt
	int	16h			; read charnum -> ah, char -> al
	mov	ah,	08eh	; ah color
					; al char
	cmp	al,	1bh		; esc
	je	@reboot

	cmp al,	08h		; backspace
	je	@cls

	stosw 			; ax -> es:di
	jmp	@@1
@reboot:
	xor	ah,	ah
	int	19h
	jmp @@1
@cls:
	dec di
	dec di
	mov	al,	0
	stosw
	dec di
	dec di
	jmp @@1
org	766
dw	0aa55h
end begin

; esc -> reload int 19
; color 
; correct chars & nums 
; backspace delete