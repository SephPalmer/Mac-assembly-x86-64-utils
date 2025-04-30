#include "core.h"

extern void asm_print_char();

// print to stdout
void print(const char *message)
{
// todo
}

// print a character to stdout
void print_char(char c)
{
    // Call the assembly function to print a character
    asm_print_char(c);
}