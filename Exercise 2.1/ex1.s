.text
.global main
.extern scanf
.extern printf
.extern malloc
.extern free

scan:		/* returns in r1 the user input || changes r0 */
  stmfd sp!, {ip, lr}
  ldr r0, =inp_string
  sub sp, sp, #4
  mov r1, sp
  bl scanf
  ldr r1, [sp, #0]
  add sp, sp, #4
  ldmfd sp!, {ip, lr}
  bx lr

print_s:
  stmfd sp!, {r1-r3, ip, lr}
  bl printf
  ldmfd sp!, {r1-r3, ip, lr}
  bx lr

print_list:		/* gets head of list in r0 || changes r0-r3 */
  stmfd sp!, {ip, lr}
  mov r3, r0
  mov r1, #0
  pr_loop:
    tst r3, r3		/* check if we are at the end of list */
    beq pr_cnt
    ldr r2, [r3]
    ldr r0, =print_int_string
    bl print_s
    ldr r3, [r3, #4]
    add r1, r1, #1
    b pr_loop
  pr_cnt:
    ldmfd sp!, {ip, lr}
    bx lr

insert_node:	/* gets head in r0,r5 and input in r1 || changes r0-r3 */
  stmfd sp!, {r0, r1, ip, lr}
  mov r0, #8
  bl malloc
  ldmfd sp!, {r2, r3, ip, lr}
  str r3, [r0]		/* integer in first 4 bytes */
  mov r1, r2	/* r2 is curr, r1 is prev, r3 is input, r0 is new node */
  stmfd sp!, {r4, ip, lr}
  ins_loop:
    tst r2, r2	/* check if we are at the end of list */
    beq tail
    ldr r4, [r2]
    cmp r3, r4
    bge ins_node	/* check if we should insert node */
    mov r1, r2
    ldr r2, [r2, #4]
    b ins_loop
  ins_node:
    cmp r2, r5		/* check if we insert in the start of the list */
    beq head
    str r0, [r1, #4]
    str r2, [r0, #4]
    mov r0, r5		/* output r0 as the head of list */
    b ins_cnt
  head:
    str r2, [r0, #4]
    b ins_cnt
  tail:
    mov r2, #0
    str r2, [r0, #4]
    cmp r1, #0		/* check if it is the first element inserted */
    beq ins_cnt
    str r0, [r1, #4]
    mov r0, r5
    b ins_cnt
  ins_cnt:
    ldmfd sp!, {r4, ip, lr}
    bx lr

remove_node:	/* gets input index in r1, head in r0 || changes r0-r3 */
  stmfd sp!, {r0, r4, ip, lr}
  mov r2, r0	/* r2 holds curr */
  mov r3, r0	/* r3 holds prev */
  mov r4, #0	/* r4 holds index counter */
  rm_loop:
    tst r2, r2	/* check if we are at the end of list */
    beq rm_cnt
    cmp r4, r1	/* check if we found our node */
    beq rm_node
    mov r3, r2
    ldr r2, [r2, #4]
    add r4, r4, #1
    b rm_loop
  rm_node:
    ldr r4, [r2, #4]
    cmp r2, r0		/* check if we delete the head */
    streq r4, [sp]	/* if so, update r0 in stack */
    strne r4, [r3, #4]	/* or else update prev's pointer */
    mov r0, r2
    bl free		/* free changes r0 also */
  rm_cnt:
    ldmfd sp!, {r0, r4, ip, lr}
    bx lr

main:
  sub sp, sp, #4
  str lr, [sp, #0]
  ldr r0, =hello_string
  bl print_s
  mov r5, #0	/* initialize list pointer */
  b input

input:
  bl scan
  cmp r1, #0		/* check in input is negative */
  blt main_cnt
  mov r0, r5
  bl insert_node
  mov r5, r0		/* r5 is the constant head of the list */
  b input

main_cnt:
  ldr r0, = del_string
  bl print_s
  mov r0, r5
  bl print_list
  b del

del:
  ldr r0, =begin_del
  bl print_s
  bl scan
  cmp r1, #0	/* check if negative in order to exit */
  blt exit
  mov r0, r5
  bl remove_node
  mov r5, r0
  tst r5, r5	/* check if list has been emptied */
  beq exit
  ldr r0, =new_list
  bl print_s
  mov r0, r5
  bl print_list
  b del

exit:
  ldr lr, [sp, #0]
  add sp, sp, #4
  mov pc, lr

.data
  hello_string: .asciz "Give positive numbers to insert to the list or a negative to stop:\n"
  del_string: .asciz "The elements in the list are (id. number):\n"
  begin_del: .asciz "Give an id to delete from the list or a negative number to terminate the program:\n"
  new_list: .asciz "The renewed list is:\n"
  inp_string: .asciz "%d"
  print_int_string: .asciz "%d. %d\n"
