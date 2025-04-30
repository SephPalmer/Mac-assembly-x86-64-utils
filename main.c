#include "core.h" // include the header file for the core functions

int main(void) {
    // Call the print character function directly via syscall
    print_char('H');
    print_char('i');
    print_char('!');
    print_char('\n'); // Print a newline

    return 0;
}