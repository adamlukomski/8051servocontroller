; ABOUT
; praca na 4800, 8bit danych, bez parzystosci, 1bit stopu, sprzetowe sterowanie przeplywem
; na razie tylko wywala znak na port2
;


;==========================================
;         TIMER 2 DECLARATIONS

T2CON EQU 0C8h

TF2   EQU T2CON.7
EXF2  EQU T2CON.6
RCLK  EQU T2CON.5
TCLK  EQU T2CON.4
EXEN2 EQU T2CON.3
TR2   EQU T2CON.2

RCAP2H EQU 0CBh
RCAP2L EQU 0CAh

;==========================================

org 0
	mov scon, #01010000b ; 8-bit uart, var baud rate
	
	;mov tmod, #00100000b ;t1 serial, autoreload mode 1 on t1
	;mov TH1, #0fah ;t1 serial 4800
	;setb TR1 ;t1 serial
	;clr RCLK ;t1 serial
	;clr TCLK ;t1 serial
	
	setb RCLK ;t2 serial override from t1
	setb TCLK ;t2 serial override from t1
	
	mov RCAP2H, #0ffh ;t2 serial 4800
	mov RCAP2L, #0b8h ;t2 serial 4800
	
	setb TR2 ; t2 serial start
	
	; koniec obslugi szeregowego
	; ustawienia domyslne dla servo

;==========================================
mainloop:
	clr RI
	jnb RI, $
	mov P2, SBUF

	clr TI
	mov SBUF, P2
	jnb TI, $
	sjmp mainloop
	
end
