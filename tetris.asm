 ;; game state memory location
  .equ T_X, 0x1000                  ; falling tetrominoe position on x
  .equ T_Y, 0x1004                  ; falling tetrominoe position on y
  .equ T_type, 0x1008               ; falling tetrominoe type
  .equ T_orientation, 0x100C        ; falling tetrominoe orientation
  .equ SCORE,  0x1010               ; score
  .equ GSA, 0x1014                  ; Game State Array starting address
  .equ SEVEN_SEGS, 0x1198           ; 7-segment display addresses
  .equ LEDS, 0x2000                 ; LED address
  .equ RANDOM_NUM, 0x2010           ; Random number generator address
  .equ BUTTONS, 0x2030              ; Buttons addresses

  ;; type enumeration
  .equ C, 0x00
  .equ B, 0x01
  .equ T, 0x02
  .equ S, 0x03
  .equ L, 0x04

  ;; GSA type
  .equ NOTHING, 0x0
  .equ PLACED, 0x1
  .equ FALLING, 0x2

  ;; orientation enumeration
  .equ N, 0
  .equ E, 1
  .equ So, 2
  .equ W, 3
  .equ ORIENTATION_END, 4

  ;; collision boundaries
  .equ COL_X, 4
  .equ COL_Y, 3

  ;; Rotation enumeration
  .equ CLOCKWISE, 0
  .equ COUNTERCLOCKWISE, 1

  ;; Button enumeration
  .equ moveL, 0x01
  .equ rotL, 0x02
  .equ reset, 0x04
  .equ rotR, 0x08
  .equ moveR, 0x10
  .equ moveD, 0x20

  ;; Collision return ENUM
  .equ W_COL, 0
  .equ E_COL, 1
  .equ So_COL, 2
  .equ OVERLAP, 3
  .equ NONE, 4

  ;; start location
  .equ START_X, 6
  .equ START_Y, 1

  ;; game rate of tetrominoe falling down (in terms of game loop iteration)
  .equ RATE, 5

  ;; standard limits
  .equ X_LIMIT, 12
  .equ Y_LIMIT, 8



######################################################################33


#Testing code:
call main

; BEGIN:clear_leds
clear_leds:
#sets all bits in the LEDS aray to 0
add t0, zero, zero
stw t0, LEDS(zero)
stw t0, LEDS+4(zero)
stw t0, LEDS+8(zero)
ret
; END:clear_leds




; BEGIN:set_pixel
set_pixel:
#sets the pixels in the LEDs
#
#cmplti t0, a0, 3 
#bne t0, zero, LED2
#cmplti t0, a0, 7 
#bne t0, zero, LED3

#LED1 
#SHIFT NUM
#addi t0, zero, SHIFT #"4"
#mul t0, a1, t0
#add t0, t0, a0

#LED2: 
#SHIFT NUM
#addi t0, zero, SHIFT #"4"
#mul t0, a1, t0
#addi a0, a0, -SHIFT
#add t0, t0, a0

#LED3: 
#SHIFT NUM
#shifting: 

#Mask
andi t0, a0, 0x0C #grab the siginificant digits (i.e 0,4,8)

#determine the shift
andi t1, a0, 0x3 #get last 2 digits (modulus 4) 
#addi t2, zero, 8 # add 8 to reg
#mul t2, t2, t1 #multiply 8 * x mod 4
slli t2, t1, 3
add t2, a1, t2 # add y value 

#Or statement
addi t3, zero, 1 # initialize 1
sll t3, t3, t2 #shift 1 by function above
ldw t4, LEDS(t0) # grab data from register 
or t4, t4, t3 # preform or on the register and the shifted value
stw t4, LEDS(t0) #store the register back 
ret
; END:set_pixel




; BEGIN:wait
wait:
addi t0, zero, 0x1
slli t0, t0, 20

WaitLoop:
addi t0, t0, -1
bne t0, zero, WaitLoop
ret
; END:wait




; BEGIN:in_gsa
in_gsa:
cmpgei t5, a0, 0 #greater than 0?
cmplti t6, a0,12 #less than 12
and t5, t5, t6 # check if x is both greater than 0 AND less than 12
cmpgei t6, a1, 0 # y is greater than 0
cmplti t7, a1, 8 # y is less than 8
and t6, t6, t7 # check if y is both greater than 0 AND less than 8
and v0, t5, t6 # check if both x and y are true 
xori v0, v0, 1
ret
; END:in_gsa




; BEGIN:get_gsa
get_gsa:
#addi t1, zero,8 #set 8 as the multiple
#mul t1, t1, a0 #multiply by x
slli t7, a0, 3
add t7, t7, a1 # add y
slli t7, t7, 2
ldw v0, GSA(t7) #return the GSA 
ret
; END:get_gsa




; BEGIN:set_gsa
set_gsa:
#addi t1, zero,8 #set 8 as the multiple
#mul t1, t1, a0 #multiply by x
slli t1, a0, 3
add t1, t1, a1 # add y
slli t1, t1, 2
stw a2, GSA(t1) #store the a2 value into the GSA 
ret
; END:set_gsa




; BEGIN:draw_gsa
draw_gsa:
addi sp, sp, -4
stw ra, 0(sp)
# This code is a good start but is inefficent 
#clear board 
#addi a0, zero, 0 #initalize variables 
#addi a1, zero, 0
#loop: 
#	addi a0, zero, 0  #reset variable
#	loop2: 
#		call get_gsa  #get the LED status of choice
#		bne v0, zero, end 
#		set_pixel
#
#		#a0<11, loop , a0+1
#		end:
#		cmpgei t0, a0, 11
#		addi a0, a0, 1
#		bne t0, zero, loop2
#	#a1<7 loop 
#	cmpgei t1, a1, 7
#	addi a1, a1, 1
#	bne t1, zero, loop
addi t3, zero, 0
addi t0, zero, 0 #intialize counter
addi t4,zero, 1
addi t7, zero, 96 #end counter

loop:
slli t0, t0, 2
ldw t2, GSA(t0) # pull data from GSA
srli t0, t0, 2
call rotate #check the values and rotate
call loadfunction #checks if its time to load values in LEDS
addi t0,t0, 1 #increment counter by 1
bne t0, t7, loop #if it hasnt reached 95, restart
ldw ra, 0(sp)
addi sp, sp, 4
ret

rotate:
bne t2, zero, addOne #if t2 is not 0, we need to add 1
ror t3,t3,t4 # otherwise we just rotate
ret

addOne:
addi t3,t3,1 # add one
ror t3,t3, t4	# rotate
ret

loadfunction:
# if 31, 63, 95 it is time to load
# set the register value and call load fcn
addi t5, zero, 31
addi t6, zero, 0
beq t0, t5, load

addi t5, zero, 63
addi t6, zero, 4
beq t5, t0, load

addi t5, zero, 95
addi t6, zero, 8
beq t5, t0, load
ret

load: 
stw t3, LEDS(t6) # store word to LED
addi t3, zero, 0 #reset t3
ret

; END:draw_gsa

; BEGIN:draw_tetromino
draw_tetromino:
addi sp, sp, -28
stw ra, 0(sp)
stw s0, 4(sp)
stw s1, 8(sp)
stw s2, 12(sp)
stw s6, 16(sp)
stw s7, 20(sp)
stw s3, 24(sp)
ldw t0, T_X(zero) # x-intercept
ldw s3, T_Y(zero) # y-intercept
ldw t2, T_type(zero) #gets the number code of the share
ldw t3, T_orientation(zero) #get number for oritentation 

#addi s0, zero, 16
#mul s0, s0, t2
slli s0, t2, 4
#addi s6, zero, 4
#mul s6, s6, t3
slli s6, t3, 2
add s0, s0, s6

### GET X START
ldw s1, DRAW_Ax(s0) #receive a 3 word array 
### GET Y START
ldw s2, DRAW_Ay(s0)  #receive a 3 word array 

add t7, zero, a0
add a0, t0, zero
add a1, s3, zero
add a2, zero, t7

addi sp, sp, -8
stw a2, 0(sp)
stw t0, 4(sp)
call set_gsa
ldw a2, 0(sp)
ldw t0, 4(sp)
addi sp, sp, 8


addi t4,zero, 0 
addi s7, zero, 3
#addi a3, zero, 1
loop2: 
	ldw t5, 0(s1) #loading the first X coordinate
	add a0, t0, t5

	ldw t6, 0(s2) #loadinf the first Y coordinate 
	add a1, s3, t6

	addi sp, sp, -12
	stw a2, 0(sp)
	stw t0, 4(sp)
	stw t4, 8(sp)
	call set_gsa
	ldw a2, 0(sp)
	ldw t0, 4(sp)
	ldw t4, 8(sp)
	addi sp, sp, 12

	addi t4, t4, 1
	addi s1, s1, 4
	addi s2, s2, 4
	#addi a3, a3, 1
	bne t4, s7, loop2

ldw ra, 0(sp)
ldw s0, 4(sp)
ldw s1, 8(sp)
ldw s2, 12(sp)
ldw s6, 16(sp)
ldw s7, 20(sp)
ldw s3, 24(sp)
addi sp, sp, 28
ret
; END:draw_tetromino


; BEGIN:generate_tetromino 
generate_tetromino:
addi sp, sp, -4
stw ra, 0(sp)

GenerateNum:
	ldw t0, RANDOM_NUM(zero) # get random num 
	andi t0, t0, 0b111 # mask the 32b number into a 3b num
	addi t1, zero, 5 # compare to see if less than 5 (0,1,2,3,4 are valid only)
	bge t0, t1, GenerateNum #if not redo the numbr gen
 
addi t2, zero, 6 #set default start
stw t2, T_X(zero)

addi t2, zero, 1 # set default start 
stw t2, T_Y(zero)

addi t2, zero, 0 #set north as defalut orientation 
stw t2, T_orientation(zero)

add t2, t0, zero # set block type
stw t2, T_type(zero)

#call draw_tetromino

ldw ra, 0(sp)
addi sp, sp, 4
jmp ra 
; END:generate_tetromino


; BEGIN:detect_collision
detect_collision:
addi sp, sp, -36
stw ra, 0(sp)
stw s4, 4(sp)
stw s3, 8(sp)
stw s0, 12(sp)
stw s1, 16(sp)
stw s2, 20(sp)
stw s6, 24(sp)
stw s7, 28(sp)
stw s5, 32(sp)

addi s5, zero, PLACED #collsion if gsa == PLACED, store this constant
add s4, a0, zero #store the ORIGINAL argument 

addi t0, zero, 0
beq a0, t0, WcolCheck 

addi t0,t0,1
beq a0, t0, EcolCheck

addi t0, t0, 1
beq a0, t0, ScolCheck
#OVERLAP CHECK HERE
	##ADD CODE HERE

ldw t0, T_X(zero) # x-intercept
ldw s3, T_Y(zero) # y-intercept

addi a0, t0, 0
addi a1, s3, 0
call in_gsa
bne v0, zero, collision 
call get_gsa
beq v0, s5, collision 
ldw t2, T_type(zero) #gets the number code of the share
ldw t3, T_orientation(zero) #get number for oritentation  


#addi s0, zero, 16
#mul s0, s0, t2
slli s0, t2, 4
#addi s6, zero, 4
#mul s6, s6, t3
slli s6, t3, 2
add s0, s0, s6

### GET X START
ldw s1, DRAW_Ax(s0) #receive a 3 word array 
### GET Y START
ldw s2, DRAW_Ay(s0)  #receive a 3 word array 

addi t4,zero, 0 
addi s7, zero, 3
#addi a3, zero, 1
loop10: 
	ldw t1, 0(s1) #loading the first X coordinate
	add a0, t0, t1

	ldw t6, 0(s2) #loadinf the first Y coordinate 
	add a1, s3, t6

	addi sp, sp, -8
	stw t0, 0(sp)
	stw t4, 4(sp)
	call in_gsa
	ldw t0, 0(sp)
	ldw t4, 4(sp)
	addi sp, sp, 8
	bne v0, zero, collision
	addi sp, sp, -8
	stw t0, 0(sp)
	stw t4, 4(sp) 
	call get_gsa
	ldw t0, 0(sp)
	ldw t4, 4(sp)
	addi sp, sp, 8
	beq v0, s5, collision


	
	addi t4, t4, 1
	addi s1, s1, 4
	addi s2, s2, 4
	#addi a3, a3, 1
	bne t4, s7, loop10
	addi v0, zero, NONE
	ldw ra, 0(sp)
	ldw s4, 4(sp)
	ldw s3, 8(sp)
	ldw s0, 12(sp)
	ldw s1, 16(sp)
	ldw s2, 20(sp)
	ldw s6, 24(sp)
	ldw s7, 28(sp)
	ldw s5, 32(sp)
	addi sp, sp, 36
	ret
	
		
WcolCheck:
	ldw t0, T_X(zero)
	addi t0,t0, -1
	stw t0, T_X(zero)
	addi a0, zero, OVERLAP
	call detect_collision
	ldw t0, T_X(zero)
	addi t0, t0, 1
	stw t0, T_X(zero)
	jmpi checkResult

EcolCheck:
	ldw t0, T_X(zero)
	addi t0,t0, 1
	stw t0, T_X(zero)
	addi a0, zero, OVERLAP
	call detect_collision
	ldw t0, T_X(zero)
	addi t0,t0, -1
	stw t0, T_X(zero)
	jmpi checkResult

ScolCheck:
	ldw t0, T_Y(zero)
	addi t0, t0, 1
	stw t0, T_Y(zero)
	addi a0, zero, OVERLAP
	call detect_collision
	ldw t0, T_Y(zero)
	addi t0, t0, -1
	stw t0, T_Y(zero)
	jmpi checkResult

checkResult:
	addi t1, zero, NONE
	bne v0, t1, collision
	ldw ra, 0(sp)
	ldw s4, 4(sp)
	ldw s3, 8(sp)
	ldw s0, 12(sp)
	ldw s1, 16(sp)
	ldw s2, 20(sp)
	ldw s6, 24(sp)
	ldw s7, 28(sp)
	ldw s5, 32(sp)
	addi sp, sp, 36
	addi v0, zero, NONE
	ret

collision:
	add v0, s4, zero
	ldw ra, 0(sp)
	ldw s4, 4(sp)
	ldw s3, 8(sp)
	ldw s0, 12(sp)
	ldw s1, 16(sp)
	ldw s2, 20(sp)
	ldw s6, 24(sp)
	ldw s7, 28(sp)
	ldw s5, 32(sp)
	addi sp, sp, 36
	ret

; END:detect_collision

; BEGIN:rotate_tetromino
rotate_tetromino:
ldw t1, T_orientation(zero)
addi t0, zero, rotR
beq a0, t0, right
left:
addi t1, t1, -1
jmpi new_orientation

right:
addi t1, t1, 1

new_orientation:
andi t1, t1, 0x3
stw t1, T_orientation(zero)
ret
; END:rotate_tetromino

; BEGIN:act
act:
addi sp, sp, -8
stw ra, 0(sp)
stw s0, 4(sp)
addi v0, zero, 0

addi t0, zero, moveL #branching the move in argument
beq t0, a0, moveL_p
addi t0, zero, moveR
beq t0, a0, moveR_p
addi t0, zero, moveD
beq t0, a0, moveD_p
addi t0, zero, rotR
beq t0, a0, rotR_p
addi t0, zero, rotL
beq t0, a0, rotL_p

reset_p:
call reset_game
jmpi end_act

moveL_p:				#detect collision -and move the tetromino if no collisions
addi a0, zero, W_COL
call detect_collision
addi t0, zero, W_COL
beq v0, t0, missed
ldw t0, T_X(zero)
addi t0, t0, -1
stw t0, T_X(zero)
jmpi succeeded 

moveR_p:
addi a0, zero, E_COL
call detect_collision
addi t0, zero, E_COL 
beq v0, t0, missed
ldw t0, T_X(zero)
addi t0, t0, 1
stw t0, T_X(zero)
jmpi succeeded

moveD_p:
addi a0, zero, So_COL
call detect_collision
addi t0, zero, So_COL
beq v0, t0, missed
ldw t0, T_Y(zero)
addi t0, t0, 1
stw t0, T_Y(zero)
jmpi succeeded


rotR_p:
addi a0, zero, rotR
call rotate_tetromino
addi a0, zero, OVERLAP
call detect_collision
addi t0, zero, OVERLAP
bne v0, t0, succeeded
ldw s0, T_X(zero)
cmplti s0, s0, 6
bne s0, zero, try_again1
addi s0, zero, -1

try_again1:
ldw t0, T_X(zero)
add t0, t0, s0
stw t0, T_X(zero)
addi a0, zero, OVERLAP
call detect_collision
addi t0, zero, OVERLAP
bne v0, t0, succeeded

ldw t0, T_X(zero)
add t0, t0, s0
stw t0, T_X(zero)
addi a0, zero, OVERLAP
call detect_collision
addi t0, zero, OVERLAP
bne v0, t0, succeeded
slli s0, s0, 1
ldw t0, T_X(zero)
sub t0, t0, s0
stw t0, T_X(zero)
addi a0, zero, rotL
call rotate_tetromino
jmpi missed


rotL_p:
addi a0, zero, rotL
call rotate_tetromino
addi a0, zero, OVERLAP
call detect_collision
addi t0, zero, OVERLAP 
bne v0, t0, succeeded
ldw s0, T_X(zero)
cmplti s0, s0, 6
bne s0, zero, try_again
addi s0, zero, -1

try_again:
ldw t0, T_X(zero)
add t0, t0, s0
stw t0, T_X(zero)
addi a0, zero, OVERLAP
call detect_collision
addi t0, zero, OVERLAP
bne v0, t0, succeeded

ldw t0, T_X(zero)
add t0, t0, s0
stw t0, T_X(zero)
addi a0, zero, OVERLAP
call detect_collision
addi t0, zero, OVERLAP
bne v0, t0, succeeded
slli s0, s0, 1
ldw t0, T_X(zero)
sub t0, t0, s0
stw t0, T_X(zero)
addi a0, zero, rotR
call rotate_tetromino


missed:
addi v0, zero, 1
jmpi end_act


succeeded:
addi v0, zero, 0

end_act:
ldw ra, 0(sp)
ldw s0, 4(sp)
addi sp, sp, 8
ret
; END:act



; BEGIN:get_input
get_input:
addi v0, zero, 0 #default return value is 0
addi t4, zero, 4 
ldw t0, BUTTONS(t4)
addi t1, zero, 16 #value after 4 shift left
addi t2, zero, 1 #start by checking the leftmost bit

loop3:
and t3, t0, t2
bne t3, zero, move			#checking if the bit == 1
beq t2, t1, end_get_input	#checking if the loop is over 
slli t2, t2, 1 	#shift left by one to check the next bit
jmpi loop3

move:
add v0, zero, t2 #return the button acivated

end_get_input:
srli t0, t0, 5  #clearing edgeCapture
slli t0, t0, 5
stw t0, BUTTONS(t4)
ret
; END:get_input


; BEGIN:detect_full_line
detect_full_line:
addi v0, zero, 8 #default return value set at 8 (value if no line is full)
addi t5, zero, PLACED #we need to check if the tetromino is placed 
addi t2, zero, 7 #max y value
addi t0, zero, 0 #count for the first loop = y (from 0 to max y value = 7)

loop4:
add t1, zero, t0 #count for the 2nd loop : start value = y (goes from y to (8*11 + y) by step of 8 => corresponds to the adress in the gsa that we test
addi t3, t0, 88 #end value (8*11 + y)

loop5:
slli t1, t1, 2
ldw t4, GSA(t1)
srli t1, t1, 2
bne t4, t5, not_placed #no need to stay in the 2nd loop if an element is not placed
beq t1, t3, full_line_found #if count == end_value, then all elements are placed
addi t1, t1, 8 #the count is incremented by 8 (cf Figure 5)
jmpi loop5

not_placed:
beq t0, t2, end_dfl
addi t0, t0, 1 #if not finished, increment y
jmpi loop4

full_line_found:
add v0, zero, t0 #return value = y

end_dfl:
ret
; END:detect_full_line


; BEGIN:remove_full_line
remove_full_line:
addi sp, sp, -12
stw ra, 0(sp)
stw s1, 4(sp)
stw s0, 8(sp)
add s0, zero, a0 #copy of a0 before calling other functions
addi s1, zero, 5 #blinking repetitions

blinking:
addi a0, zero, 11 #count of the loop (value of x)
addi a1, s0, 0 #y coordinate
addi a2, zero, NOTHING #value of gsa word (start by switching off the lights)

loop6:
addi sp, sp, -12
stw a0, 0(sp)
stw a1, 4(sp)
stw a2, 8(sp)
call set_gsa
ldw a0, 0(sp)
ldw a1, 4(sp)
ldw a2, 8(sp)
addi sp, sp, 12
beq a0, zero, set_the_line
addi a0, a0, -1
jmpi loop6


set_the_line:
addi sp, sp, -12
stw a0, 0(sp)
stw a1, 4(sp)
stw a2, 8(sp)
call draw_gsa
call wait
ldw a0, 0(sp)
ldw a1, 4(sp)
ldw a2, 8(sp)
addi sp, sp, 12
addi s1, s1, -1
addi a2, a2, 1 #set gsa value to placed when nothing and
andi a2, a2, 1 #to nothing when placed
addi a0, zero, 11 #reset x coordinate
bne s1, zero, loop6

addi a1, s0, 0 #restore value of y
get_pixels_down:
beq a1, zero, end_rfl
addi a1, a1, -1 #decrease y to get the above values in gsa
addi a0, zero, 11 #loop count = x 

loop7:

addi sp, sp, -12
stw a0, 0(sp)
stw a1, 4(sp)
stw a2, 8(sp)
call get_gsa
ldw a0, 0(sp)
ldw a1, 4(sp)
ldw a2, 8(sp)
addi sp, sp, 12

bne v0, zero, down #upload the pixels if not equal to NOTHING
beq a0, zero, get_pixels_down
addi a0, a0, -1
jmpi loop7


down:
addi a2, zero, NOTHING

addi sp, sp, -12
stw a0, 0(sp)
stw a1, 4(sp)
stw a2, 8(sp)
call set_gsa #clear the current pixel
ldw a0, 0(sp)
ldw a1, 4(sp)
ldw a2, 8(sp)
addi sp, sp, 12
  
addi a1, a1, 1
addi a2, zero, PLACED #setting to falling the pixel under

addi sp, sp, -12
stw a0, 0(sp)
stw a1, 4(sp)
stw a2, 8(sp)
call set_gsa
ldw a0, 0(sp)
ldw a1, 4(sp)
ldw a2, 8(sp)
addi sp, sp, 12

addi a1, a1, -1
beq a0, t1, get_pixels_down
addi a0, a0, 1
jmpi loop7

end_rfl:
ldw ra, 0(sp)
ldw s1, 4(sp)
ldw s0, 8(sp)
addi sp, sp, 12
ret
; END:remove_full_line


; BEGIN:increment_score
increment_score:
ldw t0, SCORE(zero)
addi t1, zero, 9999
beq t0, t1, max_value_reached 
addi t0, t0, 1
jmpi end_inc_score

max_value_reached:
addi t0, zero, 0

end_inc_score:
stw t0, SCORE(zero)
ret
; END:increment_score


; BEGIN:display_score
display_score:
ldw t0, SCORE(zero)
addi sp, sp, -12
addi t1, zero, 1
stw t1, 8(sp)
addi t1, zero, 10 #push the next values of the comparator
stw t1, 4(sp)
addi t1, zero, 100
stw t1, 0(sp)
addi t1, zero, 1000 #initial value for the comparator
addi t2, zero, 0 #loop count (value of each digit)
addi t3, zero, 1 #end value for the loop
addi t4, zero, SEVEN_SEGS #start adress for segments

loop8:
blt t0, t1, next_digit
sub t0, t0, t1
addi t2, t2, 1
jmpi loop8


next_digit:
slli t2, t2, 2
ldw t2, font_data(t2)
stw t2, 0(t4)
addi t4, t4, 4 #next segement adress
beq t1, t3, end_display_score
ldw t1, 0(sp) #pop next comparator value
addi sp, sp, 4
addi t2, zero, 0 #reset loop counter
jmpi loop8

end_display_score:
ret
; END:display_score

; BEGIN:reset_game
reset_game:
addi sp, sp, -4 #score is reset
stw ra, 0(sp)
addi t0, zero, 0
stw t0, SCORE(zero)
addi t1, zero, SEVEN_SEGS
addi t0, zero, 0xFC
stw t0, 0(t1)
stw t0, 4(t1)
stw t0, 8(t1)
stw t0, 12(t1)

#GSA is set to 0
addi t0, zero, 0
addi t1, zero, GSA
addi t2, zero, 96
loop9:
	stw t0, 0(t1)
	addi t1, t1, 4
	addi t2, t2, -1
	bne t2, zero, loop9

# new tetromino is generated
call generate_tetromino 

#LEDs are lit to GSA
addi a0, zero, FALLING
call draw_tetromino
call draw_gsa
ldw ra, 0(sp)
addi sp, sp, 4
ret
; END:reset_game

; BEGIN:main
main:
addi sp, zero, 0x1FFC

begin:
call reset_game

outer_loop:

	inner_loop:
		addi s0, zero, RATE
		while:
			call draw_gsa
			call display_score
			addi a0, zero, NOTHING
			call draw_tetromino
			call wait
			call get_input
			beq v0, zero, draw
			addi a0, v0, 0
			call act
			draw:
			addi a0, zero, FALLING
			call draw_tetromino
			addi s0, s0, -1
		bne s0, zero, while
		addi a0, zero, NOTHING
		call draw_tetromino
		addi a0, zero, moveD
		call act
		call wait
		bne v0, zero, failed
		addi a0, zero, FALLING
		call draw_tetromino
	beq v0, zero, inner_loop
	failed:
	addi a0, zero, PLACED
	call draw_tetromino
	addi s0, zero, 8 #y value to leave the while 
	while2:
		call detect_full_line
		beq v0, s0, next
		addi a0, v0, 0
		call wait
		call remove_full_line
		call increment_score
		jmpi while2
	next:
	call generate_tetromino
	addi a0, zero, OVERLAP
	addi s0, a0, 0
	call detect_collision
	beq v0, s0, endgame
	addi a0, zero, FALLING
	call draw_tetromino
	jmpi outer_loop
	
endgame: 
jmpi begin
; END:main

#####################################################################

font_data:
    .word 0xFC  ; 0
    .word 0x60  ; 1
    .word 0xDA  ; 2
    .word 0xF2  ; 3
    .word 0x66  ; 4
    .word 0xB6  ; 5
    .word 0xBE  ; 6
    .word 0xE0  ; 7
    .word 0xFE  ; 8
    .word 0xF6  ; 9

C_N_X:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

C_N_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0xFFFFFFFF

C_E_X:
  .word 0x01
  .word 0x00
  .word 0x01

C_E_Y:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

C_So_X:
  .word 0x01
  .word 0x00
  .word 0x01

C_So_Y:
  .word 0x00
  .word 0x01
  .word 0x01

C_W_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0xFFFFFFFF

C_W_Y:
  .word 0x00
  .word 0x01
  .word 0x01

B_N_X:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x02

B_N_Y:
  .word 0x00
  .word 0x00
  .word 0x00

B_E_X:
  .word 0x00
  .word 0x00
  .word 0x00

B_E_Y:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x02

B_So_X:
  .word 0xFFFFFFFE
  .word 0xFFFFFFFF
  .word 0x01

B_So_Y:
  .word 0x00
  .word 0x00
  .word 0x00

B_W_X:
  .word 0x00
  .word 0x00
  .word 0x00

B_W_Y:
  .word 0xFFFFFFFE
  .word 0xFFFFFFFF
  .word 0x01

T_N_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

T_N_Y:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0x00

T_E_X:
  .word 0x00
  .word 0x01
  .word 0x00

T_E_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

T_So_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

T_So_Y:
  .word 0x00
  .word 0x01
  .word 0x00

T_W_X:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0x00

T_W_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

S_N_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

S_N_Y:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

S_E_X:
  .word 0x00
  .word 0x01
  .word 0x01

S_E_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

S_So_X:
  .word 0x01
  .word 0x00
  .word 0xFFFFFFFF

S_So_Y:
  .word 0x00
  .word 0x01
  .word 0x01

S_W_X:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

S_W_Y:
  .word 0x01
  .word 0x00
  .word 0xFFFFFFFF

L_N_X:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x01

L_N_Y:
  .word 0x00
  .word 0x00
  .word 0xFFFFFFFF

L_E_X:
  .word 0x00
  .word 0x00
  .word 0x01

L_E_Y:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x01

L_So_X:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0xFFFFFFFF

L_So_Y:
  .word 0x00
  .word 0x00
  .word 0x01

L_W_X:
  .word 0x00
  .word 0x00
  .word 0xFFFFFFFF

L_W_Y:
  .word 0x01
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

DRAW_Ax:                        ; address of shape arrays, x axis
    .word C_N_X
    .word C_E_X
    .word C_So_X
    .word C_W_X
    .word B_N_X
    .word B_E_X
    .word B_So_X
    .word B_W_X
    .word T_N_X
    .word T_E_X
    .word T_So_X
    .word T_W_X
    .word S_N_X
    .word S_E_X
    .word S_So_X
    .word S_W_X
    .word L_N_X
    .word L_E_X
    .word L_So_X
    .word L_W_X

DRAW_Ay:                        ; address of shape arrays, y_axis
    .word C_N_Y
    .word C_E_Y
    .word C_So_Y
    .word C_W_Y
    .word B_N_Y
    .word B_E_Y
    .word B_So_Y
    .word B_W_Y
    .word T_N_Y
    .word T_E_Y
    .word T_So_Y
    .word T_W_Y
    .word S_N_Y
    .word S_E_Y
    .word S_So_Y
    .word S_W_Y
    .word L_N_Y
    .word L_E_Y
    .word L_So_Y
    .word L_W_Y