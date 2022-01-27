#include <stdint.h>

#define VGA_WIDTH 320
#define VGA_HEIGHT 200
#define VGA_ADDR  0xa0000
#define VGA_COLOR_WHITE 0xf
#define VGA_COLOR_BLACK 0x0
#define VGA_SET_COLOR(x, y, color) *(char *)(VGA_ADDR+x+VGA_WIDTH*y) = color

static inline void outb(uint16_t port, uint8_t val) {
	asm volatile ( "outb %0, %1" : : "a"(val), "Nd"(port) );
	/* There's an outb %al, $imm8  encoding, for compile-time constant port numbers that fit in 8b.  (N constraint).
	 * Wider immediate constants would be truncated at assemble-time (e.g. "i" constraint).
	 * The  outb  %al, %dx  encoding is the only option for all other cases.
	 * %1 expands to %dx because  port  is a uint16_t.  %w1 could be used if we had the port number a wider C type */
}

static inline uint8_t inb(uint16_t port) {
	uint8_t ret;
	asm volatile (
		"inb %1, %0"
		: "=a"(ret)
		: "Nd"(port)
	);
	return ret;
}

static inline void io_wait(void) {
	outb(0x80, 0);
}

char kbd_US [128] =
{
	0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',   
  '\t', /* <-- Tab */
  'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',	 
	0, /* <-- control key */
  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',  0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/',   0,
  '*',
	0,  /* Alt */
  ' ',  /* Space bar */
	0,  /* Caps lock */
	0,  /* 59 - F1 key ... > */
	0,   0,   0,   0,   0,   0,   0,   0,
	0,  /* < ... F10 */
	0,  /* 69 - Num lock*/
	0,  /* Scroll Lock */
	0,  /* Home key */
	0,  /* Up Arrow */
	0,  /* Page Up */
  '-',
	0,  /* Left Arrow */
	0,
	0,  /* Right Arrow */
  '+',
	0,  /* 79 - End key*/
	0,  /* Down Arrow */
	0,  /* Page Down */
	0,  /* Insert Key */
	0,  /* Delete Key */
	0,   0,   0,
	0,  /* F11 Key */
	0,  /* F12 Key */
	0,  /* All other keys are undefined */
};

void draw_rect(int x, int y, int width, int height, int color) {
	for (int i = x; i < width+x; i++) {
		for (int j = y; j < height+y; j++) {
			VGA_SET_COLOR(i, j, color);
		}
	}
}

void clear_screen() {
	for (int i = 0; i < VGA_WIDTH; i++) {
		for (int j = 0; j < VGA_HEIGHT; j++) {
			VGA_SET_COLOR(i, j, VGA_COLOR_BLACK);
		}
	}
}

int pos = 0;
long addr = 0xb8000;

void print_char(char c) {
	*(char *)(addr + pos) = c;
	pos+=2;
}

void print_int(int i) {

	if (i == 0) { return; }

	print_int(i/10);
	*(char *)(addr + pos) = i%10 + '0';
	pos+=2;

}


char w_pressed = 0;
char s_pressed = 0;
void main() {

	unsigned char c;
	unsigned char old_c = 0;

//	for (;;) {
//
//		c = inb(0x60);
//
//		if (c != 250 && c != old_c) {
//			print_int(c);
//	
//			print_char(' ');
//
//			old_c = c;
//		}
//	}

//	return;
	int x = 0;
	int y = 0;
	for (;;) {

		for (int i = 0; i < 100000; i++) {
			io_wait();
		}

		if ( kbd_US[inb(0x60)] == 'w' ) {
			y--;
		}
		if ( kbd_US[inb(0x60)] == 's' ) {
			y++;
		}
		if ( kbd_US[inb(0x60)] == 'a' ) {
			x--;
		}
		if ( kbd_US[inb(0x60)] == 'd' ) {
			x++;
		}

		clear_screen();
		draw_rect(x, y, 100, 100, VGA_COLOR_WHITE);
	}

	return;
}

