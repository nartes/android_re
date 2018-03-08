	.text
	.globl _start
_start:
	ldr	r1, =srcstr
	ldr	r0, =dststr
	bl strcopy
stop:
	mov	r0, #0x18
	ldr	r1, =0x20026
	# what's here?
strcopy:
	ldrb	r2, [r1], #1
	strb	r2, [r0], #1
	cmp	r2, #0
	bne	strcopy
	mov	pc, lr

	.data
srcstr:
	.asciz "First string - source"
dststr:
	.asciz "Second string - destination"
	
/*
	AREA StrCopy, CODE, READONLY
	ENTRY
start
	LDR	r1, =srcstr
	LDR	r0, =dststr
	BL	strcopy
stop
	MOV	r0, #0x18
	LDR	r1, =0x20026
	SVC	#0x123456
strcopy
	LDRB	r2, [r1],#1
	STRB	r2, [r0],#1
	CMP	r2, #0
	BNE	strcopy
	MOV	pc,lr
	AREA	Strings, DATA, READWRITE
srcstr	DCB	"First string - source",0
dststr	DCB	"Second string - destination",0
	END
*/
