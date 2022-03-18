		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Timer Definition
STCTRL		EQU		0xE000E010		; SysTick Control and Status Register
STRELOAD	EQU		0xE000E014		; SysTick Reload Value Register
STCURRENT	EQU		0xE000E018		; SysTick Current Value Register
	
STCTRL_STOP	EQU		0x00000004		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 0, Bit 0 (ENABLE) = 0
STCTRL_GO	EQU		0x00000007		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 1, Bit 0 (ENABLE) = 1
STRELOAD_MX	EQU		0x00FFFFFF		; MAX Value = 1/16MHz * 16M = 1 second
STCURR_CLR	EQU		0x00000000		; Clear STCURRENT and STCTRL.COUNT	
SIGALRM		EQU		14			; sig alarm

; System Variables
SECOND_LEFT	EQU		0x20007B80		; Secounds left for alarm( )
USR_HANDLER     EQU		0x20007B84		; Address of a user-given signal handler function	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer initialization
; void timer_init( )
		EXPORT		_timer_init
_timer_init
	;; Implement by yourself
		STMFD	sp!, {r1-r12, lr}
		LDR		R1, =STCTRL
		MOV		R2, #STCTRL_STOP
		STR 	R2, [R1]
		LDR		R1, =STRELOAD
		MOV		R2, #STRELOAD_MX
		STR		R2, [R1]
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr		; return to Reset_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer start
; int timer_start( int seconds )
		EXPORT		_timer_start
_timer_start
	;; Implement by yourself
		STMFD	sp!, {r1-r12, lr}
		MOV		R1, R0
		CMP		R1, #0
		BLE		_timer_start_return
		LDR		R7, =SECOND_LEFT
		LDR		R0, [R7]
		STR 	R1, [R7]
		LDR		R2, =STCTRL
		MOV		R3, #STCTRL_GO
		STR		R3, [R2]
		LDR		R2, =STCURRENT
		MOV		R3, #STCURR_CLR
		STR		R3, [R2]
		
_timer_start_return
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr		; return to SVC_Handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void timer_update( )
		EXPORT		_timer_update
_timer_update
	;; Implement by yourself
		STMFD	sp!, {r1-r12, lr}
		LDR		R3, =SECOND_LEFT
		LDR		R0, [R3]
		SUB		R0, R0, #1
		STR		R0, [R3]
		CMP		R0, #0
		BNE		_timer_update_done
		LDR		R3, =STCTRL
		MOV		R4, #STCTRL_STOP
		STR		R4, [R3]
	;INVOKING USER FUNCTION	
		MOVS	R0, #3
		MSR		CONTROL, R0
		LDR 	R3, =USR_HANDLER
		LDR		R4, [R3]
		BX		R4
	
		
_timer_update_done
		LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr		; return to SysTick_Handler


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void* signal_handler( int signum, void* handler )
	    EXPORT	_signal_handler
_signal_handler
	;; Implement by yourself
	STMFD	sp!, {r1-r12, lr}
	CMP		R0, #14
	BEQ		_signal
	B		_done
_signal
	LDR		R2, =USR_HANDLER
	LDR		R0, [R2]
	STR		R1, [R2]
_done

	
;	MOV		R2, R1
;	LDR		R3, =USR_HANDLER
;	LDR		R0, [R3]
;	STR		R2, [R3]
	LDMFD	sp!, {r1-r12, lr}
		MOV		pc, lr		; return to Reset_Handler
		
		END		
