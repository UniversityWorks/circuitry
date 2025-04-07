section .data

	msg db "Enter number: "
	len equ $ - msg

	msg_res db "Res: "
	len_res equ $ - msg_res

section .bss

	num resb 4

section .text
	global _start

_start:
	mov	edx, len
	mov	ecx, msg
	mov	ebx, 1
	mov	eax, 4
	int	0x80

	mov	edx, 4
	mov	ecx, num
	mov	ebx, 2
	mov	eax, 3
	int	0x80

	mov ebx, 
