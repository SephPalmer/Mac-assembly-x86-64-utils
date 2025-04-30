
.global _asm_print_char # Add underscore for macOS linker visibility

.text

# --- Print Character Function (macOS x86-64 Syscall) ---
_asm_print_char:
    # Standard function prologue
    pushq %rbp
    movq  %rsp, %rbp
    subq  $16, %rsp       # Allocate 16 bytes on stack (keeps stack 16-byte aligned)

    # The character arrives in %edi (lowest 32 bits of %rdi)
    # We need to store it somewhere in memory to get its address.
    # Store the character byte onto the stack. %dil is the lowest byte of %rdi.
    movb  %dil, -1(%rbp)  # Store the char at address [rbp - 1]

    # Prepare for the 'write' system call (syscall number 0x2000004 on macOS)
    movq  $0x2000004, %rax  # Syscall number for write in %rax
    movq  $1, %rdi        # Arg 1: file descriptor (1 = stdout) in %rdi
    leaq  -1(%rbp), %rsi   # Arg 2: address of buffer (the char on the stack) in %rsi
    movq  $1, %rdx        # Arg 3: count (1 byte) in %rdx

    # Make the system call
    syscall               # Kernel executes the write

    # Result of syscall (bytes written or error) is in %rax. We ignore it here.
    # Optionally, set function return value to 0
    # xorl %eax, %eax

    # Standard function epilogue
    addq  $16, %rsp       # Deallocate stack space
    popq  %rbp            # Restore caller's base pointer
    ret                   # Return