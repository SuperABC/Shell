j main

main:
lui $a0, 0xf000 # address of switch and btn
lui $a1, 0x000c # begin addr of vram
ori $a2, $a1, 4800 # end addr of vram
lui $a3, 0xe000 # address of 7 seg
lui $t8, 0xffff # address of ps2
ori $t8, $t8, 0xd000 # address of ps2
sw $zero, 0($a3)

initial:
lw $t0, 0($a0) # state of switch
andi $t0, $t0, 1 # state of switch[0]
beq $t0, $zero, start_background # load background when switch[0] == 0

# t0 is used to sw ascii
# t1 is used to record the begining of a line
# t2 is used to record the cursor
shell_start:
add $t0, $zero, $a1
shell_clear:
addi $t1, $zero, 0x000
sw $t1, 0($t0)
addi $t0, $t0, 1
bne $t0, $a2, shell_clear # clear the screen
addi $t0, $zero, 0x53
sw $t0, 0($a1)
addi $t0, $zero, 0x47
sw $t0, 1($a1)
addi $t0, $zero, 0x20
sw $t0, 2($a1)
addi $t0, $zero, 0x63
sw $t0, 3($a1)
addi $t0, $zero, 0x6D
sw $t0, 4($a1)
addi $t0, $zero, 0x64
sw $t0, 5($a1)
addi $t0, $zero, 0x3E
sw $t0, 6($a1)
addi $t0, $zero, 0x16
sw $t0, 7($a1)
add $t2, $zero, $a1
addi $t2, $t2, 7
add $t1, $zero, $t2
shell_loop:
lw $t0, 0($t8)
beq $t0, $t9, shell_loop
add $t9, $zero, $t0 # read new ascii
add $t0, $zero, $zero
addi $t0, $zero, 0x00FF
and $t0, $t0, $t9
sw $t0, 0($a3)
beq $t0, $zero, shell_loop
addi $t4, $zero, 0x08
beq $t0, $t4, key_back
addi $t4, $zero, 0x0D
beq $t0, $t4, key_enter
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t3, $zero, 0x16
sw $t3, 0($t2)
addi $t4, $t1, 1
beq $t2, $t4, letter1
addi $t4, $t1, 2
beq $t2, $t4, letter2
addi $t4, $t1, 3
beq $t2, $t4, letter3
addi $t4, $t1, 4
beq $t2, $t4, letter4
addi $t4, $t1, 5
beq $t2, $t4, letter5
addi $t4, $t1, 6
beq $t2, $t4, letter6
addi $t4, $t1, 7
beq $t2, $t4, letter7
addi $t4, $t1, 8
beq $t2, $t4, letter8

lw $t0, 0($a0) # state of switch
andi $t0, $t0, 1 # state of switch[0]
bne $t0, $zero, shell_loop # load back ground when switch[0] == 0


start_background:
add $t0, $zero, $a1
loop:
addi $t1, $zero, 0x000
sw $t1, 0($t0)
addi $t0, $t0, 1

bne $t0, $a2, loop

lw $t0, 0($a0) # state of switch
andi $t0, $t0, 1 # state of switch[0]
beq $t0, $zero, start_background # load back ground when switch[0] == 0
j shell_start

key_enter:
sw $zero, 0($t2)
addi $t3, $zero, 0x63 # c
addi $t4, $zero, 0x6C # l
addi $t5, $zero, 0x72 # r
add $t0, $zero, $s0
beq $t0, $t3, inst_c
j not_clr
inst_c:
add $t0, $zero, $s1
beq $t0, $t4, inst_cl
j not_clr
inst_cl:
add $t0, $zero, $s2
beq $t0, $t5, inst_clr
j not_clr
inst_clr:
addi $t0, $t1, 3
bne $t2, $t0, not_clr
j shell_start
# clr is to clear the shell
not_clr:
addi $t3, $zero, 0x64 # d
addi $t4, $zero, 0x72 # r
addi $t5, $zero, 0x61 # a
addi $t6, $zero, 0x77 # w
add $t0, $zero, $s0
beq $t0, $t3, inst_d
j not_draw
inst_d:
add $t0, $zero, $s1
beq $t0, $t4, inst_dr
j not_draw
inst_dr:
add $t0, $zero, $s2
beq $t0, $t5, inst_dra
j not_draw
inst_dra:
add $t0, $zero, $s3
beq $t0, $t6, inst_draw
j not_draw
inst_draw:
addi $t0, $t1, 4
bne $t2, $t0, not_draw
j game_draw
# draw is to move and put dot
not_draw:
addi $t3, $zero, 0x76 # v
addi $t4, $zero, 0x65 # e
addi $t5, $zero, 0x72 # r
add $t0, $zero, $s0
beq $t0, $t3, inst_v
j not_ver
inst_v:
add $t0, $zero, $s1
beq $t0, $t4, inst_ve
j not_ver
inst_ve:
add $t0, $zero, $s2
beq $t0, $t5, inst_ver
j not_ver
inst_ver:
addi $t0, $t1, 3
bne $t2, $t0, not_ver
j print_ver
# ver is to show the version
not_ver:
addi $t3, $zero, 0x68 # h
addi $t4, $zero, 0x69 # i
addi $t5, $zero, 0x64 # d
addi $t6, $zero, 0x65 # e
add $t0, $zero, $s0
beq $t0, $t3, inst_h
j no_inst
inst_h:
add $t0, $zero, $s1
beq $t0, $t4, inst_hi
j no_inst
inst_hi:
add $t0, $zero, $s2
beq $t0, $t5, inst_hid
j no_inst
inst_hid:
add $t0, $zero, $s3
beq $t0, $t6, inst_hide
j no_inst
inst_hide:
addi $t0, $t1, 4
bne $t2, $t0, no_inst
j game_hide
# hide is a game

no_inst:
addi $t1, $t1, 80
addi $t2, $t1, -7
addi $t0, $zero, 0x43
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x61
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x6E
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x20
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x6E
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x6F
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x74
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x20
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x66
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x69
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x6E
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x64
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x20
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x74
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x68
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x69
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x73
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x20
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x63
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x6D
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x64
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x21
sw $t0, 0($t2)
addi $t1, $t1, 160
addi $t2, $t1, -7
addi $t0, $zero, 0x53
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x47
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x20
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x63
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x6D
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x64
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x3E
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x16
sw $t0, 0($t2)
j shell_loop

key_back:
beq $t2, $t1, shell_loop
add $t0, $zero, $zero
sw $t0, 0($t2)
addi $t4, $zero, 1
sub $t2, $t2, $t4
addi $t0, $zero, 0x16
sw $t0, 0($t2)
j shell_loop

# save input into registers
letter1:
add $s0, $zero, $t0
j shell_loop
letter2:
add $s1, $zero, $t0
j shell_loop
letter3:
add $s2, $zero, $t0
j shell_loop
letter4:
add $s3, $zero, $t0
j shell_loop
letter5:
add $s4, $zero, $t0
j shell_loop
letter6:
add $s5, $zero, $t0
j shell_loop
letter7:
add $s6, $zero, $t0
j shell_loop
letter8:
add $s7, $zero, $t0
j shell_loop


game_draw:
add $t0, $zero, $a1
draw_clear:
addi $t1, $zero, 0x000
sw $t1, 0($t0)
addi $t0, $t0, 1
bne $t0, $a2, draw_clear # clear the screen

addi $t0, $zero, 0x7F
sw $t0, 0($t2)
draw_loop:
addi $t0, $zero, 0x7F
sw $t0, 0($t2)
lw $t1, 0($t8)
beq $t1, $t9, draw_loop
add $t9, $zero, $t1 # read new ascii
addi $t1, $zero, 0x00FF
and $t1, $t1, $t9
sw $t1, 0($a3)
beq $t1, $zero, draw_loop # t1 is the temp key

add $t0, $zero, $zero
addi $t3, $zero, 0x77
beq $t1, $t3, move_up
addi $t3, $zero, 0x73
beq $t1, $t3, move_down
addi $t3, $zero, 0x64
beq $t1, $t3, move_right
addi $t3, $zero, 0x61
beq $t1, $t3, move_left
addi $t3, $zero, 0x0D
beq $t1, $t3, put_dot
addi $t3, $zero, 0x71
beq $t1, $t3, shell_start
j draw_loop
move_up:
sw $t0, 0($t2)
addi $t2, $t2, -80
j draw_loop
move_down:
sw $t0, 0($t2)
addi $t2, $t2, 80
j draw_loop
move_left:
sw $t0, 0($t2)
addi $t2, $t2, -1
j draw_loop
move_right:
sw $t0, 0($t2)
addi $t2, $t2, 1
j draw_loop
put_dot:
addi $t0, $zero, 0x7F
sw $t0, 0($t2)
addi $t2, $t2, 1
j draw_loop

game_hide:
add $t0, $zero, $a1
hide_clear:
addi $t1, $zero, 0x000
sw $t1, 0($t0)
addi $t0, $t0, 1
bne $t0, $a2, hide_clear # clear the screen
addi $t0, $zero, 0x7F
addi $t7, $a1, 4720 # t7 is the player position
sw $t0, 0($t7)
sw $t0, 1($t7)
sw $t0, 2($t7)
sw $t0, 3($t7)
sw $t0, 4($t7)
sw $t0, 5($t7)
sw $t0, 6($t7)
sw $t0, 7($t7)
sw $t0, 8($t7)
sw $t0, 9($t7)
sw $t0, 10($t7)
sw $t0, 11($t7)
sw $t0, 12($t7)
sw $t0, 13($t7)
sw $t0, 14($t7)
sw $t0, 15($t7)
addi $t2, $a1, 10
addi $t3, $a1, 4030
addi $t4, $a1, 2530
addi $t5, $a1, 1990
hide_loop:
jal delay_100ms
sw $zero, 0($t2)
addi $t2, $t2, 80
addi $t6, $a1, 4810
bne $t2, $t6, fall_1
addi $t2, $a1, 10
fall_1:
sw $t0, 0($t2)
sw $zero, 0($t3)
addi $t3, $t3, 80
addi $t6, $a1, 4830
bne $t2, $t6, fall_2
addi $t2, $a1, 30
fall_2:
sw $t0, 0($t3)
sw $zero, 0($t4)
addi $t4, $t4, 80
addi $t6, $a1, 4850
bne $t2, $t6, fall_3
addi $t2, $a1, 50
fall_3:
sw $t0, 0($t4)
sw $zero, 0($t5)
addi $t5, $t5, 80
addi $t6, $a1, 4870
bne $t2, $t6, fall_4
addi $t2, $a1, 70
fall_4:
sw $t0, 0($t5) # fall
lw $t1, 0($t8)
beq $t1, $t9, hide_loop
add $t9, $zero, $t1 # read new ascii
addi $t1, $zero, 0x00FF
and $t1, $t1, $t9
sw $t1, 0($a3)
beq $t1, $zero, hide_loop # t1 is the temp key
addi $t6, $zero, 0x64
beq $t1, $t6, hide_right
addi $t6, $zero, 0x61
beq $t1, $t6, hide_left
addi $t6, $zero, 0x71
beq $t1, $t6, shell_start
j hide_loop
hide_right:
addi $t6, $a1, 4792
beq $t7, $t6, hide_loop
sw $zero, 0($t7)
sw $zero, 1($t7)
addi $t7, $t7, 2
sw $t0, 14($t7)
sw $t0, 15($t7)
j hide_loop
hide_left:
addi $t6, $a1, 4720
beq $t7, $t6, hide_loop
sw $zero, 14($t7)
sw $zero, 15($t7)
addi $t7, $t7, -2
sw $t0, 0($t7)
sw $t0, 1($t7)
j hide_loop

print_ver:
addi $t1, $t1, 80
addi $t2, $t1, -7
addi $t0, $zero, 0x53 # S
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x47 # G
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x20
sw $t0, 0($t2)
addi $t2, $t2, 1
jal delay_100ms
addi $t0, $zero, 0x63 # c
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x6D # m
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x64 # d
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x20
sw $t0, 0($t2)
addi $t2, $t2, 1
jal delay_100ms
addi $t0, $zero, 0x76 # v
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x30 # 0
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x2E # .
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x30 # 0
sw $t0, 0($t2)
addi $t1, $t1, 80
addi $t2, $t1, -7
jal delay_100ms
addi $t0, $zero, 0x50 # P
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x6F # o
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x77 # w
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x65 # e
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x72 # r
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x65 # e
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x64 # d
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x20
sw $t0, 0($t2)
addi $t2, $t2, 1
jal delay_100ms
addi $t0, $zero, 0x62 # b
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x79 # y
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x20
sw $t0, 0($t2)
addi $t2, $t2, 1
jal delay_100ms
addi $t0, $zero, 0x53 # S
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x47 # G
sw $t0, 0($t2)
addi $t1, $t1, 80
addi $t2, $t1, -7
jal delay_100ms
addi $t0, $zero, 0x41 # A
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x6C # l
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x6C # l
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x20
sw $t0, 0($t2)
addi $t2, $t2, 1
jal delay_100ms
addi $t0, $zero, 0x72 # r
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x69 # i
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x67 # g
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x68 # h
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x74 # t
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x73 # s
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x20
sw $t0, 0($t2)
addi $t2, $t2, 1
jal delay_100ms
addi $t0, $zero, 0x72 # r
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x65 # e
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x73 # s
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x65 # e
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x72 # r
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x76 # v
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x65 # e
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x64 # d
sw $t0, 0($t2)
jal delay_100ms
addi $t1, $t1, 160
addi $t2, $t1, -7
addi $t0, $zero, 0x53
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x47
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x20
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x63
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x6D
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x64
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x3E
sw $t0, 0($t2)
addi $t2, $t2, 1
addi $t0, $zero, 0x16
sw $t0, 0($t2)
j shell_loop

delay_100ms:
add $v1, $zero, $zero
delay_loop:
addi $v1, $v1, 0x8000
bne $v1, $zero, delay_loop
jr $ra