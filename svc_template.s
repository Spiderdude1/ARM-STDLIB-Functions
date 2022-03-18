		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table
SYSTEMCALLTBL	EQU		0x20007B00 ; originally 0x20007500
SYS_EXIT		EQU		0x0		; address 20007B00
SYS_ALARM		EQU		0x1		; address 20007B04
SYS_SIGNAL		EQU		0x2		; address 20007B08
SYS_MEMCPY		EQU		0x3		; address 20007B0C
SYS_MALLOC		EQU		0x4		; address 20007B10
SYS_FREE		EQU		0x5		; address 20007B14


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table Initialization
		EXPORT	_syscall_table_init
		
_syscall_table_init
	;; Implement by yourself
	STMFD	sp!, {r1-r12,lr}
	
	LDR		R1, =SYSTEMCALLTBL
	ADD		R1, R1, #4
	
	IMPORT _timer_start
	LDR		R2, =_timer_start
	STR		R2, [R1]
	
	IMPORT _signal_handler
	ADD		R1, R1, #4	
	LDR		R2, =_signal_handler
	STR		R2, [R1]
	
	IMPORT _kalloc
	ADD		R1, R1, #4
	LDR		R2, =_kalloc
	STR		R2, [R1]
		
	IMPORT _kfree
	ADD		R1, R1, #4
	LDR		R2, =_kfree
	STR		R2, [R1]	
		
	LDMFD	sp!, {r1-r12, lr}
	MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table Jump Routine
        EXPORT	_syscall_table_jump
_syscall_table_jump
	;; Implement by yourself
	STMFD	sp!, {r1-r12,lr}
		;LDR		R8, =SYS_MALLOC
		;LDR		R9, [R8]
		;BLX		R9
;		LDR		R1, =SYSTEMCALLTBL
;		MOV		R4, #4
;		MUL		R3, R7, R4
;		ADD		R5, R1, R3
;		LDR		R6, [R5]
;		BLX		R6
		
		CMP		R7, #0X1
		BNE		SIG
		LDR		R11, =SYSTEMCALLTBL
			ADD		R11, R11, #4
			LDR		R11, =_timer_start
			BLX		R11
SIG		CMP		R7, #0X2
		BNE		MALLOC
		ADD		R11, R11, #8
		LDR		R11, =_signal_handler
		BLX		R11
		
		
MALLOC		CMP		R7, #0X4
			BNE		FREE
			;LDR		R1, =SYSTEMCALLTBL
			ADD		R11, R11, #12
			LDR		R11, =_kalloc
			BLX		R11
		
			
		
FREE			CMP		R7, #0X5
				BNE		END_
				ADD		R11, R11, #16		
				LDR		R11, =_kfree
				BLX		R11
		
END_		
		
;		CMP		R7, #0x4
;		BEQ		q
;q
;		LDR		R1, =SYSTEMCALLTBL
;		LSR		R1, R1, #4
;		LDR		R1, =_kalloc
;		BLX		R1
		
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr			
		
		END


		
