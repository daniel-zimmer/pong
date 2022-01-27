#define VGA_WIDTH 320
#define VGA_HEIGHT 200
#define VGA_ADDR  0xa0000
#define VGA_COLOR_WHITE 0xf
#define VGA_SET_COLOR(x, y, color) *(char *)(VGA_ADDR+x+VGA_WIDTH*y) = color

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
			VGA_SET_COLOR(i, j, VGA_COLOR_WHITE);
		}
	}
}

void main() {

	draw_rect(100, 100, 100, 100, VGA_COLOR_WHITE);

	return;
}

