		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table
HEAP_TOP	EQU		0x20001000
HEAP_BOT	EQU		0x20004FE0
MAX_SIZE	EQU		0x00004000		; 16KB = 2^14
MIN_SIZE	EQU		0x00000020		; 32B  = 2^5
	
MCB_TOP		EQU		0x20006800      	; 2^10B = 1K Space
MCB_BOT		EQU		0x20006BFE
MCB_ENT_SZ	EQU		0x00000002		; 2B per entry
MCB_TOTAL	EQU		512			; 2^9 = 512 entries
	
INVALID		EQU		-1			; an invalid id
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Control Block Initialization
		EXPORT	_heap_init
_heap_init
	;; Implement by yourself
		STMFD	sp!, {r1-r12,lr}
		LDR		R1, =MAX_SIZE
		LDR		R2, =MCB_TOP
		MOV 	R4, #0x0
		STR		R1 , [R2], #4	
		LDR		R3, =0x20006C00
loop	CMP		R2, R3
		BGT		end_heap_init
		STR		R4, [R2]
		STR		R4, [R2, #1]
		ADD		R2, R2, #2
		B		loop
end_heap_init
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory Allocation
; void* _k_alloc( int size )
		EXPORT	_kalloc
_kalloc
	;; Implement by yourself
		STMFD	sp!, {r1-r12,lr}
		MOV		R3, R0
		LDR		R1, =MCB_TOP
		LDR		R2, =MCB_BOT
		LDR		R11, =_ralloc
		BLX		R11
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_ralloc
		STMFD	sp!, {r1-r12,lr}
		; R3 = size
		; R1 = MCB_TOP | LEFT
		; R2 = MCB_BOT  | Right
		; R4 = entire
		; R5 = half
		; R6 = midpoint
		; R7 = heap_addr
		; R8 = act_entire_size
		; R9 = act_half_size
		; R10 = mcb_ent_size
		LDR 	R10, =MCB_ENT_SZ
		; Initial Parameter Calculation
		;entire
		SUB 	R11, R2, R1
		ADD		R4, R11, R10
		;ADD		R11, R10, R1
		;SUB		R4, R2, R11
		; half
		ASR		R5, R4, #1
		; midpoint
		ADD		R6, R1, R5
		;heap_addr
		MOV		R7, #0x0
		;act_half_size
		LSL		R9, R5, #4
		;act_entire_size
		LSL		R8, R4, #4
		
		CMP		R3, R9
		BGT		Branch_statement3
		SUB		R2, R6, R10
		BL		_ralloc
		MOV		R7, R0
		CMP		R7, #0
		BNE		Branch_statement1
		
		
		SUB		R12, R4, R10
		ADD		R12, R12, R1
		MOV		R2, R12
		MOV		R1, R6
		
		BL		_ralloc
		MOV		R7, R0
		B		End_case
Branch_statement1
		LDR		R12, [R6]
		AND		R12, R12, #0x01
		
		CMP		R12, #0
		BNE 	Branch_statement2
		STR		R9, [R6]
		
Branch_statement2
		MOV		R7, R0
		B		End_case
		
Branch_statement3
		LDR		R12, [R1]
		AND		R12, R12, #1
		;LSR		R12, #24 ;;;;
		CMP		R12, #0
		BEQ		Branch_statement4
		MOV		R7, #0 ; or R7
		B		End_case
Branch_statement4
		LDR		R12, [R1]
		CMP		R12, R8
		BGE		Branch_statement5   
		MOV		R7, #0
		B		End_case
Branch_statement5
		LDR		R12, [R1]
		MOV		R11, R8
		ORR		R11, R11, #0x1
		STR		R11, [R1]
		LDR		R11, =MCB_TOP
		SUB		R12, R1, R11
		LSL		R12, R12, #4
		LDR		R11, =HEAP_TOP
		ADD		R7, R12, R11
		
		
End_case		
		MOV		R0, R7
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
; void free( void *ptr )
		EXPORT	_kfree
_kfree
	;; Implement by yourself
		STMFD	sp!, {r1-r12,lr}
		LDR		R2, =HEAP_TOP
		SUB		R1, R0, R2
		ASR		R1, R1, #4
		LDR		R3, =MCB_TOP
		MOV		R5, R0
		ADD		R0, R3, R1
		LDR		R11, =_rfree
		BLX		R11
		MOV		R0, R5
		LDMFD	sp!, {r1-r12, lr}
		;MOV		R0, R5
		MOV		pc, lr					; return from rfree( )
_rfree
		STMFD	sp!, {r1-r12,lr}
		
		;R1 mcb_contents
		;R2 mcb_index
		;R3 mcb_disp
		;R4 my_size
		;R10 mcb_buddy
		LDR		R1, [R0]
		LDR		R5, =MCB_TOP
		SUB		R2, R0, R5
		ASR		R1, R1, #4
		MOV		R3, R1
		LSL		R1, R1, #4
		MOV 	R4, R1
		STR		R1, [R0]
		
		SDIV	R6, R2, R3
		MOV		R8, #2
		SDIV	R11, R6, R8
		MLS		R7, R8, R11, R6
		CMP		R7, #0
		BNE		r_free_branch2
		ADD		R6, R0, R3
		LDR		R7, =MCB_BOT
		CMP		R6, R7
		BLT		r_free_branch1				
		MOV		R9, #0
		B		End_r_free

r_free_branch1
		LDR		R10, [R6]	
		AND		R12, R10, #0x0001 
		CMP		R12, #0
		BNE		Return_case1
		ASR		R10, R10, #5
		LSL		R10, R10, #5
		CMP		R10, R4
		BNE		Return_case1
		MOV		R11, #0
		STR		R11, [R6]
		LSL		R4, R4, #1
		STR		R4, [R0]
		BL		_rfree
		MOV		R9, R0
		B		End_r_free

r_free_branch2
		SUB		R6, R0, R3
		LDR		R7, =MCB_TOP
		CMP		R6, R7
		BGE		r_free_branch3
		MOV		R9, #0
		B		End_r_free

r_free_branch3
		LDR		R10, [R6]
		AND		R12, R10, #0x0001 
		CMP		R12, #0
		BNE		Return_case1
		ASR		R10, R10, #5
		LSL		R10, R10, #5
		CMP		R10, R4
		BNE		Return_case1
		MOV		R11, #0
		STR		R11, [R0]
		LSL		R4, R4, #1
		STR		R4, [R6]
		MOV		R0, R6
		BL		_rfree
		MOV		R9, R0
		B		End_r_free

Return_case1
		MOV		R9, R0

End_r_free
		MOV		R0, R9		
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr					; return from rfree( )
		
		END
