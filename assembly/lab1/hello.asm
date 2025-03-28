section .data
    Message db 'First run of the assembly!', 10  
    MsgLen equ $ - Message  

section .text
    global _start

_start:
    mov rax, 1    
    mov rsi, Message 
    mov rdx, MsgLen  
    syscall

    mov rax, 60     
    xor rdi, rdi    
    syscall
