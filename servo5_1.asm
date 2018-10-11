; ABOUT:
; dziala - 20 serw staje w pozycji neutralnej,
; po czym tak 10~12 z nich mozna zmieniach
; ale cholera nie wszystkie
;
; 922 - 1000us     znaczy:  64613
; 461 - 500us      znaczy:  65074
; 1383 - 1500us    znaczy:
; 17050 - 18500us   
;
;
; R0 - adres pamieci dla czasu aktualnego
; R1 - numer servo
; R2 - numer nastepnego
; R4 - czas aktualnego T1
; R5 - czas aktualnego T1
;

T2CON EQU 0C8h

TF2   EQU T2CON.7
EXF2  EQU T2CON.6
RCLK  EQU T2CON.5
TCLK  EQU T2CON.4
EXEN2 EQU T2CON.3
TR2   EQU T2CON.2

RCAP2H EQU 0CBh
RCAP2L EQU 0CAh

;=============

TIME1000US EQU 65535-922
TIME500US  EQU 65535-461
MEMALLOC EQU 30H

;=============

ORG 0
	LJMP MAIN
ORG 0BH
	LJMP T0_HANDLE
ORG 1BH
	LJMP T1_HANDLE
ORG 30H

;
; obszar pamieci czasow dla serv
; HIGH-LOW HIGH-LOW HIGH-LOW ...
;
;


ORG 100H
MAIN:
	MOV TMOD, #00010001B
	MOV TH0, #HIGH TIME1000US
	MOV TL0, #LOW TIME1000US

	MOV R1, #1 ; numer servo
	MOV R2, #2 ; numer servo

	; pierwsze servo za pierwszym razem ZAWSZE ma neutrala
	MOV R4, #HIGH TIME500US
	MOV R5, #LOW  TIME500US
	
	MOV TH1, R4
	MOV TL1, R5

	; wyczyszczenie pamieci
	MOV R7, #40
MEMSWEEP:
	MOV A, MEMALLOC
	ADD A, R7
	MOV R0, A
	MOV A, #00000000B

	MOV @R0, A
	DJNZ R7, MEMSWEEP

	; ustawienie neutralnych pozycji
	MOV R7, #20
MEMNEUTRAL:
	MOV A, MEMALLOC
	ADD A, R7
	ADD A, R7
	MOV R0, A
	MOV A, #HIGH TIME500US
	MOV @R0, A
	
	MOV A, MEMALLOC
	ADD A, R7
	ADD A, R7
	ADD A, #01B
	MOV R0, A
	MOV A, #LOW TIME500US
	MOV @R0, A

	DJNZ R7, MEMNEUTRAL

	; timery dla serv

	SETB TR0
	SETB ET0
	SETB ET1
	SETB EA

	; glowne rzeczy zrobione
	; teraz inicjalizacja portu szeregowego
	; z Timer2 jako baud rate generator
		
	mov scon, #01010000b
	setb RCLK
	setb TCLK
	mov RCAP2H, #0ffh
	mov RCAP2L, #0b8h
	setb TR2
	
mainloop:
	clr RI
	jnb RI, $
	mov R6, SBUF ; should be start signal, check it... start signal is a small letter 'a' - code 61 in hex
	cjne R6, #61h, mainloop ; it is? then go!

	clr RI
	jnb RI, $
	mov R3, SBUF ; placement
	clr RI
	jnb RI, $
	mov R6, SBUF ; high
	clr RI
	jnb RI, $
	mov R7, SBUF ; low
	
	; allocate those
	
	MOV A, MEMALLOC
	ADD A, R3
	ADD A, R3
	MOV R0, A
	MOV A, R6
	MOV @R0, A
	
	MOV A, MEMALLOC
	ADD A, R3
	ADD A, R3
	ADD A, #01B
	MOV R0, A
	MOV A, R7
	MOV @R0, A
	
	; sendback :P
	clr TI
	mov SBUF, R3
	jnb TI, $

	clr TI
	mov SBUF, R6
	jnb TI, $

	clr TI
	mov SBUF, R7
	jnb TI, $
	
	ljmp mainloop  ; tha`, tha` thats alll fooolks!
	
; ================================================================================================================================
T0_HANDLE:
	; T0 nigdy nie gasnie, wznawiamy go od razu
	MOV TH0, #HIGH TIME1000US
	MOV TL0, #LOW TIME1000US
;etykieta to nazwa nastepnego
	;sprawdzenie jaki jest nastepny
	;ustawienie nastepnego na 1
T0_1:
	CJNE R2, #1, T0_2
	SETB P2.0
	LJMP T0_T1START
T0_2:
	CJNE R2, #2, T0_3
	SETB P2.1
	LJMP T0_T1START
T0_3:
	CJNE R2, #3, T0_4
	SETB P2.2
	LJMP T0_T1START
T0_4:
	CJNE R2, #4, T0_5
	SETB P2.3
	LJMP T0_T1START
T0_5:
	CJNE R2, #5, T0_6
	SETB P2.4
	LJMP T0_T1START
T0_6:
	CJNE R2, #6, T0_7
	SETB P2.5
	LJMP T0_T1START
T0_7:
	CJNE R2, #7, T0_8
	SETB P2.6
	LJMP T0_T1START
T0_8:
	CJNE R2, #8, T0_9
	SETB P2.7
	LJMP T0_T1START
T0_9:
	CJNE R2, #9, T0_10
	SETB P3.4
	LJMP T0_T1START
T0_10:
	CJNE R2, #10, T0_11
	SETB P3.5
	LJMP T0_T1START
T0_11:
	CJNE R2, #11, T0_12
	SETB P3.6
	LJMP T0_T1START
T0_12:
	CJNE R2, #12, T0_13
	SETB P3.7
	LJMP T0_T1START
T0_13:
	CJNE R2, #13, T0_14
	SETB P1.0
	LJMP T0_T1START
T0_14:
	CJNE R2, #14, T0_15
	SETB P1.1
	SJMP T0_T1START
T0_15:
	CJNE R2, #15, T0_16
	SETB P1.2
	SJMP T0_T1START
T0_16:
	CJNE R2, #16, T0_17
	SETB P1.3
	SJMP T0_T1START
T0_17:
	CJNE R2, #17, T0_18
	SETB P1.4
	SJMP T0_T1START
T0_18:
	CJNE R2, #18, T0_19
	SETB P1.5
	SJMP T0_T1START
T0_19:
	CJNE R2, #19, T0_20
	SETB P1.6
	SJMP T0_T1START
T0_20:
	CJNE R2, #20, T0_T1START
	SETB P1.7
	SJMP T0_T1START
	
T0_T1START:
	; parametry czasu dla aktualnego powinny byc juz obliczone i zaladowane
	SETB TR1
	RETI
	
; ================================================================================================================================
T1_HANDLE:
T1_1:
	CJNE R1, #1, T1_2
	CLR P2.0
	; tutaj powino byc przeliczenie czasu dla NASTEPNEGO, znaczy R2
	LJMP T1_INC
T1_2:
	CJNE R1, #2, T1_3
	CLR P2.1
	LJMP T1_INC
T1_3:
	CJNE R1, #3, T1_4
	CLR P2.2
	SJMP T1_INC
T1_4:
	CJNE R1, #4, T1_5
	CLR P2.3
	SJMP T1_INC
T1_5:
	CJNE R1, #5, T1_6
	CLR P2.4
	SJMP T1_INC
T1_6:
	CJNE R1, #6, T1_7
	CLR P2.5
	SJMP T1_INC
T1_7:
	CJNE R1, #7, T1_8
	CLR P2.6
	SJMP T1_INC
T1_8:
	CJNE R1, #8, T1_9
	CLR P2.7
	SJMP T1_INC
T1_9:
	CJNE R1, #9, T1_10
	CLR P3.4
	SJMP T1_INC
T1_10:
	CJNE R1, #10, T1_11
	CLR P3.5
	SJMP T1_INC
T1_11:
	CJNE R1, #11, T1_12
	CLR P3.6
	SJMP T1_INC
T1_12:
	CJNE R1, #12, T1_13
	CLR P3.7
	SJMP T1_INC
T1_13:
	CJNE R1, #13, T1_14
	CLR P1.0
	SJMP T1_INC
T1_14:
	CJNE R1, #14, T1_15
	CLR P1.1
	SJMP T1_INC
T1_15:
	CJNE R1, #15, T1_16
	CLR P1.2
	SJMP T1_INC
T1_16:
	CJNE R1, #16, T1_17
	CLR P1.3
	SJMP T1_INC
T1_17:
	CJNE R1, #17, T1_18
	CLR P1.4
	SJMP T1_INC
T1_18:
	CJNE R1, #18, T1_19
	CLR P1.5
	SJMP T1_INC
T1_19:
	CJNE R1, #19, T1_20
	CLR P1.6
	SJMP T1_INC
T1_20:
	CJNE R1, #20, T1_INC
	CLR P1.7
	SJMP T1_INC
	
T1_INC:
	CLR TR1
	MOV A, R2
	MOV R1, A
	INC R2
	CJNE R2, #21, T1_TIMECALC
	
	MOV R2, #1
	
T1_TIMECALC:
	MOV A, MEMALLOC
	ADD A, R2
	ADD A, R2
	MOV R0, A
	MOV A, @R0
	MOV R4, A

	MOV A, MEMALLOC
	ADD A, R2
	ADD A, R2
	ADD A, #01B
	MOV R0, A
	MOV A, @R0
	MOV R5, A
	
	;MOV R4, #HIGH TIME500US
	;MOV R5, #LOW  TIME500US

	MOV TH1, R4
	MOV TL1, R5
	RETI
	
END