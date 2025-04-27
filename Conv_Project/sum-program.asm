; ================================================================
; Author: Munzer Elsarafandi
; Project: II
; Purpose: 
;   - Accepts 2 numbers per round for 3 rounds
;   - Handles positive, negative, and zero values
;   - Calculates running sum
;   - Displays intermediate and final results
; Date: [Insert Date Here]
; Updates:
;   - Added negative number support
;   - Improved zero handling
;   - Fixed register conflicts
; ================================================================

section .data
    prompt db "Enter number: ", 0
    prompt_len equ $ - prompt
    result_msg db "The sum is: ", 0
    result_msg_len equ $ - result_msg
    final_msg db "Final sum is: ", 0
    final_msg_len equ $ - final_msg
    newline db 13, 10, 0
    newline_len equ $ - newline
    error_msg db "Invalid input! Using 0.", 13, 10, 0
    error_msg_len equ $ - error_msg
    num1_msg db "num1: ", 0
    num1_msg_len equ $ - num1_msg
    num2_msg db "num2: ", 0
    num2_msg_len equ $ - num2_msg
    buffer times 16 db 0
    buffer_len equ $ - buffer

section .bss
    num1 resq 1
    num2 resq 1

section .text
global _start

; ======================= MAIN PROGRAM ==========================
_start:
    xor rbx, rbx         ; Initialize running total
    mov r12, 3           ; Loop counter (3 rounds)

game_loop:
    ; -------------------- First Number Handling -----------------
    ; Display prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; Read input
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, buffer_len
    syscall

    ; Convert to number
    mov rdi, buffer
    call atoi
    mov [num1], rax

    ; Display num1
    mov rax, 1
    mov rdi, 1
    mov rsi, num1_msg
    mov rdx, num1_msg_len
    syscall
    mov rax, [num1]
    call print_number

    ; Newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, newline_len
    syscall

    ; Clear buffer
    mov rcx, buffer_len
    mov rdi, buffer
    xor al, al
    rep stosb

    ; -------------------- Second Number Handling ----------------
    ; Display prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; Read input
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, buffer_len
    syscall

    ; Convert to number
    mov rdi, buffer
    call atoi
    mov [num2], rax

    ; Display num2
    mov rax, 1
    mov rdi, 1
    mov rsi, num2_msg
    mov rdx, num2_msg_len
    syscall
    mov rax, [num2]
    call print_number

    ; Newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, newline_len
    syscall

    ; -------------------- Calculation & Display -----------------
    ; Add numbers
    mov rdi, [num1]
    mov rsi, [num2]
    call register_adder
    add rbx, rax

    ; Display sum
    mov rax, 1
    mov rdi, 1
    mov rsi, result_msg
    mov rdx, result_msg_len
    syscall
    mov rax, rbx
    call print_number

    ; Newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, newline_len
    syscall

    ; Loop control
    dec r12
    jnz game_loop

    ; -------------------- Final Output --------------------------
    ; Display final sum
    mov rax, 1
    mov rdi, 1
    mov rsi, final_msg
    mov rdx, final_msg_len
    syscall
    mov rax, rbx
    call print_number

    ; Final newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, newline_len
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

; ====================== SUBROUTINES ============================

; ----------------------------------------------------------------
; Adds two numbers
; Input: RDI, RSI
; Output: RAX = RDI + RSI
; ----------------------------------------------------------------
register_adder:
    mov rax, rdi
    add rax, rsi
    ret

; ----------------------------------------------------------------
; Converts ASCII string to 64-bit integer
; Input: RDI = string pointer
; Output: RAX = converted number
; ----------------------------------------------------------------
atoi:
    xor rax, rax        ; Result
    xor rcx, rcx        ; Character index
    xor r9, r9          ; Sign flag (0=positive, 1=negative)
    xor r10, r10        ; Digit counter

    ; Check for sign
    movzx rdx, byte [rdi]
    cmp rdx, '-'
    jne .digit_check
    mov r9, 1           ; Set negative flag
    inc rcx             ; Skip '-' character

.digit_check:
    ; Validate at least one digit present
    movzx rdx, byte [rdi + rcx]
    cmp rdx, 10         ; Empty input (just '-' case)
    je .error
    cmp rdx, 0
    je .error

.digit_loop:
    cmp rcx, buffer_len
    jge .error

    movzx rdx, byte [rdi + rcx]
    cmp rdx, 10         ; Stop at newline
    je .done
    cmp rdx, 0          ; Stop at null terminator
    je .done

    ; Validate digit
    cmp rdx, '0'
    jb .error
    cmp rdx, '9'
    ja .error

    ; Check digit count
    inc r10
    cmp r10, 20         ; Max 19 digits for 64-bit numbers
    ja .error

    ; Convert digit
    sub rdx, '0'
    imul rax, 10
    add rax, rdx
    inc rcx
    jmp .digit_loop

.done:
    ; Apply sign
    test r9, r9
    jz .positive
    neg rax

.positive:
    ret

.error:
    ; Show error message
    push rax
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_msg_len
    syscall
    pop rax
    xor rax, rax
    ret

; ----------------------------------------------------------------
; Prints 64-bit signed integer
; Input: RAX = number to print
; ----------------------------------------------------------------
print_number:
    mov rdi, buffer + buffer_len - 1  ; Buffer end
    mov byte [rdi], 0                 ; Null terminator
    dec rdi
    mov rcx, 10                       ; Base 10
    mov r8, rax                       ; Preserve original value

    ; Handle zero case
    test rax, rax
    jnz .convert
    mov byte [rdi], '0'
    jmp .print

.convert:
    ; Convert absolute value
    test rax, rax
    jns .positive
    neg rax

.positive:
    xor rdx, rdx
    div rcx             ; RAX = quotient, RDX = remainder
    add dl, '0'         ; Convert to ASCII
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz .positive

    ; Add sign if needed
    test r8, r8
    jns .print
    mov byte [rdi], '-'
    dec rdi

.print:
    ; Calculate string length
    inc rdi
    mov rsi, rdi
    mov rdx, buffer + buffer_len
    sub rdx, rsi

    ; System call
    mov rax, 1
    mov rdi, 1
    syscall
    ret