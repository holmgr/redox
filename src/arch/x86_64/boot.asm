global start

section .text
bits 32
start:
	mov esp, stack_top

	call check_multiboot
	call check_cpuid
	call check_long_mode

	call set_up_page_tables

	; print 'OK' to screen
	mov dword [0xb8000], 0x2f4b2f4f
	hlt

; Throw error '0' if eax does not contain Multiboot 2 magic value
check_multiboot:
	cmp eax, 0x36d76289
	jne .no_multiboot
	ret
.no_multiboot:
	mov al, "0"
	jmp error

; Throw error '1' if the CPU does not support CPUID command
check_cpuid:
	; Check if CPUID is supported by attempting to flip the ID bit (bit 21) in
    ; the FLAGS register. If we can flip it, CPUID is available.

    ; Copy FLAGS in to EAX via stack
    pushfd
    pop eax

    ; Copy to ECX as well for comparing later on
    mov ecx, eax

    ; Flip the ID bit
    xor eax, 1 << 21

    ; Copy EAX to FLAGS via the stack
    push eax
    popfd

    ; Copy FLAGS back to EAX (with flipped bit if CPUID supported)
    pushfd
    pop eax

    ; Restore FLAGS from the old version stored in ECX (flipping the ID back
    ; if it was flipped before)
    push ecx
    popfd

    ; Compare EAX and ECX, if equal then CPUID is not supported
    cmp eax, ecx
    je .no_cpuid
    ret

.no_cpuid:
	mov al, "1"
	jmp error

; Test if extended processor info is available
check_long_mode:
	mov eax, 0x80000000		; implicit argument for cpuid
	cpuid					; get highest supported arg
	cmp eax, 0x80000001		; it needs to be at least this
	jb .no_long_mode		; if less, CPU too old for long mode

	; use extended info to test if long mode is available
	mov eax, 0x80000001		; argument of extended processor info
	cpuid					; return various feature bits in ecx and edx
	test edx, 1 << 29		; test if the LM-bit is set in the D-register
	jz .no_long_mode		; if not set, there is no long mode
	ret
.no_long_mode:
	mov al, "2"
	jmp error

set_up_page_tables:
	; map first P4 entry to P3 table
	mov eax, p3_table
	or eax, 0b11 ; present + writable
	mov [p4_table], eax

	; map first P3 entry to P2 table
	mov eax, p2_table
	or eax, 0b11 ; present + writable
	mov [p3_table], eax

	; map each P2 entry to a huge 2MiB page
	mov ecx, 0 ; counter variable

.map_p2_table:
	; map ecx-th P2 entry to a huge page that starts at address 2MiB*ecx
	mov eax, 0x200000				; 2MiB
	mul ecx 						; start address of ecx-th page
	or eax, 0b10000011				; present + writable + huge
	mov [p2_table + ecx * 8], eax 	; map ecx-th entry

	inc ecx 						; increase counter
	cmp ecx, 512					; if counter == 512, the whole P2 is mapped
	jne .map_p2_table				; else map the next entry

	ret

; Prints 'ERR: ' and the given error code to screen and hangs
; parameter: error code (in ascii) in al
error:
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte  [0xb800a], al
    hlt

section .bss
align 4096
p4_table:
	resb 4096
p3_table:
	resb 4096
p2_table:
	resb 4096
stack_bottom:
	resb 64
stack_top: