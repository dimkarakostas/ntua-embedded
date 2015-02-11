.text
.align 4

.global strlen
.type strlen, %function
strlen:
  stmfd sp!, {ip, lr}
  mov r1, #0	/* r1 holds string length */
  strlen_loop:
    ldrb r2, [r0], #1
    tst r2, r2		/* check if end of string */
    beq strlen_cnt
    add r1, r1, #1
    b strlen_loop
  strlen_cnt:
    mov r0, r1	/* return length in r0 */
    ldmfd sp!, {ip, lr}
    bx lr

.global strcpy
.type strcpy, %function
strcpy:
  stmfd sp!, {ip, lr}
  strcpy_loop:
    ldrb r2, [r1], #1	/* read from source */
    strb r2, [r0], #1	/* write in destination */
    tst r2, r2
    bne strcpy_loop
  ldmfd sp!, {ip, lr}
  bx lr

.global strcat
.type strcat, %function
strcat:
  stmfd sp!, {ip, lr}
  mov r3, r0	/* save head of destination string */
  strcat_read_loop:
    ldrb r2, [r0], #1	/* find destination string */
    tst r2, r2
    bne strcat_read_loop
  strcat_write_loop:	/* copy string from source to (end of) destination */
    ldrb r2, [r1], #1
    strb r2, [r0], #1
    tst r2, r2
    bne strcat_write_loop
  mov r0, r3	/* return head of destination string in r0 */
  ldmfd sp!, {ip, lr}
  bx lr

.global strcmp
.type strcmp, %function
strcmp:
  stmfd sp!, {ip, lr}
  strcmp_loop:
    ldrb r2, [r0], #1
    ldrb r3, [r1], #1
    cmp r2, r3
    beq strcmp_loop
    bgt strcmp_greater	/* if first string < second string return -1 */
    blt strcmp_less	/* if first string > second string return 1 */
    mov r0, #0	/* if equal return 0 */
    b strcmp_cnt
  strcmp_greater:
    mov r0, #-1
    b strcmp_cnt
  strcmp_less:
    mov r0, #1
    b strcmp_cnt
  strcmp_cnt:
    ldmfd sp!, {ip, lr}
    bx lr
