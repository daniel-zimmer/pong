[org 0x7c00]
bits 16

PROGRAM_LOCATION equ 0x1000

mov [BOOT_DISK], dl ; drive number starts stored in DL

; setting up segments
xor ax, ax ; ax = 0
mov ds, ax
mov es, ax
mov sp, 0x8000 ; stack grows downwards from 0x7C00
mov bp, sp

; loading another sector from disk
mov al, 10 ; read n sectors
mov cl, 2 ; sector number
mov ch, 0 ; cylinder number
mov dh, 0 ; head number

mov bx, PROGRAM_LOCATION ; where to load sector

mov ah, 2 ; read sector command
int 0x13
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; mode
mov ah, 0x0
mov al, 0x13
int 0x10

;;;;;;;;;;;;;;;;;;;;

CODE_SEG equ GDT_code - GDT_start
DATA_SEG equ GDT_data - GDT_start

cli
lgdt [GDT_descriptor]
mov eax, cr0
or eax, 1
mov cr0, eax
jmp CODE_SEG:start_protected_mode

jmp $

GDT_start:
	GDT_null:
		dd 0x0
		dd 0x0

	GDT_code:
		dw 0xffff
		dw 0x0
		db 0x0
		db 0b10011010
		db 0b11001111
		db 0x0

	GDT_data:
		dw 0xffff
		dw 0x0
		db 0x0
		db 0b10010010
		db 0b11001111
		db 0x0

GDT_end:

GDT_descriptor:
	dw GDT_end - GDT_start - 1
	dd GDT_start


[bits 32]
start_protected_mode:
	mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov ebp, 0x90000		; 32 bit stack base pointer
	mov esp, ebp

	jmp PROGRAM_LOCATION

;;;;;; vars ;;;;;

BOOT_DISK: db 0

;;;;;;; boot sector padding ;;;;;;;

times 510-($-$$) db 0
db 0x55, 0xaa ; boot sector magic number

