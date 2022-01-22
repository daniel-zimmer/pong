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
mov al, ((end - additional_sectors) / 512) ; read n sectors
mov cl, 2 ; sector number
mov ch, 0 ; cylinder number
mov dh, 0 ; head number

mov bx, 0  ; cannot move directly to es
mov es, bx ; segment register
mov bx, 0x7e00 ; where to load sector

mov ah, 2 ; read sector command
int 0x13
;;;;;;;;;;;;;;;;;;;;;;;;;;

call main
jmp $

;;;;;; vars ;;;;;

boot_disk: db 0

;;;;;;; boot sector padding ;;;;;;;

times 510-($-$$) db 0
db 0x55, 0xaa ; boot sector magic number

;;;;;;;;;;;; ADDITIONAL SECTORS ;;;;;;;;;;;;;
additional_sectors:

;; MAIN
main:
	
	loop1:
	mov ah, 0
	int 0x1a
	
	mov ax, dx
	call print_int
	
	mov ah, 0xe
	mov al, 0xa
	int 0x10
	mov al, 0xd
	int 0x10
	
	jmp loop1
	
	;mov ah, 0xe
	;mov al, dh
	;int 0x10
	
	jmp $
	
	call init_vga

loop:

	call clearScreen
	mov cx, [x_pos]
	mov dx, 100
	mov si, 50
	mov di, 50
	mov al, 0xf
	call drawBox

	inc word [x_pos]

	jmp loop

;;;;;; VARS ;;;;;;;

    x_pos: dw 0
       dt: dw 0
last_time: dw 0

;;;;;; FUNCS ;;;;;;

; print int
print_int:
	cmp ax, 0
	je .print_int_end

	mov dx, 0
	mov bx, 10
	div bx

	pusha
	call print_int
	popa

	mov ah, 0xe
	mov al, dl
	add al, '0'
	int 0x10

	jmp .print_int_end_end
	.print_int_end:
		mov ah, 0xe
		mov al, '0'
		int 0x10
	.print_int_end_end:
		ret

; VGA mode
init_vga:
	mov ah, 0
	mov al, 0x13
	int 0x10
	ret

; Draw Box
;cx = xpos , dx = ypos, si = x-length, di = y-length, al = color
drawBox:
	push si               ;save x-length
	.for_x:
		push di           ;save y-length
		.for_y:
			pusha
			mov bh, 0     ;page number (0 is default)
			add cx, si    ;cx = x-coordinate
			add dx, di    ;dx = y-coordinate
			mov ah, 0xC   ;write pixel at coordinate
			int 0x10      ;draw pixel!
			popa
		sub di, 1         ;decrease di by one and set flags
		jnz .for_y        ;repeat for y-length times
		pop di            ;restore di to y-length
	sub si, 1             ;decrease si by one and set flags
	jnz .for_x            ;repeat for x-length times
	pop si                ;restore si to x-length  -> starting state restored
	ret

; Clear Screen
clearScreen:
	mov cx, 0
	mov dx, 0
	mov si, 320
	mov di, 200
	mov al, 0
	call drawBox
	ret

;;;;;;;;;;;; SECTORS PADDING ;;;;;;;;;;;;;;
	times 512 - (($-additional_sectors) % 512) db 0
end:


