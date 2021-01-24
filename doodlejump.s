 ##############################################################
 #CSC258H5S Fall 2020 Assembly Final Project
 # University of Toronto, St. George
 #
 #Student: Xiao Sun, Student Number:1005074250
 #
 #Bitmap Display Configuration:
 #- Unit width in pixels: 8
 #- Unit height in pixels: 8
 # - Display width in pixels: 256
 # - Display height in pixels: 256
 # - Base Address for Display: 0x10008000 ($gp)
 # - Milestone 1,2,3,4,5 (choose the one the applies)
 # For milestone4, when the doodler hit the ground, the screen will become red and waiting the player to press any key to replay,
 #	when the player reached 8 highest platform, the screen will become yellow, which means success
 #	everytime the player reaches a highest platform, the speed of the game will speed up
 # For milestone5, there are two doodlers one in color 0xeba487, one in color 0xcc4466. 
 # 	The first one is controlled by j and k, j to left, k to right, the second one is controlled by h and l.
 #	There are three type of platform. One is normal platform, which in color 0x879ceb
 #	The second one is breakable platform, which will be breaked from the bottom of the platform, show in color 0x821abc
 #	The third one is harmful platform, which will speed up the game(increase the difficulty, which is a part of realisitc physics) and make the dooler lost health. 
 #	When dooler reach the harmful platform from the bottom, he will be hurt and knock down and there will be a mark to tell the user. 
 ################################################################
.data
	displayAddress:	.word 0x10008000
	end: .word 0x1009000
	platform: .word 0x879ceb
.text 
start1:
	lw $t0, displayAddress
	li $t1, 0x879ceb  #color of normal platform
	li $t2, 0xeba487  #color of Doodler1
	li $k1, 0xcc4466 #color of Dooler2
	li $t3, 0x87ceeb  #color of sky
	li $t4, 0xa67700 #color of ground
	li $t6, 0x879ceb 
	li $s0, 0x879ceb 
	li $t7, 120 #speed
	li $s7, 0 #score
	j start0
changecolor:
	li $t6, 0x821abc #breakable platform
	li $s0, 0x38464b #harmful platform
	addi $a0, $a0, 1
	addi $s7, $s7, 1
	addi $t7, $t7, -10
	beq $s7, 3, success
start0:
	li $t3, 0x87ceeb  #color of sky
	addi $s2, $t0, 0	#start positon of background
	addi $s3, $t0, 3968	#end position of background
	j random_gen


redraw:	
	addi $s4, $t0, 1280	#first platform start point
	addi $a2, $0, 8
	j loop1
loop1:
	beq $a2,$0,done1
	add $s4,$s4,$a0
	addi $a2,$a2,-1
	j loop1
done1:
	addi $a2, $0, 16
	addi $s5, $s4, 768
	addi $a0, $a0, 0
	j loop2
loop2:
	beq $a2,$0,done2
	add $s5,$s5,$a0
	addi $s5,$s5,1
	addi $a2,$a2,-1
	j loop2
	
done2:
	addi $a2,$0,16
	addi $s6, $s5, 512
	addi $a0, $a0, -1
	j loop3
	
loop3:
	beq $a2,$0,done3
	add $s6,$s6,$a0
	addi $s6,$s6,2
	addi $a2,$a2,-1
	j loop3
done3:
	addi $s1, $s6, -256 #start positon of Doodler
	addi $v1, $s6, -224
	j background
background:

	beq $s2, $s3, border #platform_count
	sw $t3, 0($s2)
	addi $s2, $s2, 4
	j background	
border:
	addi $s3, $t0, 4096
	beq $s2, $s3, platform_count
	sw $t4, 0($s2)
	addi $s2, $s2, 4
	j border	


platform_count:
	addi $t5, $zero,0
platform_init:
	addi $s2, $zero, 0
	addi $s3, $zero, 64
	addi $t5, $t5, 1
	beq $t5, 1, platform_1
	beq $t5, 2, platform_2
	beq $t5, 3, platform_3
	j press_s
platform_1:
	beq $s2, $s3, platform_init #this platform finished
	sw $s0, 0($s4)
	addi $s4, $s4, 4
	addi $s2, $s2, 4
	j platform_1

platform_2:
	beq $s2, $s3, platform_init #this platform finished
	sw $t6, 0($s5)
	addi $s5, $s5, 4
	addi $s2, $s2, 4
	j platform_2
platform_3:
	beq $s2, $s3, platform_init #this platform finished
	sw $t1, 0($s6)
	addi $s6, $s6, 4
	addi $s2, $s2, 4
	j platform_3


press_s:

	bge $s7, 1, Listener_loop
	lw $t8, 0xffff0000
	beq $t8, 1, start
	li $v0, 32
	addi $a0, $t7,100
	syscall 
	j press_s
	
start:
	lw $t5, 0xffff0004
	beq $t5, 0x00000073, Listener_loop
	li $v0, 32
	addi $a0, $t7, 100
	syscall 
	j start
Listener_loop:
	lw $t8, 0xffff0000
	beq $t8, 1, keyboard_input
	lw $t9, 128($s1)
	beq $t9, 0xa67700, Exit
	beq $t9, 0x821abc, jump_up
	beq $t9, $t1, jump_up #there is a platform under the dooder
	beq $t9, 0x38464b, jump_up
	lw $t9, 128($v1)
	beq $t9, 0xa67700, Exit
	beq $t9, 0x821abc, jump_up1
	beq $t9, $t1, jump_up1 #there is a platform under the dooder
	beq $t9, 0x38464b, jump_up1
	sw $t2, 128($s1)
	sw $k1, 128($v1)
	sw $t3, 0($s1)
	sw $t3, 0($v1)
	addi $s1,$s1,128    #drop down one line
	addi $v1,$v1,128    #drop down one line
	li $v0, 32
	add $a0, $t7, $t7  
	syscall
	j Listener_loop

jump_up:
	addi $a2, $zero, 7
loop4:
	beq $a2,$0,done4
	lw $t9, -128($s1)
	beq $t9, 0x879ceb, add1
	beq $t9, 0x38464b, add4
	sw $t3, 0($s1)
	sw $t2, -128($s1)
	addi $s1,$s1,-128
	li $v0, 32
	addi $a0, $zero, 30  
	syscall 
	addi $a2, $a2, -1
	addi $s5, $s4, -1024
	ble $s1, $s5, changecolor #achieved hight platform
	j loop4

jump_up1:
	addi $a2, $zero, 7
loop41:
	beq $a2,$0,done4
	lw $t9, -128($v1)
	beq $t9, 0x879ceb, add11
	beq $t9, 0x38464b, add41
	sw $t3, 0($v1)
	sw $k1, -128($v1)
	addi $v1,$v1,-128
	li $v0, 32
	addi $a0, $zero, 30  
	syscall 
	addi $a2, $a2, -1
	addi $s5, $s4, -1024
	ble $v1, $s5, changecolor #achieved hight platform
	j loop41

add1:	
	sw $t3, 0($s1)
	sw $t2, -256($s1)
	addi $s1,$s1,-256
	j loop4
add11:
	sw $t3, 0($v1)
	sw $k1, -256($v1)
	addi $v1,$v1,-256
	j loop4
add4:
	addi $t7, $t7, -5
	beq $t7,0,Exit
	li $v0, 0x38464b
	sw $v0, -128($s1)
	sw $t3, 0($s1)
	sw $t2, 512($s1)
	addi $s1,$s1,256

	j loop4 
add41:
	beq $t7,0,Exit
	addi $t7, $t7, -5
	li $v0, 0x38464b
	sw $v0, -128($v1)
	sw $t3, 0($v1)
	sw $k1, 512($v1)
	addi $v1,$v1,256

	j loop4

done4:	
	j Listener_loop	
keyboard_input:
	lw $t5, 0xffff0004 #listener of keyboard input
	beq $t5, 0x0000006a, respond_to_j
	beq $t5, 0x0000006b, respond_to_k
	beq $t5, 0x00000068, respond_to_h
	beq $t5, 0x0000006c, respond_to_l
	j Listener_loop	

respond_to_j:
	lw $t9, -4($s1)
	beq $t9, 0x879ceb, add2 #check if the left of the doodler is a platform
	sw $t2, -4($s1)
	sw $t3, 0($s1)
	addi $s1, $s1, -4
	j Listener_loop
add2:
	sw $t3, 0($s1)
	sw $t2, -128($s1)
	addi $s1,$s1,-128
	j respond_to_j
respond_to_k:
	lw $t9, 4($s1)
	beq $t9, 0x879ceb, add3 #check if the left of the doodler is a platform
	sw $t2, 4($s1)
	sw $t3, 0($s1)
	addi $s1, $s1, 4
	j Listener_loop
add3:
	sw $t3, 0($s1)
	sw $t2, -128($s1)
	addi $s1,$s1,-128
	j respond_to_k
respond_to_h:
	lw $t9, -4($v1)
	beq $t9, 0x879ceb, add21 #check if the left of the doodler is a platform
	sw $k1, -4($v1)
	sw $t3, 0($v1)
	addi $v1, $v1, -4
	j Listener_loop
add21:
	sw $t3, 0($v1)
	sw $k1, -128($v1)
	addi $v1,$v1,-128
	j respond_to_j
	
respond_to_l:
	lw $t9, 4($v1)
	beq $t9, 0x879ceb, add31 #check if the left of the doodler is a platform
	sw $k1, 4($v1)
	sw $t3, 0($v1)
	addi $v1, $v1, 4
	j Listener_loop
add31:
	sw $t3, 0($v1)
	sw $k1, -128($v1)
	addi $v1,$v1,-128
	j respond_to_k
random_gen:
	li $v0, 42
	li $a0, 0
	li $a1, 5
	syscall
	j redraw
Exit:
	addi $s2, $t0, 0	#start positon of background
	addi $s3, $t0, 3968	#end position of background
	li $t3, 0xdd2c00
	j background1

background1:
	beq $s2, $s3, listener1 #platform_count
	sw $t3, 0($s2)
	addi $s2, $s2, 4
	j background1
listener1:
	lw $t8, 0xffff0000
	beq $t8, 1, start1
	li $v0, 32
	addi $a0, $t7,100
	syscall 
	j listener1
end1:	
	li $v0, 10
	syscall

setcolor:
	li $t6, 0x821abc
	j redraw

success:
	addi $s2, $t0, 0	#start positon of background
	addi $s3, $t0, 3968	#end position of background
	li $t3, 0xe8de2a
	j background2
background2:
	beq $s2, $s3, listener1 #platform_count
	sw $t3, 0($s2)
	addi $s2, $s2, 4
	j background2
