section .data
    msg_sign db "Enter operation['+' or '-']: "
    len_msg_sign equ $ - msg_signqu 
    
    msg_num1 db "Enter first number [0;255]: "
    len_msg_num1 equ $ - msg_num1
    
    msg_num2 db "Enter second number [0;255]: "
    len_msg_num2 equ $ - msg_num2
    
    msg_res db "res: "
    len_msg_res equ $ - msg_res


section .bss

    sign    resb 2

    num1    resb 4
    num2    resb 4
    res     resb 4

    num1_val resd 1
    num2_val resd 1


section .text

    global _start

_start:

    mov     edx, len_msg_sign
    mov     ecx, msg_sign
    mov     ebx, 1
    mov     eax, 4
    int     0x80
    
    mov     edx, 2
    mov     ecx, sign
    mov     ebx, 0
    mov     eax, 3
    int     0x80
    
    mov     edx, len_msg_num1
    mov     ecx, msg_num1
    mov     ebx, 1
    mov     eax, 4
    int     0x80
    
    mov     edx, 4
    mov     ecx, num1
    mov     ebx, 0
    mov     eax, 3
    int     0x80
    
    mov     edx, len_msg_num2
    mov     ecx, msg_num2
    mov     ebx, 1
    mov     eax, 4
    int     0x80
    
    mov     edx, 4
    mov     ecx, num2
    mov     ebx, 0
    mov     eax, 3
    int     0x80
    
    mov     edx, len_msg_res
    mov     ecx, msg_res
    mov     ebx, 1
    mov     eax, 4
    int     0x80
    
    xor     eax, eax
    xor     ebx, ebx
    
.to_digit_first:
    movzx   edx, byte [num1 + ebx]
    cmp     dl, 0xA
    je      .converted_first
    cmp     dl, 0
    je      .converted_first
    
    sub     dl, 48
    imul    eax, 10
    add     eax, edx
    
    inc     ebx
    cmp     ebx, 4
    jl      .to_digit_first
    
.converted_first:
    mov     [num1_val], eax
    
    xor     eax, eax
    xor     ebx, ebx
    
.to_digit_second:
    movzx   edx, byte [num2 + ebx]
    cmp     dl, 0xA
    je      .converted_second
    cmp     dl, 0
    je      .converted_second
    
    sub     dl, 48
    imul    eax, 10
    add     eax, edx
    
    inc     ebx
    cmp     ebx, 4
    jl      .to_digit_second
    
.converted_second:
    mov     [num2_val], eax
    
    mov     al, byte [sign]
    cmp     al, '+'
    je      .do_add
    cmp     al, '-'
    je      .do_sub
    jmp     .exit
    
.do_add:
    mov     eax, [num1_val]
    add     eax, [num2_val]
    jmp     .convert_result
    
.do_sub:
    mov     eax, [num1_val]
    sub     eax, [num2_val]
    
.convert_result:
    xor     ecx, ecx
    
    test    eax, eax
    jnz     .to_ASCII
    
    mov     byte [res], '0'
    mov     ecx, 1
    jmp     .print_result
    
.to_ASCII:
    xor     edx, edx
    mov     ebx, 10
    div     ebx
    add     dl, 48
    push    edx
    inc     ecx
    
    test    eax, eax
    jnz     .to_ASCII
    
    mov     ebx, ecx
    xor     ecx, ecx
    
.build_loop:
    cmp     ebx, 0
    je      .print_result
    
    pop     edx
    mov     [res + ecx], dl
    inc     ecx
    dec     ebx
    jmp     .build_loop
    
.print_result:
    mov     edx, ecx
    mov     ecx, res
    mov     ebx, 1
    mov     eax, 4
    int     0x80
    
    mov     byte [res], 0xA
    mov     edx, 1
    mov     ecx, res
    mov     ebx, 1
    mov     eax, 4
    int     0x80
    
.exit:
    mov     eax, 1
    xor     ebx, ebx
    int     0x80