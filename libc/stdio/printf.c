#include <limits.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

static bool print(const char *data, size_t length) {
    const unsigned char *bytes = (const unsigned char *)data;
    for (size_t i = 0; i < length; i++)
        if (putchar(bytes[i]) == EOF)
            return false;
    return true;
}

int printf(const char *restrict format, ...) {
    va_list parameters;
    va_start(parameters, format);

    int written = 0;

    while (*format != '\0') {
        size_t maxrem = INT_MAX - written;

        if (format[0] != '%' || format[1] == '%') {
            if (format[0] == '%')
                format++;
            size_t amount = 1;
            while (format[amount] && format[amount] != '%')
                amount++;
            if (maxrem < amount) {
                // TODO: Set errno to EOVERFLOW.
                return -1;
            }
            if (!print(format, amount))
                return -1;
            format += amount;
            written += amount;
            continue;
        }

        const char *format_begun_at = format++;

        if (*format == 'c') {
            format++;
            char c = (char)va_arg(parameters, int /* char promotes to int */);
            if (!maxrem) {
                // TODO: Set errno to EOVERFLOW.
                return -1;
            }
            if (!print(&c, sizeof(c)))
                return -1;
            written++;
        } else if (*format == 's') {
            format++;
            const char *str = va_arg(parameters, const char *);
            size_t len = strlen(str);
            if (maxrem < len) {
                // TODO: Set errno to EOVERFLOW.
                return -1;
            }
            if (!print(str, len))
                return -1;
            written += len;
        } else if (*format == 'p') {
            format++;
            // get the pointer from args and cast to uintptr_t
            void *ptr = va_arg(parameters, void *);
            uintptr_t value = (uintptr_t)ptr;

            char buffer[2 + sizeof(uintptr_t) * 2 + 1];
            // buffer must contain "0x" + hex digits + NULL

            buffer[0] = '0';
            buffer[1] = 'x';
            char *hex = &buffer[2];

            for (int i = (sizeof(uintptr_t) * 2) - 1; i >= 0; i--) {
                int nibble = value & 0xF;
                hex[i] = (nibble < 10) ? ('0' + nibble) : ('a' + (nibble - 10));
                value >>= 4;
            }
            // add NUL to the end
            buffer[2 + sizeof(uintptr_t) * 2] = '\0';

            size_t len = strlen(buffer);

            if (maxrem < len) {
                // TODO: Set errno to EOVERFLOW.
                return -1;
            }
            if (!print(buffer, len))
                return -1;
            written += len;

        } else {
            format = format_begun_at;
            size_t len = strlen(format);
            if (maxrem < len) {
                // TODO: Set errno to EOVERFLOW.
                return -1;
            }
            if (!print(format, len))
                return -1;
            written += len;
            format += len;
        }
    }

    va_end(parameters);
    return written;
}
