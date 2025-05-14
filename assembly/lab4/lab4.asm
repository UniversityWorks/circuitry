section .data
    msg_sign db "Enter operation[multiply(*) or divide(/)]: "
    len_msg_sign equ $ - msg_sign

    msg_num1 db "Enter first number [0;255]: "
    len_msg_num1 equ $ - msg_num1
    
    msg_num2 db "Enter second number [0;255]: "
    len_msg_num2 equ $ - msg_num2
    
    msg_res db "res: "
    len_msg_res equ $ - msg_res

    msg_frac db "/"
    len_msg_frac equ $ - msg_frac

section .bss
    sign    resb 2
    
    num1    resb 4
    num2    resb 4
    res     resb 12
    num_temp resb 12
    
    num1_val    resd 1
    num2_val    resd 1
    
    numerator   resd 1
    denominator resd 1
    gcd_res     resd 1

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
    cmp     al, '*'
    je      .do_mul
    cmp     al, '/'
    je      .do_div
    jmp     exit

.do_mul:
    xor     eax, eax
    xor     ebx, ebx
    mov     eax, [num1_val]
    imul    eax, [num2_val]
    xor     edx, edx
    
    xor     ecx, ecx
    test    eax, eax
    jnz     .to_ASCII_res
      
    mov     byte [res], '0'
    mov     ecx, 1
    jmp     .print_integer_only

.to_ASCII_res:
    xor     edx, edx
    mov     ebx, 10
    div     ebx
    add     dl, 48
    push    edx
    inc     ecx
    
    test    eax, eax
    jnz     .to_ASCII_res
    
    mov     ebx, ecx
    xor     ecx, ecx

.build_loop_res:
    cmp     ecx, ebx
    je      .print_integer_only
    
    pop     edx
    mov     [res + ecx], dl
    inc     ecx
    jmp     .build_loop_res

.do_div:
    mov     eax, [num1_val]
    mov     [numerator], eax
    mov     eax, [num2_val]
    mov     [denominator], eax
    
    call    find_gcd
    
    mov     eax, [numerator]
    xor     edx, edx
    div     dword [gcd_res]
    mov     [numerator], eax
    
    mov     eax, [denominator]
    xor     edx, edx
    div     dword [gcd_res]
    mov     [denominator], eax
    
    mov     eax, [numerator]
    xor     ecx, ecx
    test    eax, eax
    jnz     .num_to_ASCII
      
    mov     byte [res], '0'
    mov     ecx, 1
    jmp     .print_frac

.num_to_ASCII:
    xor     edx, edx
    mov     ebx, 10
    div     ebx
    add     dl, 48
    push    edx
    inc     ecx
    
    test    eax, eax
    jnz     .num_to_ASCII
    
    mov     ebx, ecx
    xor     ecx, ecx

.num_build_loop:
    cmp     ecx, ebx
    je      .print_frac
    
    pop     edx
    mov     [res + ecx], dl
    inc     ecx
    jmp     .num_build_loop

.print_frac:
    mov     dword [res + ecx], 0
    mov     edx, ecx
    mov     ecx, res
    mov     ebx, 1
    mov     eax, 4
    int     0x80

    mov     edx, len_msg_frac
    mov     ecx, msg_frac
    mov     ebx, 1
    mov     eax, 4
    int     0x80
    
    mov     eax, [denominator]
    xor     ecx, ecx
    
.denom_to_ASCII:
    xor     edx, edx
    mov     ebx, 10
    div     ebx
    add     dl, 48
    push    edx
    inc     ecx
    
    test    eax, eax
    jnz     .denom_to_ASCII
    
    mov     ebx, ecx
    xor     ecx, ecx

.denom_build_loop:
    cmp     ecx, ebx
    je      .denom_done
    
    pop     edx
    mov     [num_temp + ecx], dl
    inc     ecx
    jmp     .denom_build_loop

.denom_done:
    mov     dword [num_temp + ecx], 0
    
    mov     edx, ecx
    mov     ecx, num_temp
    mov     ebx, 1
    mov     eax, 4
    int     0x80
    jmp     exit

.print_integer_only:
    mov     dword [res + ecx], 0
    mov     edx, ecx
    mov     ecx, res
    mov     ebx, 1
    mov     eax, 4
    int     0x80
    jmp     exit  

find_gcd:
    mov     eax, [numerator]
    mov     ebx, [denominator]
    
.gcd_loop:
    test    ebx, ebx
    jz      .gcd_done
    
    xor     edx, edx
    div     ebx
    mov     eax, ebx
    mov     ebx, edx
    jmp     .gcd_loop
    
.gcd_done:
    mov     [gcd_res], eax
    ret

exit:
    mov     eax, 1
    xor     ebx, ebx
    int     0x80