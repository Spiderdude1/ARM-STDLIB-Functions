		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _bzero( void *s, int n )
; Parameters
;	s 		- pointer to the memory location to zero-initialize
;	n		- a number of bytes to zero-initialize
; Return value
;   none
		EXPORT	_bzero
_bzero
		; implement your complete logic, including stack operations
		STMFD	sp!, {r1-r12, lr}
		MOV		R3, R0
		MOV		R2, #0
loop	SUBS	r1, r1, #1
		BMI		end_func_bzero
		STRB	R2, [R0], #1
		B		loop
		
end_func_bzero
		MOV		R0, R3
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; char* _strncpy( char* dest, char* src, int size )
; Parameters
;   	dest 	- pointer to the buffer to copy to
;	src	- pointer to the zero-terminated string to copy from
;	size	- a total of n bytes
; Return value
;   dest
		EXPORT	_strncpy
_strncpy
		; implement your complete logic, including stack operations
		STMFD	sp!, {r1-r12,lr}
		MOV		R3, R0
		MOV		R5, R2
		;PUSH	{LR}
		;LDR		R0, =dest
		;LDR		R1, =src
		;LDR		R2, =size
loop_cpy	CMP		R5, #0
		BEQ		end_func
		LDRB	R4, [R1], #1
		SUB		R5, R5, #1
		STRB	R4, [R0], #1
		B		loop_cpy
end_func
		MOV		R0, R3
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _malloc( int size )
; Parameters
;	size	- #bytes to allocate
; Return value
;   	void*	a pointer to the allocated space
		EXPORT	_malloc
_malloc
		STMFD	sp!, {r1-r12,lr}
		; set the system call # to R7
		MOV		R7, #0x04
		
	    SVC     #0x0
		; resume registers
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _free( void* addr )
; Parameters
;	size	- the address of a space to deallocate
; Return value
;   	none
		EXPORT	_free
_free
		; save registers
		STMFD	sp!, {r1-r12,lr}
		; set the system call # to R7
		MOV		R7, #0x05
        	SVC     #0x0
		; resume registers
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; unsigned int _alarm( unsigned int seconds )
; Parameters
;   seconds - seconds when a SIGALRM signal should be delivered to the calling program	
; Return value
;   unsigned int - the number of seconds remaining until any previously scheduled alarm
;                  was due to be delivered, or zero if there was no previously schedul-
;                  ed alarm. 
		EXPORT	_alarm
_alarm
		; save registers
		STMFD	sp!, {r1-r12,lr}
		; set the system call # to R7
		MOV		R7, #0x01
        	SVC     #0x0
		; resume registers
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr		
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _signal( int signum, void *handler )
; Parameters
;   signum - a signal number (assumed to be 14 = SIGALRM)
;   handler - a pointer to a user-level signal handling function
; Return value
;   void*   - a pointer to the user-level signal handling function previously handled
;             (the same as the 2nd parameter in this project)
		EXPORT	_signal
_signal
		; save registers
		STMFD	sp!, {r1-r12,lr}
		; set the system call # to R7
		MOV		R7, #0x02
        	SVC     #0x0
		; resume registers
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		END			
