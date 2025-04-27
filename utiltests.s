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