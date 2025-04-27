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
.globl _open_file             # Make the _open_file label globally visible
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
.globl _close_file             # Make the _close_file label globally visible
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
.globl _write_to_fd             # Make the _write_to_fd label globally visible
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
.globl _read_input              # Make the _read_input label globally visible
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
.globl _exit_program            # Make the _exit_program label globally visible
_exit_program:
    movq $SYS_EXIT, %rax          # syscall number 1 (exit)
    # rdi already contains the exit code passed as argument
    syscall
    # No ret needed, syscall terminates the process