# hello_file.s - Writes message, reads input, echoes input to a file on macOS x86_64
# Assemble & Link using clang: clang hello_file.s -o hello_file

# System call numbers (macOS x86_64)
SYS_EXIT  = 0x2000001
SYS_READ  = 0x2000003
SYS_WRITE = 0x2000004
SYS_OPEN  = 0x2000005
SYS_CLOSE = 0x2000006

# File open flags (combine with OR)
O_WRONLY = 0x0001      # Open for writing only
O_CREAT  = 0x0200      # Create file if it does not exist
O_TRUNC  = 0x0400      # Truncate size to 0

# File modes (permissions)
MODE_RW_R_R = 0644     # User: read/write, Group: read, Other: read

# Section for read-only data (strings)
.section __TEXT,__cstring,cstring_literals
message:
    .asciz "Hello, Mike\n"          # Initial message (Length: 12)
prompt:
    .asciz "Enter text: "          # Prompt for input (Length: 12)
thanks_message:
    .asciz "Thanks, you entered: " # Message before echoing input (Length: 21)
output_filename:
    .asciz "output.txt"            # Name of the output file

# Section for uninitialized writable data
.section __DATA,__bss
.lcomm input_buffer, 64            # Reserve 64 bytes for input buffer

# Section for the actual code
.section __TEXT,__text

# ==============================================================================
# Procedure: _open_file
# Opens a file with specified flags and mode.
# Arguments:
#   %rdi: Address of the null-terminated filename string.
#   %rsi: Flags for opening (e.g., O_WRONLY | O_CREAT | O_TRUNC).
#   %rdx: Mode (permissions) if creating the file (e.g., 0644).
# Uses syscall 5 (open).
# Returns:
#   %rax: File descriptor (>= 0) on success, or -1 on error.
# ==============================================================================
_open_file:
    movq $SYS_OPEN, %rax          # syscall number 5 (open)
    # rdi already contains filename address (Arg 1)
    # rsi already contains flags (Arg 2)
    # rdx already contains mode (Arg 3)
    syscall                       # rax will contain file descriptor or error code
    ret                           # Return from procedure

# ==============================================================================
# Procedure: _close_file
# Closes an open file descriptor.
# Arguments:
#   %rdi: File descriptor to close.
# Uses syscall 6 (close).
# Returns:
#   %rax: 0 on success, -1 on error.
# ==============================================================================
_close_file:
    movq $SYS_CLOSE, %rax         # syscall number 6 (close)
    # rdi already contains the file descriptor (Arg 1)
    syscall                       # rax will contain 0 or -1
    ret                           # Return from procedure

# ==============================================================================
# Procedure: _write_to_fd
# Writes a string to the specified file descriptor.
# Arguments:
#   %rdi: File descriptor.
#   %rsi: Address of the string to write.
#   %rdx: Length of the string to write.
# Uses syscall 4 (write).
# Returns:
#   %rax: Result of the write syscall (bytes written or -1 on error).
# ==============================================================================
_write_to_fd:
    movq $SYS_WRITE, %rax         # syscall number 4 (write)
    # rdi already contains the file descriptor (Arg 1)
    # rsi already contains the string address (Arg 2)
    # rdx already contains the string length (Arg 3)
    syscall                       # rax will contain bytes written or error code
    ret                           # Return from procedure

# ==============================================================================
# Procedure: _read_input
# Reads input from standard input (stdin) into a buffer.
# Arguments:
#   %rdi: Address of the buffer to store input.
#   %rsi: Maximum number of bytes to read (buffer size).
# Returns:
#   %rax: Number of bytes actually read.
# Uses syscall 3 (read).
# ==============================================================================
_read_input:
    movq $SYS_READ, %rax          # syscall number 3 (read)
    movq $0, %rdi                 # file descriptor 0 (stdin)
    # rsi already contains buffer address (Arg 2)
    # rdx already contains max length (Arg 3)
    syscall
    # rax already contains the number of bytes read (return value)
    ret                           # Return from procedure

# ==============================================================================
# Procedure: _exit_program
# Terminates the program with a given exit code.
# Arguments:
#   %rdi: Exit code.
# Uses syscall 1 (exit).
# Does not return.
# ==============================================================================
_exit_program:
    movq $SYS_EXIT, %rax          # syscall number 1 (exit)
    # rdi already contains the exit code passed as argument
    syscall
    # No ret needed, syscall terminates the process

# ==============================================================================
# Main entry point of the program
# ==============================================================================
.globl _main                       # Make _main globally visible
_main:
    # --- Open the output file ---
    leaq output_filename(%rip), %rdi # Arg 1: address of the filename
    movq $(O_WRONLY | O_CREAT | O_TRUNC), %rsi # Arg 2: flags
    movq $MODE_RW_R_R, %rdx       # Arg 3: mode
    call _open_file               # Call the open procedure
    # %rax now holds the file descriptor or -1

    # --- Check for open error ---
    cmpq $-1, %rax                # Compare rax with -1
    je _open_error                # If equal (error), jump to error handling
    movq %rax, %r12               # Save the file descriptor in r12 (callee-saved)

    # --- Write the "Hello, Mike\n" message to the file ---
    movq %r12, %rdi               # Arg 1: file descriptor from r12
    leaq message(%rip), %rsi      # Arg 2: address of the message string
    movq $12, %rdx                # Arg 3: length of "Hello, Mike\n"
    call _write_to_fd             # Call the write procedure

    # --- Write the "Enter text: " prompt to the file ---
    movq %r12, %rdi               # Arg 1: file descriptor
    leaq prompt(%rip), %rsi       # Arg 2: address of the prompt string
    movq $12, %rdx                # Arg 3: length of "Enter text: "
    call _write_to_fd             # Call the write procedure

    # --- Read from terminal input (stdin is still used for reading) ---
    leaq input_buffer(%rip), %rsi # Arg 2: address of the writable input buffer
    movq $64, %rdx                # Arg 3: maximum length to read
    call _read_input              # Call the read procedure (reads from stdin)
    # %rax now holds the number of bytes read

    # --- Save the number of bytes read ---
    movq %rax, %r10               # Copy byte count from rax to r10

    # --- Write the "Thanks, you entered: " message to the file ---
    movq %r12, %rdi               # Arg 1: file descriptor
    leaq thanks_message(%rip), %rsi # Arg 2: address of the "thanks" message
    movq $21, %rdx                # Arg 3: length of "Thanks, you entered: "
    call _write_to_fd             # Call the write procedure

    # --- Write the actual user input to the file ---
    movq %r12, %rdi               # Arg 1: file descriptor
    leaq input_buffer(%rip), %rsi # Arg 2: address of the buffer holding user input
    movq %r10, %rdx               # Arg 3: length = number of bytes read (from saved r10)
    call _write_to_fd             # Call the write procedure

    # --- Close the file ---
    movq %r12, %rdi               # Arg 1: file descriptor to close
    call _close_file              # Call the close procedure

    # --- Exit successfully ---
    movq $0, %rdi                 # Arg 1: exit code 0
    call _exit_program            # Call the exit procedure

_open_error:
    # If opening the file failed, exit with code 1
    movq $1, %rdi                 # Arg 1: exit code 1
    call _exit_program            # Call the exit procedure