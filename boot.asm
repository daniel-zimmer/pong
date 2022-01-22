[org 0x7c00]
bits 16

mov [boot_disk], dl ; drive number starts stored in DL

; setting up segments
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax     ; setup stack
mov sp, 0x7c00 ; stack grows downwards from 0x7C00
mov bp, sp

; loading another sector from disk
mov al, 1 ; read 1 sector
mov cl, 2 ; sector number
mov ch, 0 ; cylinder number
mov dh, 0 ; head number

mov bx, 0  ; cannot move directly to es
mov es, bx ; segment register
mov bx, 0x7e00 ; where to load sector

mov ah, 2 ; read sector command
int 0x13
;;;;;;;;;;;;;;;;;;;;;;;;;;

;mov bx, string
;call print_string

mov ah, 0
mov al, 0x13
int 0x10

;mov ax, 0xA000
;mov es, ax

mov ax, 0

loop:

	cmp ax, 1000
	je end

	;mov byte [eax], 0x77

	mov bh, 0 ; page 0
	mov cx, 100 ; x
	mov dx, 100 ; y
	mov al, 0xf ; index of color

	mov ah, 0xc
	int 0x10

	inc ax
	jmp loop

end:
	jmp $

;;;;;;

boot_disk: db 0

;;;;;;;

times 510-($-$$) db 0
db 0x55, 0xaa ; boot sector magic number

; SECTOR 2
sector_2:
	string: db "Hello, World!", 0xA, 0xD, 0

	print_string:

		mov ah, 0xe

		print_string_loop:
			mov al, [bx] 
			cmp al, 0
			je print_string_end

			int 0x10
			
			inc word bx

			jmp print_string_loop

		print_string_end:
			ret

	times 512-($-sector_2) db 0

