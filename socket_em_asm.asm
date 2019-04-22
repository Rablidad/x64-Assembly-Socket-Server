global _start

%define hton(x) ((x & 0xFF000000) >> 24) | ((x & 0x00FF0000) >>  8) | ((x & 0x0000FF00) <<  8) | ((x & 0x000000FF) << 24)
%define htons(x) ((x >> 8) & 0xFF) | ((x & 0xFF) << 8)

NULL equ 0
FL equ 10

_port equ 5555
_ip equ 0xc0a80123

IP equ hton(_ip)
PORT equ htons(_port)

SOCK_STREAM equ 1
AF_INET equ 2
PF_INET equ AF_INET


struc sockaddr_in
	sin_port: resd 1
	sin_addr: resq 1
	sin_family: resb 1
	sin_zero: resb 8
endstruc


;struc sockaddr_in
;	sin_port: resd 1
;	sin_addr: resq 1
;	sin_family: resb 1
;	sin_zero: resb 8
;endstruc


section .data

servidor:
	istruc sockaddr_in
		at sin_port, dd PORT
		at sin_addr, dq IP
		at sin_family, db AF_INET
		at sin_zero, db NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL 
	iend



conn dq 0

initializing: db "[!!!] Inicializando conexão!", FL, NULL
.length: equ $-initializing

waiting: db "[*] Aguardando Conexão!", FL, NULL
.length: equ $-waiting

received: db "[+] Conexão Recebida!", FL, NULL
.length: equ $-received


sock_return dq 0


sockfd dq 0

section .text
_start:

	; print inicialização de socket
	lea rsi, [initializing]
	mov rdx, initializing.length
	call printf
	; jmp EXIT_SUCCESS
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	xor rsi, rsi
	xor rdx, rdx
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	call make_connection


	; mov socket-descriptor to mem variable
	mov qword [sockfd], rax
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	call bind
	
	mov qword [sock_return], rax
	cmp qword [sock_return], 0
	jne EXIT_ERROR


	call listen

	mov qword [sock_return], rax
	cmp qword [sock_return], 0
	jne	EXIT_ERROR

	lea rsi, [waiting]
	mov rdx, waiting.length
	call printf


	call accept

	mov qword [sock_return], rax
	cmp qword [sock_return], 0
	jne	EXIT_ERROR
	

	lea rsi, [received]
	mov rdi, waiting.length
	call printf

	; move a fd da conn para a conn variable
	mov qword [conn], rax


	jmp EXIT_SUCCESS


global accept
accept:
	mov rax, 43
	mov rdi, qword [sockfd]
	mov rsi, NULL
	mov rdx, NULL
	syscall

	mov qword [conn], rax
	ret

global listen
listen:

	mov rax, 50
	mov rdi, qword [sockfd]
	mov rsi, 1
	syscall
	ret


global bind
bind:
	mov rax, 49
	mov rdi, qword [sockfd]
	lea rsi, [servidor+sockaddr_in]
	mov rdx, 64
	syscall
	ret

global make_connection
make_connection:
	mov rax, 41
	mov rdi, PF_INET
	mov rsi, SOCK_STREAM
	mov rdx, 0
	syscall
	ret



global printf
printf:
	mov rax, 1
	mov rdi, 1
	syscall
	ret

EXIT_SUCCESS:
	mov rax, 60
	mov rdi, 0
	syscall


EXIT_ERROR:
	mov rax, 60
	mov rdi, 1
	syscall




;servidor:
;	istruc sockaddr_in
;		at sin_port, dd PORT
;		at sin_addr, dq IP
;		at sin_family, db AF_INET
;		at sin_zero, db NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL 
;	iend
