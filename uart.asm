org 0
	mov scon, #01010000b
	mov tmod, #00100000b

	mov th1, #0fah
	setb tr1

petla:
	clr RI
	jnb RI, $
	mov P2, SBUF

	clr TI
	mov SBUF, #5Dh
	jnb TI, $
	sjmp petla


end
