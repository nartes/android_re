# 1 "src/helpers/strcopy.S"
# 1 "<built-in>"
# 1 "<command-line>"
# 31 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 32 "<command-line>" 2
# 1 "src/helpers/strcopy.S"
 .text
 .globl _start
_start:
 ldr r1, =srcstr
 ldr r0, =dststr
 bl strcopy
stop:
 mov r0, #0x18
 ldr r1, =0x20026
 # what's here?
strcopy:
 ldrb r2, [r1], #1
 strb r2, [r0], #1
 cmp r2, #0
 bne strcopy
 mov pc, lr

 .data
srcstr:
 .asciz "First string - source"
dststr:
 .asciz "Second string - destination"
