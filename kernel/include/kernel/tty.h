#ifndef _KERNEL_TTY_H
#define _KERNEL_TTY_H

#include <stddef.h>
#include <stdint.h>

#define TERMINAL_WIDTH = 80;
#define TERMINAL_HEIGHT = 25;

void terminal_initialize(void);
void terminal_fill_lines(uint8_t start, uint8_t end, uint8_t col);

void terminal_setcursor(int x, int y);
void terminal_setcolor(uint8_t col);
void terminal_putentryat(unsigned char c, uint8_t color, size_t x, size_t y);
void terminal_putchar(char c);

void terminal_write(const char *data, size_t size);
void terminal_writestring(const char *data);
void update_cursor(int x, int y);

#endif
