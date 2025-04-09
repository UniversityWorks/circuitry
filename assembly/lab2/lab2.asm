section .data
    msg db "Enter Number[0-255]: "
    len_msg equ $ - msg
    msg_res db "res: "
    len_res equ $ - msg_res

section .bss

    num  resb 3
    count resb 1
    res resb 3           

section .text

    global _start       

_start:                 

    						; out << "Enter Number[0-255]: "
    mov     edx, len_msg    
    mov     ecx, msg        
    mov     ebx, 1          
    mov     eax, 4          
    int     0x80            
    
    						; in >> num
    mov     edx, 3          
    mov     ecx, num        
    mov     ebx, 0        
    mov     eax, 3          
    int     0x80            
    
						    ; out << "res: "
    mov     edx, len_res    
    mov     ecx, msg_res    
    mov     ebx, 1          
    mov     eax, 4          
    int     0x80            
							; clean up
    xor     eax, eax        
    xor     ebx, ebx        
    xor     ecx, ecx        
    xor     edx, edx        
							; convert to digit
.to_digit:

    movzx   edx, byte [num + ebx] 
    cmp     dl, 0xA          
    je      .converted
    
    sub     dl, 48          
    imul    eax, 10          
    add     eax, edx        
    
    inc     ebx              
    cmp     ebx, 3           
    jl      .to_digit
    
.converted:
    mov     ecx, 0           
    
.to_ASCII:
    xor     edx, edx        
    mov     ebx, 10         
    div     ebx              
    add     dl, 48          
    push    edx             
    inc     ecx              
    
    cmp     eax, 0           
    jne     .to_ASCII        
    
    mov     ebx, ecx         
    
    mov     ecx, 0           
    
.build_loop:
    cmp     ebx, 0           
    je      .exit
    
    pop     edx              
    mov     [res + ecx], dl  
    inc     ecx              
    dec     ebx              
    jmp     .build_loop
    
.exit:
    mov     edx, ecx         
    mov     ecx, res         
    mov     ebx, 1           
    mov     eax, 4           
    int     0x80
    
    mov     eax, 1           
    xor     ebx, ebx         
    int     0x80
