; ================================================================
; Author: Munzer Elsarafandi
; Project: II
; Purpose: 
;   - Accepts 2 numbers per round for 3 rounds
;   - Calculates running sum
;   - Displays intermediate and final results
; Date: [04/27/2025]
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

_start:
    xor rbx, rbx         ; rbx will hold the running total
    mov rcx, 3           ; loop counter set to 3 rounds

game_loop:
    ; Display prompt for first number
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; Read first number input
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, buffer_len
    syscall

    ; Convert input to number
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

    ; Clear buffer safely
    push rcx
    mov rcx, buffer_len
    mov rdi, buffer
    xor al, al
    rep stosb
    pop rcx

    ; Display prompt for second number
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; Read second number input
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, buffer_len
    syscall

    ; Convert input to number
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

    ; Add num1 and num2
    mov rdi, [num1]
    mov rsi, [num2]
    call register_adder
    add rbx, rax         ; add to running total

    ; Display the current sum
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

    ; Decrement loop counter and check
    dec rcx
    jnz game_loop        ; Repeat loop if rcx is not zero

    ; After 3 rounds, print the final total
    mov rax, 1
    mov rdi, 1
    mov rsi, final_msg
    mov rdx, final_msg_len
    syscall

    mov rax, rbx
    call print_number

    ; Newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, newline_len
    syscall

    ; Exit program
    mov rax, 60
    xor rdi, rdi
    syscall

;==============================
; Subroutine: Adds two numbers
register_adder:
    mov rax, rdi
    add rax, rsi
    ret

;==============================
; Subroutine: Converts ASCII to Integer
atoi:
    xor rax, rax
    xor rcx, rcx
atoi_loop:
    cmp rcx, buffer_len
    jae atoi_error
    cmp rcx, 10
    jae atoi_error
    movzx rdx, byte [rdi + rcx]
    cmp rdx, 10
    je atoi_done
    cmp rdx, '0'
    jb atoi_error
    cmp rdx, '9'
    ja atoi_error
    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rcx
    jmp atoi_loop

atoi_done:
    ret

atoi_error:
    push rax
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_msg_len
    syscall
    pop rax
    mov rax, 0
    ret

;==============================
; Subroutine: Prints a number
print_number:
    mov rdi, buffer + buffer_len - 1
    mov byte [rdi], 0
    dec rdi
    mov rcx, 10
    mov r8, rax
    test rax, rax
    jnz print_loop
    mov byte [rdi], '0'
    jmp print_done

print_loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz print_loop
    test r8, r8
    jns print_done
    mov byte [rdi], '-'
    dec rdi

print_done:
    inc rdi
    mov rsi, rdi
    mov rdx, buffer + buffer_len
    sub rdx, rsi
    mov rax, 1
    mov rdi, 1
    syscall
    ret
